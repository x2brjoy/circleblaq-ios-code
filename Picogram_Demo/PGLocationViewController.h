//
//  PGLocationViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/21/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol senddataProtocol <NSObject>

-(void)sendDataToA:(NSString *)myStringData;

@end

@interface PGLocationViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate, CLLocationManagerDelegate>
{
@private
    CLLocationManager *locationManager;
    
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}
@property(nonatomic,weak)id<senddataProtocol> delegate;

@end
