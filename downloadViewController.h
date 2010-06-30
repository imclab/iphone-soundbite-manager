//
//  downloadViewController.h
//
//  Created by Aaron Leese on 5/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

#import "libraryViewController.h"

@interface downloadViewController : UIViewController <UIWebViewDelegate, UITextFieldDelegate>{

	IBOutlet UIWebView *webView; 
  
	IBOutlet UITextField *urlTextField;
	NSURL *currentURL;
	UIActivityIndicatorView *activityIndicator;
	NSURLConnection *connection;
	ASIHTTPRequest *downloadRequest;
	ASINetworkQueue *networkQueue; 
	UIProgressView *progressView;
	
	IBOutlet libraryViewController *libController;
	
}
 
//@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet UITextField *urlTextField;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSURLConnection *connection; 
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
 

-(BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
navigationType:(UIWebViewNavigationType)navigationType;

-(void)downloadItem;
-(void)triggerDownload:(NSURL*)newItem;

-(IBAction)done:(UIBarButtonItem*)btn;
-(IBAction)back:(UIBarButtonItem*)btn;
-(IBAction)forward:(UIBarButtonItem*)btn;
-(IBAction)download:(UIBarButtonItem*)btn;
-(IBAction)cancelDownload:(UIBarButtonItem*)btn;

	
@end