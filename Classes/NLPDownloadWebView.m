    //
//  NLPDownloadWebView.m
//  iPad
//
//  Created on 10-05-06. 
//

#import "NLPDownloadWebView.h"
  
void LOG ()
{
	
}

void RELEASE_SAFELY  ()
{
	
}

void MUSICFILE_PATH ()
{
	
}


//#import "NLPGlobal.h"
//#import "NLPAlert.h"
//#import "UIToolbar+NLP.h"
//#import "NLPScorePDF.h"

#define kTagForDownloadButton 99
#define kDefaultDownloadURL @"http://www.flyloops.com/"

@interface NLPDownloadWebView (Private)
-(void)downloadItem;
@end


@implementation NLPDownloadWebView


@synthesize webView, activityIndicator;
@synthesize connection, urlTextField, toolBar;
@synthesize hudView, progressView;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

#pragma mark View Manipulations

- (void)showHUD
{
	[self.hudView setHidden:NO];
}

- (void)hideHUD
{
	[self.hudView setHidden:YES];
}

#pragma mark Actions

-(IBAction)cancelDownload:(UIBarButtonItem*)btn
{
	[networkQueue cancelAllOperations];
	[self hideHUD];
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
	//if(progress >= kDownloadDone) {
	//	[NLPAlert alert:@"Done" withMessage:@"Download is complete and the score has been added to your music library."];
	//	[self hideHUD];
	//}
}


#pragma mark Http REQUEST delegate

/**
Content-Disposition: attachment; filename=fname.ext
*/
- (void)downloadFinished:(ASIHTTPRequest *)request {
	if (request.responseStatusCode != 200) {
		LOG(@"Request Headers: %@", [request requestHeaders]);
		LOG(@"Failure downloading content");
		LOG(@"Server Response: %d, %@, %@", request.responseStatusCode, request.responseHeaders, [request responseString]);
		return;
	}
	
	LOG(@"downloadFinished: %@", [request downloadDestinationPath]);
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
	} else {
		//TODO: do something sane with non .zip content
		LOG(@"Content must end with .pdf extention, ignoring");
	//	[NLPAlert alert:@"Error" withMessage:@"Only PDF files can be added to the music library"];
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSError *error = [request error];
	LOG(@"ERROR: NSError query result: %@", error);
	LOG(@"Server Response: %d, %@", request.responseStatusCode, request.responseHeaders);
	//[NLPAlert alert:@"DownloadError" withMessage:[NSString stringWithFormat:@"%@", error]];
}



-(void)downloadItem
{
	if (networkQueue == nil) {
		networkQueue = [ASINetworkQueue queue];
		[networkQueue retain];
		//[networkQueue go];
	}

	//Create a unique name for the file to avoid conflicts
	NSString *tempDirectory = NSTemporaryDirectory();
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	NSString *fileUID = [(NSString *)string autorelease];
	//@TODO set correct file extention
	NSString *path = [tempDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.pdf", fileUID]];
	LOG(@"*** starting download to path: %@ FROM %@", path, [currentURL path]);
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
	[self showHUD];
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	[self hideHUD];
	self.urlTextField.delegate = self;
	[self.activityIndicator stopAnimating];
	self.webView.delegate = self;
	self.webView.scalesPageToFit = YES;
	
	[self loadURL:kDefaultDownloadURL];
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
	//LOG(@"didReceiveResponse: %@", [response MIMEType]);
	RELEASE_SAFELY(currentURL);
	if ([[response MIMEType] isEqualToString:@"application/pdf"]) {
		//[NLPAlert alert:@"PDF Detected" withMessage:@"You can add this score to your music library by clicking the download button in the top right corner."];
		currentURL = [[response URL] retain];
		UIBarButtonItem *btn = [self.toolBar buttonWithTag:kTagForDownloadButton];
		btn.enabled = YES;
		btn.style = UIBarButtonItemStyleDone;
	} else {
		UIBarButtonItem *btn = [self.toolBar buttonWithTag:kTagForDownloadButton];
		btn.enabled = NO;
		btn.style = UIBarButtonItemStyleBordered;
	}
	[conn cancel];
	// application/pdf
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
	LOG(@"shouldStartLoad: %@", [[request URL] path]);
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
	RELEASE_SAFELY(toolBar);
	RELEASE_SAFELY(urlTextField);
	RELEASE_SAFELY(hudView);
	RELEASE_SAFELY(progressView);
}


@end