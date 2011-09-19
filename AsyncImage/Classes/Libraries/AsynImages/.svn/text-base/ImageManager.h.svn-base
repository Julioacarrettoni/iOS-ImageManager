//
//  ImageManager.h
//
//  This is object that handle the image cache and image download
//  queue to download and show an image you need an object that
//  conforms to 'ImageManagerDelegate' protocol, such as AsyncImageView
//  and from whiting, call requestImageFromUrl:forObj:forceReDownload:
//


#pragma mark - CONFIGURATION
//
#define LAZY_REQUEST NO


#import <Foundation/Foundation.h>
#import "ImageDownloader.h"

#pragma mark - ImageManagerDelegateProtocol -

@class ImageManager;
@class ImageDownloader;
@protocol ImageManagerDelegate <NSObject>

@required
@property (nonatomic, retain) ImageDownloader* imageDownloader;

//When an image is found on RAM, or on DISK, or succesfully downloaded, you get it in this method
- (void) imageDownloaded:(UIImage*) image fromURL:(NSString*)imageURL;

//When there is an error trying to download an image you get noticed in this method
- (void) imageFailedToDownloadFromURL:(NSString*)imageURL;

@optional
/* NOT FOR THE TIME BEING
 
//The following methods are just in case you need to implement special behaviour in your program
- (void) imageNotOnRAM:(NSString*) imageURL;
- (void) imageNotOnDisk:(NSString*) imageURL;

- (BOOL) shouldDownloadImageFromURL:(NSString*)imageURL;
- (BOOL) shouldCacheIntoRAMImageFromURL:(NSString*) imageURL;
- (BOOL) shouldCacheIntoDiskImageFromURL:(NSString*) imageURL;
*/
@end

#pragma mark - ImageManager class -
@interface ImageManager : NSObject <ImageDownloaderDelegate>
{
	//The pool of running requestsss
	NSMutableDictionary* imageDownloaders;
	
	//For the RAM cache
	NSMutableDictionary* imagesOnRAM;
	
	//For managing files on the disk:
	NSFileManager *fileManager;
	NSArray *paths;
	NSString *documentsDirectory;
}
#pragma mark static methods
+ (ImageManager*) sharedInstance;
+ (void) freeRamCache;
+ (void) eraseHardCache;
- (UIImage*) getImageFromFile:(NSURL*) imageURL;

//To get an image from the MAIN BUNDLE
+ (UIImage *)imageNamed:(NSString *)_imageName;

#pragma mark request Image from URL
- (void) requestImageFromUrl:(NSString*)url forObj:(id <ImageManagerDelegate>)delegate forceReDownload:(BOOL)force;

@end
