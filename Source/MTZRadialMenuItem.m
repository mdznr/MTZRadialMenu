//
//  MTZRadialMenuItem.m
//  Example App
//
//  Created by Matt Zanchelli on 6/22/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZRadialMenuItem.h"

#import "MTZRadialMenuItem_Private.h"

NSString *NSStringFromMTZRadialMenuStandardItem(MTZRadialMenuStandardItem menuItem)
{
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

+ (instancetype)menuItemWithRadialMenuStandardItem:(MTZRadialMenuStandardItem)standardItem handler:(MTZRadialMenuItemSelectedHandler)handler
{
	return [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:standardItem highlightedHandler:nil selectedHandler:handler];
}

+ (instancetype)menuItemWithRadialMenuStandardItem:(MTZRadialMenuStandardItem)standardItem highlightedHandler:(MTZRadialMenuItemHighlightedHandler)highlightedHandler selectedHandler:(MTZRadialMenuItemSelectedHandler)selectedHandler;
{
	MTZRadialMenuItem *menuItem = [[MTZRadialMenuItem alloc] init];
	menuItem.standardItem = standardItem;
	menuItem.type = MTZRadialMenuItemTypeStandardItem;
	menuItem.highlightedHandler = highlightedHandler;
	menuItem.selectedHandler = selectedHandler;
	return menuItem;
}

+ (instancetype)menuItemWithIcon:(UIImage *)icon handler:(MTZRadialMenuItemSelectedHandler)handler;
{
	return [MTZRadialMenuItem menuItemWithIcon:icon highlightedHandler:nil selectedHandler:handler];
}

+ (instancetype)menuItemWithIcon:(UIImage *)icon highlightedHandler:(MTZRadialMenuItemHighlightedHandler)highlightedHandler selectedHandler:(MTZRadialMenuItemSelectedHandler)selectedHandler;
{
	MTZRadialMenuItem *menuItem = [[MTZRadialMenuItem alloc] init];
	menuItem.type = MTZRadialMenuItemTypeIcon;
	menuItem.icon = icon;
	menuItem.highlightedHandler = highlightedHandler;
	menuItem.selectedHandler = selectedHandler;
	return menuItem;
}

+ (instancetype)menuItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage handler:(MTZRadialMenuItemSelectedHandler)handler;
{
	return [MTZRadialMenuItem menuItemWithImage:image highlightedImage:highlightedImage highlightedHandler:nil selectedHandler:handler];
}

+ (instancetype)menuItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage highlightedHandler:(MTZRadialMenuItemHighlightedHandler)highlightedHandler selectedHandler:(MTZRadialMenuItemSelectedHandler)selectedHandler;
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

- (void)setImage:(UIImage *)image
{
	_image = image;
	[self.delegate radialMenuItemAppearanceChanged:self];
}

- (void)setHighlightedImage:(UIImage *)highlightedImage
{
	_highlightedImage = highlightedImage;
	[self.delegate radialMenuItemAppearanceChanged:self];
}

@end
