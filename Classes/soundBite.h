//
//  soundBite.h
//  audioPlayer
//
//  Created by Aaron Leese on 7/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// custom class for QUESTIONS AND ANSWERS
@interface SoundBite : NSObject {
	
	NSString *sqlID;
	NSString *name;
	NSString *description;
	NSString *fileName;
	 
	NSString *parentQuestionOrSet; // the set of questions this belongs too ... or the ID of a question, if this is an answer ...
	
	NSString *comments;
	
	
}

@property(readwrite, assign)  NSString *sqlID;
@property(readwrite, assign)  NSString *name;
@property(readwrite, assign)  NSString *answerFile;
@property(readwrite, assign)  NSString *description;
@property(readwrite, assign)  NSString *fileName;
@property(readwrite, assign)  NSString *parentQuestionOrSet; 
@property(readwrite, assign)  NSString *comments;

@end
