//
//  ViewController.m
//  Example App
//
//  Created by Matt Zanchelli on 6/10/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "ViewController.h"
#import "MTZRadialMenu.h"

@implementation ViewController
            
- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	CGRect middle = CGRectMake(145, 145, 30, 30);
	CGRect right = CGRectMake(278, 276, 30, 30);
	CGRect left = CGRectMake(12, 276, 30, 30);
	
	MTZRadialMenu *radialMenu = [[MTZRadialMenu alloc] initWithFrame:middle];
	[radialMenu setImage:[UIImage imageNamed:@"Circle"] forState:UIControlStateNormal];
	[radialMenu setImage:[UIImage imageNamed:@"CircleHighlighted"] forState:UIControlStateSelected];
	[self.view addSubview:radialMenu];
	
	MTZAction *action = [MTZAction actionWithImage:[UIImage imageNamed:@"Circle"]
								  highlightedImage:[UIImage imageNamed:@"CircleHighlighted"]
										   handler:^(MTZAction *action) {
											   NSLog(@"My custom action was handled!");
										   }];
	[radialMenu setAction:action forLocation:MTZRadialMenuLocationTop];
	
	MTZAction *secondAction = [MTZAction actionWithImage:[UIImage imageNamed:@"Circle"]
										highlightedImage:[UIImage imageNamed:@"CircleHighlighted"]
												 handler:^(MTZAction *action) {
													 NSLog(@"My second custom action was handled!");
												 }];
	[radialMenu setAction:secondAction forLocation:MTZRadialMenuLocationLeft];
//	[radialMenu setAction:secondAction forLocation:MTZRadialMenuLocationRight];
//	[radialMenu setAction:secondAction forLocation:MTZRadialMenuLocationBottom];
}

@end
