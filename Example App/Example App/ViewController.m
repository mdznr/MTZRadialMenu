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

@property (nonatomic, getter=isMicrophoneRecording) BOOL microphoneRecording;
@property (strong, nonatomic) MTZRadialMenu *microphoneRadialMenu;
@property (strong, nonatomic) MTZRadialMenuItem *microphoneRecordingStopAction;
@property (strong, nonatomic) MTZRadialMenuItem *microphoneRecordingPlaybackPlayAction;
@property (strong, nonatomic) MTZRadialMenuItem *microphoneRecordingPlaybackPauseAction;
@property (strong, nonatomic) MTZRadialMenuItem *microphoneRecordingSendAction;

@end

@implementation ViewController
            
- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	
	self.cameraRecording = NO;
	self.microphoneRecording = NO;
	
	
	CGRect middle = CGRectMake(138, 269, 44, 44);
	CGRect right = CGRectMake(271, 269, 44, 44);
	CGRect left = CGRectMake(5, 269, 44, 44);
	
	
	// Camera Radial Menu
	self.cameraRadialMenu = [[MTZRadialMenu alloc] initWithBackgroundVisualEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
	self.cameraRadialMenu.frame = left;
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
	self.microphoneRadialMenu = [[MTZRadialMenu alloc] initWithBackgroundVisualEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
	self.microphoneRadialMenu.frame = right;
	self.microphoneRadialMenu.delegate = self;
	[self.microphoneRadialMenu setImage:[UIImage imageNamed:@"Microphone"] forState:UIControlStateNormal];
	[self.microphoneRadialMenu setImage:[UIImage imageNamed:@"Microphone"] forState:UIControlStateSelected];
	[self.view addSubview:self.microphoneRadialMenu];
	
	MTZRadialMenuItem *microphoneCancel = [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:MTZRadialMenuStandardItemCancel handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		[self microphoneCancel];
	}];
	[self.microphoneRadialMenu setItem:microphoneCancel forLocation:MTZRadialMenuLocationLeft];
	
	self.microphoneRecordingSendAction = [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:MTZRadialMenuStandardItemConfirm handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		[self microphoneRecordingSend];
	}];
	[self.microphoneRadialMenu setItem:self.microphoneRecordingSendAction forLocation:MTZRadialMenuLocationTop];
	
	self.microphoneRecordingStopAction = [MTZRadialMenuItem menuItemWithImage:[UIImage imageNamed:@"ActionCameraStop"] highlightedImage:[UIImage imageNamed:@"ActionCameraStopHighlighted"] handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		[self microphoneStop];
	}];
	[self.microphoneRadialMenu setItem:self.microphoneRecordingStopAction forLocation:MTZRadialMenuLocationCenter];
	
	// Microphone Recording Playback Play
	self.microphoneRecordingPlaybackPlayAction = [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:MTZRadialMenuStandardItemPlay handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		[self microphoneRecordingPlaybackPlay];
	}];
	
	// Microphone Recording Playback Pause
	self.microphoneRecordingPlaybackPauseAction = [MTZRadialMenuItem menuItemWithRadialMenuStandardItem:MTZRadialMenuStandardItemPause handler:^(MTZRadialMenu *radialMenu, MTZRadialMenuItem *menuItem) {
		[self microphoneRecordingPlaybackPause];
	}];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
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


#pragma mark Microphone

- (void)resetMicrophoneRadialMenu
{
	[self.microphoneRadialMenu setItem:self.microphoneRecordingStopAction forLocation:MTZRadialMenuLocationCenter];
}

- (void)microphoneCancel
{
	NSLog(@"Microphone: Cancel");
	
	// TODO: Stop Recording.
	
	[self.microphoneRadialMenu dismissMenuAnimated:YES];
}

- (void)microphoneStop
{
	NSLog(@"Microphone: Stop");
	
	// The camera is no longer recording.
	self.microphoneRecording = NO;
	
	[self.microphoneRadialMenu setItem:self.microphoneRecordingPlaybackPlayAction forLocation:MTZRadialMenuLocationCenter];
}

- (void)microphoneRecordingSend
{
	NSLog(@"Microphone: Sending Recording");
	
	// TODO: Stop Recording and send.
	self.microphoneRecording = NO;
	
	[self.microphoneRadialMenu dismissMenuAnimated:YES];
}

- (void)microphoneRecordingPlaybackPlay
{
	NSLog(@"Microphone: Play");
	
	[self.microphoneRadialMenu setItem:self.microphoneRecordingPlaybackPauseAction forLocation:MTZRadialMenuLocationCenter];
}

- (void)microphoneRecordingPlaybackPause
{
	NSLog(@"Microphone: Pause");
	
	[self.microphoneRadialMenu setItem:self.microphoneRecordingPlaybackPlayAction forLocation:MTZRadialMenuLocationCenter];
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
	} else if (radialMenu == self.microphoneRadialMenu) {
		[self resetMicrophoneRadialMenu];
	}
}

@end
