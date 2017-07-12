	
//
//  InstaVIdeoTableViewController.m
//  InstaVideoPlayerExample
//
//  Created by Rahul Sharma on 22/07/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "InstaVIdeoTableViewController.h"
#import "InstaVideoTableViewCell.h"
#import "LikeCommentTableViewCell.h"
#import "PostDetailsTableViewCell.h"
#import "SVPullToRefresh.h"
#import "ZOWVideoCache.h"
#import "ProgressIndicator.h"

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
#import "HomeViewTableViewController.h"
#import "SharingPostViewController.h"
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
// Chat End

@interface InstaVIdeoTableViewController ()<WebServiceHandlerDelegate,InstagramVideoViewTapDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate,MyTableViewCellDelegate>
{
    UILabel *errorMessageLabelOutlet;
    BOOL classIsAppearing;
    // Chat Start
    ShareViewXib *shareNib;
    UIView *polygonView;
    // Chat End
}

@property (strong,nonatomic) NSMutableArray *dataArray;
@property int currentIndex;
@end

@implementation InstaVIdeoTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
     _dataArray = [NSMutableArray new];
    
    [self requestForPostsBasedOnRequirement];
    [self customeError];
    
    [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    [self creatingNotificationForUpdatingLikeDetails];
    
    [self notificationForDeleteApost];
    if (_category) {
        
        if (_subcategory) {
            UILabel *titleLbl = [[UILabel alloc]init];
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"subcatecategoryIcon.png"];
            attachment.bounds = CGRectMake(0, 0, attachment.image.size.width, attachment.image.size.height);
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"   %@",_category]];
            [myString appendAttributedString:attachmentString];
            NSMutableAttributedString *myString1= [[NSMutableAttributedString alloc] initWithString:_subcategory];
            [myString appendAttributedString:myString1];
            
            titleLbl.attributedText = myString;
            [titleLbl sizeToFit];
            titleLbl.textColor = [UIColor blackColor];
            self.navigationItem.titleView = titleLbl;
        }
        else
            self.title = _category;
    }
    else
         self.navigationItem.title = self.navigationBarTitle;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    

    
   
    [self createNavLeftButton];
   
    
    [self initFooterView];
}

-(void)updateFollowStatus {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFollwoStatus:) name:@"updatedFollowStatus" object:nil];
}


-(void)updateFollwoStatus:(NSNotification *)noti {
    
    if (!classIsAppearing) {
        //check the postId and Its Index In array.
        NSString *userName = flStrForObj(noti.object[@"newUpdatedFollowData"][@"userName"]);
        NSString *foolowStatusRespectToUser = noti.object[@"newUpdatedFollowData"][@"newFollowStatus"];
        
        
        for (int i=0; i <self.dataArray.count;i++) {
            if ([flStrForObj(self.dataArray[i][@"postedByUserName"]) isEqualToString:userName]) {
                self.dataArray[i][@"userFollowRequestStatus"] = foolowStatusRespectToUser;
                NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:i];
//                NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
//                [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:rowToReload.section] withRowAnimation:UITableViewRowAnimationNone];
                
                break;
            }
        }
    }
}


-(void)notificationForDeleteApost {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePostFromNotification:) name:@"deletePost" object:nil];
}

-(void)deletePostFromNotification:(NSNotification *)noti {
    NSString *updatepostId = flStrForObj(noti.object[@"deletedPostDetails"][@"postId"]);
    for (int i=0; i <self.dataArray.count;i++) {
        
        if ([flStrForObj(self.dataArray[i][@"postId"]) isEqualToString:updatepostId])
        {
            //NSUInteger atSection = [selectedCellIndexPathForActionSheet section];
            [self removeRelatedDataOfDeletePost:i];
            [self.tableViewOutlet beginUpdates];
            [self.tableViewOutlet deleteSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableViewOutlet endUpdates];
            
            break;
        }
    }
}

-(void)removeRelatedDataOfDeletePost:(NSInteger )atSection {
    
    [self.dataArray removeObjectAtIndex:atSection];
    
    if (self.dataArray.count == 0) {
       [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)customeError
{
    
    errorMessageLabelOutlet = [[UILabel alloc]initWithFrame:CGRectMake(0, -80, [UIScreen mainScreen].bounds.size.width, 50)];
    
    errorMessageLabelOutlet.backgroundColor = [UIColor colorWithRed:108/255.0f green:187/255.0f blue:79/255.0f alpha:1.0];
    
    errorMessageLabelOutlet.textColor = [UIColor whiteColor];
    
    errorMessageLabelOutlet.textAlignment = NSTextAlignmentCenter;
    [errorMessageLabelOutlet setHidden:YES];
    UIWindow  *Window = [[[UIApplication sharedApplication] delegate] window];
    [Window addSubview:errorMessageLabelOutlet];
}

-(void)creatingNotificationForUpdatingLikeDetails {
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDetails:) name:@"updatePostDetails" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedCommentsdata:) name:@"passingUpdatedComments" object:nil];
}

-(void)updatedCommentsdata:(NSNotification *)noti {
    //check the postId and Its Index In array.
    
    if (!classIsAppearing) {
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


-(void)reportPost:(NSInteger)selectedSection{
    NSDictionary *dic = self.dataArray[selectedSection];
    NSString *postId = flStrForObj([dic objectForKey:@"postId"] );
    NSString *postedUser = flStrForObj([dic objectForKey:@"postedByUserName"]);
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

-(void)updateDetails:(NSNotification *)noti {
    
    //check the postId and Its Index In array.
    if (!classIsAppearing) {
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
                [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                
                break;
            }
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    
    classIsAppearing = NO;
    NSArray* cells = _tableViewOutlet.visibleCells;
    for (InstaVideoTableViewCell *cell in cells) {
        if([cell isKindOfClass:[InstaVideoTableViewCell class]])
        {
            [cell.videoView pause];
        }
    }
 }

-(void)viewWillAppear:(BOOL)animated {
    
    classIsAppearing = YES;
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"postKey"]) {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"postKey"];
        ProgressIndicator *pi = [ProgressIndicator sharedInstance];
        [pi showMessage:@"Posting.." On:self.view];
        [NSTimer scheduledTimerWithTimeInterval:10.5 target:self selector:@selector(hideProgress) userInfo:nil repeats:NO];
    }
    
    NSArray* cells = self.tableViewOutlet.visibleCells;
    for (InstaVideoTableViewCell *cell in cells) {
        if([cell isKindOfClass:[InstaVideoTableViewCell class]])
        {
            [cell.videoView resume];
        }
    }
}

-(void)hideProgress
{
    ProgressIndicator *pi = [ProgressIndicator sharedInstance];
    [pi hideProgressIndicator];
}
-(void)requestForPostsBasedOnRequirement {
    
    
    
    if ([self.showListOfDataFor isEqualToString:ListViewForHashTag]) {
        
        //for Hash Tag response In ListView Screen.
        //very First Time No Need To Request.
        self.navigationItem.title =@"Picogarm";

        self.dataArray = self.dataForListView[@"data"];
        
        [self jumpToSection];
        
    }
    else if ([self.showListOfDataFor isEqualToString:ListViewForPostsByLocation]) {
        
        //for postsByLocation
        //very First Time No Need To Request.

        self.dataArray = self.dataForListView[@"data"];
        
        [self jumpToSection];
    }
    else if ([self.showListOfDataFor isEqualToString:ListViewForPhotosOfYou]) {
        //for userpostViewController detail post
        //very First Time No Need To Request.
        
        NSMutableArray *tempArray =[[NSMutableArray alloc] init];
        [tempArray addObject:self.dataFromExplore];
        self.dataArray = tempArray;
    }
    else if([self.showListOfDataFor isEqualToString:ListViewForPostFromActivity])
    {
            [self getActivityPost];
    }
    else if ([self.showListOfDataFor isEqualToString:ListViewForPostFromProfile]) {
        NSMutableArray *tempArray =[[NSMutableArray alloc] init];
        [tempArray addObject:self.dataFromExplore];
        self.dataArray = [tempArray mutableCopy];
        [self.dataArray setValue:flStrForObj(self.UserNameForPostFromProfile) forKey:@"postedByUserName"];
        [self.dataArray setValue:flStrForObj(self.profilePicForPostFromProfile) forKey:@"profilePicUrl"];
       
    }
    else if ([self.showListOfDataFor isEqualToString:ListViewForExplore]) {
        self.dataArray = self.dataFromExplore;
        [self jumpToSection];
        [self updateFollowStatus];
    }
    else if ([self.showListOfDataFor isEqualToString:ListViewForPostFromSelfActivity]) {
        
    }
    else {
        
        //for Home Screen.
        //requestingForPosts.
        
        __weak InstaVIdeoTableViewController *weakSelf = self;
        self.currentIndex = 0;
        
        // setup pull-to-refresh
        [self.tableView addPullToRefreshWithActionHandler:^{
            weakSelf.currentIndex = 0;
            [weakSelf serviceRequestingForPosts:0];
            
        }];
        
        // setup infinite scrollinge
        [self.tableView addInfiniteScrollingWithActionHandler:^{
            [weakSelf serviceRequestingForPosts:weakSelf.currentIndex];
            
        }];
        
        [weakSelf serviceRequestingForPosts:0];
    }
}


-(void)jumpToSection {
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(jumpToSectionNumber) userInfo:nil repeats:NO];
}

-(void)jumpToSectionNumber {
    CGRect sectionRect = [self.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.movetoRowNumber]];
    CGPoint offset =self.tableView.contentOffset;
    offset.y = sectionRect.origin.y;
    self.tableView.contentOffset = offset;
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
   return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row ==0) {
        
        InstaVideoTableViewCell *cell = (InstaVideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"InstaVideoTableViewCell" forIndexPath:indexPath];
        [cell setDelegate:self];
        NSString *urlString;
        if (_dataArray[indexPath.row][@"mainUrl"])
            urlString = _dataArray[indexPath.section][@"mainUrl"];
        else
            urlString = _dataArray[indexPath.section][@"postMainURl"];
        
        cell.url = urlString;
        
        
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        
        dispatch_async(queue, ^{
            
            if ([flStrForObj(_dataArray[indexPath.section][@"postsType"]) isEqualToString:@"0"] || [self.postType isEqualToString:@"0"] ) {
                cell.postType = @"0";
                
                [cell.videoView setHidden:YES];
                [cell.imageViewOutlet setHidden:NO];
                [cell setUrl:urlString];
                if (_dataArray[indexPath.row][@"thumbnailImageUrl"])
                    [cell setPlaceHolderUrl:_dataArray[indexPath.row][@"thumbnailImageUrl"]];
                else
                    [cell setPlaceHolderUrl:_dataArray[indexPath.row][@"properties"][@"thumbnailImageUrl"]];
                [cell loadImageForCell];
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
        arrowImage.image = [UIImage imageNamed:@"shopnow.png"];
        
        
        
        NSString *chkCurrency = flStrForObj(_dataArray[indexPath.section][@"currency"]);
        NSString *priceWithtype;
        if (chkCurrency.length) {
            if ([_dataArray[indexPath.section][@"currency"] isEqualToString:@"INR"]) {
                priceWithtype = [NSString stringWithFormat:@"\u20B9 %@",_dataArray[indexPath.section][@"price"]];
            }else
            {
                priceWithtype = [NSString stringWithFormat:@"$ %@",_dataArray[indexPath.section][@"price"]];
            }
        }
        
        //priceLbl.textColor = [UIColor colorWithRed:226.0f/255.0f green:13.0f/255.0f blue:69.0f/255.0f alpha:1.0];
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"shopnow.png"];
        attachment.bounds = CGRectMake(0, 0, attachment.image.size.width/2, attachment.image.size.height/2);
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",priceWithtype]];
        [myString appendAttributedString:attachmentString];
        //        NSMutableAttributedString *myString1= [[NSMutableAttributedString alloc] initWithString:_subcategory];
        //        [myString appendAttributedString:myString1];
        priceLbl.textAlignment = NSTextAlignmentRight;
        priceLbl.attributedText = myString;
        [priceLbl sizeToFit];
        
        
        
        NSString *isbusiness = flStrForObj(_dataArray[indexPath.section][@"category"]);
       // if ([_controllerType isEqualToString:@"Shopping"])
       if (isbusiness.length)
        {
            showNow.frame = CGRectMake(10, 0,100, 40);
            buyButton.frame = CGRectMake(0, 0, w, 40);
            linelbl.frame = CGRectMake(10, 39, w-20, 1);
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
        NSString *isbusiness = flStrForObj(_dataArray[indexPath.section][@"category"]);
        if (isbusiness.length)
            return 40;
        else
            return 0;
    }
    else if (indexPath.row ==2)
        return 45;
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
        frame.size.width=self.view.frame.size.width - 20;
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
        firstCommentlblframe.size.width=self.view.frame.size.width - 20;
        firstCommentlbl.frame=firstCommentlblframe;
        
        CGRect secondCommentlblframe=secondCommentlbl.frame;
        secondCommentlblframe.size.width=self.view.frame.size.width -20;
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
            heightOfCaption = [Helper measureHieightLabel:captionlbl] +5;
        }
        
        if ([firstCommentlbl.text isEqualToString:@""]) {
            heightOfFirstComment = 0;
        }
        else {
            heightOfFirstComment = [Helper measureHieightLabel:firstCommentlbl]+5;
        }
        
        if ([secondCommentlbl.text isEqualToString:@""]) {
            heightOfSecondComment = 0;
        }
        else {
            heightOfSecondComment = [Helper measureHieightLabel:secondCommentlbl]+5;
        }
        
        if (heightOfFirstComment > 0 && heightOfSecondComment > 0) {
            heightOfViewAllCommentsButton = 25;
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




- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InstaVideoTableViewCell *cell1 = (InstaVideoTableViewCell *)cell;
    if(![cell1 isKindOfClass:[InstaVideoTableViewCell class]])
    {
        return;
    }
    [cell1.videoView pause];
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
        [cell notifyCompletelyVisible];
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
    __weak InstaVIdeoTableViewController *weakSelf = self;
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakSelf.tableView.pullToRefreshView stopAnimating];
        [weakSelf.tableView.infiniteScrollingView stopAnimating];
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
    [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
}

/*---------------------------------------*/
#pragma
#pragma mark - Button Actions
/*---------------------------------------*/

- (void)buyButtonClicked :(id)sender {
    UIButton *selectedHeaderButton = (UIButton *)sender;
    NSInteger selectedIndex = selectedHeaderButton.tag % 10000;
    NSString *buyUrl =  flStrForObj(self.dataArray[selectedIndex][@"productUrl"]);
    WebViewForDetailsVc *webView = [[WebViewForDetailsVc alloc]init];
    webView.category = flStrForObj(self.dataArray[selectedIndex][@"productName"]);
    webView.subcategory = flStrForObj(self.dataArray[selectedIndex][@"subCategory"]);
    webView.weburl = buyUrl;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webView animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    
}


- (IBAction)likeButtonAction:(id)sender {
    UIButton *likeButton = (UIButton *)sender;
    
    // adding animation for selected button
    [self animateButton:likeButton];
    
    if(likeButton.selected) {
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
               // [self turnOnPostNotifications:tag%2000];
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


//-(void)changeTitle:(NSString *)userName {
//    UITableViewHeaderFooterView *header = [self.tableViewOutlet  headerViewForSection:0];
//
//}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    view.backgroundColor =  [UIColor whiteColor];
    
    // Create custom view to display section header... /
    
    //creating user name label
    UILabel *UserNamelabel = [[UILabel alloc] init];
    
    if (_dataArray[section][@"postedByUserName"])
        UserNamelabel.text = flStrForObj(_dataArray[section][@"postedByUserName"]);
    else
        UserNamelabel.text = flStrForObj(_dataArray[section][@"membername"]);
    
    [UserNamelabel setFont:[UIFont fontWithName:RobotoMedium size:15]];
    UserNamelabel.textColor =[UIColor blackColor];
    
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *placeName = flStrForObj(_dataArray[section][@"place"]);
    
    if ([placeName isEqualToString:@"null"] ||[placeName isEqualToString:@"[object Object]"]) {
        placeName = @"";
    }
    
     [locationButton.titleLabel setFont:[UIFont fontWithName:RobotoLight  size:12]];
    locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    locationButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
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
    headerButton.backgroundColor =   [UIColor whiteColor];
    headerButton.tag = 10000 + section ;
    
    
    
    //creating  total  header  as button
    UIButton *FollowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    FollowButton.tag = 11000 + section ;
    [FollowButton  setTitleColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    FollowButton.frame = CGRectMake(self.view.frame.size.width - 110,15,100,26);
    [self updateFollowStatusForSectionHeader:FollowButton atSection:section followStatus:flStrForObj(_dataArray[section][@"userFollowRequestStatus"])];
    [FollowButton.titleLabel setFont:[UIFont fontWithName:RobotoRegular size:12]];
    [FollowButton addTarget:self
                     action:@selector(followButtonClicked:)
           forControlEvents:UIControlEventTouchUpInside];
    
//    if (![self.showListOfDataFor isEqualToString:ListViewForExplore] || [self.dataArray[section][@"postedByUserName"]  isEqualToString:flStrForObj([Helper userName])]) {
//        FollowButton.hidden = YES;
//        
//        //setting position of headerButton,UserImageView,timeLabel in customized  tableView Section Header.
//        //if there is no place then usernamelabel will come in middle
//        if ([placeName isEqualToString:@""]) {
//            UserNamelabel.frame=CGRectMake(60, 20, self.view.frame.size.width - 100, 18);
//            locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 120, 0);
//        }
//        else {
//            UserNamelabel.frame=CGRectMake(60, 10, self.view.frame.size.width - 100, 18);
//            locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 120, 18);
//        }
//        
//    }
//    else {
//        FollowButton.hidden = NO;
//        
//        //setting position of headerButton,UserImageView,timeLabel in customized  tableView Section Header.
//        //if there is no place then usernamelabel will come in middle
//        if ([placeName isEqualToString:@""]) {
//            UserNamelabel.frame=CGRectMake(60, 20, self.view.frame.size.width - 200, 18);
//            locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 200, 0);
//            
//        }
//        else {
//            UserNamelabel.frame=CGRectMake(60, 10, self.view.frame.size.width - 200, 18);
//            locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 200, 18);
//        }
//
//        
//      
//    }
    
    
    UIImageView *locationImageView = [[UIImageView alloc] init];
    if (![self.showListOfDataFor isEqualToString:ListViewForExplore] || [self.dataArray[section][@"postedByUserName"]  isEqualToString:flStrForObj([Helper userName])]) {
        FollowButton.hidden = YES;
        
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
            
            if (width > self.view.frame.size.width -100) {
                locationButton.frame = CGRectMake(60, 30, self.view.frame.size.width - 120, 18);
                locationImageView.frame = CGRectMake(locationButton.frame.size.width + 60, 34, 8, 10);
            }
            else {
                locationButton.frame = CGRectMake(60, 30,width +30, 18);
                
                locationImageView.frame = CGRectMake(locationButton.frame.size.width + 30, 34, 8, 10);
            }
            locationImageView.image = [UIImage imageNamed:@"home_next_arrow_icon_off"];
            //locationImageView.image = [UIImage imageNamed:@"home_next_arrow_icon_off"];
        }
    }
    else {
        FollowButton.hidden = NO;
        
        //setting position of headerButton,UserImageView,timeLabel in customized  tableView Section Header.
        //if there is no place then usernamelabel will come in middle
        if ([placeName isEqualToString:@""]) {
            UserNamelabel.frame=CGRectMake(60, 20, self.view.frame.size.width - 200, 18);
            locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 200, 0);
        }
        else {
            UserNamelabel.frame=CGRectMake(60, 10, self.view.frame.size.width - 200, 18);
            
            
            CGSize stringSize = [locationButton.titleLabel.text sizeWithAttributes:
                                 @{NSFontAttributeName: [UIFont fontWithName:RobotoRegular size:12]}];
            
            //[locationButton.titleLabel.text sizeWithFont:[UIFont fontWithName:RobotoRegular size:12]];
            CGFloat width = stringSize.width;
            
            if (width > self.view.frame.size.width - 200) {
                locationButton.frame = CGRectMake(60, 30, self.view.frame.size.width - 220, 18);
                locationImageView.frame = CGRectMake(locationButton.frame.size.width + 60, 34, 8, 10);
            }
            else {
                locationButton.frame = CGRectMake(60, 30,width +30, 18);
                
                locationImageView.frame = CGRectMake(locationButton.frame.size.width + 30, 34, 8, 10);
            }
            locationImageView.image = [UIImage imageNamed:@"home_next_arrow_icon_off"];
            
            
            
            
            //            if (stringSize.width > self.view.frame.size.width - 200 ) {
            //               locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 200, 18);
            //            }
            //            else {
            //                locationButton.frame = CGRectMake(60, 30,width +30, 18);
            //            }
            //
            //
            //
            //            locationImageView.frame = CGRectMake(locationButton.frame.size.width + 30, 34, 8, 10);
            //            //locationImageView.image = [UIImage imageNamed:@"home_next_arrow_icon_off"];
        }
    }
   
    
    
    //creating user image on tableView Header
    UIImageView *UserImageView =[[UIImageView alloc] init];
    [UserImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(_dataArray[section][@"profilePicUrl"])] placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
    
    
   
    
    UserImageView.frame = CGRectMake(10,8,40,40);
    
    [self.view layoutIfNeeded];
    UserImageView.layer.cornerRadius = UserImageView.frame.size.height/2;
    UserImageView.clipsToBounds = YES;
    headerButton.frame = CGRectMake(0, 1, tableView.frame.size.width,56);
    
    
    // adding  headerButton,UserImageView,timeLabel,UserNamelabel to the customized tableView  Section Header.
    
    [view addSubview:headerButton];
    [view addSubview:UserImageView];
    [view addSubview:locationImageView];
    [view addSubview:UserNamelabel];
    [view addSubview:locationButton];
   [view addSubview:FollowButton];
    return view;
}

-(void)followButtonClicked:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    
    NSInteger buttonIndex = selectedButton.tag%11000;
    
    // _privateAccountState ----> 1 for account is private
    // _privateAccountState ----> 0 for account is public
    
    NSString *memberPrivateAccountState = @"0";
    
    if ([memberPrivateAccountState isEqualToString:@"1"]) {
        
        //actions for when the account is private.
        // if the button title is follow then we should request for follow request and otherwise unfollow request.
        
        if ([selectedButton.titleLabel.text isEqualToString:@" FOLLOW"]) {
            [selectedButton  setTitle:@" REQUESTED" forState:UIControlStateNormal];
            [selectedButton setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
            
            [self sendNewFollowStatusThroughNotification:flStrForObj(self.dataArray[buttonIndex][@"postedByUserName"]) andNewStatus:@"0"];
            
            //arrayOfFollowingStaus[selectedButton.tag%1000] = @"0";
            
          
            [selectedButton setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
            selectedButton.backgroundColor = requstedButtonBackGroundColor;
            selectedButton .layer.borderColor = [UIColor clearColor].CGColor;
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :flStrForObj(self.dataArray[buttonIndex][@"postedByUserName"]),
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
        else if ([selectedButton.titleLabel.text isEqualToString:@" FOLLOWING"])  {
            
              [self showUnFollowAlert:flStrForObj(self.dataArray[buttonIndex][@"profilePicUrl"]) and:flStrForObj(self.dataArray[buttonIndex][@"postedByUserName"]) and:selectedButton];
            
//            [selectedButton  setTitle:@" FOLLOW" forState:UIControlStateNormal];
//            selectedButton.backgroundColor = followButtonBackGroundColor;
//            selectedButton .layer.borderColor = [UIColor whiteColor].CGColor;
//            
//            //arrayOfFollowingStaus[selectedCellForLike.row] = @"0";
//            
//            [self sendNewFollowStatusThroughNotification:flStrForObj(self.dataArray[indexPath.section][@"postedByUserName"]) andNewStatus:@"2"];
//            
//            //passing parameters.    muserNameToUnFollow
//            NSDictionary *requestDict = @{muserNameToUnFollow     :flStrForObj(self.dataArray[indexPath.section][@"postedByUserName"]),
//                                          mauthToken            :[Helper userToken],
//                                          };
//            //requesting the service and passing parametrs.
//            [WebServiceHandler unFollow:requestDict andDelegate:self];
        }
        else {
            // cancel request for follow.
            [selectedButton  setTitle:@" FOLLOW" forState:UIControlStateNormal];
            // arrayOfFollowingStaus[selectedButton.tag%1000] = @"2";
            [self sendNewFollowStatusThroughNotification:flStrForObj(self.dataArray[buttonIndex][@"postedByUserName"]) andNewStatus:@"2"];
            selectedButton.backgroundColor = followButtonBackGroundColor;
            [selectedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
            selectedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
            NSDictionary *requestDict = @{muserNameToUnFollow     : flStrForObj(self.dataArray[buttonIndex][@"postedByUserName"]),
                                          mauthToken            :[Helper userToken],
                                          };
            [selectedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
            [WebServiceHandler unFollow:requestDict andDelegate:self];
        }
    }
    
    //actions for when the account is public.
    else {
        if ([selectedButton.titleLabel.text isEqualToString:@" FOLLOWING"]) {
            
            
              [self showUnFollowAlert:flStrForObj(self.dataArray[buttonIndex][@"profilePicUrl"]) and:flStrForObj(self.dataArray[buttonIndex][@"postedByUserName"]) and:selectedButton];
            
//            [selectedButton  setTitle:@" FOLLOW" forState:UIControlStateNormal];
//            [selectedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
//            selectedButton.backgroundColor = followButtonBackGroundColor;
//            selectedButton .layer.borderColor = [UIColor whiteColor].CGColor;
//            
//            //arrayOfFollowingStaus[selectedCellForLike.row] = @"0";
//            [self sendNewFollowStatusThroughNotification:flStrForObj(self.dataArray[indexPath.section][@"postedByUserName"]) andNewStatus:@"2"];
//            
//            //passing parameters.    muserNameToUnFollow
//            NSDictionary *requestDict = @{muserNameToUnFollow     :flStrForObj(self.dataArray[indexPath.section][@"postedByUserName"]),
//                                          mauthToken            :[Helper userToken],
//                                          };
//            //requesting the service and passing parametrs.
//            [WebServiceHandler unFollow:requestDict andDelegate:self];
        }
        else {
            
            [selectedButton  setTitle:@" FOLLOWING" forState:UIControlStateNormal];
            //arrayOfFollowingStaus[selectedButton.tag%1000] = @"1";
            [self sendNewFollowStatusThroughNotification:flStrForObj(self.dataArray[buttonIndex][@"postedByUserName"]) andNewStatus:@"1"];
            [selectedButton  setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
            [selectedButton setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];
            selectedButton.backgroundColor = followingButtonBackGroundColor;
            selectedButton.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :flStrForObj(self.dataArray[buttonIndex][@"postedByUserName"]),
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
    }
    
   // [self changeTitle:flStrForObj(self.dataArray[indexPath.section][@"postedByUserName"])];
}

/*-----------------------------------------------------*/
#pragma mark -
#pragma mark - CustomActionSheet
/*----------------------------------------------------*/
- (void)showUnFollowAlert:(NSString *)profileUrl and:(NSString *)profileName  and:(id)sender{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    CGFloat margin = 8.0F;
    UIView *customView;
    customView = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, alertController.view.bounds.size.width - margin * 4.0F, 80)];
    
    UIImageView *UserImageView =[[UIImageView alloc] init];
    [UserImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(profileUrl)] placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
    UserImageView.frame = CGRectMake(customView.frame.size.width/2-20,10,40,40);
    [self.view layoutIfNeeded];
    UserImageView.layer.cornerRadius = UserImageView.frame.size.height/2;
    UserImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    UserImageView.layer.borderWidth = 2.0;
    UserImageView.layer.masksToBounds = YES;
    customView.backgroundColor = [UIColor clearColor];
    
    //creating user name label
    UILabel *UserNamelabel = [[UILabel alloc] init];
    NSString *BoldText = [profileName stringByAppendingString:@"?"];
    NSString *text = [NSString stringWithFormat:@"Unfollow  %@",
                      BoldText];
    
    // If attributed text is supported (iOS6+)
    if ([UserNamelabel respondsToSelector:@selector(setAttributedText:)]) {
        
        // Define general attributes for the entire text
        NSDictionary *attribs = @{
                                  NSForegroundColorAttributeName:UserNamelabel.textColor,
                                  NSFontAttributeName: UserNamelabel.font
                                  };
        
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:text
                                               attributes:attribs];
        
        // black and bold text attributes
        UIColor *blackColor = [UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0];
        UIFont *boldFont = [UIFont fontWithName:RobotoThin size:14];
        NSRange BoldTextRange = [text rangeOfString:BoldText];
        [attributedText setAttributes:@{NSForegroundColorAttributeName:blackColor,
                                        NSFontAttributeName:boldFont}
                                range:BoldTextRange];
        UserNamelabel.attributedText = attributedText;
    }
    // If attributed text is NOT supported (iOS5-)
    else {
        UserNamelabel.text = text;
    }
    
    [UserNamelabel setFont:[UIFont systemFontOfSize:14]];
    UserNamelabel.frame=CGRectMake(-20,60, self.view.frame.size.width,15);
    UserNamelabel.textAlignment = NSTextAlignmentCenter;
    
    [customView addSubview:UserNamelabel];
    [customView addSubview:UserImageView];
    [alertController.view addSubview:customView];
    
    UIAlertAction *actionForUnfollow = [UIAlertAction actionWithTitle:@"Unfollow" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self unfollowAction:sender];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    [alertController addAction:actionForUnfollow];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}

-(void)unfollowAction:(id)sender {
    NSLog(@"unfollow clicked");
    UIButton *selectedButton = (UIButton *)sender;
    
    [selectedButton  setTitle:@" FOLLOW" forState:UIControlStateNormal];
    //[selectedButton  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //  arrayOfFollowingStaus[selectedButton.tag%1000] = @"2";
    
    [self sendNewFollowStatusThroughNotification:flStrForObj(self.dataArray[selectedButton.tag%11000][@"postedByUserName"]) andNewStatus:@"2"];
    
    
    [selectedButton  setTitleColor:[UIColor colorWithRed:0.2196 green:0.5882 blue:0.9412 alpha:1.0] forState:UIControlStateNormal];
    selectedButton.backgroundColor = [UIColor whiteColor];
    
    
    [selectedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
    selectedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;

    
    
    //passing parameters.
    NSDictionary *requestDict = @{muserNameToUnFollow:flStrForObj(self.dataArray[selectedButton.tag%11000][@"postedByUserName"]),
                                  mauthToken            :flStrForObj([Helper userToken]),
                                  };
    //requesting the service and passing parametrs.
    [WebServiceHandler unFollow:requestDict andDelegate:self];
}

-(void)updateFollowStatusForSectionHeader:(id)sender atSection:(NSInteger )section  followStatus:(NSString *)status {
    
    UIButton *reeceivedButton = (UIButton *)sender;
    
    reeceivedButton .layer.cornerRadius = 5;
    reeceivedButton .layer.borderWidth = 1;
    
    
    //  if follow status is 0 ---> title as "Requested"
    //  if follow status is 1 ---> title as "Following"
    //  if follow status is nil ---> title as "Follow"
    
    if ([status  isEqualToString:@"0"]) {
        [reeceivedButton  setTitle:@" REQUESTED" forState:UIControlStateNormal];
        [reeceivedButton setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
        reeceivedButton.backgroundColor = requstedButtonBackGroundColor;
        reeceivedButton .layer.borderColor = [UIColor clearColor].CGColor;
          [reeceivedButton  setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
    }
    else if(([status  isEqualToString:@"1"])) {
        [reeceivedButton  setTitle:@" FOLLOWING" forState:UIControlStateNormal];
        [reeceivedButton setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];
        reeceivedButton.backgroundColor =followingButtonBackGroundColor;
        reeceivedButton.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
          [reeceivedButton  setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
    }
    else {
        
        [reeceivedButton  setTitle:@" FOLLOW" forState:UIControlStateNormal];
        reeceivedButton.backgroundColor = followButtonBackGroundColor;
        [reeceivedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
        reeceivedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
        [reeceivedButton  setTitleColor:followButtonTextColor forState:UIControlStateNormal];
    }
}

-(void)sendNewFollowStatusThroughNotification:(NSString *)userName andNewStatus:(NSString *)newFollowStatus {
    NSDictionary *newFollowDict = @{@"newFollowStatus"     :flStrForObj(newFollowStatus),
                                    @"userName"            :flStrForObj(userName),
                                    };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedFollowStatus" object:[NSDictionary dictionaryWithObject:newFollowDict forKey:@"newUpdatedFollowData"]];
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
    
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkProfileOfUserNmae = flStrForObj(_dataArray[selectedIndex][@"postedByUserName"]);
    newView.checkingFriendsProfile = YES;
    [self.navigationController pushViewController:newView animated:YES];
}

- (void)buttonClicked:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    [self openProfileOfUsername:selectedButton.titleLabel.text];
}

-(void)openProfileOfUsername:(NSString *)selectedUserName {
    if ([selectedUserName isEqualToString:@""]) {
        
    }
    else{
        UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
        newView.checkingFriendsProfile = YES;
        newView.checkProfileOfUserNmae = selectedUserName;
        [self.navigationController pushViewController:newView animated:YES];
    }
}


/*---------------------------------------------------*/
#pragma
#pragma mark - DoubleTap For PostLike.
/*----------------------------------------------------*/

- (void)animateLike:(UITapGestureRecognizer *)sender {
    
    
    //sender.view is posted image view outlet.
    
    // [[view superview] subviews][0] -- is like image in tabeleview cell.(popup image)
    // performing animation on that like image.
    
    
    UIView *view = sender.view;
    UIImageView *animateImage = (UIImageView *)[[view superview] subviews][0];
    
    
    
    for (UIButton *eachButton in view.subviews) {
        [UIView transitionWithView:view
                          duration:0.1
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [eachButton removeFromSuperview];
                            [self.view layoutIfNeeded];
                        }
                        completion:NULL];
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
        
    }
    else{
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

-(void)getActivityPost
{
    NSDictionary *requestDict = @{
                    mauthToken:flStrForObj([Helper userToken]),
                    mpostid:self.postId,
                    mmemberName:self.activityUser
                    };
 [WebServiceHandler singlePost:requestDict andDelegate:self];
}


/*----------------------------------------------------------------------*/
#pragma mark
#pragma mark - WebServiceDelegate(Response)
/*----------------------------------------------------------------------*/

//handling response.

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSDictionary *responseDict = (NSDictionary*)response;
    if (requestType == RequestTypePost) {
        //success response(200 is for success code).
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
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
        
        if ([responseDict[@"message"] isEqualToString:@"User and his followers have not posted anything"]) {
            
            UIView *noDataAvailableMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            [noDataAvailableMessageView setCenter:self.view.center];
            UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -100, self.view.frame.size.height/2 -20, 200, 60)];
            message.textAlignment = NSTextAlignmentCenter;
            message.numberOfLines = 0;
            message.text = responseDict[@"message"];
            [noDataAvailableMessageView addSubview:message];
            self.tableView.backgroundColor = [UIColor whiteColor];
            
            self.tableView.backgroundView = noDataAvailableMessageView;
        }
        else {
            if(self.currentIndex == 0)
            {
                [_dataArray removeAllObjects];
                [[ZOWVideoCache sharedVideoCache] clearAllCache];
                NSLog(@"cache cleard");
            }
            self.currentIndex ++;
            [self stopAnimation];
            
            [_dataArray addObjectsFromArray:response[@"data"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
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
            case 9584: {
                NSDictionary *likeDictonaty = responseDict[@"likeResponse"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePostDetails" object:[NSDictionary dictionaryWithObject:likeDictonaty forKey:@"profilePicUrl"]];
            }
                break;
                
            default:
                break;
        }

    }
    
    else if (requestType == RequestTypeGetPostsDetailsForActivity) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
             
                if (_dataArray.count) {
                    [_dataArray removeAllObjects];
                }
                [_dataArray addObjectsFromArray:response[@"data"]];
                NSLog(@"_dataArray:%@",_dataArray);
                [self stopAnimation];
                [self.tableView reloadData];

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

#pragma mark - MoreActions


//-(void)copyShareURL:(NSInteger )selectedSection {
//    [errorMessageLabelOutlet setHidden:NO];
//    [self showingErrorAlertfromTop:@"Link copied to clipboard."];
//    NSLog(@"copyShareURL of index :%ld ",(long)selectedSection);
//    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//    NSString *copymainurl = _dataArray[selectedSection][@"mainUrl"];
//    pasteboard.string = copymainurl;
//}


-(void)copyShareURL:(NSInteger )selectedSection {
    [errorMessageLabelOutlet setHidden:NO];
    [self showingErrorAlertfromTop:@"Link copied to clipboard."];
    NSLog(@"copyShareURL of index :%ld ",(long)selectedSection);
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    NSString *postId = [NSString stringWithFormat:@"%@",self.dataArray[selectedSection][@"postId"]];
    NSString *copyWebUrl = [Helper makeWebPostLink:postId andUserName:self.dataArray[selectedSection][@"postedByUserName"]];
    pasteboard.string = copyWebUrl;
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
    // NSDictionary *dic = _dataArray[selectedSection];
    UIAlertView *alertForDeleteConfirmation =[[UIAlertView alloc] initWithTitle:@"Confirm To Delete" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [alertForDeleteConfirmation show];
    alertForDeleteConfirmation.tag = 6000+selectedSection;
    
    NSLog(@"Deleting post");
}

-(void)sharePost:(NSInteger)selectedSection{
    
    [[NSUserDefaults standardUserDefaults]setInteger:selectedSection forKey:@"index"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    SharingPostViewController *postshare = [self.storyboard instantiateViewControllerWithIdentifier:@"sharingPost"];
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
        
        NSString *caption = @"";//NSLocalizedString(@"Checkout this cool app",nil);
        
        // NSString *description;
        
        NSString *picturelink = [Helper getWebLinkForFeed:_dataArray[selectedSection]]; //responseData[selectedSection][@"mainUrl"];
        
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

#pragma mark - error alert
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 0)//cancel pressed
    {
    }
    else if(buttonIndex == 1)//confirm delete  pressed.
    {
        NSUInteger row = alertView.tag%6000;
        //deleting a post.
        NSDictionary *requestDict = @{
                                      mauthToken :[Helper userToken],
                                      mpostid:_dataArray[row][@"postId"]
                                      };
        [WebServiceHandler deletePost:requestDict andDelegate:self];
        NSLog(@"%@",requestDict);
        [self showingProgressindicator];
    }
}
-(void)showingProgressindicator {
    //showing progress indicator and requesting for posts.
    ProgressIndicator *HomePI = [ProgressIndicator sharedInstance];  [HomePI showPIOnView:self.view withMessage:@"Deleting..."];
}


#pragma mark-Error Alert
-(void)showingErrorAlertfromTop:(NSString *)message {
//    [errorMessageLabelOutlet setHidden:NO];
//    
//    [errorMessageLabelOutlet setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
//    [self.view layoutIfNeeded];
//    errorMessageLabelOutlet.text = message;
//    
//    /**
//     *  changing the error message view position if user enter  wrong number
//     */
//    
//    [UIView animateWithDuration:0.4 animations:
//     ^ {
//         
//         [self.view layoutIfNeeded];
//     }];
//    
//    int duration = 2; // duration in seconds
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [UIView animateWithDuration:0.4 animations:
//         ^ {
//             [errorMessageLabelOutlet setFrame:CGRectMake(0, -100, [UIScreen mainScreen].bounds.size.width, 100)];
//             [errorMessageLabelOutlet setHidden:YES];
//             [self.view layoutIfNeeded];
//         }];
//    });
    
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

//- (void)delegateFordoubLeTapCell:(InstaVideoTableViewCell *)cell {
//    //sender.view is posted image view outlet.
//    
//    // [[view superview] subviews][0] -- is like image in tabeleview cell.(popup image)
//    // performing animation on that like image.
//    
//    UIView *view = cell.videoView;
//    
//    UIImageView *animateImage;
//    if ( [[[view superview] subviews][0] isKindOfClass:[UIImageView class]] ) {
//        animateImage = (UIImageView *)[[view superview] subviews][0];
//    }
//    
//    NSIndexPath *indexPath = [self.tableViewOutlet indexPathForCell:(UITableViewCell *)[[animateImage superview] superview]];
//    
//    indexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
//    
//    LikeCommentTableViewCell *likeCommentCell = (LikeCommentTableViewCell *)[self tableView:self.tableViewOutlet cellForRowAtIndexPath:indexPath];
//    UIButton *respectiveLikeButton =(UIButton *)likeCommentCell.subviews[0].subviews[1];
//    [self likePostFromDoubleTap:respectiveLikeButton];
//    
//    
//    UIButton *selectedButton = likeCommentCell.likeButtonOutlet;
//   
//    
//    //animating the like button.
//    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//    [ani setDuration:0.2];
//    [ani setRepeatCount:1];
//    [ani setFromValue:[NSNumber numberWithFloat:1.0]];
//    [ani setToValue:[NSNumber numberWithFloat:0.5]];
//    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
//    [[selectedButton layer] addAnimation:ani forKey:@"zoom"];
//    
//    //checking if the post is already liked or not .if it is already liked no need to perform anything otherwise we need to perform like action.
//    
//    NSString *likeStatus =  [NSString stringWithFormat:@"%@", self.dataArray[indexPath.section][@"likeStatus"]];
//    if ([likeStatus  isEqualToString:@"0"]) {
//        
//        selectedButton.selected = YES;
//        [[self.dataArray objectAtIndex:selectedButton.tag] setObject:@"1" forKey:@"likeStatus"];
//        NSInteger newNumberOfLikes = [self.dataArray[selectedButton.tag][@"likes"] integerValue];
//        newNumberOfLikes ++;
//        [[self.dataArray objectAtIndex:selectedButton.tag] setObject:[@(newNumberOfLikes) stringValue] forKey:@"likes"];
//        [self reloadRowToShowNewNumberOfLikes:selectedButton.tag];
//        [self likeAPost:flStrForObj(self.dataArray[selectedButton.tag][@"postId"]) postType:flStrForObj(self.dataArray[selectedButton.tag][@"postsType"])];
//    }
//    
//    
//    for (UIButton *eachButton in view.subviews) {
//        [UIView transitionWithView:view
//                          duration:0.1
//                           options:UIViewAnimationOptionTransitionCrossDissolve
//                        animations:^{
//                            [eachButton removeFromSuperview];
//                            [self.view layoutIfNeeded];
//                        }
//                        completion:NULL];
//    }
//    
//    
//    animateImage.hidden = NO;
//    animateImage.alpha = 0;
//    
//    [[view superview] bringSubviewToFront:animateImage];
//    
//    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
//        animateImage.transform = CGAffineTransformMakeScale(1.3, 1.3);
//        animateImage.alpha = 1.0;
//    }
//                     completion:^(BOOL finished) {
//                         
//                         
//                         
//                         [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction
//                                          animations:^{
//                                              animateImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
//                                          }
//                                          completion:^(BOOL finished) {
//                                              [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
//                                                  animateImage.transform = CGAffineTransformMakeScale(1.3, 1.3);
//                                                  animateImage.alpha = 0.0;
//                                              }
//                                                               completion:^(BOOL finished) {
//                                                                   animateImage.transform = CGAffineTransformMakeScale(1.0, 1.0);
//                                                                   
//                                                                   [[view superview] sendSubviewToBack:animateImage];
//                                                               }];
//                                          }];
//                     }];
//}


/*---------------------------------------*/
#pragma
#pragma mark - Button Actions
/*---------------------------------------*/


/*---------------------------------------*/
#pragma
#pragma mark - Button Actions
/*---------------------------------------*/

- (IBAction)showTagsButtonAction:(id)sender {
    
    NSIndexPath *selectedButtontToShowTags = [self.tableViewOutlet indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    // Get the subviews of the view
    NSArray *subviewsfff =  [[sender superview] subviews];
    
    UIView *view = (UIView *) subviewsfff[3];
    
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

- (void)delegateForSingleTapCell:(InstaVideoTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableViewOutlet indexPathForCell:cell];
    
    InstaVideoTableViewCell *selectedCell = [self.tableViewOutlet cellForRowAtIndexPath:indexPath];
    [self showTagsButtonAction:selectedCell.showTagsButtonOutlet];
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


-(void)initFooterView
{
    
    UIView *footerView = [[UIView alloc] init];
    [footerView setBackgroundColor:[UIColor whiteColor]];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(self.view.frame.size.width/2-20,0, 40, 40.0);
    [footerView addSubview:activityIndicator];
    [activityIndicator startAnimating];

    [self.tableViewOutlet setTableFooterView:footerView];

}

- (IBAction)firstCommentUserNameButtonActin:(id)sender {
    UIButton *userNameButton = (UIButton *)sender;
    NSString *selectedUserName = flStrForObj([userNameButton titleForState:UIControlStateNormal]);
    [self openProfileOfUsername:selectedUserName];
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

- (IBAction)sendButtonAction:(id)sender {
    
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

- (IBAction)captionUserNameButtonAction:(id)sender {
    UIButton *userNameButton = (UIButton *)sender;
    NSString *selectedUserName = flStrForObj([userNameButton titleForState:UIControlStateNormal]);
    [self openProfileOfUsername:selectedUserName];
}

- (IBAction)secondCommentButtonAction:(id)sender {
    UIButton *userNameButton = (UIButton *)sender;
    NSString *selectedUserName = flStrForObj([userNameButton titleForState:UIControlStateNormal]);
    [self openProfileOfUsername:selectedUserName];
}
@end

