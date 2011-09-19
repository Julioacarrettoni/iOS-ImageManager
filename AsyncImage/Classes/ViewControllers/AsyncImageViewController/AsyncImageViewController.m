//
//  AsyncImageViewController.m
//  AsyncImage
//
//  Created by Julio Andrés Carrettoni on 9/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageViewController.h"
#import "FullScreenImageViewController.h"
#import "ImageCell.h"
#import "ImageManager.h"

@implementation AsyncImageViewController

- (void)dealloc
{
    [theTableView release];
    [super dealloc];
}

#pragma mark - View lifecycle
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray* imagesURLSource = [NSArray arrayWithObjects:
                          @"http://fc05.deviantart.net/fs49/f/2009/202/d/4/Domo_kun_by_Reptar_Bar.png",
                          @"http://2.bp.blogspot.com/_LWocGZaCOIg/SwUJlJC2HhI/AAAAAAAABW4/jODGk7WdL3c/s320/domo-2.png",
                          @"http://fc02.deviantart.net/fs26/f/2008/147/b/7/DOMO_by_L_ement.png",
                          @"http://www.bitrebels.com/wp-content/uploads/2009/12/c0e0_fuzzy_ninja_black_domo.png",
                          @"http://www.domonation.com/uploadedimages/emperor186/domo.png",
                          @"http://www.domonation.com/uploadedimages/LuckySushi/domo.png",
                          nil];
    
    NSMutableArray* mutArray = [NSMutableArray new];
    
    for (int i = 0; i < 50; i++)
    {
        int index = arc4random()%(imagesURLSource.count);
        [mutArray addObject:[imagesURLSource objectAtIndex:index]];
    }
    
    imagesURL = [[NSArray alloc] initWithArray:mutArray];
    [mutArray release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)viewDidUnload {
    [theTableView release];
    theTableView = nil;
    
    [super viewDidUnload];
}

#pragma mark - UITableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return imagesURL.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell* cell = (ImageCell*)[tableView dequeueReusableCellWithIdentifier:@"ImageCell"];
    
    if (!cell)
    {
        cell = (ImageCell*)[[[NSBundle mainBundle] loadNibNamed:@"ImageCell" owner:nil options:nil] objectAtIndex:0];
    }
    //We use this instead of native one, cause this one is easier to manage, the other one mess with the memory :(
    cell.asyncImageView.image = [ImageManager imageNamed:@"time_sand_glass.png"];
    [cell.asyncImageView loadImageFromURL:[imagesURL objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* imageURL = [imagesURL objectAtIndex:indexPath.row];
    UIViewController* controller = [[FullScreenImageViewController alloc] initWithImageURL:imageURL];
    controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:controller animated:YES];
    [controller release];

}

- (IBAction)onWipeRamButtonTUI:(id)sender {
    [ImageManager freeRamCache];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Images cached in RAM erased." message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (IBAction)onWipeHDButtonTUI:(id)sender {
    [ImageManager eraseHardCache];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Images cached in HD erased." message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}
@end
