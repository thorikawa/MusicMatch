//
//  BumpFourAppDelegate.h
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

#import <UIKit/UIKit.h>

@class BumpFourViewController;

@interface BumpFourAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    BumpFourViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet BumpFourViewController *viewController;

@end

