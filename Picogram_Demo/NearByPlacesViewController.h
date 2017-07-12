//
//  SearchinLocationViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "NearByPlacesTableViewCell.h"

@interface NearByPlacesViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource>
{
@private
   CLLocationManager *locationManager;
}



@property(nonatomic,strong)CLLocation *currentLocation;

@property (nonatomic,strong) CLLocationManager *locationManager;



//@property (nonatomic, readonly, copy, nullable) NSString *subLocality; // neighborhood, common name, eg. Mission District
@end
