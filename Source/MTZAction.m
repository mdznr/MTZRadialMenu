//
//  MTZAction.m
//  Example App
//
//  Created by Matt Zanchelli on 6/22/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZAction.h"

#import "MTZAction_Private.h"

@interface MTZAction ()

/// A readwrite property of style.
@property (nonatomic, readwrite) MTZActionStyle style;

@end

@implementation MTZAction

#pragma mark Creating an Action

+ (instancetype)actionWithStyle:(MTZActionStyle)style handler:(MTZActionSelectedHandler)handler
{
	return [MTZAction actionWithStyle:style highlightedHandler:nil selectedHandler:handler];
}

+ (instancetype)actionWithStyle:(MTZActionStyle)style highlightedHandler:(MTZActionHighlightedHandler)highlightedHandler selectedHandler:(MTZActionSelectedHandler)selectedHandler
{
	MTZAction *action = [[MTZAction alloc] init];
	action.style = style;
	action.highlightedHandler = highlightedHandler;
	action.selectedHandler = selectedHandler;
	return action;
}

+ (instancetype)actionWithIcon:(UIImage *)icon handler:(MTZActionSelectedHandler)handler
{
	return [MTZAction actionWithIcon:icon highlightedHandler:nil selectedHandler:handler];
}

+ (instancetype)actionWithIcon:(UIImage *)icon highlightedHandler:(MTZActionHighlightedHandler)highlightedHandler selectedHandler:(MTZActionSelectedHandler)selectedHandler
{
	MTZAction *action = [[MTZAction alloc] init];
	action.style = -1;
	action.icon = icon;
	action.highlightedHandler = highlightedHandler;
	action.selectedHandler = selectedHandler;
	return action;
}

+ (instancetype)actionWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage handler:(MTZActionSelectedHandler)handler
{
	return [MTZAction actionWithImage:image highlightedImage:highlightedImage highlightedHandler:nil selectedHandler:handler];
}

+ (instancetype)actionWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage highlightedHandler:(MTZActionHighlightedHandler)highlightedHandler selectedHandler:(MTZActionSelectedHandler)selectedHandler
{
	MTZAction *action = [[MTZAction alloc] init];
	action.style = -1;
	action.image = image;
	action.highlightedImage = highlightedImage;
	action.highlightedHandler = highlightedHandler;
	action.selectedHandler = selectedHandler;
	return action;
}

- (BOOL)isStandardStyle
{
	return self.style >= 0;
}

#pragma mark Changing Images

- (void)setImage:(UIImage *)image
{
	_image = image;
	[self.delegate actionImagesChanged:self];
}

- (void)setHighlightedImage:(UIImage *)highlightedImage
{
	_highlightedImage = highlightedImage;
	[self.delegate actionImagesChanged:self];
}

@end
