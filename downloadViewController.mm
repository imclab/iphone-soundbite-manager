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


// View Methods ...
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

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self updateButtonStati];
	self.activityIndicator.center = CGPointMake(self.view.frame.size.width/2.0, self.view.frame.size.height/2.0);
}


// Webview Methods ....
- (BOOL) webView:(UIWebView *) webView shouldStartLoadWithRequest:(NSURLRequest *) request navigationType:(UIWebViewNavigationType) navigationType {
	if (connection) [connection cancel];
	RELEASE_SAFELY(connection);
	 
	self.urlTextField.text = [[request URL] absoluteString];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	NSLog(@"shouldStartLoad: %@", [[request URL] path]);
	
	NSString* fileRequest = [[request URL] path];
	NSString* fileExt = [fileRequest pathExtension];
	NSLog(@"file ext: %@", fileExt);
	
	NSURL* url = [request URL];
    NSLog(@"URL: %@", url);
	
	 
	if(fileExt == @"mid") //fileRequest
    {
		//[self downloadItem];
		//[NSThread detachNewThreadSelector:@selector(download:) toTarget:self withObject:@"/tmp/file.ipa"];
        return NO;
    }
    return YES;
	
}

-(IBAction)done:(UIBarButtonItem*)btn {
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)back:(UIBarButtonItem*)btn {
	[webView goBack];
}

-(IBAction)forward:(UIBarButtonItem*)forward {
	[webView goForward];
}


- (void)loadURL:(NSString*)url {
	self.urlTextField.text = url;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
	[self.activityIndicator startAnimating];
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
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

-(IBAction)download:(UIBarButtonItem*)download {
	
	// this was moved to the download manager ... which exists on the app delegate ....
	//[self downloadItem];
}

-(void)setProgress:(float)progress {
	self.progressView.progress = progress;
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self.activityIndicator stopAnimating];
	[self updateButtonStati];
}

// Action Sheet ....
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
//	[networkQueue cancelAllOperations];
	RELEASE_SAFELY(connection); 
	RELEASE_SAFELY(urlTextField); 
	RELEASE_SAFELY(progressView);
}




@end

