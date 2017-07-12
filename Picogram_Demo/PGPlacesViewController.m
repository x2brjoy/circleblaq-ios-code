//
//  PlacesViewController.m
//  Picogram
//
//  Created by 3Embed on 19/01/15.
//
//

#import "PGPlacesViewController.h"
#import "FSConverter.h"
#import "FSVenue.h"
#import "NearByPlacesViewController.h"
#import "FontDetailsClass.h"
#import "TinderGenericUtility.h"
#import "SaveSelectedAddressViewController.h"
#import "WebServiceHandler.h"

@interface PGPlacesViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,weak)IBOutlet UITableView *tbleView;
@property(nonatomic,weak)IBOutlet UISearchBar *searchbar;
@property(nonatomic,strong)NSArray *searchResults;
@property(nonatomic,strong)NSArray *firstResut;
@property(nonatomic,assign) BOOL isSearching;
@end

@implementation PGPlacesViewController {
    NSArray *search;
    NSString *locationname;
    NSString *detailedAddress;
    NSNumber *locationDistance;
    CLLocation *locaiton;
    NSString*latitude;
    NSString *longitude;
    FSVenue *venue;
    NSArray *googlePlacesApiResult;
}
@synthesize delegate;

#define kGOOGLE_API_KEY @"AIzaSyCizq7QvPED3UkztXhCs1BTqyyFoRWRYWI"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Locations";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    _currentLocation =_temporaryLocation;
   
    self.automaticallyAdjustsScrollViewInsets=NO;
    [self createNavRightButton];
    [self createNavLeftButton];
    self.navigationItem.hidesBackButton=YES;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden=NO;
}

#pragma mark
#pragma mark - navigation bar buttons

- (void)createNavRightButton
{
    UIButton *navNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navNextButton setTitle:@"Cancel"
                   forState:UIControlStateNormal];
    navNextButton.titleLabel.font = [UIFont fontWithName:RobotoRegular  size:13];
    [navNextButton setTitleColor:[UIColor blackColor]
                        forState:UIControlStateNormal];
    [navNextButton setTitleColor:[UIColor blackColor]
                        forState:UIControlStateHighlighted];
    [navNextButton setFrame:CGRectMake(0,0,50,30)];
    [navNextButton addTarget:self action:@selector(CancelButton:)
            forControlEvents:UIControlEventTouchUpInside];
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navNextButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    // negativeSpacer.width = -5;// it was -6 in iOS 6
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

/*------------------------------------------*/
#pragma mark -
#pragma mark - navigation bar buttons
/*------------------------------------------*/

- (void)createNavLeftButton {
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"location_direction_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"location_direction_icon_on"]
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
- (void)backButtonClicked {
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) CancelButton:(UIButton *)sender {
    self.navigationItem.hidesBackButton =YES;
    [self.navigationController popViewControllerAnimated:YES];
}

/*------------------------------------------*/
#pragma mark -
#pragma mark - near by locations.
/*------------------------------------------*/

-(void)queryGooglePlaces:(NSString *) _searchString {
    _isSearching = YES;
   // https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=geocode&language=en&sensor=true&key=AIzaSyBwexlAGlenKnpkdUas2nybqROB069pmGo
    
  //  https://maps.googleapis.com/maps/api/place/autocomplete/json?input=h&types=establishment&location=0,0&radius=20000000&key=AIzaSyBBFZrlfhtpTbcJO_Ze0_XhNsHE_aRDlU0
    
  //https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=40.409262,49.867092&radius=5000&keyword=Paris&key=AIzaSyBBFZrlfhtpTbcJO_Ze0_XhNsHE_aRDlU0
    
//    NSString *strUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=%@&location=%f,%f&radius=5000&key=AIzaSyBBFZrlfhtpTbcJO_Ze0_XhNsHE_aRDlU0",_searchString,_currentLocation.coordinate.latitude,_currentLocation.coordinate.longitude];
    
    NSString *strUrl = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=OOZHXARNKFGUATVDGV2A3QMY5IWZPBCOMYH3PV1GYVH0LN5Y&client_secret=SAZX0KD50HLQ2RSIPXR0UQLNVWOEBJTI2YSSD2H0SD4SKVOX&v=20130815&ll=%f,%f&query=%@",_currentLocation.coordinate.latitude,_currentLocation.coordinate.longitude,_searchString
                        ];
    NSLog(@"%@",strUrl);
   // NSString *strUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=geocode&language=en&sensor=true&key=AIzaSyBwexlAGlenKnpkdUas2nybqROB069pmGo",_searchString];
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:strUrl];
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {
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
    if (_isSearching) {
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

/*------------------------------------------*/
#pragma mark -
#pragma mark - UITableViewDelegate Methods
/*------------------------------------------*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return googlePlacesApiResult.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    //    //NSDictionary *dict = _searchResults[indexPath.row];
    //    if (_isSearching) {
    //        // cell.textLabel.text = dict[@"description"];
    //        cell.textLabel.text = [_searchResults[indexPath.row] namE];
    //        FSVenue *venue = _searchResults[indexPath.row];
    //        if (venue.location.address) {
    //            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@m, %@",
    //                                         venue.location.distance,
    //                                         venue.location.address];
    //        }else {
    //            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@m",
    //                                         venue.location.distance];
    //        }
    //    }
    //    else {
    //        cell.textLabel.text = dict[@"name"];
    //    }
    
    cell.detailTextLabel.text = flStrForObj(googlePlacesApiResult[indexPath.row][@"description"]);
    cell.textLabel.text = flStrForObj(googlePlacesApiResult[indexPath.row][@"terms"][0][@"value"]);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

/*---------------------------------------------*/
#pragma mark -
#pragma mark - UITableViewDataSource Methods
/*---------------------------------------------*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    [tableViewCell setSelected:NO animated:YES];
    //    FSVenue *venue = _searchResults[indexPath.row];
    //    NSString *locationname;
    //    NSNumber *locationDistance;
    //    CLLocation *locaiton;
    //
    //
    //    if (_isSearching) {
    //        locationname = venue.namE;
    //        locationDistance =venue.location.distance;
    //        //locaiton = venue.location.coordinate;
    //            locaiton = [[CLLocation alloc] initWithLatitude:venue.location.coordinate.latitude longitude:venue.location.coordinate.longitude];
    //        latitude = [NSString stringWithFormat:@"%f", venue.location.coordinate.latitude];
    //        longitude = [NSString stringWithFormat:@"%f", venue.location.coordinate.longitude];
    //
    //
    //    }
    
    NSLog(@"seleected place place id is :%@",flStrForObj(googlePlacesApiResult[indexPath.row][@"reference"]));
    [self retrieveJSONDetailsAbout:googlePlacesApiResult[indexPath.row][@"reference"] withCompletion:^(NSArray *result){
        
        NSString *selectedAddressName = [NSString stringWithFormat:@"%@",flStrForObj([result valueForKey:@"name"])];
        NSString *selectedAddress = [NSString stringWithFormat:@"%@",flStrForObj([result valueForKey:@"formatted_address"])];
        NSString *fullAddress  = [[selectedAddressName stringByAppendingString:@" "] stringByAppendingString:selectedAddress];
        detailedAddress = fullAddress;
        NSDictionary *latLongdict = [result valueForKey:@"geometry"];
        latitude = latLongdict[@"location"][@"lat"];
        longitude = latLongdict[@"location"][@"lng"];
//        [self performSegueWithIdentifier:@"placeToSaveAddress" sender:self];
        
        [delegate sendDataToA:selectedAddressName and:selectedAddress and:latitude and:longitude];
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    
    
    
    
    
    
    
}
/*--------------------------------------*/
#pragma mark - UIsearchbardelegate.
/*--------------------------------------*/

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.tbleView reloadData];
    [searchBar resignFirstResponder];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
   
    [searchBar resignFirstResponder];
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
   
    return YES;
}

#pragma mark - Prepare Segue -
    
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
    {
        if([segue.identifier isEqualToString:@"placeToSaveAddress"])
        {
            SaveSelectedAddressViewController *saveAddressVC = [segue destinationViewController];
            //saveAddressVC.isFromProviderBookingVC = self.isFromProviderBookingVC;
            saveAddressVC.selectedAddressDetails = @{
                                                     @"address":detailedAddress,
                                                     @"lat":latitude,
                                                     @"log":longitude,
                                                     };
            
        }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self retrieveGooglePlaceInformation:flStrForObj(searchBar.text) withCompletion:^(NSArray *result) {
        NSLog(@"results :%@",result);
        googlePlacesApiResult = result;
        [self.tbleView reloadData];
    }];
}

#pragma mark - Google API Requests -


-(void)retrieveGooglePlaceInformation:(NSString *)searchWord
                       withCompletion:(void (^)(NSArray *))complete {
    
    
    NSString *searchWordProtection = [searchWord stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (searchWordProtection.length != 0) {
        
        NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=establishment|geocode&location=%@,%@&radius=500po &language=en&key=%@",searchWord,@"13.23333",@"77.858555",PicogramPlacesApi_Key];
        
        
        NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        NSURLSession *delegateFreeSession;
        delegateFreeSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                            delegate:nil
                                                       delegateQueue:[NSOperationQueue mainQueue]];
        
        NSURLSessionDataTask *task;
        task = [delegateFreeSession dataTaskWithRequest:request
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          
                                          
                                          if (!data || !response || error) {
                                              NSLog(@"Google Service Error : %@",[error localizedDescription]);
                                              return;
                                          }
                                          
                                          NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                          NSArray *results = [jSONresult valueForKey:@"predictions"];
                                          
                                          if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]) {
                                              
                                              complete(nil);
                                          }
                                          else
                                          {
                                              complete(results);
                                              NSLog(@"res %@",results);
                                          }
                                      }];
        [task resume];
    }
}

-(void)retrieveJSONDetailsAbout:(NSString *)place withCompletion:(void (^)(NSArray *))complete {
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&key=%@",place,PicogramPlacesApi_Key];
    
    NSURL *url = [NSURL URLWithString:urlString];// stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *task = [delegateFreeSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jSONresult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSArray *results = [jSONresult valueForKey:@"result"];
        
        if (error || [jSONresult[@"status"] isEqualToString:@"NOT_FOUND"] || [jSONresult[@"status"] isEqualToString:@"REQUEST_DENIED"]){
            if (!error){
                NSDictionary *userInfo = @{@"error":jSONresult[@"status"]};
                NSError *newError = [NSError errorWithDomain:@"API Error" code:666 userInfo:userInfo];
                complete(@[@"API Error", newError]);
                return;
            }
            complete(@[@"Actual Error", error]);
            return;
        }else{
            complete(results);
        }
    }];
    
    [task resume];
}
@end
