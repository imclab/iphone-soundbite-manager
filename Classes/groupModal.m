//
//  groupModal.m
//  audioPlayer
//
//  Created by Aaron Leese on 8/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "groupModal.h"

#import "audioPlayerAppDelegate.h"

@implementation groupModal

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	textField.returnKeyType = UIReturnKeyDone;
	textField.delegate = self;
	
	// select the textField
	[textField becomeFirstResponder];
	
}

// this helps dismiss the keyboard then the "done" button is clicked

- (BOOL)textFieldShouldReturn:(UITextField*) myTextField {
	[myTextField resignFirstResponder];
	
	
	// get the app delegate, and create the new group .....
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate createQuestionGroup:[textField text]];	
	
	
	[self.parentViewController dismissModalViewControllerAnimated:YES];
	
	return YES;
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
}


@end
