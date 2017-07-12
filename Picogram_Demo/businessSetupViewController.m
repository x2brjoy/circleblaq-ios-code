//
//  businessSetupViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 26/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "businessSetupViewController.h"
#import "Helper.h"
#import "FontDetailsClass.h"
#import "UserProfileViewController.h"
#import "addressViewController.h"
#import "AddressPickerViewController.h"
#import "PickAddressFromMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "TinderGenericUtility.h"
#import "UserProfileViewController.h"
#import "FontDetailsClass.h"
#import "businessSetupTableViewCell.h"
#import "UpdatePhoneNumberVC.h"
#import "OptionsViewController.h"
#import "ProgressIndicator.h"
@interface businessSetupViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CLLocationManagerDelegate,UIWebViewDelegate,UITextViewDelegate,WebServiceHandlerDelegate>
{
    int w,h,scrolHeight;
    UITableView *detailTableView;
    NSArray *sectionHeaders;
    NSArray *row1Array;
    NSArray *row1ImgArray;
    NSArray *row2Array;
    NSArray *row2ImgArray;
    UIView *cellView;
    UIImageView *iconDisplay;
    UILabel *iconLbl;
    UITextField *iconTxT;
    //UITextView *cell.iconTxT;
    UIScrollView *basescrollview;
    CLLocationManager *locationManager;
    NSString *longitude;
    NSString *lattitude;
    NSString *address;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    NSString *profileName;
    CGFloat lblHeight;
    NSString *myString;
    NSString *webUrl,*contactNumber,*contactEmail,*bio;
    float height,addressHeight;
    CGSize bioHeight;
    BOOL isediting;
    CLLocation *currentLocation;
     int keyboardHeight;
}

@end

@implementation businessSetupViewController

- (void)viewDidLoad {
   // [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden = YES;
    //profileName = [Helper userName];
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    lblHeight = 50;
    height = 50.0;
    
    self.view.backgroundColor = [UIColor whiteColor];
    sectionHeaders= [[NSArray alloc] initWithObjects:@"BUSINESS DETAILS",@"CONTACT INFORMATION",nil];
     row1Array = [[NSArray alloc] initWithObjects:@"Business Name",@"Address",@"Website URL",@"About Business", nil];
    row1ImgArray = [[NSArray alloc] initWithObjects:@"set_business_name_icon",@"set_business_address_icon",@"set_business_url_icon",@"set_business_about_icon", nil];
    row2Array = [[NSArray alloc] initWithObjects:@"Phone Number",@"Email", nil];
    row2ImgArray = [[NSArray alloc] initWithObjects:@"set_business_phone_icon",@"set_business_mail_icon", nil];
    webUrl = [[NSUserDefaults standardUserDefaults]valueForKey:@"ProfileWebUrl"];
    contactNumber = [[NSUserDefaults standardUserDefaults]valueForKey:@"ProfileContact"];
    contactEmail = [[NSUserDefaults standardUserDefaults]valueForKey:@"ProfileEmail"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedPhoneNumberdataReceived:) name:@"passPhoneData" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedAddress:) name:@"passLatestAddress" object:nil];
    //bio = [[NSUserDefaults standardUserDefaults]valueForKey:@"Profilebio"];
    
    [self createSetupView];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
    if (!address) {
        //[self askforpermissiontoenablelocation];
        [self GetTheUserCurrentLocation];
    }
    
   [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

-(void)updatedPhoneNumberdataReceived:(NSNotification *)noti {
    contactNumber = [NSString stringWithFormat:@"%@", noti.object[@"updatedPhoneNumber"]];
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:1];
    NSArray *arr = [NSArray arrayWithObject:index];
    [detailTableView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];
    
}

-(void)updatedAddress:(NSNotification *)notify
{
    address = [NSString stringWithFormat:@"%@", notify.object];
    NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:0];
    NSArray *arr = [NSArray arrayWithObject:index];
    [detailTableView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];
}


-(void)viewWillDisappear:(BOOL)animated
{
 
 self.navigationController.navigationBarHidden=NO;
    [self dismiss];
    //[[self navigationController] setNavigationBarHidden:NO animated:YES];
}
-(void)createSetupView
{
    w = [[UIScreen mainScreen]bounds].size.width;
    h = [[UIScreen mainScreen]bounds].size.height;
    
    basescrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, w, h)];
    [self.view addSubview:basescrollview];
    //basescrollview.backgroundColor = [UIColor redColor];
    if (h<520) {
        scrolHeight = h+300;
        basescrollview.contentSize = CGSizeMake(w,scrolHeight);
    }
   else
   {
       scrolHeight = h+200;
       basescrollview.contentSize = CGSizeMake(w,scrolHeight);
   }
    UIView *staticView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, w,40)];
    //staticView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:staticView];
    
    UIView *topView = [[UIView alloc]init];
    if (w>=375)
        topView.frame = CGRectMake(0, 0, w, 220);
    else
       topView.frame = CGRectMake(0, 0, w,220);
    
   // topView.backgroundColor = [UIColor lightGrayColor];
    [basescrollview addSubview:topView];
    
    UIButton *crossBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 40, 40)];
    [crossBtn setImage:[UIImage imageNamed:@"settings_back_icon_off.png"] forState:UIControlStateNormal];
    [crossBtn setImage:[UIImage imageNamed:@"settings_back_icon_on.png"] forState:UIControlStateHighlighted];
    [crossBtn addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [staticView addSubview:crossBtn];
    
    UIButton *doneBtn = [[UIButton alloc]initWithFrame:CGRectMake(w-50, 0, 40, 40)];
    [Helper setButton:doneBtn Text:@"Done" WithFont:RobotoMedium FSize:15.0f TitleColor:[UIColor blueColor] ShadowColor:nil];
    [doneBtn addTarget:self action:@selector(doneBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [staticView addSubview:doneBtn];
    
    UILabel *headerlable = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, w-40, 150)];//80
    //headerlable.backgroundColor = [UIColor grayColor];
     headerlable.numberOfLines = 3;
    [Helper setToLabel:headerlable Text:@"Setup your Business Profile" WithFont:RobotoLight FSize:30.0f Color:[UIColor blackColor]];
    headerlable.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:headerlable];
    
    UILabel *detailedlable = [[UILabel alloc]initWithFrame:CGRectMake(20, 100+20, w-40, 100)];//180
    detailedlable.numberOfLines = 0;
    [Helper setToLabel:detailedlable Text:@"Edit or remove any information that you don't want to be displayed on Picogram.You can always edit this at any time in Settings" WithFont:RobotoLight FSize:15.0f Color:[UIColor grayColor]];
    detailedlable.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:detailedlable];
    
    
    detailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(topView.frame), w, h)];//)];
    detailTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    detailTableView.delegate = self;
    detailTableView.dataSource = self;
    detailTableView.separatorColor = [UIColor clearColor];
    detailTableView.allowsSelection = NO;
    detailTableView.scrollEnabled = NO;
    
    detailTableView.backgroundColor = [UIColor whiteColor];
    [basescrollview addSubview:detailTableView];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismiss)];
    [topView addGestureRecognizer:tap];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CloseBtn Action
-(void)closeBtnAction
{
    //OptionsViewController
    if ([_fromController isEqualToString:@"profile"]) {
        
        [UIView transitionWithView:self.view.window
                          duration:1.0f
                           options:UIViewAnimationOptionTransitionCurlUp
                        animations:^{
                            
                            self.tabBarController.hidesBottomBarWhenPushed = NO;
                            [self.navigationController popToRootViewControllerAnimated:NO];
                            }
                        completion:NULL];

        /* self.tabBarController.hidesBottomBarWhenPushed = NO;
         //[self.navigationController.navigationBar setHidden:NO];
         [self.navigationController popToRootViewControllerAnimated:YES];
         //self.hidesBottomBarWhenPushed = NO;*/
    }
    else
    [self popToOptionView];
   
}

-(void) popToOptionView
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[OptionsViewController class]]) {
            //self.tabBarController.hidesBottomBarWhenPushed = NO;
            [self.navigationController.navigationBar setHidden:NO];
            [self.navigationController popToViewController:controller
                                                  animated:YES];
        }
    }
    
    
    

}

-(void)doneBtnAction
{
    [self sendUpdateBusinessProfile]; 
}

#pragma marks - UITableviewDelegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 4;
    else
        return 2;
}

//Custom Header
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // creating custom header view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    view.backgroundColor =[UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    
    UIView *TopLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width,1)];
    view.backgroundColor =[UIColor colorWithRed:0.9753 green:0.9753 blue:0.9753 alpha:1.0];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(49, 0, tableView.frame.size.width,1)];
    view.backgroundColor =[UIColor colorWithRed:0.9753 green:0.9753 blue:0.9753 alpha:1.0];
    
    /* Create custom view to display section header... */
    UILabel *titileForHeader = [[UILabel alloc] init];
    titileForHeader.text =[sectionHeaders objectAtIndex:section];
    [titileForHeader setFont:[UIFont fontWithName:RobotoMedium size:14]];
    titileForHeader.textColor =[UIColor colorWithRed:0.5296 green:0.5296 blue:0.5296 alpha:1.0];
    titileForHeader.frame=CGRectMake(20, 20, self.view.frame.size.width - 10, 15);
    
    [view addSubview:titileForHeader];
    [view addSubview:TopLine];
    [view addSubview:bottomLine];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  
    if (section == 5) {
        return 40.0;
    }
    else {
        return 0;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    
    //businessSetupTableViewCell *tempCell = [detailTableView cellForRowAtIndexPath:indexPath];
    
    businessSetupTableViewCell *tempCell = (businessSetupTableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
     CGSize size =   tempCell.iconTxT.contentSize;
    if ((indexPath.section == 0) && (indexPath.row == 3)) {
        
        if (bioHeight.height >=size.height) {
            if(bioHeight.height >50.0f)
            return bioHeight.height;
            else
                return 50.0f;
        }
        else if (size.height >bioHeight.height) {
            if(size.height >50.0f)
                return size.height;
            else
                return 50.0f;
        }
    }
    else
    {
    if (size.height<=50.0f) {
        return 50.0f;
    }
    }
    return size.height+10;
    

}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *arr,*arrImg;
    
    static NSString *CellIdentifier = @"Cell";
    
    businessSetupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[businessSetupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for (UIView *view in cell.subviews) {
        if ([view isKindOfClass:[UIImageView class]]||[view isKindOfClass:[UITextView class]] || [view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    
   
    cell.iconDisplay.image = [UIImage imageNamed:row1ImgArray[indexPath.row]];
    
    if (indexPath.section == 0) {
        arr = [row1Array copy];
        arrImg = [row1ImgArray copy];
        cell.iconTxT.tag = (int)indexPath.row+indexPath.section;
        NSLog(@"tags:%ld",(long)cell.iconTxT.tag);
    }
    else{
        arr = [row2Array copy];
        arrImg = [row2ImgArray copy];
       [cell.iconTxT setTag:(int)indexPath.row+4];
    }
    cell.iconDisplay.image = [UIImage imageNamed:arrImg[indexPath.row]];
    cell.iconTxT.text = arr[indexPath.row];
    cell.iconTxT.delegate = self;
   
    if ((indexPath.row == 0)&&(indexPath.section == 0)) {
        if (profileName) {
            cell.iconTxT.text = profileName;
        }
        else
        {  cell.iconTxT.text =row1Array[indexPath.row];
            cell.iconTxT.textColor = [UIColor lightGrayColor];
        }
        
        NSLog(@"textViewTag:%ld",(long)cell.iconTxT.tag);
        }
    if ((indexPath.section == 0) && (indexPath.row == 1)) {
        //cell.iconTxT.text = @"";
        cell.iconTxT.userInteractionEnabled = NO;
        if (address) {
            cell.iconTxT.text = address;
            cell.iconTxT.textColor = [UIColor blackColor];
            [cell.iconTxT sizeToFit];
        }
        else
        { cell.iconTxT.text = @"Address.";
          cell.iconTxT.textColor = [UIColor lightGrayColor];
        }
        UIButton *addressBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 0, w-70, cell.iconTxT.frame.size.height)];
        addressBtn.backgroundColor = [UIColor clearColor];
        [cell addSubview:addressBtn];
        [addressBtn addTarget:self action:@selector(addAddress:) forControlEvents:UIControlEventTouchUpInside];
        iconLbl = [[UILabel alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(cell.iconTxT.frame) , w, 0)];
    }
    if ((indexPath.section == 0) && (indexPath.row == 2)) {
        if (webUrl.length) {
            cell.iconTxT.text = webUrl;
           }
        else
        {  cell.iconTxT.text = @"Website URL";//[[NSUserDefaults standardUserDefaults]valueForKey:@"Profilebio"];;
            cell.iconTxT.textColor = [UIColor lightGrayColor];
            cell.iconTxT.autocapitalizationType = UITextAutocapitalizationTypeNone;
        }
    }
    if ((indexPath.section == 0) && (indexPath.row == 3)) {

        if (cell.iconTxT.text.length==0 || [cell.iconTxT.text isEqualToString:row1Array[indexPath.row]]) {
            cell.iconTxT.text =row1Array[indexPath.row];
            if (bio) {
                cell.iconTxT.text = bio;
            }
            
           cell.iconTxT.textColor = [UIColor lightGrayColor];
        }
       else
        [cell.iconTxT sizeToFit];
        //}
        iconLbl = [[UILabel alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(cell.iconTxT.frame) , w, 0)];
        
    }
    if( (indexPath.row == 0)&&(indexPath.section == 1)) {
        if (contactNumber.length) {
            
            cell.iconTxT.text = contactNumber;
            [cell.iconTxT sizeToFit];

        }
        else{
            cell.iconTxT.text =row2Array[indexPath.row];//[[NSUserDefaults standardUserDefaults]valueForKey:@"Profilebio"];;
            cell.iconTxT.textColor = [UIColor lightGrayColor];
        }
        //cell.iconTxT.backgroundColor = [UIColor redColor];
    }
    else if ((indexPath.row == 1)&&(indexPath.section == 1))
    {
        if (contactEmail) {
            cell.iconTxT.text = contactEmail;
        }
        else
        {  cell.iconTxT.text =row2Array[indexPath.row];
           cell.iconTxT.textColor = [UIColor lightGrayColor];
        }
        cell.iconTxT.keyboardType = UIKeyboardTypeEmailAddress;
    }
    else
    {
        cell.iconTxT.keyboardType = UIKeyboardTypeDefault;
        cell.iconTxT.returnKeyType = UIReturnKeyNext;
    }
       
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section ==1 && indexPath.row ==0) {
        //UpdatePhoneNumberVC
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UpdatePhoneNumberVC *newView = [storyboard instantiateViewControllerWithIdentifier:@"UpdatePhoneNumberVC"];
        [self.navigationController pushViewController:newView animated:YES];
    }
    
   }

-(void)addAddress:(id)sender {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PickAddressFromMapViewController *newView = [storyboard instantiateViewControllerWithIdentifier:@"pickAddressPG"];
    newView.currentLocation = currentLocation;
    [self.navigationController pushViewController:newView animated:YES];
}




-(void)resizeCell:(UITextView*)txtView
{
    height = txtView.contentSize.height;
}

#pragma mark - UITextView Delegrate

- (void)textViewDidChange:(UITextView *)textView{
    
    if ([textView.text isEqualToString:@"\n"]) {
        textView.text = @"";
    }
    
    NSIndexPath *indexPathForTextView = [detailTableView indexPathForCell:(businessSetupTableViewCell *)[[textView superview]superview]];
    if ((indexPathForTextView.section == 0) && (indexPathForTextView.row == 3)) {
       
        CGFloat fixedWidth = textView.frame.size.width;
        CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
        CGRect newFrame = textView.frame;
        newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
        textView.frame = newFrame;
        bio = textView.text;
        bioHeight = textView.contentSize;
        [detailTableView beginUpdates];
        [detailTableView endUpdates];
        
    }

}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    BOOL flag = NO;
    [self viewMoveUp];
   NSArray *defaultArray = [[NSArray alloc] initWithObjects:@"Business Name",@"Phone Number",@"Email",@"Address",@"Website URL",@"About Business",nil];
    for (int i = 0;i<defaultArray.count;i++) {
        if ([textView.text isEqualToString:defaultArray[i]]) {
            flag = YES;
         }
    }
    if (flag == YES) {
        textView.text = @"";
        
    }
        //optional
    textView.textColor = [UIColor blackColor];
    if (textView.tag == 4) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UpdatePhoneNumberVC *newView = [storyboard instantiateViewControllerWithIdentifier:@"UpdatePhoneNumberVC"];
        newView.controllerName = @"businessSetup";
        self.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:newView animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView
{

    [self hidekeyb:textView];
    if (textView.tag == 0) {
        if ([textView.text  isEqualToString:@""]) {
            textView.text = row1Array[textView.tag];
            textView.textColor = [UIColor lightGrayColor];
        }
        else
            profileName = textView.text;
    }
    if (textView.tag == 3) {
        if ([textView.text  isEqualToString:@""]) {
            textView.text = row1Array[textView.tag];
            textView.textColor = [UIColor lightGrayColor];
        }
    }
    //Website
    if (textView.tag == 2) {
        if ([textView.text  isEqualToString:@""]) {
            textView.text = row1Array[textView.tag];
            textView.textColor = [UIColor lightGrayColor];
        }
    }
    if (textView.tag == 4) {
        if ([textView.text  isEqualToString:@""]) {
            textView.text = row2Array[0];
            textView.textColor = [UIColor lightGrayColor];
        }
    }
    if (textView.tag == 5) {
        if ([textView.text  isEqualToString:@""]) {
            textView.text = row2Array[1];
            textView.textColor = [UIColor lightGrayColor];
        }
    }
    
    [self.view endEditing:YES];
    
    CGFloat tableViewHeight = detailTableView.contentSize.height;  //detailTableView.bounds.size.height;
     basescrollview.contentSize = CGSizeMake(w,tableViewHeight+260);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSInteger nextTag;
//    if (textView.tag == 0) {
//        nextTag = textView.tag + 1;
//    }
//    else
        nextTag = textView.tag + 1;
    
    // Try to find next responder
    UIResponder* nextResponder = [textView.superview.superview.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        if ([text isEqualToString:@"\n"]) {
            if (nextTag == 4 || textView.tag == 0) {
                if (textView.tag == 0) {
                    profileName = textView.text;
                }
                [self hidekeyb:textView];
                //[textView resignFirstResponder];
                return NO;
            }
            else
            [nextResponder becomeFirstResponder];
        }
            
    } else
    {// Not found, so remove keyboard.
        if ([text isEqualToString:@"\n"]) {
            [self hidekeyb:textView];
            //[textView resignFirstResponder];
        }
    }
 
    
    
    return YES;
}


-(void) askforpermissiontoenablelocation
{
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [locationManager requestWhenInUseAuthorization];
         [self GetTheUserCurrentLocation];
    }
    
    if ( [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self showAlert];
    }
    else
    {
        //get the user current location.
        [self GetTheUserCurrentLocation];
    }
}


-(void)showAlert {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled!"
                                                        message:@"Please enable Location Based Services for better results! We promise to keep your location private"
                                                       delegate:self
                                              cancelButtonTitle:@"Settings"
                                              otherButtonTitles:@"Cancel", nil];
    
    
    //TODO if user has not given permission to device
    if (![CLLocationManager locationServicesEnabled])
    {
        alertView.tag = 100;
    }
    //TODO if user has not given permission to particular app
    else
    {
        alertView.tag = 200;
    }
    
    [alertView show];
    
    return;
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0)//Settings button pressed
    {
        if (alertView.tag == 100)
        {
            //This will open ios devices location settings
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
        }
        else if (alertView.tag == 200)
        {
            //This will opne particular app location settings
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
    else if(buttonIndex == 1)//Cancel button pressed.
    {
        //TODO for cancel
    }
}

-(void)GetTheUserCurrentLocation {
    if ([CLLocationManager locationServicesEnabled ]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
         locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
   // [errorAlert show];
}



- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        lattitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
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
             address = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                   placemark.thoroughfare,placemark.subLocality,
                                  placemark.locality,placemark.postalCode,
                                  placemark.administrativeArea,
                                  placemark.country];
             
             NSLog(@"user location %@",address);
             
             [[NSUserDefaults standardUserDefaults]setObject:address forKey:@"address"];
             [[NSUserDefaults standardUserDefaults]synchronize];
             
             NSIndexPath *index = [NSIndexPath indexPathForRow:1 inSection:0];
             NSArray *arr = [NSArray arrayWithObject:index];
             [detailTableView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationNone];             //[detailTableView reloadData];
             
         }
         else
         {
             NSLog(@"%@", error.debugDescription);
         }
     } ];
}

-(void)dismiss
{
    [self.view endEditing:YES];
    CGRect frame = self.view.frame;
    [UIView animateWithDuration:0.0 delay:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
    } completion:^(BOOL finished) {
        [self.view setFrame:CGRectMake (frame.origin.x,
                                        0,
                                        frame.size.width,
                                        frame.size.height)];
    }];
}


/*
 * Method to Request Own Activities
 *
 */
-(void)sendUpdateBusinessProfile
{
    UITextField * textField = (UITextField *)[detailTableView viewWithTag:2];
    UITextView * aboutBusinesstextField = (UITextView *)[detailTableView viewWithTag:3];
    if ([self validaingDetails]) {
        if (lattitude == nil) {
            lattitude = @"13.0223";
            longitude = @"77.5949";
        }
      
        ProgressIndicator *pi = [ProgressIndicator sharedInstance];
        [pi showMessage:@"Creating business Profile.." On:self.view];
        
    if ((lattitude.length)&&(longitude.length)&&(address != nil)){
        NSDictionary *requestDict = @{
                                      mauthToken            :flStrForObj([Helper userToken]),
                                      mbusinessName         :flStrForObj(profileName),
                                      maboutBusiness        :flStrForObj(aboutBusinesstextField.text),
                                      mlocation             :address,
                                      mlatitude             :lattitude,
                                      mlongitude            :longitude,
                                      mwebsite              :textField.text,
                                      mphoneNumber          :flStrForObj(myString),
                                    };
        
        [WebServiceHandler updradeToBusniessProfile:requestDict andDelegate:self];
    
    }
    else
    {
        [[ProgressIndicator sharedInstance]hideProgressIndicator];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                        message:@"Incomplete information to create profile"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
    }
    }
}


- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    
     
    if (error) {
        
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        
              
        return;
    }
    
    
    NSDictionary *responseDict = (NSDictionary*)response;
    
    if (requestType == RequestTypeGetupdradeToBusniessProfile ) {
        
        
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                ProgressIndicator *pi = [ProgressIndicator sharedInstance];
                [pi hideProgressIndicator];

                
                NSString *type =@"1";
                [[NSUserDefaults standardUserDefaults] setValue:type forKey:@"BussinessAccountStatus" ];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                NSDictionary *dataForBussiness = responseDict[@"result"][0];
                NSData *dataSaveForBussiness = [NSKeyedArchiver archivedDataWithRootObject:dataForBussiness];
                
                [[NSUserDefaults standardUserDefaults] setObject:dataSaveForBussiness forKey:userDetailForBussiness];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSLog(@"Response From Following Activity:%@",responseDict);
                NSLog(@"gotData:%@",responseDict[@"data"]);
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                 [self popToBaseController];
                }
                break;
                //failure responses.
            case 2021: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 2022: {
                [self errorAlert:responseDict[@"message"]];
                
            }
                break;
            default:
                break;
        }
    }
    
    
}

- (void)errorAlert:(NSString *)message {
    //showing error alert for failure response.
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];//Send via SMS
    [alert show];
        
}


-(BOOL)validaingDetails
{
    UITextView * textField = (UITextView *)[detailTableView viewWithTag:3];
    NSLog(@"textField:%@",textField.text);
    
    UITextView * numtextField = (UITextView *)[detailTableView viewWithTag:4];
    myString = numtextField.text;
    myString = [myString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    UITextView * webUrll =   (UITextView *)[detailTableView viewWithTag:2];
    UITextView * email =   (UITextView *)[detailTableView viewWithTag:5];
    if ([flStrForObj(webUrll.text) isEqualToString:@""])
    {
        [self errorAlert:@"Business Url missing"];
        return NO;
    }
    if ((profileName.length<1)||[profileName isEqualToString:@"Business Name"]) {
        [self errorAlert:@"Business Name is missing"];
        return NO;
    }
    if ([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"About Business"] ) {
        [self errorAlert:@"About Business is missing"];
        return NO;
    }
    
    else{
    
        BOOL trueUrl = [Helper validateUrl:flStrForObj(webUrll.text)];
        if (trueUrl) {
            if (![flStrForObj(email.text) isEqualToString:@""])
            {
                trueUrl =  [Helper emailValidationCheck:flStrForObj(email.text)];
                if (!trueUrl)
                { [self errorAlert:@"Invalid Email Address"];
                    return trueUrl;
                }
            }
            if (![flStrForObj(myString) isEqualToString:@""]) {
                trueUrl = YES;
                return trueUrl;
                
            }
            else
                [self errorAlert:@"Contact Number Missing"];
        }
        else
            [self errorAlert:@"Invalid WebUrl"];
        return trueUrl;
    }
    return NO;
}


-(void)popToBaseController
{
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[UserProfileViewController class]]) {
                    [UIView transitionWithView:self.view.window
                                  duration:1.0f
                                   options:UIViewAnimationOptionTransitionCurlUp
                                animations:^{
                                    // self.tabBarController.hidesBottomBarWhenPushed = NO;
                                    self.tabBarController.hidesBottomBarWhenPushed = NO;
                                    [self.navigationController.navigationBar setHidden:NO];
                                    [self.navigationController popToViewController:controller
                                                                          animated:NO];
                                    
                                    
                                }
                                    completion:^(BOOL finished){
                                        [Helper showAlertWithTitle:@"Welcome" Message:@"Your Business profile is now active on your Picogram profile,hope you grow your business on Picogram "];
                                    }];
                break;
            }
    }
}

  /*  for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[UserProfileViewController class]]) {
            //Do not forget to import AnOldViewController.h
            //self.tabBarController.hidesBottomBarWhenPushed = NO;
            
            if (_fromController) {
                [UIView transitionWithView:self.view.window
                                  duration:1.0f
                                   options:UIViewAnimationOptionTransitionCurlUp
                                animations:^{
                                    // self.tabBarController.hidesBottomBarWhenPushed = NO;
                                    self.tabBarController.hidesBottomBarWhenPushed = NO;
                                    [self.navigationController.navigationBar setHidden:NO];
                                    [self.navigationController popToViewController:controller
                                                                          animated:NO];
                                    
                                    
                                }
                                completion:NULL];
                break;
            }else
            {
                [self popToOptionView];
                
//                // self.hidesBottomBarWhenPushed = NO;
//                [self.navigationController.navigationBar setHidden:NO];
//                [self.navigationController popToViewController:controller
//                                                      animated:YES];
//                //self.hidesBottomBarWhenPushed = NO;
//                break;
            }
        }
    }
}*/





- (void)keyboardDidShow:(NSNotification *)notification
{
   
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
    [self viewMoveUp];
    
}

-(void)viewMoveUp {
    
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.view setFrame:CGRectMake(0,-250,w,h)];
                         //[self.view layoutIfNeeded];
                     }];
}


-(void)keyboardDidHide:(NSNotification *)notification
{
    

   
}

-(void)hidekeyb:(UITextView *)text{
    [UIView animateWithDuration:0.2
animations:^{
    [self.view setFrame:CGRectMake(0,0,w,h)];
    [text resignFirstResponder];
    //[self.view layoutIfNeeded];
}];

}
@end
