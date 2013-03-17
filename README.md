---
**Note**
---
This project is provided AS-IF, just download it, and run it to see how it works


---

What is it?
---

Basically what it does is provide a mechanism to asynchronously show images (images from a URL for example).

It is easy to use as it is intended to replace UIImageViews with a more "advanced" version and it can be EASYLY done on the **Interface Builder** or programmatically. Also this UIImageView replacement automatically show/hide a associated view (for the loading UIActivityIndicator or anything else)

The magic is that it has it owns "smart" cache so it you show the same image more than once it doesn't get re-downloaded. Actually is has a 2 level cache, images are stored on RAM and on the DISK.

 - In case of a memory warning (low available RAM) the imageManager will release **HALF** of the images on RAM (the least used ones).
 - When the App goes on background, **ALL** images on RAM are released to minimize your app footprint (why is this importan?
- http://developer.apple.com/library/ios/#documentation/iphone/conceptual/iphoneosprogrammingguide/ManagingYourApplicationsFlow/ManagingYourApplicationsFlow.html#//apple_ref/doc/uid/TP40007072-CH4-SW35
-  http://developer.apple.com/library/ios/#documentation/iphone/conceptual/iphoneosprogrammingguide/PerformanceTuning/PerformanceTuning.html#//apple_ref/doc/uid/TP40007072-CH8-SW53 )- List item

 - Images that wasn't used for a week or more are deleted to save iPhone hard drive space.

 - Since Nov 29/2011 the cache stores the images in the cache folder in case of iOS 5.0 and in case of 5.0.1 or greater in the documents folder BUT with the 'com.apple.MobileBackup' flag to avoid backups of the image cache files.

 - Also it has an implementation for "imageNamed:" as a workarround for the cache problem of the native "imageNamed:" on some old OS versions.

 - It is intended to work on UITableViews and UICollections

---

How to Install
--------
Just Copy the folder "*AsyncImage/Classes/Libraries/*" with the 6 files on it to your project.

How to use
---

All you need to know is in AsyncImageView.h and ImageManager.h

A fast tutorial will be:

 1. Go to the XIB where you have the UIImageView
 2. Change the UIImageView class to *AsyncImageView*
 3. If you like, link the *loadingView* and the *delegate* IBOutlet property.
 4. Go to your code and import "*AsyncImageView.h*"
 5. set the AsyncImageView *image* to either *'nil'* or a placeholder image of your choice (you have to do thi **ALWAYS** before loading the real image, specially if the image is on a cell because of the cells reutilization)
 6. Finally invoke "*loadImageFromURL:*" (you can use the alternative method with "force:YES" to always check if a new version of the image is available).
 7. You are done!

**Note:** If you set a "loadingView" on step 3, that view will show/hide when the AsyncImageView is waiting for a request ;)

Enjoy!
---