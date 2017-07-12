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

#import "Cloudinary.h"
#import "WDUploadProgressView.h"
#import "PGDiscoverPeopleViewController.h"


@interface HomeViewController ()<WebServiceHandlerDelegate,InstagramVideoViewTapDelegate,UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic) NSMutableArray *dataArray;
@property int currentIndex;

@end

@implementation HomeViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray new];
    [self requestForPostsBasedOnRequirement];
    
    self.navigationController.navigationBar.tintColor = [UIColor  blackColor];
    self.navigationController.navigationBar.topItem.title = @"";
    self.navigationItem.title = @"Picogram";
    
    [self creatingNotificationForUpdatingLikeDetails];
}

-(void)creatingNotificationForUpdatingLikeDetails {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDetails:) name:@"updatePostDetails" object:nil];
}

-(void)updateDetails:(NSNotification *)noti {
    
    //check the postId and Its Index In array.
    
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
            
            //            NSString *updatedNumberOfLikes = flStrForObj(noti.object[@"profilePicUrl"][@"data"][0][@"likes"]);
            //            [[self.dataArray objectAtIndex:i] setObject:updatedNumberOfLikes forKey:@"likes"];
            //            _dataArray[i][@"likes"] = noti.object[@"profilePicUrl"][@"data"][0][@"likes"];
            
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:1 inSection:i];
            NSIndexPath* secondRowToreload  = [NSIndexPath indexPathForRow:2 inSection:i];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload,secondRowToreload, nil];
            [self.tableViewOutlet reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
            
            break;
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
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row ==0) {
        
        InstaVideoTableViewCell *cell = (InstaVideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"InstaVideoTableViewCell" forIndexPath:indexPath];
        
        NSString *urlString = _dataArray[indexPath.section][@"mainUrl"];
        cell.url = urlString;
        
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        
        dispatch_async(queue, ^{
            
            if ([flStrForObj(_dataArray[indexPath.section][@"postsType"]) isEqualToString:@"0"]) {
                [cell.videoView setHidden:YES];
                [cell.imageViewOutlet setHidden:NO];
                [cell setUrl:urlString];
                [cell setPlaceHolderUrl:_dataArray[indexPath.row][@"thumbnailImageUrl"]];
                [cell loadImageForCell];
            }
            else {
                InstagramVideoView *obj = [cell videoView];
                obj.delegate = self;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [cell loadVideoForCellFromLinkwithUrl:urlString];
                    if(indexPath.row != 0)
                    {
                        [cell.videoView pause];
                    }
                });
                [cell.videoView mute];
                [cell.videoView setHidden:NO];
                [cell.imageViewOutlet setHidden:YES];
            }
        });
        return cell;
    }
    else if (indexPath.row ==1){
        
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row ==0)
        //        return _tableViewOutlet.frame.size.height/2+20;
        return self.view.frame.size.width;
    else if (indexPath.row ==1)
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
        
        NSMutableAttributedString * attributtedComment = [[NSMutableAttributedString alloc] initWithString:commentWithUserName];
        [attributtedComment addAttribute:NSForegroundColorAttributeName
                                   value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                                   range:NSMakeRange(0,postedUser.length)];
        [attributtedComment addAttribute:NSFontAttributeName
                                   value:[UIFont fontWithName:RobotoMedium size:15]
                                   range:NSMakeRange(0, postedUser.length)];
        
        
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
        
        NSArray *response =  [flStrForObj(_dataArray[indexPath.section][@"comments"]) componentsSeparatedByString:@"^^"];
        NSMutableArray *arrayOffCommentedUserNames = [[NSMutableArray alloc]init];
        NSMutableArray * arrayOfComments = [[NSMutableArray alloc]init];
        for(int i=0;i <response.count-1;i++) {
            NSString* temp = [response objectAtIndex:i+1];
            NSString * userName = [temp componentsSeparatedByString:@"$$"][0];
            NSString * commen = [temp componentsSeparatedByString:@"$$"][1];
            [arrayOffCommentedUserNames addObject:userName];
            [arrayOfComments addObject:commen];
        }
        
        if (arrayOfComments.count == 1) {
            NSString *commentedUser1 = flStrForObj(arrayOffCommentedUserNames[0]);
            NSString *commentedText1 = flStrForObj(arrayOfComments[0]);
            
            NSString *postcommentWithUserName1 = [commentedUser1 stringByAppendingFormat:@"  %@",commentedText1];
            
            postcommentWithUserName1 = [postcommentWithUserName1 stringByTrimmingCharactersInSet:ws];
            
            firstCommentlbl.text = postcommentWithUserName1;
        }
        else if (arrayOfComments.count >1) {
            
            NSString *commentedUser1 = flStrForObj(arrayOffCommentedUserNames[arrayOffCommentedUserNames.count-1]);
            NSString *commentedText1 = flStrForObj(arrayOfComments[arrayOfComments.count-1]);
            
            NSString *commentedUser2 = flStrForObj(arrayOffCommentedUserNames[arrayOffCommentedUserNames.count -2]);
            NSString *commentedText2 = flStrForObj(arrayOfComments[arrayOfComments.count-2]);
            
            
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
            heightOfCaption = [Helper measureHieightLabel:captionlbl];
        }
        
        if ([firstCommentlbl.text isEqualToString:@""]) {
            heightOfFirstComment = 0;
        }
        else {
            heightOfFirstComment = [Helper measureHieightLabel:firstCommentlbl];
        }
        
        if ([secondCommentlbl.text isEqualToString:@""]) {
            heightOfSecondComment = 0;
        }
        else {
            heightOfSecondComment = [Helper measureHieightLabel:secondCommentlbl];
        }
        
        if (heightOfFirstComment > 0 && heightOfSecondComment > 0) {
            heightOfViewAllCommentsButton = 20;
        }
        else {
            heightOfViewAllCommentsButton = 0;
        }
        
        if (numberOfLikes > 0) {
            heightOfLikesNumberView = 20;
        }
        else {
            heightOfLikesNumberView = 0;
        }
        
        // 20 --- > for posted time label height.
        CGFloat totalHeightOfRow =  heightOfCaption + heightOfFirstComment +heightOfSecondComment  + heightOfViewAllCommentsButton + heightOfLikesNumberView + 20;
        
        if (totalHeightOfRow == 20 ) {
            totalHeightOfRow = 25;
        }
        
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
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:2 inSection:reloadRowAtSection];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableViewOutlet reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
}

/*---------------------------------------*/
#pragma
#pragma mark - Button Actions
/*---------------------------------------*/

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
    newView.commentingOnPostFrom = @"ToHomeScreen";
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
        
        sheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Report",@"Share to Facebook", @"Copy Share URL", @"Turn on Post Notifications", nil];
        [sheet setTag:moreButton.tag];
        
    }
    else
    {
        sheet = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Delete",@"Edit", @"Share", nil];
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
    newView.commentingOnPostFrom = @"ToHomeScreen";
    [self.navigationController pushViewController:newView animated:YES];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSInteger tag = popup.tag;
    if(!(tag < 2000)){
        
        switch (buttonIndex) {
            case 0:
                // [self reportPost:tag%2000];
                break;
            case 1:
                //  [self shareToFacebook:tag%2000];
                break;
            case 2:
                // [self copyShareURL:tag%2000];
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
            // [self deletePost:tag%1000];
        }
        else if (buttonIndex == 1){
            // [self copyShareURL:tag%1000];
        }
        else if (buttonIndex == 2) {
            // [self sharePost:tag%1000];
        }
    }
}

/*----------------------------------------------------------------------------*/
#pragma
#pragma mark - tableview Header Buttons And Actions.
/*----------------------------------------------------------------------------*/

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    view.backgroundColor =[UIColor whiteColor];
    
    // Create custom view to display section header... /
    
    //creating user name label
    UILabel *UserNamelabel = [[UILabel alloc] init];
    UserNamelabel.text = flStrForObj(_dataArray[section][@"postedByUserName"]);
    [UserNamelabel setFont:[UIFont fontWithName:RobotoMedium size:15]];
    UserNamelabel.textColor =[UIColor colorWithRed:0.1568 green:0.1568 blue:0.1568 alpha:1.0];
    
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *placeName = flStrForObj(_dataArray[section][@"place"]);
    
    if ([placeName isEqualToString:@"[object Object]"]) {
        placeName = @"";
    }
    
    locationButton.titleLabel.font = [UIFont fontWithName:RobotoRegular size:15];
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
    headerButton.backgroundColor =[UIColor whiteColor];
    headerButton.tag = 10000 + section ;
    
    
    //creating user image on tableView Header
    UIImageView *UserImageView =[[UIImageView alloc] init];
    [UserImageView sd_setImageWithURL:[NSURL URLWithString:flStrForObj(_dataArray[section][@"profilePicUrl"])] placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
    
    
    //setting position of headerButton,UserImageView,timeLabel in customized  tableView Section Header.
    //if there is no place then usernamelabel will come in middle
    if ([placeName isEqualToString:@""]) {
        UserNamelabel.frame=CGRectMake(60, 20, self.view.frame.size.width - 100, 15);
        locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 120, 0);
        
    }
    else {
        UserNamelabel.frame=CGRectMake(60, 10, self.view.frame.size.width - 100, 15);
        locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 120, 15);
    }
    
    UserImageView.frame = CGRectMake(10,8,40,40);
    
    UserImageView.layer.cornerRadius = UserImageView.frame.size.height/2;
    UserImageView.clipsToBounds = YES;
    headerButton.frame = CGRectMake(0, 1, tableView.frame.size.width,56);
    
    
    // adding  headerButton,UserImageView,timeLabel,UserNamelabel to the customized tableView  Section Header.
    
    [view addSubview:headerButton];
    [view addSubview:UserImageView];
    [view addSubview:UserNamelabel];
    [view addSubview:locationButton];
    return view;
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
        UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
        
        //removing @ from string.
        NSString *stringWithoutspecialCharacter = [string
                                                   stringByReplacingOccurrencesOfString:@"@" withString:@""];
        newView.checkProfileOfUserNmae = stringWithoutspecialCharacter;
        newView.checkingFriendsProfile = YES;
        [self.navigationController pushViewController:newView animated:YES];
    };
}

-(void)openPostsByHashtag:(NSString *)string {
    HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
    newView.navTittle = string;
    [self.navigationController pushViewController:newView animated:YES];
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
        
        if ([responseDict[@"message"] isEqualToString:messageWhenNoPosts]) {
            
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
                NSLog(@"cache cleard");
            }
            self.currentIndex ++;
            [self stopAnimation];
            
            [_dataArray addObjectsFromArray:response[@"data"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableViewOutlet reloadData];
            });
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
    
    UIView *noDataAvailableMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [noDataAvailableMessageView setCenter:self.view.center];
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 -100, self.view.frame.size.height/2 -20, 200, 60)];
    message.textAlignment = NSTextAlignmentCenter;
    message.numberOfLines = 0;
    message.text = errorMessage;
    [noDataAvailableMessageView addSubview:message];
    self.tableViewOutlet.backgroundColor = [UIColor whiteColor];
    
    self.tableViewOutlet.backgroundView = noDataAvailableMessageView;
    
    return noDataAvailableMessageView;
}

- (IBAction)followPeopleButtonAction:(id)sender {
    PGDiscoverPeopleViewController *postsVc = [self.storyboard instantiateViewControllerWithIdentifier:mDiscoverPeopleVcSI];
    [self.navigationController pushViewController:postsVc animated:YES];
}
@end
