//
//  PickAddressFromMapViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 24/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
//#import <GoogleMaps/GoogleMaps.h>

@interface PickAddressFromMapViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *navigationLeftButton;
@property (strong, nonatomic) IBOutlet UIView *topAddressView;
@property(nonatomic,strong)CLLocation *currentLocation;


@property (weak, nonatomic) IBOutlet UILabel *selectedAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property BOOL isFromProviderBookingVC;
- (IBAction)confirmLocationButtonAction:(id)sender;
- (IBAction)navigationBackButtonAction:(id)sender;
- (IBAction)searchAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *searchButtonOutlet;


@end



