//
//  FullScreenImageViewController.m
//  AsyncImage
//
//  Created by Julio Andrés Carrettoni on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FullScreenImageViewController.h"
#import "AsyncImageView.h"

@implementation FullScreenImageViewController

#pragma mark - View lifecycle

- (id) initWithImageURL:(NSString*) _imageURL
{
    self = [self init];
    if (self) {
        imageURL = [_imageURL retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [asyncImageView loadImageFromURL:imageURL];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [asyncImageView release];
    asyncImageView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)onDoneButtonTUI:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)dealloc {
    [imageURL release];
    [asyncImageView release];
    [super dealloc];
}
@end
