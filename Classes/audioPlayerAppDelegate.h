//
//  midiPlayerAppDelegate.h
//  midiPlayer
//
//  Created by Aaron Leese on 4/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import "downloadViewController.h"

#import "libraryViewController.h"

#import "downloadManager.h"
#import "libraryManager.h"
#import "audioPlayer.h"

@interface audioPlayerAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window; 
 
	// custom classed objects ...
	libraryManager *myLibrary;
	audioPlayer *myAudioPlayer;
	downloadManager *downloader;
	
	IBOutlet libraryViewController *myLibraryView;

	NSString *CurrentQuestionID;
	
	
}

@property (nonatomic, retain) NSString *CurrentQuestionID;

@property (nonatomic, retain) IBOutlet UIWindow *window; 

//- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag;
- (void) startRecording;
- (void) stopRecording;
- (void) play:(NSString*)fileName; 
- (void) setVolume:(float) newVolume;
- (bool) isRecording;
- (float) getInputOrOutputLevel;

- (NSString *) getCurrentQuestionFile;
- (NSString*) getRecordedToPath;
- (void) setCurrentQuestion:(NSString*)group withID:(NSString*)sqlID;
- (NSMutableArray*) getSoundBiteArray;

- (void) triggerDownload:(NSURL*) newItem;
 

// Library ////////////////////////////////////// 
- (NSArray*) getCurrentQuestionGroup;
- (void) setCurrentQuestionGroup:(NSString*) newGroup;

- (NSString*) getCurrentQuestionGroupName;

-(SoundBite*) getCurrentSoundbite;
- (void) setCurrentSoundbite:(SoundBite*) currentSoundbite;
@end
