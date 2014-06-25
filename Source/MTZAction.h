//
//  MTZAction.h
//  Example App
//
//  Created by Matt Zanchelli on 6/22/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

@import UIKit;

@class MTZAction;
@class MTZRadialMenu;

/// Possible standard action types to apply to a button in a radial menu.
/// @discussion Be sure to read the guidelines for usage on the radial menu. Standard actions should be used consistently.
typedef NS_ENUM(NSInteger, MTZActionStyle){
	/// Indicates the action cancels the operation and leaves things unchanged.
	MTZActionStyleCancel = 0,
	/// Indicates the action confirms the operation.
	MTZActionStyleConfirm,
	/// Indicates the action pauses some media.
	MTZActionStylePause,
	/// Indicates the action plays some media.
	MTZActionStylePlay,
	/// Indicates the action triggers the camera.
	MTZActionStyleCamera,
};

typedef void (^MTZActionHighlightedHandler)(MTZRadialMenu *radialMenu, MTZAction *action, BOOL highlighted);
typedef void (^MTZActionSelectedHandler)(MTZRadialMenu *radialMenu, MTZAction *action);

/// A @c MTZAction object represents an action that can be taken in a radial menu. You use this class to configure information about a single action, including the image to display, and a handler to execute when the user selects the action. After creating an action object, add it to a @c MTZRadialMenu object before displaying the corresponding radial menu to the user.
@interface MTZAction : NSObject

#pragma mark Creating an Action

/// Create and return an action of the specified style and behavior.
/// @param style The standard action style. Use the appropriate style if the corresponding action is standard. For a list of possible values, see the constants in @c MTZActionStyle.
/// @param handler A block to execute when the user selects the action. This block has no return value and takes the radial menu and selected action object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new action object.
+ (instancetype)actionWithStyle:(MTZActionStyle)style handler:(MTZActionSelectedHandler)handler;

/// Create and return an action of the specified style and behavior.
/// @param style The standard action style. Use the appropriate style if the corresponding action is standard. For a list of possible values, see the constants in @c MTZActionStyle.
/// @param highlightedHandler A block to execute when the user highlights the action (a touch enters the action's location). This block has no return value and takes the radial menu and highlighted action object. Usage of this includes——but is not limited to——starting or stopping an action while the radial menu remains open. Most of the time nothing is required here, see @c actionWithImage:highlightedImage:handler: instead.
/// @param selectedHandler A block to execute when the user selects the action. This block has no return value and takes the radial menu and selected action object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new action object.
+ (instancetype)actionWithStyle:(MTZActionStyle)style highlightedHandler:(MTZActionHighlightedHandler)highlightedHandler selectedHandler:(MTZActionSelectedHandler)selectedHandler;

/// Create and return an action with the specified icon and behavior.
/// @param icon An image (with @c UIImageRenderingModeAlwaysTemplate @c renderingMode) that appears white by default and the @c tintColor of the radial menu when highlighted.
/// @param handler A block to execute when the user selects the action. This block has no return value and takes the radial menu and selected action object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new action object.
+ (instancetype)actionWithIcon:(UIImage *)icon handler:(MTZActionSelectedHandler)handler;

/// Create and return an action with the specified icon and behavior.
/// @param icon An image (with @c UIImageRenderingModeAlwaysTemplate @c renderingMode) that appears white by default and the @c tintColor of the radial menu when highlighted.
/// @param highlightedHandler A block to execute when the user highlights the action (a touch enters the action's location). This block has no return value and takes the radial menu and highlighted action object. Usage of this includes——but is not limited to——starting or stopping an action while the radial menu remains open. Most of the time nothing is required here, see @c actionWithImage:highlightedImage:handler: instead.
/// @param selectedHandler A block to execute when the user selects the action. This block has no return value and takes the radial menu and selected action object. The handler is responsible for dismissing the menu, if appropriate.
+ (instancetype)actionWithIcon:(UIImage *)icon highlightedHandler:(MTZActionHighlightedHandler)highlightedHandler selectedHandler:(MTZActionSelectedHandler)selectedHandler;

/// Create and return an action with the specified images and behavior.
/// @param image The image to use for the radial menu item.
/// @param highlightedImage The image to use when the menu item is highlighted.
/// @param handler A block to execute when the user selects the action. This block has no return value and takes the radial menu and selected action object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new action object.
+ (instancetype)actionWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage handler:(MTZActionSelectedHandler)handler;

/// Create and return an action with the specified images and behavior.
/// Create and return an action with the specified images and behavior.
/// @param image The image to use for the radial menu item.
/// @param highlightedImage The image to use when the menu item is highlighted.
/// @param highlightedHandler A block to execute when the user highlights the action (a touch enters the action's location). This block has no return value and takes the radial menu and highlighted action object. Usage of this includes——but is not limited to——starting or stopping an action while the radial menu remains open. Most of the time nothing is required here, see @c actionWithImage:highlightedImage:handler: instead.
/// @param selectedHandler A block to execute when the user selects the action. This block has no return value and takes the radial menu and selected action object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new action object.
+ (instancetype)actionWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage highlightedHandler:(MTZActionHighlightedHandler)highlightedHandler selectedHandler:(MTZActionSelectedHandler)selectedHandler;


#pragma mark Properties

/// The standard action style, if any.
/// @discussion Check @c standardStyle to see if this will be a valid action type.
/// @discussion This property is only set when creating an instance of @c MTZAction with @c actionWithStyle:handler: or @c actionWithStyle:highlightedHandler:selectedHandler:
@property (nonatomic, readonly) MTZActionStyle style;

/// The image with @c UIImageRenderingModeAlwaysTemplate to use as an icon.
/// @discussion The icon is used for all states, and color is applied automatically.
/// @discussion This property is only set when creating an instance of @c MTZAction with @c actionWithIcon:handler: or @c actionWithIcon:highlightedHandler:selectedHandler:
@property (nonatomic, copy) UIImage *icon;

/// The image to use for the normal state.
/// @discussion This property is only set when creating an instance of @c MTZAction with @c actionWithImage:highlightedImage:handler: or @c actionWithImage:highlightedImage:highlightedHandler:selectedHandler:
@property (nonatomic, copy) UIImage *image;

/// The image to use for the highlighted state.
/// @discussion This property is only set when creating an instance of @c MTZAction with @c actionWithImage:highlightedImage:handler: or @c actionWithImage:highlightedImage:highlightedHandler:selectedHandler:
@property (nonatomic, copy) UIImage *highlightedImage;

@end
