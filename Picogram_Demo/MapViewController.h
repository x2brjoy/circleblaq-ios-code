//
//  MapViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 4/6/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <MapKit/MapKit.h>


@interface MapViewController : UIViewController//<MKMapViewDelegate>

//@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)backButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *backButtonOutlet;

@property NSString *checkingPhotoMapOf;
@property (nonatomic,strong)NSMutableArray *postDetails;

@end
