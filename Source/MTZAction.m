//
//  MTZAction.m
//  Example App
//
//  Created by Matt Zanchelli on 6/22/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZAction.h"

#import "MTZAction_Private.h"

@implementation MTZAction

#pragma mark Creating an Action

+ (instancetype)actionWithStyle:(MTZActionStyle)style handler:(void (^)(MTZRadialMenu *radialMenu, MTZAction *action))handler
{
	MTZAction *action = [[MTZAction alloc] init];
	action.style = style;
	action.handler = handler;
	return action;
}

+ (instancetype)actionWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage handler:(void (^)(MTZRadialMenu *radialMenu, MTZAction *action))handler
{
	MTZAction *action = [[MTZAction alloc] init];
	action.style = -1;
	action.image = image;
	action.highlightedImage = highlightedImage;
	action.handler = handler;
	return action;
}

- (BOOL)isStandardStyle
{
	return self.style >= 0;
}

@end