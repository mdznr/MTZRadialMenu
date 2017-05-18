//
//  MTZRadialMenuItem.m
//  Example App
//
//  Created by Matt Zanchelli on 6/22/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZRadialMenuItem.h"

#import "MTZRadialMenuItem_Private.h"

NS_ASSUME_NONNULL_BEGIN

NSString *NSStringFromMTZRadialMenuStandardItem(MTZRadialMenuStandardItem menuItem) {
	switch (menuItem) {
		case MTZRadialMenuStandardItemCancel:  return @"MTZRadialMenuStandardItemCancel";
		case MTZRadialMenuStandardItemConfirm: return @"MTZRadialMenuStandardItemConfirm";
		case MTZRadialMenuStandardItemCamera:  return @"MTZRadialMenuStandardItemCamera";
		case MTZRadialMenuStandardItemPause:   return @"MTZRadialMenuStandardItemPause";
		case MTZRadialMenuStandardItemPlay:    return @"MTZRadialMenuStandardItemPlay";
		default: return nil;
	}
}

@implementation MTZRadialMenuItem

#pragma mark Creating an Action

+ (instancetype)menuItemWithRadialMenuStandardItem:(MTZRadialMenuStandardItem)standardItem handler:(nullable MTZRadialMenuItemSelectedHandler)handler
{
	return [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:standardItem highlightedHandler:nil selectedHandler:handler];
}

+ (instancetype)menuItemWithRadialMenuStandardItem:(MTZRadialMenuStandardItem)standardItem highlightedHandler:(nullable MTZRadialMenuItemHighlightedHandler)highlightedHandler selectedHandler:(nullable MTZRadialMenuItemSelectedHandler)selectedHandler;
{
	MTZRadialMenuItem *menuItem = [[MTZRadialMenuItem alloc] init];
	menuItem.standardItem = standardItem;
	menuItem.type = MTZRadialMenuItemTypeStandardItem;
	menuItem.highlightedHandler = highlightedHandler;
	menuItem.selectedHandler = selectedHandler;
	return menuItem;
}

+ (instancetype)menuItemWithIcon:(UIImage *)icon handler:(nullable MTZRadialMenuItemSelectedHandler)handler;
{
	return [MTZRadialMenuItem menuItemWithIcon:icon highlightedHandler:nil selectedHandler:handler];
}

+ (instancetype)menuItemWithIcon:(UIImage *)icon highlightedHandler:(nullable MTZRadialMenuItemHighlightedHandler)highlightedHandler selectedHandler:(nullable MTZRadialMenuItemSelectedHandler)selectedHandler;
{
	MTZRadialMenuItem *menuItem = [[MTZRadialMenuItem alloc] init];
	menuItem.type = MTZRadialMenuItemTypeIcon;
	menuItem.icon = icon;
	menuItem.highlightedHandler = highlightedHandler;
	menuItem.selectedHandler = selectedHandler;
	return menuItem;
}

+ (instancetype)menuItemWithImage:(UIImage *)image highlightedImage:(nullable UIImage *)highlightedImage handler:(nullable MTZRadialMenuItemSelectedHandler)handler;
{
	return [MTZRadialMenuItem menuItemWithImage:image highlightedImage:highlightedImage highlightedHandler:nil selectedHandler:handler];
}

+ (instancetype)menuItemWithImage:(UIImage *)image highlightedImage:(nullable UIImage *)highlightedImage highlightedHandler:(nullable MTZRadialMenuItemHighlightedHandler)highlightedHandler selectedHandler:(nullable MTZRadialMenuItemSelectedHandler)selectedHandler;
{
	MTZRadialMenuItem *menuItem = [[MTZRadialMenuItem alloc] init];
	menuItem.type = MTZRadialMenuItemTypeImages;
	menuItem.image = image;
	menuItem.highlightedImage = highlightedImage;
	menuItem.highlightedHandler = highlightedHandler;
	menuItem.selectedHandler = selectedHandler;
	return menuItem;
}

#pragma mark Changing Images

- (void)setImage:(nullable UIImage *)image
{
	_image = image;
	[self.delegate radialMenuItemAppearanceChanged:self];
}

- (void)setHighlightedImage:(nullable UIImage *)highlightedImage
{
	_highlightedImage = highlightedImage;
	[self.delegate radialMenuItemAppearanceChanged:self];
}

@end

NS_ASSUME_NONNULL_END
