//
//  MTZAction.h
//  Example App
//
//  Created by Matt Zanchelli on 6/22/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

@import UIKit;

@class MTZRadialMenu;

/// Possible standard action types to apply to a button in a radial menu.
/// @discussion Be sure to read the guidelines for usage on the radial menu. Standard actions should be used consistently.
typedef NS_ENUM(NSInteger, MTZActionStyle){
	/// Indicates the action cancels the operation and leaves things unchanged.
	MTZActionStyleCancel = 0,
	/// Indicates the action confirms the operation.
	MTZActionStyleConfirm,
};

/// A @c MTZAction object represents an action that can be taken in a radial menu. You use this class to configure information about a single action, including the image to display, and a handler to execute when the user selects the action. After creating an action object, add it to a @c MTZRadialMenu object before displaying the corresponding radial menu to the user.
@interface MTZAction : NSObject

#pragma mark Creating an Action

/// Create and return an action with the specified images and behavior.
/// @param style The standard action style. Use the appropriate style if the corresponding action is standard. For a list of possible values, see the constants in @c MTZActionStyle.
/// @param handler A block to execute when the user selects the action. This block has no return value and takes the radial menu and selected action object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new action object.
/// @discussion Actions are enabled by default when you create them.
+ (instancetype)actionWithStyle:(MTZActionStyle)style handler:(void (^)(MTZRadialMenu *radialMenu, MTZAction *action))handler;

/// Create and return an action with the specified images and behavior.
/// @param image The image to use for the radial menu item.
/// @param highlightedImage The image to use when the menu item is highlighted.
/// @param handler A block to execute when the user selects the action. This block has no return value and takes the radial menu and selected action object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new action object.
/// @discussion Actions are enabled by default when you create them.
+ (instancetype)actionWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage handler:(void (^)(MTZRadialMenu *radialMenu, MTZAction *action))handler;

/// Create and return an action with the specified images and behavior.
/// Create and return an action with the specified images and behavior.
/// @param image The image to use for the radial menu item.
/// @param highlightedImage The image to use when the menu item is highlighted.
/// @param highlightedHandler A block to execute when the user highlights the action (a touch enters the action's location). This block has no return value and takes the radial menu and highlighted action object. Usage of this includes——but is not limited to——starting or stopping an action while the radial menu remains open. Most of the time nothing is required here, see @c actionWithImage:highlightedImage:handler: instead.
/// @param selectedHandler A block to execute when the user selects the action. This block has no return value and takes the radial menu and selected action object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new action object.
/// @discussion Actions are enabled by default when you create them.
+ (instancetype)actionWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage highlightedHandler:(void (^)(MTZRadialMenu *radialMenu, MTZAction *action))highlightedHandler selectedHandler:(void (^)(MTZRadialMenu *radialMenu, MTZAction *action))selectedHandler;


#pragma mark Properties

/// The standard action style, if any.
/// @discussion Check @c standardStyle to see if this will be a valid action type.
@property (nonatomic, readonly) MTZActionStyle style;

@end