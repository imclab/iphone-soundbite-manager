//
//  libraryManager.h
//  audioPlayer
//
//  Created by Aaron Leese on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "soundBite.h"


// The LIBRARY manager, which handles the questions ...
//////////////////////////////////////////////////////////////
@interface libraryManager : NSObject {

	NSMutableDictionary *libraryArray;
	
	// STATE variables .... //////////
	NSString *currentGroup; 
	
	SoundBite* currentSoundbite;
}

- (void) updateLibrary;
- (void) refreshLibrary;

- (NSArray*) getCurrentQuestionGroupArray;
- (NSMutableArray*)getCurrentSoundBiteArray;

- (void) setAnswerPath:(NSString*) answerPath;

- (SoundBite*) getCurrentSoundBite;
- (void) setCurrentSoundbite:(SoundBite*) newCurrentSoundbite;

- (NSString*) getCurrentQuestionGroupName;

- (void) createNewGroup:(NSString*) newGroupName;

- (NSString*) getCurrentGroup;
- (void) getCurrentGroup:(NSString*) newGroup;


@end
