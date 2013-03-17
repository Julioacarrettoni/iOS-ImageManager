//
//  ImageDownloader.h
//  
//  You are barking at the wrong tree! you shouldn't mess around
//  with this object, if you want to asynchronously download
//  and cache images go read the header of 'AsyncImageVIew' or
//  'ImageManager', thats where the magic is.
//

#import <Foundation/Foundation.h>

@class ImageDownloader;

@protocol ImageDownloaderDelegate <NSObject>
- (void) imageDownloader:(ImageDownloader*)imageDownloaded foundCacheImage:(UIImage*) cachedImage;
- (void) imageDownloader:(ImageDownloader*)imageDownloaded finishedToDownloadImageData:(NSData*)imageData;
- (void) imageDownloaderFailedToDownloadImage:(ImageDownloader*) imageDownloaded;
@end

@interface ImageDownloader : NSObject
{	
    NSMutableArray* delegates;
	NSURLConnection* theConnection;
	NSMutableData* downloadedData;
}

@property (nonatomic, retain) NSURL *url;

+ (ImageDownloader *)requestImageFromURL:(NSURL *)imageURL;
+ (ImageDownloader *)requestImageFromURL:(NSURL *)imageURL force:(BOOL)force;
- (void)requestImageFromURL:(NSURL *)imageURL force:(BOOL)force;

- (void) cancel;

@property (nonatomic, retain) NSMutableArray* delegates;

@end
