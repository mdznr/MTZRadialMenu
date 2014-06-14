//
//  MTZRadialMenu.m
//
//  Created by Matt Zanchelli on 6/11/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZRadialMenu.h"

#import "MTZButton.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

#define RADIALMENU_OPEN_ANIMATION_DURATION 0.52
#define RADIALMENU_OPEN_ANIMATION_DAMPING 0.7
#define RADIALMENU_OPEN_ANIMATION_INITIAL_VELOCITY 0.35

#define RADIALMENU_CLOSE_ANIMATION_DURATION 0.4
#define RADIALMENU_CLOSE_ANIMATION_DAMPING 1
#define RADIALMENU_CLOSE_ANIMATION_INITIAL_VELOCITY 0.4

#define RADIALMENU_EXPANDING_ANIMATION_DURATION 0.5
#define RADIALMENU_EXPANDING_ANIMATION_DAMPING 1.0
#define RADIALMENU_EXPANDING_ANIMATION_INITIAL_VELOCITY 0

#define RADIALMENU_UNEXPANDING_ANIMATION_DURATION 0.3
#define RADIALMENU_UNEXPANDING_ANIMATION_DAMPING 1.0
#define RADIALMENU_UNEXPANDING_ANIMATION_INITIAL_VELOCITY 0.3

#define RADIALMENU_BUTTON_RADIUS 15
#define RADIALMENU_RADIUS_CONTRACTED 15
#define RADIALMENU_RADIUS_NORMAL 105
#define RADIALMENU_RADIUS_EXPANDED 120

#define RADIALMENU_BUTTON_PADDING 8

@interface MTZAction ()

/// A Boolean value representing whether the action is a standard type.
@property (nonatomic, getter=isStandardType) BOOL standardType;

/// The type of standard action, if any.
/// @discussion Check @c standardType to see if this will be a valid action type.
@property (nonatomic) MTZActionType type;

/// The image to use for the normal state.
@property (nonatomic, copy) UIImage *image;

/// The image to use for the highlighted state.
@property (nonatomic, copy) UIImage *highlightedImage;

/// The handler for when the action is selected.
@property (nonatomic, weak) void (^handler)(MTZRadialMenu *radialMenu, MTZAction *action);

@end

@implementation MTZAction

#pragma mark Creating an Action

+ (instancetype)actionOfType:(MTZActionType)type handler:(void (^)(MTZRadialMenu *radialMenu, MTZAction *action))handler
{
	MTZAction *action = [[MTZAction alloc] init];
	action.standardType = YES;
	action.type = type;
	action.handler = handler;
	return action;
}

+ (instancetype)actionWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage handler:(void (^)(MTZRadialMenu *radialMenu, MTZAction *action))handler
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
	// Expanded is the state while an outer menu item is highlighted.
	MTZRadialMenuStateExpanded
} MTZRadialMenuState;

/// A simple description string for a given location.
NSString *descriptionStringForLocation(MTZRadialMenuLocation location)
{
	switch (location) {
		case MTZRadialMenuLocationCenter: return @"MTZRadialMenuLocationCenter";
		case MTZRadialMenuLocationTop:    return @"MTZRadialMenuLocationTop";
		case MTZRadialMenuLocationLeft:   return @"MTZRadialMenuLocationLeft";
		case MTZRadialMenuLocationRight:  return @"MTZRadialMenuLocationRight";
		case MTZRadialMenuLocationBottom: return @"MTZRadialMenuLocationBottom";
		default: return nil;
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
@property (strong, nonatomic) MTZButton *button;

/// The action buttons.
@property (strong,  nonatomic) UIButton *centerButton, *topButton, *leftButton, *rightButton, *bottomButton;

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
	CGRect frame = CGRectMake(0, 0, 2 * RADIALMENU_BUTTON_RADIUS, 2 * RADIALMENU_BUTTON_RADIUS);
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = frame;
	button.hidden = YES; // Hidden by default.
	return button;
}

- (void)__MTZRadialMenuSetup
{
	// The radial menu will extend beyond the bounds of the original button.
	self.clipsToBounds = NO;
	
	// Data
	self.actions = [[NSMutableDictionary alloc] initWithCapacity:3];
	self.menuAnimating = NO;
	self.menuVisible = NO;
	self.menuState = MTZRadialMenuStateContracted;
	
	// Radial menu
	self.radialMenu = [[UIView alloc] init];
	[self addSubview:self.radialMenu];
	self.radialMenu.clipsToBounds = YES;
	self.radialMenu.alpha = 0.0f;
	self.menuRadius = RADIALMENU_RADIUS_CONTRACTED;
	
	UIImageView *radialMenuBackground = [[UIImageView alloc] initWithFrame:self.radialMenu.bounds];
	radialMenuBackground.image = [UIImage imageNamed:@"MTZRadialMenuBackground"];
	radialMenuBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.radialMenu addSubview:radialMenuBackground];
	
	// Action buttons
	self.actionButtons = [[NSMutableDictionary alloc] initWithCapacity:4];
	
	// Center button
	UIButton *centerButton = [MTZRadialMenu newActionButton];
	[self.radialMenu addSubview:centerButton];
	self.actionButtons[descriptionStringForLocation(MTZRadialMenuLocationCenter)] = centerButton;
	{
		CGRect frame = centerButton.frame;
		frame.origin.x = (self.radialMenu.bounds.size.width - frame.size.width)/2;
		frame.origin.y = (self.radialMenu.bounds.size.height - frame.size.height)/2;
		centerButton.frame = frame;
	}
	centerButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
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
	self.button = [MTZButton buttonWithType:UIButtonTypeCustom];
	self.button.frame = self.bounds;
	[self insertSubview:self.button belowSubview:self.radialMenu];
	self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Gestures
	self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressButton:)];
	[self.button addGestureRecognizer:self.longPressGestureRecognizer];
	self.touchGestureRecognizer = [[MTZTouchGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch:)];
	self.touchGestureRecognizer.enabled = NO;
	[self addGestureRecognizer:self.touchGestureRecognizer];
}

#pragma mark Responding to Gestures & Touches

- (void)didLongPressButton:(UIGestureRecognizer *)sender
{
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			[self highlightLocation:MTZRadialMenuLocationCenter];
			[self displayMenu];
		case UIGestureRecognizerStateChanged:
			[self didTouch:sender];
			break;
		case UIGestureRecognizerStateEnded:
			[self didTouch:sender];
			self.touchGestureRecognizer.enabled = YES;
			self.longPressGestureRecognizer.enabled = NO;
			break;
		case UIGestureRecognizerStateCancelled:
			[self dismissMenuAnimated:YES];
			break;
		default:
			break;
	}
}

- (void)didTouch:(UIGestureRecognizer *)sender
{
	// Do not do anything if the menu isn't visible.
	if ( !self.menuVisible ) return;
	
	CGPoint point = [sender locationInView:self.radialMenu];
	CGFloat distance = [self distanceOfPointFromCenter:point];
	
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			if ( distance >= RADIALMENU_RADIUS_EXPANDED * 1.5 ) {
				[self dismissMenuAnimated:YES];
				break;
			}
		case UIGestureRecognizerStateChanged: {
			MTZRadialMenuLocation location = [self locationForPoint:point];
			MTZAction *action = [self actionForLocation:location];
			if ( location == MTZRadialMenuLocationCenter ) {
				// Highlighting center action.
				self.menuState = MTZRadialMenuStateNormal;
			} else if ( location < 0 ) {
				// Outside the radial menu.
				self.menuState = MTZRadialMenuStateNormal;
			} else {
				// Possibly highlighting outer actions.
				if ( action ) {
					// Highlighting an action on the outer ring.
					self.menuState = MTZRadialMenuStateExpanded;
				} else {
					// Valid location, but nothing's there.
					self.menuState = MTZRadialMenuStateNormal;
					// From here on out, use the center location.
					location = MTZRadialMenuLocationCenter;
				}
			}
			[self highlightLocation:location];
		} break;
		case UIGestureRecognizerStateEnded: {
			// Released touch, see if it is on an action.
			MTZRadialMenuLocation location = [self locationForPoint:point];
			
			// Outside the menu, close it.
			if ( location < 0 ) {
				self.menuState = MTZRadialMenuStateContracted;
			} else {
				self.menuState = MTZRadialMenuStateNormal;
			}
			// Don't highlight anything.
			[self highlightLocation:-1];
			// Set the location to be selected.
			[self selectLocation:location];
		} break;
		case UIGestureRecognizerStateCancelled:
			// TODO: If still on the original gesture to open the menu, close it (return to state before gesture started)
			self.menuState = MTZRadialMenuStateNormal;
			break;
		default:
			break;
	}
}

- (void)highlightLocation:(MTZRadialMenuLocation)location
{
	NSString *locationKey = descriptionStringForLocation(location);
	for ( NSString *key in self.actionButtons.allKeys ) {
		UIButton *button = self.actionButtons[key];
		BOOL highlighted = key == locationKey;
		if ( button.highlighted != highlighted ) {
			button.highlighted = highlighted;
		}
	}
}

- (void)selectLocation:(MTZRadialMenuLocation)location
{
	MTZAction *action = [self actionForLocation:location];
	action = action ? action : [self actionForLocation:MTZRadialMenuLocationCenter];
	if ( action ) {
		// Act on it!
		action.handler(self, action);
	} else {
		// Something weird happened, dismiss the menu.
		[self dismissMenuAnimated:YES];
	}
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	if ( self.exclusiveTouch ) { return YES; }
	
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

/// Find the point relative to the center of the radial menu.
/// @param point The point in terms of the radial menu's bounds.
/// @return The adjusted point relative to the center of the radial menu.
- (CGPoint)pointRelativeToCenter:(CGPoint)point
{
	CGPoint center = CGPointMake(self.radialMenu.bounds.size.width/2, self.radialMenu.bounds.size.height/2);
	return CGPointMake(point.x - center.x, point.y - center.y);
}

/// Find the corresponding location for a point on a radial menu.
/// @param point The point inside the radial menu (with respect to the bounds).
/// @return The location in the radial menu the point maps to or -1, if nothing found.
- (MTZRadialMenuLocation)locationForPoint:(CGPoint)point
{
	CGFloat distance = [self distanceOfPointFromCenter:point];
	
	if ( distance >= RADIALMENU_RADIUS_EXPANDED * 1.5 ) {
		// It's outside the radial menu.
		return -1;
	} else if ( distance < 48 ) {
		// It's the center of the radial menu.
		return MTZRadialMenuLocationCenter;
	} else {
		// It must be one of the other locations.
		
		// Size of the radialMenu
		CGSize size = self.radialMenu.bounds.size;
		// Coordinates on a 0 to 1 scale.
		CGFloat x = point.x / size.width;
		CGFloat y = point.y / size.height;
		// Where can it be? Let's narrow it down.
		BOOL topOrRight = y < x;
		BOOL bottomOrRight = (1-y) < x;
		if ( topOrRight ) {
			return bottomOrRight ? MTZRadialMenuLocationRight : MTZRadialMenuLocationTop;
		} else {
			return bottomOrRight ? MTZRadialMenuLocationBottom : MTZRadialMenuLocationLeft;
		}
	}
}

#pragma mark Menu State

- (void)setMenuState:(MTZRadialMenuState)menuState
{
	// Only apply if menu state has changed.
	if ( _menuState == menuState ) return;
	
	// Animate changes.
	switch (_menuState) {
		// Contracted
		case MTZRadialMenuStateContracted: {
			[self displayMenu];
		} break;
		// Normal
		case MTZRadialMenuStateNormal: {
			if ( menuState == MTZRadialMenuStateContracted ) {
				[self dismissMenuAnimated:YES];
			} else {
				[self setMenuStateExpandedFromNormal];
			}
		} break;
		// Expanded
		case MTZRadialMenuStateExpanded: {
			if ( menuState == MTZRadialMenuStateContracted ) {
				[self dismissMenuAnimated:YES];
			} else {
				[self setMenuStateNormalFromExpanded];
			}
		} break;
	}
	
	// Update menu state.
	_menuState = menuState;
}

- (void)setMenuStateExpandedFromNormal
{
	[UIView animateWithDuration:RADIALMENU_EXPANDING_ANIMATION_DURATION
						  delay:0
		 usingSpringWithDamping:RADIALMENU_EXPANDING_ANIMATION_DAMPING
		  initialSpringVelocity:RADIALMENU_EXPANDING_ANIMATION_INITIAL_VELOCITY
						options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 self.menuRadius = RADIALMENU_RADIUS_EXPANDED;
					 }
					 completion:^(BOOL finished) {}];
}

- (void)setMenuStateNormalFromExpanded
{
	[UIView animateWithDuration:RADIALMENU_UNEXPANDING_ANIMATION_DURATION
						  delay:0
		 usingSpringWithDamping:RADIALMENU_UNEXPANDING_ANIMATION_DAMPING
		  initialSpringVelocity:RADIALMENU_UNEXPANDING_ANIMATION_INITIAL_VELOCITY
						options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 self.menuRadius = RADIALMENU_RADIUS_NORMAL;
					 }
					 completion:^(BOOL finished) {}];
}

- (void)setMenuRadius:(CGFloat)radius
{
	_menuRadius = radius;
	self.radialMenu.frame = CGRectMake((self.bounds.size.width/2) - _menuRadius,
									   (self.bounds.size.height/2) - _menuRadius,
									   2 * _menuRadius,
									   2 * _menuRadius);
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
			self.menuState = MTZRadialMenuStateNormal;
			self.menuVisible = YES;
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
			self.menuState = MTZRadialMenuStateContracted;
			self.menuVisible = NO;
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
		self.exclusiveTouch = NO;
	} else {
		self.exclusiveTouch = YES;
	}
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
		// Look up standard graphic resources for type.
		switch (action.type) {
			case MTZActionTypeCancel:
				image = [UIImage imageNamed:@"MTZActionTypeCancel"];
				highlightedImage = [UIImage imageNamed:@"MTZActionTypeCancelHighlighted"];
				break;
			case MTZActionTypeConfirm:
				image = [UIImage imageNamed:@"MTZActionTypeConfirm"];
				highlightedImage = [UIImage imageNamed:@"MTZActionTypeConfirmHighlighted"];
				break;
			default:
				break;
		}
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

@end
