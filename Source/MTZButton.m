//
//  MTZButton.m
//
//  Created by Matt Zanchelli on 6/14/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZButton.h"

@implementation MTZButton

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	return CGRectContainsPoint(self.bounds, point);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	return CGRectContainsPoint(self.bounds, point) ? self : nil;
}

@end
