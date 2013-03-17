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
    
//    NSMutableArray* baconArray = [NSMutableArray array];
//    for (int i = 0; i < 100; i++)
//    {
//        int height = arc4random()%20*20+500;
//        int width = arc4random()%20*20+500;
//        NSString* name = [NSString stringWithFormat:@"http://baconmockup.com/%d/%d", width, height];
//        [baconArray addObject:name];
//    }
//    NSArray* imagesURLSource = [NSArray arrayWithArray:baconArray];
    
    NSArray* imagesURLSource = [NSArray arrayWithObjects:
                                @"http://2.bp.blogspot.com/-hU25nwadhPI/TV1TNKRmBYI/AAAAAAAAAH8/dKxiSpvhsPE/s1600/600px-MA_Route_1_svg.png",
                                @"http://www.personal.psu.edu/bjh5378/numbertwo.jpg",
                                @"https://comolocuentestedoy.files.wordpress.com/2012/06/512px-number_3_in_yellow_rounded_square-svg.png",
                                @"http://www.thetimes.co.uk/tto/multimedia/archive/00351/115739913_4_351229c.jpg",
                                @"http://i210.photobucket.com/albums/bb240/ShakeSicle/ATHF%20Pictures/meatwad5shape.gif",
                                @"http://2.bp.blogspot.com/_g77lmGbXe3k/TSgdKypI6uI/AAAAAAAAAZ4/gP5XzlZYQYI/s1600/6.jpg",
                                @"http://www.sci.uma.es/media/tinyimages/img/image_136.jpeg",
                                @"http://www.ask8ball.net/assets/images/main/8ball.jpg",
                                @"http://www.supermoviezone.com/wp-content/uploads/2013/02/9_foreign_movie_poster.jpg",
                                @"http://www.marketingdirecto.com/wp-content/uploads/2013/01/bigstockphoto_number___3032573-number-101.jpg",
                                @"http://www.angelesamor.org/wp-content/uploads/2011/11/11.jpg",
                                @"http://chan.catiewayne.com/m/src/135535389420.png",
                                @"http://www.nocturnar.com/forum/attachments/perfiles/12199d1331606082-martes-13-martes-13.gif",
                                @"http://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/California_14.svg/385px-California_14.svg.png",
                                @"http://www.kriptopolis.org/images/quince.gif",
                                @"http://3.bp.blogspot.com/-1yte0G7O4p8/T3oaeU8MsxI/AAAAAAAAQxk/I3QH9ud9kXk/s1600/16.jpg",
//                          @"http://fc05.deviantart.net/fs49/f/2009/202/d/4/Domo_kun_by_Reptar_Bar.png",
//                          @"http://2.bp.blogspot.com/_LWocGZaCOIg/SwUJlJC2HhI/AAAAAAAABW4/jODGk7WdL3c/s320/domo-2.png",
//                          @"http://fc02.deviantart.net/fs26/f/2008/147/b/7/DOMO_by_L_ement.png",
//                          @"http://www.bitrebels.com/wp-content/uploads/2009/12/c0e0_fuzzy_ninja_black_domo.png",
//                          @"http://www.domonation.com/uploadedimages/emperor186/domo.png",
//                          @"http://www.domonation.com/uploadedimages/LuckySushi/domo.png",
                          nil];

    
    NSMutableArray* mutArray = [NSMutableArray new];
    
    for (int i = 0; i < 5000; i++)
    {
        int index = i%imagesURLSource.count;//arc4random()%(imagesURLSource.count);
        [mutArray addObject:[imagesURLSource objectAtIndex:index]];
    }
    
    imagesURL = [[NSArray alloc] initWithArray:mutArray];
    [mutArray release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
