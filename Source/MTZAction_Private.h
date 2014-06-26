//
//  MTZAction_Private.h
//
//  Created by Matt Zanchelli on 6/22/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

/// Get a string representation of an action style.
NSString *NSStringFromMTZActionStyle(MTZActionStyle style);

@protocol MTZActionDelegate <NSObject>

/// The images for the action have changed.
- (void)actionImagesChanged:(MTZAction *)action;

@end


/// Represents the different types of possible action items.
typedef NS_ENUM(NSInteger, MTZActionType) {
	/// The action is of a standard style.
	MTZActionTypeStandardStyle,
	/// The action uses an icon.
	MTZActionTypeIcon,
	/// The action uses images for different states.
	MTZActionTypeImages,
};


@interface MTZAction ()

/// The type of action this is. This is dependent on which method was used to create the action.
@property (nonatomic, readwrite) MTZActionType actionType;

/// A readwrite property of style.
@property (nonatomic, readwrite) MTZActionStyle style;

/// The handler for when the action is highlighted.
@property (nonatomic, copy) MTZActionHighlightedHandler highlightedHandler;

/// The handler for when the action is selected.
@property (nonatomic, copy) MTZActionSelectedHandler selectedHandler;

/// A delegate to handle changes to the action. This is designed for use by @c MTZRadialMenu.
@property (nonatomic, weak) id<MTZActionDelegate> delegate;

@end
