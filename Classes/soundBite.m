//
//  soundBite.m
//  audioPlayer
//
//  Created by Aaron Leese on 7/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "soundBite.h"

@implementation SoundBite

-(id) init {
	
	fileName = @"filename";
	questionName = @"no name";
	sqlID = @"none";
	
	return self;
}

-(id)copyWithZone:(NSZone *)zone
{
	
	NSLog(@"copy constructor for soundbite -");
	
	// We'll ignore the zone for now
	SoundBite *another = [[SoundBite alloc] init];
		
	another->fileName = [fileName copyWithZone: zone];
	another->questionName = [questionName copyWithZone: zone]; 
	another->sqlID = [sqlID copyWithZone: zone]; 
	another->parentQuestionOrSet = [parentQuestionOrSet copyWithZone: zone];
	another->comments = [comments copyWithZone: zone];
	
	return another;
}

-(id) getDictionary
{
	// this synthesizes the soundbite into a dictionary object (which can then be saved)
	
	NSMutableDictionary *newValue = [[NSMutableDictionary alloc] init];
	
	[newValue setObject:fileName forKey:@"fileName"]; 
	[newValue setObject:questionName forKey:@"name"]; 
	[newValue setObject:sqlID forKey:@"sqlID"];  
	[newValue setObject:parentQuestionOrSet forKey:@"parentQuestionOrSet"]; 
	[newValue setObject:comments forKey:@"comments"];  
	
	return [NSDictionary dictionaryWithDictionary:newValue];
	
}

-(NSString*) getID {
	return sqlID; 
}

-(NSString*) getName {
	
	return questionName;
}


-(void) testing: (NSString*) test
{
	questionName = @"asdasdasdfsdf";

}


/*
-(NSString*)setName:(NSString*)newName {
	name = newName;
}

-(NSString*) getComments {
	return comments;
}

-(NSString*) setComments:(NSString*)newComments {
	comments = newComments;
}
 */



@synthesize sqlID;
@synthesize questionName;
@synthesize fileName; 
@synthesize parentQuestionOrSet; 
@synthesize comments;

@end

