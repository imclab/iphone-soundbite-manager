//
//  libraryViewController.h
//
//  Created by Aaron Leese on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h> 
 
#import "soundBite.h"
#import "questionSet.h"

@interface libraryViewController : UITableViewController {
	 
	IBOutlet UITabBarController* tabBar;
	NSArray *tableDataSource; // current data ....
	
	IBOutlet QuestionSetView *questionSetview;
		
} 

-(IBAction) newQuestionGroup:(id)sender;

- (void) refreshLibraryView;


@end



