//
//  PlacesViewController.h
//  Picogram
//
//  Created by 3Embed on 19/01/15.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "NearByPlacesViewController.h"


@protocol PGPlacesViewControllerDelegate <NSObject>

//-(void)sendDataToA:(NSString *)myStringData and:(NSNumber *)distance;

-(void)sendDataToA:(NSString *)myStringData and:(NSString *)distance and:(NSString *)latitude and:(NSString *)longitude;

@end


typedef void(^PlacesCallback)(NSString *name , CLLocation *location);

@interface PGPlacesViewController : UIViewController


@property(nonatomic,strong)CLLocation *currentLocation;
@property(nonatomic,strong)CLLocation *temporaryLocation;
@property(nonatomic,strong)NSString *controllerType;

@property(nonatomic,strong) PlacesCallback callback;
@property(nonatomic,assign)id delegate;

@end
