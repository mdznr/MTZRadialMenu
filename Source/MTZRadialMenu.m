//
//  MTZRadialMenu.m
//
//  Created by Matt Zanchelli on 6/11/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZRadialMenu.h"

#import "MTZRadialMenuItem_Private.h"
#import "MTZButton.h"

#import <UIKit/UIGestureRecognizerSubclass.h>

// Menu State Animation Parameters
// Contracted -> Normal
#define RADIALMENU_ANIMATION_FROM_CONTRACTED_TO_NORMAL_DURATION           0.52
#define RADIALMENU_ANIMATION_FROM_CONTRACTED_TO_NORMAL_DAMPING            0.70
#define RADIALMENU_ANIMATION_FROM_CONTRACTED_TO_NORMAL_INITIAL_VELOCITY   0.35
// Contracted -> Expanded
#define RADIALMENU_ANIMATION_FROM_CONTRACTED_TO_EXPANDED_DURATION         0.52
#define RADIALMENU_ANIMATION_FROM_CONTRACTED_TO_EXPANDED_DAMPING          0.80
#define RADIALMENU_ANIMATION_FROM_CONTRACTED_TO_EXPANDED_INITIAL_VELOCITY 0.35
// Normal -> Contracted
#define RADIALMENU_ANIMATION_FROM_NORMAL_TO_CONTRACTED_DURATION           0.52
#define RADIALMENU_ANIMATION_FROM_NORMAL_TO_CONTRACTED_DAMPING            1.00
#define RADIALMENU_ANIMATION_FROM_NORMAL_TO_CONTRACTED_INITIAL_VELOCITY   0.00
// Normal -> Expanded
#define RADIALMENU_ANIMATION_FROM_NORMAL_TO_EXPANDED_DURATION             0.52
#define RADIALMENU_ANIMATION_FROM_NORMAL_TO_EXPANDED_DAMPING              1.00
#define RADIALMENU_ANIMATION_FROM_NORMAL_TO_EXPANDED_INITIAL_VELOCITY     0.00
// Expanded -> Normal
#define RADIALMENU_ANIMATION_FROM_EXPANDED_TO_NORMAL_DURATION             0.36
#define RADIALMENU_ANIMATION_FROM_EXPANDED_TO_NORMAL_DAMPING              1.00
#define RADIALMENU_ANIMATION_FROM_EXPANDED_TO_NORMAL_INITIAL_VELOCITY     0.30
// Expanded -> Contracted
#define RADIALMENU_ANIMATION_FROM_EXPANDED_TO_CONTRACTED_DURATION         0.52
#define RADIALMENU_ANIMATION_FROM_EXPANDED_TO_CONTRACTED_DAMPING          1.00
#define RADIALMENU_ANIMATION_FROM_EXPANDED_TO_CONTRACTED_INITIAL_VELOCITY 0.00

// Menu Metrics
#define RADIALMENU_BUTTON_RADIUS 15
#define RADIALMENU_RADIUS_CONTRACTED (RADIALMENU_BUTTON_RADIUS)
#define RADIALMENU_CENTER_TARGET_RADIUS (RADIALMENU_BUTTON_RADIUS * 3.2)
#define RADIALMENU_RADIUS_NORMAL 105
#define RADIALMENU_RADIUS_EXPANDED 120
#define RADIALMENU_BUTTON_PADDING 8

#define BIG_CIRCLE_RADIUS 192


#pragma mark Misc. Helpers

/// The distance between two points.
CGFloat CGPointDistance(CGPoint a, CGPoint b) {
	return sqrt(pow((a.x - b.x), 2) + pow((a.y - b.y), 2));
}

/// A container for three varying parameters of a spring animation.
typedef struct {
	NSTimeInterval duration;
	CGFloat damping;
	CGFloat initialVelocity;
} MTZSpringAnimationParameters;


#pragma mark MTZRadialMenuLocation

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

MTZRadialMenuLocation locationFromLocationString(NSString *locationString)
{
	if ([locationString isEqualToString:@"MTZRadialMenuLocationCenter"]) {
		return MTZRadialMenuLocationCenter;
	}
	
	if ([locationString isEqualToString:@"MTZRadialMenuLocationTop"]) {
		return MTZRadialMenuLocationTop;
	}
	
	if ([locationString isEqualToString:@"MTZRadialMenuLocationLeft"]) {
		return MTZRadialMenuLocationLeft;
	}
	
	if ([locationString isEqualToString:@"MTZRadialMenuLocationRight"]) {
		return MTZRadialMenuLocationRight;
	}
	
	if ([locationString isEqualToString:@"MTZRadialMenuLocationBottom"]) {
		return MTZRadialMenuLocationBottom;
	}
	
	return -1;
}


#pragma mark MTZRadialMenuState

/// The state of a radial menu.
typedef NS_ENUM(NSInteger, MTZRadialMenuState) {
	// Contracted is the smallest size, used when hidden.
	MTZRadialMenuStateContracted,
	// Normal is the state while the menu is visible and not being interacted with.
	MTZRadialMenuStateNormal,
	// Expanded is the state while an outer menu item is highlighted.
	MTZRadialMenuStateExpanded
};


#pragma mark MTZRadialMenu

@interface MTZRadialMenu () <MTZRadialMenuItemDelegate>

/// The item for locations.
@property (nonatomic, strong) NSMutableDictionary *items;

/// Action buttons corresponding to locations.
@property (nonatomic, strong) NSMutableDictionary *itemButtons;

/// The radial menu.
@property (nonatomic, strong) UIView *radialMenu;

/// The background for the radial menu.
@property (nonatomic, strong) UIVisualEffectView *radialMenuBackground;

/// A readwrite version of `backgroundVisualEffect`.
@property (nonatomic, copy, readwrite) UIVisualEffect *backgroundVisualEffect;

/// The main button to activate the radial menu.
@property (nonatomic, strong) MTZButton *mainButton;

/// The radius of the radial menu.
@property (nonatomic) CGFloat menuRadius;

/// The state of the menu.
@property (nonatomic) MTZRadialMenuState menuState;

@property (nonatomic, strong) UILongPressGestureRecognizer *pressGestureRecognizer;

/// The number of active state transitions.
/// @discussion This is used to know when all of the additive transitions have succesfully ended.
@property (nonatomic) NSInteger activeStateTransitionCount;

@end


@implementation MTZRadialMenu

#pragma mark Initialization & Setup

- (instancetype)initWithBackgroundVisualEffect:(UIVisualEffect *)effect
{
	self = [super initWithFrame:CGRectMake(0, 0, 2 * RADIALMENU_BUTTON_RADIUS, 2 * RADIALMENU_BUTTON_RADIUS)];
	if (self) {
		// Initialization code.
		self.backgroundVisualEffect = effect;
		[self __MTZRadialMenuSetup];
	}
	return self;
}

- (instancetype)init
{
	self = [super initWithFrame:CGRectMake(0, 0, 2 * RADIALMENU_BUTTON_RADIUS, 2 * RADIALMENU_BUTTON_RADIUS)];
	if (self) {
		// Initialization code
		[self __MTZRadialMenuSetup];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		// Initialization code
		[self __MTZRadialMenuSetup];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
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
	button.adjustsImageWhenHighlighted = NO;
	button.tintColor = [UIColor whiteColor];
	return button;
}

- (void)__MTZRadialMenuSetup
{
	// The radial menu will extend beyond the bounds of the original button.
	self.clipsToBounds = NO;
	
	// Data
	self.items = [[NSMutableDictionary alloc] initWithCapacity:3];
	self.activeStateTransitionCount = 0;
	
	// Main button
	self.mainButton = [MTZButton buttonWithType:UIButtonTypeSystem];
	self.mainButton.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
	[self addSubview:self.mainButton];
	self.mainButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	// Radial menu
	self.radialMenu = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RADIALMENU_RADIUS_CONTRACTED, RADIALMENU_RADIUS_CONTRACTED)];
	self.radialMenu.clipsToBounds = YES;
	[self addSubview:self.radialMenu];
	self.radialMenu.center = self.mainButton.center;
	self.radialMenu.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	// Radial menu
	if (!self.backgroundVisualEffect) {
		self.backgroundVisualEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	}
	self.radialMenuBackground = [[UIVisualEffectView alloc] initWithEffect:self.backgroundVisualEffect];
	self.radialMenuBackground.clipsToBounds = YES;
	[self.radialMenu addSubview:self.radialMenuBackground];
	// Make it big, then scale it down using transforms in `setMenuRadius:`
	self.radialMenuBackground.frame = CGRectMake(0, 0, 2 * BIG_CIRCLE_RADIUS, 2 * BIG_CIRCLE_RADIUS);
	self.radialMenuBackground.layer.cornerRadius = BIG_CIRCLE_RADIUS;
	self.radialMenuBackground.center = self.radialMenu.center;
	self.radialMenuBackground.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	// Item buttons
	self.itemButtons = [[NSMutableDictionary alloc] initWithCapacity:5];
	
	// Center button
	UIButton *centerButton = [MTZRadialMenu newActionButton];
	[self.radialMenu addSubview:centerButton];
	self.itemButtons[descriptionStringForLocation(MTZRadialMenuLocationCenter)] = centerButton;
	{
		CGRect frame = centerButton.frame;
		frame.origin.x = CGRectGetMidX(self.radialMenu.bounds);
		frame.origin.y = CGRectGetMidY(self.radialMenu.bounds);
		centerButton.frame = frame;
	}
	centerButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	// Top button
	UIButton *topButton = [MTZRadialMenu newActionButton];
	[self.radialMenu addSubview:topButton];
	self.itemButtons[descriptionStringForLocation(MTZRadialMenuLocationTop)] = topButton;
	{
		CGRect frame = topButton.frame;
		frame.origin.y = RADIALMENU_BUTTON_PADDING;
		topButton.frame = frame;
	}
	topButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	
	// Left button
	UIButton *leftButton = [MTZRadialMenu newActionButton];
	[self.radialMenu addSubview:leftButton];
	self.itemButtons[descriptionStringForLocation(MTZRadialMenuLocationLeft)] = leftButton;
	{
		CGRect frame = leftButton.frame;
		frame.origin.x = RADIALMENU_BUTTON_PADDING;
		leftButton.frame = frame;
	}
	leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	// Right button
	UIButton *rightButton = [MTZRadialMenu newActionButton];
	[self.radialMenu addSubview:rightButton];
	self.itemButtons[descriptionStringForLocation(MTZRadialMenuLocationRight)] = rightButton;
	{
		CGRect frame = rightButton.frame;
		frame.origin.x = self.radialMenu.bounds.size.width - RADIALMENU_BUTTON_PADDING - frame.size.width;
		rightButton.frame = frame;
	}
	rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	
	// Bottom button
	UIButton *bottomButton = [MTZRadialMenu newActionButton];
	[self.radialMenu addSubview:bottomButton];
	self.itemButtons[descriptionStringForLocation(MTZRadialMenuLocationBottom)] = bottomButton;
	{
		CGRect frame = bottomButton.frame;
		frame.origin.y = self.radialMenu.bounds.size.height - RADIALMENU_BUTTON_PADDING - frame.size.height;
		bottomButton.frame = frame;
	}
	bottomButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	
	// Default center action
	MTZRadialMenuItem *defaultCenter = [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:MTZRadialMenuStandardItemCancel handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		[radialMenu dismissMenuAnimated:YES];
	}];
	[self setItem:defaultCenter forLocation:MTZRadialMenuLocationCenter];
	
	// Gestures
	self.pressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch:)];
	[self addGestureRecognizer:self.pressGestureRecognizer];
	
	// Defaults
	_menuState = -1; // Forces next call to setMenuState: to go through.
	self.menuState = MTZRadialMenuStateContracted;
}


#pragma mark Responding to Gestures & Touches

- (void)didTouch:(UIGestureRecognizer *)sender
{
	CGPoint point = [sender locationInView:self];
	CGFloat distance = [self distanceOfPointFromCenter:point];
	
	switch (sender.state) {
		case UIGestureRecognizerStateBegan: {
			// Open menu, if not already. Note: This only happens when `minimumPressDuration` is normal.
			if (![self isMenuVisible]) {
				[self highlightLocation:-1];
				[self setMenuState:MTZRadialMenuStateNormal animated:YES];
			}
			// Dismiss menu, if way outside. Note: This only happens when `exclusiveTouch` is YES.
			if (distance >= RADIALMENU_RADIUS_EXPANDED * 1.5) {
				[self dismissMenuAnimated:YES];
				break;
			}
		}
		case UIGestureRecognizerStateChanged: {
			MTZRadialMenuLocation location = [self locationForPoint:point];
			MTZRadialMenuItem *item = [self menuItemForLocation:location];
			if (location == MTZRadialMenuLocationCenter) {
				// Highlighting center action.
				[self setMenuState:MTZRadialMenuStateNormal animated:YES];
			} else if (location < 0) {
				// Outside the radial menu.
				[self setMenuState:MTZRadialMenuStateNormal animated:YES];
			} else {
				// Possibly highlighting outer actions.
				if (item) {
					// Highlighting an action on the outer ring.
					[self setMenuState:MTZRadialMenuStateExpanded animated:YES];;
				} else {
					// Valid location, but nothing's there.
					[self setMenuState:MTZRadialMenuStateNormal animated:YES];
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
			if (location < 0) {
				[self setMenuState:MTZRadialMenuStateContracted animated:YES];
			} else {
				[self setMenuState:MTZRadialMenuStateNormal animated:YES];
			}
			// Don't highlight anything.
			[self highlightLocation:-1];
			// Set the location to be selected.
			[self selectLocation:location];
		} break;
		case UIGestureRecognizerStateCancelled:
		default: {
			// TODO: If still on the original gesture to open the menu, close it (return to state before gesture started)
			[self highlightLocation:-1];
			[self setMenuState:MTZRadialMenuStateNormal animated:YES];
		} break;
	}
}

- (void)highlightLocation:(MTZRadialMenuLocation)location
{
	NSString *locationKey = descriptionStringForLocation(location);
	for (NSString *key in self.itemButtons.allKeys) {
		UIButton *button = self.itemButtons[key];
		BOOL shouldBeHighlighted = [key isEqualToString:locationKey];
		// Commented out as button.highlighted is set to YES the first loop even though it does not appear so. I think this is because `UIButton` automatically sets its highlighted appearance based on touch events. This might have to be overriden for `MTZButton` for this check to work.
//		if (button.highlighted != shouldBeHighlighted) {
			// Set the highlighted state on the button.
			button.highlighted = shouldBeHighlighted;
			// Apply the radial menu's tintColor to the button, if highlighted.
			button.tintColor = shouldBeHighlighted ? self.tintColor : [UIColor whiteColor];
			// Call highlighted handler.
			MTZRadialMenuLocation currentLocation = locationFromLocationString(key);
			MTZRadialMenuItem *item = [self menuItemForLocation:currentLocation];
			if (item && item.highlightedHandler) {
				item.highlightedHandler(self, item, shouldBeHighlighted);
			}
//		}
	}
}

- (void)selectLocation:(MTZRadialMenuLocation)location
{
	MTZRadialMenuItem *item = [self menuItemForLocation:location];
	item = item ? item : [self menuItemForLocation:MTZRadialMenuLocationCenter];
	if (item) {
		// Act on it!
		item.selectedHandler(self, item);
	} else {
		// Something weird happened, dismiss the menu.
		[self dismissMenuAnimated:YES];
	}
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	if (self.exclusiveTouch) {
		return YES;
	}
	
	if (CGRectContainsPoint(self.bounds, point)) {
		return YES;
	}
	
	CGPoint convertedPoint = [self.radialMenu convertPoint:point fromView:self];
	return [self.radialMenu pointInside:convertedPoint withEvent:event];
}

/// Find the distance of a point from the center of the radial menu.
/// @param point The point in terms of the bounds of the view.
/// @return The distance of the point to the center of the radial menu.
- (CGFloat)distanceOfPointFromCenter:(CGPoint)point
{
	CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
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
	
	if (distance >= RADIALMENU_RADIUS_EXPANDED * 1.5) {
		// It's outside the radial menu.
		return -1;
	} else if (distance < RADIALMENU_CENTER_TARGET_RADIUS) {
		// It's the center of the radial menu.
		return MTZRadialMenuLocationCenter;
	} else {
		// It must be one of the other locations.
		
		// Size of the view.
		CGSize size = self.bounds.size;
		// Coordinates on a 0 to 1 scale.
		CGFloat x = point.x / size.width;
		CGFloat y = point.y / size.height;
		// Where can it be? Let's narrow it down.
		BOOL topOrRight = y < x;
		BOOL bottomOrRight = (1-y) < x;
		if (topOrRight) {
			return bottomOrRight ? MTZRadialMenuLocationRight : MTZRadialMenuLocationTop;
		} else {
			return bottomOrRight ? MTZRadialMenuLocationBottom : MTZRadialMenuLocationLeft;
		}
	}
}


#pragma mark Menu State

- (void)setMenuState:(MTZRadialMenuState)menuState animated:(BOOL)animated
{
	// Only apply if menu state has changed.
	if (_menuState == menuState) {
		return;
	}
	
	// The changes to make.
	void (^changeMenuState)() = ^void() {
		self.menuState = menuState;
	};
	
	// If not animated, don't bother animating.
	if (!animated) {
		changeMenuState();
		return;
	}
	
	// The parameters for the spring animation.
	MTZSpringAnimationParameters animationParameters = [MTZRadialMenu menuStateAnimationParametersFromMenuState:_menuState toMenuState:menuState];
	
	// Animate with the correct parameters.
	[UIView animateWithDuration:animationParameters.duration
						  delay:0
		 usingSpringWithDamping:animationParameters.damping
		  initialSpringVelocity:animationParameters.initialVelocity
						options:0
					 animations:changeMenuState
					 completion:nil];
}

/// Set the state of the radial menu.
/// @param menuState The state of the menu to change to.
/// @discussion Note that this method is safe to call externally in an animation block or outside of one.
- (void)setMenuState:(MTZRadialMenuState)menuState
{
	// Only apply if menu state has changed.
	if (self.menuState == menuState) {
		return;
	}
	
	BOOL menuWasOpen = (self.menuState == MTZRadialMenuStateNormal || self.menuState == MTZRadialMenuStateExpanded);
	
	_menuState = menuState;
	
	BOOL menuOpen;
	CGFloat alpha;
	CGFloat radius;
	
	if (self.menuState == MTZRadialMenuStateContracted) {
		menuOpen = NO;
		alpha = 0.0f;
		radius = RADIALMENU_RADIUS_CONTRACTED;
	} else {
		menuOpen = YES;
		alpha = 1.0f;
		if (self.menuState == MTZRadialMenuStateNormal) {
			radius = RADIALMENU_RADIUS_NORMAL;
		} else if (self.menuState == MTZRadialMenuStateExpanded) {
			radius = RADIALMENU_RADIUS_EXPANDED;
		}
	}
	
	if (menuOpen && !menuWasOpen) {
		[self tellDelegateRadialMenuWillDisplay];
	} else if (!menuOpen && menuWasOpen) {
		[self tellDelegateRadialMenuWillDismiss];
	}
	
	self.exclusiveTouch = menuOpen;
	CFTimeInterval minimumPressDuration = menuOpen ? 0.0 : 0.5;
	if (self.pressGestureRecognizer.minimumPressDuration != minimumPressDuration) {
		self.pressGestureRecognizer.minimumPressDuration = minimumPressDuration;
	}
	
	__weak MTZRadialMenu *weakSelf = self;
	
	// Update visual appearance.
	void (^animations)() = ^void() {
		weakSelf.menuRadius = radius;
		weakSelf.radialMenu.alpha = alpha;
		weakSelf.mainButton.alpha = 1 - alpha;
	};
	
	// The completion after all animations are complete.
	// Update gesture recognizers and touch behaviours.
	void (^completion)(BOOL) = ^void(BOOL finished) {
		if (menuOpen && !menuWasOpen) {
			[weakSelf tellDelegateRadialMenuDidDisplay];
		} else if (!menuOpen && menuWasOpen) {
			[weakSelf tellDelegateRadialMenuDidDismiss];
		}
	};
	
	
	// Put in an animation block with 0 duration to inherit parent's animation context.
	[UIView animateWithDuration:0 animations:animations completion:^(BOOL finished) {
		weakSelf.activeStateTransitionCount--;
		if (weakSelf.activeStateTransitionCount == 0) {
			completion(finished);
		}
	}];
	
	self.activeStateTransitionCount++;
}


#pragma Menu State to Menu State
	
+ (MTZSpringAnimationParameters)menuStateAnimationParametersFromMenuState:(MTZRadialMenuState)fromMenuState
															  toMenuState:(MTZRadialMenuState)toMenuState
{
	MTZSpringAnimationParameters params = (MTZSpringAnimationParameters) {0, 1, 0};
	
	switch (fromMenuState) {
		case MTZRadialMenuStateExpanded: {
			if (toMenuState == MTZRadialMenuStateContracted) {
				params = [MTZRadialMenu menuStateAnimationParametersFromExpandedToContracted];
			} else if (toMenuState == MTZRadialMenuStateNormal) {
				params = [MTZRadialMenu menuStateAnimationParametersFromExpandedToNormal];
			}
		} break;
		case MTZRadialMenuStateNormal: {
			if (toMenuState == MTZRadialMenuStateExpanded) {
				params = [MTZRadialMenu menuStateAnimationParametersFromNormalToExpanded];
			} else if (toMenuState == MTZRadialMenuStateContracted) {
				params = [MTZRadialMenu menuStateAnimationParametersFromNormalToContracted];
			}
		} break;
		case MTZRadialMenuStateContracted:
		default: {
			if (toMenuState == MTZRadialMenuStateNormal) {
				params = [MTZRadialMenu menuStateAnimationParametersFromContractedToNormal];
			} else if (toMenuState == MTZRadialMenuStateExpanded) {
				params = [MTZRadialMenu menuStateAnimationParametersFromContractedToExpanded];
			}
		} break;
	}
	
	return params;
}

/// Contracted -> Normal
+ (MTZSpringAnimationParameters)menuStateAnimationParametersFromContractedToNormal
{
	return (MTZSpringAnimationParameters) {RADIALMENU_ANIMATION_FROM_CONTRACTED_TO_NORMAL_DURATION, RADIALMENU_ANIMATION_FROM_CONTRACTED_TO_NORMAL_DAMPING, RADIALMENU_ANIMATION_FROM_CONTRACTED_TO_NORMAL_INITIAL_VELOCITY};
}

/// Contracted -> Expanded
+ (MTZSpringAnimationParameters)menuStateAnimationParametersFromContractedToExpanded
{
	return (MTZSpringAnimationParameters) {RADIALMENU_ANIMATION_FROM_CONTRACTED_TO_EXPANDED_DURATION, RADIALMENU_ANIMATION_FROM_CONTRACTED_TO_EXPANDED_DAMPING, RADIALMENU_ANIMATION_FROM_CONTRACTED_TO_EXPANDED_INITIAL_VELOCITY};
}

/// Normal -> Contracted
+ (MTZSpringAnimationParameters)menuStateAnimationParametersFromNormalToContracted
{
	return (MTZSpringAnimationParameters) {RADIALMENU_ANIMATION_FROM_NORMAL_TO_CONTRACTED_DURATION, RADIALMENU_ANIMATION_FROM_NORMAL_TO_CONTRACTED_DAMPING, RADIALMENU_ANIMATION_FROM_NORMAL_TO_CONTRACTED_INITIAL_VELOCITY};
}

/// Normal -> Expanded
+ (MTZSpringAnimationParameters)menuStateAnimationParametersFromNormalToExpanded
{
	return (MTZSpringAnimationParameters) {RADIALMENU_ANIMATION_FROM_NORMAL_TO_EXPANDED_DURATION, RADIALMENU_ANIMATION_FROM_NORMAL_TO_EXPANDED_DAMPING, RADIALMENU_ANIMATION_FROM_NORMAL_TO_EXPANDED_INITIAL_VELOCITY};
}

/// Expanded -> Normal
+ (MTZSpringAnimationParameters)menuStateAnimationParametersFromExpandedToNormal
{
	return (MTZSpringAnimationParameters) {RADIALMENU_ANIMATION_FROM_EXPANDED_TO_NORMAL_DURATION, RADIALMENU_ANIMATION_FROM_EXPANDED_TO_NORMAL_DAMPING, RADIALMENU_ANIMATION_FROM_EXPANDED_TO_NORMAL_INITIAL_VELOCITY};
}

/// Expanded -> Contracted
+ (MTZSpringAnimationParameters)menuStateAnimationParametersFromExpandedToContracted
{
	return (MTZSpringAnimationParameters) {RADIALMENU_ANIMATION_FROM_EXPANDED_TO_CONTRACTED_DURATION, RADIALMENU_ANIMATION_FROM_EXPANDED_TO_CONTRACTED_DAMPING, RADIALMENU_ANIMATION_FROM_EXPANDED_TO_CONTRACTED_INITIAL_VELOCITY};
}

- (void)setMenuRadius:(CGFloat)radius
{
	_menuRadius = radius;
	
	self.radialMenu.frame = CGRectMake((self.bounds.size.width/2) - self.menuRadius,
									   (self.bounds.size.height/2) - self.menuRadius,
									   2 * self.menuRadius,
									   2 * self.menuRadius);
	
	// Scale the background down.
	CGFloat scale = radius / BIG_CIRCLE_RADIUS;
	self.radialMenuBackground.transform = CGAffineTransformMakeScale(scale, scale);
}


#pragma mark Display & Dismissal

- (void)displayMenu
{
	if ([self isMenuVisible]) {
		return;
	}
	
	[self tellDelegateRadialMenuWillDisplay];
	[self setMenuState:MTZRadialMenuStateNormal animated:YES];
	[self tellDelegateRadialMenuDidDisplay];
}

- (void)dismissMenuAnimated:(BOOL)animated
{
	if (![self isMenuVisible]) {
		return;
	}

	[self setMenuState:MTZRadialMenuStateContracted animated:animated];
}

- (BOOL)isMenuVisible
{
	return self.menuState != MTZRadialMenuStateContracted;
}


#pragma mark Configuring the Main Button Presentation

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
	[self.mainButton setImage:image forState:state];
}

- (UIImage *)imageForState:(UIControlState)state
{
	return [self.mainButton imageForState:state];
}


#pragma mark Configuring the User Actions

- (void)setItem:(MTZRadialMenuItem *)item forLocation:(MTZRadialMenuLocation)location;
{
	NSString *locationKey = descriptionStringForLocation(location);
	UIButton *itemButton = self.itemButtons[locationKey];
	
	if (item) {
		item.delegate = self;
		self.items[locationKey] = item;
		itemButton.hidden = NO;
	} else {
		[self.items removeObjectForKey:locationKey];
		itemButton.hidden = YES;
	}
	
	switch (item.type) {
		case MTZRadialMenuItemTypeStandardItem: {
			NSString *styleName = NSStringFromMTZRadialMenuStandardItem(item.standardItem);
			UIImage *icon = [MTZRadialMenu resourceNamed:styleName];
			[itemButton setImage:icon forState:UIControlStateNormal];
			[itemButton setImage:nil forState:UIControlStateHighlighted];
		} break;
		case MTZRadialMenuItemTypeIcon: {
			[itemButton setImage:item.icon forState:UIControlStateNormal];
			[itemButton setImage:nil forState:UIControlStateHighlighted];
		} break;
		case MTZRadialMenuItemTypeImages: {
			[itemButton setImage:item.image forState:UIControlStateNormal];
			[itemButton setImage:item.highlightedImage forState:UIControlStateHighlighted];
		} break;
	}
}

- (MTZRadialMenuItem *)menuItemForLocation:(MTZRadialMenuLocation)location;
{
	return self.items[descriptionStringForLocation(location)];
}


#pragma mark MTZRadialMenuItemDelegate

- (void)radialMenuItemAppearanceChanged:(MTZRadialMenuItem *)menuItem
{
	// Look up the location for the action.
	NSString *locationKey = [self locationStringForItem:menuItem];
	// Get the button for the location.
	UIButton *actionButton = self.itemButtons[locationKey];
	
	// Update button resources.
	[actionButton setImage:menuItem.image forState:UIControlStateNormal];
	[actionButton setImage:menuItem.highlightedImage forState:UIControlStateHighlighted];
}


#pragma mark Sending delegate (MTZRadialMenuDelegate) methods

- (void)tellDelegateRadialMenuWillDisplay
{
	if ([self.delegate respondsToSelector:@selector(radialMenuWillDisplay:)]) {
		[self.delegate radialMenuWillDisplay:self];
	}
}

- (void)tellDelegateRadialMenuDidDisplay
{
	if ([self.delegate respondsToSelector:@selector(radialMenuDidDisplay:)]) {
		[self.delegate radialMenuDidDisplay:self];
	}
}

- (void)tellDelegateRadialMenuWillDismiss
{
	if ([self.delegate respondsToSelector:@selector(radialMenuWillDismiss:)]) {
		[self.delegate radialMenuWillDismiss:self];
	}
}

- (void)tellDelegateRadialMenuDidDismiss
{
	if ([self.delegate respondsToSelector:@selector(radialMenuDidDismiss:)]) {
		[self.delegate radialMenuDidDismiss:self];
	}
}


#pragma mark Misc.

- (NSString *)locationStringForItem:(MTZRadialMenuItem *)item
{
	for (NSString *key in self.items.allKeys) {
		if (self.items[key] == item) {
			return key;
		}
	}
	return nil;
}

+ (UIImage *)resourceNamed:(NSString *)name
{
	NSBundle *MTZRadialMenuBundle = [NSBundle bundleForClass:[MTZRadialMenu class]];
	
	if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
		return [UIImage imageNamed:name inBundle:MTZRadialMenuBundle compatibleWithTraitCollection:nil];
	}
	
	NSString *filePath = [MTZRadialMenuBundle pathForResource:name ofType:@"png"];
	return [UIImage imageWithContentsOfFile:filePath];
}

@end
