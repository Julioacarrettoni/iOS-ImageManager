//
//  AsyncImageView.m
//

#import "AsyncImageView.h"
#import "ImageManager.h"

@implementation AsyncImageView

@synthesize imageURL;
@synthesize loadingView;
@synthesize asyncImageDownloadDelegate;
@synthesize imageDownloader;

- (void)dealloc
{
	[imageURL release];
	imageURL = nil;
	
	self.loadingView = nil;
    self.asyncImageDownloadDelegate= nil;
    [super dealloc];
}

//Download an image from a given URL or show it  if already downloaded
- (void)loadImageFromURL:(NSString*)url
{
	[self loadImageFromURL:url forceRedownload:NO];	
}

//Download an image from a given URL. if force is set to YES, it will ignore any already downloaded image
- (void)loadImageFromURL:(NSString*)url forceRedownload:(BOOL) force
{
	[imageURL release];
	imageURL = [url retain];
	
	self.loadingView.hidden = NO;
	[[ImageManager sharedInstance] requestImageFromUrl:url forObj:self forceReDownload:force];
}

#pragma mark - ImageManagerDelegate
//When an image is found on RAM, or on DISK, or succesfully downloaded, you get it in this method
- (void) imageDownloaded:(UIImage*) image fromURL:(NSString*)imageURL
{
	self.loadingView.hidden = YES;
	self.image = image;
	
	if ([self.asyncImageDownloadDelegate respondsToSelector:@selector(asyncImageFinishedToDownloadImage:)])
    {
		[self.asyncImageDownloadDelegate asyncImageFinishedToDownloadImage:self];
    }
}

//When there is an error trying to download an image you get noticed in this method
- (void) imageFailedToDownloadFromURL:(NSString*)imageURL
{
	self.loadingView.hidden = YES;
	
	if ([self.asyncImageDownloadDelegate respondsToSelector:@selector(asyncImageFailedToDownloadImageFor:)])
    {
		[self.asyncImageDownloadDelegate asyncImageFailedToDownloadImageFor:self];
    }
}


@end
