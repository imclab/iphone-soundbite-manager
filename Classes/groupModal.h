//
//  groupModal.h
//  audioPlayer
//
//  Created by Aaron Leese on 8/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface groupModal : UIViewController {

	IBOutlet UITextField *textField;
	
}

@property (nonatomic, retain) UITextField *textField;

- (BOOL)textFieldShouldReturn : (UITextField*) myTextField;

@end
