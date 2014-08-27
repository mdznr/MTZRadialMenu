//
//  MTZRadialMenu.h
//
//  Created by Matt Zanchelli on 6/11/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MTZRadialMenuItem.h"

/// The delegate of a @c MTZRadialMenu object must adopt the @c MTZRadialMenuDelegate protocol. Optional methods of the protocol allow the delegate to handle dependant UI and state when a radial menu is displayed and dismissed.
@protocol MTZRadialMenuDelegate <NSObject>

/// Called before the radial menu is displayed.
/// @param radialMenu The radial menu that is about to display.
- (void)radialMenuWillDisplay:(MTZRadialMenu *)radialMenu;

/// Called after the radial menu is displayed.
/// @param radialMenu The radial menu that just displayed.
- (void)radialMenuDidDisplay:(MTZRadialMenu *)radialMenu;

/// Called before the radial menu is closed.
/// @param radialMenu The radial menu that is about to close.
- (void)radialMenuWillDismiss:(MTZRadialMenu *)radialMenu;

/// Called after the radial menu is closed.
/// @param radialMenu The radial menu that just closed.
- (void)radialMenuDidDismiss:(MTZRadialMenu *)radialMenu;

@end


/// Describes the location of an action in a @c MTZRadialMenu.
/// @discussion Remember: Some of these locations may not be visible on screen.
typedef NS_ENUM(NSInteger, MTZRadialMenuLocation) {
	/// The center of the radial menu.
	MTZRadialMenuLocationCenter = 0,
	/// The top of the radial menu.
	MTZRadialMenuLocationTop = 1,
	/// The left of the radial menu.
	MTZRadialMenuLocationLeft,
	/// The right of the radial menu.
	MTZRadialMenuLocationRight,
	/// The bottom of the radial menu.
	/// @discussion Use with caution. The finger used to activate this radial menu might be obstructing visibility of this item.
	/// @discussion Not only may the user be unaware of functionality at this location, but may accidentally trigger it.
	MTZRadialMenuLocationBottom
};


/// An instance of the @c MTZRadialMenu class implements a radial menu that appears when long-pressing on a button. This class provides methods for setting the main button image, the presentation of menu items, and other appearance properties of a radial menu.
/// @discussion If using commonly used menu items, but sure to use them consistently. Confirm (@c MTZRadialMenuStandardItemConfirm) actions should be located at the top of the radial menu. Cancel (@c MTZRadialMenuStandardItemCancel) actions should be located on either the left or right side, depending on which side is closest to the center of the display. This ensures that the action is visible and consistently activated for users of both handedness and for use of radial menus on any side of the display.
@interface MTZRadialMenu : UIControl

/// Creates a new radial menu with the designated background visual effect.
- (instancetype)initWithBackgroundVisualEffect:(UIVisualEffect *)effect;

/// The object that acts as the delegate of the receiving radial menu.
/// @discussion The delegate must adopt the @c MTZRadialMenuDelegate protocol.
@property (nonatomic, weak) id<MTZRadialMenuDelegate> delegate;

#pragma mark Appearance

/// The visual effect being used for the background. (read-only)
@property (nonatomic, copy, readonly) UIVisualEffect *backgroundVisualEffect;

#pragma mark Configuring the Main Button Presentation

/// Sets the image for the main button to use for the specified state.
/// In general, if a property is not specified for a state, the default is to use the @c UIControlStateNormal value. If the @c UIControlStateNormal value is not set, then the property defaults to a system value. Therefore, at a minimum, you should set the value for the normal state.
- (void)setImage:(UIImage *)image forState:(UIControlState)state;

/// Returns the image for the main button for a particular control state.
- (UIImage *)imageForState:(UIControlState)state;

/*
/// The inset or outset margins for the rectangle around the activate button's image.
/// Use this property to resize and reposition the effective drawing rectangle for the button image. You can specify a different value for each of the four insets (top, left, bottom, right). A positive value shrinks, or insets, that edge—moving it closer to the center of the button. A negative value expands, or outsets, that edge. Use the @c UIEdgeInsetsMake function to construct a value for this property. The default value is @c UIEdgeInsetsZero.
/// This property is used only for positioning the image during layout. The button does not use this property to determine @c intrinsicContentSize and @c sizeThatFits:.
@property (nonatomic) UIEdgeInsets imageEdgeInsets;
*/

#pragma mark Configuring the User Actions

/// Sets the item for a particular location on the receiving radial menu.
/// @param item The action to add to the radial menu.
/// @param location The location on the radial menu to position this action.
- (void)setItem:(MTZRadialMenuItem *)item forLocation:(MTZRadialMenuLocation)location;

/// Returns the menu item for a particular location on the receiving radial menu.
- (MTZRadialMenuItem *)menuItemForLocation:(MTZRadialMenuLocation)location;

#pragma mark Getting the Current State

/// A Boolean value that indicates whether the menu is displayed. (read-only)
/// @discussion If @c NO, the menu is hidden and a long-press gesture must be used to present the menu.
@property (nonatomic, readonly, getter=isMenuVisible) BOOL menuVisible;

#pragma mark Dismissal

/// Dismiss the menu, optionally with animation.
/// @param animated @c YES if the receiver should be removed by animating it first; otherwise, @c NO if it should be removed immediately with no animation.
/// @discussion This method should not be called regularly. The radial menu is automatically dismissed when an action is selected. This method should only be used in unforeseen circumstances where the menu must be dismissed.
- (void)dismissMenuAnimated:(BOOL)animated;

@end
