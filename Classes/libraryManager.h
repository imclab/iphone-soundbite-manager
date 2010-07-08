//
//  libraryManager.h
//  audioPlayer
//
//  Created by Aaron Leese on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


// custom class for QUESTIONS AND ANSWERS
@interface SoundBite : NSObject {
	
	NSString *sqlID;
	NSString *name;
	NSString *description;
	NSString *fileName;
	NSString *set; // the set of questions this belongs too ... or the ID of a question, if this is an answer ...
	BOOL answered;
	NSString *comment;

}

@property(readwrite, assign)  NSString *sqlID;
@property(readwrite, assign)  NSString *name;
@property(readwrite, assign)  NSString *description;
@property(readwrite, assign)  NSString *fileName;
@property(readwrite, assign)  NSString *set;
@property(readwrite, assign)  BOOL answered;
@property(readwrite, assign)  NSString *comment;

@end


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


@end
