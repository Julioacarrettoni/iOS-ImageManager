//
//  AsyncImageViewController.h
//  AsyncImage
//
//  Created by Julio Andrés Carrettoni on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AsyncImageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate >{
    NSArray* imagesURL;
    IBOutlet UITableView *theTableView;
}

- (IBAction)onWipeRamButtonTUI:(id)sender;
- (IBAction)onWipeHDButtonTUI:(id)sender;

@end
