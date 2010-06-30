//
//  NLPDownloadWebView.h
//  iPad
//
//  Created on 10-05-06.
//  Copyright 2010 Noteloop Systems Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@interface NLPDownloadWebView : UIViewController <UIWebViewDelegate, UITextFieldDelegate> {
	UIWebView *webView;
	UIToolbar *toolBar;
	UITextField *urlTextField;
	NSURL *currentURL;
	UIActivityIndicatorView *activityIndicator;
	NSURLConnection *connection;
	ASIHTTPRequest *downloadRequest;
	ASINetworkQueue *networkQueue;
	UIView *hudView;
	UIProgressView *progressView;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolBar;
@property (nonatomic, retain) IBOutlet UITextField *urlTextField;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) IBOutlet UIView *hudView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;

-(IBAction)done:(UIBarButtonItem*)btn;
-(IBAction)back:(UIBarButtonItem*)btn;
-(IBAction)forward:(UIBarButtonItem*)btn;
-(IBAction)download:(UIBarButtonItem*)btn;
-(IBAction)cancelDownload:(UIBarButtonItem*)btn;

@end