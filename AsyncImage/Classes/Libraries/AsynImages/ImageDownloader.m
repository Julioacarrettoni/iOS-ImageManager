//
//  ImageDownloader.m
//  iGarfield
//
//  Created by Julio Carrettoni on 11/07/10.
//  Copyright 2010 FDV Solutions. All rights reserved.
//
#import "ImageDownloader.h"
#import "ImageManager.h"

@implementation ImageDownloader
@synthesize url;
@synthesize delegates;

#pragma mark - Overrided NSObject Methods
- (NSUInteger)hash
{
	return [url hash];
}

- (BOOL)isEqual:(id)anObject
{
	if ([anObject isKindOfClass:[ImageDownloader class]])
	{
		ImageDownloader* theObject = (ImageDownloader*) anObject;
		return [self.url isEqual:theObject.url];
	}
	return NO;
}

- (void) dealloc
{
	[theConnection release];
	theConnection = nil;
	
	[url release];
	url = nil;
	
    self.delegates = nil;
    
	[super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        delegates = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Request image from URL
- (void) requestImageFromURL:(NSURL*) imageURL
{
    UIImage* image = [[ImageManager sharedInstance] getImageFromFile:imageURL];
    
    if (image)
    {
        [[ImageManager sharedInstance] imageDownloader:self foundCacheImage:image];
        return;
    }
    
	downloadedData = [NSMutableData new];
	theConnection = [[NSURLConnection new] initWithRequest:[NSURLRequest requestWithURL:imageURL] delegate:self startImmediately:YES];
}

+ (ImageDownloader*) requestImageFromURL:(NSURL*) imageURL
{
	ImageDownloader* imageDownloader = [ImageDownloader new];
    imageDownloader.url = imageURL;
	//[imageDownloader requestImageFromURL:imageURL];
    [imageDownloader performSelector:@selector(requestImageFromURL:) withObject:imageURL afterDelay:0.1];
	return [imageDownloader autorelease];
}

- (void) cancel
{
	[theConnection cancel];
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[downloadedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[[ImageManager sharedInstance] imageDownloader:self finishedToDownloadImageData:downloadedData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[[ImageManager sharedInstance] imageDownloaderFailedToDownloadImage:self];
}
@end
