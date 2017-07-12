//
//  TLYTableViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 11/13/15.
//  Copyright © 2015 Telly, Inc. All rights reserved.
//

#import "HomeViewTableViewController.h"
#import "TLYShyNavBarManager.h"
#import "HomeViewTableViewCell.h"
#import "HomeViewCommentsViewController.h"
#import "LikeViewController.h"
#import "ShareViewXib.h"
#import "TLYShyStatusBarController.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "ProgressIndicator.h"
#import "UIImageView+WebCache.h"
#import "KILabel.h"
#import "HashTagViewController.h"
#import "UIImageView+AFNetworking.h"
#import  "UserProfileViewController.h"
#import "UIImage+GIF.h"
#import "TinderGenericUtility.h"
#import <SCRecorder/SCPlayer.h>
#import <SCRecorder/SCVideoPlayerView.h>
#import <SCRecorder/SCRecordSession.h>
#import <AVKit/AVKit.h>
#import "PhotosPostedByLocationViewController.h"
#import "Cloudinary.h"
#import "UIScrollView+SVPullToRefresh.h"
#import  "UIScrollView+SVInfiniteScrolling.h"
#import "FontDetailsClass.h"
#import "PGDiscoverPeopleViewController.h"
#import "WDUploadProgressView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareVideo.h>
#import <FBSDKShareKit/FBSDKShareOpenGraphContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareVideoContent.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKShareKit/FBSDKShareAPI.h>
#import <FBSDKShareKit/FBSDKSharePhotoContent.h>
#import "SharingPostViewController.h"
#import "Helper.h"
@import FirebaseInstanceID;

@interface HomeViewTableViewController () <UITableViewDataSource, UITableViewDelegate,shareViewDelegate,WebServiceHandlerDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate,SCPlayerDelegate,SDWebImageManagerDelegate,CLUploaderDelegate,WDUploadProgressDelegate> {
    
    UIRefreshControl *refreshControl;
    ShareViewXib *shareNib;
    
    
    BOOL noPostsAreAvailable;
    //for handing response.
    NSMutableArray *responseData;
    
    //for tableview Delegates And DataSource.
    CGFloat heightOfTheRow;
    
    SCPlayer *player;
    NSString *comment;
    
    //for pagination.
    NSInteger pageNumber;
    WDUploadProgressView *progressView;
    
    //adding for uploading image/video.
    NSDictionary *cloundinaryCreditinals;
    NSString *VideoUrl;
    NSString *thumbimageforvideourl;
    NSString *thumbNailUrl;
    NSString *mainUrl;
}

@end
@implementation HomeViewTableViewController

/*---------------------------------------------------*/
#pragma
#pragma mark - view Delagtes.
/*----------------------------------------------------*/
- (void)viewDidLoad {
    [super viewDidLoad];
    [self navbarCustomizing];
    [self showingProgressindicator];
    [self hidingViewsIntially];
    pageNumber = 0;
    [self addingRefreshControl];
    [self serviceRequestingForPosts:pageNumber];
    cloundinaryCreditinals =[[NSUserDefaults standardUserDefaults]objectForKey:cloudinartyDetails];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedCommentsdata:) name:@"passingUpdatedCommentsToHomeScreen" object:nil];
    
    NSString *token = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", token);
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:mdeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


-(void)updatedCommentsdata:(NSNotification *)noti {
    NSInteger updateCellNumber  = [noti.object[@"newCommentsData"][@"selectedCell"] integerValue];
    NSString *updatedComment = flStrForObj(noti.object[@"newCommentsData"][@"data"][0][@"commenTs"]);
    [[responseData objectAtIndex:updateCellNumber] setObject:updatedComment forKey:@"comments"];
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:updateCellNumber] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)viewWillAppear:(BOOL)animated {
    
    if(noPostsAreAvailable) {
        pageNumber = 0;
        [self serviceRequestingForPosts:pageNumber];
    }
    
    if (_startUpload) {
        dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(backgroundQueue, ^{
            //BACKGROUND
            [self checkUploadImageOrVideo];
            _startUpload = 0;
            dispatch_async(dispatch_get_main_queue(), ^{
                //FOREGROUND
            });
        });
    }
}

//unhiding status bar.
-(BOOL)prefersStatusBarHidden {
    return NO;
}

/*----------------------------------------------------------------------------*/
#pragma
#pragma mark - ViewDidLoad Method Implementation.
/*----------------------------------------------------------------------------*/
-(void)hidingViewsIntially {
    //intially the tableview and addcontactsview will hide and if there is no posts avaiulable then viewWhenNopostsAvailable will shown and if any posts available then tableview will shown.
    self.tableView.hidden =YES;
    self.viewWhenNopostsAvailable.hidden =YES;
}

-(void)navbarCustomizing {
    //title view for navbar.
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_picogram_logo"]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    
    //<<<<<<< Updated upstream
    //    UIImage *backbuttonImage = [UIImage imageNamed:@"discovery_people_contact_icon"];
    //    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    backButton.frame = CGRectMake( 0.0f, 0.0f,backbuttonImage.size.width, backbuttonImage.size.height);
    //    [backButton addTarget:self action:@selector(directChatButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //    [backButton setBackgroundImage:[UIImage imageNamed:@"discovery_people_contact_icon"] forState:UIControlStateNormal];
    //    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    //=======
    UIImage *backbuttonImage = [UIImage imageNamed:@"directChat_icon_Off"];
    UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    chatButton.frame = CGRectMake( 0.0f, 0.0f,backbuttonImage.size.width, backbuttonImage.size.height);
    [chatButton addTarget:self action:@selector(directChatButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [chatButton setBackgroundImage:[UIImage imageNamed:@"directChat_icon_Off"] forState:UIControlStateNormal];
    [chatButton setBackgroundImage:[UIImage imageNamed:@"directChat_icon_On"] forState:UIControlStateHighlighted];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
    
}


- (IBAction)directChatButtonAction:(id)sender {
    
    [self performSegueWithIdentifier:@"homeToInsta" sender:nil];

    //[self performSegueWithIdentifier:@"homeToDirectChat" sender:nil];
}

-(void)showingProgressindicator {
    //showing progress indicator and requesting for posts.
    ProgressIndicator *HomePI = [ProgressIndicator sharedInstance];  [HomePI showPIOnView:self.view withMessage:@"Loading..."];
}



-(void)addingRefreshControl {
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
}
-(void)refreshTable:(id)sender {
    //reload table
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    pageNumber = 0;
    [self serviceRequestingForPosts:pageNumber];
    
}

/*-------------------------------------------------------------------------*/
#pragma
#pragma mark - tableview delegates and data source.
/*------------------------------------------------------------------------*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (responseData.count) {
        noPostsAreAvailable =NO;
    }
    else {
        noPostsAreAvailable = YES;
    }
    
    return responseData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_startUpload)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fileForUpload"] count])
        {
            return [[[NSUserDefaults standardUserDefaults] objectForKey:@"fileForUpload"] count];
        }
        else
        {
            return 1;
        }
    }
    else
    {
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section !=0 &&  section == responseData.count -1  ) {
        if(responseData.count %10 == 0) {
            
            //            UIView *footerView = [[UIView alloc] init];
            //            [footerView setBackgroundColor:[UIColor whiteColor]];
            //            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            //            activityIndicator.frame = CGRectMake(self.view.frame.size.width/2-20,0, 40, 40.0);
            //            [footerView addSubview:activityIndicator];
            //            [activityIndicator startAnimating];
            
            [self requestForMorePosts];
            UIView *emptyview = [[UIView alloc] init];
            return emptyview;
        }
        else {
            UIView *emptyview = [[UIView alloc] init];
            return emptyview;
        }
    }
    else {
        
        UIView *emptyview = [[UIView alloc] init];
        return emptyview;
    }
}

-(void)loadMore:(id)sender {
    NSLog(@"load more clicked");
}

//Custom Header (it contains profile image of the posted person and his/her username and time label and location if available.)

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // creating custom header view
    
    UIView *view;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fileForUpload"] count])
    {    // creating custom header view
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
        view.backgroundColor =[UIColor whiteColor];
    }
    else
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
        view.backgroundColor =[UIColor whiteColor];
    }
    
    /* Create custom view to display section header... */
    
    //creating user name label
    UILabel *UserNamelabel = [[UILabel alloc] init];
    UserNamelabel.text = flStrForObj(responseData[section][@"postedByUserName"]);
    [UserNamelabel setFont:[UIFont fontWithName:RobotoMedium size:14]];
    UserNamelabel.textColor =[UIColor colorWithRed:0.1568 green:0.1568 blue:0.1568 alpha:1.0];
    
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *placeName = flStrForObj(responseData[section][@"place"]);
    if ([placeName isEqualToString:@"[object Object]"]) {
        placeName = @"";
        locationButton.enabled = NO;
    }
    
    locationButton.titleLabel.font = [UIFont fontWithName:RobotoRegular size:14];
    locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [locationButton addTarget:self
                       action:@selector(locationButtonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
    [locationButton setTitle:placeName forState:UIControlStateNormal];
    [locationButton setTitleColor: [UIColor blackColor] forState:
     UIControlStateNormal];
    
    //creating post time label
    UILabel *timeLabel = [[UILabel alloc] init];
    
    timeLabel.text =@"";
    [timeLabel setFont:[UIFont fontWithName:RobotoRegular size:14]];
    timeLabel.textColor =[UIColor colorWithRed:0.5686 green:0.5686 blue:0.5686 alpha:1.0];
    
    //creating  total  header  as button
    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [headerButton addTarget:self
                     action:@selector(headerButtonClicked:)
           forControlEvents:UIControlEventTouchUpInside];
    headerButton.backgroundColor =[UIColor whiteColor];
    headerButton.tag = 10000 + section ;
    
    //creating user image on tableView Header
    UIImageView *UserImageView =[[UIImageView alloc] init];
    
    //need some default image url if user has no profile pic.
    [UserImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(responseData[section][@"profilePicUrl"])]
                     placeholderImage:[UIImage imageNamed:@"defaultpp"]];
    
    
    //updating profilepicture of the post user.
    
    if ([flStrForObj(responseData[section][@"profilePicUrl"]) isEqualToString:@"defaultUrl"]) {
        UserImageView.image = [UIImage imageNamed:@"defaultpp.png"];
    }
    else {
        [UserImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(responseData[section][@"profilePicUrl"])] placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
    }
    
    //setting position of headerButton,UserImageView,timeLabel in customized  tableView Section Header.
    //if there is no place then usernamelabel will come in middle
    if ([placeName isEqualToString:@""]) {
        UserNamelabel.frame=CGRectMake(60, 20, self.view.frame.size.width - 100, 15);
    }
    else {
        UserNamelabel.frame=CGRectMake(60, 10, self.view.frame.size.width - 100, 15);
    }
    
    locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 120, 15);
    timeLabel.frame =CGRectMake(tableView.frame.size.width-50, 20, 50, 15);
    UserImageView.frame = CGRectMake(10,8,40,40);
    
     [self.view layoutIfNeeded];
    UserImageView.layer.cornerRadius = UserImageView.frame.size.height/2;
    UserImageView.clipsToBounds = YES;
    headerButton.frame = CGRectMake(0, 1, tableView.frame.size.width,56);
    
    
    // adding  headerButton,UserImageView,timeLabel,UserNamelabel to the customized tableView  Section Header.
    
    [view addSubview:headerButton];
    [view addSubview:UserImageView];
    [view addSubview:timeLabel];
    [view addSubview:UserNamelabel];
    [view addSubview:locationButton];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeViewTableViewCell *homeTableViewcell;
    homeTableViewcell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                        forIndexPath:indexPath];
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"fileForUpload"] count] && indexPath.section==0)
    {
        
    }
    
    homeTableViewcell.imageViewHeightConstraint.constant = 320;
    
    //giving height for imageview but its is not fixed it must be vary on every image height.
    //    homeTableViewcell.imageViewHeightConstraint.constant = 320;
    
    //downloading image and updating in imageview by using sd_webimage(it is very fast).
    //if image is not downloaded then default loading image will shown(it is gif formated).
    
    UIView *view = (UIView *)[homeTableViewcell viewWithTag:12345];
    [view removeFromSuperview];
    
    if ([flStrForObj(responseData[indexPath.section][@"postsType"]) isEqualToString:@"1"]) { //video
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [homeTableViewcell.postedImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:responseData[indexPath.section][@"thumbnailImageUrl"]]
                                                       placeholderImage:[UIImage sd_animatedGIFNamed:@"loading"]];
            [player setItemByUrl:[NSURL URLWithString:responseData[indexPath.section][@"mainUrl"]]];
        });
        player = [SCPlayer player];
        player.delegate = self;
        SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:player];
        playerView.frame = CGRectMake(0,0,self.view.frame.size.width,320);
        NSLog(@"player view frame is :%f",playerView.frame.size.height);
        playerView.tag = 12345;
        [homeTableViewcell.postedImageViewOutlet addSubview:playerView];
        [homeTableViewcell.postedImageViewOutlet bringSubviewToFront:playerView];
        player.loopEnabled = YES;
        player.muted = NO;
        [player play];
    }
    else //image
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [homeTableViewcell.postedImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:responseData[indexPath.section][@"mainUrl"]]
                                                       placeholderImage:[UIImage sd_animatedGIFNamed:@"loading"]];
        });
    }
    
    homeTableViewcell.timeLabelOutlet.text =  [Helper convertEpochToNormalTime:responseData[indexPath.section][@"postedOn"]];
    
    [homeTableViewcell.listOfPeopleLikedThePostButton addTarget:self action:@selector(likeButton:) forControlEvents:UIControlEventTouchUpInside];
    [homeTableViewcell.shareButtonOutlet addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [homeTableViewcell.showTagsButtonOutlet addTarget:self action:@selector(showTagsAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (responseData[indexPath.section][@"likedByUser"]){
        homeTableViewcell.personsLikedinfoLabelOutlet.text =  [NSString stringWithFormat:@"%@", flStrForObj(responseData[indexPath.section][@"likes"])];
    }
    else{
        homeTableViewcell.personsLikedinfoLabelOutlet.text =  [NSString stringWithFormat:@"%@", flStrForObj(responseData[indexPath.section][@"likedByUser"])];
    }
    
    
    if (![responseData[indexPath.section][@"usersTagged"]  containsString:@"undefined"])  {
        if ([flStrForObj(responseData[indexPath.section][@"postsType"]) isEqualToString:@"1"]) {
            homeTableViewcell.showTagsButtonOutlet.hidden = YES;
        }
        else {
            homeTableViewcell.showTagsButtonOutlet.hidden = NO;
        }
    }
    else {
        homeTableViewcell.showTagsButtonOutlet.hidden = YES;
    }
    
    [self showCommentsOnPost:indexPath.section tableviewCell:homeTableViewcell];
    [self customizingCaption:indexPath.section tableviewCell:homeTableViewcell];
    
    //setting Tags For  Different Items
    //alloting tag for every button and imageView.
   // homeTableViewcell.moreButtonOutlet.tag = 1000 + indexPath.section;
    homeTableViewcell.postedImageViewOutlet.tag = 5000 + indexPath.section;
    
    if ([[Helper userName] isEqualToString: flStrForObj(responseData[indexPath.section][@"postedByUserName"])])
    {
        homeTableViewcell.postType = @"myPost";
        homeTableViewcell.moreButtonOutlet.tag = 1000 + indexPath.section;
    }else
    {
        homeTableViewcell.postType = @"followingPost";
        homeTableViewcell.moreButtonOutlet.tag = 2000 + indexPath.section;
    }

    
    //in posts details it contains 4 fixed buttons(for every post). they are like,shrae,comment and more.
    [homeTableViewcell.moreButtonOutlet addTarget:self
                                           action:@selector(moreButtnAction:)
                                 forControlEvents:UIControlEventTouchUpInside];
    [homeTableViewcell.viewAllCommentsButtonOutlet addTarget:self action:@selector(viewAllCommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [homeTableViewcell.commentButtonOutlet addTarget:self action:@selector(CommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //setting heightContsraintFor Label and cell(according to labels height).
    [self HeightConstraintForLabels:homeTableViewcell];
    //handling hashTags and UserNames.
    homeTableViewcell.userNameWithCaptionOutlet.userInteractionEnabled =YES;
    homeTableViewcell.commentLabelOne.userInteractionEnabled = YES;
    homeTableViewcell.commentLabelTwo.userInteractionEnabled = YES;
    [self updateLikeButtonStatus:indexPath.section tableviewCell:homeTableViewcell];
    [self handlingHashTags:homeTableViewcell];
    [self handlingURLLink:homeTableViewcell];
    [self handlinguserName:homeTableViewcell];
    
    [self creatingTapGesturePostedImage:homeTableViewcell.postedImageViewOutlet];
    return homeTableViewcell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return heightOfTheRow;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected section  %ld",(long)indexPath.section);
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([flStrForObj(responseData[indexPath.section][@"postsType"]) isEqualToString:@"1"]) { //video
        [player play];
    }
    else {
        [player pause];
    }
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}



/*----------------------------------------------------------------------------*/
#pragma
#pragma mark - tableview Header Buttons And Actions.
/*----------------------------------------------------------------------------*/

//in tableview header loaction of the post is there so if any place user added the we need to show respective place posts(if available).

-(void)locationButtonClicked:(id)sender {
    UIButton *selectedLoaction = (UIButton *)sender;
    PhotosPostedByLocationViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"photosPostedByLoactionVCStoryBoardId"];
    postsVc.navtitle = selectedLoaction.titleLabel.text;
    [self.navigationController pushViewController:postsVc animated:YES];
}

//headerbutton action.(if user clicked on that header then it respective user profile will shown).
- (void)headerButtonClicked :(id)sender {
    UIButton *selectedHeaderButton = (UIButton *)sender;
    NSInteger selectedIndex = selectedHeaderButton.tag % 10000;
    
    NSIndexPath *selectedCellHeader = [_tableView indexPathForCell:(UITableViewCell *)[[[[sender superview] superview] superview] superview]];
    NSLog( @"selected hearder is :%ld",(long)selectedCellHeader.section);
    
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkProfileOfUserNmae = flStrForObj(responseData[selectedIndex][@"postedByUserName"]);
    newView.checkingFriendsProfile = YES;
    [self.navigationController pushViewController:newView animated:YES];
}

//S
//***
-(void)userNameTapped:(UITapGestureRecognizer *)tapGesture
{
    UILabel *selectedLabel = (UILabel *)tapGesture.view;
    NSInteger selectedIndex = selectedLabel.tag % 8000;
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkProfileOfUserNmae =flStrForObj(responseData[selectedIndex][@"postedByUserName"]);
    newView.checkingFriendsProfile = YES;
    [self.navigationController pushViewController:newView animated:YES];
}

-(void)HeightConstraintForLabels:(id)sender {
    HomeViewTableViewCell *receivedCell = (HomeViewTableViewCell *)sender;
    
    //setting height constraints.
    
    if([comment isEqualToString:@"null"]) {
        receivedCell.userNameWithCaptionHeightConstraint.constant = 0;
    }
    else {
        // for caption label.
        receivedCell.userNameWithCaptionHeightConstraint.constant = [Helper heightOfText:receivedCell.userNameWithCaptionOutlet];
    }
    
    if([receivedCell.commentLabelOne.text isEqualToString:@""]) {
        receivedCell.firstCommentHeightConstraint.constant = 0;
    }
    else {
        //for first comment label.
        
        receivedCell.firstCommentHeightConstraint.constant = [Helper heightOfText:receivedCell.commentLabelOne];
    }
    
    if([receivedCell.commentLabelOne.text isEqualToString:@""]) {
        receivedCell.secondCommentHeightConstraint.constant = 0;
    }
    else {
        //for secondComments Label.
        
        receivedCell.secondCommentHeightConstraint.constant = [Helper heightOfText:receivedCell.commentLabelTwo];
    }
    
    //need to check.
    if (![receivedCell.commentLabelOne.text isEqualToString:@""] && ![receivedCell.commentLabelTwo.text isEqualToString:@""]) {
        receivedCell.viewAllCommentsHeightConstraint.constant = 20;
        receivedCell.viewAllCommentsButtonOutlet.hidden = NO;
    }
    else {
        receivedCell.viewAllCommentsHeightConstraint.constant = 0;
        receivedCell.viewAllCommentsButtonOutlet.hidden = YES;
    }
    
    // for likes view
    if([receivedCell.personsLikedinfoLabelOutlet.text isEqualToString:@"0"]) {
        receivedCell.listOfPeopleLikedThePostButton.enabled = NO;
    }
    else
    {
        receivedCell.listOfPeopleLikedThePostButton.enabled = YES;
    }
    
    //captionAndCommentview is along with comments(first and second) and like view (number of likes) and caption.
    receivedCell.captionAndCommentHeightConstraint.constant = receivedCell.userNameWithCaptionHeightConstraint.constant +   receivedCell.firstCommentHeightConstraint.constant  +receivedCell.secondCommentHeightConstraint.constant + receivedCell.timeLabelHeightConstraint.constant + receivedCell.viewAllCommentsButtonOutlet.frame.size.height;
    
    //totallikeButtonsViewWithCommentsandCaptionView it is
    receivedCell.totallikeButtonsViewWithCommentsandCaptionViewHeightConstraint.constant = receivedCell.captionAndCommentHeightConstraint.constant + receivedCell.LikeViewHeightConstraint.constant;
    
    //total height of the section including with image,header and comments section(40 is tableview header height and it is fixed).
    heightOfTheRow = receivedCell.totallikeButtonsViewWithCommentsandCaptionViewHeightConstraint.constant + 15 + receivedCell.imageViewHeightConstraint.constant + 40 ;
}

/*------------------------------------------------------*/
#pragma
#pragma mark - Show Tags On Image.
/*------------------------------------------------------*/

-(void)showTagsAction:(id)sender {
    
    NSIndexPath *selectedButtontToShowTags = [_tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    // Get the subviews of the view
    NSArray *subviewsfff =  [[sender superview] subviews];
    
    
    
    for (UIView *subview in subviewsfff) {
        NSLog(@"%@", subview);
    }
    
    UIView *view = (UIView *) subviewsfff[0];
    
    NSArray *namesOfTaggedPeople = [responseData[selectedButtontToShowTags.section][@"usersTagged"] componentsSeparatedByString:@","];
    
    // if there is no one tagged then from response by defaultly we are getting undefined so handling that.
    if ([namesOfTaggedPeople[0]  isEqualToString:@"undefined"]) {
        namesOfTaggedPeople = nil;
    }
    
    if (!view.subviews.count) {
        for( int i = 0; i < namesOfTaggedPeople.count; i++ ) {
            UIButton *customButton;
            customButton = [UIButton buttonWithType: UIButtonTypeCustom];
            [customButton setBackgroundColor: [UIColor clearColor]];
            [customButton setTitleColor:[UIColor blackColor] forState:
             UIControlStateHighlighted];
            //sets background image for normal state
            [customButton setBackgroundImage:[UIImage imageNamed:
                                              @"tag_people_tittle_btn"]
                                    forState:UIControlStateNormal];
            [customButton setBackgroundImage:[UIImage imageNamed:@"tag_people_tittle_btn"] forState:UIControlStateHighlighted];
            [customButton setTitle:[namesOfTaggedPeople objectAtIndex:i] forState:UIControlStateNormal];
            CGSize stringsize = [customButton.titleLabel.text sizeWithFont:[UIFont fontWithName:RobotoRegular size:13]];
            [customButton setFrame:CGRectMake(60, i*50, stringsize.width + 50, 30)];
            customButton.tag = 12345 + i;
            [customButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [UIView transitionWithView:view
                              duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [view addSubview:customButton];
                                [view bringSubviewToFront:customButton];
                                [self.view layoutIfNeeded];
                            }
                            completion:NULL];
        }
    }
    else {
        for (UIButton *eachButton in view.subviews) {
            [UIView transitionWithView:view
                              duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [eachButton removeFromSuperview];
                                [self.view layoutIfNeeded];
                            }
                            completion:NULL];
        }
    }
}

/*--------------------------------------------------------------*/
#pragma
#pragma mark - Caption And Comment
/*--------------------------------------------------------------*/

-(void)customizingCaption:( NSInteger )section tableviewCell:(id)sender{
    HomeViewTableViewCell *receivedCell = (HomeViewTableViewCell *)sender;
    
    //customizing CaptionLabel.
    //user name with status and changing the color and font  for username and status.
    NSString *postedUser = flStrForObj(responseData[section][@"postedByUserName"]);
    comment = flStrForObj(responseData[section][@"postCaption"]);
    NSString *commentWithUserName = [postedUser stringByAppendingFormat:@"  %@",comment];
    NSMutableAttributedString * attributtedComment = [[NSMutableAttributedString alloc] initWithString:commentWithUserName];
    [attributtedComment addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                               range:NSMakeRange(0,postedUser.length)];
    [attributtedComment addAttribute:NSFontAttributeName
                               value:[UIFont fontWithName:RobotoMedium size:14]
                               range:NSMakeRange(0, postedUser.length)];
    [receivedCell.userNameWithCaptionOutlet setAttributedText:attributtedComment];
}


-(void)showCommentsOnPost:(NSInteger )section tableviewCell:(id)sender {
    
    HomeViewTableViewCell *receivedCell = (HomeViewTableViewCell *)sender;
    
    NSArray *response =  [flStrForObj(responseData[section][@"comments"]) componentsSeparatedByString:@"^^"];
    NSMutableArray *arrayOffCommentedUserNames = [[NSMutableArray alloc]init];
    NSMutableArray * arrayOfComments = [[NSMutableArray alloc]init];
    for(int i=0;i <response.count-1;i++) {
        NSString* temp = [response objectAtIndex:i+1];
        NSString * userName = [temp componentsSeparatedByString:@"$$"][0];
        NSString * commen = [temp componentsSeparatedByString:@"$$"][1];
        [arrayOffCommentedUserNames addObject:userName];
        [arrayOfComments addObject:commen];
    }
    
    if (arrayOfComments.count == 0) {
        receivedCell.commentLabelOne.text = @"";
        receivedCell.commentLabelTwo.text = @"";
    }
    else if (arrayOfComments.count == 1) {
        NSString *commentedUser1 = flStrForObj(arrayOffCommentedUserNames[0]);
        NSString *commentedText1 = flStrForObj(arrayOfComments[0]);
        NSString *postcommentWithUserName1 = [commentedUser1 stringByAppendingFormat:@"  %@",commentedText1];
        
        NSMutableAttributedString * attributtedPostComment1 = [[NSMutableAttributedString alloc] initWithString:postcommentWithUserName1];
        [attributtedPostComment1 addAttribute:NSForegroundColorAttributeName
                                        value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                                        range:NSMakeRange(0,commentedUser1.length)];
        [attributtedPostComment1 addAttribute:NSFontAttributeName
                                        value:[UIFont fontWithName:RobotoMedium size:14]
                                        range:NSMakeRange(0, commentedUser1.length)];
        [receivedCell.commentLabelOne setAttributedText:attributtedPostComment1];
        receivedCell.commentLabelTwo.text = @"";
    }
    else {
        
        NSString *commentedUser1 = flStrForObj(arrayOffCommentedUserNames[arrayOffCommentedUserNames.count-1]);
        NSString *commentedText1 = flStrForObj(arrayOfComments[arrayOfComments.count-1]);
        NSString *commentedUser2 = flStrForObj(arrayOffCommentedUserNames[arrayOffCommentedUserNames.count -2]);
        NSString *commentedText2 = flStrForObj(arrayOfComments[arrayOfComments.count-2]);
        
        
        NSString *postcommentWithUserName1 = [commentedUser1 stringByAppendingFormat:@"  %@",commentedText1];
        NSString *postcommentWithUserName2 = [commentedUser2 stringByAppendingFormat:@"  %@",commentedText2];
        NSMutableAttributedString * attributtedPostComment1 = [[NSMutableAttributedString alloc] initWithString:postcommentWithUserName1];
        NSMutableAttributedString * attributtedPostComment2 = [[NSMutableAttributedString alloc] initWithString:postcommentWithUserName2];
        [attributtedPostComment1 addAttribute:NSForegroundColorAttributeName
                                        value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                                        range:NSMakeRange(0,commentedUser1.length)];
        [attributtedPostComment1 addAttribute:NSFontAttributeName
                                        value:[UIFont fontWithName:RobotoMedium size:14]
                                        range:NSMakeRange(0, commentedUser1.length)];
        [attributtedPostComment2 addAttribute:NSForegroundColorAttributeName
                                        value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                                        range:NSMakeRange(0,commentedUser2.length)];
        [attributtedPostComment2 addAttribute:NSFontAttributeName
                                        value:[UIFont fontWithName:RobotoMedium size:14]
                                        range:NSMakeRange(0, commentedUser2.length)];
        [receivedCell.commentLabelOne setAttributedText:attributtedPostComment1];
        [receivedCell.commentLabelTwo setAttributedText:attributtedPostComment2];
    }
}

/*------------------------------------------------*/
#pragma
#pragma mark - Like
/*-----------------------------------------------*/

-(void)updateLikeButtonStatus :(NSInteger )section tableviewCell:(id)sender {
    
    HomeViewTableViewCell *receivedCell = (HomeViewTableViewCell *)sender;
    
    NSString *likeStatus =  [NSString stringWithFormat:@"%@", responseData[section][@"likeStatus"]];
    
    if ([likeStatus  isEqualToString:@"0"]) {
        receivedCell.likeButtonOutlet  .selected = NO;
    }
    else  {
        receivedCell.likeButtonOutlet .selected = YES;
    }
    receivedCell.likeButtonOutlet.tag = 12365 + section;
    [receivedCell.likeButtonOutlet addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

//list of all persons who liked the post button.
-(void)likeButton:(id)sender {
    
    NSIndexPath *selectedCellForAllLikes = [_tableView indexPathForCell:(UITableViewCell *)[[[[sender superview] superview] superview] superview]];
    
    LikeViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"likeStoryBoardId"];
    newView.navigationTitle = @"Likers";
    newView.postId =  flStrForObj(responseData[selectedCellForAllLikes.section][@"postId"]);
    newView.postType = flStrForObj(responseData[selectedCellForAllLikes.section][@"postsType"]);
    [self.navigationController pushViewController:newView animated:YES];
}

-(void)likePostFromDoubleTap:(id)sender {
    
    UIButton *selectedButton = (UIButton *)sender;
    NSIndexPath *selectedCellForLike = [_tableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    
    //animating the like button.
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [ani setDuration:0.2];
    [ani setRepeatCount:1];
    [ani setFromValue:[NSNumber numberWithFloat:1.0]];
    [ani setToValue:[NSNumber numberWithFloat:0.5]];
    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[selectedButton layer] addAnimation:ani forKey:@"zoom"];
    
    // checking if the post is already liked or not .if it is already liked no need to perform anything otherwise we need to perform like action.
    
    NSString *likeStatus =  [NSString stringWithFormat:@"%@", responseData[selectedCellForLike.section][@"likeStatus"]];
    
    if ([likeStatus  isEqualToString:@"0"]) {
        selectedButton.selected = YES;
        [self likeAPost:selectedCellForLike.section];
        [[responseData objectAtIndex:selectedCellForLike.section] setObject:@"1" forKey:@"likeStatus"];
        NSInteger newNumberOfLikes = [responseData[selectedCellForLike.section][@"likes"] integerValue];
        newNumberOfLikes ++;
        [[responseData objectAtIndex:selectedCellForLike.section] setObject:[@(newNumberOfLikes) stringValue] forKey:@"likes"];
        
        NSArray *subviews =   [[[[sender superview] superview] superview] subviews];
        NSArray *subviw2 = [subviews[0] subviews];
        NSArray *subview3 =  [subviw2[4] subviews];
        NSArray *subview4 =  [subview3[0] subviews];
        
        //subview4[0] is the label for displaying number of likes.
        UILabel *totalLikeslabel =  (UILabel *)subview4[0];
        totalLikeslabel.text =  [NSString stringWithFormat:@"%@", flStrForObj(responseData[selectedCellForLike.section][@"likes"])];
        
        //   [_tableView reloadSections:[NSIndexSet indexSetWithIndex:selectedCellForLike.section] withRowAnimation:UITableViewRowAnimationNone];
    }
}

-(void)likeButtonAction:(id)sender {
    
    HomeViewTableViewCell *receivedCell ;
    
    UIButton *selectedButton = (UIButton *)sender;
    NSIndexPath *selectedCellForLike = [_tableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [ani setDuration:0.2];
    [ani setRepeatCount:1];
    [ani setFromValue:[NSNumber numberWithFloat:1.0]];
    [ani setToValue:[NSNumber numberWithFloat:0.5]];
    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[selectedButton layer] addAnimation:ani forKey:@"zoom"];
    
    if (selectedButton.selected) {
        selectedButton.selected = NO;
        [self unlikeAPost:selectedCellForLike.section];
        [[responseData objectAtIndex:selectedCellForLike.section] setObject:@"0" forKey:@"likeStatus"];
        NSInteger newNumberOfLikes = [responseData[selectedCellForLike.section][@"likes"] integerValue];
        newNumberOfLikes --;
        [[responseData objectAtIndex:selectedCellForLike.section] setObject:[@(newNumberOfLikes) stringValue] forKey:@"likes"];
        receivedCell.personsLikedinfoLabelOutlet.text = [NSString stringWithFormat:@"%@", flStrForObj(responseData[selectedCellForLike.section][@"likes"])];
        
        NSArray *subviews =   [[[[sender superview] superview] superview] subviews];
        NSArray *subviw2 = [subviews[0] subviews];
        NSArray *subview3 =  [subviw2[4] subviews];
        NSArray *subview4 =  [subview3[0] subviews];
        
        UILabel *totalLikeslabel =  (UILabel *)subview4[0];
        totalLikeslabel.text = [NSString stringWithFormat:@"%@", flStrForObj(responseData[selectedCellForLike.section][@"likes"])];
      
    }
    else {
        selectedButton.selected = YES;
        [self likeAPost:selectedCellForLike.section];
        [[responseData objectAtIndex:selectedCellForLike.section] setObject:@"1" forKey:@"likeStatus"];
        NSInteger newNumberOfLikes = [responseData[selectedCellForLike.section][@"likes"] integerValue];
        newNumberOfLikes ++;
        [[responseData objectAtIndex:selectedCellForLike.section] setObject:[@(newNumberOfLikes) stringValue] forKey:@"likes"];
        
        NSArray *subviews =   [[[[sender superview] superview] superview] subviews];
        NSArray *subviw2 = [subviews[0] subviews];
        NSArray *subview3 =  [subviw2[4] subviews];
        NSArray *subview4 =  [subview3[0] subviews];
        
        UILabel *totalLikeslabel =  (UILabel *)subview4[0];
        totalLikeslabel.text =  [NSString stringWithFormat:@"%@", flStrForObj(responseData[selectedCellForLike.section][@"likes"])];
        
        //        [_tableView reloadSections:[NSIndexSet indexSetWithIndex:selectedCellForLike.section] withRowAnimation:UITableViewRowAnimationNone];
    }
}

/*-----------------------------------------------------*/
#pragma
#pragma mark - MORE BUTTON
/*----------------------------------------------------*/

- (void)moreButtnAction:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    int tag = [sender tag];
    UIActionSheet *sheet;
    if(!(tag < 2000)){
        
        sheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Report",@"Share to Facebook", @"Copy Share URL", @"Turn on Post Notifications", nil];
        [sheet setTag:selectedButton.tag];
        
    }
    else
    {
        sheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Delete",@"Edit", @"Share", nil];
        [sheet setTag:selectedButton.tag];
        
    }
    [sheet showInView:self.view];
}



- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    int tag = popup.tag;
    if(!(tag < 2000)){
        
        switch (buttonIndex) {
            case 0:
                [self reportPost:tag%2000];
                break;
            case 1:
                [self shareToFacebook:tag%2000];
                break;
            case 2:
                [self copyShareURL:tag%2000];
                break;
            case 3:
                [self turnOnPostNotifications:tag%2000];
                break;
            default:
                break;
        }
    }
    else
    {
        
        if (buttonIndex == 0)
            [self deletePost:tag%1000];
        else if (buttonIndex == 1)
            [self copyShareURL:tag%1000];
        else if (buttonIndex == 2)
            [self sharePost:tag%1000];
        
       /* switch (buttonIndex) {
            case 0:
                [self deletePost:tag%1000];
                break;
            case 1:
                [self copyShareURL:tag%1000];
                break;
            case 2:
                [self sharePost:tag%1000];
                break;
            default:
                break;
        }*/
        
        
    }
}





-(void)shareToFacebook:(NSInteger )selectedSection {
    NSLog(@"SHAREtO FB of index :%ld ",(long)selectedSection);
   
   NSDictionary *dic = responseData[selectedSection];
        
        ProgressIndicator *pi = [ProgressIndicator sharedInstance];
        [pi showMessage:@"Posting.." On:self.view];
    
        if ([flStrForObj([dic objectForKey:@"postsType"] )isEqualToString:@"0"]) {
            // NSString *mediaLink = [self getWebLinkForFeed:feed];
            
            NSString *caption = @"";// NSLocalizedString(@"Checkout this cool app",nil);
            
            // NSString *description;
            
            NSString *picturelink = [Helper getWebLinkForFeed:responseData[selectedSection]]; //responseData[selectedSection][@"mainUrl"];
            
            //NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:picturelink]];
            
            NSMutableDictionary *params1 = [NSMutableDictionary dictionaryWithCapacity:3L];
            
            //[params1 setObject:videoData forKey:@"video.mov"];
            [params1 setObject:[NSURL URLWithString:picturelink] forKey:@"link"];
            [params1 setObject:caption forKey:@"title"];
            [params1 setObject:caption forKey:@"description"];
            
            
            [self makeFBPostWithParams:params1];
        }
        else{
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            
            ALAssetsLibraryWriteVideoCompletionBlock videoWriteCompletionBlock = ^(NSURL *newURL, NSError *error) {
                if (error)
                {
                    NSLog( @"Error writing image with metadata to Photo Library: %@", error );
                }
                else
                {
                    NSLog(@"Wrote image with metadata to Photo Library %@", newURL.absoluteString);
                    
                    FBSDKShareVideo* video = [FBSDKShareVideo videoWithVideoURL:newURL];
                    
                    FBSDKShareVideoContent* content = [[FBSDKShareVideoContent alloc] init];
                    content.video = video;
                    [FBSDKShareAPI shareWithContent:content delegate:nil];
                }
            };
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"Downloading Started");
                NSString *urlToDownload = responseData[selectedSection][@"mainUrl"];
                NSURL  *url = [NSURL URLWithString:urlToDownload];
                NSData *urlData = [NSData dataWithContentsOfURL:url];
                if ( urlData )
                {
                    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString  *documentsDirectory = [paths objectAtIndex:0];
                    
                    NSString  *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"thefile.mp4"];
                    
                    
                    
                    
                    //saving is done on main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [urlData writeToFile:filePath atomically:YES];
                        NSLog(@"File Saved !");
                        
                        
                        NSURL *videoURL = [NSURL URLWithString:filePath];
                        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:videoURL])
                        {
                            [library writeVideoAtPathToSavedPhotosAlbum:videoURL completionBlock:videoWriteCompletionBlock];
                        }
                        
                        
                    });
                }
                
            });
            
            
        }
    
}


/**
 *  NPost the media with its description on facebook
 *
 *  @param params mediatype,caption,mediaLink
 */

- (void) makeFBPostWithParams:(NSDictionary*)params
{
    
    NSData *imageData = [[NSData alloc] initWithContentsOfURL:params[@"link"]];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            FBSDKSharePhoto *sharePhoto = [[FBSDKSharePhoto alloc] init];
            sharePhoto.caption = params[@"title"]; //@"Test Caption";
            sharePhoto.image = image;//[UIImage imageNamed:@"BGI.jpg"];
            FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
            content.photos = @[sharePhoto];
            
            [FBSDKShareAPI shareWithContent:content delegate:nil];
        });
        
    }
    else{
        
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        [login logInWithPublishPermissions:@[@"publish_actions"] fromViewController:self
                                   handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                       if (error) {
                                           NSLog(@"Process error");
                                       } else if (result.isCancelled)
                                       {
                                           NSLog(@"Cancelled");
                                       }
                                       else
                                       {
                                           NSLog(@"Logged in");
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               FBSDKSharePhoto *sharePhoto = [[FBSDKSharePhoto alloc] init];
                                               sharePhoto.caption = params[@"title"]; //@"Test Caption";
                                               sharePhoto.image = image;//[UIImage imageNamed:@"BGI.jpg"];
                                               
                                               
                                               FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
                                               content.photos = @[sharePhoto];
                                               
                                               [FBSDKShareAPI shareWithContent:content delegate:nil];
                                           });
                                       }
                                   }];
        
    }
    
}



-(void)copyShareURL:(NSInteger )selectedSection {
    NSLog(@"copyShareURL of index :%ld ",(long)selectedSection);
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *copymainurl = responseData[selectedSection][@"mainUrl"];
    pasteboard.string = copymainurl;
}

-(void)turnOnPostNotifications:(NSInteger )selectedSection {
    NSLog(@"turnOnPostNotifications of index :%ld ",(long)selectedSection);
}

- (void)paste {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *string = pasteboard.string;
    NSLog(@"%@",string);
}

-(void)deletePost:(NSInteger)selectedSection{
    
}

-(void)sharePost:(NSInteger)selectedSection{
    
    [[NSUserDefaults standardUserDefaults]setInteger:selectedSection forKey:@"index"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    [self performSegueWithIdentifier:@"homeTosharingSegue" sender:self];
    
  /*  HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
    newView.navTittle = @"string";
    [self.navigationController pushViewController:newView animated:YES];
    
    SharingPostViewController *postshare = [self.storyboard instantiateViewControllerWithIdentifier:@"sharingPostStoryBoardId"];
    //[postshare.postDetailsDic setValue:responseData[selectedSection] forKey:@"postDetail"];
    //postshare.postDetailsDic = responseData[selectedSection];
    [self.navigationController pushViewController:postshare animated:YES];*/
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqualToString:@"homeTosharingSegue"]) {
        int index = [[NSUserDefaults standardUserDefaults]integerForKey:@"index"];
        SharingPostViewController *vc = [segue destinationViewController];
        vc.postDetailsDic =responseData[index];
        //sending fb id for registering.
        }
}



-(void)reportPost:(NSInteger)selectedSection{
    
    
}

/*--------------------------------------------------*/
#pragma
#pragma mark - Comment Section
/*---------------------------------------------------*/

-(void)viewAllCommentButtonAction:(id)sender {
    NSIndexPath *selectedCellForViewAllComments = [_tableView indexPathForCell:(UITableViewCell *)[[[[sender superview] superview] superview] superview]];
    
    HomeViewCommentsViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsStoryBoardId"];
    newView.postId = flStrForObj(responseData[selectedCellForViewAllComments.section][@"postId"]);
    newView.postCaption =  flStrForObj(responseData[selectedCellForViewAllComments.section][@"postCaption"]);
    newView.postType = flStrForObj(responseData[selectedCellForViewAllComments.section][@"postsType"]);
    newView.imageUrlOfPostedUser =  flStrForObj(responseData[selectedCellForViewAllComments.section][@"profilePicUrl"]);
    newView.selectedCellIs =selectedCellForViewAllComments.section;
    newView.userNameOfPostedUser = flStrForObj(responseData[selectedCellForViewAllComments.section][@"postedByUserName"]);
   
    [self.navigationController pushViewController:newView animated:YES];
}

-(void)CommentButtonAction:(id)sender {
    NSIndexPath *selectedCellForComment = [_tableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    NSLog( @"selected cell is :%ld",(long)selectedCellForComment.section);
    HomeViewCommentsViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsStoryBoardId"];
    newView.postId =  flStrForObj(responseData[selectedCellForComment.section][@"postId"]);
    newView.postCaption =  flStrForObj(responseData[selectedCellForComment.section][@"postCaption"]);
    newView.postType = flStrForObj(responseData[selectedCellForComment.section][@"postsType"]);
    newView.imageUrlOfPostedUser =  flStrForObj(responseData[selectedCellForComment.section][@"profilePicUrl"]);
    newView.selectedCellIs =selectedCellForComment.section;
    newView.userNameOfPostedUser = flStrForObj(responseData[selectedCellForComment.section][@"postedByUserName"]);
    [self.navigationController pushViewController:newView animated:YES];
}

/*----------------------------------------------*/
#pragma
#pragma mark - share
/*----------------------------------------------*/

-(void)shareButtonAction:(id)sender {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    shareNib = [[ShareViewXib alloc] init];
    shareNib.delegate = self;
    [shareNib showViewWithContacts:window];
}

-(void)cancelButtonClicked {
    [UIView animateWithDuration:0.4 animations:^{
        [shareNib removeFromSuperview];
        [self.view layoutIfNeeded];
    }completion:nil];
}

/*-----------------------------------------------------------------------------*/
#pragma
#pragma mark - Handling Hashtags,URL and UserNames.
/*------------------------------------------------------------------------------*/

-(void)handlingHashTags:(id)sender {
    
    HomeViewTableViewCell *receivedCell = (HomeViewTableViewCell *)sender;
    // Attach a block to be called when the user taps a hashtag.
    
    receivedCell.userNameWithCaptionOutlet.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
        newView.navTittle = string;
        [self.navigationController pushViewController:newView animated:YES];
    };
    receivedCell.commentLabelOne.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
        newView.navTittle = string;
        [self.navigationController pushViewController:newView animated:YES];
    };
    receivedCell.commentLabelTwo.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
        newView.navTittle = string;
        [self.navigationController pushViewController:newView animated:YES];
    };
}

-(void)handlinguserName:(id)sender {
    
    HomeViewTableViewCell *receivedCell = (HomeViewTableViewCell *)sender;
    // Attach a block to be called when the user taps a user handle.
    
    receivedCell.userNameWithCaptionOutlet.userHandleLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
        
        //removing @ from string.
        NSString *stringWithoutspecialCharacter = [string
                                                   stringByReplacingOccurrencesOfString:@"@" withString:@""];
        newView.checkProfileOfUserNmae = stringWithoutspecialCharacter;
        newView.checkingFriendsProfile = YES;
        [self.navigationController pushViewController:newView animated:YES];
    };
}

-(void)handlingURLLink :(id)sender {
    
    HomeViewTableViewCell *receivedCell = (HomeViewTableViewCell *)sender;
    
    // Attach a block to be called when the user taps a URL
    receivedCell.userNameWithCaptionOutlet.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        NSLog(@"URL tapped %@", string);
    };
}

/*---------------------------------------------------------------------------------------*/
#pragma
#pragma mark - (For Update Posts).(PAGING)
/*---------------------------------------------------------------------------------------*/

-(void)requestForMorePosts {
    if(responseData.count %10 == 0) {
        pageNumber++;
        [self serviceRequestingForPosts:pageNumber];
    }
}

/*---------------------------------------------------*/
#pragma
#pragma mark - DoubleTap For PostLike.
/*----------------------------------------------------*/

- (void) animateLike:(UITapGestureRecognizer *)sender{
    
    HomeViewTableViewCell *receivedCell ;
    
    for (UIButton *eachButton in receivedCell.postedImageViewOutlet.subviews) {
        [UIView transitionWithView:receivedCell.postedImageViewOutlet
                          duration:0
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [eachButton removeFromSuperview];
                            [self.view layoutIfNeeded];
                        }
                        completion:NULL];
    }
    
    
    UIView *view = sender.view;
    // [[view superview] subviews][1] -- is like image in tabeleview cell.
    // performing animation on that like image.
    
    //subView2[0]] -- is likebutton
    //calling like service.
    
    
    
    [[view superview] subviews][1].hidden = NO;
    [[view superview] subviews][1].alpha = 0;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [[view superview] subviews][1].transform = CGAffineTransformMakeScale(1.3, 1.3);
        [[view superview] subviews][1].alpha = 1.0;
    }
                     completion:^(BOOL finished) {
                         NSArray *subviews1 = [[view superview] subviews];
                         NSArray *subView2 =[subviews1[2] subviews];
                         [self likePostFromDoubleTap:subView2[0]];
                         
                         [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                             [[view superview] subviews][1].transform = CGAffineTransformMakeScale(1.0, 1.0);
                         }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                                                  [[view superview] subviews][1].transform = CGAffineTransformMakeScale(1.3, 1.3);
                                                  [[view superview] subviews][1].alpha = 0.0;
                                              }
                                                               completion:^(BOOL finished) {
                                                                   [[view superview] subviews][1].transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                               }];
                                          }];
                     }];
    
}

- (IBAction)findPeopleToFollowButtonAction:(id)sender {
    //  discoverPeopleStoryBoardId
    PGDiscoverPeopleViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:@"discoverPeopleStoryBoardId"];
    [self.navigationController pushViewController:postsVc animated:YES];
}


/*----------------------------------------------------------------------*/
#pragma mark
#pragma mark - WebServiceDelegate(Response)
/*----------------------------------------------------------------------*/

//handling response.

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    if (error) {
        [refreshControl endRefreshing];

        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        if (self.tableView.numberOfSections == 0) {
            self.tableView.hidden = NO;
            UIView *noDataAvailableMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [noDataAvailableMessageView setCenter:self.view.center];
            UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -100, self.view.frame.size.height/2 -20, 200,100)];
            message.numberOfLines =0;
            message.textAlignment = NSTextAlignmentCenter;
            message.text = [error localizedDescription];
            [noDataAvailableMessageView addSubview:message];
            self.tableView.backgroundColor = [UIColor whiteColor];
            self.tableView.backgroundView = noDataAvailableMessageView;
        }
        
         return;
    }
    
    if (self.tableView.numberOfSections > 0){
        self.tableView.backgroundView = nil;
    }
    
    
    NSDictionary *responseDict = (NSDictionary*)response;
    if (requestType == RequestTypePost) {
        
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        //success response(200 is for success code).
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [self serviceRequestingForPosts:pageNumber];
            }
                break;
                //failure responses.
            case 1986: {
                [self errrAlert:responseDict[@"message"]];
            }
                break;
            case 1987: {
                [self errrAlert:responseDict[@"message"]];
            }
                break;
            case 1988: {
                [self errrAlert:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }
    
    if (requestType == RequestTypegetPostsInHOmeScreen ) {
        [_tableView.pullToRefreshView stopAnimating];
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [self handleTheresponseOfHomeScreenPosts:responseDict];
            }
                break;
            default:
                break;
        }
    }
    else if (requestType == RequestTypeLikeAPost) {
    }
    else if (requestType == RequestTypeUnlikeAPost) {
    }
}

- (void)errrAlert:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];//Send via SMS
    [alert show];
}

-(void)handleTheresponseOfHomeScreenPosts:(NSDictionary *)receivedata {
    
    [refreshControl endRefreshing];
    
    // first time when view load or while pull to refresh.
    if (pageNumber==0) {
        responseData = receivedata[@"data"];
    }
    
    // if response is there then we need to show posts details otherwise we need to show  no postsavilable start following people.
    if (![receivedata[@"message"] isEqualToString:@"User and his followers have not posted anything"]) {
        if (pageNumber >0 ) {
            NSInteger indexOfNewSection = pageNumber*10;
            //just creating array for get the number of new posts.
            NSArray *arrayForNewPosts = receivedata[@"data"];
            for (int i =0; i <arrayForNewPosts.count; i++) {
                [self.tableView beginUpdates];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexOfNewSection]
                              withRowAnimation:UITableViewRowAnimationNone];
                //updating data array.
                [responseData addObject:receivedata[@"data"][i]];
                indexOfNewSection++;
                [self.tableView endUpdates];
            }
            if (responseData.count >1) {
                self.shyNavBarManager.scrollView=self.tableView;
                self.shyNavBarManager.stickyNavigationBar = NO;
            }
            else {
                self.shyNavBarManager.scrollView=self.tableView;
                self.shyNavBarManager.stickyNavigationBar = YES;
            }
        }
        else {
            //at very first time we need to reload the tableviw later just adding sections to the avilable posts.
            [self.tableView reloadData];
            self.tableView.hidden = NO;
        }
    }
    else {
        //if responseData count is zero then there is no posts availbale.
        self.viewWhenNopostsAvailable.hidden = NO;
    }
}


-(void)dealloc {
    self.tableView.delegate = nil;
    self.tableView.dataSource =nil;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [player pause];
}

-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [self clearImageCache];
}

-(void)clearImageCache{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
}

/*-------------------------------------------------------------------------------*/
#pragma mark - Uploading Image Or Video to Cloudinary.
/*--------------------------------------------------------------------------------*/

- (void)checkUploadImageOrVideo {
    
    // if  RECORD SESSION is available then user trying to upload video otherwise _recordsession is empty so show respective message.
    if (_recordsession) {
        progressView = [[WDUploadProgressView alloc] initWithTableView:self.tableView cancelButton:YES];
        progressView.delegate = self;
        
        // Add Here an image to show
        [progressView setPhotoImage:[UIImage imageNamed:@"uploading"]];
        // Additionally you can set the message at any time (Default: Uploading...)
        [progressView setUploadMessage:@"Uploading..."];
        // You can customize the progress tint color
        [progressView setProgressTintColor:[UIColor redColor]];
        
    }
    else {
        progressView = [[WDUploadProgressView alloc] initWithTableView:self.tableView cancelButton:YES];
        progressView.delegate = self;
        
        // Add Here an image to show
        [progressView setPhotoImage:[UIImage imageNamed:@"uploading"]];
        // Additionally you can set the message at any time (Default: Uploading...)
        [progressView setUploadMessage:@"Uploading..."];
        // You can customize the progress tint color
        [progressView setProgressTintColor:[UIColor redColor]];
        
    }
    
    //if both _recordsession and _pathOfVideo available then start uploading vide to cloudinary.
    //otherwise user trying to upload image so call uploading image to cloiusdinary .
    
    if (_recordsession && _pathOfVideo) {
        [self uploadingVideoToCloudinary];
    }
    else {
        [self uploadingImageToCloudinary];
    }
}

-(void)uploadingImageToCloudinary {
    CLCloudinary *mobileCloudinary = [[CLCloudinary alloc] init];
    [mobileCloudinary.config setValue:cloundinaryCreditinals[@"response"][@"cloudName"] forKey:@"cloud_name"];
    CLUploader* mobileUploader = [[CLUploader alloc] init:mobileCloudinary delegate:self];
    [mobileUploader upload:self.postedImagePath options:@{
                                                          @"signature":cloundinaryCreditinals[@"response"][@"signature"],
                                                          @"timestamp": cloundinaryCreditinals[@"response"][@"timestamp"],
                                                          @"api_key": cloundinaryCreditinals[@"response"][@"apiKey"],
                                                          }];
    [mobileUploader upload:self.postedthumbNailImagePath options:@{
                                                                   @"signature":cloundinaryCreditinals[@"response"][@"signature"],
                                                                   @"timestamp": cloundinaryCreditinals[@"response"][@"timestamp"],
                                                                   @"api_key": cloundinaryCreditinals[@"response"][@"apiKey"],
                                                                   }];
}

-(void)uploadingVideoToCloudinary {
    CLCloudinary *mobileCloudinary = [[CLCloudinary alloc] init];
    [mobileCloudinary.config setValue:cloundinaryCreditinals[@"response"][@"cloudName"] forKey:@"cloud_name"];
    CLUploader* mobileUploader = [[CLUploader alloc] init:mobileCloudinary delegate:self];
    [mobileUploader upload:self.pathOfVideo options:@{
                                                      @"signature":cloundinaryCreditinals[@"response"][@"signature"],
                                                      @"timestamp": cloundinaryCreditinals[@"response"][@"timestamp"],
                                                      @"api_key": cloundinaryCreditinals[@"response"][@"apiKey"],
                                                      @"resource_type": @"video"
                                                      }];
}

/*-----------------------------------------------------*/
#pragma mark - cloudinary delegate
/*----------------------------------------------------*/

- (void) uploaderSuccess:(NSDictionary*)result context:(id)context {
    
    
    
    NSString* publicId = [result valueForKey:@"public_id"];
    NSLog(@"Upload success. Public ID=%@, Full result=%@", publicId, result);
//    [self uploadDidFinish:progressView];
    if (_pathOfVideo) {
        //video url.
        VideoUrl =[result[@"url"] stringByReplacingOccurrencesOfString:@".mov"
                                                            withString:@".mp4"];
        NSString *str = VideoUrl;
        
        //getting thumbnailimage from video(just we need to change format of url .mov to .png).
        str = [str stringByReplacingOccurrencesOfString:@".mp4"
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

-(void)uploaderError:(NSString*)result code:(int)code context:(id)context {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"failed to  post" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    NSLog(@"Upload error: %@, %d", result, code);
}

- (void) uploaderProgress:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite context:(id)context {
   
    NSLog(@"Upload progress: %ld/%ld (+%ld)", (long)totalBytesWritten, (long)totalBytesExpectedToWrite, (long)bytesWritten);
    
    
    if (totalBytesExpectedToWrite > 0)
    {
        progressView.progress += totalBytesWritten / totalBytesExpectedToWrite;
    }
    else
    {
        progressView.progress= 0;
    }
}


/*-----------------------------------------------------*/
#pragma mark - Request For Services.
/*----------------------------------------------------*/

-(void)requestForpostingVideo {
    NSDictionary *requestDict = @{mtype    :@"1",
                                  mmailUrl :VideoUrl,
                                  mthumbeNailUrl :thumbimageforvideourl,
                                  mauthToken :[Helper userToken],
                                  musersTagged:_taggedFriendsString,
                                  mpostCaption :_caption,
                                  mhashTags :_hashTags,
                                  mlocation :_location,
                                  mlatitude:_lat,
                                  mhasAudio:@"0" ,
                                  mlongitude:_longi,
                                  mContainerHeight:@"100",
                                  mcontainerWidth:@"100",
                                  muserCoordinates:@"24"
                                  };
    [WebServiceHandler postImageOrVideo:requestDict andDelegate:self];
}

-(void)requestForpostingImage {
    NSDictionary *requestDict = @{mtype    :@"0",
                                  mmailUrl :mainUrl,
                                  mthumbeNailUrl :thumbNailUrl,
                                  mauthToken :[Helper userToken],
                                  musersTagged:_taggedFriendsString,
                                  mpostCaption : _caption,
                                  mhashTags :_hashTags,
                                  mlocation :_location,
                                  mlatitude:_lat,
                                  mlongitude:_longi,
                                  mContainerHeight:@"100",
                                  mcontainerWidth:@"100",
                                  muserCoordinates:@"24"

                                  };
    [WebServiceHandler postImageOrVideo:requestDict andDelegate:self];
}


-(void)serviceRequestingForPosts :(NSInteger )index {
    //service requesting
    NSDictionary *requestDict = @{
                                  mauthToken:flStrForObj([Helper userToken]),
                                  moffset:flStrForObj([NSNumber numberWithInteger:index*10]),
                                  mlimit:flStrForObj([NSNumber numberWithInteger:10])
                                  };
    [WebServiceHandler getPostsInHOmeScreen:requestDict andDelegate:self];
}

-(void)likeAPost:(NSInteger)selectedIndex
{
    NSDictionary *requestDict;
    NSString *postId = flStrForObj(responseData[selectedIndex][@"postId"]);
    
    // 1 is for video and 0 is for photo.
    
    if ([flStrForObj(responseData[selectedIndex][@"postsType"]) isEqualToString:@"1"]) {
        requestDict = @{
                        mauthToken:flStrForObj([Helper userToken]),
                        mpostid:postId,
                        mLabel:@"Video"
                        };
    }
    else {
        requestDict = @{
                        mauthToken:flStrForObj([Helper userToken]),
                        mpostid:postId,
                        mLabel:@"Photo"
                        };
    }
    [WebServiceHandler likeAPost:requestDict andDelegate:self];
}

-(void)unlikeAPost:(NSInteger)selectedIndex {
    NSDictionary *requestDict;
    NSString *postId =  flStrForObj(responseData[selectedIndex][@"postId"]);
    if ([flStrForObj(responseData[selectedIndex][@"postsType"]) isEqualToString:@"1"]) {
        requestDict = @{
                        mauthToken:flStrForObj([Helper userToken]),
                        mpostid:postId,
                        mLabel:@"Video",
                        mUserName:[Helper userName]
                        };
    }
    else {
        requestDict = @{
                        mauthToken:flStrForObj([Helper userToken]),
                        mpostid:postId,
                        mLabel:@"Photo",
                        mUserName:[Helper userName]
                        };
    }
    [WebServiceHandler unlikeAPost:requestDict andDelegate:self];
}

/*-------------------------------------------------------------------*/
#pragma mark - showing taggedPeople On Image
/*-------------------------------------------------------------------*/

-(void)creatingTapGesturePostedImage:(id)sender {
    HomeViewTableViewCell *receivedCell;
    UIImageView *selectedpostImage = (UIImageView *)sender;
    selectedpostImage.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
    
    tapGesture1.numberOfTapsRequired = 1;
    tapGesture1.numberOfTouchesRequired = 1;
    [tapGesture1 setDelegate:self];
    [selectedpostImage addGestureRecognizer:tapGesture1];
    
    
    //adding tapgesture for every image for double tapping like.
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(animateLike:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [selectedpostImage addGestureRecognizer:doubleTap];
    
    [tapGesture1 requireGestureRecognizerToFail:doubleTap];
    
    
    //before creating tap getsures for other cells we need to remove likeimage popup and hide if any tag buttons open.
    receivedCell.likeImage.hidden = YES;
    receivedCell.likeImage.alpha = 0;
    for (UIButton *eachButton in receivedCell.postedImageViewOutlet.subviews) {
        [UIView transitionWithView:receivedCell.postedImageViewOutlet
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [eachButton removeFromSuperview];
                            [self.view layoutIfNeeded];
                        }
                        completion:NULL];
    }
}

-(void)tapGesture:(UITapGestureRecognizer *)sender {
    UIView *view = sender.view;
    NSArray *namesOfTaggedPeople = [responseData[view.tag%5000][@"usersTagged"] componentsSeparatedByString:@","];
    
    // if there is no one tagged then from response by defaultly we are getting undefined so handling that.
    if ([namesOfTaggedPeople[0]  isEqualToString:@"undefined"]) {
        namesOfTaggedPeople = nil;
    }
    
    if (!view.subviews.count) {
        for( int i = 0; i < namesOfTaggedPeople.count; i++ ) {
            UIButton *customButton;
            customButton = [UIButton buttonWithType: UIButtonTypeCustom];
            [customButton setBackgroundColor: [UIColor clearColor]];
            [customButton setTitleColor:[UIColor blackColor] forState:
             UIControlStateHighlighted];
            //sets background image for normal state
            [customButton setBackgroundImage:[UIImage imageNamed:
                                              @"tag_people_tittle_btn"]
                                    forState:UIControlStateNormal];
            [customButton setBackgroundImage:[UIImage imageNamed:@"tag_people_tittle_btn"] forState:UIControlStateHighlighted];
            [customButton setTitle:[namesOfTaggedPeople objectAtIndex:i] forState:UIControlStateNormal];
            CGSize stringsize = [customButton.titleLabel.text sizeWithFont:[UIFont fontWithName:RobotoRegular size:15]];
            [customButton setFrame:CGRectMake(60, i*50, stringsize.width + 50, 40)];
            customButton.tag = 12345 + i;
            [customButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [UIView transitionWithView:view
                              duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [view addSubview:customButton];
                                [self.view layoutIfNeeded];
                            }
                            completion:NULL];
        }
    }
    else {
        for (UIButton *eachButton in view.subviews) {
            [UIView transitionWithView:view
                              duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [eachButton removeFromSuperview];
                                [self.view layoutIfNeeded];
                            }
                            completion:NULL];
        }
    }
}

- (void)buttonClicked:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkProfileOfUserNmae = selectedButton.titleLabel.text;
    newView.checkingFriendsProfile = YES;
    [self.navigationController pushViewController:newView animated:YES];
}

#pragma mark - WDUploadProgressView Delegate Methods
- (void)uploadDidFinish:(WDUploadProgressView *)progressVie {
    [progressVie removeFromSuperview];
    [self.tableView setTableHeaderView:nil];
}

- (void)uploadDidCancel:(WDUploadProgressView *)progressVie {
    [progressVie removeFromSuperview];
    [self.tableView setTableHeaderView:nil];
}

//PostSharingViewController.h
//postSharingScreen
//sharingPost
@end
