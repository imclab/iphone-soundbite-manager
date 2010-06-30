//
//  downloadViewController.m
//
//  Created by Aaron Leese on 5/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
 
#import "downloadViewController.h"

#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

#define kTagForDownloadButton 99
#define kDefaultDownloadURL @"http://www.flyloops.com/"

/*
@interface downloadViewController (Private)
-(void)downloadItem;
@end
*/

@implementation downloadViewController

@synthesize webView, activityIndicator;
@synthesize connection, urlTextField;
@synthesize progressView;


#pragma mark View Manipulations


-(void)viewDidLoad
{	
	 
	[super viewDidLoad];
	 
	
	 self.webView.scalesPageToFit = YES;
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:kDefaultDownloadURL]]];

	//[self loadURL:kDefaultDownloadURL];
	//[webView setMainFrameURL:@"http://www.google.com"];
	
	activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[activityIndicator setCenter:CGPointMake(320/2.0, 460/2.0)]; // I do this because I'm in landscape mode
	[self.view addSubview:activityIndicator];
	
}


// Downloading 

-(IBAction)cancelDownload:(UIBarButtonItem*)btn
{
	[networkQueue cancelAllOperations]; 
}

-(IBAction)done:(UIBarButtonItem*)btn
{
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)back:(UIBarButtonItem*)btn
{
	[webView goBack];
}

-(IBAction)forward:(UIBarButtonItem*)forward
{
	[webView goForward];
}

-(IBAction)download:(UIBarButtonItem*)download
{
	[self downloadItem];
}

#pragma	mark Progress Delegate

-(void)setProgress:(float)progress {
	self.progressView.progress = progress;

}


#pragma mark Http REQUEST delegate

/**
 Content-Disposition: attachment; filename=fname.ext
 */
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
	NSString* fn = [[request downloadDestinationPath] lastPathComponent];
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
	
	[libController refreshLibraryView];
	
}

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

-(void)downloadItem
{
	if (networkQueue == nil) {
		networkQueue = [ASINetworkQueue queue];
		[networkQueue retain];
		[networkQueue go];
	}
	

	NSString* appDirectory = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
	NSString* docDirectory  = [appDirectory stringByAppendingString:@"/Documents/"];
	NSString* theFileName = [[currentURL path] lastPathComponent];
	
	NSLog(@"downloading to: %@", docDirectory); 
	
	// since we have no meta data on midi files,retain filename for now ...
	//Create a unique name for the file to avoid conflicts
	//CFUUIDRef theUUID = CFUUIDCreate(NULL);
	//CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	//CFRelease(theUUID);
	//NSString *fileUID = [(NSString *)string autorelease];
	//@TODO set correct file extention
	//NSString *path = [tempDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.mid", fileUID]];
	
	NSString *path = [docDirectory stringByAppendingString:theFileName];
	NSLog(@"*** starting download to path: %@ FROM %@", path, [currentURL path]);
	
	[ASIHTTPRequest clearSession]; //Silly @HACK
	RELEASE_SAFELY(downloadRequest);
	downloadRequest = [[ASIHTTPRequest alloc] initWithURL:currentURL];
	//	downloadRequest.product = product;
	[downloadRequest setDownloadDestinationPath: path];
	[downloadRequest setTimeOutSeconds: 60];
	[downloadRequest setDelegate: self];
	[downloadRequest setRequestMethod: @"GET"];
	[downloadRequest setAllowResumeForFileDownloads: YES];
	[downloadRequest setDownloadProgressDelegate:self];
	[downloadRequest setDidFinishSelector: @selector(downloadFinished:)];
	[networkQueue setShowAccurateProgress: YES];
	[networkQueue addOperation: downloadRequest];
	self.progressView.progress = 0.0;
	[networkQueue go];

	
}

- (void) triggerDownload:(NSURL*) newItem
{
	NSLog(@"triggering download to library");
	
	if (networkQueue == nil) {
		networkQueue = [ASINetworkQueue queue];
		[networkQueue retain];
		[networkQueue go];
	}
	
	NSString* appDirectory = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
	NSString* docDirectory  = [appDirectory stringByAppendingString:@"/Documents/"];
	NSString* theFileName = [[newItem path] lastPathComponent];
	
	NSLog(@"downloading to: %@", docDirectory); 
	
	// since we have no meta data on midi files,retain filename for now ...
	//Create a unique name for the file to avoid conflicts
	//CFUUIDRef theUUID = CFUUIDCreate(NULL);
	//CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	//CFRelease(theUUID);
	//NSString *fileUID = [(NSString *)string autorelease];
	//@TODO set correct file extention
	//NSString *path = [tempDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.mid", fileUID]];
	
	NSString *path = [docDirectory stringByAppendingString:theFileName];
	NSLog(@"*** starting download to path: %@ FROM %@", path, newItem);
	
	[ASIHTTPRequest clearSession]; //Silly @HACK
	RELEASE_SAFELY(downloadRequest);
	downloadRequest = [[ASIHTTPRequest alloc] initWithURL:newItem];
	//	downloadRequest.product = product;
	[downloadRequest setDownloadDestinationPath: path];
	[downloadRequest setTimeOutSeconds: 60];
	[downloadRequest setDelegate: self];
	[downloadRequest setRequestMethod: @"GET"];
	[downloadRequest setAllowResumeForFileDownloads: YES];
	[downloadRequest setDownloadProgressDelegate:self];
	[downloadRequest setDidFinishSelector: @selector(downloadFinished:)];
	[networkQueue setShowAccurateProgress: YES];
	[networkQueue addOperation: downloadRequest];
	self.progressView.progress = 0.0;
	[networkQueue go];	
	
}

- (void)updateButtonStati {
	//	[self.toolBar buttonWithTag:10].enabled = [self.webView canGoBack]; 
	//	[self.toolBar buttonWithTag:11].enabled = [self.webView canGoForward];
}

- (void)loadURL:(NSString*)url
{
	self.urlTextField.text = url;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
	[self.activityIndicator startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self updateButtonStati];
	self.activityIndicator.center = CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0);
}

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	NSLog(@"action sheet button clicked");
	
    if (buttonIndex == 0) {
		// Download 
		[self downloadItem];
    } else if (buttonIndex == 1) {
		// cancel ... do nothing
		NSLog(@"cancelled");
    }
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"didReceiveResponse: %@", [response MIMEType]);
	RELEASE_SAFELY(currentURL);
	
	if ([[response MIMEType] isEqualToString:@"audio/midi"]) {
		
		//[NLPAlert alert:@"PDF Detected" withMessage:@"You can add this score to your music library by clicking the download button in the top right corner."];
		currentURL = [[response URL] retain];
		
		UIActionSheet *popupQuery = [[UIActionSheet alloc]
									 initWithTitle:nil
									 delegate:self
									 cancelButtonTitle:@"Cancel"
									 destructiveButtonTitle:nil
									 otherButtonTitles:@"Download Midi",nil];
		
		popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		[popupQuery showInView:self.tabBarController.view];
		[popupQuery release];
		
	} 
	
	[conn cancel]; 
}

#pragma mark UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self loadURL:textField.text];
	[textField resignFirstResponder];
	return YES;
}

#pragma mark UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.activityIndicator stopAnimating];
	[self updateButtonStati];
}

/**
 Some reference material here:
 http://stackoverflow.com/questions/1555289/detecting-download-in-uiwebview
 */


- (BOOL) webView:(UIWebView *) webView shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType
{
	if (connection) [connection cancel];
	RELEASE_SAFELY(connection);
	//	[self.toolBar buttonWithTag:kTagForDownloadButton].enabled = NO;
	//	[self.toolBar buttonWithTag:kTagForDownloadButton].style = UIBarButtonItemStyleBordered;
	self.urlTextField.text = [[request URL] absoluteString];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	NSLog(@"shouldStartLoad: %@", [[request URL] path]);
	
	NSString* fileRequest = [[request URL] path];
	NSString* fileExt = [fileRequest pathExtension];
	NSLog(@"file ext: %@", fileExt);
	
	NSURL* url = [request URL];
    NSLog(@"URL: %@", url);
	
	// mime type is nil because the request hasn't actually been made yet ...
	//NSString *mimeType = [request valueForHTTPHeaderField:@"Content-Type"];
    //NSLog(@"Content-type: %@", mimeType);
	 
	if(fileExt == @"mid") //fileRequest
    {
		//[self downloadItem];
		//[NSThread detachNewThreadSelector:@selector(download:) toTarget:self withObject:@"/tmp/file.ipa"];
        return NO;
    }
    return YES;
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[super dealloc];
	RELEASE_SAFELY(webView);
	RELEASE_SAFELY(activityIndicator);
	[networkQueue cancelAllOperations];
	RELEASE_SAFELY(connection); 
	RELEASE_SAFELY(urlTextField); 
	RELEASE_SAFELY(progressView);
}




@end

