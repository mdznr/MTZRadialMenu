//
//  ViewController.m
//  Example App
//
//  Created by Matt Zanchelli on 6/10/14.
//  Copyright (c) 2014 Matt Zanchelli. All rights reserved.
//

#import "ViewController.h"

@import RadialMenu;

@interface ViewController () <MTZRadialMenuDelegate>

@property (nonatomic, getter=isCameraRecording) BOOL cameraRecording;
@property (strong, nonatomic) MTZRadialMenu *cameraRadialMenu;
@property (strong, nonatomic) MTZRadialMenuItem *cameraPhotoTakeAndSendAction;
@property (strong, nonatomic) MTZRadialMenuItem *cameraRecordingStartAction;
@property (strong, nonatomic) MTZRadialMenuItem *cameraRecordingStopAction;
@property (strong, nonatomic) MTZRadialMenuItem *cameraRecordingPlaybackPlayAction;
@property (strong, nonatomic) MTZRadialMenuItem *cameraRecordingPlaybackPauseAction;
@property (strong, nonatomic) MTZRadialMenuItem *cameraRecordingSendAction;

@end

@implementation ViewController
            
- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	
	self.cameraRecording = NO;
	
	
	CGRect middle = CGRectMake(138, 269, 44, 44);
	CGRect right = CGRectMake(271, 269, 44, 44);
	CGRect left = CGRectMake(5, 269, 44, 44);
	
	
	// Camera Radial Menu
	self.cameraRadialMenu = [[MTZRadialMenu alloc] initWithFrame:left];
	self.cameraRadialMenu.delegate = self;
	[self.cameraRadialMenu setImage:[UIImage imageNamed:@"Camera"] forState:UIControlStateNormal];
	[self.cameraRadialMenu setImage:[UIImage imageNamed:@"CameraHighlighted"] forState:UIControlStateSelected];
	[self.view addSubview:self.cameraRadialMenu];
	
	// Camera Cancel
	MTZRadialMenuItem *cameraCancel = [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:MTZRadialMenuStandardItemCancel handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		// TODO: Only dismiss radial menu after touch has at least left the original location (must wait for it to highlight again, or touch changed).
		[self cameraCancel];
	}];
	
	// Camera Photo Take and Send
	self.cameraPhotoTakeAndSendAction = [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:MTZRadialMenuStandardItemCamera handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		[self cameraTakeAndSendPhoto];
	}];
	
	// Camera Recording Start
	self.cameraRecordingStartAction = [MTZRadialMenuItem menuItemWithIcon:[UIImage imageNamed:@"ActionCameraRecord"] highlightedHandler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem, BOOL highlighted) {
		if (highlighted) {
			[self cameraRecord];
		}
	} selectedHandler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		[self cameraRecord];
	}];

	// Camera Recording Stop
	self.cameraRecordingStopAction = [MTZRadialMenuItem menuItemWithImage:[UIImage imageNamed:@"ActionCameraStop"] highlightedImage:[UIImage imageNamed:@"ActionCameraStopHighlighted"] handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		[self cameraStop];
	}];
	
	// Camera Recording Send
	self.cameraRecordingSendAction = [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:MTZRadialMenuStandardItemConfirm handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		[self cameraRecordingSend];
	}];
	
	// Camera Recording Playback Play
	self.cameraRecordingPlaybackPlayAction = [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:MTZRadialMenuStandardItemPlay handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		[self cameraRecordingPlaybackPlay];
	}];

	// Camera Recording Playback Pause
	self.cameraRecordingPlaybackPauseAction = [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:MTZRadialMenuStandardItemPause handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		[self cameraRecordingPlaybackPause];
	}];
	
	[self.cameraRadialMenu setItem:cameraCancel forLocation:MTZRadialMenuLocationCenter];
	[self resetCameraRadialMenu];
	
	
	// Microphone Radial Menu
	MTZRadialMenu *microphoneRadialMenu = [[MTZRadialMenu alloc] initWithFrame:right];
	microphoneRadialMenu.delegate = self;
	[microphoneRadialMenu setImage:[UIImage imageNamed:@"Microphone"] forState:UIControlStateNormal];
	[microphoneRadialMenu setImage:[UIImage imageNamed:@"Microphone"] forState:UIControlStateSelected];
	[self.view addSubview:microphoneRadialMenu];
	
	MTZRadialMenuItem *microphoneSend = [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:MTZRadialMenuStandardItemConfirm handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		NSLog(@"Microphone: Send");
		[radialMenu dismissMenuAnimated:YES];
	}];
	[microphoneRadialMenu setItem:microphoneSend forLocation:MTZRadialMenuLocationTop];
	
	MTZRadialMenuItem *microphoneCancel = [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:MTZRadialMenuStandardItemCancel handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		NSLog(@"Micrphone: Cancel");
		[radialMenu dismissMenuAnimated:YES];
	}];
	
	[microphoneRadialMenu setItem:microphoneCancel forLocation:MTZRadialMenuLocationLeft];
	
	MTZRadialMenuItem *play = [MTZRadialMenuItem menuItemWithImage:[UIImage imageNamed:@"ActionPlay"]
								highlightedImage:[UIImage imageNamed:@"ActionPlayHighlighted"]
							  highlightedHandler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem, BOOL highlighted) {
								  NSLog(@"Play Highlighted: %d", highlighted);
							  }
								 selectedHandler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
									 NSLog(@"Play");
								 }];
	[microphoneRadialMenu setItem:play forLocation:MTZRadialMenuLocationCenter];
}


#pragma mark Camera

- (void)resetCameraRadialMenu
{
	[self.cameraRadialMenu setItem:self.cameraPhotoTakeAndSendAction forLocation:MTZRadialMenuLocationTop];
	[self.cameraRadialMenu setItem:self.cameraRecordingStartAction forLocation:MTZRadialMenuLocationRight];
}

- (void)cameraCancel
{
	NSLog(@"Camera: Cancel");
	
	[self.cameraRadialMenu dismissMenuAnimated:YES];
}

- (void)cameraTakeAndSendPhoto
{
	NSLog(@"Camera: Take and Send Photo");
	
	[self.cameraRadialMenu dismissMenuAnimated:YES];
}

- (void)cameraRecord
{
	NSLog(@"Camera: Start Recording");
	
	// The camera is now recording.
	self.cameraRecording = YES;
	
	// Change the action to stop.
	[self.cameraRadialMenu setItem:self.cameraRecordingStopAction forLocation:MTZRadialMenuLocationRight];
}

- (void)cameraStop
{
	NSLog(@"Camera: Stop");
	
	// The camera is no longer recording.
	self.cameraRecording = NO;
	
	[self.cameraRadialMenu setItem:self.cameraRecordingPlaybackPlayAction forLocation:MTZRadialMenuLocationRight];
	[self.cameraRadialMenu setItem:self.cameraRecordingSendAction forLocation:MTZRadialMenuLocationTop];
}

- (void)cameraRecordingSend
{
	NSLog(@"Camera: Sending Recording");
	
	[self.cameraRadialMenu dismissMenuAnimated:YES];
}

- (void)cameraRecordingPlaybackPlay
{
	NSLog(@"Camera: Play");
	
	[self.cameraRadialMenu setItem:self.cameraRecordingPlaybackPauseAction forLocation:MTZRadialMenuLocationRight];
}

- (void)cameraRecordingPlaybackPause
{
	NSLog(@"Camera: Pause");
	
	[self.cameraRadialMenu setItem:self.cameraRecordingPlaybackPlayAction forLocation:MTZRadialMenuLocationRight];
}


#pragma mark MTZRadialMenuDelegate

- (void)radialMenuWillDisplay:(MTZRadialMenu *)radialMenu
{
	NSLog(@"radialMenuWillDisplay");
	
	if (radialMenu == self.cameraRadialMenu) {
		radialMenu.tintColor = [UIColor colorWithHue:1.0f/6.0f saturation:1.0f brightness:1.0f alpha:1.0f];
	}
}

- (void)radialMenuDidDisplay:(MTZRadialMenu *)radialMenu
{
	NSLog(@"radialMenuDidDisplay");
}

- (void)radialMenuWillDismiss:(MTZRadialMenu *)radialMenu
{
	NSLog(@"radialMenuWillDismiss");
	
	if (radialMenu == self.cameraRadialMenu) {
		radialMenu.tintColor = self.view.tintColor;
	}
}

- (void)radialMenuDidDismiss:(MTZRadialMenu *)radialMenu
{
	NSLog(@"radialMenuDidDismiss");
	
	if (radialMenu == self.cameraRadialMenu) {
		[self resetCameraRadialMenu];
	}
}

@end
