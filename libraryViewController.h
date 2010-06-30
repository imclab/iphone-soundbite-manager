//
//  libraryViewController.h
//
//  Created by Aaron Leese on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h> 
 

@interface libraryViewController : UITableViewController {
	
	UIActivityIndicatorView *activityIndicator;
	IBOutlet UITabBarController* tabBar;
	 
} 

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator; 
 
- (void) refreshLibraryView;

@end
