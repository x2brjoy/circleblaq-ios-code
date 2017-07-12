//
//  addressViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 27/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "addressViewController.h"
#import "Helper.h"
#import "FontDetailsClass.h"
#import "PGPlacesViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface addressViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *addressTbl;
    UITextField *cellTextfield;
    CLLocationManager *locationManager;
    
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@end

@implementation addressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavLeftButton];
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    [self location];
    self.title = @"Location";
    self.view.backgroundColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1.0f];
    //cellTextfield = [[UITextField alloc]initWithFrame:CGRectMake(10, 5, [[UIScreen mainScreen]bounds].size.width-20, 40)];
    addressTbl = [[UITableView alloc] initWithFrame:CGRectMake(0,15, [[UIScreen mainScreen]bounds].size.width,250)];
    addressTbl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    addressTbl.delegate = self;
    addressTbl.dataSource = self;
    addressTbl.scrollEnabled = NO;
    
    addressTbl.backgroundColor = [UIColor colorWithRed:245/255.0f green:245/255.0f blue:245/255.0f alpha:1.0f];;
    [self.view addSubview:addressTbl];
    
    UILabel *msg = [[UILabel alloc]initWithFrame:CGRectMake(15,CGRectGetMaxY(addressTbl.frame), [[UIScreen mainScreen]bounds].size.width-20, 100)];
    [Helper setToLabel:msg Text:@"Please add Valid address so that people can navigate to your location " WithFont:RobotoLight FSize:15.0f Color:[UIColor grayColor]];
    msg.numberOfLines = 0;
    msg.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:msg];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - navigation bar buttons

//method for creating navigation bar left button.
- (void)createNavLeftButton {
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_on"]
                     forState:UIControlStateSelected];
    navCancelButton.titleLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    [navCancelButton addTarget:self
                        action:@selector(CancelButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];
    
    [navCancelButton setFrame:CGRectMake(0.0f,0.0f,30,30)];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

//action for navigation bar items (buttons).

- (void)CancelButtonAction:(UIButton *)sender {
    //[self.navigationController popViewControllerAnimated:YES];
     [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma marks - UITableviewDelegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
      cell.backgroundView = [[UIView alloc] init];
    
    [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
    cellTextfield = [[UITextField alloc]initWithFrame:CGRectMake(15, 5, [[UIScreen mainScreen]bounds].size.width-30, 40)];
    [cell addSubview:cellTextfield];
    if (indexPath.row == 0) {
    cellTextfield.placeholder = @"Street address";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (indexPath.row == 1) {
        cellTextfield.placeholder = @"City/Town";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 2) {
     cellTextfield.placeholder = @"Postal Code";
    cell.accessoryType = UITableViewCellAccessoryNone;
    }

    
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section ==0 && indexPath.row ==1) {
       
//        PGPlacesViewController *PVC = [[PGPlacesViewController alloc] init];
//        [self presentViewController:PVC animated:YES completion:nil];
        
        
        
        
    }
    
}


-(void)location
{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    [locationManager requestAlwaysAuthorization];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}



- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        NSString *longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        NSString *lattitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        NSLog(@"edges:%@ & %@",longitude,lattitude);
        //currentLatitude = currentLocation.coordinate.latitude;
       // currentLongitude = currentLocation.coordinate.longitude;

        [[NSUserDefaults standardUserDefaults]setObject:longitude forKey:@"longitude"];
        [[NSUserDefaults standardUserDefaults]setObject:lattitude forKey:@"lattitude"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        
    }
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
         if (error == nil && [placemarks count] > 0) {
             placemark = [placemarks lastObject];
             NSString *address = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                  placemark.subThoroughfare, placemark.thoroughfare,
                                  placemark.postalCode, placemark.locality,
                                  placemark.administrativeArea,
                                  placemark.country];
             
             NSLog(@"user location %@",address);
             
             [[NSUserDefaults standardUserDefaults]setObject:address forKey:@"address"];
             [[NSUserDefaults standardUserDefaults]synchronize];
             
             //[[NSNotificationCenter defaultCenter] postNotificationName:@"passLatestAddress" object:address forKey:@"updatedAddress"]];
            
             
         }
         else
         {
             NSLog(@"%@", error.debugDescription);
         }
     } ];
    
    
}


@end
