//
//  SearchingLocationViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/21/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "FSConverter.h"
#import "FSVenue.h"

@interface SearchingLocationViewController : UIViewController
- (IBAction)getLocation:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property(nonatomic,strong)CLLocation *currentLocation;

@end
