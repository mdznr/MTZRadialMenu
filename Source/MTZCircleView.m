//
//  MTZCircleView.m
//  Example App
//
//  Created by Matt Zanchelli on 6/11/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "MTZCircleView.h"

@interface MTZPathAnimation : NSObject <CAAction>
@end

@implementation MTZPathAnimation

- (void)runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict
{
	if ([event isEqualToString:@"path"]) {
		CAShapeLayer *layer = (CAShapeLayer *)anObject;
		
		CABasicAnimation *pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
		pathAnim.fromValue = (id)((CAShapeLayer *)layer.presentationLayer).path;
		pathAnim.toValue = (id)layer.path;
		pathAnim.removedOnCompletion = NO;
		[layer addAnimation:pathAnim forKey:@"path"];
	}
}

@end


@implementation MTZCircleView

+ (Class)layerClass
{
	return [CAShapeLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self __MTZCircleViewSetup];
    }
    return self;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		// Initialization code
		[self __MTZCircleViewSetup];
	}
	return self;
}

- (void)__MTZCircleViewSetup
{
	CAShapeLayer *layer = (CAShapeLayer *)self.layer;
	
	UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
	layer.path = circlePath.CGPath;
}

- (void)setColor:(UIColor *)color
{
	_color = color;
	((CAShapeLayer *)self.layer).fillColor = _color.CGColor;
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
	if ([event isEqualToString:@"path"]) {
		return [[MTZPathAnimation alloc] init];
	}
	return [super actionForLayer:layer forKey:event];
}

- (void)layoutSublayersOfLayer:(CAShapeLayer *)layer
{
	UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:layer.bounds];
	layer.path = circlePath.CGPath;
}

@end
