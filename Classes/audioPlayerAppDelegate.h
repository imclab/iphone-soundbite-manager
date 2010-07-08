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

@interface audioPlayerAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
 
	// custom classed objects ...
	libraryManager *myLibrary;
	audioPlayer *myAudioPlayer;
	downloadManager *downloader;
	
	IBOutlet libraryViewController *myLibraryView;

	NSString *CurrentQuestionID;
}

@property (nonatomic, retain) NSString *CurrentQuestionID;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

//- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag;
- (void) startRecording;
- (void) stopRecording;
- (void) play:(NSString*)fileName; 
- (void) setVolume:(float) newVolume;
- (bool) isRecording;
- (float) getInputOrOutputLevel;

- (NSString *) getCurrentQuestionFile;
- (void) setCurrentQuestion:(NSString*)group withID:(NSString*)sqlID;
- (NSMutableArray*) getSoundBiteArray:(NSString*)group;

- (void) triggerDownload:(NSURL*) newItem;
- (NSArray*) getLibrary:(NSString*)QuestionGroup;
@end
