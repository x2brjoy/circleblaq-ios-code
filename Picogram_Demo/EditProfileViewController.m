//
//  EditProfileViewController.m
//  Pods
//
//  Created by Rahul Sharma on 5/5/16.
//
#import "EditProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "ProgressIndicator.h"
#import "TinderGenericUtility.h"
#import "TWPhotoPickerController.h"
#import "Cloudinary/Cloudinary.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "FBLoginHandler.h"
#import "UIImageView+WebCache.h"
#import  "FontDetailsClass.h"
#import "Cloudinary.h"
#import "Helper.h"

@interface EditProfileViewController ()<FBLoginHandlerDelegate,CLUploaderDelegate,WebServiceHandlerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UITextViewDelegate> {
    
 
    NSArray *pickerArray;
    CLCloudinary *cloudinary;
    NSString *oldprofilePicUrl;
    UIActivityIndicatorView *av;
    NSDictionary *cloundinaryCreditinals;
    BOOL  isUploadImageToCloudinary;
    BOOL needToShowAlertForSavingChanges;
    NSString *newProfilePicImagePath;
}

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self pickerForGenderSelection];
    [self createNavLeftButton];
    [self createTapGestureForView];
    [self createTapGestureScrollDownView];
    [self createTapGestureForProfileImageAndLabel];
    [self convertProfileImageToRoundedShape];
    [self navBarCustomization];
    [self gettingCloudinaryCredntials];
    oldprofilePicUrl = _profilepicurl;
    isUploadImageToCloudinary = NO;
    
    NSString *bussinessStatus = [Helper bussinessAccountStatus];
    if ([bussinessStatus isEqualToString:@"1"]) {
//   if ([Helper isBusinessAccount]) {
               self.businessNameLbl.hidden = NO;
        self.businessIconImg.hidden = NO;
        [self.scrollViewOutlet setContentSize:CGSizeMake(320, 800)];
    }
    else {
        self.bussinessBioTextViewSuperViewHeightConstr.constant =0;
        self.businessNameLbl.hidden = YES;
        self.businessIconImg.hidden = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedPhoneNumberdataReceived:) name:@"passPhoneData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedEmaildataReceived:) name:@"passEmailData" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:self.userNameTextfield];
    
    self.bioTextViewOutlet.delegate =self;
    
    self.bioTextViewOutlet.autocorrectionType = UITextAutocorrectionTypeNo;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.websiteTextField) {
        if ([self.websiteTextField.text isEqualToString:@""]) {
           // self.websiteTextField.text = @"http://www.";
        }
     }
}


-(void)textFieldTextChanged:(id)sender {
    NSString *convertString = self.userNameTextfield.text;
    self.userNameTextfield.text = [convertString lowercaseString];
    if ([convertString containsString:@" "]) {
        if ([self.userNameTextfield.text length] > 0) {
            self.userNameTextfield.text = [self.userNameTextfield.text substringToIndex:[self.userNameTextfield.text length] - 1];
            NSString *addUnderScore = [self.userNameTextfield.text stringByAppendingString:@"_"];
            self.userNameTextfield.text = addUnderScore;
        }
    }
}

-(void) gettingCloudinaryCredntials{
    cloundinaryCreditinals =[[NSUserDefaults standardUserDefaults]objectForKey:cloudinartyDetails];
}
-(void)navBarCustomization {
    self.navigationItem.title =@"Edit Profile";
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
}

-(void)pickerForGenderSelection {
    pickerArray = [[NSArray alloc]initWithObjects:@"Not Specified",@"Male",@"Female",nil];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.hidden = YES;
}

-(void)updatedPhoneNumberdataReceived:(NSNotification *)noti {
    _phoneNumberTextField.text =  [NSString stringWithFormat:@"%@", noti.object[@"updatedPhoneNumber"]];
}

-(void)updatedEmaildataReceived:(NSNotification *)noti {
    _emailTextField.text = noti.object[@"updatedEmailId"];
}

-(void)viewWillAppear:(BOOL)animated {
    
    
   self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    
    
    if (_necessarytocallEditProfile) {
        // Requesting For Post Api.(passing "token" as parameter)
        NSDictionary *requestDict = @{
                                      mauthToken :flStrForObj([Helper userToken]),
                                      };
        [WebServiceHandler RequestTypeEditProfile:requestDict andDelegate:self];
        
        
        //showing activity view.
        self.viewForActivityIndicator.hidden =NO;
        self.viewForDetails.hidden = YES;
        
        
        [self createActivityViewInNavbar];
        
        _necessarytocallEditProfile=NO;
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    }
}

//method for creating activityview in  navigation bar right.
- (void)createActivityViewInNavbar {
    av = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [av setFrame:CGRectMake(0,0,50,30)];
    [self.view addSubview:av];
    av.tag  = 1;
    [av startAnimating];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:av];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    self.userNameTextfield.tintColor = [UIColor blueColor];
}

#pragma mark
#pragma mark - rounded image.

-(void)convertProfileImageToRoundedShape {
    [self.view layoutIfNeeded];
    _profileImageViewOutlet.image = _profilepic;
    _profileImageViewOutlet.layer.cornerRadius = _profileImageViewOutlet.frame.size.height/2;
    _profileImageViewOutlet.clipsToBounds = YES;
}

#pragma mark
#pragma mark - navigation bar buttons

//method for creating navigation bar left button.
- (void)createNavLeftButton {
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    [navCancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [navCancelButton addTarget:self
                        action:@selector(CancelButtonAction:)
              forControlEvents:UIControlEventTouchUpInside];
    navCancelButton.titleLabel.font = [UIFont fontWithName:RobotoRegular size:17];
    [navCancelButton setFrame:CGRectMake(10.0f,0.0f,60,40)];
    
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

//method for creating navigation bar right button.
- (void)createNavRightButton {
    
    UIButton *navDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navDoneButton setTitle:@"Done"
                   forState:UIControlStateNormal];
    [navDoneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    navDoneButton.titleLabel.font = [UIFont fontWithName:RobotoRegular size:17];
    [navDoneButton setFrame:CGRectMake(0,0,50,30)];
    [navDoneButton addTarget:self action:@selector(DoneButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navDoneButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

//action for navigation bar items (buttons).

- (void)CancelButtonAction:(UIButton *)sender {
    if(needToShowAlertForSavingChanges) {
        UIAlertView *alertForSavingProfileOrNot = [[UIAlertView alloc] initWithTitle:@"Unsaved Changes" message:@"You have unsaved changes.Are you sure you want to cancel?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertForSavingProfileOrNot.tag = 1254895;
        [alertForSavingProfileOrNot show];
    }
    else {
        [self goBack];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1254895) {
        if(buttonIndex == 1)//cancel pressed
        {
            [self goBack];
            //               [self dismissViewControllerAnimated:NO completion:nil];
            //               [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)DoneButtonAction:(UIButton *)sender {
    [self hideKeyboard];
    
    // if there is no user name just need to show the alert.
    //   username is mandatory.
    
    if ([_userNameTextfield.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please Choose a User Name" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    else if ([_userNameTextfield.text length] > 30 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Select username less than 30 characters" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    else if ([_fullNameTextField.text length] > 30 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Select fullname less than 30 characters" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    else if (self.bioTextViewOutlet.text.length > 150) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Bio should be less than 150 characters" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    else {
        if (![self.websiteTextField.text isEqualToString:@""]) {
            if (![self validateUrl:self.websiteTextField.text]) {
                UIAlertView *erroralert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"enter valid website url" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [erroralert show];
            }
            else {
                if (isUploadImageToCloudinary) {
                    ProgressIndicator *loginPI = [ProgressIndicator sharedInstance];
                    [loginPI showPIOnView:self.view withMessage:@"Updating Details"];
                    [self uploadingImageToCloudinary:newProfilePicImagePath];
                }
                else {
                    [self requestForSavingProfile];
                }
            }
        }
        else {
            //checking is necceassry to upload image to cloudinary.
            if (isUploadImageToCloudinary) {
                ProgressIndicator *loginPI = [ProgressIndicator sharedInstance];
                [loginPI showPIOnView:self.view withMessage:@"Updating Details"];
                [self uploadingImageToCloudinary:newProfilePicImagePath];
            }
            else {
                [self requestForSavingProfile];
            }
        }
        
    }
}


-(void)requestForSavingProfile {
    ProgressIndicator *loginPI = [ProgressIndicator sharedInstance];
    [loginPI showPIOnView:self.view withMessage:@"Updating Details"];
    
    NSString *bioText = flStrForObj(self.bioTextViewOutlet.text);
    if ([self.bioTextViewOutlet.text isEqualToString:@"Bio"]) {
        bioText = @"";
    }
    NSDictionary *requestDict;
    // Requesting For Post Api.(passing "token" as parameter)
    
    NSString *bussinessStatus = [Helper bussinessAccountStatus];
    
    if ([bussinessStatus isEqualToString:@"1"]) {
    //if ([Helper isBusinessAccount]) {
        UITextView *textV = (UITextView *)[self.view viewWithTag:5];
        
        requestDict = @{
                        mauthToken :flStrForObj([Helper userToken]),
                        mUserName:flStrForObj(self.userNameTextfield.text),
                        mfullName :flStrForObj(self.fullNameTextField.text),
                        //                                  mbio:flStrForObj(self.bioTextField.text),
                        mbio:flStrForObj(bioText),
                        mwebsite:flStrForObj(self.websiteTextField.text),
                        mgender:flStrForObj(self.genderLabel.text),
                        mProfileUrl:flStrForObj(_profilepicurl),
                        mbusinessName:flStrForObj(_businessNameLbl.text),
                        maboutBusiness:flStrForObj(textV.text),
                    };
    }
   else
   {requestDict = @{
                                  mauthToken :flStrForObj([Helper userToken]),
                                  mUserName:flStrForObj(self.userNameTextfield.text),
                                  mfullName :flStrForObj(self.fullNameTextField.text),
                                  //                                  mbio:flStrForObj(self.bioTextField.text),
                                  mbio:flStrForObj(bioText),
                                  mwebsite:flStrForObj(self.websiteTextField.text),
                                  mgender:flStrForObj(self.genderLabel.text),
                                  mProfileUrl:flStrForObj(_profilepicurl)
                                  };}
    [WebServiceHandler RequestTypeSavingProfile:requestDict andDelegate:self];
}




- (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx = @"((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?";
    
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    
    if ([urlTest evaluateWithObject:candidate]) {
        if ([candidate containsString:@".."]) {
            return false;
        }
        else {
            return true;
        }
    }
    else {
        return false;
    }
}


-(void)createTapGestureForProfileImageAndLabel {
    //tapGesture hiding keyBoard.
    UITapGestureRecognizer *tapForImage = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(showactionShett)];
    tapForImage.delegate = self;
    [self.profileImageViewOutlet addGestureRecognizer:tapForImage];
    
    UITapGestureRecognizer *tapForLabel =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showactionShett)];
    tapForLabel.delegate = self ;
    [self.editLabel addGestureRecognizer:tapForLabel];
    
}

-(void)createTapGestureForView {
    //tapGesture hiding keyBoard.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(showPickerView)];
    tap.delegate = self;
    [self.genderView addGestureRecognizer:tap];
}

-(void)createTapGestureScrollDownView {
    //tapGesture hiding keyBoard.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(scrollDown)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

-(void)scrollDown {
}

-(void)showPickerView {
    [UIView animateWithDuration:0.4 animations:^{
        self.viewTopConstraint.constant = -60;
        [self.view layoutIfNeeded];
        self.pickerView.hidden = NO;
    }];
}
-(void)showactionShett {
    [self hideKeyboard];
    
    UIActionSheet *acctionSheet = [[UIActionSheet alloc] initWithTitle:@"Change Profile Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Current Photo" otherButtonTitles:@"Import from Facebook",@"Take Photo",@"Choose From Library", nil];
    [acctionSheet showInView:self.view];
}

-(void)hideKeyboard {
    [self.emailTextField resignFirstResponder];
    [self.phoneNumberTextField resignFirstResponder];
    [self.userNameTextfield resignFirstResponder];
    [self.fullNameTextField resignFirstResponder];
    [self.bioTextField resignFirstResponder];
    [self.bioTextViewOutlet resignFirstResponder];
    [self.websiteTextField resignFirstResponder];
}



-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.bioTextViewOutlet.text  isEqual: @"Bio"]) {
        [textView setText:@""];
        textView.textColor = [UIColor blackColor];
    }
    if(textView.tag == 5)
    {
        [self viewMoveUp];
    }
}

-(void)adjustContentSize:(UITextView*)tv{
    CGFloat deadSpace = ([tv bounds].size.height - [tv contentSize].height);
    CGFloat inset = MAX(0, deadSpace/2.0);
    tv.contentInset = UIEdgeInsetsMake(inset, tv.contentInset.left, inset, tv.contentInset.right);
}

-(void)textViewDidChange:(UITextView *)textView
{
    
    if(textView.tag  == 5 ) {
        CGRect newFramae = self.aboutbussinessTextViewOutlet.frame;
        newFramae.size.height = textView.contentSize.height;
        if(newFramae.size.height  < 40 ) {
            self.bussinessBioTextViewSuperViewHeightConstr.constant = 150;
        }
        else {
            if (newFramae.size.height < 120) {
                self.bussinessBioTextViewSuperViewHeightConstr.constant = 115 + newFramae.size.height;
            }
        }
    }
    else {
        needToShowAlertForSavingChanges = YES;
        //    [self adjustContentSize:self.bioTextViewOutlet];
        
        CGRect newFramae = self.bioTextViewOutlet.frame;
        newFramae.size.height = self.bioTextViewOutlet.contentSize.height;
        
        if(newFramae.size.height  < 40 ) {
            self.topViewHeightConstraint.constant = 200;
            
        }
        else {
            if (newFramae.size.height < 120) {
                self.topViewHeightConstraint.constant = 165 + newFramae.size.height;
            }
        }
    }
}

-(void)updateHeightOfTextView{
    CGRect newFramae = self.bioTextViewOutlet.frame;
    newFramae.size.height = self.bioTextViewOutlet.contentSize.height;
    
    if(newFramae.size.height  < 40 ) {
        self.topViewHeightConstraint.constant = 200;
    }
    else {
        self.topViewHeightConstraint.constant = 165 + newFramae.size.height;
    }
}

-(void)updateHeightOfBusinessTextView{
    CGRect newFramae = self.aboutbussinessTextViewOutlet.frame;
    newFramae.size.height = self.aboutbussinessTextViewOutlet.contentSize.height;
    
    if(newFramae.size.height  < 40 ) {
        self.bussinessBioTextViewSuperViewHeightConstr.constant = 150;
    }
    else {
        
        NSLog(@"aboutbusinessContarins:%f",self.bussinessBioTextViewSuperViewHeightConstr.constant);
        self.bussinessBioTextViewSuperViewHeightConstr.constant = 100 + newFramae.size.height;
        NSLog(@"Changed aboutbusinessContarins:%f",self.bussinessBioTextViewSuperViewHeightConstr.constant);
       // self.bussinessBioTextViewSuperViewHeightConstr.constant = 50 + newFramae.size.height;
    }
}

-(void)textViewDidChangeSelection:(UITextView *)textView
{
    
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.bioTextViewOutlet.text.length == 0) {
        [textView setText:@"Bio"];
        textView.textColor = [UIColor lightGrayColor];
    }
    if (textView.tag == 5) {
        [self viewMoveDown];
    }
}

/*-----------------------------------*/
#pragma mark
#pragma mark - textfield Delegates.
/*-----------------------------------*/

/**
 *  giving implementation to key board return button.
 *
 */

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _fullNameTextField) {
        [ _userNameTextfield becomeFirstResponder];
    }
    
    else if (textField ==_userNameTextfield) {
        [ _websiteTextField becomeFirstResponder];
    }
    else if (textField == _websiteTextField) {
        [_bioTextField becomeFirstResponder];
        [_bioTextViewOutlet becomeFirstResponder];
    }
    else if(textField == _bioTextField){
        [_bioTextField resignFirstResponder];
    }
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
        [textView resignFirstResponder];
    return YES;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _websiteTextField || textField == _bioTextField || textField == _fullNameTextField || textField == _userNameTextfield) {
        needToShowAlertForSavingChanges = YES;
    }
    
    if(textField == _userNameTextfield) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
        
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        if ([string isEqualToString:filtered]) {
            textField.tintColor = [UIColor blueColor];
        }
        else {
            textField.tintColor = [UIColor redColor];
        }
        return [string isEqualToString:filtered];
    }

    return  YES;
}

/*-------------------------------------------------------------*/
#pragma
#pragma mark - ScrollView Delegate(For Update Posts).(PAGING)
/*-------------------------------------------------------------*/

- (void)scrollViewDidScroll: (UIScrollView *)scroll {
    CGFloat currentOffset = scroll.contentOffset.y;
    NSLog(@"%f",currentOffset);
    if (currentOffset < -64) {
        [UIView animateWithDuration:0.2 animations:^{
            self.viewTopConstraint.constant = 20;
            [self.view layoutIfNeeded];
            self.pickerView.hidden = YES;
        }];
    }
}

#pragma mark - Picker View Data source
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component{
    return [pickerArray count];
}

#pragma mark- Picker View Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:
(NSInteger)row inComponent:(NSInteger)component{
    [self.genderLabel setText:[pickerArray objectAtIndex:row]];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:
(NSInteger)row forComponent:(NSInteger)component{
    return [pickerArray objectAtIndex:row];
}

/*--------------------------------------*/
#pragma mark
#pragma mark -  action sheet
/*--------------------------------------*/

//uiaction sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    needToShowAlertForSavingChanges = YES;
    if  ([buttonTitle isEqualToString:@"Import from Facebook"]) {
        
        NSDictionary *fbdetails = [[NSUserDefaults standardUserDefaults]objectForKey:@"userFbDetails"];
        
        if (fbdetails) {
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",fbdetails[@"id"]]];
            self.profilepicurl = pictureURL.absoluteString;
            
            [_profileImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:self.profilepicurl]];
            [self.view layoutIfNeeded];
            _profileImageViewOutlet.layer.cornerRadius = _profileImageViewOutlet.frame.size.height/2;
            _profileImageViewOutlet.clipsToBounds = YES;
            newProfilePicImagePath = nil;
            isUploadImageToCloudinary = NO;
        }
        else {
            //request for fb.
            FBLoginHandler *handler = [FBLoginHandler sharedInstance];
            [handler loginWithFacebook:self];
            [handler setDelegate:self];
        }
    }
    if ([buttonTitle isEqualToString:@"Take Photo"]) {
        
#if TARGET_IPHONE_SIMULATOR
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"IN SIMULATOR CAMERA IS NOT AVAILABLE" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
#else
        self.imgpicker = [[UIImagePickerController alloc] init];
        self.imgpicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imgpicker.delegate =self;
        [self presentViewController:self.imgpicker animated:YES completion:nil];
#endif
        
    }
    
    if ([buttonTitle isEqualToString:@"Choose From Library"]) {
        TWPhotoPickerController *photoPickr = [[TWPhotoPickerController alloc] init];
        photoPickr.viewFromProfileSelector = @"itisForProfilePhoto";
        photoPickr.cropBlock = ^(UIImage *image) {
            [self.profileImageViewOutlet setImage:image];
            
            UIImage  *selectedProfileThumbNailImage = [self imageWithImage:image scaledToSize:CGSizeMake(50,50)];
            
            NSData *thumbNaildata = UIImagePNGRepresentation(selectedProfileThumbNailImage);
            NSString *thumbNailimageName = [NSString stringWithFormat:@"%@%@.png",@"ThumbnailImage",[self getCurrentTime]];
            //to get the image path.
            NSArray* Thumbnailpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* thumabNaildocumentsDirectory = [Thumbnailpaths objectAtIndex:0];
            NSString* ThumbnailimagePath = [thumabNaildocumentsDirectory stringByAppendingPathComponent:thumbNailimageName];
            [thumbNaildata writeToFile:ThumbnailimagePath atomically:NO];
            
            isUploadImageToCloudinary = YES;
            newProfilePicImagePath = ThumbnailimagePath;
            _profilepicurl = @"wait need to upload image to cloudinary";
            
            [self.view layoutIfNeeded];
            
            _profileImageViewOutlet.layer.cornerRadius = _profileImageViewOutlet.frame.size.height/2;
            _profileImageViewOutlet.clipsToBounds = YES;
        };
        [self presentViewController:photoPickr animated:YES completion:NULL];
    }
    
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        
    }
    
    if  ([buttonTitle isEqualToString:@"Remove Current Photo"]) {
        _profileImageViewOutlet.image = [UIImage imageNamed:@"defaultpp"];
        _profilepicurl = @"default Url";
    }
}

/*--------------------------------------------*/
#pragma mark
#pragma mark - imageResizing.
/*--------------------------------------------*/

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(NSString*)getCurrentTime {
    NSDate *currentDateTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // Set the dateFormatter format
    //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    // or this format to show day of the week Sat,11-12-2011 23:27:09
    [dateFormatter setDateFormat:@"EEEMMddyyyyHHmmss"];
    // Get the date time in NSString
    NSString *dateInStringFormated = [dateFormatter stringFromDate:currentDateTime];
    //  //NSLog(@"%@", dateInStringFormated);
    return dateInStringFormated;
    // Release the dateFormatter
    //[dateFormatter release];
}

/*-----------------------------------------*/
#pragma mark
#pragma mark - image picker(camera photo)
/*-----------------------------------------*/

//image picker
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    NSData *dataimage = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"], 1);
    
    UIImage *selectedProfileImage =[[UIImage alloc] initWithData:dataimage];
    
    UIImage  *selectedProfileThumbNailImage = [self imageWithImage:selectedProfileImage scaledToSize:CGSizeMake(50,50)];
    
    NSData *data = UIImagePNGRepresentation(selectedProfileImage);
    NSString *imageName = [NSString stringWithFormat:@"%@%@.png",@"Image",[self getCurrentTime]];
    //to get the image path.
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* imagePath = [documentsDirectory stringByAppendingPathComponent:imageName];
    [data writeToFile:imagePath atomically:NO];
    
    
    NSData *thumbNaildata = UIImagePNGRepresentation(selectedProfileThumbNailImage);
    NSString *thumbNailimageName = [NSString stringWithFormat:@"%@%@.png",@"ThumbnailImage",[self getCurrentTime]];
    //to get the image path.
    NSArray* Thumbnailpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* thumabNaildocumentsDirectory = [Thumbnailpaths objectAtIndex:0];
    NSString* ThumbnailimagePath = [thumabNaildocumentsDirectory stringByAppendingPathComponent:thumbNailimageName];
    [thumbNaildata writeToFile:ThumbnailimagePath atomically:NO];
    
    // storing the captured image to gallery.(optional)
    UIImage *storingImage = [[UIImage alloc] initWithData:data]; // if u want to store original captured image then keep dataimage instead of data.
    [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[storingImage CGImage] orientation:(ALAssetOrientation)[storingImage imageOrientation] completionBlock:nil];
    //uploading image to cloudinary.
    isUploadImageToCloudinary = YES;
    newProfilePicImagePath = ThumbnailimagePath;
    _profilepicurl = @"wait need to upload image to cloudinary";
    
    //setting image to the imageview and converting into rounded.
    [self.profileImageViewOutlet setImage:selectedProfileImage];
    [self.view layoutIfNeeded];
    _profileImageViewOutlet.layer.cornerRadius = _profileImageViewOutlet.frame.size.height/2;
    _profileImageViewOutlet.clipsToBounds = YES;
    [self.imgpicker dismissViewControllerAnimated:YES completion:nil];
}

/*--------------------------------------------*/
#pragma mark
#pragma mark - cloudinaryImageUploadingDelegates.
/*--------------------------------------------*/

- (void) uploaderSuccess:(NSDictionary*)result context:(id)context {
    NSString* publicId = [result valueForKey:@"public_id"];
    NSLog(@"Upload success. Public ID=%@, Full result=%@", publicId, result);
    _profilepicurl = result[@"secure_url"];
    [self requestForSavingProfile];
    isUploadImageToCloudinary = NO;
}

- (void) uploaderError:(NSString*)result code:(int) code context:(id)context {
   // NSLog(@"Upload error: %@, %d", result, code);
}

- (void) uploaderProgress:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite context:(id)context {
   // NSLog(@"Upload progress: %ld/%d (+%d)", (long)totalBytesWritten, totalBytesExpectedToWrite, bytesWritten);
}




/*---------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*---------------------------------*/

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    [av stopAnimating];
    [self createNavRightButton];
    
    //hiding activity view.
    self.viewForActivityIndicator.hidden = YES;
    self.viewForDetails.hidden = NO;
    
    if (error) {
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        return;
    }
    
    //storing the response from server to dictonary.
    NSDictionary *responseDict = (NSDictionary*)response;
    //checking the request type and handling respective response code.
    if (requestType == RequestTypeSavingProfile ) {
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
                //updating dictonary and saving new dictonary(in nsuserdefaults)
                //updating token value in dictonary and saving.
                NSString *newTokenValue =response[@"token"];
                NSString *newUserName =  response[@"data"][@"username"];
                NSMutableDictionary *newDict = [[NSMutableDictionary alloc] init];
                NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:userDetailKey];
                NSDictionary  *oldDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [newDict addEntriesFromDictionary:oldDict];
                [newDict setObject:newTokenValue forKey:@"token"];
                [newDict setObject:newUserName forKey:@"username"];
                
                //[[NSUserDefaults standardUserDefaults] setObject:newDict forKey:userDetailKey];
                NSData *dataSave = [NSKeyedArchiver archivedDataWithRootObject:newDict];
                [[NSUserDefaults standardUserDefaults] setObject:dataSave forKey:userDetailKey];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProfilePic" object:[NSDictionary dictionaryWithObject:responseDict forKey:@"profilePicUrl"]];
                
                if (flStrForObj(responseDict[@"data"][@"phoneNumber"]).length) {
                    [[NSUserDefaults standardUserDefaults]setObject:flStrForObj(responseDict[@"data"][@"phoneNumber"]) forKey:@"ProfileContact"];
                }
                if (flStrForObj(responseDict[@"data"][@"email"]).length) {
                    [[NSUserDefaults standardUserDefaults]setObject:flStrForObj(responseDict[@"data"][@"email"]) forKey:@"ProfileEmail"];
                }
                if (flStrForObj(responseDict[@"data"][@"bio"]).length) {
                    [[NSUserDefaults standardUserDefaults]setObject:flStrForObj(responseDict[@"data"][@"bio"]) forKey:@"Profilebio"];
                }
                if (flStrForObj(responseDict[@"data"][@"website"]).length) {
                    [[NSUserDefaults standardUserDefaults]setValue:flStrForObj(responseDict[@"data"][@"website"]) forKey:@"ProfileWebUrl"];
                }
                
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                
                
                [self goBack];
            }
                break;
                //failure response.
            case 198: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 400: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1973: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1974: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }
    
    //checking the request type and handling respective response code.
    if (requestType == RequestTypeEditProfile ) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [[ProgressIndicator sharedInstance] hideProgressIndicator];
                if (flStrForObj(responseDict[@"data"][@"name"])) {
                    self.fullNameTextField.text = flStrForObj(responseDict[@"data"][@"fullName"]);
                }
                if (flStrForObj(responseDict[@"data"][@"username"])) {
                    self.userNameTextfield.text = flStrForObj(responseDict[@"data"][@"username"]);
                }
                if (flStrForObj(responseDict[@"data"][@"phoneNumber"])) {
                    self.phoneNumberTextField.text = flStrForObj(responseDict[@"data"][@"phoneNumber"]);
                }
                if (flStrForObj(responseDict[@"data"][@"email"])) {
                    self.emailTextField.text = flStrForObj(responseDict[@"data"][@"email"]);
                }
                if (flStrForObj(responseDict[@"data"][@"bio"])) {
                    self.bioTextField.text = flStrForObj(responseDict[@"data"][@"bio"]);
                    self.bioTextViewOutlet.text =  flStrForObj(responseDict[@"data"][@"bio"]);
                    if ([self.bioTextViewOutlet.text isEqualToString:@""]) {
                        self.bioTextViewOutlet.text = @"Bio";
                        self.bioTextViewOutlet.textColor = [UIColor lightGrayColor];
                    }
                    
                    
                    [self updateHeightOfTextView];
                }
                NSString *category = flStrForObj(responseDict[@"data"][@"businessName"]);
                if (category.length) {
                    self.businessNameLbl.text = flStrForObj(responseDict[@"data"][@"businessName"]);
                }
                 NSString *subCategory = flStrForObj(responseDict[@"data"][@"aboutBusiness"]);
                if (subCategory.length) {
                    self.aboutbussinessTextViewOutlet.text = flStrForObj(responseDict[@"data"][@"aboutBusiness"]);
                    [self updateHeightOfBusinessTextView];
                }
                if (flStrForObj(responseDict[@"data"][@"websiteUrl"])) {
                    self.websiteTextField.text = flStrForObj(responseDict[@"data"][@"websiteUrl"]);
                }
                if (flStrForObj(responseDict[@"data"][@"profilePicUrl"])) {
                    _profilepicurl= flStrForObj(responseDict[@"data"][@"profilePicUrl"]);
                    [_profileImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:_profilepicurl]];
                    [_profileImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:_profilepicurl] placeholderImage:[UIImage imageNamed:@"defaultpp"]];
                    [self.view layoutIfNeeded];
                    _profileImageViewOutlet.layer.cornerRadius = _profileImageViewOutlet.frame.size.height/2;
                    _profileImageViewOutlet.clipsToBounds = YES;
                }
                if (flStrForObj(responseDict[@"data"][@"gender"])) {
                    self.genderLabel.text = flStrForObj(responseDict[@"data"][@"gender"]);
                    if ([self.genderLabel.text isEqualToString:@""]) {
                        self.genderLabel.text = @"Not Specified";
                    }
                }
            }
                break;
                //failure response.
            case 1971: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1972: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1973: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            case 1974: {
                [self errAlert:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }
}

- (void)errAlert:(NSString *)message {
    //creating alert for error message.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];
    [alert show];
}

- (IBAction)emailAddressButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"updateEmailVcSegue" sender:nil];
}

- (IBAction)phoneNumberButtonAction:(id)sender {
    [self performSegueWithIdentifier:@"editProfileToPhoneNumberVerification" sender:nil];
}



/*------------------------------------------------*/
#pragma mark
#pragma mark - facebook handler
/*-------------------------------------------------*/

/**
 *  Facebook login is success
 *  @param userInfo Userdict
 */

- (void)didFacebookUserLoginWithDetails:(NSDictionary*)userInfo {
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1",userInfo[@"id"]]];
    self.profilepicurl = pictureURL.absoluteString;
    
    [_profileImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:self.profilepicurl]];
    [self.view layoutIfNeeded];
    _profileImageViewOutlet.layer.cornerRadius = _profileImageViewOutlet.frame.size.height/2;
    _profileImageViewOutlet.clipsToBounds = YES;
    
    newProfilePicImagePath = nil;
    isUploadImageToCloudinary = NO;
}

/**
 *  Login failed with error
 *
 *  @param error error
 */
- (void)didFailWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

/**
 *  User cancelled
 */

- (void)didUserCancelLogin {
    NSLog(@"USER CANCELED THE LOGIN");
}

-(void)uploadingImageToCloudinary:(NSString *)imagePath {
    
    CLCloudinary *mobileCloudinary = [[CLCloudinary alloc] init];
    [mobileCloudinary.config setValue:cloundinaryCreditinals[@"response"][@"cloudName"] forKey:@"cloud_name"];
    CLUploader* mobileUploader = [[CLUploader alloc] init:mobileCloudinary delegate:self];
    
    [mobileUploader upload:imagePath options:@{
                                               @"signature":cloundinaryCreditinals[@"response"][@"signature"],
                                               @"timestamp": cloundinaryCreditinals[@"response"][@"timestamp"],
                                               @"api_key": cloundinaryCreditinals[@"response"][@"apiKey"],
                                               }];
}

//image need to upload when take photo or select from library
//for fb i will get link so no need to upload in cloudinary
//for remove photo default url is there
//no need to call cloudinary  if user not changed d profil pic.

-(void)goBack {
    if ([_pushingVcFrom isEqualToString:@"ProfileScreen"]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)viewMoveUp {
    
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.view setFrame:CGRectMake(0,-250,self.view.frame.size.width,self.view.frame.size.height)];
                         //[self.view layoutIfNeeded];
                     }];
}

-(void)viewMoveDown {
    
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         [self.view setFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
                         //[self.view layoutIfNeeded];
                     }];
}

@end
