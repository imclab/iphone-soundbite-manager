//
//  downloadManager.m
//  audioPlayer
//
//  Created by Aaron Leese on 7/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "downloadManager.h"
#import "audioPlayerAppDelegate.h"

#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }



@implementation downloadManager


// UPLOAD methods
- (void) confirmRecievedNewItems
{
	
	// Here we send a quick response to the server to indicate that we recieved the new items
	// The server PHP handles these requests and marks the files as delivered
	/////////////////////////////////////////
	NSString *URL = @"http://www.flyloops.com/iphone/index.php";
	NSURL* url = [NSURL URLWithString:URL];
	
	// ping the web app, note that this question has been recieved ....
	//ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	//[request setPostValue:@"1" forKey:@"QuestionNum"];
	//[request startAsynchronous];
	
}

- (void) uploadAnAnswer {
	
	// hmmm .....
	
}


- (void) uploadANewQuestion {
	
	// hmmm ....
}



// DOWNLOAD methods 

-(void)downloadItem {
	if (networkQueue == nil) {
		networkQueue = [ASINetworkQueue queue];
		[networkQueue retain];
		[networkQueue go];
	}
	
	
	
	NSString* appDirectory = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
	NSString* docDirectory  = [appDirectory stringByAppendingString:@"/Documents/"];
	NSString* theFileName = [[currentURL path] lastPathComponent];
	
	NSLog(@"downloading to: %@", docDirectory); 
	
	NSString *path = [docDirectory stringByAppendingString:theFileName];
	NSLog(@"*** starting download to path: %@ FROM %@", path, [currentURL path]);
	
	[ASIHTTPRequest clearSession]; //Silly @HACK
	RELEASE_SAFELY(downloadRequest);
	downloadRequest = [[ASIHTTPRequest alloc] initWithURL:currentURL];
	[downloadRequest setDownloadDestinationPath: path];
	[downloadRequest setTimeOutSeconds: 60];
	[downloadRequest setDelegate: self];
	[downloadRequest setRequestMethod: @"GET"];
	[downloadRequest setAllowResumeForFileDownloads: YES];
	[downloadRequest setDownloadProgressDelegate:self];
	[downloadRequest setDidFinishSelector: @selector(downloadFinished:)];
	[networkQueue setShowAccurateProgress: YES];
	[networkQueue addOperation: downloadRequest];
	//self.progressView.progress = 0.0;
	[networkQueue go];
	
	
}

- (void) triggerDownload:(NSURL*) newItem {
	NSLog(@"triggering download to library");
	
	if (networkQueue == nil) {
		networkQueue = [ASINetworkQueue queue];
		[networkQueue retain];
		[networkQueue go];
	}
	
	NSString* appDirectory = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
	NSString* docDirectory  = [appDirectory stringByAppendingString:@"/Documents/"];
	NSString* theFileName = [[newItem path] lastPathComponent];
	NSString *path = [docDirectory stringByAppendingString:theFileName];
	NSLog(@"*** DOWNLOAD to path: %@ FROM %@", path, newItem);
	
	[ASIHTTPRequest clearSession]; //Silly @HACK
	RELEASE_SAFELY(downloadRequest);
	downloadRequest = [[ASIHTTPRequest alloc] initWithURL:newItem];
	[downloadRequest setDownloadDestinationPath: path];
	[downloadRequest setTimeOutSeconds: 60];
	[downloadRequest setDelegate: self];
	[downloadRequest setRequestMethod: @"GET"];
	[downloadRequest setAllowResumeForFileDownloads: YES];
	[downloadRequest setDownloadProgressDelegate:self];
	[downloadRequest setDidFinishSelector: @selector(downloadFinished:)];
	[networkQueue setShowAccurateProgress: YES];
	[networkQueue addOperation: downloadRequest];
	//self.progressView.progress = 0.0;
	[networkQueue go];	
	
}

-(IBAction)cancelDownload:(UIBarButtonItem*)btn {
	[networkQueue cancelAllOperations]; 
}
 
- (void)downloadFinished:(ASIHTTPRequest *)request {
	
	NSLog(@"finished download");
	
	if (request.responseStatusCode != 200) {
		NSLog(@"Request Headers: %@", [request requestHeaders]);
		//	LOG(@"Failure downloading content");
		//	LOG(@"Server Response: %d, %@, %@", request.responseStatusCode, request.responseHeaders, [request responseString]);
		return;
	}
	
	//LOG(@"downloadFinished: %@", [request downloadDestinationPath]);
	NSString* ext = [[request downloadDestinationPath] pathExtension];
	//NSString* fn = [[request downloadDestinationPath] lastPathComponent];
	
	if([ext caseInsensitiveCompare: @"pdf"] == NSOrderedSame) {
		//	LOG(@"!adding PDF --> [%@] %@", fn, MUSICFILE_PATH(fn));
		NSError *err;
		/*	if ([[NSFileManager defaultManager] copyItemAtPath:[request downloadDestinationPath]
		 toPath:MUSICFILE_PATH(fn) error:&err]) 
		 {
		 //[NLPScorePDF createUserScore:fn];
		 NSString *title = [[[currentURL path] lastPathComponent] stringByDeletingPathExtension];
		 //	[NLPScorePDF createUserScore:fn title:title];
		 //[NLPAlert alert:@"PDF Added" withMessage:score.title];
		 } else {
		 //	[NLPAlert alert:@"Error adding PDF" withMessage:fn];
		 }
		 */
	} 
	
	
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate refreshLibraryView];	
	//[libController refreshLibraryView];
	
}

// other ....

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:@"Download" message:   
						  @"download failed!"
						  delegate:self cancelButtonTitle:@"OK" 
						  otherButtonTitles:nil, nil];
	[alert show];
	[alert release];
	
	NSLog(@"ERROR: NSError query result: %@", error);
	NSLog(@"Server Response: %d, %@", request.responseStatusCode, request.responseHeaders);
	//[NLPAlert alert:@"DownloadError" withMessage:[NSString stringWithFormat:@"%@", error]];
}
 
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self loadURL:textField.text];
	[textField resignFirstResponder];
	return YES;
}
 

/**
 Some reference material here:
 http://stackoverflow.com/questions/1555289/detecting-download-in-uiwebview
 */


- (void)dealloc {
	
	[networkQueue cancelAllOperations];
}




@end