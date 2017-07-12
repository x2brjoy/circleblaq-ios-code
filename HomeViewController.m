//
//  HomeViewController.m
//  Picogram
//
//  Created by Govind on 10/3/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "HomeViewController.h"

#import "InstaVideoTableViewCell.h"
#import "LikeCommentTableViewCell.h"
#import "PostDetailsTableViewCell.h"
#import "SVPullToRefresh.h"
#import "ZOWVideoCache.h"

#import "Helper.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "TinderGenericUtility.h"
#import "FontDetailsClass.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"
#import "PhotosPostedByLocationViewController.h"
#import "UserProfileViewController.h"
#import "HomeViewCommentsViewController.h"
#import "LikeViewController.h"
#import "HashTagViewController.h"
#import "SharingPostViewController.h"
#import "PGTabBar.h"

#import "Cloudinary.h"

#import "PGDiscoverPeopleViewController.h"
#import "ProgressIndicator.h"
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
#import "TLYShyNavBar.h"
#import "WebViewForDetailsVc.h"

// Chat Start
#import "ShareViewXib.h"
#import "suggestionViewController.h"
#import "AppDelegate.h"
#import "PageContentViewController.h"
#import "ChatNavigationContollerClass.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBObjects.h"
#import "CouchbaseEvents.h"
#import "MSReceive.h"
#import "ContacDataBase.h"
#import "MacroFile.h"
#import "UIImageView+AFNetworking.h"
#import "HomeScreenTabBarController.h"
#import <Photos/Photos.h>

// Chat End

@import FirebaseInstanceID;

@interface HomeViewController ()<WebServiceHandlerDelegate,InstagramVideoViewTapDelegate,UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource,CLUploaderDelegate,UIGestureRecognizerDelegate,CLUploaderDelegate,MyTableViewCellDelegate>
{
    
    
    NSDictionary *cloundinaryCreditinals;
    //adding for uploading image/video.
    NSString *VideoUrl;
    NSString *thumbimageforvideourl;
    NSString *thumbNailUrl;
    NSString *mainUrl;
    UILabel *errorMessageLabelOutlet;
    UILabel *statusOfUploading;
    UIButton *tryToUploadAgain;
    
    NSMutableArray *dataForUploading;
    
    NSIndexPath *selectedCellIndexPathForActionSheet;
    UIProgressView *customprogressView;
    UIView *uploadingview;
    UIView *viewForBadge;
    // Chat Start
    ShareViewXib *shareNib;
    UIView *polygonView;
    // Chat End
}
@property (nonatomic, retain) UIDocumentInteractionController *dic;

@property (strong,nonatomic) NSMutableArray *dataArray;
@property int currentIndex;
@property NSInteger presentCellIndex;

@property bool noPostsAreAvailable;



@property bool classIsAppearing;
@end

@implementation HomeViewController

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Chat Start
   
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableViewOutlet.contentInset = UIEdgeInsetsMake(0, 0, -29, 0);
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"logged_in"]) {
        
        [[PicogramSocketIOWrapper sharedInstance]callMethodTogetadduserwhileOffline];
        
        [[PicogramSocketIOWrapper sharedInstance] sendHeartBeatForUser:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]] withStatus:@"1" andPushToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"]];
        
        [[PicogramSocketIOWrapper sharedInstance]getofflineGroupMsg:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
        
        [[PicogramSocketIOWrapper sharedInstance]sendLastcreatedGrouptime:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"userId"]]];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"logged_in"];
        
    }
 
    // Chat End

    cloundinaryCreditinals =[[NSUserDefaults standardUserDefaults]objectForKey:cloudinartyDetails];
    
    _dataArray = [NSMutableArray new];
    [self requestForPostsBasedOnRequirement];
    [self customeError];
    
    self.followButtonOutlet.layer.cornerRadius = 5;

    self.navigationController.navigationBar.tintColor = [UIColor  blackColor];
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_picogram_logo"]];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];

    
   // self.view.backgroundColor = [UIColor colorWithRed:30.0f/255.0f green:36.0f/255.0f blue:52.0f/255.0f alpha:1.0];
    
    
    
    [self creatingNotificationForUpdatingLikeDetails];
    [self showingProgressindicator];
    
    
    NSString *token = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", token);
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:mdeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self notificationForDeleteApost];
    
    
//    self.shyNavBarManager.scrollView=self.tableViewOutlet;
//    self.shyNavBarManager.stickyNavigationBar = NO;
    
    //[self CreateBottomView];
    
    
}
-(void)newmwrsmnb { }

-(void)CreateBottomView
{
    UIWindow *WindowForBadge = [[[UIApplication sharedApplication] delegate] window];
    viewForBadge = [[UIView alloc]init];
    
    //    CGFloat tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    viewForBadge.frame = CGRectMake(self.tabBarController.tabBar.frame.size.width -((self.tabBarController.tabBar.frame.size.width/5)*2),self.view.frame.size.height -(self.tabBarController.tabBar.frame.size.height*2),self.tabBarController.tabBar.frame.size.width/5,self.tabBarController.tabBar.frame.size.height - 10);
    
    //    UIImageView *backGroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,viewBottom.frame.size.width,viewBottom.frame.size.height)];
    //    backGroundImage.image = [UIImage imageNamed:@"home_view_btn"];
    //    [viewBottom addSubview:backGroundImage];
    
    [viewForBadge setBackgroundColor:[UIColor redColor]];
    viewForBadge.layer.cornerRadius = 5;
    
    UIButton *commentButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,viewForBadge.frame.size.width,viewForBadge.frame.size.height)];
    
    [commentButton setTitle:@"0" forState:UIControlStateNormal];
    [commentButton setImage:[UIImage imageNamed:@"chat_heart_icon_off"] forState:UIControlStateNormal];
    
    [commentButton.titleLabel setFont:[UIFont fontWithName:RobotoBold size:20]];
    
    UIButton *likeButton = [[UIButton alloc] initWithFrame:CGRectMake(viewForBadge.frame.size.width/2, 0,viewForBadge.frame.size.width/2,viewForBadge.frame.size.height)];
    
    [likeButton setTitle:@"1" forState:UIControlStateNormal];
    [likeButton setImage:[UIImage imageNamed:@"chat_heart_icon_on"] forState:UIControlStateNormal];
    
    [viewForBadge addSubview:commentButton];
    //[viewBottom addSubview:likeButton];
    
    [WindowForBadge addSubview:viewForBadge];
    
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideBadge) userInfo:nil repeats:NO];
}
-(void)hideBadge {
     [viewForBadge setHidden:YES];
}

-(void)deletePostFromNotification:(NSNotification *)noti {
    NSString *updatepostId = flStrForObj(noti.object[@"deletedPostDetails"][@"postId"]);
    for (int i=0; i <self.dataArray.count;i++) {
        
        if ([flStrForObj(self.dataArray[i][@"postId"]) isEqualToString:updatepostId])
        {
            //NSUInteger atSection = [selectedCellIndexPathForActionSheet section];
            [self removeRelatedDataOfDeletePost:i];
            [self.tableViewOutlet beginUpdates];
            [self.tableViewOutlet deleteSections:[NSIndexSet indexSetWithIndex:selectedCellIndexPathForActionSheet.section] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableViewOutlet endUpdates];
            
            break;
        }
    }
}


-(void)notificationForDeleteApost {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePostFromNotification:) name:@"deletePost" object:nil];
}

-(void)showingProgressindicator {
    //showing progress indicator and requesting for posts.
    ProgressIndicator *HomePI = [ProgressIndicator sharedInstance];
    [HomePI showPIOnView:self.view withMessage:@"Loading..."];
}



-(void)viewWillAppear:(BOOL)animated {
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"postKey"]) {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"postKey"];
        ProgressIndicator *pi = [ProgressIndicator sharedInstance];
        [pi showMessage:@"Posting.." On:self.view];
    }
    
    if(_noPostsAreAvailable) {
        [self requestForPostsBasedOnRequirement];
    }
    
    _classIsAppearing = YES;
    
    
    dataForUploading = [[NSUserDefaults standardUserDefaults] objectForKey:@"fileForUpload"];
    NSString *necessaryToUpload = flStrForObj(dataForUploading[0][@"startUpload"]);
    
    [[NSUserDefaults standardUserDefaults]setObject:dataForUploading forKey:@"fileForUploadTemporary"];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"fileForUpload"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    // dataForUploading = [[NSUserDefaults standardUserDefaults] objectForKey:@"fileForUpload"];
    
    
    if ([necessaryToUpload isEqualToString:@"1"]) {
        
        // for video uploading.
        self.postedImagePath = dataForUploading[0][@"postedImagePath"];
        self.postedthumbNailImagePath = dataForUploading[0][@"postedthumbNailImagePath"];
        self.imageForVideoThumabnailpath =   dataForUploading[0][@"imageForVideoThumabnailpath"];
        self.recordsession =  dataForUploading[0][@"recordSession"];
        self.pathOfVideo = dataForUploading[0][@"path"];
        self.dataVideo = dataForUploading[0][@"pathVid"];
        self.taggedFriendsString = dataForUploading[0][@"taggedFriendsString"];
        self.taggedFriendStringPoistions = dataForUploading[0][@"taggedFriendStringPoistions"];
        self.caption = dataForUploading[0][@"caption"];
        self.hashTags = dataForUploading[0][@"hashTags"];
        self.location = dataForUploading[0][@"location"];
        self.lat = dataForUploading[0][@"lat"];
        self.longi= dataForUploading[0][@"log"];
        _twitter = flStrForObj(dataForUploading[0][@"twitter"]);
        _facebook = flStrForObj(dataForUploading[0][@"facebook"]);
        _tumblr = flStrForObj(dataForUploading[0][ @"tumblr"]);
        _flickr = flStrForObj(dataForUploading[0][@"instagram"]);
        _business = flStrForObj(dataForUploading[0][@"businessProfile"]);
        _category = flStrForObj(dataForUploading[0][@"category"]);
        _subcategory = flStrForObj(dataForUploading[0][@"subcatory"]);
        _currency = flStrForObj(dataForUploading[0][@"currency"]);
        _price = flStrForObj(dataForUploading[0][@"price"]);
        _productlink = flStrForObj(dataForUploading[0][@"productUrl"]);
        _productName = flStrForObj(dataForUploading[0][@"productName"]);
        
        [self checkUploadImageOrVideo];
        _startUpload = 0;
        dataForUploading = nil;
    }
    
    NSArray* cells = _tableViewOutlet.visibleCells;
    for (InstaVideoTableViewCell *cell in cells) {
        if([cell isKindOfClass:[InstaVideoTableViewCell class]])
        {
            [self checkVisibilityOfCell:cell inScrollView:self.tableViewOutlet];
        }
    }
}


-(void)removeTemporaryDataForUploading{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"fileForUploadTemporary"];
}

-(void)creatingNotificationForUpdatingLikeDetails {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDetails:) name:@"updatePostDetails" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedCommentsdata:) name:@"passingUpdatedComments" object:nil];
}

-(void)updatedCommentsdata:(NSNotification *)noti {
    //check the postId and Its Index In array.
    
    if (!_classIsAppearing) {
        NSString *updatepostId = flStrForObj(noti.object[@"newCommentsData"][@"data"][0][@"postId"]);
        NSString *commentUpdateFor = flStrForObj(noti.object[@"newCommentsData"][@"message"]);
        //Successfully posted users Comment
        for (int i=0; i <self.dataArray.count;i++) {
            if ([flStrForObj(self.dataArray[i][@"postId"]) isEqualToString:updatepostId])
            {
                
                //NSInteger updateCellNumber  = [noti.object[@"newCommentsData"][@"selectedCell"] integerValue];
                if ([commentUpdateFor isEqualToString:@"Successfully posted users Comment"]) {
                   //when new comment on post
                    NSMutableArray *newCommentData = noti.object[@"newCommentsData"][@"data"][0][@"commentData"];
                    NSMutableArray *oldCommentsData = [[NSMutableArray alloc] init];
                    oldCommentsData = self.dataArray[i][@"commentData"];
                    [newCommentData addObjectsFromArray:oldCommentsData];
                    
                    [[self.dataArray objectAtIndex:i] setObject:newCommentData forKey:@"commentData"];
                    NSString *newNumberOfComments = noti.object[@"newCommentsData"][@"data"][0][@"totalComments"];
                    
                    [[self.dataArray objectAtIndex:i] setObject:newNumberOfComments forKey:@"totalComments"];
                    
                    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:3 inSection:i];
                    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload,nil];
                    [self.tableViewOutlet reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                    break;
                }
                else {
                     //when delete comment on post
                   
                   
                    NSArray *deletedCommentData = noti.object[@"newCommentsData"][@"data"][0][@"commentData"];
                    NSMutableArray *previousCommentData = [[NSMutableArray alloc] init];
                    previousCommentData = self.dataArray[i][@"commentData"];
                    
                    NSString *theCommentIdToremove = flStrForObj(deletedCommentData[0][@"commentId"]);
                    
                    for (int x=0;x<previousCommentData.count;x++) {
                        
                        NSString *commentIdFromOldData = flStrForObj(previousCommentData[x][@"commentId"]);
                        
                        if ([commentIdFromOldData isEqualToString:theCommentIdToremove]) {
                            [previousCommentData removeObjectAtIndex:x];
                            
                            [[self.dataArray objectAtIndex:i] setObject:previousCommentData forKey:@"commentData"];
                            
                            NSString *newNumberOfComments = noti.object[@"newCommentsData"][@"data"][0][@"totalComments"];
                            
                            [[self.dataArray objectAtIndex:i] setObject:newNumberOfComments forKey:@"totalComments"];
                            
                            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:3 inSection:i];
                            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload,nil];
                            [self.tableViewOutlet reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                            break;
                     }
                    }
                }
            }
        }
    }
}


-(void)updateDetails:(NSNotification *)noti {
    
    //check the postId and Its Index In array.
    
    if (!_classIsAppearing) {
        NSString *updatepostId = flStrForObj(noti.object[@"profilePicUrl"][@"data"][0][@"postId"]);
        
        for (int i=0; i <self.dataArray.count;i++) {
            
            if ([flStrForObj(self.dataArray[i][@"postId"]) isEqualToString:updatepostId])
            {
                //  updating the new data and reloading particular section.(row is constant)
                // row 1 is likebutton and commentButton.
                //row 2 is caption and comments.
                
                
                if ([flStrForObj(noti.object[@"profilePicUrl"][@"message"]) isEqualToString:@"unliked the post"]) {
                    //notification for unlike a post
                    //so update like status to zero.
                    
                    [[self.dataArray objectAtIndex:i] setObject:@"0" forKey:@"likeStatus"];
                }
                else {
                    [[self.dataArray objectAtIndex:i] setObject:@"1" forKey:@"likeStatus"];
                }
                
                NSString *updatedNumberOfLikes = flStrForObj(noti.object[@"profilePicUrl"][@"data"][0][@"likes"]);
                [[self.dataArray objectAtIndex:i] setObject:updatedNumberOfLikes forKey:@"likes"];
                _dataArray[i][@"likes"] = noti.object[@"profilePicUrl"][@"data"][0][@"likes"];
                
                NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:2 inSection:i];
                NSIndexPath* secondRowToreload  = [NSIndexPath indexPathForRow:3 inSection:i];
                NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload,secondRowToreload, nil];
                [self.tableViewOutlet reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                
                break;
            }
        }
    }
}




-(void)requestForPostsBasedOnRequirement {
    
    //for Home Screen.
    //requestingForPosts.
    
    __weak HomeViewController *weakSelf = self;
    self.currentIndex = 0;
    
    // setup pull-to-refresh
    [self.tableViewOutlet addPullToRefreshWithActionHandler:^{
        weakSelf.currentIndex = 0;
        [weakSelf serviceRequestingForPosts:0];
        
    }];
    
    // setup infinite scrollinge
    [self.tableViewOutlet addInfiniteScrollingWithActionHandler:^{
        [weakSelf serviceRequestingForPosts:weakSelf.currentIndex];
        
    }];
    [weakSelf serviceRequestingForPosts:0];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//   navigation bar back button

- (void)createNavLeftButton {
    self.navigationController.navigationItem.hidesBackButton =  YES;
    UIButton  *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_on"]
                     forState:UIControlStateSelected];
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    [navCancelButton setFrame:CGRectMake(10.0f,0.0f,40,40)];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

-(void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}


/*---------------------------------------------------*/
#pragma
#pragma mark -  Table view data source and delegates
/*---------------------------------------------------*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_dataArray.count) {
        _noPostsAreAvailable =NO;
    }
    else {
        _noPostsAreAvailable = YES;
    }
    
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row ==0) {
        
        InstaVideoTableViewCell *cell = (InstaVideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"InstaVideoTableViewCell" forIndexPath:indexPath];
        
        [cell setDelegate:self];
        
        
        NSString *urlString = self.dataArray[indexPath.section][@"mainUrl"];
        cell.url = urlString;
        
        //        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        //
        //        dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //
            if ([flStrForObj(self.dataArray[indexPath.section][@"postsType"]) isEqualToString:@"0"]) {
                cell.postType = @"0";
                
                [cell.videoView setHidden:YES];
                [cell.imageViewOutlet setHidden:NO];
                [cell setUrl:urlString];
                [cell setPlaceHolderUrl:_dataArray[indexPath.row][@"thumbnailImageUrl"]];
                
                
                [cell loadImageForCell];
                
                cell.imageViewOutlet.tag = 5000 +indexPath.section;
                cell.videoView.tag = 1000 +indexPath.section;
            }
            else {
                
                cell.videoView = [cell videoView];
                
                
                cell.postType = @"1";
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [cell loadVideoForCellFromLinkwithUrl:urlString];
                    if(indexPath.section != 0)
                    {
                        [cell.videoView pause];
                    }
                });
                
                [cell.videoView mute];
                [cell.videoView setHidden:NO];
                [cell.imageViewOutlet setHidden:YES];
            }
        });
        
        if (![self.dataArray[indexPath.section][@"usersTaggedInPosts"]  containsString:@"undefined"])  {
            
            cell.showTagsButtonOutlet.tag = 1520;
            
            if ([flStrForObj(self.dataArray[indexPath.section][@"postsType"]) isEqualToString:@"1"]) {
                cell.showTagsButtonOutlet.hidden = YES;
            }
            else {
                cell.showTagsButtonOutlet.hidden = NO;
            }
        }
        else {
            cell.showTagsButtonOutlet.hidden = YES;
        }
        
        [self removeTagsOnPhotos:cell.imageViewOutlet];
        return cell;
    }
    else if (indexPath.row ==1){
        
        static NSString *CellIdentifier = @"Cell";
        float  w = [[UIScreen mainScreen]bounds].size.width;
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
       
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        for (UIView *view in cell.subviews) {
            if ([view isKindOfClass:[UILabel class]]||[view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
            }
        }
        
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [buyButton addTarget:self
                      action:@selector(buyButtonClicked:)
            forControlEvents:UIControlEventTouchUpInside];
        buyButton.backgroundColor =[UIColor clearColor];
        buyButton.tag = 10000 + indexPath.section ;
        
        UIImageView *arrowImage = [[UIImageView alloc]init];
        
        UILabel *showNow = [[UILabel alloc]init];
        UILabel *linelbl = [[UILabel alloc]init];
        linelbl.backgroundColor =[UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0];
        [Helper setToLabel:showNow Text:@"Shop Now" WithFont:RobotoRegular FSize:16 Color:[UIColor colorWithRed:46/255.0f green:144/255.0f blue:235/255.0f alpha:1.0f]];
        arrowImage.image = [UIImage imageNamed:@"shopnow.png"];
        
        
        UILabel *priceLbl = [[UILabel alloc]init];
        priceLbl.textColor = [UIColor colorWithRed:46/255.0f green:144/255.0f blue:235/255.0f alpha:1.0f];
        NSString *chkCurrency = flStrForObj(_dataArray[indexPath.section][@"currency"]);
        NSString *priceWithtype;
        if (chkCurrency.length) {
            if ([_dataArray[indexPath.section][@"currency"] isEqualToString:@"INR"]) {
                priceWithtype = [NSString stringWithFormat:@"\u20B9 %@",_dataArray[indexPath.section][@"price"]];
            }else
            {
                priceWithtype = [NSString stringWithFormat:@"$ %@",_dataArray[indexPath.section][@"price"]];
            }
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"shopnow.png"];
            attachment.bounds = CGRectMake(0, 0, attachment.image.size.width/2, attachment.image.size.height/2);
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ",priceWithtype]];
            [myString appendAttributedString:attachmentString];
            priceLbl.textAlignment = NSTextAlignmentRight;
            priceLbl.attributedText = myString;
            [priceLbl sizeToFit];
  
        }
        
        NSString *isbusiness = flStrForObj(_dataArray[indexPath.section][@"productName"]);
        if ([isbusiness isEqualToString:@"product"])
        {
            showNow.frame = CGRectMake(10, 0,100, 40);
            buyButton.frame = CGRectMake(0, 0, w, 40);
            linelbl.frame = CGRectMake(10, 39, w-20,0.5);
            //arrowImage.frame = CGRectMake(w-15, 20-6.5f, 15/2, 25/2);
            priceLbl.frame = CGRectMake(CGRectGetMaxX(showNow.frame), 0,w-CGRectGetMaxX(showNow.frame)-10, 40);
            [cell addSubview:arrowImage];
            // [arrowImage bringSubviewToFront:buyButton];
        }
        else
        {
            showNow.frame = CGRectMake(10, 0, w-10, 0);
            buyButton.frame = CGRectMake(0, 0, w, 0);
            linelbl.frame = CGRectMake(0, 39, w, 0);
            priceLbl.frame = CGRectMake(CGRectGetMaxX(showNow.frame), 0, 0, 0);
            //arrowImage.frame = CGRectMake(0, 0, 0, 0);
            
        }
        
        showNow.backgroundColor = [UIColor clearColor];
        [cell addSubview:linelbl];
        [cell addSubview:showNow];
        [cell addSubview:buyButton];
        [cell addSubview:priceLbl];
        
         cell.backgroundColor = [UIColor whiteColor];
        
        return cell;
    }
    else if (indexPath.row ==2){
        
        LikeCommentTableViewCell *cell = (LikeCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"LikeCommentTableViewCell"];
        
        if ([self.dataArray[indexPath.section][@"likeStatus"]integerValue] == 0) {
            cell.likeButtonOutlet.selected = NO;
        }
        else {
            cell.likeButtonOutlet.selected = YES;
        }
        
        
        if ([[Helper userName] isEqualToString: flStrForObj(self.dataArray[indexPath.section][@"postedByUserName"])])
        {
            cell.moreButtonOutlet.tag = 1000 + indexPath.section;
        }
        else
        {
            cell.moreButtonOutlet.tag = 2000 + indexPath.section;
        }
        cell.likeButtonOutlet.tag = indexPath.section;
        cell.commentButtonOutlet.tag = indexPath.section;
        cell.shareButtonOutlet.tag = indexPath.section;
        
        return cell;
    }
        else {
        
        PostDetailsTableViewCell *cell = (PostDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PostDetailsTableViewCell"];
        
        [cell customizingCaption:_dataArray and:indexPath.section andFrame:self.view.frame];
        [cell showcomments:_dataArray and:indexPath.section andframe:self.view.frame];
        [cell showinNumberOfLikes:[self.dataArray[indexPath.section][@"likes"] integerValue]];
        
        cell.postedTimeLabelOutlet.text = [Helper convertEpochToNormalTime:self.dataArray[indexPath.section][@"postedOn"]];
        //handinlg hashtags and usernames.
        [self handlingHashTags:cell];
        [self handlinguserName:cell];
        
        cell.numberOfLikesButtonOutlet.tag = indexPath.section;
        cell.viewAllCommentsButtonOutlet.tag = indexPath.section;
        
        return cell;
    }
}

-(void)removeTagsOnPhotos:(UIImageView *)sender{
    
    UIView *view = (UIView *)sender;
    
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row ==0)
        //        return _tableViewOutlet.frame.size.height/2+20;
        return self.view.frame.size.width;
    else if (indexPath.row == 1)
    {
        NSString *isbusiness = flStrForObj(_dataArray[indexPath.section][@"productName"]);
        if ([isbusiness isEqualToString:@"product"])
            return 40;
        else
            return 0;
    }
    else if (indexPath.row ==2)
    {
        return 45;
    }
    else
    {
        PostDetailsTableViewCell *cell = (PostDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PostDetailsTableViewCell"];
        
        UILabel*captionlbl=[[UILabel alloc]initWithFrame:cell.captionLabelOutlet.bounds];
        captionlbl.font=cell.captionLabelOutlet.font;
        
        
        UILabel *firstCommentlbl=[[UILabel alloc]initWithFrame:cell.firstCommentLabel.bounds];
        firstCommentlbl.font=cell.firstCommentLabel.font;
        
        UILabel *secondCommentlbl=[[UILabel alloc]initWithFrame:cell.secondCommentLabelOutlet.bounds];
        secondCommentlbl.font=cell.secondCommentLabelOutlet.font;
        
        //alloting text for labels.
        NSString *postedUser = flStrForObj(_dataArray[indexPath.section][@"postedByUserName"]);
        NSString *caption = flStrForObj(_dataArray[indexPath.section][@"postCaption"]);
        NSString *commentWithUserName =  [postedUser stringByAppendingFormat:@"  %@",caption];
        
        NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        commentWithUserName = [commentWithUserName stringByTrimmingCharactersInSet:ws];
        
        
        
        NSInteger numberOfLikes = [self.dataArray[indexPath.section][@"likes"] integerValue];
        
        firstCommentlbl.text = @"";
        secondCommentlbl.text = @"";
        
        if ([caption isEqualToString:@"null"]) {
            captionlbl.text = @"";
        }
        else {
            captionlbl.text = commentWithUserName;
        }
        
        CGRect frame=captionlbl.frame;
        frame.size.width=self.view.frame.size.width;
        captionlbl.frame=frame;
        
        NSArray *response = self.dataArray[indexPath.section][@"commentData"];
        
        if (response.count == 1) {
            NSString *commentedUser1 = flStrForObj(response[0][@"commentedByUser"]);
            NSString *commentedText1 = flStrForObj(response[0][@"commentBody"]);
            
            NSString *postcommentWithUserName1 = [commentedUser1 stringByAppendingFormat:@"  %@",commentedText1];
            
            postcommentWithUserName1 = [postcommentWithUserName1 stringByTrimmingCharactersInSet:ws];
            
            firstCommentlbl.text = postcommentWithUserName1;
        }
        else if (response.count >1) {
            
            NSString *commentedUser1 = flStrForObj(response[0][@"commentedByUser"]);
            NSString *commentedText1 = flStrForObj(response[0][@"commentBody"]);
            
            NSString *commentedUser2 = flStrForObj(response[1][@"commentedByUser"]);
            NSString *commentedText2 =  flStrForObj(response[1][@"commentBody"]);
            
            
            NSString *postcommentWithUserName1 = [commentedUser1 stringByAppendingFormat:@"  %@",commentedText1];
            
            postcommentWithUserName1 = [postcommentWithUserName1 stringByTrimmingCharactersInSet:ws];
            
            NSString *postcommentWithUserName2 = [commentedUser2 stringByAppendingFormat:@"  %@",commentedText2];
            
            postcommentWithUserName2 = [postcommentWithUserName2 stringByTrimmingCharactersInSet:ws];
            
            firstCommentlbl.text =postcommentWithUserName1;
            secondCommentlbl.text = postcommentWithUserName2;
        }
        
        
        CGRect firstCommentlblframe=firstCommentlbl.frame;
        firstCommentlblframe.size.width=self.view.frame.size.width;
        firstCommentlbl.frame=firstCommentlblframe;
        
        CGRect secondCommentlblframe=secondCommentlbl.frame;
        secondCommentlblframe.size.width=self.view.frame.size.width;
        secondCommentlbl.frame=secondCommentlblframe;
        
        
        CGFloat heightOfCaption;
        CGFloat heightOfFirstComment;
        CGFloat heightOfSecondComment;
        CGFloat heightOfViewAllCommentsButton;
        CGFloat heightOfLikesNumberView;
        
        
        //claculating the height of text and if the text is empty directly making the respective label or button height as zero otherwise calculating height of text by using measureHieightLabel method.
        //+5 ids for spacing for the labels.
        
        if ([captionlbl.text  isEqualToString:@""]) {
            heightOfCaption = 0;
        }
        else {
            heightOfCaption = [Helper measureHieightLabel:captionlbl] + 5;
        }
        
        if ([firstCommentlbl.text isEqualToString:@""]) {
            heightOfFirstComment = 0;
        }
        else {
            heightOfFirstComment = [Helper measureHieightLabel:firstCommentlbl] + 5;
        }
        
        if ([secondCommentlbl.text isEqualToString:@""]) {
            heightOfSecondComment = 0;
        }
        else {
            heightOfSecondComment = [Helper measureHieightLabel:secondCommentlbl] + 5;
        }
        
        if (heightOfFirstComment > 0 && heightOfSecondComment > 0) {
            heightOfViewAllCommentsButton = 20;
        }
        else {
            heightOfViewAllCommentsButton = 0;
        }
        
        if (numberOfLikes > 0) {
            heightOfLikesNumberView = 25;
        }
        else {
            heightOfLikesNumberView = 0;
        }
        
        // 20 --- > for posted time label height.
        CGFloat totalHeightOfRow =  heightOfCaption + heightOfFirstComment +heightOfSecondComment  + heightOfViewAllCommentsButton + heightOfLikesNumberView + 30;
        
        return  totalHeightOfRow;
    }
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPat
//{
//    _presentCellIndex = indexPat.section;
//
//
//}

-(void)viewWillDisappear:(BOOL)animated {
    
    _classIsAppearing = NO;
    NSArray* cells = _tableViewOutlet.visibleCells;
    for (InstaVideoTableViewCell *cell in cells) {
        if([cell isKindOfClass:[InstaVideoTableViewCell class]])
        {
            [cell.videoView pause];
            
        }
    }
    
    NSLog(@"video is stopped in home");
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InstaVideoTableViewCell *cell1 = (InstaVideoTableViewCell *)cell;
    if(![cell1 isKindOfClass:[InstaVideoTableViewCell class]])
    {
        return;
    }
    [cell1.videoView pause];
    [cell1.videoView setHidden:YES];
    
}


/**
 *  @brief used for checking the visibility of the cell
 *
 *  @param cell        current cell
 *  @param aScrollView table view's scroll view
 */
- (void)checkVisibilityOfCell:(InstaVideoTableViewCell *)cell inScrollView:(UIScrollView *)aScrollView {
    CGRect cellRect = [aScrollView convertRect:cell.frame toView:aScrollView.superview];
    if(![cell isKindOfClass:[InstaVideoTableViewCell class]])
    {
        return;
    }
    if (CGRectContainsRect(aScrollView.frame, cellRect))
    {
        [cell notifyCompletelyVisible];
    }
    else
        [cell notifyNotCompletelyVisible];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    NSArray* cells = _tableViewOutlet.visibleCells;
    
    NSUInteger cellCount = [cells count];
    if (cellCount == 0)
        return;
    
    // Check the visibility of the first cell
    InstaVideoTableViewCell *cell = [cells firstObject];
    [self checkVisibilityOfCell:cell inScrollView:aScrollView];
    if (cellCount == 1)
        return;
    
    // Check the visibility of the last cell
    cell = [cells lastObject];
    [self checkVisibilityOfCell:[cells lastObject] inScrollView:aScrollView];
    if (cellCount == 2)
        return;
    
    // All of the rest of the cells are visible: Loop through the 2nd through n-1 cells
    for (NSUInteger i = 1; i < cellCount - 1; i++){
        cell = [cells objectAtIndex:i];
        if(![[cells objectAtIndex:i] isKindOfClass:[InstaVideoTableViewCell class]])
        {
            return;
        }
        [[cells objectAtIndex:i] notifyCompletelyVisible];
    }
}

- (void)stopAnimation {
    __weak HomeViewController *weakSelf = self;
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.tableViewOutlet.pullToRefreshView stopAnimating];
        [weakSelf.tableViewOutlet.infiniteScrollingView stopAnimating];
    });
}

/*---------------------------------------*/
#pragma
#pragma mark - Reloading TableView
/*---------------------------------------*/


-(void)animateButton:(UIButton *)likeButton {
    
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [ani setDuration:0.2];
    [ani setRepeatCount:1];
    [ani setFromValue:[NSNumber numberWithFloat:1.0]];
    [ani setToValue:[NSNumber numberWithFloat:0.5]];
    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[likeButton layer] addAnimation:ani forKey:@"zoom"];
    
}

-(void)reloadRowToShowNewNumberOfLikes:(NSInteger )reloadRowAtSection {
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:3 inSection:reloadRowAtSection];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableViewOutlet reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
}

/*---------------------------------------*/
#pragma
#pragma mark - Button Actions
/*---------------------------------------*/

- (IBAction)showTagsButtonAction:(id)sender {
    
    NSIndexPath *selectedButtontToShowTags = [self.tableViewOutlet indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    // Get the subviews of the view
    NSArray *subviewsfff =  [[sender superview] subviews];
    
    UIView *view = (UIView *)subviewsfff[2];
    
    NSArray *namesOfTaggedPeople = [self.dataArray[selectedButtontToShowTags.section][@"usersTaggedInPosts"] componentsSeparatedByString:@","];
    NSArray *positionsOfNames = [self.dataArray[selectedButtontToShowTags.section][@"taggedUserCoordinates"] componentsSeparatedByString:@",,"];
    
    
    // if there is no one tagged then from response by defaultly we are getting undefined so handling that.
    if ([namesOfTaggedPeople[0]  isEqualToString:@"undefined"]) {
        namesOfTaggedPeople = nil;
        positionsOfNames = nil;
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
            
            [customButton addTarget:self action:@selector(selectedUserProfile:) forControlEvents:UIControlEventTouchUpInside];
            
            [customButton setTitle:[namesOfTaggedPeople objectAtIndex:i] forState:UIControlStateNormal];
            
            CGPoint fromPoint = CGPointFromString([positionsOfNames objectAtIndex:i]);
            
            CGSize stringsize = [customButton.titleLabel.text sizeWithFont:[UIFont fontWithName:RobotoMedium size:13]];
            [customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
            //checking the poistion is going out of imaege  or not.
            //if button poistion is out of image then need to alifgn properly.
            if (fromPoint.x + customButton.frame.size.width > view.frame.size.width || fromPoint.y + customButton.frame.size.height > view.frame.size.height) {
                NSLog(@"custom button is out of view");
                if (fromPoint.x + customButton.frame.size.width > view.frame.size.width) {
                   NSLog(@"custom button is out of view along horizontal");
                   [customButton setFrame:CGRectMake(fromPoint.x - ((fromPoint.x + customButton.frame.size.width) - view.frame.size.width),fromPoint.y, stringsize.width + 50, 35)];
                }
                else {
                    NSLog(@"custom button is aligned properly along horizontal");
                }
                
                if( fromPoint.y + customButton.frame.size.height > view.frame.size.height) {
                    NSLog(@"custom button is out of view along vertical");
                     //[customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
                    
                    [customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y - ((fromPoint.y + customButton.frame.size.height) - view.frame.size.height), stringsize.width + 50, 35)];
                }
                else {
                    NSLog(@"custom button is aligned properly along vertical");
                }
                
                if (fromPoint.x + customButton.frame.size.width > view.frame.size.width && fromPoint.y + customButton.frame.size.height > view.frame.size.height) {
                     [customButton setFrame:CGRectMake(fromPoint.x - ((fromPoint.x + customButton.frame.size.width) - view.frame.size.width),fromPoint.y - ((fromPoint.y + customButton.frame.size.height) - view.frame.size.height), stringsize.width + 50, 35)];
                    
                    NSLog(@"custom button is out of view along both horizontal and vertical");
                }
            }
            else {
               [customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
            }
            [customButton setTitleEdgeInsets:UIEdgeInsetsMake(5.0f, 0.0f, 0.0f, 0.0f)];
            customButton.tag = 12345 + i;
            [customButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [UIView transitionWithView:view
                              duration:0
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
                              duration:0
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [eachButton removeFromSuperview];
                                [self.view layoutIfNeeded];
                            }
                            completion:NULL];
        }
    }
}

-(void)selectedUserProfile:(id)sender {
    UIButton *selectedButton= (UIButton *)sender;
    NSString *userName = [selectedButton titleForState:UIControlStateNormal];
    
    [self openProfileOfUsername:userName];
}


- (IBAction)likeButtonAction:(id)sender {
    UIButton *likeButton = (UIButton *)sender;
    
    // adding animation for selected button
    [self animateButton:likeButton];
    
    if (likeButton.selected) {
        likeButton.selected = NO;
        
        [[self.dataArray objectAtIndex:likeButton.tag] setObject:@"0" forKey:@"likeStatus"];
        NSInteger newNumberOfLikes = [self.dataArray[likeButton.tag][@"likes"] integerValue];
        newNumberOfLikes --;
        [[self.dataArray objectAtIndex:likeButton.tag] setObject:[@(newNumberOfLikes) stringValue] forKey:@"likes"];
        [self reloadRowToShowNewNumberOfLikes:likeButton.tag];
        [self unlikeAPost:flStrForObj(self.dataArray[likeButton.tag][@"postId"]) postType:flStrForObj(self.dataArray[likeButton.tag][@"postsType"])];
        
    }
    else  {
        likeButton.selected = YES;
        
        [[self.dataArray objectAtIndex:likeButton.tag] setObject:@"1" forKey:@"likeStatus"];
        NSInteger newNumberOfLikes = [self.dataArray[likeButton.tag][@"likes"] integerValue];
        newNumberOfLikes ++;
        [[self.dataArray objectAtIndex:likeButton.tag] setObject:[@(newNumberOfLikes) stringValue] forKey:@"likes"];
        [self reloadRowToShowNewNumberOfLikes:likeButton.tag];
        [self likeAPost:flStrForObj(self.dataArray[likeButton.tag][@"postId"]) postType:flStrForObj(self.dataArray[likeButton.tag][@"postsType"])];
        
        
    }
}


-(IBAction)CommentButtonAction:(id)sender {
    
    UIButton *commentButton = (UIButton *)sender;
    
    HomeViewCommentsViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsStoryBoardId"];
    newView.postId =  flStrForObj(self.dataArray[commentButton.tag][@"postId"]);
    newView.postCaption =  flStrForObj(self.dataArray[commentButton.tag][@"postCaption"]);
    newView.postType = flStrForObj(self.dataArray[commentButton.tag][@"postsType"]);
    newView.imageUrlOfPostedUser =  flStrForObj(self.dataArray[commentButton.tag][@"profilePicUrl"]);
    newView.selectedCellIs =commentButton.tag;
    newView.userNameOfPostedUser = flStrForObj(self.dataArray[commentButton.tag][@"postedByUserName"]);
    [self.navigationController pushViewController:newView animated:YES];
}

- (IBAction)numberOfLikesButtonAction:(id)sender {
    UIButton *listOflikes = (UIButton *)sender;
    LikeViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"likeStoryBoardId"];
    newView.navigationTitle = @"Likers";
    newView.postId =  flStrForObj(self.dataArray[listOflikes.tag][@"postId"]);
    newView.postType = flStrForObj(self.dataArray[listOflikes.tag][@"postsType"]);
    [self.navigationController pushViewController:newView animated:YES];
}

- (IBAction)moreButtonAction:(id)sender {
    
    selectedCellIndexPathForActionSheet = [self.tableViewOutlet indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    UIButton *moreButton = (UIButton *)sender;
    NSInteger tag = [sender tag];
    UIActionSheet *sheet;
    if(!(tag < 2000)){
        
        sheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Report",@"Share to Facebook", @"Copy Share URL", nil];
        [sheet setTag:moreButton.tag];
        
    }
    else
    {
        sheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Delete", @"Share", nil];
        [sheet setTag:moreButton.tag];
        
    }
    [sheet showInView:self.view];
}

- (IBAction)viewAllCommentsButtonAction:(id)sender {
    UIButton *allCommentButton = (UIButton *)sender;
    HomeViewCommentsViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsStoryBoardId"];
    newView.postId =  flStrForObj(self.dataArray[allCommentButton.tag][@"postId"]);
    newView.postCaption =  flStrForObj(self.dataArray[allCommentButton.tag][@"postCaption"]);
    newView.postType = flStrForObj(self.dataArray[allCommentButton.tag][@"postsType"]);
    newView.imageUrlOfPostedUser =  flStrForObj(self.dataArray[allCommentButton.tag][@"profilePicUrl"]);
    newView.selectedCellIs =allCommentButton.tag;
    newView.userNameOfPostedUser = flStrForObj(self.dataArray[allCommentButton.tag][@"postedByUserName"]);
    [self.navigationController pushViewController:newView animated:YES];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSInteger tag = popup.tag;
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
        {
            [self deletePost:tag%1000];
        }
        
        else if (buttonIndex == 1) {
            [self sharePost:tag%1000];
        }
    }
}

/*----------------------------------------------------------------------------*/
#pragma
#pragma mark - tableview Header Buttons And Actions.
/*----------------------------------------------------------------------------*/




- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{  return 56; }

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    view.backgroundColor = [UIColor whiteColor];
    
    // Create custom view to display section header... /
    
    //creating user name label
    UILabel *UserNamelabel = [[UILabel alloc] init];
    UserNamelabel.text = flStrForObj(_dataArray[section][@"postedByUserName"]);
    [UserNamelabel setFont:[UIFont fontWithName:RobotoMedium size:15]];
    UserNamelabel.textColor =[UIColor colorWithRed:0.1568 green:0.1568 blue:0.1568 alpha:1.0];
    
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *placeName = flStrForObj(_dataArray[section][@"place"]);
    
    if ([placeName isEqualToString:@"null"] ||[placeName isEqualToString:@"[object Object]"]) {
        placeName = @"";
    }
    
    [locationButton.titleLabel setFont:[UIFont fontWithName:RobotoRegular  size:12]];
   // [locationButton.titleLabel setFont:[UIFont fontWithName:AvenirNextCondensedRegular  size:12]];
    locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    locationButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [locationButton addTarget:self
                       action:@selector(locationButtonClicked:)
             forControlEvents:UIControlEventTouchUpInside];
    [locationButton setTitle:placeName forState:UIControlStateNormal];
    [locationButton setTitleColor: [UIColor blackColor] forState:
     UIControlStateNormal];
    
    
    //creating  total  header  as button
    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [headerButton addTarget:self
                     action:@selector(headerButtonClicked:)
           forControlEvents:UIControlEventTouchUpInside];
    headerButton.backgroundColor =[UIColor whiteColor];
    headerButton.tag = 10000 + section ;
    
    
    //creating user image on tableView Header
    UIImageView *UserImageView =[[UIImageView alloc] init];
    [UserImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(_dataArray[section][@"profilePicUrl"])] placeholderImage:[UIImage imageNamed:defaultProfileImageName]];
    
    UserImageView.layer.borderWidth = 1;
    UserImageView.layer.borderColor  = [UIColor whiteColor].CGColor
;
    
    UIImageView *locationImageView = [[UIImageView alloc] init];
    //setting position of headerButton,UserImageView,timeLabel in customized  tableView Section Header.
    //if there is no place then usernamelabel will come in middle
    if ([placeName isEqualToString:@""]) {
        UserNamelabel.frame=CGRectMake(60, 20, self.view.frame.size.width - 100, 18);
        locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 120, 0);
    }
    else {
        UserNamelabel.frame=CGRectMake(60, 10, self.view.frame.size.width - 100, 18);
        
        CGSize stringSize = [locationButton.titleLabel.text sizeWithAttributes:
                             @{NSFontAttributeName: [UIFont fontWithName:RobotoRegular size:12]}];
        CGFloat width = stringSize.width;
        
        //[locationButton.titleLabel.text sizeWithFont:[UIFont fontWithName:RobotoRegular size:12]];
        
        // locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 120, 18);
        locationButton.frame = CGRectMake(60, 30,width +30, 18);
        
        locationImageView.frame = CGRectMake(locationButton.frame.size.width + 30, 34, 8, 10);
        locationImageView.image = [UIImage imageNamed:@"home_next_arrow_icon_off"];
    }
    
    UserImageView.frame = CGRectMake(10,8,40,40);
    
    [self.view layoutIfNeeded];
    UserImageView.layer.cornerRadius = UserImageView.frame.size.height/2;
    UserImageView.clipsToBounds = YES;
    headerButton.frame = CGRectMake(0, 1, tableView.frame.size.width,56);
    
    
    // adding  headerButton,UserImageView,timeLabel,UserNamelabel to the customized tableView  Section Header.
    
    [view addSubview:headerButton];
    [view addSubview:UserImageView];
    [view addSubview:UserNamelabel];
    [view addSubview:locationButton];
    [view addSubview:locationImageView];
    
    return view;
}

-(void)tableviewHeader {
    
    
    uploadingview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableViewOutlet.frame.size.width, 60)];
    uploadingview.backgroundColor =[UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1.0];
    
    
    //creating user name label
    statusOfUploading = [[UILabel alloc] init];
    statusOfUploading.text = @"Posting";
    statusOfUploading.textAlignment = NSTextAlignmentLeft;
    [statusOfUploading setFont:[UIFont fontWithName:RobotoMedium size:16]];
    statusOfUploading.textColor =[UIColor colorWithRed:0.1568 green:0.1568 blue:0.1568 alpha:1.0];
    statusOfUploading.frame=CGRectMake(60,0, self.view.frame.size.width - 50,58);
    
    UIImageView *thumbNailOfImage;
    if (_recordsession || _pathOfVideo) {
        thumbNailOfImage = [[UIImageView alloc] initWithFrame:CGRectMake(10,10,40,40)];
        UIImage *thumbNailIM = [self gettingThumbnailImage:_pathOfVideo];
        thumbNailOfImage.image = thumbNailIM;
        
        
        UIImageView *resumeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"video_share_video_icon_on"]];
        resumeImage.frame  = CGRectMake(10,10,40,40);
        resumeImage.center = thumbNailOfImage.center;
        [uploadingview addSubview:resumeImage];
    }
    else {
        thumbNailOfImage = [[UIImageView alloc] initWithFrame:CGRectMake(10,10,40,40)];
        NSData *imgData = [NSData dataWithContentsOfFile:self.postedthumbNailImagePath];
        thumbNailOfImage.image = [[UIImage alloc] initWithData:imgData];
        
    }
    
    
    tryToUploadAgain = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70,10,30,30)];
    [tryToUploadAgain setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    [tryToUploadAgain addTarget:self
                         action:@selector(restartUploading:)
               forControlEvents:UIControlEventTouchUpInside];
    tryToUploadAgain.hidden = YES;
    
    
    
    customprogressView = [[UIProgressView alloc] init];
    customprogressView.frame = CGRectMake(0,58,self.view.frame.size.width,20);
    customprogressView.trackTintColor = [UIColor colorWithRed:192/255.0 green:222/255.0 blue:250/255.0 alpha:1.0];
    
    [uploadingview addSubview:customprogressView];
    [uploadingview addSubview:tryToUploadAgain];
    [uploadingview addSubview:thumbNailOfImage];
    [uploadingview addSubview:statusOfUploading];
    
    if (self.tableViewOutlet.hidden) {
        [self.view addSubview:uploadingview];
    }
    else {
        [self.tableViewOutlet setTableHeaderView:uploadingview];
    }
}

-(void)customeError
{
    errorMessageLabelOutlet = [[UILabel alloc]initWithFrame:CGRectMake(0, -80, [UIScreen mainScreen].bounds.size.width, 50)];
    errorMessageLabelOutlet.backgroundColor = [UIColor colorWithRed:108/255.0f green:187/255.0f blue:79/255.0f alpha:1.0];
    errorMessageLabelOutlet.textColor = [UIColor whiteColor];
    errorMessageLabelOutlet.textAlignment = NSTextAlignmentCenter;
    [errorMessageLabelOutlet setHidden:YES];
    [self.view addSubview:errorMessageLabelOutlet];
}

#pragma mark-Error Alert
-(void)showingErrorAlertfromTop:(NSString *)message {
    [errorMessageLabelOutlet setHidden:NO];
    
    [errorMessageLabelOutlet setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    [self.view layoutIfNeeded];
    errorMessageLabelOutlet.text = message;
    
    /**
     *  changing the error message view position if user enter  wrong number
     */
    
    [UIView animateWithDuration:0.4 animations:
     ^ {
         
         [self.view layoutIfNeeded];
     }];
    
    int duration = 2; // duration in seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.4 animations:
         ^ {
             [errorMessageLabelOutlet setFrame:CGRectMake(0, -100, [UIScreen mainScreen].bounds.size.width, 100)];
             [errorMessageLabelOutlet setHidden:YES];
             [self.view layoutIfNeeded];
         }];
    });
}

/*---------------------------------------------------*/
#pragma mark
#pragma mark - converting video to thumbnail image
/*---------------------------------------------------*/

-(UIImage *)gettingThumbnailImage :(NSString *)url {
    NSURL *videoURl = [NSURL fileURLWithPath:url];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURl options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    
    UIImage *img = [[UIImage alloc] initWithCGImage:imgRef];
    return img;
    
    
}


-(void)restartUploading:(id)sender {
    NSLog(@"start uploading again");
    tryToUploadAgain.hidden = YES;
    [self checkUploadImageOrVideo];
}

- (void)makeMyProgressBarMoving {
    if (customprogressView.progress < 1) {
        //it will progress of 0.016666666666 for every sec.(value for 60 secs.)(1/60)
        [customprogressView setProgress:0.1 + customprogressView.progress animated:YES];
    }
    else if (customprogressView.progress == 1){
        [customprogressView setProgress:0 animated:NO];
    }
}

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
    [self openProfileOfUsername:flStrForObj(self.dataArray[selectedIndex][@"postedByUserName"])];
}


/*-----------------------------------------------------------------------------*/
#pragma
#pragma mark - Image or Video Tap Gesture Delegates Handling
/*------------------------------------------------------------------------------*/


- (void)videoViewDidSingleTap:(InstagramVideoView *)view {
    NSLog(@"single tap method called");
}

- (void)videoViewDidDoubleTap:(InstagramVideoView *)view {
    NSLog(@"double tap method called");
    
}


/*-----------------------------------------------------------------------------*/
#pragma
#pragma mark - Handling Hashtags,URL and UserNames.
/*------------------------------------------------------------------------------*/

-(void)handlingHashTags:(id)sender {
    
    PostDetailsTableViewCell *receivedCell = (PostDetailsTableViewCell *)sender;
    // Attach a block to be called when the user taps a hashtag.
    
    receivedCell.captionLabelOutlet.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self openPostsByHashtag:string];
    };
    receivedCell.firstCommentLabel.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self openPostsByHashtag:string];
    };
    receivedCell.secondCommentLabelOutlet.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [self openPostsByHashtag:string];
    };
}

-(void)handlinguserName:(id)sender {
    
    PostDetailsTableViewCell *receivedCell = (PostDetailsTableViewCell *)sender;
    // Attach a block to be called when the user taps a user handle.
    
    receivedCell.captionLabelOutlet.userHandleLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        //removing @ from string.
        NSString *stringWithoutspecialCharacter = [string
                                                   stringByReplacingOccurrencesOfString:@"@" withString:@""];
        
        [self openProfileOfUsername:stringWithoutspecialCharacter];
    };
    receivedCell.firstCommentLabel.userHandleLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        //removing @ from string.
        NSString *stringWithoutspecialCharacter = [string
                                                   stringByReplacingOccurrencesOfString:@"@" withString:@""];
        
        [self openProfileOfUsername:stringWithoutspecialCharacter];
    };
    receivedCell.secondCommentLabelOutlet.userHandleLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        //removing @ from string.
        NSString *stringWithoutspecialCharacter = [string
                                                   stringByReplacingOccurrencesOfString:@"@" withString:@""];
        
        [self openProfileOfUsername:stringWithoutspecialCharacter];
    };
}

-(void)openPostsByHashtag:(NSString *)string {
    if ([string isEqualToString:@"#"]) {
        //nothing to do
    }
    else {
        HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
        newView.navTittle = string;
        [self.navigationController pushViewController:newView animated:YES];
    }
}

/*-----------------------------------------------------------------------------*/
#pragma
#pragma mark - REQUESTING SERVICES .
/*------------------------------------------------------------------------------*/


-(void)likeAPost:(NSString *)postId postType:(NSString *)postType {
    NSDictionary *requestDict;
    
    // 1 is for video and 0 is for photo.
    
    if ([flStrForObj(postType) isEqualToString:@"1"]) {
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

-(void)unlikeAPost:(NSString *)postId postType:(NSString *)postType {
    NSDictionary *requestDict;
    if ([flStrForObj(postType) isEqualToString:@"1"]) {
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


/*----------------------------------------------------------------------*/
#pragma mark
#pragma mark - WebServiceDelegate(Response)
/*----------------------------------------------------------------------*/

//handling response.

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    self.tableViewOutlet.backgroundView = nil;
    if (error) {
        
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        self.tableViewOutlet.backgroundView = nil;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self errorMessageForTableViewBackGround:[error localizedDescription]];
        return;
    }
    
    NSDictionary *responseDict = (NSDictionary*)response;
    if (requestType == RequestTypePost||requestType == RequestTypebusinessPostProduct) {

        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        
        //success response(200 is for success code).
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                self.currentIndex = 0;
                [self serviceRequestingForPosts:0];
            }
                break;
                //failure responses.
            case 9757: {
                [self errrAlert:responseDict[@"message"]];
            }
                break;
            case 9758: {
                [self errrAlert:responseDict[@"message"]];
            }
                break;
            case 9759: {
                [self errrAlert:responseDict[@"message"]];
            }
                break;
            case 9760: {
                [self errrAlert:responseDict[@"message"]];
            }
                break;
            case 9761: {
                [self errrAlert:responseDict[@"message"]];
            }
                break;
            case 9762: {
                [self errrAlert:responseDict[@"message"]];
            }
                break;
            case 9763: {
                [self errrAlert:responseDict[@"message"]];
            }
                break;
            case 9764: {
                [self errrAlert:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }
    
    else if (requestType == RequestTypereportPost)
    {
        //success response(200 is for success code).
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                 [Helper showAlertWithTitle:@"Thanks for reporting this post" Message:@"Your feedback is important in helping us keep the Picogram community safe."];
            }
                break;
                //failure responses.
            case 9477: {
                [self errrAlert:responseDict[@"messsage"]];
            }
                break;
            case 9758: {
                [self errrAlert:responseDict[@"messsage"]];
            }
                break;
            case 9759: {
                [self errrAlert:responseDict[@"messsage"]];
            }
                break;
            case 9760: {
                [self errrAlert:responseDict[@"messsage"]];
            }
                break;
            case 9761: {
                [self errrAlert:responseDict[@"messsage"]];
            }
                break;
            case 9762: {
                [self errrAlert:responseDict[@"messsage"]];
            }
                break;
            case 9763: {
                [self errrAlert:responseDict[@"messsage"]];
            }
                break;
            case 9764: {
                [self errrAlert:responseDict[@"messsage"]];
            }
                break;
            default:
                break;
        }
        
       
    }
    
    if (requestType == RequestTypegetPostsInHOmeScreen ) {
        
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        if ([responseDict[@"message"] isEqualToString:messageWhenNoPosts] && self.currentIndex ==0) {
            
            self.viewWhenNoPostsOutlet.hidden = NO;
            self.tableViewOutlet.hidden = YES;
            
        }
        else {
            
            self.viewWhenNoPostsOutlet.hidden = YES;
            self.tableViewOutlet.hidden = NO;
            
            if(self.currentIndex == 0)
            {
                [_dataArray removeAllObjects];
                [[ZOWVideoCache sharedVideoCache] clearAllCache];
                //                NSLog(@"cache cleard");
            }
            self.currentIndex ++;
            [self stopAnimation];
            
            if (![responseDict[@"message"] isEqualToString:messageWhenNoPosts]) {
                [_dataArray addObjectsFromArray:response[@"data"]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableViewOutlet reloadData];
            });
        }
    }
    else if (requestType == RequestTypeDeletePost) {
        
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deletePost" object:[NSDictionary dictionaryWithObject:responseDict forKey:@"deletedPostDetails"]];
            }
                break;
            case 1986: {
                [self errrAlert:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }
    
    else if (requestType == RequestTypeLikeAPost) {
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePostDetails" object:[NSDictionary dictionaryWithObject:responseDict forKey:@"profilePicUrl"]];
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
            case 9584: {
                NSDictionary *likeDictonaty = responseDict[@"likeResponse"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePostDetails" object:[NSDictionary dictionaryWithObject:likeDictonaty forKey:@"profilePicUrl"]];
            }
                break;
            default:
                break;
        }
    }
    else if (requestType == RequestTypeUnlikeAPost) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePostDetails" object:[NSDictionary dictionaryWithObject:responseDict forKey:@"profilePicUrl"]];
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
}

- (void)errrAlert:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];//Send via SMS
    [alert show];
}

-(UIView *)errorMessageForTableViewBackGround:(NSString *)errorMessage {
    
    self.viewWhenNoPostsOutlet.hidden = YES;
    self.tableViewOutlet.hidden = NO;
    
    
    UIView *noDataAvailableMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [noDataAvailableMessageView setCenter:self.view.center];
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -100, self.view.frame.size.height/2 -20, 200, 60)];
    message.textAlignment = NSTextAlignmentCenter;
    message.numberOfLines = 0;
    message.text = errorMessage;
    [noDataAvailableMessageView addSubview:message];
    self.tableViewOutlet.backgroundColor = [UIColor clearColor];
    
    self.tableViewOutlet.backgroundView = noDataAvailableMessageView;
    
    return noDataAvailableMessageView;
}

// Chat Start

-(void)viewDidAppear:(BOOL)animated
{
    // Chat Start
    NSString *valueToSave =@"0";
    [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"TabSellected"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]])
        {
            UIScrollView *scrollView = (UIScrollView *)view;
            NSString *tabSellected = [[NSUserDefaults standardUserDefaults]
                                      stringForKey:@"TabSellected"];
            
            if([tabSellected isEqualToString:@"0"])
            {
                // scrollView.contentSize = CGSizeMake(self.view.frame.size.width*2, self.view.frame.size.height);
                scrollView.scrollEnabled = YES;
            }else{
                scrollView.scrollEnabled = NO;
                // scrollView.contentSize = CGSizeZero;
            }
        }
    }
    
    
    // Chat End
    
    [self.tabBarController.tabBar setHidden:NO];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        suggestionViewController *sug = [[suggestionViewController alloc]init];
        [sug favoritesSetUp ];
    }];
}



-(void)cancelButtonClicked {
    [shareNib removeFromSuperview];
}

-(void)customeErrorlocalPush:(NSDictionary *)detail
{
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    
    polygonView = [[UIView alloc] initWithFrame: CGRectMake ( 0,-80, self.view.frame.size.width, 80)];
    polygonView.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:248.0f/255.0f blue:247.0f/255.0f alpha:1.0];
    
    //    polygonView.backgroundColor = [UIColor darkGrayColor];
    
    [window addSubview:polygonView];
    
    [window bringSubviewToFront:polygonView];
   
   
    [UIView animateWithDuration:0.75f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         polygonView.frame = CGRectMake ( 0, 0, self.view.frame.size.width, 80);
                         
                         [polygonView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                     }
     ];
    
    UIButton *gotoChat = [[UIButton alloc]initWithFrame: CGRectMake(0, 0,self.view.frame.size.width, 50)];
    [gotoChat addTarget:self action:@selector(gotoChatList) forControlEvents:UIControlEventTouchUpInside];
    [gotoChat setTitle:@"" forState:UIControlStateNormal];
    gotoChat.backgroundColor = [UIColor clearColor];
    [polygonView addSubview:gotoChat];
    
    UIImageView *groupImage = [[UIImageView alloc]initWithFrame: CGRectMake(5, 20, 30, 30)];
    groupImage.layer.cornerRadius = groupImage.frame.size.width / 2;
    
    NSURL *imageUrl =[NSURL URLWithString:detail[@"GroupImage"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
    UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
    groupImage.image = placeholderImage;
    
    groupImage.clipsToBounds = YES;
    [polygonView setNeedsLayout];
    
    [groupImage setImageWithURLRequest:request
                      placeholderImage:placeholderImage
                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                   
                                   groupImage.image = image;
                                   groupImage.layer.cornerRadius = groupImage.frame.size.width / 2;
                                   groupImage.clipsToBounds = YES;
                                   
                               } failure:nil];
    
    
    [polygonView addSubview:groupImage];
    
    NSString * groupMember = [NSString stringWithFormat:@"Sent To %@",detail[@"GroupMembers"]];
    
    UILabel *sendTo = [[UILabel alloc]initWithFrame: CGRectMake(groupImage.frame.size.width + 10, 10, polygonView.frame.size.width - 50, 45)];
    sendTo.text =groupMember;
    sendTo.textColor = [UIColor blackColor];
    [polygonView addSubview:sendTo];
    [window bringSubviewToFront:sendTo];
    
    NSTimer *aTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(aTimeHide) userInfo:nil repeats:NO];
    NSLog(@"%@",aTimer);
    //add code to customize, e.g. polygonView.backgroundColor = [UIColor blackColor];
    
    
}

-(void)aTimeHide
{
  
    
    [UIView animateWithDuration:0.75 animations:^{
        polygonView.frame = CGRectMake ( 0,-80, self.view.frame.size.width, 80);
        
        [polygonView layoutIfNeeded];
    }completion:^(BOOL finished) {
        [polygonView removeFromSuperview];
    }];
    
    
}

-(void)gotoChatList{
    
    [UIView animateWithDuration:0.75 animations:^{
        polygonView.frame = CGRectMake ( 0,-80, self.view.frame.size.width, 80);
        
        [polygonView layoutIfNeeded];
    }completion:^(BOOL finished) {
        [polygonView removeFromSuperview];
    }];
   
    ChatNavigationContollerClass *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"chatNavigationContollerClass"];
    
    PageContentViewController * pgController = [PageContentViewController sharedInstance];
    [pgController.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}

-(void)sendButtonClicked:(NSDictionary *)detail
{
    [shareNib removeFromSuperview];
    
    [self customeErrorlocalPush:detail];
}


- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

// Chat End



- (IBAction)followPeopleButtonAction:(id)sender {
    PGDiscoverPeopleViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:mDiscoverPeopleVcSI];
    [self.navigationController pushViewController:postsVc animated:YES];
}

- (IBAction)firstCommentUserNameButtonAction:(id)sender {
}



-(void)removeRelatedDataOfDeletePost:(NSInteger )atSection {
    
    [self.dataArray removeObjectAtIndex:atSection];
    
    if (self.dataArray.count == 0) {
        self.viewWhenNoPostsOutlet.hidden = NO;
        self.tableViewOutlet.hidden = YES;
    }
}

-(void)deleteUrlFromCloudniary{
    CLCloudinary *mobileCloudinary = [[CLCloudinary alloc] init];
    [mobileCloudinary.config setValue:cloundinaryCreditinals[@"response"][@"cloudName"] forKey:@"cloud_name"];
    
    CLUploader* mobileUploader = [[CLUploader alloc] init:mobileCloudinary delegate:self];
    
    [mobileUploader destroy:@"xeb0lrounb84id8wdgnz" options:@{
                                                          @"signature":cloundinaryCreditinals[@"response"][@"signature"],
                                                          @"timestamp": cloundinaryCreditinals[@"response"][@"timestamp"],
                                                          @"api_key": cloundinaryCreditinals[@"response"][@"apiKey"],
                                                          }];
}

-(void)likePostFromDoubleTap:(id)sender {
    
    UIButton *selectedButton = (UIButton *)sender;
    NSIndexPath *selectedCellForLike = [self.tableViewOutlet indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    //animating the like button.
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [ani setDuration:0.2];
    [ani setRepeatCount:1];
    [ani setFromValue:[NSNumber numberWithFloat:1.0]];
    [ani setToValue:[NSNumber numberWithFloat:0.5]];
    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[selectedButton layer] addAnimation:ani forKey:@"zoom"];
    
    //checking if the post is already liked or not .if it is already liked no need to perform anything otherwise we need to perform like action.
    
    NSString *likeStatus =  [NSString stringWithFormat:@"%@", self.dataArray[selectedCellForLike.section][@"likeStatus"]];
    if ([likeStatus  isEqualToString:@"0"]) {
        
        selectedButton.selected = YES;
        [[self.dataArray objectAtIndex:selectedButton.tag] setObject:@"1" forKey:@"likeStatus"];
        NSInteger newNumberOfLikes = [self.dataArray[selectedButton.tag][@"likes"] integerValue];
        newNumberOfLikes ++;
        [[self.dataArray objectAtIndex:selectedButton.tag] setObject:[@(newNumberOfLikes) stringValue] forKey:@"likes"];
        [self reloadRowToShowNewNumberOfLikes:selectedButton.tag];
        [self likeAPost:flStrForObj(self.dataArray[selectedButton.tag][@"postId"]) postType:flStrForObj(self.dataArray[selectedButton.tag][@"postsType"])];
    }
}


/*-------------------------------------------------------------------------------*/
#pragma mark - Uploading Image Or Video to Cloudinary.
/*--------------------------------------------------------------------------------*/

- (void)checkUploadImageOrVideo {
    
    // if  RECORD SESSION is available then user trying to upload video otherwise _recordsession is empty so show respective message.
    
    if (_recordsession || _pathOfVideo) {
        [self tableviewHeader];
    }
    else {
        [self tableviewHeader];
    }
    
    //if both _recordsession and _pathOfVideo available then start uploading vide to cloudinary.
    //otherwise user trying to upload image so call uploading image to cloiusdinary .
    
    if (_recordsession || _pathOfVideo||_dataVideo) {
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
    //    [mobileUploader upload:self.postedthumbNailImagePath options:@{
    //                                                                   @"signature":cloundinaryCreditinals[@"response"][@"signature"],
    //                                                                   @"timestamp": cloundinaryCreditinals[@"response"][@"timestamp"],
    //                                                                   @"api_key": cloundinaryCreditinals[@"response"][@"apiKey"],
    //                                                                   }];
}

-(void)uploadingVideoToCloudinary {
    id upload;
    if (_dataVideo) {
         upload=_dataVideo;
    }else{
          upload=  _pathOfVideo;
    }
    
    CLCloudinary *mobileCloudinary = [[CLCloudinary alloc] init];
    [mobileCloudinary.config setValue:cloundinaryCreditinals[@"response"][@"cloudName"] forKey:@"cloud_name"];
    CLUploader* mobileUploader = [[CLUploader alloc] init:mobileCloudinary delegate:self];
    [mobileUploader upload:upload options:@{
                                            @"signature":cloundinaryCreditinals[@"response"][@"signature"],
                                            @"timestamp": cloundinaryCreditinals[@"response"][@"timestamp"],
                                            @"api_key": cloundinaryCreditinals[@"response"][@"apiKey"],
                                            @"resource_type": @"video"
                                            }];
}



/*-----------------------------------------------------*/
#pragma mark - cloudinary delegate
/*----------------------------------------------------*/

- (void)uploaderSuccess:(NSDictionary*)result context:(id)context {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* publicId = [result valueForKey:@"public_id"];
        NSLog(@"Upload success. Public ID=%@, Full result=%@", publicId, result);
        [self.tableViewOutlet setTableHeaderView:nil];
        [uploadingview removeFromSuperview];
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
            NSString *appendString = @"w_150,h_150/";
            NSString * newString = [result[@"url"] stringByReplacingOccurrencesOfString:fixedUrlForCloudinary withString:@""];
            
            thumbNailUrl =[[fixedUrlForCloudinary stringByAppendingString:appendString] stringByAppendingString:newString];
            mainUrl =result[@"url"];
            
            if(mainUrl) {
                [self requestForpostingImage];
            }
        }
    });
}

-(void)uploaderError:(NSString*)result code:(NSInteger )code context:(id)context {
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"failed to  post" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alert show];
    
    statusOfUploading.text = @"Failed";
    tryToUploadAgain.hidden = NO;
    
    NSLog(@"Upload error: %@, %ld", result, (long)code);
}

- (void) uploaderProgress:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite context:(id)context {
    
    
    tryToUploadAgain.hidden = YES;
    
    NSLog(@"Upload progress: %ld/%ld (+%ld)", (long)totalBytesWritten, (long)totalBytesExpectedToWrite, (long)bytesWritten);
    
    
    CGFloat percentageUploaded = (CGFloat )totalBytesWritten/totalBytesExpectedToWrite;
    [customprogressView setProgress:percentageUploaded animated:YES];
}

/*-----------------------------------------------------*/
#pragma mark - Request For Services.
/*----------------------------------------------------*/

-(void)requestForpostingVideo {
    
    if ([_business isEqualToString:@"No"]) {
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
                                      muserCoordinates:flStrForObj(self.taggedFriendStringPoistions)
                                      };
        [self postVideoToSocialMedia:requestDict];
        [WebServiceHandler postImageOrVideo:requestDict andDelegate:self];
    }
    else
    {
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
                                      muserCoordinates:flStrForObj(self.taggedFriendStringPoistions),
                                      mprice:_price,
                                      mproductName:_productName,
                                      mproductUrl:_productlink,
                                      mcategory:_category,
                                      msubCategory:_subcategory,
                                      mcurrency:_currency
                                      };
        [self postVideoToSocialMedia:requestDict];
        [WebServiceHandler businessPostProduct:requestDict andDelegate:self];
    }
}

/**
 *  This method will let the media link generate in main thread
 *
 *  @param feed media path
 */
- (void) postToSocialMedia:(NSDictionary*)postDetails
{
    
    NSLog(@"data Found t:%d",(int)dataForUploading[0][@"twitter"]);
    NSLog(@"data Found f:%d",(int)dataForUploading[0][@"facebook"]);
    
    if ([self.twitter isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Helper twitterSharing:postDetails];
        });
    }
    if ([self.facebook isEqualToString:@"1"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [Helper makeFBPostWithParams:postDetails];
        });
    }
    else if ([_flickr isEqualToString:@"1"])
        
    {
        
        NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
        
        if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
            
            NSString *path = [Helper instagramSharing:postDetails];
            
            _dic = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
            _dic.UTI = @"com.instagram.exclusivegram";
            _dic.delegate = nil;
            
            _dic.annotation = [NSDictionary dictionaryWithObject:NSLocalizedString(@"Shared via @Picogram",nil) forKey:@"InstagramCaption"];
            [_dic presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
            
        }
        else
        {
            [Helper showAlertWithTitle:NSLocalizedString(@"Message",nil) Message:NSLocalizedString(@"You don't have Instagram installed. Download instagram app to get more functionality.",nil)];
            
        }
    }
    
    [self removeTemporaryDataForUploading];
}

/**
 *  This method will let the media link generate in main thread
 *
 *  @param feed media path
 */
- (void) postVideoToSocialMedia:(NSDictionary*)postDetails
{
    if ([flStrForObj(dataForUploading[0][@"twitter"]) isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Helper twitterSharing:postDetails];
        });
        
    }
    if ([flStrForObj(dataForUploading[0][@"facebook"]) isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Helper sharingVideo:postDetails];
        });
    }
    if ([_flickr isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Helper videoOnInstagram:postDetails];
        });
    }
    
    [self removeTemporaryDataForUploading];
}

- (UIDocumentInteractionController *) setupControllerWithURL: (NSURL* ) fileURL usingDelegate: (id <UIDocumentInteractionControllerDelegate>) interactionDelegate {
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL: fileURL];
    interactionController.delegate = interactionDelegate;
    return interactionController;
}

-(void)requestForpostingImage {
    
    bool isValidForCheckingPrice = [self.price containsString:@"."];
    
    if (isValidForCheckingPrice) {
        NSArray *stringsSeparatedBySpace = [self.price componentsSeparatedByString:@"."];
        NSString *laststring = [stringsSeparatedBySpace lastObject];
        
        if (laststring.length == 1) {
            //contains only single dot
            NSString *newPrice = [self.price stringByAppendingString:@"0"];
            self.price = newPrice;
        }
        else if (laststring.length ==0 ){
            NSString *newPrice = [self.price stringByAppendingString:@".00"];
            self.price = newPrice;
        }
    }
    else {
        NSString *newPrice = [self.price stringByAppendingString:@".00"];
        self.price = newPrice;
    }
    
    if ([_business isEqualToString:@"No"]) {
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
                                       muserCoordinates:flStrForObj(self.taggedFriendStringPoistions)
                                      
                                      };
        [self postToSocialMedia:requestDict];
        [WebServiceHandler postImageOrVideo:requestDict andDelegate:self];
    }
    else{
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
                                       muserCoordinates:flStrForObj(self.taggedFriendStringPoistions),
                                      mprice:_price,
                                      mproductName:_productName,
                                      mproductUrl:_productlink,
                                      mcategory:_category,
                                      msubCategory:_subcategory,
                                      mcurrency:_currency
                                      };
        [self postToSocialMedia:requestDict];
        [WebServiceHandler businessPostProduct:requestDict andDelegate:self];
    }
}


-(void)reportPost:(NSInteger)selectedSection{
    NSDictionary *dic = self.dataArray[selectedSection];
    NSString *postId = flStrForObj([dic objectForKey:@"postId"] );
    NSString *postedUser = flStrForObj([dic objectForKey:@"postedByUserName"]);
    //[self reportOption:postId];
    [self reportOption:postId andUserName:postedUser];
    
    
}

-(void)reportOption:(NSString*)postId andUserName:(NSString *)posteUser{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"It's Spam" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSDictionary *requestDict = @{mauthToken :[Helper userToken],
                                          mpostid :postId,
                                          @"reasonFlag":@"0",
                                          @"membername":flStrForObj(posteUser)
                                      };
        [self reportRequest:requestDict];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"It's inappropriate" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        NSDictionary *requestDict = @{mauthToken :[Helper userToken],
                                      mpostid :postId,
                                      @"reasonFlag":@"1",
                                      @"membername":flStrForObj(posteUser)
                                      };
        [self reportRequest:requestDict];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // OK button tapped.
        
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

-(void)reportRequest:(NSDictionary *)dic
{
    [WebServiceHandler sendreportPost:dic andDelegate:self];
}

/*------------------------------------------------------*/
#pragma
#pragma mark - Show Tags On Image.
/*------------------------------------------------------*/

//-(void)showTagsAction:(UITapGestureRecognizer *)sender {
//    UIView *view = sender.view;
//    
//    NSIndexPath *selectedButtontToShowTags = [self.tableViewOutlet indexPathForCell:(UITableViewCell *)[[view superview] superview]];
//    
//    
//    NSArray *namesOfTaggedPeople = [self.dataArray[selectedButtontToShowTags.section][@"usersTaggedInPosts"] componentsSeparatedByString:@","];
//    NSArray *positionsOfNames = [self.dataArray[selectedButtontToShowTags.section][@"taggedUserCoordinates"] componentsSeparatedByString:@",,"];
//    
//    // if there is no one tagged then from response by defaultly we are getting undefined so handling that.
//    if ([namesOfTaggedPeople[0]  isEqualToString:@"undefined"]) {
//        namesOfTaggedPeople = nil;
//        positionsOfNames = nil;
//    }
//    
//    if (!view.subviews.count) {
//        for( int i = 0; i < namesOfTaggedPeople.count; i++ ) {
//            
//            
//            UIButton *customButton;
//            customButton = [UIButton buttonWithType: UIButtonTypeCustom];
//            [customButton setBackgroundColor: [UIColor clearColor]];
//            [customButton setTitleColor:[UIColor blackColor] forState:
//             UIControlStateHighlighted];
//            //sets background image for normal state
//            [customButton setBackgroundImage:[UIImage imageNamed:
//                                              @"tag_people_tittle_btn"]
//                                    forState:UIControlStateNormal];
//            [customButton setBackgroundImage:[UIImage imageNamed:@"tag_people_tittle_btn"] forState:UIControlStateHighlighted];
//            [customButton setTitle:[namesOfTaggedPeople objectAtIndex:i] forState:UIControlStateNormal];
//            CGPoint fromPoint = CGPointFromString([positionsOfNames objectAtIndex:i]);
//            
//            CGSize stringsize = [customButton.titleLabel.text sizeWithFont:[UIFont fontWithName:RobotoRegular size:15]];
//            
//            [customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
//            //checking the poistion is going out of imaege  or not.
//            //if button poistion is out of image then need to alifgn properly.
//            
//            if (fromPoint.x + customButton.frame.size.width > view.frame.size.width || fromPoint.y + customButton.frame.size.height > view.frame.size.height) {
//                NSLog(@"custom button is out of view");
//                if (fromPoint.x + customButton.frame.size.width > view.frame.size.width) {
//                    NSLog(@"custom button is out of view along horizontal");
//                    [customButton setFrame:CGRectMake(fromPoint.x - ((fromPoint.x + customButton.frame.size.width) - view.frame.size.width),fromPoint.y, stringsize.width + 50, 35)];
//                }
//                else {
//                    NSLog(@"custom button is aligned properly along horizontal");
//                }
//                
//                if( fromPoint.y + customButton.frame.size.height > view.frame.size.height) {
//                    NSLog(@"custom button is out of view along vertical");
//                    //[customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
//                    
//                    [customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y - ((fromPoint.y + customButton.frame.size.height) - view.frame.size.height), stringsize.width + 50, 35)];
//                }
//                else {
//                    NSLog(@"custom button is aligned properly along vertical");
//                }
//                
//                if (fromPoint.x + customButton.frame.size.width > view.frame.size.width && fromPoint.y + customButton.frame.size.height > view.frame.size.height) {
//                    [customButton setFrame:CGRectMake(fromPoint.x - ((fromPoint.x + customButton.frame.size.width) - view.frame.size.width),fromPoint.y - ((fromPoint.y + customButton.frame.size.height) - view.frame.size.height), stringsize.width + 50, 35)];
//                    
//                    NSLog(@"custom button is out of view along both horizontal and vertical");
//                }
//            }
//            else {
//                [customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
//            }
//            customButton.tag = 12345 + i;
//            [customButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
//            
//            [UIView transitionWithView:view
//                              duration:0.2
//                               options:UIViewAnimationOptionTransitionCrossDissolve
//                            animations:^{
//                                [view addSubview:customButton];
//                                [self.view layoutIfNeeded];
//                            }
//                            completion:NULL];
//        }
//    }
//    else {
//        for (UIButton *eachButton in view.subviews) {
//            [UIView transitionWithView:view
//                              duration:0.2
//                               options:UIViewAnimationOptionTransitionCrossDissolve
//                            animations:^{
//                                if (eachButton.tag ==1520) {
//                                }
//                                else {
//                                    [eachButton removeFromSuperview];
//                                    [self.view layoutIfNeeded];
//                                }
//                            }
//                            completion:NULL];
//        }
//    }
//}

- (void)buttonClicked:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    [self openProfileOfUsername:selectedButton.titleLabel.text];
}

-(void)openProfileOfUsername:(NSString *)selectedUserName {
    
    if ([selectedUserName isEqualToString:@""]) {
        
    }
    else {
        UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
        newView.checkingFriendsProfile = YES;
        newView.checkProfileOfUserNmae = selectedUserName;
        [self.navigationController pushViewController:newView animated:YES];
    }
}

- (void)buyButtonClicked :(id)sender {
    UIButton *selectedHeaderButton = (UIButton *)sender;
    NSInteger selectedIndex = selectedHeaderButton.tag % 10000;
    NSString *buyUrl =  flStrForObj(self.dataArray[selectedIndex][@"productUrl"]);
    WebViewForDetailsVc *webView = [[WebViewForDetailsVc alloc]init];
    webView.category = flStrForObj(self.dataArray[selectedIndex][@"category"]);
    webView.subcategory = flStrForObj(self.dataArray[selectedIndex][@"subCategory"]);
    webView.weburl = buyUrl;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webView animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    
}


#pragma mark - MoreActions


-(void)copyShareURL:(NSInteger )selectedSection {
    [errorMessageLabelOutlet setHidden:NO];
    [self showingErrorAlertfromTop:@"Link copied to clipboard."];
    NSLog(@"copyShareURL of index :%ld ",(long)selectedSection);
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *postId = [NSString stringWithFormat:@"%@",self.dataArray[selectedSection][@"postId"]];
    NSString *copyWebUrl = [Helper makeWebPostLink:postId andUserName:self.dataArray[selectedSection][@"postedByUserName"]];
    pasteboard.string = copyWebUrl;
    
    //    NSString *copymainurl = _dataArray[selectedSection][@"mainUrl"];
    //    pasteboard.string = copymainurl;
}

-(void)turnOnPostNotifications:(NSInteger )selectedSection {
    NSLog(@"turnOnPostNotifications of index :%ld ",(long)selectedSection);
}

- (void)paste {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *string = pasteboard.string;
    NSLog(@"%@",string);
}

-(void)deletePost:(NSInteger)selectedSection {
    // NSDictionary *dic = _dataArray[selectedSection];
    UIAlertView *alertForDeleteConfirmation =[[UIAlertView alloc] initWithTitle:@"Confirm To Delete" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [alertForDeleteConfirmation show];
    alertForDeleteConfirmation.tag = 26;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 26) {
        if(buttonIndex == 0)//cancel pressed
        {
        }
        else if(buttonIndex == 1)//confirm delete  pressed.
        {
            NSUInteger row = [selectedCellIndexPathForActionSheet section];
            //deleting a post.
            NSDictionary *requestDict = @{
                                          mauthToken :flStrForObj([Helper userToken]),
                                          mpostid:self.dataArray[row][@"postId"]
                                          };
            [WebServiceHandler deletePost:requestDict andDelegate:self];
            NSLog(@"%@",requestDict);
            ProgressIndicator *HomePI = [ProgressIndicator sharedInstance];
            [HomePI showPIOnView:self.view withMessage:@"Deleting..."];
        }
    }
}


-(void)sharePost:(NSInteger)selectedSection{
    
    [[NSUserDefaults standardUserDefaults]setInteger:selectedSection forKey:@"index"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    //[self performSegueWithIdentifier:@"homeTosharingSegue" sender:self];
    
    /*  HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
     newView.navTittle = @"string";
     [self.navigationController pushViewController:newView animated:YES];*/
    
    SharingPostViewController *postshare = [self.storyboard instantiateViewControllerWithIdentifier:@"sharingPost"];
    //[postshare.postDetailsDic setValue:responseData[selectedSection] forKey:@"postDetail"];
    postshare.postDetailsDic = _dataArray[selectedSection];
    [self.navigationController pushViewController:postshare animated:YES];
}


-(void)shareToFacebook:(NSInteger )selectedSection {
    NSLog(@"SHAREtO FB of index :%ld ",(long)selectedSection);
    
    NSDictionary *dic = _dataArray[selectedSection];
    
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi showMessage:@"Posting.." On:self.view];
    
    if ([flStrForObj([dic objectForKey:@"postsType"] )isEqualToString:@"0"]) {
        // NSString *mediaLink = [self getWebLinkForFeed:feed];
        
        NSString *caption = NSLocalizedString(@"Checkout this cool app",nil);
        
        // NSString *description;
        
        NSString *picturelink = [Helper getWebLinkForFeed:_dataArray[selectedSection]]; //responseData[selectedSection][@"mainUrl"];
        
        //NSData *videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:picturelink]];
        
        NSMutableDictionary *params1 = [NSMutableDictionary dictionaryWithCapacity:3L];
        
        //[params1 setObject:videoData forKey:@"video.mov"];
        [params1 setObject:[NSURL URLWithString:picturelink] forKey:@"link"];
        [params1 setObject:NSLocalizedString(@"Created from Picogram.",nil) forKey:@"title"];
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
            NSString *urlToDownload = _dataArray[selectedSection][@"mainUrl"];
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

- (void)delegateFordoubLeTapCell:(InstaVideoTableViewCell *)cell {
    
    UIView *view = cell.videoView;
    
    UIImageView *animateImage = cell.popUpImageViewOutlet;
    
    NSIndexPath *indexPath = [self.tableViewOutlet indexPathForCell:(UITableViewCell *)[[animateImage superview] superview]];
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row+2 inSection:indexPath.section];
    
    LikeCommentTableViewCell *selectedCell = [self.tableViewOutlet cellForRowAtIndexPath:indexPath];
    
    UIButton *selectedButton = selectedCell.likeButtonOutlet;
    
    //animating the like button.
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [ani setDuration:0.2];
    [ani setRepeatCount:1];
    [ani setFromValue:[NSNumber numberWithFloat:1.0]];
    [ani setToValue:[NSNumber numberWithFloat:0.5]];
    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[selectedButton layer] addAnimation:ani forKey:@"zoom"];
    
    //checking if the post is already liked or not .if it is already liked no need to perform anything otherwise we need to perform like action.
    
    NSString *likeStatus =  [NSString stringWithFormat:@"%@", self.dataArray[indexPath.section][@"likeStatus"]];
    if ([likeStatus  isEqualToString:@"0"]) {
        
        selectedButton.selected = YES;
        [[self.dataArray objectAtIndex:selectedButton.tag] setObject:@"1" forKey:@"likeStatus"];
        NSInteger newNumberOfLikes = [self.dataArray[selectedButton.tag][@"likes"] integerValue];
        newNumberOfLikes ++;
        [[self.dataArray objectAtIndex:selectedButton.tag] setObject:[@(newNumberOfLikes) stringValue] forKey:@"likes"];
        [self reloadRowToShowNewNumberOfLikes:selectedButton.tag];
        [self likeAPost:flStrForObj(self.dataArray[selectedButton.tag][@"postId"]) postType:flStrForObj(self.dataArray[selectedButton.tag][@"postsType"])];
    }
    
    animateImage.hidden = NO;
    animateImage.alpha = 0;
    
    [[view superview] bringSubviewToFront:animateImage];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        animateImage.transform = CGAffineTransformMakeScale(1.3, 1.3);
        animateImage.alpha = 1.0;
    }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              animateImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                                                  animateImage.transform = CGAffineTransformMakeScale(1.3, 1.3);
                                                  animateImage.alpha = 0.0;
                                              }
                                                               completion:^(BOOL finished) {
                                                                   animateImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                                   
                                                                   [[view superview] sendSubviewToBack:animateImage];
                                                               }];
                                          }];
                     }];
}


- (void)delegateForSingleTapCell:(InstaVideoTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableViewOutlet indexPathForCell:(UITableViewCell *)[[cell.videoView superview] superview]];
    InstaVideoTableViewCell *selectedCell = [self.tableViewOutlet cellForRowAtIndexPath:indexPath];
    [self showTagsButtonAction:selectedCell.showTagsButtonOutlet];
}

- (IBAction)firstCommentUserNameButton:(id)sender {
    UIButton *userNameButton = (UIButton *)sender;
    NSString *selectedUserName = flStrForObj([userNameButton titleForState:UIControlStateNormal]);
    [self openProfileOfUsername:selectedUserName];
}

- (IBAction)captionUserNameButtonAction:(id)sender {
    UIButton *userNameButton = (UIButton *)sender;
    NSString *selectedUserName = flStrForObj([userNameButton titleForState:UIControlStateNormal]);
    [self openProfileOfUsername:selectedUserName];
}

- (IBAction)chatActionButton:(id)sender {
    
    HomeScreenTabBarController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"homeScreenTabBarController"];
    
    PageContentViewController * pgController = [PageContentViewController sharedInstance];
    [pgController.pageViewController setViewControllers:@[homeVC] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        if (finished) {
            
        }
    }];
}

- (IBAction)secondCommentUserNmaeButtonAction:(id)sender {
    UIButton *userNameButton = (UIButton *)sender;
    NSString *selectedUserName = flStrForObj([userNameButton titleForState:UIControlStateNormal]);
    [self openProfileOfUsername:selectedUserName];
}

- (IBAction)shareButtonAction:(id)sender {
    
   
        UIButton *likeButton = (UIButton *)sender;
        
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friends"];
        self.friendesList = [[managedObjectContext executeFetchRequest:fetchRequest error:nil]mutableCopy];
        
        
        //    NSInteger num = [sender integerValue];
        NSLog(@"%@",[self.dataArray objectAtIndex:likeButton.tag]);
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        shareNib = [[ShareViewXib alloc] init];
        shareNib.delegate = self;
        shareNib.friendesListShow =self.friendesList;
        shareNib.friendesPost = [self.dataArray objectAtIndex:likeButton.tag];
        [shareNib showViewWithContacts:window];
    
}

@end
