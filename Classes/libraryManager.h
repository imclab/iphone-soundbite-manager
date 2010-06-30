//
//  libraryManager.h
//  audioPlayer
//
//  Created by Aaron Leese on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface libraryManager : NSObject {

	NSMutableArray *libraryArray;
}

- (void) updateLibrary;
- (void) refreshLibrary;

- (NSMutableArray*) getLibraryArray;

@end