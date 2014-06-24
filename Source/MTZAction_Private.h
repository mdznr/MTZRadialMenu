//
//  MTZAction_Private.h
//
//  Created by Matt Zanchelli on 6/22/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

@protocol MTZActionDelegate <NSObject>

/// The images for the action have changed.
- (void)actionImagesChanged:(MTZAction *)action;

@end


@interface MTZAction ()

/// A Boolean value representing whether the action is a standard style.
@property (nonatomic, readonly, getter=isStandardStyle) BOOL standardStyle;

/// The handler for when the action is highlighted.
@property (nonatomic, copy) MTZActionHighlightedHandler highlightedHandler;

/// The handler for when the action is selected.
@property (nonatomic, copy) MTZActionSelectedHandler selectedHandler;

/// A delegate to handle changes to the action. This is designed for use by @c MTZRadialMenu.
@property (nonatomic, weak) id<MTZActionDelegate> delegate;

@end
