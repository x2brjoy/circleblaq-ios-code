//
//  ShareViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/16/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGShareViewController.h"
#import "PGTagPeopleViewController.h"
#import "selectPostAsTableViewController.h"
#import "PGLocationViewController.h"
#import "PGPlacesViewController.h"
#import "CameraViewController.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "ProgressIndicator.h"
#import "FullImageViewXib.h"
#import "ListOfTagFriendsTableViewCell.h"
#import "HomeViewController.h"
#import "NearByPlacesCollectionViewCell.h"
#import "FSConverter.h"
#import "FSVenue.h"
#import "PGTagPeopleViewController.h"
#import "TinderGenericUtility.h"
#import "FontDetailsClass.h"
#import "AppDelegate.h"
#import "HomeViewController.h"
#import "Helper.h"
#import <CoreText/CTStringAttributes.h>
#import "UITextView+Placeholder.h"
#import "SaloonInfoViewController.h"

@interface PGShareViewController ()<CLLocationManagerDelegate,MKMapViewDelegate,UIGestureRecognizerDelegate,WebServiceHandlerDelegate,UITableViewDataSource,UINavigationControllerDelegate,UINavigationBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UITextViewDelegate,UITextFieldDelegate,saloonDetailsEnteredDelegate> {
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    float h;
    FullImageViewXib *fullimageViewNib;
    
    NSString *thumbNailUrl;
    NSString *mainUrl;
    NSString *lastString;
    NSString *searchResultsFor;
    NSString *VideoUrl;
    NSString *thumbimageforvideourl;
    
    BOOL _isSearching;
    
    int keyboardH;
    
    NSArray *hashTagresponseData;
    NSMutableArray *userNmaeresponseData;
    NSMutableArray *stringsSeparatedBySpace;
    NSMutableArray *listOfHashTags;
    NSMutableArray *listOfCountForhashTag;
    NSDictionary *hashTagsData;
    NSDictionary *tagFriendsData;
    NSMutableArray *arrayOfHashTags;
    NSMutableArray *arrayOfHashtagCount;
    NSMutableArray *arrayOfUserNames;
    NSMutableArray *taggedFriendsArray;
    NSMutableArray *taggedFriendPositions;
    NSMutableArray *arrayOfFullNames;
    NSMutableArray *arrayOfProfilePicUrl;
    
    
    BOOL showTableViewHeader;
    BOOL isValidForTagFriends;
    BOOL isValidForHashTags;
    BOOL showOnlyHashTagResults;
    BOOL showOnlyTagFriendsResults;
    
    UIButton *navCancelButton;
    
    UIButton *navShareButton;
    
    NSDictionary *cloundinaryCreditinals;
    NSString *uploadType;
    NSString *placelongitude;
    NSString *placelatitude;
    double latInDouble;
    double longInDouble;
    NSArray *list;
    NearByPlacesCollectionViewCell *collectionViewCell;
    UIButton *subCategorybtn;
    NSString *str;
    // for new
    NSString *taggedFriendsString;
    int selectedType;
    NSString *hashTagsInLowerCase,*posttypeSelect;
    UISegmentedControl *postType;
    //UITextView *pricetext,*purchaselikeTF;
    UITextField *priceTextField,*purchaseLinkTextField;
    UIView *businessPostView, *productCategoryView, *prodSubCategoryView, *currencyView, *price ,*PurchaseLink,*nextView2,*PurchaseLinkLine,*priceLine,*currencyLblLine,*prodLine,*subProdLine,*postAsTopLine, *postAsBottomLine;
    UILabel *postTypeLbl,*categoryLbl,*subCateLbl,*currencyRLbl,*priceNLbl,*prodSubLbl;
    NSArray *subCatArray;
    CGFloat *businessViewHeight;
    BOOL fromGalary;
    
    NSString *tagFirendLocation;
    
}

@end

@implementation PGShareViewController


#define kGOOGLE_API_KEY @"AIzaSyCizq7QvPED3UkztXhCs1BTqyyFoRWRYWI"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

/*--------------------------------------*/
#pragma mark
#pragma mark - viewcontroller
/*--------------------------------------*/

- (void)viewDidLoad {
    [super viewDidLoad];
    h = self.view.frame.size.height;
    fromGalary = YES;
    
    
    
    NSString *bussinessStatus = [Helper bussinessAccountStatus];
    if ([bussinessStatus isEqualToString:@"1"]) {
        
//    if ([Helper isBusinessAccount]) {
        str = @"business";
    }
    
    uploadType = @"business";
    list = [[NSArray alloc]initWithObjects:@"Category",@"Sub-category",@"Currency", nil];
    _PlacesSuggestionViewHeightConstraint.constant = 0;
    _socialMediaViewTopConstraint.constant = 10;
    self.baseScrollview.delaysContentTouches = NO;
    self.baseScrollview.userInteractionEnabled = YES;
    
    self.tappedImageView.hidden = YES;
    
    self.captionTextViewOutlet.placeholder = @"Write a caption..";
    self.captionTextViewOutlet.text =@"";
    self.captionTextViewOutlet.placeholderColor = [UIColor lightGrayColor];
    self.captionTextViewOutlet.textColor = [UIColor blackColor];
    
    [self changeTheHeightOfTextView];
    
    [self askforpermissiontoenablelocation];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9606 green:0.9605 blue:0.9605 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    //get the user current location.
    //[self GetTheUserCurrentLocation];
    
    // creating tap gesture for tag the people (whenever user clicks on tap to tagImage this reconiger will reconige the tap.)
    [self creatingTapGestureReconigerForTagThePeople];
    
    // creating tap gesture for profile image(whenever user clicks on tap profile image this reconiger will reconige the tap.)
    [self creatingTapGestureReconigerToSeeFullProfileImageView];
    
    //creating tap gesture for keyBoard dismissal(whenever user clicks outside of textfiled/textView this reconiger will reconige the tap.)
    [self creatingTapGestureForDismissingKeyBoard];
    
    //creating navbar  buttons.
    [self createNavLeftButton];
    
    [self createNavRightButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    //getting data(image or video) from previous view controller.
    [self gettingProfileImageFromCamera];
    self.navigationController.delegate = self;
    cloundinaryCreditinals =[[NSUserDefaults standardUserDefaults]objectForKey:cloudinartyDetails];
    
    
    if(_recordsession ||_pathOfVideo) {
        self.dividerOnTagPeopleView.backgroundColor = [UIColor clearColor];
        self.tagPeopleButtonOutlet.enabled = NO;
        self.tagPeopleViewHeightConstraint.constant =0;
        [self.tagPeopleButtonOutlet setTitle:@"" forState:UIControlStateNormal];
    }
    else {
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbNotification:)
                                                 name:@"facebookCancel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twitterNotification:)
                                                 name:@"TwitterLoginFailed" object:nil];
    
    
}

- (void)keyBoardWillDismiss:(NSNotification*)notification {
    
}

- (void)viewWillAppear:(BOOL)animated {
    
}

-(void)saloondetalis:(NSString *)nameOfSaloon address:(NSString *)addressOfSaloon caption:(NSString *)caption {
    purchaseLinkTextField.text = nameOfSaloon;
}

-(void)openPurchaseLinkVc {
    
     //  [self performSegueWithIdentifier:@"shareToProductLinkSegue" sender:nil];
    
    if (keyboardH <10) {
        //keyboard is opened
         [self performSegueWithIdentifier:@"shareToProductLinkSegue" sender:nil];
    }
    else {
        //keyboard is closed
        [UIView animateWithDuration:0.2 animations: ^{
            CGRect frame = self.view.bounds;
            frame.origin.y = 40;
            self.view.frame = frame;
            [self.view layoutIfNeeded];
            
            [purchaseLinkTextField endEditing:YES];
            [priceTextField endEditing:YES];
        } completion:^(BOOL finished) {
          [self performSegueWithIdentifier:@"shareToProductLinkSegue" sender:nil];
        }];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == purchaseLinkTextField) {
        [self openPurchaseLinkVc];
        return NO;
    }
    return YES;
}

#pragma mark
#pragma mark - navigation bar next button

- (void)createNavRightButton {
    
    navShareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navShareButton setTitle:@"Share"
                    forState:UIControlStateNormal];
    [navShareButton setTitleColor:[UIColor colorWithRed:56/255.0f green:121/255.0f blue:240/255.0f alpha:1.0]
                         forState:UIControlStateNormal];
    
    navShareButton.titleLabel.font = [UIFont fontWithName:RobotoMedium size:18];
    [navShareButton setFrame:CGRectMake(0,0,50,30)];
    [navShareButton addTarget:self action:@selector(navshareButtonAction:)
             forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navShareButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}


-(void)OKButtonAction:(id)sender {
    [self.captionTextViewOutlet resignFirstResponder];
}

- (void)navshareButtonAction:(UIButton *)sender {
    
    
    NSString *titleOfShareButton = [navShareButton titleForState:UIControlStateNormal];
    //[self.view endEditing:YES];
    if ([titleOfShareButton isEqualToString:@"Ok"]) {
        if ([uploadType isEqualToString:@"Individual"]) {
            [self.captionTextViewOutlet resignFirstResponder];
        }else
        {
            postType.hidden = NO;
            businessPostView.hidden = NO;
            postTypeLbl.hidden = NO;
            postAsBottomLine.hidden = NO;
            postAsTopLine.hidden = NO;
            [self.captionTextViewOutlet resignFirstResponder];
        }
    }
    else {
        // posting video  api requesting.
        NSArray * words = [self.captionTextViewOutlet.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        NSMutableArray *WordsForUsertagged = [NSMutableArray new];
        for (NSString * word in words){
            if ([word length] > 1 && [word characterAtIndex:0] == '@'){
                NSString * editedWord = [word substringFromIndex:1];
                [WordsForUsertagged addObject:editedWord];
            }
        }
        
        NSMutableArray *WordsForHashTags = [NSMutableArray new];
        for (NSString * word in words){
            if ([word length] > 1 && [word characterAtIndex:0] == '#'){
                NSString * editedWord = [word substringFromIndex:1];
                [WordsForHashTags addObject:editedWord];
            }
        }
        taggedFriendsString = [[taggedFriendsArray valueForKey:@"description"] componentsJoinedByString:@","];
        NSString *hashTagsString = [[WordsForHashTags valueForKey:@"description"] componentsJoinedByString:@","];
        hashTagsInLowerCase = [hashTagsString lowercaseString];
        tagFirendLocation = [[taggedFriendPositions valueForKey:@"description"] componentsJoinedByString:@",,"];
        
       
        if (!taggedFriendsString) {
            taggedFriendsString = @"";
            tagFirendLocation =@"";
        }
        NSString *bussinessStatus = [Helper bussinessAccountStatus];
        if ([bussinessStatus isEqualToString:@"1"]) {
            
//        if ([Helper isBusinessAccount]) {
            BOOL validurl;
            validurl = YES;
            if (flStrForObj(purchaseLinkTextField.text)) {
                validurl = [Helper validateUrl:flStrForObj(purchaseLinkTextField.text)];
            }
            
            
            //just move to home screen.
            if(![uploadType isEqualToString:@"Individual"]){
                    if (validurl) {
                        if(categoryLbl.text.length>1)
                        {
                            if ([priceTextField.text isEqualToString:@""]) {
                                [self showErrorAlert:@"Error" Message:@"Please enter Price"];
                            }
                            else
                            {
                                NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"$₹"];
                                NSString *priceText = priceTextField.text;
                                priceText = [[priceText componentsSeparatedByCharactersInSet:set]
                                             componentsJoinedByString:@""];
                                NSUInteger i = [priceText rangeOfCharacterFromSet: [ [NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet] ].location;
                                
                                if (i == NSNotFound) {
                                    [self performSegueWithIdentifier:@"shareTohomeTab" sender:nil];
                                }
                                else
                                    [self showErrorAlert:@"Error" Message:@"Invalid Price"];
                             
                            }
                        }
                        else
                            [self showErrorAlert:@"Error" Message:@"Select Product Category"];
                    }
                    else
                        [self showErrorAlert:@"Error" Message:@"Invalid Purchase link"];
                }
                else
                    [self performSegueWithIdentifier:@"shareTohomeTab" sender:nil];
            }
            else
        {
            uploadType = @"Individual";
            [self performSegueWithIdentifier:@"shareTohomeTab" sender:nil];
        }
    }
}

-(void)showErrorAlert:(NSString *)title Message:(NSString *)Message {
    
    [UIView animateWithDuration:0.5 animations: ^{
        CGRect frame = self.view.bounds;
        frame.origin.y = 40;
        self.view.frame = frame;
        [self.view layoutIfNeeded];
        [purchaseLinkTextField endEditing:YES];
        [priceTextField endEditing:YES];
        
    } completion:^(BOOL finished) {
        [Helper showAlertWithTitle:@"Error" Message:Message];
    }];
}

-(void)viewDidAppear:(BOOL)animated {
    if(_locationLabelOutlet.text.length !=0) {
        _addLocationButtonOutlet.titleLabel.text =@"";
        _PlacesSuggestionViewHeightConstraint.constant = 50;
        [UIView animateWithDuration:0.5 animations:^{
            _PlacesSuggestionViewHeightConstraint.constant = 0;
            [self.view layoutIfNeeded];
        }];
        _socialMediaViewTopConstraint.constant = 10;
    }
    else {
        _addLocationButtonOutlet.titleLabel.text =@"Add Location";
    }
    //hiding navigation bar rightbutton intially.
    
    [navShareButton setTitle:@"Share"
                    forState:UIControlStateNormal];
    
    
    if (fromGalary) {
        
        if ([str isEqualToString:@"business"]) {
            float w = [[UIScreen mainScreen]bounds].size.width;
            float hh = [[UIScreen mainScreen]bounds].size.height;
            [self createBusinessPost];
            [self.baseScrollview setScrollEnabled:YES];
            [self.baseScrollview setContentSize:CGSizeMake(w, hh+ 160)];
            fromGalary = NO;
        }
    }
}

/*---------------------------------------------------*/
#pragma mark
#pragma mark - heightOfTextView.
/*--------------------------------------------------*/

-(void) changeTheHeightOfTextView {
    //if the device is 4s then textview height will change.
    if(CGRectGetHeight(self.view.frame) == 480 ) {
        _textViewHeightOUtletConstraint.constant=75;
    }
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

/*--------------------------------------*/
#pragma mark
#pragma mark - heightOfSearchView.
/*--------------------------------------*/

-(void)settingSearchViewHeight {
    //height of searchViewHeight is vary for every device.
    self.searchViewHeightConstraint.constant =self.view.frame.size.height -CGRectGetHeight(self.captionTextViewOutlet.frame) -CGRectGetHeight(self.navigationController.navigationBar.frame)-keyboardH +30;
}

/*-----------------------------------------------*/
#pragma mark
#pragma mark - heightOfKeyBoard.
/*-----------------------------------------------*/

- (void)keyboardWillShown:(NSNotification*)notification {
    // Get the size of the keyboard.
    CGSize keyboard = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //Given size may not account for screen rotation
    keyboardH = MIN(keyboard.height,keyboard.width);
}

- (void)keyboardWillHide:(NSNotification*)notification {
    keyboardH = 0;
}
/*--------------------------------------*/
#pragma mark
#pragma mark - share image.
/*--------------------------------------*/
-(void)gettingProfileImageFromCamera {
    if (_recordsession || _pathOfVideo) {
        _shareImageOutlet.image = self.videoimg;
    }
    else {
        _shareImageOutlet.image =_image2;
        self.highlatedImageView.image = _shareImageOutlet.image;
    }
}

/*--------------------------------------*/
#pragma mark
#pragma mark - tapGesture.
/*--------------------------------------*/
-(void)creatingTapGestureForDismissingKeyBoard {
    //adding tapGesture for view(transperent view) for dismissing keyBoard.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)];
    tap.delegate = self;
    [self.viewForDismissKeyBoard addGestureRecognizer:tap];
}

-(void)creatingTapGestureReconigerForTagThePeople {
    UITapGestureRecognizer *tapForremoveView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapForRemoveimageview:)];
    tapForremoveView.numberOfTapsRequired = 1;
    tapForremoveView.delegate = self;
    [self.tappedImageView addGestureRecognizer:tapForremoveView];
}

-(void)creatingTapGestureReconigerToSeeFullProfileImageView {
    UITapGestureRecognizer *tapForProfileImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapForRemoveTaggedPerson:)];
    tapForProfileImage.numberOfTapsRequired = 1;
    tapForProfileImage.delegate = self;
    self.shareImageOutlet.userInteractionEnabled = YES;
    [self.shareImageOutlet addGestureRecognizer:tapForProfileImage];
}

/*--------------------------------------*/
#pragma mark
#pragma mark - handling tapGestures.
/*--------------------------------------*/

-(void)handletapForRemoveimageview:(id)sender {
    self.tappedImageView.hidden = YES;
    self.baseScrollView.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
}

-(void)handletapForRemoveTaggedPerson:(id)sender {
    
    if (_recordsession || _pathOfVideo) {
        [self.captionTextViewOutlet resignFirstResponder];
        if (_recordsession) {
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            fullimageViewNib = [[FullImageViewXib alloc] init];
            [fullimageViewNib PlayVideo:_recordsession onWindow:window];
        }
    }
    else {
        [self.captionTextViewOutlet resignFirstResponder];
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        fullimageViewNib = [[FullImageViewXib alloc] init];
        [fullimageViewNib showFullImage:_shareImageOutlet.image onWindow:window];
    }
}

- (void)dismissKeyboard:(id)sender {
    UIView *selectedView = [sender view];
    if ([selectedView.subviews isKindOfClass:[UITableView class]]) {
    }
    else {
        /**
         *  methdos used to dismiss key board.
         */
        if([uploadType isEqualToString:@"business"])
        { postType.hidden = NO;
            businessPostView.hidden = NO;
            postTypeLbl.hidden = NO;
            postAsBottomLine.hidden = NO;
            postAsTopLine.hidden = NO;
        }
        [self.captionTextViewOutlet resignFirstResponder];
    }
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}
-(void)dismissKeyboard {
    /**
     *  methdos used to dismiss key board.
     */
    [self.captionTextViewOutlet resignFirstResponder];
}

/*--------------------------------------*/
#pragma mark -
#pragma mark -ButtonActions
/*--------------------------------------*/


- (IBAction)addLocationButtonAction:(id)sender {
    if (keyboardH <10) {
        //keyboard is opened
         [self performSegueWithIdentifier:@"gettingLocationSegue" sender:nil];
    }
    else {
        //keyboard is closed
        [UIView animateWithDuration:0.2 animations: ^{
            CGRect frame = self.view.bounds;
            frame.origin.y = 40;
            self.view.frame = frame;
            [self.view layoutIfNeeded];
            
            [purchaseLinkTextField endEditing:YES];
            [priceTextField endEditing:YES];
        } completion:^(BOOL finished) {
                [self performSegueWithIdentifier:@"gettingLocationSegue" sender:nil];
        }];
    }
}

- (IBAction)loactionCancelButtonAction:(id)sender {
    
    [self.addLocationButtonOutlet setTitle:@"Add Location" forState:UIControlStateNormal];
    _addLocationButtonOutlet.imageView.image =[UIImage imageNamed:@"share_to_location_grey_icon"];
    _locationLabelOutlet.text =@"";
    _distanceFromLocationOutlet.text=@"";
    _locationCancelImgaeOutlet.image=nil;
    _PlacesSuggestionViewHeightConstraint.constant =0;
    [UIView animateWithDuration:0.5 animations:^{
        _PlacesSuggestionViewHeightConstraint.constant = 50;
        [self.view layoutIfNeeded];
    }];
    _socialMediaViewTopConstraint.constant = 0;
    _addLocationButtonOutlet.userInteractionEnabled = YES;
}

- (IBAction)tagPeopleButtonAction:(id)sender {
    
    if (keyboardH <10) {
        //keyboard is opened
         [self performSegueWithIdentifier:@"TagPeopleSegue" sender:nil];
    }
    else {
        //keyboard is closed
        [UIView animateWithDuration:0.2 animations: ^{
            CGRect frame = self.view.bounds;
            frame.origin.y = 40;
            self.view.frame = frame;
            [self.view layoutIfNeeded];
            
            [purchaseLinkTextField endEditing:YES];
            [priceTextField endEditing:YES];
        } completion:^(BOOL finished) {
             [self performSegueWithIdentifier:@"TagPeopleSegue" sender:nil];
        }];
    }
}

/*----------------------------------------*/
#pragma mark - cloudinary delegate
/*----------------------------------------*/

- (void) uploaderSuccess:(NSDictionary*)result context:(id)context {
    NSString* publicId = [result valueForKey:@"public_id"];
    NSLog(@"Upload success. Public ID=%@, Full result=%@", publicId, result);
    
    if (_pathOfVideo) {
        //video url.
        VideoUrl = result[@"url"];
        NSString *str = VideoUrl;
        
        //getting thumbnailimage from video(just we need to change format of url .mov to .png).
        str = [str stringByReplacingOccurrencesOfString:@".mov"
                                             withString:@".jpeg"];
        thumbimageforvideourl = str;
        if (VideoUrl) {
            [self requestForpostingVideo];
        }
    }
    
    else {
        NSString *heightOfImage =result[@"height"];
        NSString *heightOfImageInString = [NSString stringWithFormat:@"%@",heightOfImage];
        
        if ([heightOfImageInString isEqualToString:@"150"] || [heightOfImageInString isEqualToString:@"100"] ) {
            thumbNailUrl=result[@"url"];
        }
        else {
            mainUrl =result[@"url"];
        }
        if(mainUrl  && thumbNailUrl) {
            [self requestForpostingImage];
        }
    }
}

-(void) uploaderError:(NSString*)result code:(int) code context:(id)context {
    
    [[ProgressIndicator sharedInstance] hideProgressIndicator];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"failed to  post" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    NSLog(@"Upload error: %@, %d", result, code);
}


-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == priceTextField) {
        if (priceTextField.text.length ==0) {
            if (categoryLbl.text.length > 0) {
                if ([categoryLbl.text containsString:@"USD"]) {
                    NSString *defaultPrice = @"$";
                    priceTextField.text = defaultPrice;
                }
                else if ([categoryLbl.text containsString:@"INR"]) {
                    NSString *defaultPrice = @"₹";
                    priceTextField.text = defaultPrice;
                }
            }
            else {
                NSString *defaultPrice = @"";
                priceTextField.text = defaultPrice;
            }
        }
    }
    else if (textField == purchaseLinkTextField)
    {
        if (purchaseLinkTextField.text.length ==0) {
            NSString *defaultPrice = @"http://www.";
            purchaseLinkTextField.text = defaultPrice;
        }
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = self.view.bounds;
        frame.origin.y = 40;
        self.view.frame = frame;
    }];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
//    if (textField == priceTextField) {
//        if (priceTextField.text.length ==0) {
//            if (categoryLbl.text.length >2) {
//                
//            }
//            else {
//                NSString *defaultPrice = @"USD  ";
//                priceTextField.text = defaultPrice;
//            }
//        }
//    }
//    else if (textField == purchaseLinkTextField)
//    {
//        if (purchaseLinkTextField.text.length ==0) {
//            NSString *defaultPrice = @"https://www.";
//            purchaseLinkTextField.text = defaultPrice;
//        }
//    }
    
    if (textField == priceTextField) {
        if (priceTextField.text.length == 0) {
            if (currencyRLbl.text.length > 0) {
                if ([currencyRLbl.text containsString:@"USD"]) {
                    NSString *defaultPrice = @"$";
                    priceTextField.text = defaultPrice;
                }
                else if ([currencyRLbl.text containsString:@"INR"]) {
                    NSString *defaultPrice = @"₹";
                    priceTextField.text = defaultPrice;
                }
            }
            else {
                NSString *defaultPrice = @"";
                priceTextField.text = defaultPrice;
            }
        }
    }
    else if (textField == purchaseLinkTextField)
    {
        if (purchaseLinkTextField.text.length ==0) {
            NSString *defaultPrice = @"http://www.";
            purchaseLinkTextField.text = defaultPrice;
        }
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = self.view.bounds;
        frame.origin.y = - 70;
        self.view.frame = frame;
    }];
}


-(void)requestForpostingImage {
    // login api requesting.
    NSArray * words = [self.captionTextViewOutlet.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableArray *WordsForUsertagged = [NSMutableArray new];
    
    for (NSString * word in words){
        if ([word length] > 1 && [word characterAtIndex:0] == '@'){
            NSString * editedWord = [word substringFromIndex:1];
            [WordsForUsertagged addObject:editedWord];
        }
    }
  
    NSMutableArray *WordsForHashTags = [NSMutableArray new];
    for (NSString * word in words){
        if ([word length] > 1 && [word characterAtIndex:0] == '#'){
            NSString * editedWord = [word substringFromIndex:1];
            [WordsForHashTags addObject:editedWord];
        }
    }
    
    
    taggedFriendsString = [[taggedFriendsArray valueForKey:@"description"] componentsJoinedByString:@","];
    NSString *hashTagsString = [[WordsForHashTags valueForKey:@"description"] componentsJoinedByString:@","];
    hashTagsInLowerCase = [hashTagsString lowercaseString];
      tagFirendLocation = [[taggedFriendPositions valueForKey:@"description"] componentsJoinedByString:@",,"];
  
    if (!taggedFriendsString) {
        taggedFriendsString = @"";
         tagFirendLocation = @"";
    }
    NSDictionary *requestDict = @{mtype    :@"0",
                                  mmailUrl :mainUrl,
                                  mthumbeNailUrl :thumbNailUrl,
                                  mauthToken :flStrForObj([Helper userToken]),
                                  musersTagged:taggedFriendsString,
                                  @"taggedFriendStringPoistions":tagFirendLocation,
                                  mpostCaption : self.captionTextViewOutlet.text,
                                  mhashTags :hashTagsInLowerCase,
                                  mlocation :self.locationLabelOutlet.text,
                                  mlatitude:[NSNumber numberWithDouble:latInDouble],
                                  mlongitude:[NSNumber numberWithDouble:longInDouble]
                                  };
    [WebServiceHandler postImageOrVideo:requestDict andDelegate:self];
}

-(void)requestForpostingVideo {
    // posting video  api requesting.
    NSArray * words = [self.captionTextViewOutlet.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableArray *WordsForUsertagged = [NSMutableArray new];
    for (NSString * word in words){
        if ([word length] > 1 && [word characterAtIndex:0] == '@'){
            NSString * editedWord = [word substringFromIndex:1];
            [WordsForUsertagged addObject:editedWord];
        }
    }
    
    NSMutableArray *WordsForHashTags = [NSMutableArray new];
    for (NSString * word in words){
        if ([word length] > 1 && [word characterAtIndex:0] == '#'){
            NSString * editedWord = [word substringFromIndex:1];
            [WordsForHashTags addObject:editedWord];
        }
    }
    
    taggedFriendsString = [[taggedFriendsArray valueForKey:@"description"] componentsJoinedByString:@","];
    NSString *hashTagsString = [[WordsForHashTags valueForKey:@"description"] componentsJoinedByString:@","];
    hashTagsInLowerCase = [hashTagsString lowercaseString];

    tagFirendLocation = [[tagFirendLocation valueForKey:@"description"] componentsJoinedByString:@",,"];
    
   
    if (!taggedFriendsString) {
        taggedFriendsString = @"";
        tagFirendLocation = @"";
    }
    
    NSDictionary *requestDict = @{mtype    :@"1",
                                  mmailUrl :VideoUrl,
                                  mthumbeNailUrl :thumbimageforvideourl,
                                  mauthToken :flStrForObj([Helper userToken]),
                                  musersTagged:taggedFriendsString,
                                  @"taggedFriendStringPoistions":tagFirendLocation,
                                  mpostCaption : self.captionTextViewOutlet.text,
                                  mhashTags :hashTagsInLowerCase,
                                  mlocation :self.locationLabelOutlet.text,
                                  mlatitude:[NSNumber numberWithDouble:latInDouble],
                                  mlongitude:[NSNumber numberWithDouble:longInDouble]
                                  };
    [WebServiceHandler postImageOrVideo:requestDict andDelegate:self];
}

- (void) uploaderProgress:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite context:(id)context {
    NSLog(@"Upload progress: %ld/%ld (+%ld)", (long)totalBytesWritten, (long)totalBytesExpectedToWrite, (long)bytesWritten);
}

/*------------------------------------------------------------------------------*/
#pragma mark -
#pragma mark -  data reciving from places view controller.
/*-----------------------------------------------------------------------------*/

-(void)sendDataToA:(NSString *)myStringData and:(NSString *)addresss and:(NSString *)latitude and:(NSString *)longitude {
    
    
    [self.addLocationButtonOutlet setTitle:@"" forState:UIControlStateNormal];
    _addLocationButtonOutlet.imageView.image =[UIImage imageNamed:@"share_to_location_blue_icon"];
    if(myStringData.length >30) {
        //  _locationLabelHeightConstraint.constant=25;
    }
    _locationLabelOutlet.text =myStringData;
    placelatitude = latitude;
    placelongitude = longitude;
    
    latInDouble = [latitude doubleValue];
    longInDouble = [longitude doubleValue];
    
    NSString *distanceFromLocation = addresss;
    //[distance stringValue];
    _distanceFromLocationOutlet.text= distanceFromLocation;
    //[distanceFromLocation stringByAppendingString:@" meters away"];
    _locationCancelImgaeOutlet.image=[UIImage imageNamed:@"share_to_second_cancel_icon_off"];
    _addLocationButtonOutlet.userInteractionEnabled = NO;
}

-(void)sendDataToA:(NSMutableArray *)array andPositions:(NSMutableArray *)positionsArray {
    
    
    taggedFriendsArray = array;
    
    taggedFriendPositions = positionsArray;
    
    if (array.count == 0) {
        self.detailsOfTaggedFriendsLabelWidthContstraint.constant = 0;
        self.detailsOfTaggedFriendsLabel.text =@"";
    }
    else if (array.count  == 1 ) {
        NSString *nameOfTaggedPerson = [array objectAtIndex:0];
        self.detailsOfTaggedFriendsLabel.text = nameOfTaggedPerson;
    }
    else {
        NSString *numberOfFriendsTagged  = [[NSString stringWithFormat: @"%ld",(unsigned long)array.count] stringByAppendingString:@" PEOPLE"];
        self.detailsOfTaggedFriendsLabel.text = numberOfFriendsTagged;
    }
    
    if (self.detailsOfTaggedFriendsLabel.text.length >0) {
        
        self.tagPeopleButtonOutlet.selected = YES;
    }
    else
    {
        self.tagPeopleButtonOutlet.selected = NO;
    }
}

/*-------------------------------------*/
#pragma mark
#pragma mark - labelHeightDynamically.
/*------------------------------------*/

-(CGFloat )widthOfText:(UILabel *)label {
    
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.width = expectedLabelSize.width;
    label.frame = newFrame;
    CGFloat dynamicWidthOfLabel = newFrame.size.width;
    return dynamicWidthOfLabel;
}

-(NSInteger )collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    collectionViewCell.backgroundColor = [UIColor whiteColor];
    collectionViewCell.locationNameLabel.layer.cornerRadius = 5;
    collectionViewCell.locationNameLabel.clipsToBounds = YES;
    if (_isSearching) {
        // cell.textLabel.text = dict[@"description"];
        collectionViewCell.locationNameLabel.text = [_searchResults[indexPath.row] namE];
    }
    if (indexPath.row ==5 ) {
    }
    else {
    }
    return collectionViewCell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    _addLocationButtonOutlet.userInteractionEnabled = NO;
    [self.addLocationButtonOutlet setTitle:@"" forState:UIControlStateNormal];
    _addLocationButtonOutlet.imageView.image =[UIImage imageNamed:@"share_to_location_blue_icon"];
    _locationLabelOutlet.text = [_searchResults[indexPath.row] namE];
    _PlacesSuggestionViewHeightConstraint.constant = 50;
    [UIView animateWithDuration:0.5 animations:^{
        _PlacesSuggestionViewHeightConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
    _socialMediaViewTopConstraint.constant = 15;
    _locationCancelImgaeOutlet.image=[UIImage imageNamed:@"share_to_second_cancel_icon_off"];
    FSVenue *venue = _searchResults[indexPath.row];
    _distanceFromLocationOutlet.text =  [NSString stringWithFormat:@"%@ meters away",
                                         venue.location.distance];
    latInDouble = [[NSString stringWithFormat:@"%f", venue.location.coordinate.latitude] doubleValue];
    longInDouble = [[NSString stringWithFormat:@"%f", venue.location.coordinate.longitude] doubleValue];
}

-(void)MoveDownKeyBoardAfterPerformingSegue {
    [UIView animateWithDuration:0.1 animations:^{
        [priceTextField endEditing:YES];
    } completion:^(BOOL finished){
    }];
}

/*-------------------------------------------------*/
#pragma mark -
#pragma mark - prepareForSegue.
/*--------------------------------------------------*/

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"TagPeopleSegue"]) {
        
        PGTagPeopleViewController *tagPeopleVC =[segue destinationViewController];
        tagPeopleVC.tagPeopleImage = _shareImageOutlet.image;
        tagPeopleVC.delegate=self; // protocol listener
        tagPeopleVC.arrayOfTaggedFriends = taggedFriendsArray;
        tagPeopleVC.arrayOfTaggedFriendsPositions =taggedFriendPositions;
        
    }
    else  if([segue.identifier isEqualToString:@"shareToProductLinkSegue"]) {
        SaloonInfoViewController *saloon = [segue destinationViewController];
        NSString *text = purchaseLinkTextField.text;
        saloon.selectedProduct = text;
        saloon.delegate = self;
        [self MoveDownKeyBoardAfterPerformingSegue];
    }
    
    else  if([segue.identifier isEqualToString:@"addLocationSegue"]) {
        PGLocationViewController *locationController = [segue destinationViewController];
        locationController.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"gettingLocationSegue"]) {
        PGPlacesViewController *places = [segue destinationViewController];
        places.temporaryLocation = self.currentLocation;
        NSLog(@"%@",self.currentLocation);
        places.delegate=self;
    }
    else if ([segue.identifier isEqualToString:@"sharingToSelect"])
    {
        selectPostAsTableViewController *selectorVC = [segue destinationViewController];
        selectorVC.title = list[selectedType-1];
        selectorVC.titleStr = selectedType;
        if (selectedType == 2) {
            selectorVC.subCategoryArray = [subCatArray copy];
        }
        if (selectedType == 2 || selectedType == 3) {
            selectorVC.callBackOnlyCategory = ^(NSString *returnedStr,int type)
            {
                NSLog(@"returned List:%@",returnedStr);
                
                switch(type)
                {
                    case 1:categoryLbl.text = returnedStr;
                        break;
                    case 2:subCateLbl.text = returnedStr;
                        break;
                    case 3: {
                        
                        if ([returnedStr containsString:@"USD"]) {
                          NSString *currentText = priceTextField.text;
                            currentText = [currentText stringByReplacingOccurrencesOfString:@"₹" withString:@"$"];
                            
                            priceTextField.text = currentText;
                            
                        }
                        else if ([returnedStr containsString:@"INR"]) {
                            NSString *currentText = priceTextField.text;
                            currentText = [currentText stringByReplacingOccurrencesOfString:@"$" withString:@"₹"];
                            priceTextField.text = currentText;                    }
                        
                        currencyRLbl.text = returnedStr;
                    }
                }
            };
        }
        else{
            selectorVC.callBack = ^(NSString *strN ,int type,NSArray *subcat)
            {
                NSLog(@"returned List:%@",subcat);
                if ((int)[subcat count]>0) {
                    //int index = 0;
                    subCatArray = [subcat copy];
                    [self unhideSubCategory];
                }
                else
                    [self hideSubcategory];
                
                switch(type)
                {
                        categoryLbl.text = @" ";
                    case 1:categoryLbl.text = strN;
                        break;
                    case 2:subCateLbl.text = strN;
                        break;
                    case 3:currencyRLbl.text = strN;
                }
                
            };
        }
    }
    else if([segue.identifier isEqualToString:@"shareTohomeTab"])  {
        
        
        NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
        [navigationArray removeAllObjects];
        
//        UITabBarController *tabBarController = segue.destinationViewController;
//        UINavigationController *navigationController = (UINavigationController *)[[tabBarController viewControllers] objectAtIndex:0];
//        HomeViewController *controller = (HomeViewController *)[[navigationController viewControllers] objectAtIndex:0];
        
        NSDictionary * uploadingDict;
        
        
        
        
        if (_recordsession || _pathOfVideo) {
            if (![uploadType isEqualToString:@"business"]) {
                
                if (_recordsession) {
                    uploadingDict = @{               @"path" :_pathOfVideo,
                                                     @"recordSession" :flStrForObj(_recordsession),
                                                     @"imageForVideoThumabnailpath":flStrForObj(self.imageForVideoThumabnailpath),
                                                     @"sharingVideo":[NSNumber numberWithBool:_sharingVideo],
                                                     @"caption":flStrForObj(self.captionTextViewOutlet.text),
                                                     @"hashTags":flStrForObj(hashTagsInLowerCase),
                                                     @"location":flStrForObj(self.locationLabelOutlet.text),
                                                     @"lat":[NSNumber numberWithDouble:latInDouble],
                                                     @"log":[NSNumber numberWithDouble:longInDouble],
                                                     @"taggedFriendsString":flStrForObj(taggedFriendsString),
                                                     @"taggedFriendStringPoistions":flStrForObj(tagFirendLocation),
                                                     @"startUpload":@"1",
                                                     @"facebook":[NSNumber numberWithBool:_facebookSwitch.on],
                                                     @"twitter":[NSNumber numberWithBool:_twitterSwitch.on],
                                                     @"instagram":[NSNumber numberWithBool:_instgramSwitch.on],
                                                     @"businessProfile":@"No",
                                                     };
                }
                else{
                    uploadingDict = @{   @"path" :_pathOfVideo,
                                                     @"recordSession" :flStrForObj(_recordsession),
                                                     @"imageForVideoThumabnailpath":flStrForObj(self.imageForVideoThumabnailpath),
                                                     @"sharingVideo":[NSNumber numberWithBool:_sharingVideo],
                                                     @"caption":flStrForObj(self.captionTextViewOutlet.text),
                                                     @"hashTags":flStrForObj(hashTagsInLowerCase),
                                                     @"location":flStrForObj(self.locationLabelOutlet.text),
                                                     @"lat":[NSNumber numberWithDouble:latInDouble],
                                                     @"log":[NSNumber numberWithDouble:longInDouble],
                                                     @"taggedFriendsString":flStrForObj(taggedFriendsString),
                                                     @"taggedFriendStringPoistions":flStrForObj(tagFirendLocation),
                                                     @"startUpload":@"1",
                                                     @"facebook":[NSNumber numberWithBool:_facebookSwitch.on],
                                                     @"twitter":[NSNumber numberWithBool:_twitterSwitch.on],
                                                     @"instagram":[NSNumber numberWithBool:_instgramSwitch.on],
                                                     @"businessProfile":@"No",
                                                     @"pathVid":self.videoData
                                                     };
                }
            }
            else{
                
                NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"$₹"];
                NSString *priceText = priceTextField.text;
                priceText = [[priceText componentsSeparatedByCharactersInSet:set]
                             componentsJoinedByString:@""];
                if (_recordsession) {
                    uploadingDict = @{               @"path" :_pathOfVideo,
                                                     @"recordSession" :flStrForObj(_recordsession),
                                                     @"imageForVideoThumabnailpath":flStrForObj(self.imageForVideoThumabnailpath),
                                                     @"sharingVideo":[NSNumber numberWithBool:_sharingVideo],
                                                     @"caption":flStrForObj(self.captionTextViewOutlet.text),
                                                     @"hashTags":flStrForObj(hashTagsInLowerCase),
                                                     @"location":flStrForObj(self.locationLabelOutlet.text),
                                                     @"lat":[NSNumber numberWithDouble:latInDouble],
                                                     @"log":[NSNumber numberWithDouble:longInDouble],
                                                     @"taggedFriendsString":flStrForObj(taggedFriendsString),
                                                     @"startUpload":@"1",
                                                     @"taggedFriendStringPoistions":flStrForObj(tagFirendLocation),
                                                     @"facebook":[NSNumber numberWithBool:_facebookSwitch.on],
                                                     @"twitter":[NSNumber numberWithBool:_twitterSwitch.on],
                                                     @"instagram":[NSNumber numberWithBool:_instgramSwitch.on],
                                                     @"category":flStrForObj(categoryLbl.text),
                                                     @"subcatory":flStrForObj(subCateLbl.text),
                                                     @"currency":flStrForObj(currencyRLbl.text),
                                                     @"price" : flStrForObj(priceText),
                                                     @"productName" : @"product",
                                                     @"productUrl" : flStrForObj(purchaseLinkTextField.text),
                                                     @"businessProfile":@"Yes",
                                                     };
                }
                else {
                    uploadingDict = @{               @"path" :_pathOfVideo,
                                                     @"recordSession" :flStrForObj(_recordsession),
                                                     @"imageForVideoThumabnailpath":flStrForObj(self.imageForVideoThumabnailpath),
                                                     @"sharingVideo":[NSNumber numberWithBool:_sharingVideo],
                                                     @"caption":flStrForObj(self.captionTextViewOutlet.text),
                                                     @"hashTags":flStrForObj(hashTagsInLowerCase),
                                                     @"location":flStrForObj(self.locationLabelOutlet.text),
                                                     @"lat":[NSNumber numberWithDouble:latInDouble],
                                                     @"log":[NSNumber numberWithDouble:longInDouble],
                                                     @"taggedFriendsString":flStrForObj(taggedFriendsString),
                                                     @"startUpload":@"1",
                                                     @"taggedFriendStringPoistions":flStrForObj(tagFirendLocation),
                                                     @"facebook":[NSNumber numberWithBool:_facebookSwitch.on],
                                                     @"twitter":[NSNumber numberWithBool:_twitterSwitch.on],
                                                     @"instagram":[NSNumber numberWithBool:_instgramSwitch.on],
                                                     @"category":flStrForObj(categoryLbl.text),
                                                     @"subcatory":flStrForObj(subCateLbl.text),
                                                     @"currency":flStrForObj(currencyRLbl.text),
                                                     @"price" : flStrForObj(priceText),
                                                     @"productName" : @"product",
                                                     @"productUrl" : flStrForObj(purchaseLinkTextField.text),
                                                     @"businessProfile":@"Yes",
                                                      @"pathVid":self.videoData
                                                     };
                }
            }
        }
        else {
            NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"$₹"];
            NSString *priceText = priceTextField.text;
            priceText = [[priceText componentsSeparatedByCharactersInSet:set]
                         componentsJoinedByString:@""];
            
            if (![uploadType isEqualToString:@"business"]) {
                uploadingDict = @{
                                  @"imageForVideoThumabnailpath":flStrForObj(self.imageForVideoThumabnailpath),
                                  @"sharingVideo":[NSNumber numberWithBool:_sharingVideo],
                                  @"caption":flStrForObj(self.captionTextViewOutlet.text),
                                  @"hashTags":flStrForObj(hashTagsInLowerCase),
                                  @"location":flStrForObj(self.locationLabelOutlet.text),
                                  @"lat":[NSNumber numberWithDouble:latInDouble],
                                  @"log":[NSNumber numberWithDouble:longInDouble],
                                  @"taggedFriendsString":flStrForObj(taggedFriendsString),
                                  @"taggedFriendStringPoistions":flStrForObj(tagFirendLocation),
                                  @"startUpload":@"1",
                                  @"postedImagePath": _postedImagePath,
                                  @"facebook":[NSNumber numberWithBool:_facebookSwitch.on],
                                  @"twitter":[NSNumber numberWithBool:_twitterSwitch.on],
                                  @"instagram":[NSNumber numberWithBool:_instgramSwitch.on],
                                  @"postedthumbNailImagePath":_postedthumbNailImagePath,
                                  @"businessProfile":@"No",
                                  //                              @"tagLocationOnImage":taggedFriendPositions
                                  };
            }
            else
            {
                uploadingDict = @{
                                  @"imageForVideoThumabnailpath":flStrForObj(self.imageForVideoThumabnailpath),
                                  @"sharingVideo":[NSNumber numberWithBool:_sharingVideo],
                                  @"caption":flStrForObj(self.captionTextViewOutlet.text),
                                  @"hashTags":flStrForObj(hashTagsInLowerCase),
                                  @"location":flStrForObj(self.locationLabelOutlet.text),
                                  @"lat":[NSNumber numberWithDouble:latInDouble],
                                  @"log":[NSNumber numberWithDouble:longInDouble],
                                  @"taggedFriendsString":flStrForObj(taggedFriendsString),
                                  @"taggedFriendStringPoistions":flStrForObj(tagFirendLocation),
                                  @"startUpload":@"1",
                                  @"postedImagePath": _postedImagePath,
                                  @"facebook":[NSNumber numberWithBool:_facebookSwitch.on],
                                  @"twitter":[NSNumber numberWithBool:_twitterSwitch.on],
                                  @"instagram":[NSNumber numberWithBool:_instgramSwitch.on],
                                  @"postedthumbNailImagePath":_postedthumbNailImagePath,
                                  //                              @"tagLocationOnImage":taggedFriendPositions
                                  @"category":flStrForObj(categoryLbl.text),
                                  @"subcatory":flStrForObj(subCateLbl.text),
                                  @"currency":flStrForObj(currencyRLbl.text),
                                  @"price" : flStrForObj(priceText),
                                  @"productName" : @"product",
                                  @"productUrl" : flStrForObj(purchaseLinkTextField.text),
                                  @"businessProfile":@"Yes",
                                  };
            }
        }
        
        NSMutableArray *bookingInfo = [[NSMutableArray alloc] init];
        [bookingInfo addObject:uploadingDict];
        [[NSUserDefaults standardUserDefaults]setObject:bookingInfo forKey:@"fileForUpload"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


/*----------------------------------------------------*/
#pragma mark
#pragma mark - navigation bar buttons
/*-----------------------------------*/

- (void)createNavLeftButton {
    navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
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

- (void)backButtonClicked {
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}



/*-----------------------------------------------*/
#pragma mark -
#pragma mark - textView Delegate
/*----------------------------------------------*/

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    //settingHeightFor SearchView(it will vary for device).
    if (textView.tag == 10 || textView.tag == 20) {
        if ([textView.text isEqualToString:@"00.00"]) {
            [textView setText:@""];
        }
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [self moveViewToTop:textView];
    }
    else
    {
        
        [self settingSearchViewHeight];
       
        
        self.navigationItem.title = @"Caption";
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.searchViewOutlet.hidden =NO;
            self.tableviewOutlet.hidden =YES;
            self.tagFriendsTableView.hidden = YES;
            self.viewForDismissKeyBoard.hidden = NO;
            
            navCancelButton.hidden = YES;
            
            self.baseScrollview.scrollEnabled = NO;
            
            [navShareButton setTitle:@"Ok"
                            forState:UIControlStateNormal];
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    self.baseScrollview.scrollEnabled = YES;
    if (textView.tag == 10 || textView.tag == 20) {
        if(textView.tag == 10)
        {
            if (textView.text.length == 0)
            {
                [textView setText:@"00.00"];
            }
        }
        if (textView.tag == 20) {
            if([Helper validateUrl:textView.text])
            {
                
            }
            else
            {
                //                [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardDidShowNotification object:nil];
                //                [UIView animateWithDuration:0.1 animations: ^{
                //
                //                    CGRect frame = self.view.bounds;
                //                    frame.origin.y = 40;
                //                    self.view.frame = frame;
                //                    [self.view layoutIfNeeded];
                //                } completion:^(BOOL finished) {
                //
                //                    [textView resignFirstResponder];
                //                }];
                //
                //
                //                UIAlertView *toast = [[UIAlertView alloc] initWithTitle:nil
                //                                                                message:@"Invalid weburl"
                //                                                               delegate:nil
                //                                                      cancelButtonTitle:nil
                //                                                      otherButtonTitles:nil, nil];
                //                [toast show];
                //                int duration = 1; // in seconds
                //
                //                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                //
                //                    [toast dismissWithClickedButtonIndex:0 animated:YES];
                //                });
                
            }
        }
    }
    else
    {
        
        [UIView animateWithDuration:0.5 animations: ^{
            self.searchViewOutlet.hidden =YES;
            [self.view layoutIfNeeded];
        }];
        NSLog(@"did end editing");
        [self dismissKeyboard];
        self.navigationItem.title = @"New post";
        navCancelButton.hidden = NO;
        
        [navShareButton setTitle:@"Share"
                        forState:UIControlStateNormal];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.tag == 10) {
        if ([self substring:@"." existsInString:textView.text]) {
            
            NSArray* dateArray = [textView.text componentsSeparatedByString: @"."];
            NSLog(@"seperated string:%@",dateArray);
            if (dateArray.count > 1)
            {
                NSString *centAmount = dateArray[1];
                if (centAmount.length > 2)
                {  float num = [textView.text floatValue];
                    NSString* formattedNumber = [NSString stringWithFormat:@"%.02f", num];
                    textView.text = formattedNumber;
                    return NO;
                }
            }
        }
        if ([text isEqualToString:@"\n"]) {
            [UIView animateWithDuration:0.4 animations: ^{
                
                CGRect frame = self.view.bounds;
                frame.origin.y = 40;
                self.view.frame = frame;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                [textView resignFirstResponder];
            }];
            
            return NO;
        }
    }
    else if (textView.tag == 20) {
        if ([text isEqualToString:@"\n"]) {
            [UIView animateWithDuration:0.4 animations: ^{
                
                CGRect frame = self.view.bounds;
                frame.origin.y = 40;
                self.view.frame = frame;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                [textView resignFirstResponder];
            }];
            return NO;
        }
    }
    else {
        if ([text isEqualToString:@"\n"]) {
            [UIView animateWithDuration:0.4 animations: ^{
                
                CGRect frame = self.view.bounds;
                frame.origin.y = 40;
                self.view.frame = frame;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                [textView resignFirstResponder];
            }];
            return NO;
        }
        //        if ( [self.captionTextViewOutlet.text isEqualToString:@"\n"]) {
        //            if ([text isEqualToString:@"\n"]) {
        //                [self.captionTextViewOutlet resignFirstResponder];
        //                return NO;
        //            }
        //        }
    }
    return YES;
}



- (void)textViewDidChange:(UITextView *)textView {
    
    
    if (textView.tag == 10) {
       //price textView
    }
    else {
        //From here you can get the last text entered by the user
        stringsSeparatedBySpace = (NSMutableArray *)[textView.text componentsSeparatedByString:@" "];
        
        //then you can check whether its one of your userstrings and trigger the event
        lastString = [stringsSeparatedBySpace lastObject];
        isValidForTagFriends = [lastString containsString:@"@"];
        isValidForHashTags = [lastString containsString:@"#"];
        
        if(isValidForTagFriends) {
            showOnlyHashTagResults = NO;
            showOnlyTagFriendsResults = YES;
            
            if (lastString.length > 1) {
                [self requestForTagFriends];
                self.tableviewOutlet.hidden = YES;
                self.tagFriendsTableView.hidden = NO;
            }
            else {
                self.tableviewOutlet.hidden = YES;
                self.tagFriendsTableView.hidden = YES;
                [userNmaeresponseData  removeAllObjects];
            }
        }
        else if(isValidForHashTags) {
            showOnlyHashTagResults = YES;
            showOnlyTagFriendsResults = NO;
            if (lastString.length > 1) {
                [self requestForhashTags];
                self.tableviewOutlet.hidden = NO;
                self.tagFriendsTableView.hidden = YES;
            }
            else {
                self.tableviewOutlet.hidden = YES;
                self.tagFriendsTableView.hidden = YES;
                [userNmaeresponseData  removeAllObjects];
            }
        }
        else {
            showOnlyHashTagResults = NO;
            showOnlyTagFriendsResults = NO;
            self.tableviewOutlet.hidden =YES;
            self.tagFriendsTableView.hidden = YES;
            self.viewForDismissKeyBoard.hidden = NO;
        }
    }
}

-(BOOL)substring:(NSString *)substr existsInString:(NSString *)strN {
    if(!([strN rangeOfString:substr options:NSCaseInsensitiveSearch].length==0)) {
        return YES;
    }
    
    return NO;
}

-(void)requestForhashTags {
    NSString  *stringToSearchForhashTags = [lastString substringFromIndex:1];
    searchResultsFor = stringToSearchForhashTags;
    NSDictionary *requestDict = @{
                                  mhashTag :stringToSearchForhashTags,
                                  mauthToken :flStrForObj([Helper userToken]),
                                  };
    if (userNmaeresponseData.count == 0 ||  hashTagresponseData.count == 0) {
        showTableViewHeader = YES;
    }
    else  {
        showTableViewHeader = NO;
    }
    [WebServiceHandler getHashTagSuggestion:requestDict andDelegate:self];
    showTableViewHeader =YES;
    [self.tableviewOutlet reloadData];
}

-(void)requestForTagFriends {
    NSString  *stringToSearchForTagFriend = [lastString substringFromIndex:1];
    searchResultsFor =stringToSearchForTagFriend;
    NSDictionary *requestDict = @{
                                  muserTosearch :stringToSearchForTagFriend,
                                  mauthToken :flStrForObj([Helper userToken]),
                                  };
    [WebServiceHandler getUserNameSuggestion:requestDict andDelegate:self];
    showTableViewHeader =YES;
    [self.tagFriendsTableView reloadData];
}

/*-------------------------------------------------------------*/
#pragma mark -
#pragma mark - TableviewDelegateForListOfFriends and hashtags
/*-------------------------------------------------------------*/

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isValidForTagFriends) {
        return userNmaeresponseData.count;
    }
    else {
        return hashTagresponseData.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ListOfTagFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListOfFriendsCell"];
    
    if (showOnlyHashTagResults) {
        cell.hashNameLabelOutlet.text = arrayOfHashTags[indexPath.row];
        NSString* myNewString = [NSString stringWithFormat:@"%@", arrayOfHashtagCount[indexPath.row]];
        cell.numberOfPostsLabelOutlet.text = myNewString;
    }
    if (showOnlyTagFriendsResults) {
        
        cell.userNameLabelOutlet.text = arrayOfFullNames[indexPath.row];
        cell.profileNameLabelOutlet.text = arrayOfUserNames[indexPath.row];
        
        
        
        [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:[arrayOfProfilePicUrl objectAtIndex:indexPath.row]]
                                 placeholderImage:[UIImage imageNamed:@"defaultpp"]];
        [cell layoutIfNeeded];
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width/2;
        cell.profileImageView.clipsToBounds =  YES;
        cell.profileImageView.layer.masksToBounds = YES;
        
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //appending selected row at indexpath text(user name or hashtag) to the TextView.
    if (isValidForHashTags) {
        ListOfTagFriendsTableViewCell *selectedCell = [self.tableviewOutlet cellForRowAtIndexPath:indexPath];
        //adding space at the end for slected hash tag (ending that hash tag).
        NSString *cellText =  [selectedCell.hashNameLabelOutlet.text stringByAppendingString:@" "];
        //adding # before the hash tag string.
        NSString *cellTextWithSymbol =@"#";
        cellTextWithSymbol = [cellTextWithSymbol stringByAppendingString:cellText];
        
        //        //replacing
        self.captionTextViewOutlet.text = [self.captionTextViewOutlet.text stringByReplacingCharactersInRange:[self.captionTextViewOutlet.text rangeOfString:lastString options:NSBackwardsSearch] withString:@""];
        
        self.captionTextViewOutlet.text = [self.captionTextViewOutlet.text stringByAppendingString:cellTextWithSymbol];
        self.tableviewOutlet.hidden = YES;
    }
    if (isValidForTagFriends) {
        //for selected row the username will add with the space and intiall letter with @ letter.
        ListOfTagFriendsTableViewCell *selectedCell = [self.tagFriendsTableView cellForRowAtIndexPath:indexPath];
        NSString *cellText = [selectedCell.profileNameLabelOutlet.text stringByAppendingString:@" "];
        NSString *cellTextWithSymbol =@"@";
        cellTextWithSymbol = [cellTextWithSymbol stringByAppendingString:cellText];
        self.captionTextViewOutlet.text = [self.captionTextViewOutlet.text stringByReplacingCharactersInRange:[self.captionTextViewOutlet.text rangeOfString:lastString options:NSBackwardsSearch] withString:@""];
        
        self.captionTextViewOutlet.text = [ self.captionTextViewOutlet.text stringByAppendingString:cellTextWithSymbol];
        self.tagFriendsTableView.hidden =YES;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (showTableViewHeader) {
        return 40;
    }
    else {
        return 0.0;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // creating custom header view
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    view.backgroundColor =[UIColor whiteColor];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = CGRectMake(10, 0.0, 40.0, 40.0);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    [indicator startAnimating];
    
    /* Create custom view to display section header... */
    //creating user name label
    UILabel *UserNamelabel = [[UILabel alloc] init];
    NSString *strWithSearchResultsFor =@"Searching For ";
    NSString *searchStrWithDoubleQuotes = [NSString stringWithFormat:@"\"%@\"",searchResultsFor];
    UserNamelabel.text =[strWithSearchResultsFor stringByAppendingString:searchStrWithDoubleQuotes];
    [UserNamelabel setFont:[UIFont boldSystemFontOfSize:14]];
    UserNamelabel.textColor =[UIColor colorWithRed:0.2745 green:0.4353 blue:0.8078 alpha:1.0];
    UserNamelabel.frame=CGRectMake(50, 0, view.frame.size.width,view.frame.size.height);
    UserNamelabel.textAlignment = NSTextAlignmentLeft;
    [view addSubview:indicator];
    [view addSubview:UserNamelabel];
    return view;
}

/*--------------------------------------*/
#pragma mark -
#pragma mark - CLLocationManagerDelegate
/*--------------------------------------*/

-(void)GetTheUserCurrentLocation {
    if ([CLLocationManager locationServicesEnabled ]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError: %@", error);
    //    UIAlertView *errorAlert = [[UIAlertView alloc]
    //                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"%@", [locations lastObject]);
    [self.locationManager stopUpdatingLocation];
    geocoder = [[CLGeocoder alloc] init];
    self.currentLocation = [locations lastObject];
    [self queryGooglePlaces:@""];
}

-(void) askforpermissiontoenablelocation
{
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [locationManager requestWhenInUseAuthorization];
    }
    
    //Checking authorization status
    
    //    if (![CLLocationManager locationServicesEnabled])
    //    {
    //          [self showAlert];
    //    }
    //    else
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

/*------------------------------------------*/
#pragma mark -
#pragma mark - near by locations.
/*------------------------------------------*/

-(void)getNearbyPlaces {
    // https://maps.googleapis.com/maps/api/place/search/json?location=-33.8670522,151.1957362&radius=500&sensor=true&key=AIzaSyA7WH1h7WtWLqQuK6o0FGQDjJby6Aw_Pow
    
    _isSearching = NO;
    
    NSString *strUrl = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%f,%f&radius=10000&sensor=true&key=AIzaSyBBFZrlfhtpTbcJO_Ze0_XhNsHE_aRDlU0",_currentLocation.coordinate.latitude,_currentLocation.coordinate.longitude];
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:strUrl];
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    
    //    NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
    //    [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
}

-(void) queryGooglePlaces:(NSString *) _searchString {
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
    //Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    //    NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
    //    [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
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
    else {
        _searchResults = [json objectForKey:@"results"];
    }
    if (_firstResut.count == 0) {
        _firstResut = _searchResults;
    }
    _PlacesSuggestionViewHeightConstraint.constant = 0;
    [UIView animateWithDuration:0.5 animations:^{
        _PlacesSuggestionViewHeightConstraint.constant = 50;
        [self.view layoutIfNeeded];
    }];
    [self.placesSuggestionCollectionView reloadData];
}


/*-----------------------------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*------------------------------------------------------*/

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    
    //handling response.
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
    if (requestType == RequestTypePost) {
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        //success response(200 is for success code).
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
            }
                break;
                //failure responses.
            case 1986: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 1987: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 1988: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }
    
    //response for hashtagsuggestion api.
    if (requestType == RequestTypeGetHashTagsSuggestion) {
        showTableViewHeader = NO;
        //success response(200 is for success code).
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                hashTagsData = responseDict;
                [self handlingSuccessResponseOfHashTags];
            }
                break;
            case 19021: {
                [self errorAlert:responseDict[@"message"]];
            }
            case 19022: {
                [self errorAlert:responseDict[@"message"]];
            }
        }
    }
    //response for tagFriend api.
    if (requestType == RequestTypeGetTagFriendsSuggestion) {
        showTableViewHeader = NO;
        //success response(200 is for success code).
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                tagFriendsData = responseDict;
                [self handlingSuccessResponseOfUserNamesSuggestionapi];
            }
                break;
            case 19031: {
                [self errorAlert:responseDict[@"message"]];
            }
            case 19032: {
                [self errorAlert:responseDict[@"message"]];
            }
        }
    }
}

- (void)errorAlert:(NSString *)message {
    //alert for failure response.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];
    [alert show];
}

//getting response of gethashtag api and converting into arrays(arrayOfHashtagCount,arrayOfHashTags to populate the data in tableview).
-(void)handlingSuccessResponseOfHashTags {
    if (hashTagsData) {
        //arrayOfHashTags(contains only hashtagnames),arrayOfHashtagCount(contains only hashatgcount),hashTagresponseData(contains array of hashtagnames and hashtagcount),hashTagsData(dictonary contains data of success response).
        arrayOfHashTags =[[NSMutableArray alloc] init];
        arrayOfHashtagCount =[[NSMutableArray alloc] init];
        hashTagresponseData =[[NSMutableArray alloc] init];
        hashTagresponseData = hashTagsData[@"data"];
        /**
         *  separating hashtagnames,hashatgcount from hashTagresponseData array and intialinzing in separate arrays.
         */
        for(int i = 0; i< hashTagresponseData.count;i++) {
            NSString *hashTag = hashTagresponseData[i][@"hashtag"];
            NSString *hashTagCount =hashTagresponseData[i][@"Count"];
            
            //adding names and count value to the array.
            [arrayOfHashtagCount addObject:hashTagCount];
            [arrayOfHashTags addObject:hashTag];
        }
        if (hashTagresponseData.count == 0) {
            self.tableviewOutlet.hidden =YES;
            self.tagFriendsTableView.hidden = YES;
            self.viewForDismissKeyBoard.hidden = NO;
        }
        else {
            //reloading every time.
            [self.tableviewOutlet reloadData];
        }
    }
}


//getting response of gethashtag api and converting into arrays(arrayOfHashtagCount,arrayOfHashTags to populate the data in tableview).
-(void)handlingSuccessResponseOfUserNamesSuggestionapi {
    if (tagFriendsData) {
        //arrayOfHashTags(contains only hashtagnames),arrayOfHashtagCount(contains only hashatgcount),hashTagresponseData(contains array of hashtagnames and hashtagcount),hashTagsData(dictonary contains data of success response).
        
        arrayOfUserNames =[[NSMutableArray alloc] init];
        arrayOfFullNames =[[NSMutableArray alloc] init];
        arrayOfProfilePicUrl =[[NSMutableArray alloc] init];
        
        
        
        userNmaeresponseData =[[NSMutableArray alloc] init];
        userNmaeresponseData = tagFriendsData[@"data"];
        
        /**
         *  separating hashtagnames,hashatgcount from hashTagresponseData array and intialinzing in separate arrays.
         */
        for(int i = 0; i< userNmaeresponseData.count;i++) {
            NSString *userName = userNmaeresponseData[i][@"username"];
            NSString *fullName =  flStrForObj(userNmaeresponseData[i][@"fullName"]);
            NSString *profilePicUrl =flStrForObj(userNmaeresponseData[i][@"profilePicUrl"]);
            
            
            [arrayOfFullNames addObject:fullName];
            [arrayOfProfilePicUrl addObject:profilePicUrl];
            
            //adding names and count value to the array.
            [arrayOfUserNames addObject:userName];
        }
        if (userNmaeresponseData.count == 0) {
            self.tableviewOutlet.hidden =YES;
            self.tagFriendsTableView.hidden = YES;
            self.viewForDismissKeyBoard.hidden = NO;
        }
        else  {
            //reloading every time.
            [self.tagFriendsTableView reloadData];
        }
    }
}

-(void)dealloc {
    self.tableviewOutlet.delegate = nil;
    self.tagFriendsTableView.dataSource =nil;
}



- (IBAction)TumblrAction:(id)sender
{}
- (IBAction)FacebookAction:(id)sender{
    
    if (self.facebookSwitch.on) {
        [Helper checkFbLogin];
        self.facebookButtonOutlet.selected =YES;
    }
    else {
        self.facebookButtonOutlet.selected =NO;
    }
}
- (IBAction)twitterAction:(id)sender{
    
    if (self.twitterSwitch.on) {
        [Helper chkTwitterLogin];
        self.TwitterButtonOutlet.selected = YES;
    }
    else
    {
        self.TwitterButtonOutlet.selected = NO;
    }
}

- (IBAction)instgramAction:(id)sender {
    if (self.instgramSwitch.on ) {
        self.InstagrambuttonOutlet.selected = YES;
    }
    else {
        self.InstagrambuttonOutlet.selected = NO;
    }
}

-(void)fbNotification:(NSNotification *)noti {
    self.facebookButtonOutlet.selected = NO;
    self.facebookSwitch.on = NO;
}

-(void)twitterNotification:(NSNotification *)noti {
    self.TwitterButtonOutlet.selected = NO;
    self.twitterSwitch.on = NO;
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"There is no Twitter account configured" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
    
}

-(void)createBusinessPost
{
    
    float w = [[UIScreen mainScreen]bounds].size.width;
    //_addlocationView.backgroundColor = [UIColor greenColor];
    [_addLocationButtonOutlet setHidden:NO];
    CGRect frame = _activityView.frame;
    
    float h = frame.origin.y;
    
    
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"BUSINESS", @"INDIVIDUAL", nil];
    postType = [[UISegmentedControl alloc] initWithItems:itemArray];
    
    postTypeLbl = [[UILabel alloc]initWithFrame:CGRectMake(0,self.tagPeopleView.frame.size.height, w, 23)];
    [Helper setToLabel:postTypeLbl Text:@"    POST AS" WithFont:RobotoBold FSize:10 Color:[UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f]];
    postTypeLbl.backgroundColor = [UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1.0f];
    [self.activityView addSubview:postTypeLbl];
    
    //postAsTopLine
    
    postAsTopLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.tagPeopleView.frame.size.height -1 , w, 0.5f)];
    postAsTopLine.backgroundColor = [UIColor colorWithRed:219/255.0f green:219/255.0f blue:219/255.0f alpha:1.0f];
    [self.activityView addSubview:postAsTopLine];
    
    postAsBottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.tagPeopleView.frame.size.height + postTypeLbl.frame.size.height +1, w, 0.5f)];
    postAsBottomLine.backgroundColor = [UIColor colorWithRed:219/255.0f green:219/255.0f blue:219/255.0f alpha:1.0f];
    [self.activityView addSubview:postAsBottomLine];
    
    postType.frame = CGRectMake(14,self.tagPeopleView.frame.size.height + postTypeLbl.frame.size.height +10,w-28, 30);//h+50
    [postType addTarget:self action:@selector(segmentAction:) forControlEvents: UIControlEventValueChanged];
    postType.selectedSegmentIndex = 0;
    [self.activityView addSubview:postType];
    
    //[postType sendSubviewToBack:self.baseScrollview];
    
    
    businessPostView = [[UIView alloc]initWithFrame:CGRectMake(0, self.tagPeopleView.frame.size.height + postTypeLbl.frame.size.height +10 + postType.frame.size.height,320, 225)];
    // businessPostView.backgroundColor = [UIColor greenColor];
    [self.activityView addSubview:businessPostView];
    
    
    productCategoryView = [[UIView alloc]initWithFrame:CGRectMake(0, 15, w, 40)];
    UILabel *prodLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, w/2, 40)];
    [Helper setToLabel:prodLbl Text:@" Product Category" WithFont:RobotoRegular FSize:12.0f Color:[UIColor colorWithRed:185/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f]];
    [productCategoryView addSubview:prodLbl];
    
    UIView *nextView = [[UIView alloc]initWithFrame:CGRectMake(w-20, 12.5f, 8, 13)];
    [nextView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"more"]]];
    [productCategoryView addSubview:nextView];
    
    categoryLbl = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(prodLbl.frame), 0, w/2-40, 40)];
    [Helper setToLabel:categoryLbl Text:@" " WithFont:RobotoRegular FSize:15.0f Color:[UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f]];
    categoryLbl.textAlignment = NSTextAlignmentRight;
    [productCategoryView addSubview:categoryLbl];
    
    UIButton *Categorybtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, w, 40)];
    Categorybtn.backgroundColor = [UIColor clearColor];
    Categorybtn.tag = 1;
    str = @"category";
    [Categorybtn addTarget:self
                    action:@selector(selectorBtn:)
          forControlEvents:UIControlEventTouchUpInside];
    [productCategoryView addSubview:Categorybtn];
    
    
    
    [businessPostView addSubview:productCategoryView];
    //[businessPostView bringSubviewToFront:productCategoryView];
    
    UIView *segmentLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.tagPeopleView.frame.size.height + postTypeLbl.frame.size.height +20 + postType.frame.size.height, w, 0.5f)];
    segmentLine.backgroundColor = [UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f];
    [self.activityView addSubview:segmentLine];
    
    UIView *prodTopLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(productCategoryView.frame), w, 0.5f)];
    prodTopLine.backgroundColor = [UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f];
    [businessPostView addSubview:prodTopLine];
    
    prodLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(productCategoryView.frame), w, 0.5f)];
    prodLine.backgroundColor = [UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f];
    [businessPostView addSubview:prodLine];
    
    
    /************************/
    prodSubCategoryView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(productCategoryView.frame), w, 0)];
    prodSubLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, w/2, 40)];
    [Helper setToLabel:prodSubLbl Text:@" Product Sub Category" WithFont:RobotoRegular FSize:12.0f Color:[UIColor colorWithRed:185/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f]];
    [prodSubLbl setHidden:YES];
    [prodSubCategoryView addSubview:prodSubLbl];
    
    subCateLbl = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(prodLbl.frame), 0, w/2-40, 40)];
    [Helper setToLabel:subCateLbl Text:@" " WithFont:RobotoRegular FSize:15.0f Color:[UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f]];
    subCateLbl.textAlignment = NSTextAlignmentRight;
    //subCateLbl.backgroundColor = [UIColor yellowColor];
    [subCateLbl setHidden:YES];
    [prodSubCategoryView addSubview:subCateLbl];
    
    
    nextView2 = [[UIView alloc]initWithFrame:CGRectMake(w-20, 12.5f, 8, 13)];
    [nextView2 setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"more"]]];
    [nextView2 setHidden:YES];
    [prodSubCategoryView addSubview:nextView2];
    
    subCategorybtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, w, 40)];
    subCategorybtn.backgroundColor = [UIColor clearColor];
    subCategorybtn.tag = 2;
    str = @"category";
    [subCategorybtn addTarget:self
                       action:@selector(selectorBtn:)
             forControlEvents:UIControlEventTouchUpInside];
    [subCategorybtn setHidden:YES];
    [prodSubCategoryView addSubview:subCategorybtn];
    
    subProdLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(prodSubCategoryView.frame), w, 0.5f)];
    subProdLine.backgroundColor = [UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f];
    [businessPostView addSubview:subProdLine];
    
    
    /************************/
    
    
    currencyView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(prodSubCategoryView.frame), w, 40)];
    UILabel *currencyLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, w/2, 40)];
    [Helper setToLabel:currencyLbl Text:@" Currency" WithFont:RobotoRegular FSize:12.0f Color:[UIColor colorWithRed:185/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f]];
    
 
    
    [currencyView addSubview:currencyLbl];
    //currencyLbl.backgroundColor = [UIColor greenColor];
    [businessPostView addSubview:currencyView];
    //[businessPostView bringSubviewToFront:currencyView];
    
    currencyRLbl = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(prodLbl.frame), 0, w/2-40, 40)];
    [Helper setToLabel:currencyRLbl Text:@"" WithFont:RobotoRegular FSize:15.0f Color:[UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f]];
    currencyRLbl.textAlignment = NSTextAlignmentRight;
    // currencyRLbl.backgroundColor = [UIColor yellowColor];
    [currencyView addSubview:currencyRLbl];
    
    UIView *nextView3 = [[UIView alloc]initWithFrame:CGRectMake(w-20, 12.5f, 8, 13)];
    [nextView3 setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"more"]]];
    [currencyView addSubview:nextView3];
    
    currencyLblLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(currencyView.frame), w, 0.5f)];
    currencyLblLine.backgroundColor = [UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f];
    [businessPostView addSubview:currencyLblLine];
    
    UIButton *currencybtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, w, 40)];
    currencybtn.backgroundColor = [UIColor clearColor];
    currencybtn.tag = 3;
    str = @"category";
    [currencybtn addTarget:self
                    action:@selector(selectorBtn:)
          forControlEvents:UIControlEventTouchUpInside];
    [currencyView addSubview:currencybtn];
    
    
    
    price = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(currencyView.frame), w, 40)];
    UILabel *priceLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, w/2, 40)];
    //NSString *priceTagStr = [NSString stringWithUTF8String:" Price\u00b2^"];//@" Price*"
    [Helper setToLabel:priceLbl Text:@" Price*" WithFont:RobotoRegular FSize:12.0f Color:[UIColor colorWithRed:185/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f]];
    priceLbl.attributedText = [self supscriptString:@" Price*"];
    [price addSubview:priceLbl];
    
    
    UITapGestureRecognizer *priceLbltapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(priceLblLbllabelTapped)];
    priceLbltapGestureRecognizer.numberOfTapsRequired = 1;
    [priceLbl addGestureRecognizer:priceLbltapGestureRecognizer];
    priceLbl.userInteractionEnabled = YES;
    
    priceTextField = [[UITextField alloc]initWithFrame:CGRectMake(120, 5, w-130, 30)];
    priceTextField.tag = 10;
    [priceTextField setFont:[UIFont fontWithName:RobotoRegular size:12.0f]];
    priceTextField.textColor = [UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f];
    priceTextField.textAlignment = NSTextAlignmentRight;
    priceTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    priceTextField.placeholder = @"00.00";
    [priceTextField setValue:[UIColor darkGrayColor]
                    forKeyPath:@"_placeholderLabel.textColor"];
    
    priceTextField.delegate = self;
    [priceTextField addTarget:self
                  action:@selector(priceTextFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    //pricetext.backgroundColor = [UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f];
    [price addSubview:priceTextField];
    
    priceLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(price.frame), w, 0.5f)];
    priceLine.backgroundColor = [UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f];
    [businessPostView addSubview:priceLine];
    [businessPostView addSubview:price];
    // [businessPostView bringSubviewToFront:price];
    
    
    
    PurchaseLink = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(price.frame), w, 40)];
    UILabel *purchaseLinkLbl = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, w/2, 40)];
    
    UITapGestureRecognizer *purchaseLinkLbltapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(purchaseLinkLbllabelTapped)];
    purchaseLinkLbltapGestureRecognizer.numberOfTapsRequired = 1;
    [purchaseLinkLbl addGestureRecognizer:purchaseLinkLbltapGestureRecognizer];
    purchaseLinkLbl.userInteractionEnabled = YES;
    
    [Helper setToLabel:purchaseLinkLbl Text:@" Purchase Link*" WithFont:RobotoRegular FSize:12.0f Color:[UIColor colorWithRed:185/255.0f green:184/255.0f blue:184/255.0f alpha:1.0f]];
    purchaseLinkLbl.attributedText = [self supscriptString:@" Purchase Link*"];
    [PurchaseLink addSubview:purchaseLinkLbl];
    
    PurchaseLinkLine = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(PurchaseLink.frame), w, 0.5f)];
    PurchaseLinkLine.backgroundColor = [UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f];
    [businessPostView addSubview:PurchaseLinkLine];
    [businessPostView addSubview:PurchaseLink];
    // [businessPostView bringSubviewToFront:PurchaseLink];
    
    purchaseLinkTextField = [[UITextField alloc]initWithFrame:CGRectMake(120,5, w-130 ,30)];
    purchaseLinkTextField.tag = 20;
    purchaseLinkTextField.delegate = self;
    [purchaseLinkTextField addTarget:self
                  action:@selector(purchaseLinktextFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [purchaseLinkTextField setFont:[UIFont fontWithName:RobotoRegular size:12.0f]];
    purchaseLinkTextField.textColor = [UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f];
    purchaseLinkTextField.textAlignment = NSTextAlignmentRight;
    //purchaselikeTF.backgroundColor = [UIColor colorWithRed:225/255.0f green:225/255.0f blue:225/255.0f alpha:1.0f];
   
    [PurchaseLink addSubview:purchaseLinkTextField];
    
    [businessPostView addSubview:prodSubCategoryView];
    // [businessPostView bringSubviewToFront:productCategoryView];
    _topConstraintOfAddLocationView.constant = 70+businessPostView.frame.size.height-40;
    
    CGRect subCatframe = prodSubCategoryView.frame;
    subCatframe.size.height = 0;
    prodSubCategoryView.frame = subCatframe;
    // prodSubCategoryView.backgroundColor = [UIColor greenColor];
    
}
-(void)priceLblLbllabelTapped {
    [priceTextField becomeFirstResponder];
}

-(void)purchaseLinkLbllabelTapped {
     [purchaseLinkTextField becomeFirstResponder];
}
-(void)purchaseLinktextFieldDidChange:(UITextField *)theTextField {
    NSString *convertString = purchaseLinkTextField.text;
    if ([convertString containsString:@" "]) {
        if ([purchaseLinkTextField.text length] > 0) {
            purchaseLinkTextField.text = [purchaseLinkTextField.text substringToIndex:[purchaseLinkTextField.text length] - 1];
            NSString *removeSpace = [purchaseLinkTextField.text stringByAppendingString:@""];
            purchaseLinkTextField.text = removeSpace;
        }
    }
}

-(void)priceTextFieldDidChange:(UITextField *)theTextField {
    
//    NSString *text = theTextField.text;
//    NSRange range = [text rangeOfString:@"."];
//    
//    if (range.location != NSNotFound &&
//        [text hasSuffix:@"."] &&
//        range.location != (text.length - 1))
//    {
//        // There's more than one decimal
//        theTextField.text = [text substringToIndex:text.length - 1];
//    }
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(textField == priceTextField) {
        
//        NSNumberFormatter *formatter = [NSNumberFormatter new];
//        [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
//        [formatter setLenient:YES];
//        [formatter setGeneratesDecimalNumbers:YES];
//        
//        NSString *replaced = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        NSDecimalNumber *amount = (NSDecimalNumber*) [formatter numberFromString:replaced];
//        if (amount == nil) {
//            // Something screwed up the parsing. Probably an alpha character.
//            return NO;
//        }
//        // If the field is empty (the initial case) the number should be shifted to
//        // start in the right most decimal place.
//        short powerOf10 = 0;
//        if ([textField.text isEqualToString:@""]) {
//            powerOf10 = -formatter.maximumFractionDigits;
//        }
//        // If the edit point is to the right of the decimal point we need to do
//        // some shifting.
//        else if (range.location + formatter.maximumFractionDigits >= textField.text.length) {
//            // If there's a range of text selected, it'll delete part of the number
//            // so shift it back to the right.
//            if (range.length) {
//                powerOf10 = -range.length;
//            }
//            // Otherwise they're adding this many characters so shift left.
//            else {
//                powerOf10 = [string length];
//            }
//        }
//        amount = [amount decimalNumberByMultiplyingByPowerOf10:powerOf10];
//        
//        // Replace the value and then cancel this change.
//        textField.text = [formatter stringFromNumber:amount];
//        return NO;
        
        
        
        
        
        
        
        NSString* valregex = @"^[+|-]*[0-9]*.[0-9]{1,2}";
        
        //^[+-]?(?:[0-9]{0,5}\.[0-9]{1,3}|[0-9]{1,5})$
        
        
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERSFORPRICE] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        if ([string isEqualToString:filtered]) {
            NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            NSArray  *arrayOfString = [newString componentsSeparatedByString:@"."];
            NSArray *arrayOfDollor = [newString componentsSeparatedByString:@"$"];
            NSArray *arrayOfRupee = [newString componentsSeparatedByString:@"₹"];
            
            if ([arrayOfString count] > 2  ||[arrayOfDollor count] > 2  ||[arrayOfRupee count] > 2 ) {
                return NO;
            }
            else {
                //checking number of characters after dot.
                 NSRange range = [newString rangeOfString:@"."];
                if ([newString containsString:@"."] && range.location == (newString.length - 4)) {
                  return NO;
                }
                else {
                  return YES;

                }
            }
        }
        else {
           
            return [string isEqualToString:filtered];
        }
        
//        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        NSString *expression = @"^[+|-]*[0-9]*.[0-9]{1,2}";
//        NSError *error = nil;
//        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
//        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString options:0 range:NSMakeRange(0, [newString length])];
//        return numberOfMatches != 0;
    }
    return  YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == priceTextField) {
        [purchaseLinkTextField becomeFirstResponder];
        [priceTextField resignFirstResponder];
        return NO;
    }
    else if (textField == purchaseLinkTextField) {
        [UIView animateWithDuration:0.4 animations:^{
            CGRect frame = self.view.bounds;
            frame.origin.y = 40;
            self.view.frame = frame;
        }completion:^(BOOL FINSHED) {
            [purchaseLinkTextField resignFirstResponder];
            [priceTextField resignFirstResponder];
        }];
        return NO;
    }
    return YES;
}



- (void)segmentAction:(UISegmentedControl *)segment
{
    float w = [[UIScreen mainScreen]bounds].size.width;
    float h = [[UIScreen mainScreen]bounds].size.height;
    
    switch (segment.selectedSegmentIndex) {
        case 0:
            str = @"business";
            uploadType = @"business";
            //[Helper showAlertWithTitle:@"Post Type" Message:@"Businss Selected"];
            if(!prodSubLbl.hidden)
                _topConstraintOfAddLocationView.constant = 70+businessPostView.frame.size.height;
            else
                _topConstraintOfAddLocationView.constant = 70+businessPostView.frame.size.height-40;
            [self.baseScrollview setScrollEnabled:YES];
            [self.baseScrollview setContentSize:CGSizeMake(w, h+180)];
            [businessPostView setHidden:NO];
            break;
        case 1:
            //[Helper showAlertWithTitle:@"Post Type" Message:@"Individual Selected"];
            _topConstraintOfAddLocationView.constant = 70;
            [self.baseScrollview setScrollEnabled:NO];
            str = @"Individual";
            uploadType = @"Individual";
            
            [businessPostView setHidden:YES];
            break;
            
        default:
            break;
    }
}



- (void)selectorBtn:(id)sender {
    
    if (keyboardH <10) {
        //keyboard is opened
        
        UIButton *likeButton = (UIButton *)sender;
        selectedType = (int)(likeButton.tag);
        //posttypeSelect
        [self performSegueWithIdentifier:@"sharingToSelect" sender:self];
    }
    else {
        //keyboard is closed
        [UIView animateWithDuration:0.2 animations: ^{
            CGRect frame = self.view.bounds;
            frame.origin.y = 40;
            self.view.frame = frame;
            [self.view layoutIfNeeded];
            
            [purchaseLinkTextField endEditing:YES];
            [priceTextField endEditing:YES];
        } completion:^(BOOL finished) {
            UIButton *likeButton = (UIButton *)sender;
            selectedType = (int)(likeButton.tag);
            //posttypeSelect
            [self performSegueWithIdentifier:@"sharingToSelect" sender:self];
        }];
    }
}

-(void)hideSubcategory
{
    _topConstraintOfAddLocationView.constant = 70+businessPostView.frame.size.height-40;
    
    CGRect subCatframe = prodSubCategoryView.frame;
    subCatframe.size.height = 0;
    prodSubCategoryView.frame = subCatframe;
    
    [self businessViewScaling];
    
    [prodSubLbl setHidden:YES];
    [subCateLbl setHidden:YES];
    [subCategorybtn setHidden:YES];
    [nextView2 setHidden:YES];
}

-(void)businessViewScaling
{
    CGRect prodLineFrame = subProdLine.frame;
    prodLineFrame.origin.y = CGRectGetMaxY(prodSubCategoryView.frame);
    subProdLine.frame = prodLineFrame;
    
    
    CGRect currFrame = currencyView.frame;
    currFrame.origin.y = CGRectGetMaxY(prodSubCategoryView.frame);
    currencyView.frame = currFrame;
    
    CGRect priceFrame = price.frame;
    priceFrame.origin.y = CGRectGetMaxY(currencyView.frame);
    price.frame = priceFrame;
    
    CGRect currencyLblLineFrame =  currencyLblLine.frame;
    currencyLblLineFrame.origin.y = CGRectGetMaxY(currencyView.frame);
    currencyLblLine.frame = currencyLblLineFrame;
    
    CGRect priceLineFrame =  priceLine.frame;
    priceLineFrame.origin.y = CGRectGetMaxY(price.frame);
    priceLine.frame = priceLineFrame;
    
    CGRect purchFrame = PurchaseLink.frame;
    purchFrame.origin.y = CGRectGetMaxY(price.frame);
    PurchaseLink.frame = purchFrame;
    
    CGRect purchLinkLineFrame =  PurchaseLinkLine.frame;
    purchLinkLineFrame.origin.y = CGRectGetMaxY(PurchaseLink.frame);
    PurchaseLinkLine.frame = purchLinkLineFrame;
}
-(void)unhideSubCategory
{
    _topConstraintOfAddLocationView.constant = 70+businessPostView.frame.size.height;
    
    CGRect subCatframe = prodSubCategoryView.frame;
    subCatframe.size.height = 40;
    prodSubCategoryView.frame = subCatframe;
    
    [self businessViewScaling];
    
    [prodSubLbl setHidden:NO];
    [subCateLbl setHidden:NO];
    [subCategorybtn setHidden:NO];
    [nextView2 setHidden:NO];
}

- (void)moveViewToTop:(UITextView *)textView{
    [UIView animateWithDuration:0.4 animations:^{
        CGRect frame = self.view.bounds;
        frame.origin.y = - 70;
        self.view.frame = frame;
    }];
}

-(NSMutableAttributedString *)supscriptString :(NSString *)customestr
{
    NSUInteger len = customestr.length;
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc]initWithString:customestr];
    
    [attributedTitle addAttribute:(NSString*)kCTSuperscriptAttributeName value:@"1" range:NSMakeRange(len-1, 1)];
    
    return  attributedTitle;
    
}
@end
