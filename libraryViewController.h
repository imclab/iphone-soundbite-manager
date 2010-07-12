//
//  libraryViewController.h
//
//  Created by Aaron Leese on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h> 
 
#import "soundBite.h"

@interface libraryViewController : UITableViewController {
	
	UIActivityIndicatorView *activityIndicator;
	IBOutlet UITabBarController* tabBar;
	
	NSArray *tableDataSource; // current data ....
	NSString *CurrentGroup; 
	 } 


@property (nonatomic, retain) NSArray *tableDataSource;
@property (nonatomic, retain) NSString *CurrentTitle; 


@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator; 
 
- (void) refreshLibraryView;


@end



