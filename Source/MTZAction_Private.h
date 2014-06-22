//
//  MTZAction_Private.h
//
//  Created by Matt Zanchelli on 6/22/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

@interface MTZAction ()

/// A Boolean value representing whether the action is a standard style.
@property (nonatomic, readonly, getter=isStandardStyle) BOOL standardStyle;

/// The image to use for the normal state.
@property (nonatomic, copy) UIImage *image;

/// The image to use for the highlighted state.
@property (nonatomic, copy) UIImage *highlightedImage;

/// The handler for when the action is selected.
@property (nonatomic, weak) void (^handler)(MTZRadialMenu *radialMenu, MTZAction *action);

@end