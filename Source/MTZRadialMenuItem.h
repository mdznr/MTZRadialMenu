//
//  MTZRadialMenuItem.h
//  Example App
//
//  Created by Matt Zanchelli on 6/22/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

@import UIKit;

@class MTZRadialMenuItem;
@class MTZRadialMenu;

/// Possible standard action types to apply to a button in a radial menu.
/// @discussion Be sure to read the guidelines for usage on the radial menu. Standard actions should be used consistently.
typedef NS_ENUM(NSInteger, MTZRadialMenuStandardItem){
	/// A standard item with a cancel icon. Indicates the action cancels the operation and leaves things unchanged.
	MTZRadialMenuStandardItemCancel = 0,
	/// A standard item with a confirm icon. Indicates the action confirms an operation.
	MTZRadialMenuStandardItemConfirm,
	/// A standard item with a pause icon. Indicates the action pauses some media.
	MTZRadialMenuStandardItemPause,
	/// A standard item with a play icon. Indicates the action plays some media.
	MTZRadialMenuStandardItemPlay,
	/// A standard item with a camera icon. Indicates the action triggers the camera.
	MTZRadialMenuStandardItemCamera,
};

typedef void (^MTZRadialMenuItemHighlightedHandler)(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem, BOOL highlighted);
typedef void (^MTZRadialMenuItemSelectedHandler)(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem);

/// A @c MTZRadialMenuItem object represents an item to add to a radial menu. You use this class to configure information about a single item, including the image to display, and a handler(s) to execute when the user highlights or selects the action. After creating an action object, add it to a @c MTZRadialMenu object before displaying the corresponding radial menu to the user.
@interface MTZRadialMenuItem : NSObject

#pragma mark Creating an Action

/// Create and return a radial menu item of the specified standard item and behavior.
/// @param standardItem The standard radial menu item. Use the appropriate item if the corresponding action is standard. For a list of possible values, see the constants in @c MTZRadialMenuStandardItem.
/// @param handler A block to execute when the user selects the item. This block has no return value and takes the radial menu and selected item object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new radial menu item object.
+ (instancetype)menuItemWithRadialMenuStandardItem:(MTZRadialMenuStandardItem)standardItem handler:(MTZRadialMenuItemSelectedHandler)handler;

/// Create and return a radial menu item of the specified standard item and behavior.
/// @param standardItem The standard radial menu item. Use the appropriate item if the corresponding action is standard. For a list of possible values, see the
/// @param highlightedHandler A block to execute when the user highlights the item (a touch enters the item's location). This block has no return value and takes the radial menu and highlighted item object. Usage of this includes——but is not limited to——starting or stopping an action while the radial menu remains open. Most of the time nothing is required here, see @c menuItemWithRadialMenuStandardItem:handler: instead.
/// @param selectedHandler A block to execute when the user selects the item. This block has no return value and takes the radial menu and selected item object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new radial menu item object.
+ (instancetype)menuItemWithRadialMenuStandardItem:(MTZRadialMenuStandardItem)standardItem highlightedHandler:(MTZRadialMenuItemHighlightedHandler)highlightedHandler selectedHandler:(MTZRadialMenuItemSelectedHandler)selectedHandler;

/// Create and return a radial menu item with the specified icon and behavior.
/// @param icon An image (with @c UIImageRenderingModeAlwaysTemplate @c renderingMode) that appears white by default and the @c tintColor of the radial menu when highlighted.
/// @param handler A block to execute when the user selects the item. This block has no return value and takes the radial menu and selected item object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new radial menu item object.
+ (instancetype)menuItemWithIcon:(UIImage *)icon handler:(MTZRadialMenuItemSelectedHandler)handler;

/// Create and return a radial menu item with the specified icon and behavior.
/// @param icon An image (with @c UIImageRenderingModeAlwaysTemplate @c renderingMode) that appears white by default and the @c tintColor of the radial menu when highlighted.
/// @param highlightedHandler A block to execute when the user highlights the item (a touch enters the item's location). This block has no return value and takes the radial menu and highlighted item object. Usage of this includes——but is not limited to——starting or stopping an action while the radial menu remains open. Most of the time nothing is required here, see @c menuItemWithRadialMenuStandardItem:handler: instead.
/// @param selectedHandler A block to execute when the user selects the item. This block has no return value and takes the radial menu and selected item object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new radial menu item object.
+ (instancetype)menuItemWithIcon:(UIImage *)icon highlightedHandler:(MTZRadialMenuItemHighlightedHandler)highlightedHandler selectedHandler:(MTZRadialMenuItemSelectedHandler)selectedHandler;

/// Create and return a radial menu item with the specified images and behavior.
/// @param image The image to use for the radial menu item.
/// @param highlightedImage The image to use when the menu item is highlighted.
/// @param highlightedHandler A block to execute when the user highlights the item (a touch enters the item's location). This block has no return value and takes the radial menu and highlighted item object. Usage of this includes——but is not limited to——starting or stopping an action while the radial menu remains open. Most of the time nothing is required here, see @c menuItemWithRadialMenuStandardItem:handler: instead.
/// @param selectedHandler A block to execute when the user selects the item. This block has no return value and takes the radial menu and selected item object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new radial menu item object.
+ (instancetype)menuItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage handler:(MTZRadialMenuItemSelectedHandler)handler;

/// Create and return a radial menu item with the specified images and behavior.
/// @param image The image to use for the radial menu item.
/// @param highlightedImage The image to use when the menu item is highlighted.
/// @param handler A block to execute when the user selects the item. This block has no return value and takes the radial menu and selected item object. The handler is responsible for dismissing the menu, if appropriate.
/// @return A new radial menu item object.
+ (instancetype)menuItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage highlightedHandler:(MTZRadialMenuItemHighlightedHandler)highlightedHandler selectedHandler:(MTZRadialMenuItemSelectedHandler)selectedHandler;

@end
