//
//  downloadManager.h
//  audioPlayer
//
//  Created by Aaron Leese on 7/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h" 


@interface downloadManager : NSObject {

	ASIHTTPRequest *downloadRequest;
	ASINetworkQueue *networkQueue; 
	
	NSURL *currentURL;
	
}


-(void)downloadItem;
-(void)uploadAnswer;
-(void)uploadNewQuestion;

-(void)triggerDownload:(NSURL*)newItem;

@end
