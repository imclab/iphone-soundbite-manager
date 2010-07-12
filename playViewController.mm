//
//  playViewController.m
//
//  Created by Aaron Leese on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "playViewController.h"
#import "audioPlayerAppDelegate.h"
#import "soundBite.h"
#import <AVFoundation/AVFoundation.h>

@implementation levelIndicator

- (void)drawRect:(CGRect)rect {
	
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	float level = [appDelegate getInputOrOutputLevel];
	 
	CGContextRef context = UIGraphicsGetCurrentContext(); 
    
	CGContextClearRect(context, CGRectMake(0, 0, 20, 350));
	
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 0.0, 1.0); // yellow line
	
	// recall - level is in dB (hance negative)
	CGContextSetRGBFillColor(context, (level/60 + 1), 1.0, 0.0, 1.0); // green color, half transparent ....
	CGContextFillRect(context, CGRectMake(0.0, -3*level, 20.0, 350.0)); // a square at the bottom left-hand corner

	
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
@synthesize playAnswerButton; 
@synthesize stopButton; 
@synthesize recButton; 
@synthesize volumeSlider;  
@synthesize answerLabel; 
@synthesize comments; 

-(void)viewDidLoad
{	
	
	volumeSlider.transform = CGAffineTransformRotate(volumeSlider.transform, 270.0/180*M_PI);
	
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1
											 target:self
										   selector: @selector(timerCallback)
										   userInfo:nil
											repeats: YES];
	
	
	// set the comments field text ...
	
	
	// check and see if there is an answer, disable the playAnswer button if not ...
	
	
	//if (answerFile)
	/*
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	SoundBite *soundBite = [appDelegate getCurrentSoundbite];
	[comments setText:[soundBite comments]];
	
	NSLog(@"bite %@", [soundBite answerFile]);
	
	if ([[soundBite answerFile] length] != 0)
	{
		[playAnswerButton setEnabled:true];
		[answerLabel setText:[soundBite answerFile]];
	}
	else 
	{
		[playAnswerButton setEnabled:false];
		[answerLabel setText:@""];
	}
	 */
	
	
}

-(void)viewDidAppear:(BOOL)animated 
{ 
	
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	SoundBite *soundBite = [appDelegate getCurrentSoundbite];
	[comments setText:[soundBite comments]];
	
	NSLog(@"bite %@", [soundBite answerFile]);
	
	if ([[soundBite answerFile] length] != 0)
	{
		[playAnswerButton setEnabled:true];
		
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		
		NSTimeInterval timeStamp = [[[soundBite answerFile] stringByDeletingPathExtension] doubleValue];
		
		NSDate *myDate = [NSDate dateWithTimeIntervalSinceReferenceDate: timeStamp];
		
		NSString *dateString = [myDate description];
	
		[answerLabel setText:dateString];
	}
	else 
	{
		[playAnswerButton setEnabled:false];
		[answerLabel setText:@""];
	}

	
}

-(IBAction)buttonPressed:(id)sender {
	
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	  	
	if ([[sender currentTitle] isEqualToString:(@"play question")])
	{ 
		
		if ([[appDelegate getCurrentQuestionFile] length] == 0)
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
	
		NSString *fileName = [appDelegate getCurrentQuestionFile];
	 	NSString *docDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/"];
		NSString *soundFilePath = [docDirectory stringByAppendingPathComponent:fileName];

		
		[appDelegate play:soundFilePath];

	}
	else if ([[sender currentTitle] isEqualToString:(@"record")])
	{
		 [appDelegate startRecording];
	}
	else if ([[sender currentTitle] isEqualToString:(@"stop")])
	{
		 [appDelegate stopRecording];
	}
	else if ([[sender currentTitle] isEqualToString:(@"play answer")])
	{
		/*
		if ([[appDelegate getCurrentQuestionFile] length] == 0)
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
		 */
		
		SoundBite *soundBite = [appDelegate getCurrentSoundbite];
		
		
		NSString *fileName = [soundBite answerFile];
	 	NSString *docDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/"];
		NSString *soundFilePath = [docDirectory stringByAppendingPathComponent:fileName];
		
		
		[appDelegate play:soundFilePath];
		
	}

}

/* volume slider */
- (IBAction)sliderMoved:(id)sender;
{
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setVolume:[volumeSlider value]];
	
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

