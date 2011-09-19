//
//  ImageCell.m
//  AsyncImage
//
//  Created by Julio Andrés Carrettoni on 9/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageCell.h"

@implementation ImageCell
@synthesize asyncImageView;

- (void)dealloc {
    [asyncImageView release];
    [super dealloc];
}
@end
