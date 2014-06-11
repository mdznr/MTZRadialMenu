//
//  MTZRadialMenu.m
//
//  Created by Matt Zanchelli on 6/11/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZRadialMenu.h"

#import "MTZCircleView.h"

#define RADIALMENU_OPEN_ANIMATION_DURATION 0.52
#define RADIALMENU_OPEN_ANIMATION_DAMPING 0.7
#define RADIALMENU_OPEN_ANIMATION_INITIAL_VELOCITY 0.35

#define RADIALMENU_CLOSE_ANIMATION_DURATION 0.4
#define RADIALMENU_CLOSE_ANIMATION_DAMPING 1
#define RADIALMENU_CLOSE_ANIMATION_INITIAL_VELOCITY 0.4

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

#pragma mark -

@end


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
	self = [super initWithFrame:CGRectMake(0, 0, 30, 30)];
	if (self) {
		// Initialization code
		[self __MTZRadialMenuSetup];
	}
	return self;
}

+ (UIButton *)newActionButton
{
	UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//	button.translatesAutoresizingMaskIntoConstraints = NO;
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
	
	// Radial menu
	self.radialMenu = [[UIView alloc] init];
	[self addSubview:self.radialMenu];
	self.radialMenu.clipsToBounds = YES;
	[self setRadialMenuRadius:1];
	
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
		frame.origin.y = 8;
		topButton.frame = frame;
	}
	topButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	
	// Left button
	UIButton *leftButton = [MTZRadialMenu newActionButton];
	[self.radialMenu addSubview:leftButton];
	self.actionButtons[descriptionStringForLocation(MTZRadialMenuLocationLeft)] = leftButton;
	{
		CGRect frame = leftButton.frame;
		frame.origin.x = 8;
		leftButton.frame = frame;
	}
	leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	// Right button
	UIButton *rightButton = [MTZRadialMenu newActionButton];
	[self.radialMenu addSubview:rightButton];
	self.actionButtons[descriptionStringForLocation(MTZRadialMenuLocationRight)] = rightButton;
	{
		CGRect frame = rightButton.frame;
		frame.origin.x = self.radialMenu.bounds.size.width - 8 - frame.size.width;
		rightButton.frame = frame;
	}
	rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	// Bottom button
	UIButton *bottomButton = [MTZRadialMenu newActionButton];
	[self.radialMenu addSubview:bottomButton];
	self.actionButtons[descriptionStringForLocation(MTZRadialMenuLocationBottom)] = bottomButton;
	{
		CGRect frame = bottomButton.frame;
		frame.origin.y = self.radialMenu.bounds.size.height - 8 - frame.size.height;
		bottomButton.frame = frame;
	}
	bottomButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	
	// Main button
	self.button = [[UIButton alloc] initWithFrame:self.bounds];
	[self addSubview:self.button];
	self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Gestures
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressButton:)];
	[self.button addGestureRecognizer:longPress];
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapButton:)];
	[self.button addGestureRecognizer:tap];
}

#pragma mark -
#pragma mark - Responding to Gestures and Touches


- (void)didLongPressButton:(UILongPressGestureRecognizer *)sender
{
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			[self displayMenu];
			break;
		case UIGestureRecognizerStateChanged:
			break;
		case UIGestureRecognizerStateEnded:
			break;
		case UIGestureRecognizerStateCancelled:
		default:
			[self dismissMenuAnimated:YES];
			break;
	}
}

- (void)didTapButton:(UITapGestureRecognizer *)sender
{
	// Only recognizes the ended state.
	if (sender.state != UIGestureRecognizerStateEnded) return;
	
	if ( self.menuVisible || self.menuAnimating ) {
		[self dismissMenuAnimated:YES];
	} else {
		// TODO: Perform regular tap action.
	}
}

#pragma mark -
#pragma mark Configuring the Main Button Presentation

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
	[_button setImage:image forState:state];
}

- (UIImage *)imageForState:(UIControlState)state
{
	return [_button imageForState:state];
}

- (void)setImageEdgeInsets:(UIEdgeInsets)imageEdgeInsets
{
	_button.imageEdgeInsets = imageEdgeInsets;
}

- (UIEdgeInsets)imageEdgeInsets
{
	return _button.imageEdgeInsets;
}

#pragma mark -
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

#pragma mark -
#pragma mark Display & Dismissal

- (void)displayMenu
{
	if ( self.menuVisible && !self.menuAnimating ) return;
	
	self.menuAnimating = YES;
	
	void (^animations)() = ^void() {
		[self setRadialMenuRadius:105];
		self.radialMenu.alpha = 1.0f;
	};
	
	void (^completion)(BOOL) = ^void(BOOL finished) {
		if ( finished ) {
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
		[self setRadialMenuRadius:15];
		self.radialMenu.alpha = 0.0f;
	};
	
	void (^completion)(BOOL) = ^void(BOOL finished) {
		if ( finished ) {
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

- (void)setRadialMenuRadius:(CGFloat)radius
{
	self.radialMenu.frame = CGRectMake((self.bounds.size.width/2)-radius,
									   (self.bounds.size.height/2)-radius,
									   2*radius,
									   2*radius);
}

@end
