//
//  BumpFourViewController.m
//  BumpFour
//
//  Created by Jake on 10/12/09.
//
//  Copyright 2010, Bump Technologies, Inc. All rights reserved.  Use of the 
//  software programs described herein is subject to applicable license agreements 
//  and nondisclosure agreements. Unless specifically otherwise agreed in
//  writing, all rights, title, and interest to this software and
//  documentation remain with Bump Technologies, Inc. Unless expressly
//  agreed in a signed license agreement, Bump Technologies makes no
//  representations about the suitability of this software for any purpose
//  and it is provided "as is" without express or implied warranty.
//  

#import "MainViewController.h"
#define END_OF_GAME_ALERT 101

@implementation MainViewController
@synthesize bumpConn, bumpToConnectButton;

- (void) showMessage:(NSString *)message{
	if(endOfGameAlert != nil){
		[endOfGameAlert release];
		endOfGameAlert = nil;
	}
	endOfGameAlert = [[UIAlertView alloc] initWithTitle:@"★結果★" message:message delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:nil, nil];
	endOfGameAlert.tag = END_OF_GAME_ALERT;
	[endOfGameAlert show];
}

-(IBAction) startBumpButtonPress{
    NSLog(@"startBump");
	self.bumpConn = [[[BumpConnector alloc] init] autorelease];	
	bumpConn.mainViewController = self;
	[bumpConn startBump];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (alertView.tag == END_OF_GAME_ALERT) {
		switch (buttonIndex) {
			case 0: //Quit Pressed
				NSLog(@"Quit Pressed");
				[bumpConn stopBump];
				break;
			case 1: //Play Again Pressed
				NSLog(@"Play Again Pressed");
				[bumpConn startGame];
				break;
			default:
				break;
		}
	} 

	if(endOfGameAlert != nil){
		[endOfGameAlert release];
		endOfGameAlert = nil;
	}
}
#pragma mark -

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.bumpConn = nil;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
//}

-(void)applicationWillTerminate:(UIApplication *)application{
	[bumpConn stopBump];
}


- (void)dealloc {
    [super dealloc];
}

@end
