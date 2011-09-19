//
//  AsyncImageAppDelegate.h
//  AsyncImage
//
//  Created by Julio Andrés Carrettoni on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AsyncImageViewController;

@interface AsyncImageAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet AsyncImageViewController *viewController;

@end
