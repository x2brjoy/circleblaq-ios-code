//
//  PickAddressFromMapViewController.m
//  iServe_AutoLayout
//
//  Created by Apple on 14/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PickAddressFromMapViewController.h"
#import "SaveSelectedAddressViewController.h"
#import "PGLocationViewController.h"
#import "PGPlacesViewController.h"
#import "FontDetailsClass.h"
#import "TinderGenericUtility.h"

@import GoogleMaps;
@interface PickAddressFromMapViewController ()<GMSMapViewDelegate>//,GetCurrentLocationDelegate>
{
    double currentLatitude;
    double currentLongitude;
    CLLocationCoordinate2D coor;
   // GetCurrentLocation *getCurrentLocation;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@end

@implementation PickAddressFromMapViewController

#pragma mark - Initial Methods -

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = YES;
    NSString *str = @"Place the pin on exact location\nor Allow location services";//LS(@"Place the pin on exact location\nor Allow location services");
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:str];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:RobotoRegular size:11] range:NSMakeRange(35,23)];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(35,23)];
    
    @try{
         [self.messageLabel setAttributedText:attributedString];
    }
    @catch(NSException *NSException)
    {
        NSLog(@"Error:%@",NSException.reason);
    }
   
    
    
    //Set Properties Of MapView
    currentLatitude = [[[NSUserDefaults standardUserDefaults]objectForKey:@"lattitude"]floatValue];
    currentLongitude = [[[NSUserDefaults standardUserDefaults]objectForKey:@"longitude"]floatValue];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentLatitude longitude:currentLongitude zoom:16];
    self.selectedAddressLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"address"];
    self.mapView.camera = camera;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.delegate = self;
    self.mapView.myLocationEnabled = YES;
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
//    getCurrentLocation = [GetCurrentLocation sharedInstance];
//    getCurrentLocation.delegate = self;
//    [getCurrentLocation getLocation];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIButton Actions -

- (IBAction)confirmLocationButtonAction:(id)sender
{
   /* if (flStrForStr(self.selectedAddressLabel.text).length >0) {
        [[NSUserDefaults standardUserDefaults]setObject:flStrForStr(self.selectedAddressLabel.text) forKey:@"address"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
  // [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];*/
    
    [self performSegueWithIdentifier:@"toSaveAddressVC" sender:sender];
}

- (IBAction)navigationBackButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)searchAction:(id)sender {
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
   // PGLocationViewController *locVC = [storyboard instantiateViewControllerWithIdentifier:@"getLocation"];
    PGPlacesViewController *locVC = [storyboard instantiateViewControllerWithIdentifier:@"getLocation"];
    locVC.temporaryLocation = _currentLocation;
    locVC.title = @"Find Location";
    locVC.controllerType = @"PickAddress";
    [self.navigationController pushViewController:locVC animated:YES];

    
}

#pragma mark - GMSMapview Delegate -

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    CGPoint point1 = self.mapView.center;
     coor = [self.mapView.projection coordinateForPoint:point1];
    NSLog(@"Location:%f",coor.latitude);
    currentLatitude = coor.latitude;
   currentLongitude = coor.longitude;
    CLLocation *location = [[CLLocation alloc]initWithLatitude:currentLatitude longitude:currentLongitude];
    [self getAddress:location];
    
}

#pragma mark - Get Current Location Delegates -

- (void)updatedLocation:(double)latitude and:(double)longitude
{
    //change map camera postion to current location
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                            longitude:longitude
                                                                 zoom:16];
    [self.mapView setCamera:camera];
    
    //save current location to plot direciton on map
    currentLatitude = latitude;
    currentLongitude =  longitude;
    
}

-(void)updatedAddress:(NSString *)currentAddress
{
    self.selectedAddressLabel.text = currentAddress;
    NSLog(@"Current Address In PickUp Address Class:%@",self.selectedAddressLabel.text);
}

#pragma mark - Location Services Methods -


#pragma mark - Get Current Location Methods -

- (void)getAddress:(CLLocation *)coordinate
{
    
   CLGeocoder *geocoderN = [[CLGeocoder alloc] init];
    
    [geocoderN reverseGeocodeLocation:coordinate
                   completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!error)
         {
             CLPlacemark *placemark1 = [placemarks objectAtIndex:0];
             
             self.selectedAddressLabel.text = [[placemark1.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             NSLog(@"Business Selected Address:%@",self.selectedAddressLabel.text);
             
         }
         else
         {
             NSLog(@"Failed to update location : %@",error);
         }
     }];
}

#pragma mark - Prepare Segue -

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toSaveAddressVC"])
    {
        SaveSelectedAddressViewController *saveAddressVC = [segue destinationViewController];
        //saveAddressVC.isFromProviderBookingVC = self.isFromProviderBookingVC;
        saveAddressVC.selectedAddressDetails = @{
                                                 @"address":flStrForStr(self.selectedAddressLabel.text),
                                                 @"lat":[NSNumber numberWithDouble:currentLatitude],
                                                 @"log":[NSNumber numberWithDouble:currentLongitude],
                                                 };
        
    }
}



@end
