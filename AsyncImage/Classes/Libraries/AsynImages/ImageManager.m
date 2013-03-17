//
//  ImageManager.m
//  FDV Solutions
//
//  Created by Julio Carrettoni on 26/05/10.
//  Copyright 2010 FDV Solutions. All rights reserved.
//

#import "ImageManager.h"
#import "ImageDownloader.h"
#import "asyncimageview.h"

#include <sys/xattr.h>
#define IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define DIRECTORY_FOR_STORING_DATA_DUE_TO_ICLOUD ((IOS_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0.1"))? documentsDirectory : cacheDirectory)

#pragma mark - Constants
static NSString* imageCacheFolder = @"/imageCache/";

#pragma mark - Private Methods
@interface ImageManager(ImageManager_private_methods)

- (void) freeRamCache;
- (void) eraseHardCache;

- (void) checkImagesOnRAMForImage:(NSString*) imageURL forObject:(id <ImageManagerDelegate>)delegate;
- (void) downloadImageFrom:(NSURL*) imageURL forObject:(id <ImageManagerDelegate>)delegate;

- (void) cancelDownloadRequestForObject:(id <ImageManagerDelegate>)delegate;

- (UIImage*) getImageFromFile:(NSURL*) imageURL;
- (void) loadImage:(UIImage*)image intoRamForThisURL:(NSString*)imageURL;
- (void) saveImageData:(NSData*)data forThisURL:(NSURL*)imageURL;

@end

static ImageManager* instance = nil;

@implementation ImageManager

#pragma mark - FOr iOS 5.0.1 and beyong!
+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)path;
{
    const char* filePath = [path fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

#pragma mark - static methods
+ (ImageManager*) sharedInstance
{
    @synchronized(instance)
    {
        if (!instance)
        {
            instance = [ImageManager new];
        }
        return instance;
    }
}

+ (void) freeRamCache
{
	[instance freeRamCache];
}

+ (void) eraseHardCache
{
	[instance eraseHardCache];
}

- (void) applicationDidEnterBackground:(id) obj
{
	@synchronized(self) {
		[self freeRamCache];
	}    
}

- (void) receivedMemoryNotification:(id) obj
{
	@synchronized(self) {
		[self freeHalfRamCache];
	}
}

#pragma mark - Overrided NSObject methods

- (id)init
{
    self = [super init];
    if (self)
	{
		//Here we will store the the images on RAM
		imagesOnRAM = [NSMutableDictionary new];
        imagesAccessedHistory = [NSMutableArray new];
		
		//We create what we need to acces the files on the disk ONCE to improve access later
		fileManager = [[NSFileManager defaultManager] retain];
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentsDirectory = [[[paths objectAtIndex:0] stringByAppendingString:imageCacheFolder] retain];
        
        paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		cacheDirectory =  [[[paths objectAtIndex:0] stringByAppendingString:imageCacheFolder] retain];
        
		//In case the folder doesn't exist, we create it now and we only make the check once
		if (![fileManager fileExistsAtPath:documentsDirectory])
		{
			[fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            [ImageManager addSkipBackupAttributeToItemAtPath:documentsDirectory];
		}
        
        //In case the folder doesn't exist, we create it now and we only make the check once
		if (![fileManager fileExistsAtPath:cacheDirectory])
		{
			[fileManager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            [ImageManager addSkipBackupAttributeToItemAtPath:cacheDirectory];
		}
		
        //we create the necesary structures to manage the downladers
        imageDownloaders = [NSMutableDictionary new];
        
		//We want to be noticed in cases of low memory to free the RAM cache
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMemoryNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        
        [self performSelectorInBackground:@selector(freeOldImagesInTheDiskCache) withObject:nil];
	}
    return self;
}

- (void)removeDelegate:(id<ImageDownloaderDelegate>)delegate {
    @synchronized(imageDownloaders)
    {
        for (NSString *key in imageDownloaders) {
            ImageDownloader *downloader = [imageDownloaders objectForKey:key];
            [downloader.delegates removeObject:delegate];
        }
    }
}

#pragma mark request Image from URL
- (void) requestImageFromUrl:(NSString*)url forObj:(id <ImageManagerDelegate>)delegate forceReDownload:(BOOL)force
{
	//getting and image has 3 steps:
	// 1) We check if the image is on the RAM
	// 2) if (1) fails, we check if the image is on the DISK
	// 3) if (2) fails, we try to download it from the Internet
	//
	// but if force is set to true, then we just skip ahead to point 3
	
	if (!delegate || (!url || url.length == 0))
		return; //there is no point to continue if we have nothing to work with
	
    //this object could already be downloading another image so we need to cancel that request
    [self cancelDownloadRequestForObject:delegate];
    
	if (!force)
	{
		[self checkImagesOnRAMForImage:url forObject:delegate];
	}
	else
	{
		[self downloadImageFrom:[NSURL URLWithString:url] forObject:delegate force:force];
	}
	
}

- (void) checkImagesOnRAMForImage:(NSString*) imageURL forObject:(id <ImageManagerDelegate>)delegate
{
	//First we check if we have the image already loaded on RAM
	UIImage* image = [self getImageFromRAM:imageURL];
    
	if (image)
	{
		//we do! so we tell the object we are done!
		[delegate imageDownloaded:image fromURL:imageURL];
	}
	else
	{
		//we need to check if the image exist on disk
		//[self scheduleACheckImagesOnDISKForImage:imageURL forObject:delegate];
        [self downloadImageFrom:[NSURL URLWithString:imageURL] forObject:delegate];
	}
}

- (void) downloadImageFrom:(NSURL*) url forObject:(id <ImageManagerDelegate>)delegate {
    [self downloadImageFrom:url forObject:delegate force:NO];
}

- (void) downloadImageFrom:(NSURL*) url forObject:(id <ImageManagerDelegate>)delegate force:(BOOL)force
{
    @synchronized(imageDownloaders)
    {
        //first we check if there is a existing downloader for that file
        ImageDownloader* iDownloader = [imageDownloaders objectForKey:url.absoluteString];
        
        if (!iDownloader)
        {
            iDownloader = [ImageDownloader requestImageFromURL:url force:force];
            [imageDownloaders setValue:iDownloader forKey:url.absoluteString];
        }
        
        [delegate setImageDownloader:iDownloader];
        [iDownloader.delegates addObject:delegate];
    }
}

- (void) cancelDownloadRequestForObject:(id <ImageManagerDelegate>)delegate
{
    @synchronized(imageDownloaders)
    {
        ImageDownloader* iDownloader = [delegate imageDownloader];
        if (iDownloader)
        {
            //there is a downloader associated to this object
            NSMutableArray* delegates = iDownloader.delegates;
            [delegates removeObject:delegate];
            
            //If no-one else is waiting for this image we cancel its download
            if (delegates.count == 0 && LAZY_REQUEST)
            {
                [iDownloader cancel];
                [imageDownloaders removeObjectForKey:iDownloader.url.absoluteString];
            }
        }
    }
}

#pragma mark - ImageDownloaderDelegate

- (void) imageDownloader:(ImageDownloader*)imageDownloader foundCacheImage:(UIImage*) image
{
    NSArray* delegates = imageDownloader.delegates;
    for (NSObject* obj in delegates)
    {
        [obj performSelector:@selector(imageDownloaded:fromURL:) withObject:image withObject:imageDownloader.url.absoluteString];
    }
    [self loadImage:image intoRamForThisURL:imageDownloader.url.absoluteString];
    
    @synchronized(imageDownloaders)
    {
        [imageDownloaders removeObjectForKey:imageDownloader.url.absoluteString];
    }
}

- (void) imageDownloader:(ImageDownloader*)imageDownloader finishedToDownloadImageData:(NSData*)imageData
{
    NSArray* delegates = imageDownloader.delegates;
        
    UIImage* image = [UIImage imageWithData:imageData];
    if (image)
    {
        for (NSObject* obj in delegates)
        {
            [obj performSelector:@selector(imageDownloaded:fromURL:) withObject:image withObject:imageDownloader.url.absoluteString];
        }
        [self loadImage:image intoRamForThisURL:imageDownloader.url.absoluteString];
        [self saveImageData:imageData forThisURL:imageDownloader.url];
    }
    else
    {
        [delegates makeObjectsPerformSelector:@selector(imageFailedToDownloadFromURL:) withObject:imageDownloader.url.absoluteString];
    }
    
    @synchronized(imageDownloaders)
    {
        [imageDownloaders removeObjectForKey:imageDownloader.url.absoluteString];
    }
}

- (void) imageDownloaderFailedToDownloadImage:(ImageDownloader*) imageDownloader
{
    //The download failed, we must tell all the objects waiting for this image
    NSArray* delegates = imageDownloader.delegates;
    [delegates makeObjectsPerformSelector:@selector(imageFailedToDownloadFromURL:) withObject:imageDownloader.url.absoluteString];
    
    @synchronized(imageDownloaders)
    {
        [imageDownloaders removeObjectForKey:imageDownloader.url.absoluteString];
    }
}


#pragma mark - cache management methods
- (void) eraseHardCache
{
    @synchronized (fileManager)
    {
        [fileManager removeItemAtPath:documentsDirectory error:nil];
        [fileManager removeItemAtPath:cacheDirectory error:nil];
        
        [fileManager createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        
        [ImageManager addSkipBackupAttributeToItemAtPath:documentsDirectory];
        [ImageManager addSkipBackupAttributeToItemAtPath:cacheDirectory];
    }
}

//In case we are low on memory we erase the RAM cache.
- (void) freeRamCache
{
    @synchronized(imagesOnRAM)
    {
        [imagesOnRAM removeAllObjects];
    }
}

- (void) freeHalfRamCache
{
    @synchronized(imagesAccessedHistory)
    {
        @synchronized(imagesOnRAM)
        {
            NSUInteger half = imagesOnRAM.count/2;
            for (int i = (imagesOnRAM.count-1); i > half; i--)
            {
                NSString* key = [imagesAccessedHistory objectAtIndex:i];
                [imagesOnRAM removeObjectForKey:key];
                [imagesAccessedHistory removeObject:key];
            }
        }
    }
}

- (void) freeOldImagesInTheDiskCache
{
    @synchronized (fileManager)
    {
        NSString* folderPath = DIRECTORY_FOR_STORING_DATA_DUE_TO_ICLOUD;
        NSArray* files = [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
        NSDate* currentDate = [NSDate date];
        
        for (NSString* fileName in files)
        {
            NSString* filePath = [folderPath stringByAppendingPathComponent:fileName];
            NSDictionary* attributes = [fileManager attributesOfItemAtPath:filePath error:nil];
            if (attributes)
            {
                NSDate* fileModificationDate = [attributes objectForKey:NSFileModificationDate];
                if ([currentDate timeIntervalSinceDate:fileModificationDate] > 60*60*24*7)//Over one week
                {
                    [fileManager removeItemAtPath:filePath error:nil];
                }
            }
        }
    }
}

- (UIImage*) getImageFromRAM:(NSString*) imageURL
{
    if (imageURL)
    {
        @synchronized(imagesOnRAM)
        {
            UIImage* image = [imagesOnRAM objectForKey:imageURL];
            if (image)
            {
                @synchronized(imagesAccessedHistory)
                {
                    [imagesAccessedHistory removeObject:imageURL];
                    [imagesAccessedHistory insertObject:imageURL atIndex:0];
                }
            }
            return image;
        }
    }
    return nil;
}

- (void) storeImageOnRam:(UIImage*)image withKey:(NSString*) key
{
    if (image && key)
    {
        @synchronized(imagesOnRAM)
        {
            [imagesOnRAM setObject:image forKey:key];
            
            @synchronized(imagesAccessedHistory)
            {
                [imagesAccessedHistory removeObject:key];
                [imagesAccessedHistory insertObject:key atIndex:0];
            }
        }
    }
}

#pragma mark - images on disk management
//Given a URL this method generates a name for the image
- (NSString*) getImageFileNameFrom:(NSURL*) url
{
	//return [[[url path] componentsSeparatedByString:@"/"] lastObject];
    return [NSString stringWithFormat:@"%u", [[url absoluteString] hash]];
}

//Given a image name, this method looks for the file and return a UIImage, or nil if the image dosn't exist
- (UIImage*) getImageFromFile:(NSURL*) imageURL {
    
    UIImage* image = [self getImageFromRAM:imageURL.absoluteString];
    if (image)
        return image;
    
	NSString *path = [DIRECTORY_FOR_STORING_DATA_DUE_TO_ICLOUD stringByAppendingPathComponent:[self getImageFileNameFrom:imageURL]];
    @synchronized (fileManager)
    {
        if (![fileManager fileExistsAtPath:path])
            return nil;
        
        //We update the file Modification date
        image = [UIImage imageWithData:[fileManager contentsAtPath:path]];
        
        //We change the modification date as now and then images over onw week old are DELETED!
        [fileManager setAttributes:@{NSFileModificationDate:[NSDate date]} ofItemAtPath:path error:nil];
        return image;
    }
}

//This just loads the image into the RAM cache
- (void) loadImage:(UIImage*)image intoRamForThisURL:(NSString*)imageURL
{
    [self storeImageOnRam:image withKey:imageURL];
}

//This saves the image into the fyle system cache
- (void) saveImageData:(NSData*)data forThisURL:(NSURL*)imageURL
{
	if (data != nil && imageURL != nil)
	{
		//Now we save it to the fyle system
		NSString* filePath = [DIRECTORY_FOR_STORING_DATA_DUE_TO_ICLOUD stringByAppendingString:[self getImageFileNameFrom:imageURL]];
		@synchronized (fileManager)
        {
            [fileManager createFileAtPath:filePath contents:data attributes:nil];
            [ImageManager addSkipBackupAttributeToItemAtPath:filePath];
            [fileManager setAttributes:@{NSFileModificationDate:[NSDate date]} ofItemAtPath:filePath error:nil];
        }
	}
}

- (UIImage *)imageNamed:(NSString *)_imageName {

        UIImage* image = [self getImageFromRAM:_imageName];
        
        if (!image)
        {
            NSRange range = [_imageName rangeOfString:@"." options:NSBackwardsSearch];
            NSArray* nameArray = [NSArray arrayWithObjects:[_imageName substringToIndex:range.location], [_imageName substringFromIndex:range.location+range.length], nil];
            if ([nameArray count] > 1)
            {
                NSString* imagePath = [[NSBundle mainBundle] pathForResource:[nameArray objectAtIndex:0] ofType:[nameArray lastObject]];
                image = [UIImage imageWithContentsOfFile:imagePath];
                [self storeImageOnRam:image withKey:_imageName];
            }
        }
        return image;
}

+ (UIImage *)imageNamed:(NSString *)_imageName {
    return [[ImageManager sharedInstance] imageNamed:_imageName];
}

#pragma mark - To avoid someone to play around with this object
-(id)retain {
    return self;
}

-(unsigned)retainCount {
    return UINT_MAX;
}

-(oneway void)release {
}

-(id)autorelease {
    return self;    
}

@end
