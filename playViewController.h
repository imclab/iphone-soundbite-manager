//
//  playViewController.h
//
//  Created by Aaron Leese on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
 

@interface levelIndicator : UIView
{
	NSString *name;
	
}
 
- (void)drawRect:(CGRect)rect;

- (id)init;

- (id)initWithFrame:(CGRect)frame;
- (void)dealloc;
	
@end


@interface playViewController : UIViewController <UITextFieldDelegate>
{
	
	IBOutlet UIButton* playButton;
	IBOutlet UIButton* stopButton; 
	IBOutlet UIButton *playAnswerButton;
	
	IBOutlet UIButton* recButton; 
	IBOutlet UISlider* volumeSlider;	
	IBOutlet UILabel* answerLabel;	
	IBOutlet UITextField* questionName;
	
	IBOutlet UITextView *comments;
	
	UIActivityIndicatorView* activityIndicator;
	UITabBarController* tabBar;
	NSMutableArray *arrayNo;
	
	IBOutlet levelIndicator *myLevelIndicator;
	
	NSTimer *timer;
}

- (IBAction)buttonPressed:(id)sender;
- (IBAction)sliderMoved:(id)sender;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (void) timerCallback;

@property (nonatomic, retain) UIButton *recButton; 
@property (nonatomic, retain) UIButton *playButton; 
@property (nonatomic, retain) UIButton *playAnswerButton; 
@property (nonatomic, retain) UIButton *stopButton; 
@property (nonatomic, retain) UISlider *volumeSlider; 
@property (nonatomic, retain) UILabel *answerLabel; 
@property (nonatomic, retain) UITextField *questionName; 
@property (nonatomic, retain) UIPickerView *instrumentSelector; 
@property (nonatomic, retain) UITextView *comments; 



@end
