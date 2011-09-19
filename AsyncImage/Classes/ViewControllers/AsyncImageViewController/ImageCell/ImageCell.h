//
//  ImageCell.h
//  AsyncImage
//
//  Created by Julio Andrés Carrettoni on 9/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncImageView.h"

@interface ImageCell : UITableViewCell {
    AsyncImageView *asyncImageView;
}

@property (nonatomic, retain) IBOutlet AsyncImageView *asyncImageView;

@end
