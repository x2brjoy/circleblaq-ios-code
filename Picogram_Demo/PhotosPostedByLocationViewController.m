//
//  PhotosPostedByLocationViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 4/16/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PhotosPostedByLocationViewController.h"
#import "ShareViewXib.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"
#import "DetailPostViewController.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "FontDetailsClass.h"
#import "FullImageViewXib.h"
#import "Helper.h"
#import "InstaVIdeoTableViewController.h"

@interface PhotosPostedByLocationViewController ()<shareViewDelegate,WebServiceHandlerDelegate,SDWebImageManagerDelegate,UICollectionViewDelegate,UICollectionViewDataSource> {
    
    ShareViewXib *shareNib;
   

    NSMutableArray *responseForPostsByLoaction;
    NSMutableDictionary *dataForListView;
    
    UIActivityIndicatorView *av;
    MKPointAnnotation *point;
    CLLocationCoordinate2D coordinate;
    FullImageViewXib *fullimageViewNib;
   
    
    //anjali
    UIImage* displayImage;
    UIImage* originalImage;
    UIImage *pinImage ;
    
   // [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]];

    
}
@end
@implementation PhotosPostedByLocationViewController
@synthesize mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView.delegate=self;
    point = [[MKPointAnnotation alloc] init];
    self.navigationItem.title= self.navtitle;
    self.navigationItem.hidesBackButton=YES;
    [self createNavLeftButton];
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};

    
    
    [self createActivityViewInNavbar];
    
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleGesture:)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    [self.mapView addGestureRecognizer:tgr];
    
  
    [[SDImageCache sharedImageCache] setMaxMemoryCost:1024 * 1024 * 1];
    [[SDImageCache sharedImageCache] setMaxCacheAge:3600 * 24 * 7];
    [[SDImageCache sharedImageCache] setShouldDecompressImages:YES];
    [[SDImageCache sharedImageCache] setShouldCacheImagesInMemory:NO];
    
    [self requestForPosts];
}

- (IBAction)mapsDirections:(id)sender {
//    NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude, mapPoint.coordinate.latitude, mapPoint.coordinate.longitude];
//    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: directionsURL]];
}

-(void)handleGesture:(id)sender {
    NSString *latitude;
    NSString *longitude;
    
    if (responseForPostsByLoaction.count > 0) {
        latitude = [responseForPostsByLoaction[0][@"latitude"] stringValue];
        longitude = [responseForPostsByLoaction[0][@"longitude"] stringValue];
    }
    
    NSString *combinationOfLatLong = [[latitude stringByAppendingString:[@"," stringByAppendingString:longitude]] stringByAppendingString:@"&zoom=14&views=traffic"];
    
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Open in Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // to open in Apple Maps
        NSString *stringWithLocation =[@"http://maps.apple.com//?center=" stringByAppendingString:combinationOfLatLong];
        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com://"]])
        {
            NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",mapView.userLocation.coordinate.latitude,mapView.userLocation.coordinate.longitude, [latitude  floatValue],[longitude  floatValue]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:directionsURL]];
        }
        else {
            //if app is not available automatically alert will come with download of that app.
              [self showActionSheetForDownloadingApp];
        }
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Open In Google Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
         // to open in Google Maps
        NSString *stringWithLocation =[@"comgooglemaps://?center=" stringByAppendingString:combinationOfLatLong];
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:stringWithLocation]];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

-(void)showActionSheetForDownloadingApp {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Restore Maps ?" message:@"You followed a link that requires the app Maps,which is no longer on your iphone.You can restore it from the App store." preferredStyle:UIAlertControllerStyleAlert];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Show in App Store" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        //to show in itunes
        //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.com/apps/Maps"]];
        
        
        //to show in apple store.
//        NSString *appName = [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
        NSURL *appStoreURL = [NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.com/app/%@",[@"Maps" stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        [[UIApplication sharedApplication] openURL:appStoreURL];
        
       // [self dismissViewControllerAnimated:YES completion:^{
            //        }];
        
    }]];
    
    
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self clearImageCache];
}

-(void)requestForPosts {
    NSString *locationName = self.navtitle;
    
    // Requesting For Post Api.(passing "token" as parameter)
    NSDictionary *requestDict = @{
                                  mauthToken :[Helper userToken],
                                  mplace:locationName
                                  };
    [WebServiceHandler RequestTypepostsbasedonLocation:requestDict andDelegate:self];
}



//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
//    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:NO];
//    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
//    point.coordinate = userLocation.coordinate;
//
//    [self.mapView addAnnotation:point];
//}

/*--------------------------------------------------------------------------------*/
#pragma mark -
#pragma mark - collectionView Delegates and DataSource.
/*----------------------------------------------------------------------------------*/

/**
 *  declaring numberOfSectionsInCollectionView
 *
 *  @param collectionView declaring numberOfSectionsInCollectionView in collection view.
 *
 *  @return number of sctions in collection view here it is 1.
 */

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

/**
 *  declaring numberOfItemsInSection
 *  @param collectionView declaring numberOfItemsInSection in collection view.
 *  @param section    here only one section.
 *  @return number of items in collection view here it is 100.
 */

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return responseForPostsByLoaction.count;
}

/**
 *  implementation of collection view cell
 *  @param collectionView collectionView has only image view
 *  @return implemented cell will return.
 */

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotosPostedByLocationCollectionViewCell *collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCellIndentifier" forIndexPath:indexPath];
    
    NSString *thumbNailUrl = responseForPostsByLoaction[indexPath.row][@"thumbnailImageUrl"];

    
//    [collectionViewCell.postedImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:thumbNailUrl] placeholderImage:[UIImage sd_animatedGIFNamed:@"loading"]];
    
    [collectionViewCell.postedImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:thumbNailUrl]];
    
    collectionViewCell.layer.borderWidth= 0.5f;
    collectionViewCell.layer.borderColor=[[UIColor whiteColor] CGColor];
    //collectionViewCell.contentView.backgroundColor =[UIColor clearColor];
    
    return collectionViewCell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake( CGRectGetWidth(self.view.frame)/3,CGRectGetWidth(self.view.frame)/3);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    InstaVIdeoTableViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:mInstaTableVcStoryBoardId];
    
    newView.showListOfDataFor = @"ListViewForPostsByLocation";
    newView.dataForListView = dataForListView;
    newView.movetoRowNumber = indexPath.item;
    newView.navigationBarTitle = self.navigationItem.title;
    [self.navigationController pushViewController:newView animated:YES];
}





#pragma mark
#pragma mark - navigation bar buttons

- (void)createNavLeftButton
{
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_on"]
                     forState:UIControlStateSelected];
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    
    
    [navCancelButton setFrame:CGRectMake(10.0f,0.0f,40,40)];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    
    // UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithCustomView:segmentView];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}
- (void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
    // [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createNavRightButton
{
    UIButton *navNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navNextButton setImage:[UIImage imageNamed:@"hashtagh_send_icon_off"]
                   forState:UIControlStateNormal];
    [navNextButton setImage:[UIImage imageNamed:@"hashtagh_send_icon_on"]
                   forState:UIControlStateSelected];
    [navNextButton setTitleColor:[UIColor grayColor]
                        forState:UIControlStateHighlighted];
    
    [navNextButton setFrame:CGRectMake(5,17,45,45)];
    
    navNextButton.titleLabel.font = [UIFont fontWithName:RobotoRegular size:13];
    
    [navNextButton addTarget:self action:@selector(shareButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navNextButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}


//method for creating activityview in  navigation bar right.
- (void)createActivityViewInNavbar {
    av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [av setFrame:CGRectMake(0,0,50,30)];
    [self.view addSubview:av];
    av.tag  = 1;
    [av startAnimating];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:av];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}


- (void)shareButtonAction:(UIButton *)sender {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    shareNib = [[ShareViewXib alloc] init];
    shareNib.delegate = self;
    [shareNib showViewWithContacts:window];
}

-(void)cancelButtonClicked
{
    [shareNib removeFromSuperview];
}

/*---------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*---------------------------------*/

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    [av stopAnimating];
    //[self createNavRightButton];
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        return;
    }
    
    //storing the response from server to dictonary.
    NSDictionary *responseDict = (NSDictionary*)response;
    
    //checking the request type and handling respective response code.
    
    if (requestType == RequestTypebasedonLoaction ) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
                responseForPostsByLoaction =[[NSMutableArray alloc] init];
                dataForListView = response;
                responseForPostsByLoaction = response[@"data"];
                
                if (responseForPostsByLoaction.count >0) {
                    NSString *latitudeOfSelectedLoaction =  responseForPostsByLoaction[0][@"latitude"];
                    NSString *longitudeeOfSelectedLoaction =  responseForPostsByLoaction[0][@"longitude"];
                    coordinate = CLLocationCoordinate2DMake([latitudeOfSelectedLoaction  doubleValue] ,
                                                            [longitudeeOfSelectedLoaction  doubleValue] );
                }
                else {
                    [self backGrounViewWithImageAndTitle:@"No Posts"];
                }
               
                [self.photosCollectionView reloadData];
                
            }
                break;
                
                //failure response.
            case 3033: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1972: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1973: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1974: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }
}
- (void)errAlert:(NSString *)message {
    //creating alert for error message.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];
    [alert show];
}

-(void)backGrounViewWithImageAndTitle:(NSString *)mesage{
    
    UIView *viewWhenNoPosts = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.photosCollectionView.frame.size.width, self.photosCollectionView.frame.size.height)];
    
    UIImageView *image =[[UIImageView alloc] init];
    image.image = [UIImage imageNamed:@"ip5"];
    image.frame =  CGRectMake(self.photosCollectionView.frame.size.width/2 - 45, self.photosCollectionView.frame.size.height/2 - 45, 90, 90);
    [viewWhenNoPosts addSubview:image];
    
    UILabel *labelForNoPostsMessage = [[UILabel alloc] init];
    labelForNoPostsMessage.text = mesage;
    labelForNoPostsMessage.numberOfLines =0;
    labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
    labelForNoPostsMessage.frame = CGRectMake(0, CGRectGetMaxY(image.frame) + 10, self.photosCollectionView.frame.size.width, 60);
    labelForNoPostsMessage.textColor = [UIColor blackColor];
    [labelForNoPostsMessage setFont:[UIFont fontWithName:RobotoRegular size:15]];
    labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
    [viewWhenNoPosts addSubview:labelForNoPostsMessage];
    self.photosCollectionView.backgroundColor = backGroundColor;
    self.photosCollectionView.backgroundView = viewWhenNoPosts;
}

-(void)dealloc {
    [self clearImageCache];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self clearImageCache];
}

-(void)clearImageCache{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearDisk];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    
    if (responseForPostsByLoaction.count) {
        coordinate.latitude = [responseForPostsByLoaction[0][@"latitude"] doubleValue];
        coordinate.longitude = [responseForPostsByLoaction[0][@"longitude"] doubleValue];
    }
    else {
        coordinate.latitude = self.selected_location.coordinate.latitude;
        coordinate.longitude = self.selected_location.coordinate.longitude;
    }
    
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    point.coordinate = coordinate;
    [self.mapView addAnnotation:point];
    
    //    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(yourLocation.coordinate, 100, 100);
    //    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    //    [self.mapView setRegion:adjustedRegion animated:YES];
}

//
//- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id < MKAnnotation >)annotation
//{
//    static NSString *reuseId = @"StandardPin";
//    
//    MKAnnotationView *aView = (MKAnnotationView *)[sender
//                                                   dequeueReusableAnnotationViewWithIdentifier:reuseId];
//    
//    if (aView == nil)
//    {
//        aView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
//        aView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        aView.canShowCallout = YES;
//    }
//    
//    for (int i = 0; i < arrayofmainUrls.count; i++) {
//        originalImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:arrayofmainUrls[i]]]];
//        pinImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:arrayOfThumbNailUrls[i]]]];
//        
//        aView.image = [self imageWithImage:pinImage scaledToSize:CGSizeMake(30, 30)];
//        //}
//        // aView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_postDict[@"thumbnailImageUrl"]]]]; //[UIImage imageNamed : @"Location_OnMap"];
//        aView.annotation = annotation;
//        aView.calloutOffset = CGPointMake(0, -5);
//        aView.draggable = YES;
//        aView.enabled = YES;
//        // return aView;
//    }
//   /* originalImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_postDict[@"mainUrl"]]]];
//     pinImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_postDict[@"thumbnailImageUrl"]]]];
//     
//     aView.image = [self imageWithImage:pinImage scaledToSize:CGSizeMake(30, 30)];
//     aView.annotation = annotation;
//     aView.calloutOffset = CGPointMake(0, -5);
//     aView.draggable = YES;
//     aView.enabled = YES;*/
//    return aView;
//}
//
//
//- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)mk
//{
//    
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//    fullimageViewNib = [[FullImageViewXib alloc] init];
//    [fullimageViewNib showFullImage:originalImage onWindow:window];
//    
//}
//
//- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
//{
//    UIGraphicsBeginImageContext(newSize);
//    
//    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    displayImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return displayImage;
//}
//
//-(void)handletapForRemoveTaggedPerson:(id)sender {
//    
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//    fullimageViewNib = [[FullImageViewXib alloc] init];
//    [fullimageViewNib showFullImage:pinImage onWindow:window];
//    
//}*/
@end
