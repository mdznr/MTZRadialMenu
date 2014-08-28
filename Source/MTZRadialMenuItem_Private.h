//
//  MTZRadialMenuItem_Private.h
//
//  Created by Matt Zanchelli on 6/22/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

/// Get a string representation of an standard radial menu item.
NSString *NSStringFromMTZRadialMenuStandardItem(MTZRadialMenuStandardItem menuItem);

@protocol MTZRadialMenuItemDelegate <NSObject>

/// The appearance for the menu item has changed.
- (void)radialMenuItemAppearanceChanged:(MTZRadialMenuItem *)menuItem;

@end


/// Represents the different types of possible radial menu items.
typedef NS_ENUM(NSInteger, MTZRadialMenuItemType) {
	/// The action is of a standard style.
	MTZRadialMenuItemTypeStandardItem,
	/// The action uses an icon.
	MTZRadialMenuItemTypeIcon,
	/// The action uses images for different states.
	MTZRadialMenuItemTypeImages,
};


@interface MTZRadialMenuItem ()

/// The type of radial menu item this is. This is dependent on which method was used to create the item.
@property (nonatomic, readwrite) MTZRadialMenuItemType type;

/// The handler for when the item is highlighted.
@property (nonatomic, copy) MTZRadialMenuItemHighlightedHandler highlightedHandler;

/// The handler for when the item is selected.
@property (nonatomic, copy) MTZRadialMenuItemSelectedHandler selectedHandler;

/// A delegate to handle changes to the item. This is designed for use by @c MTZRadialMenu.
@property (nonatomic, weak) id<MTZRadialMenuItemDelegate> delegate;

#pragma mark Graphics Properties

/// The standard item, if any.
/// @discussion This property is only set when creating an instance of @c MTZRadialMenuItem with @c menuItemWithRadialMenuStandardItem:handler: or @c menuItemWithRadialMenuStandardItem:highlightedHandler:selectedHandler:
@property (nonatomic) MTZRadialMenuStandardItem standardItem;

/// The image with @c UIImageRenderingModeAlwaysTemplate to use as an icon.
/// @discussion The icon is used for all states, and color is applied automatically.
/// @discussion This property is only set when creating an instance of @c MTZRadialMenuItem with @c menuItemWithIcon:handler: or @c menuItemWithIcon:highlightedHandler:selectedHandler
@property (nonatomic, copy) UIImage *icon;

/// The image to use for the normal state.
/// @discussion This property is only set when creating an instance of @c MTZRadialMenuItem with @c menuItemWithImage:highlightedImage:handler: or @c menuItemWithImage:highlightedImage:highlightedHandler:selectedHandler:
@property (nonatomic, copy) UIImage *image;

/// The image to use for the highlighted state.
/// @discussion This property is only set when creating an instance of @c MTZRadialMenuItem with @c menuItemWithImage:highlightedImage:handler: or @c menuItemnWithImage:highlightedImage:highlightedHandler:selectedHandler:
@property (nonatomic, copy) UIImage *highlightedImage;

@end
