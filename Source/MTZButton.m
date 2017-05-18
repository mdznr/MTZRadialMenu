//
//  MTZButton.m
//
//  Created by Matt Zanchelli on 6/14/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZButton.h"

NS_ASSUME_NONNULL_BEGIN

@implementation MTZButton

- (BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event
{
	return CGRectContainsPoint(self.bounds, point);
}

- (nullable UIView *)hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event
{
	return CGRectContainsPoint(self.bounds, point) ? self : nil;
}

@end

NS_ASSUME_NONNULL_END
