//
//  MTZRadialMenu.h
//
//  Created by Matt Zanchelli on 6/11/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Possible standard action types to apply to a button in a radial menu.
/// @discussion Be sure to read the guidelines for usage on the radial menu. Standard actions should be used consistently.
typedef enum MTZActionType: NSInteger {
	/// Indicates the action cancels the operation and leaves things unchanged.
	MTZActionTypeCancel,
	/// Indicates the action confirms the operation.
	MTZActionTypeConfirm,
} MTZActionType;


/// A @c MTZAction object represents an action that can be taken in a radial menu. You use this class to configure information about a single action, including the image to display, and a handler to execute when the user selects the action. After creating an action object, add it to a @c MTZRadialMenu object before displaying the corresponding radial menu to the user.
@interface MTZAction : NSObject

#pragma mark Creating an Action

/// Create and return an action with the specified images and behavior.
/// @param type The standard type of action. Use the appropriate standard type if the corresponding action is standard. For a list of possible values, see the constants in @c MTZActionType.
/// @param handler A block to execute when the user selects the action. This block hasn o return value and takes the selected action object as its only parameter.
/// @return A new action object.
/// @discussion Actions are enabled by default when you create them.
+ (instancetype)actionOfType:(MTZActionType)type handler:(void (^)(MTZAction *action))handler;

/// Create and return an action with the specified images and behavior.
/// @param image The image to use for the radial menu item.
/// @param highlightedImage The image to use when the menu item is highlighted.
/// @param handler A block to execute when the user selects the action. This block hasn o return value and takes the selected action object as its only parameter.
/// @return A new action object.
/// @discussion Actions are enabled by default when you create them.
+ (instancetype)actionWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage handler:(void (^)(MTZAction *action))handler;

#pragma mark -

@end


/// Describes the location of an action in a @c MTZRadialMenu.
/// @discussion Remember: Some of these locations may not be visible on screen.
typedef enum MTZRadialMenuLocation: NSInteger {
	/// The top of the radial menu.
	MTZRadialMenuLocationTop,
	/// The left of the radial menu.
	MTZRadialMenuLocationLeft,
	/// The right of the radial menu.
	MTZRadialMenuLocationRight,
	/// The bottom of the radial menu.
	/// @discussion Use with caution. The finger used to activate this radial menu might be obstructing visibility of this item.
	/// @discussion Not only may the user be unaware of functionality at this location, but may accidentally trigger it.
	MTZRadialMenuLocationBottom,
} MTZRadialMenuLocation;


/// An instance of the @c MTZRadialMenu class implements a radial menu that appears when long-pressing on a button. This class provides methods for setting the main button image, the presentation of menu items, and other appearance properties of a radial menu.
/// @discussion If using commonly used action items, but sure to use them consistently. Send (@c MTZActionStyleSend) actions should be located at the top of the radial menu. Cancel (@c MTZActionStyleCancel) actions should be located on either the left or right side, depending on which side is closest to the center of the display. This ensures that the action is visible and consistently activated for users of both handedness and for use of radial menus on any side of the display.
@interface MTZRadialMenu : UIControl

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

#pragma mark -
#pragma mark Configuring the User Actions

/// Sets the action for a particular location on the receiving radial menu.
/// @param action The action to add to the radial menu.
/// @param location The location on the radial menu to position this action.
- (void)setAction:(MTZAction *)action forLocation:(MTZRadialMenuLocation)location;

/// Returns the actino for a particular location on the receiving radial menu.
- (MTZAction *)actionForLocation:(MTZRadialMenuLocation)location;

#pragma mark -
#pragma mark Getting the Current State

/// A Boolean value that indicates whether the menu is displayed. (read-only)
/// @discussion If @c NO, the menu is hidden and a long-press gesture must be used to present the menu.
@property (nonatomic, readonly, getter=isMenuVisible) BOOL menuVisible;

#pragma mark -
#pragma mark Dismissal

/// Dismiss the menu, optionally with animation.
/// @param animated @c YES if the receiver should be removed by animating it first; otherwise, @c NO if it should be removed immediately with no animation.
/// @discussion This method should not be called regularly. The radial menu is automatically dismissed when an action is selected. This method should only be used in unforeseen circumstances where the menu must be dismissed.
- (void)dismissMenuAnimated:(BOOL)animated;

@end
