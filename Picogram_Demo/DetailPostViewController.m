//
//  DetailPostViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 6/7/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "DetailPostViewController.h"
#import "HomeViewTableViewCell.h"
#import "WebServiceConstants.h"
#import "UIImageView+WebCache.h"
#import "KILabel.h"
#import "HashTagViewController.h"
#import "UIImageView+AFNetworking.h"
#import  "UserProfileViewController.h"
#import "UIImage+GIF.h"
#import <SCRecorder/SCPlayer.h>
#import <SCRecorder/SCVideoPlayerView.h>
#import <SCRecorder/SCRecordSession.h>
#import "PhotosPostedByLocationViewController.h"
#import "LikeViewController.h"
#import "HomeViewCommentsViewController.h"
#import "WebServiceHandler.h"
#import "ShareViewXib.h"
#import "FontDetailsClass.h"
#import "TinderGenericUtility.h"

@interface DetailPostViewController () <UITableViewDelegate,UITableViewDataSource,SCPlayerDelegate,SDWebImageManagerDelegate,WebServiceHandlerDelegate,shareViewDelegate,UIActionSheetDelegate,UIGestureRecognizerDelegate> {
      HomeViewTableViewCell *cell;
      CGFloat heightOfTheRow;
      NSString *comment;
      ShareViewXib *shareNib;
}

@end

@implementation DetailPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavLeftButton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedCommentsdata:) name:@"passingUpdatedCommentsToDetailPostView" object:nil];
}

-(void)updatedCommentsdata:(NSNotification *)noti {
    NSInteger updateCellNumber  =[noti.object[@"newCommentsData"][@"selectedCell"] integerValue];
    NSString *updatedComment =noti.object[@"newCommentsData"][@"data"][0][@"Posts"][@"properties"][@"commenTs"];
    self.commentsOndPost = updatedComment;
    [_detailPostTableView reloadSections:[NSIndexSet indexSetWithIndex:updateCellNumber] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark - navigation bar back button

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

/*-------------------------------------------------------------------------*/
#pragma
#pragma mark - tableview delegates and data source.
/*------------------------------------------------------------------------*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

//Custom Header (it contains profile image of the posted person and his/her username and time label and location if available.)

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // creating custom header view
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    view.backgroundColor =[UIColor whiteColor];
    
    /* Create custom view to display section header... */
    
    //creating user name label
    
    UILabel *UserNamelabel = [[UILabel alloc] init];
    UserNamelabel.text =self.postedUser;
    [UserNamelabel setFont:[UIFont fontWithName:RobotoMedium size:14]];
    UserNamelabel.textColor = [UIColor colorWithRed:0.1568 green:0.1568 blue:0.1568 alpha:1.0];
    
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *placeName = self.location;
   
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
    [timeLabel setFont:[UIFont boldSystemFontOfSize:14]];
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
    [UserImageView sd_setImageWithURL:[NSURL URLWithString:self.profileImageUrl]
                     placeholderImage:[UIImage imageNamed:@"defaultpp"]];
    
    //    UserImageView.image = [UIImage imageNamed:@"defaultpp"];
    
    //updating profilepicture of the post user.
    
    
    //setting position of headerButton,UserImageView,timeLabel in customized  tableView Section Header.
    //if there is no place then usernamelabel will come in middle
    if ([placeName isEqualToString:@""]) {
        UserNamelabel.frame=CGRectMake(60, 20, self.view.frame.size.width - 100, 15);
    }
    else {
        UserNamelabel.frame=CGRectMake(60, 10, self.view.frame.size.width - 100, 15);
    }
    
    locationButton.frame = CGRectMake(60, 30,self.view.frame.size.width - 100, 15);
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
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"
                                           forIndexPath:indexPath];
    
    //giving height for imageview but its is not fixed it must be vary on every image height.
    cell.imageViewHeightConstraint.constant = 320;
    
    //downloading image and updating in imageview by using sd_webimage(it is very fast).
    //if image is not downloaded then default loading image will shown(it is gif formated).
    
    UIView *view = (UIView *)[cell viewWithTag:12345];
    [view removeFromSuperview];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [cell.postedImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:self.selectedImageUrl]
                                          placeholderImage:[UIImage imageNamed:@""]];
        });
    
    [cell.listOfPeopleLikedThePostButton addTarget:self action:@selector(likeButton:) forControlEvents:UIControlEventTouchUpInside];
    [cell.shareButtonOutlet addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.personsLikedinfoLabelOutlet.text = self.numberOfLikes;
    cell.timeLabelOutlet.text = self.postedTime;
    [self showCommentsOnPost:indexPath.section];
    //customizing CaptionLabel.
    //user name with status and changing the color and font  for username and status.
    NSString *postedUser = self.postedUser;
    comment = self.caption;
    NSString *commentWithUserName = [postedUser stringByAppendingFormat:@"  %@",comment];
    NSMutableAttributedString * attributtedComment = [[NSMutableAttributedString alloc] initWithString:commentWithUserName];
    [attributtedComment addAttribute:NSForegroundColorAttributeName
                               value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                               range:NSMakeRange(0,postedUser.length)];
    [attributtedComment addAttribute:NSFontAttributeName
                               value:[UIFont fontWithName:@"Lato-Heavy" size:14]
                               range:NSMakeRange(0, postedUser.length)];
    [cell.userNameWithCaptionOutlet setAttributedText:attributtedComment];
    [self creatingTapGesturePostedImage:cell.postedImageViewOutlet];
    
    //setting Tags For  Different Items
    //alloting tag for every button and imageView.
    cell.moreButtonOutlet.tag = 1000 + indexPath.section;
    cell.viewAllCommentsButtonOutlet.tag = 3000 + indexPath.section;
    cell.commentButtonOutlet.tag = 4000 + indexPath.section;
    cell.postedImageViewOutlet.tag = 5000 + indexPath.section;
    cell.listOfPeopleLikedThePostButton.tag = 6000 +indexPath.section;
    cell.shareButtonOutlet.tag = 7000+indexPath.section;
    
    //in posts details it contains 4 fixed buttons(for every post). they are like,shrae,comment and more.
    [cell.moreButtonOutlet addTarget:self
                              action:@selector(moreButtnAction:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    [cell.viewAllCommentsButtonOutlet addTarget:self action:@selector(viewAllCommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentButtonOutlet addTarget:self action:@selector(CommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //setting heightContsraintFor Label and cell(according to labels height).
    [self HeightConstraintForLabels];
    
    //handling hashTags and UserNames.
    cell.userNameWithCaptionOutlet.userInteractionEnabled =YES;
    [self updateLikeButtonStatus:indexPath.section];
    [self handlingHashTags];
    [self handlingURLLink];
    [self handlinguserName];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return heightOfTheRow;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected section  %ld",(long)indexPath.section);
}

-(void)showCommentsOnPost:(NSInteger )section {
    NSArray *response =  [flStrForObj(_commentsOndPost) componentsSeparatedByString:@"^^"];
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
        cell.commentLabelOne.text = @"";
        cell.commentLabelTwo.text = @"";
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
        [cell.commentLabelOne setAttributedText:attributtedPostComment1];
        cell.commentLabelTwo.text = @"";
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
        [cell.commentLabelOne setAttributedText:attributtedPostComment1];
        [cell.commentLabelTwo setAttributedText:attributtedPostComment2];
    }
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
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkProfileOfUserNmae = self.postedUser;
    newView.checkingFriendsProfile = YES;
    [self.navigationController pushViewController:newView animated:YES];
}

//***
/*-------------------------------------------------------------------------------*/
#pragma
#pragma mark -   HeightConstraints.
/*-------------------------------------------------------------------------------*/

-(void)HeightConstraintForLabels {
    //setting height constraints.
    
    CGFloat dynamicHeightOfuserNameWithCaptionLabel;
    
    if([comment isEqualToString:@"null"]) {
        cell.userNameWithCaptionHeightConstraint.constant = 0;
    }
    else {
        // for caption label.
        dynamicHeightOfuserNameWithCaptionLabel =  [self heightOfText:cell.userNameWithCaptionOutlet];
        cell.userNameWithCaptionHeightConstraint.constant = dynamicHeightOfuserNameWithCaptionLabel;
    }
    if ([cell.personsLikedinfoLabelOutlet.text  isEqualToString:@"0"]) {
        
    }
    
    //for first comment label.
    CGFloat dynamicHeightOffirstCommentLabel =  [self heightOfText:cell.commentLabelOne];
    cell.firstCommentHeightConstraint.constant = dynamicHeightOffirstCommentLabel;
    
    //for secondComments Label.
    CGFloat dynamicHeightOfSecondCommentLabel = [self heightOfText:cell.commentLabelTwo];
    cell.secondCommentHeightConstraint.constant = dynamicHeightOfSecondCommentLabel;
    
    // for likes view
    if([cell.personsLikedinfoLabelOutlet.text isEqualToString:@"0"]) {
        cell.listOfPeopleLikedThePostButton.enabled = NO;
    }
    else {
        cell.listOfPeopleLikedThePostButton.enabled = YES;
    }
    
    //captionAndCommentview is along with comments(first and second) and like view (number of likes) and caption.
    cell.captionAndCommentHeightConstraint.constant = dynamicHeightOfuserNameWithCaptionLabel + dynamicHeightOffirstCommentLabel +dynamicHeightOfSecondCommentLabel + cell.timeLabelHeightConstraint.constant + cell.viewAllCommentsButtonOutlet.frame.size.height;
    
    //totallikeButtonsViewWithCommentsandCaptionView it is
    cell.totallikeButtonsViewWithCommentsandCaptionViewHeightConstraint.constant = cell.captionAndCommentHeightConstraint.constant + cell.LikeViewHeightConstraint.constant;
    
    //total height of the section including with image,header and comments section(40 is tableview header height and it is fixed).
    heightOfTheRow = cell.totallikeButtonsViewWithCommentsandCaptionViewHeightConstraint.constant + cell.LikeViewHeightConstraint.constant + cell.imageViewHeightConstraint.constant + 40 ;
}

/*------------------------------------------------*/
#pragma
#pragma mark - Like
/*-----------------------------------------------*/

-(void)updateLikeButtonStatus :(NSInteger )section {
    if ([_likeStaus isEqualToString:@"0"]) {
        cell.likeButtonOutlet  .selected = NO;
    }
    else  {
        cell.likeButtonOutlet .selected = YES;
    }
    cell.likeButtonOutlet.tag = 12365 + section;
    [cell.likeButtonOutlet addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)likeButtonAction:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [ani setDuration:0.2];
    [ani setRepeatCount:1];
    [ani setFromValue:[NSNumber numberWithFloat:1.0]];
    [ani setToValue:[NSNumber numberWithFloat:0.5]];
    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[selectedButton layer] addAnimation:ani forKey:@"zoom"];
    
    if (selectedButton.selected) {
         selectedButton.selected = NO;
         self.likeStaus =@"0";
         [self unlikeAPost];
        
        NSInteger newNumberOfLikes = [_numberOfLikes integerValue];
        newNumberOfLikes --;
        _numberOfLikes = [NSString stringWithFormat:@"%ld",(long)newNumberOfLikes];
       
        //getting the  number of likes label.
        NSArray *subviews =   [[[[sender superview] superview] superview] subviews];
        NSArray *subviw2 = [subviews[0] subviews];
        NSArray *subview3 =  [subviw2[4] subviews];
        NSArray *subview4 =  [subview3[0] subviews];
        UILabel *totalLikeslabel =  (UILabel *)subview4[0];
        totalLikeslabel.text = _numberOfLikes;
    }
    else {
        selectedButton.selected = YES;
        self.likeStaus =@"1";
        [self likeAPost];
        NSInteger newNumberOfLikes = [_numberOfLikes integerValue];
        newNumberOfLikes ++;
        _numberOfLikes = [NSString stringWithFormat:@"%ld",(long)newNumberOfLikes];
        
        //getting the  number of likes label.
        NSArray *subviews =   [[[[sender superview] superview] superview] subviews];
        NSArray *subviw2 = [subviews[0] subviews];
        NSArray *subview3 =  [subviw2[4] subviews];
        NSArray *subview4 =  [subview3[0] subviews];
        UILabel *totalLikeslabel =  (UILabel *)subview4[0];
        totalLikeslabel.text = _numberOfLikes;
    }
}


-(void)likeAPost
{
    NSDictionary *requestDict;
    
    // 1 is for video and 0 is for photo.
    
    if ([_postType isEqualToString:@"1"]) {
        requestDict = @{
                        mauthToken:flStrForObj(_userToken),
                        mpostid:_postId,
                        mLabel:@"Video"
                        };
    }
    else {
        requestDict = @{
                        mauthToken:flStrForObj(_userToken),
                        mpostid:_postId,
                        mLabel:@"Photo"
                        };
    }
    
    [WebServiceHandler likeAPost:requestDict andDelegate:self];
}

-(void)unlikeAPost
{
    NSDictionary *requestDict;
        if ([_postType isEqualToString:@"1"]) {
        requestDict = @{
                        mauthToken:flStrForObj(_userToken),
                        mpostid:_postId,
                        mLabel:@"Video",
                        mUserName:_userName
                        };
    }
    else {
        requestDict = @{
                        mauthToken:flStrForObj(_userToken),
                        mpostid:_postId,
                        mLabel:@"Photo",
                        mUserName:_userName
                        };
    }
    [WebServiceHandler unlikeAPost:requestDict andDelegate:self];
}



//list of all persons who liked the post button.
-(void)likeButton:(id)sender {
    LikeViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"likeStoryBoardId"];
    newView.navigationTitle = @"Likers";
    newView.postId = self.postId;
    newView.postType =self.postType;
    [self.navigationController pushViewController:newView animated:YES];
}

/*-----------------------------------------------------*/
#pragma
#pragma mark - MORE BUTTON
/*----------------------------------------------------*/

- (void)moreButtnAction:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Report" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Share to Facebook", @"Copy Share URL", @"Turn on Post Notifications", nil];
    [sheet showInView:self.view];
}


/*-------------------------------------------*/
#pragma
#pragma mark - COMMENT
/*------------------------------------------*/

-(void)viewAllCommentButtonAction:(id)sender {
    HomeViewCommentsViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsStoryBoardId"];
    newView.postId =self.postId;
    newView.postCaption = self.caption;
    newView.postType = self.postType;
    newView.imageUrlOfPostedUser = self.profileImageUrl;
    newView.selectedCellIs = 0;
    newView.userNameOfPostedUser = self.postedUser;
    
    newView.imageUrlOfPostedUser = _profileImageUrl;
    newView.userNameOfPostedUser =_userName;
    [self.navigationController pushViewController:newView animated:YES];
}

-(void)CommentButtonAction:(id)sender {
    HomeViewCommentsViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsStoryBoardId"];
    newView.postId = self.postId;
    newView.postCaption = self.caption;
    newView.postType = self.postType;
    newView.imageUrlOfPostedUser = self.profileImageUrl;
    newView.selectedCellIs = 0;
    newView.userNameOfPostedUser = self.postedUser;
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

-(void)handlingHashTags {
    // Attach a block to be called when the user taps a hashtag.
    
    cell.userNameWithCaptionOutlet.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
        newView.navTittle = string;
        [self.navigationController pushViewController:newView animated:YES];
    };
}

-(void)handlinguserName {
    // Attach a block to be called when the user taps a user handle.
    
    cell.userNameWithCaptionOutlet.userHandleLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
        
        //removing @ from string.
        NSString *stringWithoutspecialCharacter = [string
                                                   stringByReplacingOccurrencesOfString:@"@" withString:@""];
        newView.checkProfileOfUserNmae = stringWithoutspecialCharacter;
        newView.checkingFriendsProfile = YES;
        [self.navigationController pushViewController:newView animated:YES];
    };
}

-(void)handlingURLLink {
    // Attach a block to be called when the user taps a URL
    cell.userNameWithCaptionOutlet.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        NSLog(@"URL tapped %@", string);
    };
}

/*---------------------------------------------------*/
#pragma
#pragma mark - DoubleTap For PostLike.
/*----------------------------------------------------*/

- (void)oneFingerTwoTaps{
    
   
    cell.likeImage.hidden = NO;
    cell.likeImage.alpha = 1;
    int duration = 2;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        cell.likeImage.hidden = YES;
        cell.likeImage.alpha = 0;
    });
}

/*-------------------------------------------------------*/
#pragma mark
#pragma mark - labelHeightDynamically.
/*------------------------------------------------------*/

-(CGFloat )heightOfText:(UILabel *)label {
    
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
    CGFloat dynamicHeightOfLabel = newFrame.size.height + 5;
    return dynamicHeightOfLabel;
}

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
     if (requestType == RequestTypeLikeAPost) {
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

/*-------------------------------------------------------------------*/
#pragma mark - showing taggedPeople On Image
/*-------------------------------------------------------------------*/


-(void)creatingTapGesturePostedImage:(id)sender {
    
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
    cell.likeImage.hidden = YES;
    cell.likeImage.alpha = 0;
    for (UIButton *eachButton in cell.postedImageViewOutlet.subviews) {
        [UIView transitionWithView:cell.postedImageViewOutlet
                          duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [eachButton removeFromSuperview];
                            [self.view layoutIfNeeded];
                        }
                        completion:NULL];
    }
}

/*---------------------------------------------------*/
#pragma
#pragma mark - DoubleTap For PostLike.
/*----------------------------------------------------*/

- (void) animateLike:(UITapGestureRecognizer *)sender{
    for (UIButton *eachButton in cell.postedImageViewOutlet.subviews) {
        [UIView transitionWithView:cell.postedImageViewOutlet
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

-(void)likePostFromDoubleTap:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    NSIndexPath *selectedCellForLike = [_detailPostTableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    
    //animating the like button.
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    [ani setDuration:0.2];
    [ani setRepeatCount:1];
    [ani setFromValue:[NSNumber numberWithFloat:1.0]];
    [ani setToValue:[NSNumber numberWithFloat:0.5]];
    [ani setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[selectedButton layer] addAnimation:ani forKey:@"zoom"];
    
    // checking if the post is already liked or not .if it is already liked no need to perform anything otherwise we need to perform like action.
    
    NSString *likeStatus = self.likeStaus;
    if ([likeStatus  isEqualToString:@"0"]) {
        selectedButton.selected = YES;
        [self likeAPost:selectedCellForLike.section];
         self.likeStaus =@"1";
        NSInteger newNumberOfLikes = [_numberOfLikes integerValue];
        newNumberOfLikes ++;
        _numberOfLikes = [NSString stringWithFormat:@"%ld",(long)newNumberOfLikes];
        
        NSArray *subviews =   [[[[sender superview] superview] superview] subviews];
        NSArray *subviw2 = [subviews[0] subviews];
        NSArray *subview3 =  [subviw2[4] subviews];
        NSArray *subview4 =  [subview3[0] subviews];
        
        //subview4[0] is the label for displaying number of likes.
        UILabel *totalLikeslabel =  (UILabel *)subview4[0];
        totalLikeslabel.text =  [NSString stringWithFormat:@"%ld", (long)newNumberOfLikes];
        
    }
}

-(void)likeAPost:(NSInteger)selectedIndex
{
    NSDictionary *requestDict;
    NSString *postId = self.postId;
    
    // 1 is for video and 0 is for photo.
    
    if ([_postType isEqualToString:@"1"]) {
        requestDict = @{
                        mauthToken:flStrForObj(_userToken),
                        mpostid:postId,
                        mLabel:@"Video"
                        };
    }
    else {
        requestDict = @{
                        mauthToken:flStrForObj(_userToken),
                        mpostid:postId,
                        mLabel:@"Photo"
                        };
    }
    [WebServiceHandler likeAPost:requestDict andDelegate:self];
}

-(void)tapGesture:(UITapGestureRecognizer *)sender {
    UIView *view = sender.view;
    NSArray *namesOfTaggedPeople = [_taggedPeople componentsSeparatedByString:@","];
    
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

@end
