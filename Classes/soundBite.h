//
//  soundBite.h
//  audioPlayer
//
//  Created by Aaron Leese on 7/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// custom class for QUESTIONS AND ANSWERS
@interface SoundBite : NSObject <NSCopying> {
	
@public
	NSString *sqlID;
	NSString *questionName; 
	NSString *fileName;
	NSString *parentQuestionOrSet; // the set of questions this belongs too ... or the ID of a question, if this is an answer ...
	NSString *comments;
	
}

-(id)copyWithZone:(NSZone *)zone;

-(id)getDictionary;

-(NSString*) getID;
-(NSString*) getName;  
/*
-(NSString*) setName:(NSString*)newName;
-(NSString*) getComments;
-(NSString*) setComments:(NSString*)newComments;
*/

-(void) testing: (NSString*) test;

@property(readwrite, assign)  NSString *sqlID;
@property(readwrite, assign)  NSString *questionName;  
@property(readwrite, assign)  NSString *fileName;
@property(readwrite, assign)  NSString *parentQuestionOrSet; 
@property(readwrite, assign)  NSString *comments;

@end
