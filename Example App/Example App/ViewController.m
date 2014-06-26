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

@property (strong, nonatomic) MTZRadialMenu *cameraRadialMenu;
@property (nonatomic) BOOL recording;
@property (strong, nonatomic) MTZAction *cameraPhotoTakeAndSendAction;
@property (strong, nonatomic) MTZAction *cameraRecordingStartAction;
@property (strong, nonatomic) MTZAction *cameraRecordingStopAction;
@property (strong, nonatomic) MTZAction *cameraRecordingPlaybackPlayAction;
@property (strong, nonatomic) MTZAction *cameraRecordingPlaybackPauseAction;
@property (strong, nonatomic) MTZAction *cameraRecordingSendAction;

@end

@implementation ViewController
            
- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	CGRect middle = CGRectMake(138, 269, 44, 44);
	CGRect right = CGRectMake(271, 269, 44, 44);
	CGRect left = CGRectMake(5, 269, 44, 44);
	
	
	
	
	
	
	
	
	// Camera Radial Menu
	self.cameraRadialMenu = [[MTZRadialMenu alloc] initWithFrame:left];
	[self.cameraRadialMenu setImage:[UIImage imageNamed:@"Camera"] forState:UIControlStateNormal];
	[self.cameraRadialMenu setImage:[UIImage imageNamed:@"CameraHighlighted"] forState:UIControlStateSelected];
	[self.view addSubview:self.cameraRadialMenu];
	
	
	self.recording = NO;
	__block ViewController *blocksafeSelf = self;
	
	// Camera Cancel
	MTZAction *cameraCancel = [MTZAction actionWithStyle:MTZActionStyleCancel handler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
		// TODO: Only dismiss radial menu after touch has at least left the original location (must wait for it to highlight again, or touch changed).
		[self cameraCancel];
	}];
	
	// Camera Photo Take and Send
	self.cameraPhotoTakeAndSendAction = [MTZAction actionWithStyle:MTZActionStyleCamera handler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
		[self cameraTakeAndSendPhoto];
	}];
	
	// Camera Recording Start
	self.cameraRecordingStartAction = [MTZAction actionWithIcon:[UIImage imageNamed:@"ActionCameraRecord"] highlightedHandler:^(MTZRadialMenu *radialMenu, MTZAction *action, BOOL highlighted) {
		if (highlighted) {
			[self cameraRecord];
		}
	} selectedHandler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
		[self cameraRecord];
	}];

	// Camera Recording Stop
	self.cameraRecordingStopAction = [MTZAction actionWithImage:[UIImage imageNamed:@"ActionCameraStop"] highlightedImage:[UIImage imageNamed:@"ActionCameraStopHighlighted"] highlightedHandler:^(MTZRadialMenu *radialMenu, MTZAction *action, BOOL highlighted) {
		if (highlighted) {
			[self cameraStop];
		}
	} selectedHandler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
		[self cameraStop];
	}];
	
	// Camera Recording Playback Play
	self.cameraRecordingPlaybackPlayAction = [MTZAction actionWithStyle:MTZActionStylePlay handler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
		[self cameraRecordingPlaybackPlay];
	}];

	// Camera Recording Playback Pause
	self.cameraRecordingPlaybackPauseAction = [MTZAction actionWithStyle:MTZActionStylePause handler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
		[self cameraRecordingPlaybackPause];
	}];
	
	// Camera Recording Send
	self.cameraRecordingSendAction = [MTZAction actionWithStyle:MTZActionStyleConfirm handler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
		[self cameraRecordingSend];
	}];
	
	[self.cameraRadialMenu setAction:cameraCancel forLocation:MTZRadialMenuLocationCenter];
	[self resetCameraRadialMenu];
	
	
	
	
	
	
	
	
	
	
	
	
	
	// Microphone Radial Menu
	MTZRadialMenu *microphoneRadialMenu = [[MTZRadialMenu alloc] initWithFrame:right];
	microphoneRadialMenu.delegate = self;
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
	
	MTZAction *play = [MTZAction actionWithImage:[UIImage imageNamed:@"ActionPlay"]
								highlightedImage:[UIImage imageNamed:@"ActionPlayHighlighted"]
							  highlightedHandler:^(MTZRadialMenu *radialMenu, MTZAction *action, BOOL highlighted) {
								  NSLog(@"Play Highlighted: %d", highlighted);
							  }
								 selectedHandler:^(MTZRadialMenu *radialMenu, MTZAction *action) {
									 NSLog(@"Play");
								 }];
	[microphoneRadialMenu setAction:play forLocation:MTZRadialMenuLocationCenter];
}


#pragma mark Camera

- (void)resetCameraRadialMenu
{
	[self.cameraRadialMenu setAction:self.cameraPhotoTakeAndSendAction forLocation:MTZRadialMenuLocationTop];
	[self.cameraRadialMenu setAction:self.cameraRecordingStartAction forLocation:MTZRadialMenuLocationRight];
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
	self.recording = YES;
	
	// Change the action to stop.
	[self.cameraRadialMenu setAction:self.cameraRecordingStopAction forLocation:MTZRadialMenuLocationRight];
}

- (void)cameraStop
{
	NSLog(@"Camera: Stop");
	
	// The camera is no longer recording.
	self.recording = NO;
	
	[self.cameraRadialMenu setAction:self.cameraRecordingPlaybackPlayAction forLocation:MTZRadialMenuLocationRight];
	[self.cameraRadialMenu setAction:self.cameraRecordingSendAction forLocation:MTZRadialMenuLocationTop];
}

- (void)cameraRecordingPlaybackPlay
{
	NSLog(@"Camera: Play");
	
	[self.cameraRadialMenu setAction:self.cameraRecordingPlaybackPauseAction forLocation:MTZRadialMenuLocationRight];
}

- (void)cameraRecordingPlaybackPause
{
	NSLog(@"Camera: Pause");
	
	[self.cameraRadialMenu setAction:self.cameraRecordingPlaybackPlayAction forLocation:MTZRadialMenuLocationRight];
}

- (void)cameraRecordingSend
{
	NSLog(@"Camera: Sending Recording");
	
	[self.cameraRadialMenu dismissMenuAnimated:YES];
}


#pragma mark MTZRadialMenuDelegate

- (void)radialMenuWillDisplay:(MTZRadialMenu *)radialMenu
{
	NSLog(@"radialMenuWillDisplay");
}

- (void)radialMenuDidDisplay:(MTZRadialMenu *)radialMenu
{
	NSLog(@"radialMenuDidDisplay");
}

- (void)radialMenuWillDismiss:(MTZRadialMenu *)radialMenu
{
	NSLog(@"radialMenuWillDismiss");
}

- (void)radialMenuDidDismiss:(MTZRadialMenu *)radialMenu
{
	NSLog(@"radialMenuDidDismiss");
	
	if (radialMenu == self.cameraRadialMenu) {
		[self resetCameraRadialMenu];
	}
}

@end
