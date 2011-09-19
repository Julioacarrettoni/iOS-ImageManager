//
//  FullScreenImageViewController.h
//  AsyncImage
//
//  Created by Julio Andrés Carrettoni on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AsyncImageView;

@interface FullScreenImageViewController : UIViewController
{
    IBOutlet AsyncImageView *asyncImageView;
    NSString* imageURL;
}
- (id) initWithImageURL:(NSString*) _imageURL;
- (IBAction)onDoneButtonTUI:(id)sender;

@end
