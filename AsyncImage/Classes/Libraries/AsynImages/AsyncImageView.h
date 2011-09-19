//
//  AsyncImageView.h
//
//  This is just an example of an object that uses ImageManager to
//  Download and render a remote image and uses a cache to improve
//  performance. Also this object gives the ability to the view containing
//  it to be aware of the changes of states.
//  feel free to edit this object or to use it as a guide to create other similar
//  but this one should work for most of the common cases where you need to show
//  asynchronic images
//
//  HOW TO USE IT?
//  
//  Create an AsyncImageView programatically or in a 'XIB' change the class of a 
//  UIImageView to AsyncImageView (from there also you can set the delegate and 
//  loadingScreen as it were a UITableView)
//  Then from code just call 'loadImageFromURL:' and the object will show the image
//  If you requires further control (such as change the layout after the image is
//  downloaded, imeplement the AsyncImageViewDelegate
// 
//

#import <UIKit/UIKit.h>
#import "ImageDownloader.h"
#import "ImageManager.h"

#pragma mark - AsyncImageViewDelegate
@class AsyncImageView;
//In case you want to perform extra actions once an image is downloaded (or fails to)
@protocol AsyncImageViewDelegate <NSObject>
@optional
//The image for the given URL was found and its loaded into "image" of the current AsyncImage object
//This is useful in case you need to do some layout work after the download
- (void) asyncImageFinishedToDownloadImage:(AsyncImageView*) asyncImage;

//This method will tell you that the download failed, this is useful in cae you would like
//To show a special "not found" image like in browsers
- (void) asyncImageFailedToDownloadImageFor:(AsyncImageView*) asyncImage;
@end

#pragma mark - AsyncImageView

@interface AsyncImageView : UIImageView <ImageManagerDelegate>
{
}

#pragma mark properties
//This view will be shown while the app download the image
//and will be removed once it finish downloading
@property (nonatomic, retain) IBOutlet UIView *loadingView;

//Once the image is downloaded(or fails to) this object will get notified about it
@property (nonatomic, retain) IBOutlet id <AsyncImageViewDelegate> asyncImageDownloadDelegate;

//The url the image is trying (or is currently) showing
@property (nonatomic, readonly) NSString* imageURL;

#pragma mark Load image methods
//Download an image from a given URL or show it if already downloaded
- (void)loadImageFromURL:(NSString*)url;

//Download an image from a given URL. if force is set to YES, it will ignore any already downloaded image
- (void)loadImageFromURL:(NSString*)url forceRedownload:(BOOL) force;

@end
