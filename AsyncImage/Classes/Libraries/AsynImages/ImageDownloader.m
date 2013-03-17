//
//  ImageDownloader.m
//  iGarfield
//
//  Created by Julio Carrettoni on 11/07/10.
//  Copyright 2010 FDV Solutions. All rights reserved.
//
#import "ImageDownloader.h"
#import "ImageManager.h"

@interface ImageDownloader () <NSURLConnectionDataDelegate>

@end

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
    [downloadedData release];
    downloadedData = nil;
    
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

- (void)requestImageFromURL:(NSURL *)imageURL {
    [self requestImageFromURL:imageURL force:NO];
}

- (void)forceRequestImageFromURL:(NSURL *)imageURL {
    [self requestImageFromURL:imageURL force:YES];
}

- (void)requestImageFromURL:(NSURL *)imageURL force:(BOOL)force {
    UIImage* image = force? nil: [[ImageManager sharedInstance] getImageFromFile:imageURL];
    
    if (image) {
        [[ImageManager sharedInstance] imageDownloader:self foundCacheImage:image];
        return;
    }
    
	downloadedData = [NSMutableData new];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL
                                             cachePolicy:NSURLRequestReloadRevalidatingCacheData
                                         timeoutInterval:DEFAULT_TIMEOUT];
	theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

+ (ImageDownloader *)requestImageFromURL:(NSURL *)imageURL {
    return [self requestImageFromURL:imageURL force:NO];
}

+ (ImageDownloader *)requestImageFromURL:(NSURL *)imageURL force:(BOOL)force {
	ImageDownloader* imageDownloader = [ImageDownloader new];
    imageDownloader.url = imageURL;
    SEL selector = force? @selector(forceRequestImageFromURL:): @selector(requestImageFromURL:);
    [imageDownloader performSelector:selector withObject:imageURL afterDelay:0.1];
	return [imageDownloader autorelease];
}

- (void) cancel
{
	[theConnection cancel];
}

#pragma mark - NSURLConnectionDelegate

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response) {
        return [NSURLRequest requestWithURL:[request URL]
                                cachePolicy:NSURLRequestReloadRevalidatingCacheData
                            timeoutInterval:DEFAULT_TIMEOUT];
    }
    return request;
}

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
