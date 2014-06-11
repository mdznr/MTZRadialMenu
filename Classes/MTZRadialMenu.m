//
//  MTZRadialMenu.m
//
//  Created by Matt Zanchelli on 6/11/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZRadialMenu.h"

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

- (void)__MTZRadialMenuSetup
{
	// The radial menu will extend beyond the bounds of the original button.
	self.clipsToBounds = NO;
	
	// Data
	self.actions = [[NSMutableDictionary alloc] initWithCapacity:3];
	self.menuVisible = NO;
	
	// Radial menu
	self.radialMenu = [[UIView alloc] init];
	[self addSubview:self.radialMenu];
	self.radialMenu.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.31f];
	self.radialMenu.clipsToBounds = YES;
	[self setRadialMenuRadius:1];
	
	// Action buttons
//	self.actionButtons = [[NSMutableDictionary alloc] initWithCapacity:3];
//	UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//	self.actionButtons[descriptionStringForLocation(MTZRadialMenuLocationTop)] = ;
//	self.actionButtons[descriptionStringForLocation(MTZRadialMenuLocationLeft)] = ;
//	self.actionButtons[descriptionStringForLocation(MTZRadialMenuLocationRight)] = ;
//	self.actionButtons[descriptionStringForLocation(MTZRadialMenuLocationBottom)] = ;
	
	// Main button
	self.button = [[UIButton alloc] initWithFrame:self.frame];
	[self addSubview:self.button];
	self.button.translatesAutoresizingMaskIntoConstraints = NO;
	
	// Gestures
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressButton:)];
	[self.button addGestureRecognizer:longPress];
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapButton:)];
	[self.button addGestureRecognizer:tap];
	
	// Layout
	NSDictionary *views = NSDictionaryOfVariableBindings(_button);
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_button]|" options:0 metrics:nil views:views]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_button]|" options:0 metrics:nil views:views]];
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
	
	if ( self.menuVisible ) {
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
	self.actions[descriptionStringForLocation(location)] = action;
	//
	//
	//
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
	if ( self.menuVisible ) return;
	
	[UIView animateWithDuration:0.3
						  delay:0
		 usingSpringWithDamping:1
		  initialSpringVelocity:0.15
						options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 [self setRadialMenuRadius:105];
					 }
					 completion:^(BOOL finished) {
						 self.menuVisible = YES;
					 }];
}

- (void)dismissMenuAnimated:(BOOL)animated
{
	if ( !self.menuVisible ) return;
	
	[UIView animateWithDuration:animated ? 0.25 : 0
						  delay:0
		 usingSpringWithDamping:1
		  initialSpringVelocity:0.25
						options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
					 animations:^{
						 [self setRadialMenuRadius:1];
					 }
					 completion:^(BOOL finished) {
						 self.menuVisible = NO;
					 }];
}

- (void)setRadialMenuRadius:(CGFloat)radius
{
	self.radialMenu.frame = CGRectMake((self.frame.size.width/2)-radius, (self.frame.size.height/2)-radius, 2*radius, 2*radius);
	self.radialMenu.layer.cornerRadius = radius;
}

@end
