//
//  MTZRadialMenu.m
//
//  Created by Matt Zanchelli on 6/11/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZRadialMenu.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

#define RADIALMENU_OPEN_ANIMATION_DURATION 0.52
#define RADIALMENU_OPEN_ANIMATION_DAMPING 0.7
#define RADIALMENU_OPEN_ANIMATION_INITIAL_VELOCITY 0.35

#define RADIALMENU_CLOSE_ANIMATION_DURATION 0.4
#define RADIALMENU_CLOSE_ANIMATION_DAMPING 1
#define RADIALMENU_CLOSE_ANIMATION_INITIAL_VELOCITY 0.4

#define RADIALMENU_BUTTON_RADIUS 15
#define RADIALMENU_RADIUS_CONTRACTED 15
#define RADIALMENU_RADIUS_NORMAL 105
#define RADIALMENU_RADIUS_EXPANDED 120

#define RADIALMENU_BUTTON_PADDING 8

@interface MTZAction ()

///
@property (nonatomic, getter=isStandardType) BOOL standardType;

///
@property (nonatomic) MTZActionType type;

///
@property (nonatomic, copy) UIImage *image;

///
@property (nonatomic, copy) UIImage *highlightedImage;

///
@property (nonatomic, weak) void (^handler)(MTZAction *);

@end

@implementation MTZAction

#pragma mark Creating an Action

+ (instancetype)actionOfType:(MTZActionType)type handler:(void (^)(MTZAction *action))handler
{
	MTZAction *action = [[MTZAction alloc] init];
	action.standardType = YES;
	action.type = type;
	action.handler = handler;
	return action;
}

+ (instancetype)actionWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage handler:(void (^)(MTZAction *action))handler
{
	MTZAction *action = [[MTZAction alloc] init];
	action.standardType = NO;
	action.image = image;
	action.highlightedImage = highlightedImage;
	action.handler = handler;
	return action;
}

@end


@interface MTZTouchGestureRecognizer : UIGestureRecognizer
@end

@implementation MTZTouchGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ( self.state == UIGestureRecognizerStatePossible ) {
		self.state = UIGestureRecognizerStateBegan;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.state = UIGestureRecognizerStateCancelled;
}

@end


/// The state of a radial menu.
typedef enum {
	// Contracted is the smallest size, used when hidden.
	MTZRadialMenuStateContracted,
	// Normal is the state while the menu is visible and not being interacted with.
	MTZRadialMenuStateNormal,
	// Expanding is the state while the menu is being interacted with and expanded.
	MTZRadialMenuStateExpanding
} MTZRadialMenuState;

/// A simple description string for a given location.
NSString *descriptionStringForLocation(MTZRadialMenuLocation location)
{
	switch (location) {
		case MTZRadialMenuLocationTop:    return @"MTZRadialMenuLocationTop";
		case MTZRadialMenuLocationLeft:   return @"MTZRadialMenuLocationLeft";
		case MTZRadialMenuLocationRight:  return @"MTZRadialMenuLocationRight";
		case MTZRadialMenuLocationBottom: return @"MTZRadialMenuLocationBottom";
	}
}

CGFloat CGPointDistance(CGPoint a, CGPoint b)
{
	return sqrt(pow((a.x - b.x), 2) + pow((a.y - b.y), 2));
}

@interface MTZRadialMenu ()

/// The actions for locations.
@property (strong, nonatomic) NSMutableDictionary *actions;

/// Action buttons corresponding to locations.
@property (strong, nonatomic) NSMutableDictionary *actionButtons;

/// The radial menu.
@property (strong, nonatomic) UIView *radialMenu;

/// The main button to activate the radial menu.
@property (strong, nonatomic) UIButton *button;

/// The action buttons.
@property (strong,  nonatomic) UIButton *topButton, *leftButton, *rightButton, *bottomButton;

/// A Boolean value that indicates whether the menu is displayed.
@property (nonatomic, readwrite, getter=isMenuVisible) BOOL menuVisible;

/// A Boolean value that indicates whether the menu is currently animating.
@property (nonatomic, getter=isMenuAnimating) BOOL menuAnimating;

/// The radius of the radial menu.
@property (nonatomic) CGFloat menuRadius;

/// The state of the menu.
@property (nonatomic) MTZRadialMenuState menuState;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (strong, nonatomic) MTZTouchGestureRecognizer *touchGestureRecognizer;

@end


@implementation MTZRadialMenu

#pragma mark Initialization & Setup

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self __MTZRadialMenuSetup];
    }
    return self;
}

- (instancetype)init
{
	self = [super initWithFrame:CGRectMake(0, 0, 2*RADIALMENU_BUTTON_RADIUS, 2*RADIALMENU_BUTTON_RADIUS)];
	if (self) {
		// Initialization code
		[self __MTZRadialMenuSetup];
	}
	return self;
}

+ (UIButton *)newActionButton
{
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 2*RADIALMENU_BUTTON_RADIUS, 2*RADIALMENU_BUTTON_RADIUS)];
	button.hidden = YES; // Hidden by default.
	return button;
}

- (void)__MTZRadialMenuSetup
{
	// The radial menu will extend beyond the bounds of the original button.
	self.clipsToBounds = NO;
	
	// Data
	self.actions = [[NSMutableDictionary alloc] initWithCapacity:3];
	self.menuVisible = NO;
	self.menuAnimating = NO;
	self.menuState = MTZRadialMenuStateContracted;
	
	// Radial menu
	self.radialMenu = [[UIView alloc] init];
	[self addSubview:self.radialMenu];
	self.radialMenu.clipsToBounds = YES;
	self.radialMenu.alpha = 0.0f;
	self.menuRadius = RADIALMENU_RADIUS_CONTRACTED;
	
	UIImageView *radialMenuBackground = [[UIImageView alloc] initWithFrame:self.radialMenu.bounds];
	radialMenuBackground.image = [UIImage imageNamed:@"MenuBackground"];
	radialMenuBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.radialMenu addSubview:radialMenuBackground];
	
	// Action buttons
	self.actionButtons = [[NSMutableDictionary alloc] initWithCapacity:4];
	
	// Top button
	UIButton *topButton = [MTZRadialMenu newActionButton];
	[self.radialMenu addSubview:topButton];
	self.actionButtons[descriptionStringForLocation(MTZRadialMenuLocationTop)] = topButton;
	{
		CGRect frame = topButton.frame;
		frame.origin.y = RADIALMENU_BUTTON_PADDING;
		topButton.frame = frame;
	}
	topButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	
	// Left button
	UIButton *leftButton = [MTZRadialMenu newActionButton];
	[self.radialMenu addSubview:leftButton];
	self.actionButtons[descriptionStringForLocation(MTZRadialMenuLocationLeft)] = leftButton;
	{
		CGRect frame = leftButton.frame;
		frame.origin.x = RADIALMENU_BUTTON_PADDING;
		leftButton.frame = frame;
	}
	leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	// Right button
	UIButton *rightButton = [MTZRadialMenu newActionButton];
	[self.radialMenu addSubview:rightButton];
	self.actionButtons[descriptionStringForLocation(MTZRadialMenuLocationRight)] = rightButton;
	{
		CGRect frame = rightButton.frame;
		frame.origin.x = self.radialMenu.bounds.size.width - RADIALMENU_BUTTON_PADDING - frame.size.width;
		rightButton.frame = frame;
	}
	rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	// Bottom button
	UIButton *bottomButton = [MTZRadialMenu newActionButton];
	[self.radialMenu addSubview:bottomButton];
	self.actionButtons[descriptionStringForLocation(MTZRadialMenuLocationBottom)] = bottomButton;
	{
		CGRect frame = bottomButton.frame;
		frame.origin.y = self.radialMenu.bounds.size.height - RADIALMENU_BUTTON_PADDING - frame.size.height;
		bottomButton.frame = frame;
	}
	bottomButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	
	// Main button
	self.button = [[UIButton alloc] initWithFrame:self.bounds];
	[self addSubview:self.button];
	self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Gestures
//	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapButton:)];
//	[self addGestureRecognizer:tap];
	self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressButton:)];
	[self.button addGestureRecognizer:self.longPressGestureRecognizer];
//	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
//	pan.maximumNumberOfTouches = 1;
//	[self addGestureRecognizer:pan];
	self.touchGestureRecognizer = [[MTZTouchGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
	self.touchGestureRecognizer.enabled = NO;
	[self addGestureRecognizer:self.touchGestureRecognizer];
}

#pragma mark Properties

- (void)setMenuRadius:(CGFloat)radius
{
	_menuRadius = radius;
	self.radialMenu.frame = CGRectMake((self.bounds.size.width/2) - _menuRadius,
									   (self.bounds.size.height/2) - _menuRadius,
									   2 * _menuRadius,
									   2 * _menuRadius);
}

#pragma mark Responding to Gestures & Touches

- (void)didTapButton:(UIGestureRecognizer *)sender
{
	// Only recognizes the ended state.
	if (sender.state != UIGestureRecognizerStateEnded) return;
	
	if ( self.menuVisible || self.menuAnimating ) {
		[self dismissMenuAnimated:YES];
	} else {
		// TODO: Perform regular tap action.
	}
}

- (void)didLongPressButton:(UIGestureRecognizer *)sender
{
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			[self displayMenu];
			break;
		case UIGestureRecognizerStateChanged:
			[self didPan:sender];
			break;
		case UIGestureRecognizerStateEnded:
			[self didPan:sender];
			self.touchGestureRecognizer.enabled = YES;
			self.longPressGestureRecognizer.enabled = NO;
			break;
		case UIGestureRecognizerStateCancelled:
		default:
			[self dismissMenuAnimated:YES];
			break;
	}
}

- (void)didPan:(UIGestureRecognizer *)sender
{
	// Do not do anything if the menu isn't visible.
	if ( !self.menuVisible ) return;
	
	CGPoint point = [sender locationInView:self.radialMenu];
	CGFloat distance = [self distanceOfPointFromCenter:point];
	
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
		case UIGestureRecognizerStateChanged: {
			if ( distance >= 180 ) {
				if ( self.menuState != MTZRadialMenuStateNormal ) {
					[self returnMenuToNormalRadius];
				}
			} else {
				CGFloat radius = radiusForDistance(distance);
				if ( self.menuState == MTZRadialMenuStateExpanding ) {
					self.menuRadius = radius;
				} else {
					self.menuState = MTZRadialMenuStateExpanding;
					[UIView animateWithDuration:0.3
										  delay:0
						 usingSpringWithDamping:1.0
						  initialSpringVelocity:0.3
										options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
									 animations:^{
										 self.menuRadius = radius;
									 }
									 completion:^(BOOL finished) {}];
				}
			}
		} break;
		case UIGestureRecognizerStateEnded:
			// Released touch, see if it is on an action.
			if ( NO ) {
				// Selected an action
			} else if ( NO ) {
				// Left radial menu
				[self dismissMenuAnimated:YES];
			} else {
				// Still on menu, didn't select an action, though.
				[self returnMenuToNormalRadius];
			}
			break;
		case UIGestureRecognizerStateCancelled:
		default:
			[self returnMenuToNormalRadius];
			break;
	}
}

- (void)returnMenuToNormalRadius
{
	self.menuState = MTZRadialMenuStateNormal;
	
	[UIView animateWithDuration:0.45
						  delay:0
		 usingSpringWithDamping:0.6
		  initialSpringVelocity:0
						options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 self.menuRadius = RADIALMENU_RADIUS_NORMAL;
					 }
					 completion:^(BOOL finished) {}];
}

CGFloat radiusForDistance(CGFloat distance)
{
	CGFloat percentage = distance / RADIALMENU_RADIUS_EXPANDED;
	CGFloat difference = RADIALMENU_RADIUS_EXPANDED - RADIALMENU_RADIUS_NORMAL;
	CGFloat radius = RADIALMENU_RADIUS_NORMAL + (easingCurveForPercentage(percentage) * difference);
	return radius;
}

CGFloat easingCurveForPercentage(CGFloat percentage)
{
	// y = x
	return percentage;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	CGPoint convertedPoint = [self.radialMenu convertPoint:point fromView:self];
	return [self.radialMenu pointInside:convertedPoint withEvent:event];
}

/// Find the distance of a point from the center of the radial menu.
/// @param point The point in terms of the radial menu's bounds.
/// @return The distance of the point to the center of the radial menu.
- (CGFloat)distanceOfPointFromCenter:(CGPoint)point
{
	CGPoint center = CGPointMake(self.radialMenu.bounds.size.width/2, self.radialMenu.bounds.size.height/2);
	return CGPointDistance(point, center);
}

#pragma mark Configuring the Main Button Presentation

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
	[_button setImage:image forState:state];
}

- (UIImage *)imageForState:(UIControlState)state
{
	return [_button imageForState:state];
}

- (void)setImageEdgeInsets:(UIEdgeInsets)insets
{
	self.button.imageEdgeInsets = insets;
}

- (UIEdgeInsets)imageEdgeInsets
{
	return self.button.imageEdgeInsets;
}

#pragma mark Configuring the User Actions

/// Sets the action for a particular location on the receiving radial menu.
/// @param action The action to add to the radial menu.
/// @param location The location on the radial menu to position this action.
- (void)setAction:(MTZAction *)action forLocation:(MTZRadialMenuLocation)location
{
	NSString *locationKey = descriptionStringForLocation(location);
	UIButton *actionButton = self.actionButtons[locationKey];
	
	if ( !action ) {
		[self.actions removeObjectForKey:locationKey];
		actionButton.hidden = YES;
	} else {
		self.actions[locationKey] = action;
		actionButton.hidden = NO;
	}
	
	UIImage *image = nil;
	UIImage *highlightedImage = nil;
	if ( action.isStandardType ) {
		// TODO: Look up standard graphic resources for type.
	} else {
		image = action.image;
		highlightedImage = action.highlightedImage;
	}
	[actionButton setImage:image forState:UIControlStateNormal];
	[actionButton setImage:highlightedImage forState:UIControlStateHighlighted];
}

/// Returns the actino for a particular location on the receiving radial menu.
- (MTZAction *)actionForLocation:(MTZRadialMenuLocation)location
{
	return self.actions[descriptionStringForLocation(location)];
}

#pragma mark Display & Dismissal

- (void)displayMenu
{
	if ( self.menuVisible && !self.menuAnimating ) return;
	
	self.menuAnimating = YES;
	
	void (^animations)() = ^void() {
		self.menuRadius = RADIALMENU_RADIUS_NORMAL;
		self.radialMenu.alpha = 1.0f;
	};
	
	void (^completion)(BOOL) = ^void(BOOL finished) {
		if ( finished ) {
			self.menuVisible = YES;
			self.menuState = MTZRadialMenuStateNormal;
			self.menuAnimating = NO;
		}
	};
	
	[UIView animateWithDuration:RADIALMENU_OPEN_ANIMATION_DURATION
						  delay:0
		 usingSpringWithDamping:RADIALMENU_OPEN_ANIMATION_DAMPING
		  initialSpringVelocity:RADIALMENU_OPEN_ANIMATION_INITIAL_VELOCITY
						options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
					 animations:animations
					 completion:completion];
}

- (void)dismissMenuAnimated:(BOOL)animated
{
	if ( !self.menuVisible && !self.menuAnimating ) return;
	
	self.menuAnimating = YES;
	
	void (^animations)() = ^void() {
		self.menuRadius = RADIALMENU_RADIUS_CONTRACTED;
		self.radialMenu.alpha = 0.0f;
	};
	
	void (^completion)(BOOL) = ^void(BOOL finished) {
		if ( finished ) {
			self.menuVisible = NO;
			self.menuState = MTZRadialMenuStateContracted;
			self.menuAnimating = NO;
		}
	};
	
	[UIView animateWithDuration:animated ? RADIALMENU_CLOSE_ANIMATION_DURATION : 0
						  delay:0
		 usingSpringWithDamping:RADIALMENU_CLOSE_ANIMATION_DAMPING
		  initialSpringVelocity:RADIALMENU_CLOSE_ANIMATION_INITIAL_VELOCITY
						options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
					 animations:animations
					 completion:completion];
}

- (void)setMenuVisible:(BOOL)menuVisible
{
	_menuVisible = menuVisible;
	if ( !_menuVisible ) {
		self.touchGestureRecognizer.enabled = NO;
		self.longPressGestureRecognizer.enabled = YES;
	}
}

@end
