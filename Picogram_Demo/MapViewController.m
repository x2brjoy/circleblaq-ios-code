//
//  MapViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 4/6/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "MapViewController.h"
#import <GoogleMaps/GoogleMaps.h>


@interface MapViewController ()
@property (nonatomic, strong) GMSMapView *mapView_;
@property (nonatomic, strong) NSMutableArray *markersArray;
@end

@implementation MapViewController


//@synthesize mapView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden=NO;
    self.tabBarController.tabBar.hidden=YES;
    
    [self setupMapView];
   // [self plotMarkers];
    
    
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [self plotMarkers];
}
-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden=NO;
    self.tabBarController.tabBar.hidden=NO;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.backButtonOutlet setTitle:self.checkingPhotoMapOf forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-Map setup

- (void)setupMapView
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:13.028829
                                                            longitude:77.589753
                                                                 zoom:16];
    self.mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view = self.mapView_;
    self.mapView_.myLocationEnabled = YES;
    self.mapView_.mapType = kGMSTypeNormal;
    self.mapView_.settings.myLocationButton = YES;
    self.mapView_.settings.zoomGestures = YES;
    self.mapView_.settings.tiltGestures = NO;
    self.mapView_.settings.rotateGestures = NO;
    [self.mapView_ clear];

    
}

- (void)plotMarkers
{
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    for (int i=0; i<[_postDetails count]; i++){
        NSURL *url = [NSURL URLWithString:_postDetails[i][@"mainUrl"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [UIImage imageWithData:data scale:0.0];//[[UIImage alloc] initWithData:data];
        UIImage *imgg = [self imageWithImage:img scaledToSize:CGSizeMake(15, 15)];
        
        double lt=[_postDetails[i][@"latitude"] doubleValue];
        double ln=[_postDetails[i][@"longitude"]doubleValue];
        NSString *name = _postDetails[i][@"place"];
        
        // Instantiate and set the GMSMarker properties
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.appearAnimation=YES;
        marker.position = CLLocationCoordinate2DMake(lt,ln);
        marker.title = name;
        marker.snippet = _postDetails[i][@"place"];
        bounds = [bounds includingCoordinate:marker.position];
        marker.icon = imgg; //[UIImage imageNamed:img];
        marker.map = self.mapView_;
        
       // [self.markersArray addObject:marker];
        //[_mapView_ animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];
        [_mapView_ animateToLocation:CLLocationCoordinate2DMake(lt, ln)];

    }
   // [_mapView_ animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];

}

// Lazy load the getter method
- (NSMutableArray *)markersArray
{
    if (!_markersArray) {
        _markersArray = [NSMutableArray array];
    }
    return _markersArray;
}

/*--------------------------------------------*/
#pragma mark
#pragma mark - imageResizing.
/*--------------------------------------------*/

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
