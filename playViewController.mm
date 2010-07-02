//
//  playViewController.m
//
//  Created by Aaron Leese on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "playViewController.h"

#import "audioPlayerAppDelegate.h"

#import <AVFoundation/AVFoundation.h>


@implementation levelIndicator

- (void)drawRect:(CGRect)rect
{
	
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	float level = [appDelegate getInputLevel];
	// in Db ... order of -60 ... up to 0
	
	
	CGContextRef context = UIGraphicsGetCurrentContext(); 
    
	CGContextClearRect(context, CGRectMake(0, 0, 50, 300));
	
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 0.0, 1.0); // yellow line
	
	/*
    CGContextBeginPath(context);
	
    CGContextMoveToPoint(context, 0.0, 0.0); //start point
    CGContextAddLineToPoint(context, 20.0, 20.0);
    CGContextAddLineToPoint(context, 250.0, 350.0);
    CGContextAddLineToPoint(context, 50.0, 350.0); // end path
    CGContextClosePath(context); // close path
	
    CGContextSetLineWidth(context, 8.0); // this is set from now on until you explicitly change it
	
    CGContextStrokePath(context); // do actual stroking
	
	 */
	
	CGContextSetRGBFillColor(context, (level/60 + 1), 1.0, 0.0, 0.5); // green color, half transparent ....
	CGContextFillRect(context, CGRectMake(0.0, 0.0 - 3*level, 20.0, 300.0)); // a square at the bottom left-hand corner

	
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		NSLog(@"levelindicator init");
		
		
	}
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end

//////////////////////////////////////////////////
@implementation playViewController

@synthesize playButton; 
@synthesize stopButton; 
@synthesize recButton; 
@synthesize volumeSlider;  
@synthesize statusLabel; 

-(void)viewDidLoad
{	
	self.statusLabel.text = @"";

	volumeSlider.transform = CGAffineTransformRotate(volumeSlider.transform, 270.0/180*M_PI);
	
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1
											 target:self
										   selector: @selector(timerCallback)
										   userInfo:nil
											repeats: YES];
	
	//levelIndicator *myLevelIndicator = [[levelIndicator alloc] init];
	//myLevelIndicator = [[levelIndicator alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 100.0)];
	
	
}

-(IBAction)buttonPressed:(id)sender {
	
	  	
	if ([[sender currentTitle] isEqualToString:(@"play question")])
	{ 
		
		audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		if ([[appDelegate getCurrentQuestion] length] == 0)
		{ 		 
		 UIAlertView *alert = [[UIAlertView alloc] 
		 initWithTitle:@"Error" message:   
		 @"please select a question to play"
		 delegate:self cancelButtonTitle:@"OK" 
		 otherButtonTitles:nil, nil];
		 [alert show];
		 [alert release];
		 
		 return;
		}
	
		NSString *fileName = [appDelegate getCurrentQuestion];
	 	NSString *docDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/"];
		NSString *soundFilePath = [docDirectory stringByAppendingPathComponent:fileName];

		
		[appDelegate play:soundFilePath];

		//play:(NSString*) filePath {
		
		/*
		NSString *soundFilePath = [appDelegate getCurrentQuestion];
		NSURL *soundFileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
		
		
		[[AVAudioSession sharedInstance] setDelegate: self];
		[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];
		
		// Registers the audio route change listener callback function
		//  AudioSessionAddPropertyListener (
		//                                 kAudioSessionProperty_AudioRouteChange,
		//                               audioRouteChangeListenerCallback,
        //                             self
		//                           );
		
		// Activates the audio session.
		
		NSError *activationError = nil;
		[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
		
		AVAudioPlayer *appSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: soundFileURL error: nil];
		//[newPlayer release];
		
		[appSoundPlayer prepareToPlay];
		[appSoundPlayer setVolume: 1.0];
		[appSoundPlayer setDelegate: self];
		[appSoundPlayer play];

		 */
		
		
	
	}

	else if ([[sender currentTitle] isEqualToString:(@"record")])
	{
		
		 audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate startRecording];
		  		
	}
	else if ([[sender currentTitle] isEqualToString:(@"stop")])
	{
		
		audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
		[appDelegate stopRecording];
		 
	}
}

/* volume slider */
- (IBAction)sliderMoved:(id)sender;
{
	 //myMidiPlayer->setVolume(100*(volumeSlider.value));
}

-(void) timerCallback
{
	
	[myLevelIndicator setNeedsDisplay];
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSString *title = [recButton titleForState:UIControlStateNormal];
	
	if ([appDelegate isRecording] && [title isEqualToString:@"record"])
	{
			[recButton setTitle:@"stop" forState:UIControlStateNormal];
			[recButton setTitle:@"stop" forState:UIControlStateHighlighted];
			[recButton setTitle:@"stop" forState:UIControlStateSelected];
	}
	else if  ( ![appDelegate isRecording] && [title isEqualToString:@"stop"])
	{
			[recButton setTitle:@"record" forState:UIControlStateNormal];
			[recButton setTitle:@"record" forState:UIControlStateHighlighted];
			[recButton setTitle:@"record" forState:UIControlStateSelected];
				 
	}
	
}

@end

