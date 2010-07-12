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
	
	SoundBite* currentSoundbite;
}

- (void) updateLibrary;
- (void) refreshLibrary;

- (NSArray*) getLibraryArray:(NSString*)QuestionGroup;
- (NSMutableArray*)getCurrentSoundBiteArray:(NSString*)group;

- (void) setAnswerPath:(NSString*) answerPath;

- (SoundBite*) getCurrentSoundBite;
- (void) setCurrentSoundbite:(SoundBite*) newCurrentSoundbite;

@end
