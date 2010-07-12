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
	name = @"Qname";
	sqlID = @"none";
	
	return self;
}

@synthesize sqlID;
@synthesize name;
@synthesize fileName;
@synthesize description;
@synthesize answerFile;
@synthesize set;
@synthesize answered;
@synthesize comments;

@end

