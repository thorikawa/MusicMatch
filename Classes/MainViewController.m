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
#import "SBJson.h"
#define END_OF_GAME_ALERT 101

@implementation MainViewController
@synthesize bumpConn, bumpToConnectButton;

- (void) showMessage:(NSString *)message favoriteArray:(NSArray*)favArray{
	if(endOfGameAlert != nil){
		[endOfGameAlert release];
		endOfGameAlert = nil;
	}
    //NSMutableArray* otherTitles = [[[NSMutableArray alloc] init] autorelease];
    //[otherTitles addObject:nil];
    
	endOfGameAlert = [[UIAlertView alloc] initWithTitle:@"★結果★" message:message delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:nil];
    for (int i=0; i<MIN(3, [favArray count]); i++) {
        NSDictionary* fav = [favArray objectAtIndex:i];
        NSString* msg = [NSString stringWithFormat:@"%@/%@", [fav objectForKey:@"songTitle"], [fav objectForKey:@"artistName"]];
        [endOfGameAlert addButtonWithTitle:msg];
    }

    if (mFavArray != nil) {
        [mFavArray release];
        mFavArray = nil;
    }
    mFavArray = [favArray retain];
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
        int index;
		switch (buttonIndex) {
			case 0: //Quit Pressed
				NSLog(@"Quit Pressed");
				[bumpConn stopBump];
                if(endOfGameAlert != nil){
                    [endOfGameAlert release];
                    endOfGameAlert = nil;
                }
				break;
			case 1: //Play Again Pressed
            case 2:
            case 3:
            {
                NSLog(@"Fav Press");
                index = buttonIndex - 1;
                NSDictionary* dic = [mFavArray objectAtIndex:index];
                NSString* urlString = [NSString stringWithFormat:@"http://itunes.apple.com/search?term=%@+%@&country=JP&media=music&entity=song", [dic objectForKey:@"songTitle"], [dic objectForKey:@"artistName"]];
                //NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                NSString *encoded = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
                NSLog(@"accessTo:[%@]", encoded);
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:encoded]];
                NSError* error;
                NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
                //if (error != nil) {
                //    NSLog(@"%@", [error debugDescription]);
                //}
                NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                NSLog(@"%@", json_string);
                NSDictionary* json = [json_string JSONValue];
                NSArray* results = [json objectForKey:@"results"];
                NSLog(@"get results");
                if ([results count] <= 0) {
                    break;
                }
                NSDictionary* one = [results objectAtIndex:0];
                if (one == nil) {
                    NSLog(@"###Not found!!###");
                    break;
                }
                NSString* previewUrl = [one objectForKey:@"previewUrl"];
                NSLog(@"preview:%@",previewUrl);
                MPMoviePlayerViewController *vc = [[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:previewUrl]] autorelease];
                [self presentMoviePlayerViewControllerAnimated:vc];
                //[self.view addSubview:vc.view];
                
                /*
                MPMoviePlayerController *player =
                [[MPMoviePlayerController alloc]
                 initWithContentURL:[NSURL fileURLWithPath:previewUrl]];
                //[player autorelease];
                [player play];
                 */
            }
				break;
			default:
				break;
		}
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
