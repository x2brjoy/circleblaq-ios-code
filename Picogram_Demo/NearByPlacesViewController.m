//
//  SearchinLocationViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "NearByPlacesViewController.h"
#import "PGPlacesViewController.h"
#import "FSConverter.h"
#import "FSVenue.h"
#import <CoreLocation/CoreLocation.h>
#import "searchViewController.h"
#import "PhotosPostedByLocationViewController.h"
#import "Helper.h"

@interface NearByPlacesViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>
{
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    NSString *locationname;
}

@property(nonatomic,weak)IBOutlet UITableView *tbleView;
@property(nonatomic,strong)NSArray *searchResults;
@property(nonatomic,strong)NSArray *firstResut;
@property(nonatomic,assign) BOOL isSearching;
@end

@implementation NearByPlacesViewController


#define kGOOGLE_API_KEY @"AIzaSyCizq7QvPED3UkztXhCs1BTqyyFoRWRYWI"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

- (void)viewDidLoad

{
    [super viewDidLoad];
    [self checkingLocationStatus];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    self.navigationItem.title = @"NEAR BY";
    [self queryGooglePlaces:@""];
    [self createNavLeftButton];
}

-(void)checkingLocationStatus
{
    if ([CLLocationManager locationServicesEnabled ]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }
}

-(void)viewWillAppear:(BOOL)animated{

}

-(void)viewWillDisappear:(BOOL)animated{
  
}
#pragma mark - CLLocationManagerDelegate


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
    [self.locationManager stopUpdatingLocation];
    geocoder = [[CLGeocoder alloc] init];
    self.currentLocation = [locations lastObject];
    [self queryGooglePlaces:@""];
}

-(void) queryGooglePlaces:(NSString *) _searchString {
    
    _isSearching = YES;

    NSString *strUrl = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=OOZHXARNKFGUATVDGV2A3QMY5IWZPBCOMYH3PV1GYVH0LN5Y&client_secret=SAZX0KD50HLQ2RSIPXR0UQLNVWOEBJTI2YSSD2H0SD4SKVOX&v=20130815&ll=%f,%f&query=%@",self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude,_searchString
                        ];
    NSLog(@"%@",strUrl);
    
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:strUrl];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData
{
    
    if (responseData == nil) {
        return;
    }
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    
    // NSLog(@"results : %@",json);
    
    if (_isSearching)
    {
        NSArray* venues = [json valueForKeyPath:@"response.venues"];
        FSConverter *converter = [[FSConverter alloc]init];
        
        _searchResults =[converter convertToObjects:venues];
        
        //_searchResults = [json objectForKey:@"predictions"];
    }
    else{
        _searchResults = [json objectForKey:@"results"];
    }
    
    if (_firstResut.count == 0) {
        _firstResut = _searchResults;
    }
    
    
    
    //Write out the data to the console.
    [self.tbleView reloadData];
    
    //Plot the data in the places array onto the map with the plotPostions method.
    // [self plotPositions:places];
    
}



#pragma mark -
#pragma mark UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResults count];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    NearByPlacesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (_isSearching) {
        // cell.textLabel.text = dict[@"description"];
        
        cell.addressLabelOutlet.text = [_searchResults[indexPath.row] namE];
        
        FSVenue *venue = _searchResults[indexPath.row];
        if (venue.location.address) {
            cell.subLocationAddressLabelOutlet.text =venue.location.address;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 ) {
        return 50;
    }
    else {
        return 150;
    }
}
#pragma mark - UITableViewDataSource Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    [tableViewCell setSelected:NO animated:YES];
    
    FSVenue *venue = _searchResults[indexPath.row];
    
    NSNumber *locationDistance;
    CLLocation *locaiton;
    if (_isSearching)
    {
        locationname = venue.namE;
        locationDistance =venue.location.distance;
        //locaiton = venue.location.coordinate;
        locaiton = [[CLLocation alloc] initWithLatitude:venue.location.coordinate.latitude longitude:venue.location.coordinate.longitude];
    }
    
    PhotosPostedByLocationViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"photosPostedByLoactionVCStoryBoardId"];
    postsVc.navtitle =locationname;
    postsVc.selected_location = locaiton;
    [self.navigationController pushViewController:postsVc animated:YES];
    
}

#pragma mark
#pragma mark - navigation bar buttons

- (void)createNavLeftButton
{
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_on"]
                     forState:UIControlStateSelected];
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    [navCancelButton setFrame:CGRectMake(10.0f,0.0f,40,40)];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    
    // UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithCustomView:segmentView];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
