//
//  PhotosPostedByLocationViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 4/16/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PhotosPostedByLocationCollectionViewCell.h"

@interface PhotosPostedByLocationViewController : UIViewController<MKMapViewDelegate>
{
    UIView *AlertForNumberConformation;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak,nonatomic) NSString *navtitle;
@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (nonatomic, copy, readonly) NSString *image;
@property (weak, nonatomic) NSDictionary *postDict;

@property (weak,nonatomic) NSString *place_latitude;
@property (weak,nonatomic) NSString *place_longitude;

@property CLLocation *selected_location;
@end
