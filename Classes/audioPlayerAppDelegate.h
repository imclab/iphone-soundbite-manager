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

///////////////////////////////// AUDIO
- (void) startRecording;
- (void) stopRecording;
- (void) play:(NSString*)fileName; 
- (void) setVolume:(float) newVolume;
- (bool) isRecording;
- (float) getInputOrOutputLevel;
- (void) reviewRecorded;
- (void) createNewSoundbite;

///////////////////////////////// LIBRARY
- (NSString *) getCurrentQuestionFile;
- (NSString*) getRecordedToPath;
- (void) setCurrentQuestion:(NSString*)group withID:(NSString*)sqlID;
- (NSMutableArray*) getSoundBiteArray;
- (NSArray*) getCurrentQuestionGroup;
- (void) setCurrentQuestionGroup:(NSString*) newGroup;
- (NSString*) getCurrentQuestionGroupName;
-(SoundBite*) getCurrentSoundbite;
- (void) setCurrentSoundbite:(SoundBite*) currentSoundbite;

- (void) setQuestionName:(NSString*) newName;


///////////////////////////////// UPLOAD / DOWNLOAD
- (void) triggerDownload:(NSURL*) newItem;
- (void) uploadAnswer;
- (void) saveSoundbiteToLibrary;	

@end
