//
//  ViewController.m
//  Example App
//
//  Created by Matt Zanchelli on 6/10/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "ViewController.h"

@import RadialMenu;

@interface ViewController ()

@property (atomic) BOOL toggled;

@end

@implementation ViewController
            
- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	CGRect middle = CGRectMake(138, 269, 44, 44);
	CGRect right = CGRectMake(271, 269, 44, 44);
	CGRect left = CGRectMake(5, 269, 44, 44);
	
	// Microphone Radial Menu
	MTZRadialMenu *microphoneRadialMenu = [[MTZRadialMenu alloc] initWithFrame:right];
	[microphoneRadialMenu setImage:[UIImage imageNamed:@"Microphone"] forState:UIControlStateNormal];
	[microphoneRadialMenu setImage:[UIImage imageNamed:@"Microphone"] forState:UIControlStateSelected];
	[self.view addSubview:microphoneRadialMenu];
	
	MTZAction *microphoneSend = [MTZAction actionWithStyle:MTZActionStyleConfirm handler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
		NSLog(@"Microphone: Send");
		[radialMenu dismissMenuAnimated:YES];
	}];
	[microphoneRadialMenu setAction:microphoneSend forLocation:MTZRadialMenuLocationTop];
	
	MTZAction *microphoneCancel = [MTZAction actionWithStyle:MTZActionStyleCancel handler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
		NSLog(@"Micrphone: Cancel");
		[radialMenu dismissMenuAnimated:YES];
	}];
	
	[microphoneRadialMenu setAction:microphoneCancel forLocation:MTZRadialMenuLocationLeft];
	
	self.toggled = YES;
	
	__block ViewController *blocksafeSelf = self;
	
	MTZAction *play = [MTZAction actionWithImage:[UIImage imageNamed:@"ActionPlay"]
								highlightedImage:[UIImage imageNamed:@"ActionPlayHighlighted"]
							  highlightedHandler:^(MTZRadialMenu *radialMenu, MTZAction *action, BOOL highlighted){
								  NSLog(@"Play Highlighted: %d", highlighted);
								  
								  if (highlighted) {
									  blocksafeSelf.toggled = !blocksafeSelf.toggled;
								  }
								  
								  if (blocksafeSelf.toggled) {
									  action.image = [UIImage imageNamed:@"Circle"];
									  action.highlightedImage = [UIImage imageNamed:@"CircleHighlighted"];
								  } else {
									  action.image = [UIImage imageNamed:@"ActionPlay"];
									  action.highlightedImage = [UIImage imageNamed:@"ActionPlayHighlighted"];
								  }
							  }
								 selectedHandler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
									 blocksafeSelf.toggled = YES;
									 action.image = [UIImage imageNamed:@"Circle"];
									 action.highlightedImage = [UIImage imageNamed:@"CircleHighlighted"];
									 NSLog(@"Play");
								 }];
	[microphoneRadialMenu setAction:play forLocation:MTZRadialMenuLocationCenter];
	
	// Camera Radial Menu
	MTZRadialMenu *cameraRadialMenu = [[MTZRadialMenu alloc] initWithFrame:left];
	[cameraRadialMenu setImage:[UIImage imageNamed:@"Camera"] forState:UIControlStateNormal];
	[cameraRadialMenu setImage:[UIImage imageNamed:@"CameraHighlighted"] forState:UIControlStateSelected];
	[self.view addSubview:cameraRadialMenu];
	
	MTZAction *cameraSend = [MTZAction actionWithStyle:MTZActionStyleConfirm handler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
		NSLog(@"Camera: Send");
		[radialMenu dismissMenuAnimated:YES];
	}];
	
	MTZAction *cameraCancel = [MTZAction actionWithStyle:MTZActionStyleCancel handler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
		NSLog(@"Camera: Cancel");
		[radialMenu dismissMenuAnimated:YES];
	}];
	
	MTZAction *cameraRecord = [MTZAction actionWithImage:[UIImage imageNamed:@""] highlightedImage:[UIImage imageNamed:@""] highlightedHandler:^(MTZRadialMenu *radialMenu, MTZAction *action, BOOL highlighted) {
		NSLog(@"Camera: Start Record");
	} selectedHandler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
		NSLog(@"Camera: Selected Record");
	}];
	
	[cameraRadialMenu setAction:cameraSend forLocation:MTZRadialMenuLocationTop];
	[cameraRadialMenu setAction:cameraCancel forLocation:MTZRadialMenuLocationCenter];
	[cameraRadialMenu setAction:cameraRecord forLocation:MTZRadialMenuLocationRight];
}

@end
