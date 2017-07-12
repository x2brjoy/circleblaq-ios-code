//
//  ListOfPostsViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 8/5/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.

#import "ListViewVC.pch"


@interface ListOfPostsViewController ()<UITableViewDataSource,UITableViewDelegate,WebServiceHandlerDelegate,shareViewDelegate> {
    HomeViewTableViewCell *Listcell;
    NSString *comment;
    CGFloat heightOfTheRow;
    NSString *userToken;
    NSString *userName;
    NSDictionary *userDatawhileRegistration;
    NSDictionary *userData;
    ShareViewXib *shareNib;
    NSMutableArray *arrayForFbListData;
    NSMutableArray *arrayForDiscoverPeopleData;
    NSMutableArray *arrayForHashTagData;
    
    
    NSMutableArray *commonDeatilsArray;
}
@end

@implementation ListOfPostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavLeftButton];
//    self.navigationItem.title =@"EXPLORE";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    
    
    
        
    userDatawhileRegistration =[[NSUserDefaults standardUserDefaults]objectForKey:userDetailkeyWhileRegistration];
    userData =[[NSUserDefaults standardUserDefaults]objectForKey:userDetailKey];
    
    if (userData[@"token"]) {
        userToken = userData[@"token"];
        userName = userData[@"username"];
    }
    else {
        userToken = userDatawhileRegistration[@"response"][@"authToken"];
        userName = userDatawhileRegistration[@"response"][@"username"];
    }
    [self arrangeDataInCommonArray];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedCommentsdata:) name:@"passingUpdatedComments" object:nil];
    
    
    [self jumpToSection];
}

-(void)arrangeDataInCommonArray {
    
    
    dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(backgroundQueue, ^{
        
        commonDeatilsArray = [[NSMutableArray alloc] init];
        
        if([_listViewForPostsOf isEqualToString:@"listViewForFb"]) {
            arrayForFbListData =[[NSMutableArray alloc] init];
            arrayForFbListData = _ListViewdata[@"userPosts"];
            self.navigationItem.title = self.navTitle;
            for (int i = 0 ; i != arrayForFbListData.count ; i++) {
                [commonDeatilsArray addObject: @{
                                                 @"postId" : flStrForObj(arrayForFbListData[i][@"postId"]),
                                                 @"postType" : flStrForObj(arrayForFbListData[i][@"type"]),
                                                 @"likeStatus": @"0",
                                                 @"mainUrl":  flStrForObj(arrayForFbListData[i][@"mainUrl"]),
                                                 @"numberOfLikes":flStrForObj(arrayForFbListData[i][@"likes"]),
                                                 @"postCaption": flStrForObj(arrayForFbListData[i][@"postCaption"]),
                                                 @"profilePicUrl":flStrForObj(_ListViewdata[@"profilePicUrl"]),
                                                 @"postedByuserName": flStrForObj(_ListViewdata[@"username"]),
                                                 @"place": flStrForObj(arrayForFbListData[i][@"place"]),
                                                 @"comments":flStrForObj(arrayForFbListData[i][@"comments"]),
                                                 @"epochValue":flStrForObj(arrayForFbListData[i][@"postedOn"])
                                                 }];
            }
        }
        else  if([_listViewForPostsOf isEqualToString:@"listViewForDiscoverPeople"]) {
            arrayForDiscoverPeopleData =[[NSMutableArray alloc] init];
            arrayForDiscoverPeopleData = _ListViewdata[@"postData"];
            self.navigationItem.title = self.navTitle;
            
            for (int i = 0 ; i != arrayForDiscoverPeopleData.count ; i++) {
                [commonDeatilsArray addObject: @{
                                                 @"postId" : flStrForObj(arrayForDiscoverPeopleData[i][@"postId"]),
                                                 @"postType" : flStrForObj(arrayForDiscoverPeopleData[i][@"postType"]),
                                                 @"likeStatus": @"0",
                                                 @"mainUrl":  flStrForObj(arrayForDiscoverPeopleData[i][@"mainUrl"]),
                                                 @"numberOfLikes":flStrForObj(arrayForDiscoverPeopleData[i][@"likes"]),
                                                 @"postCaption": flStrForObj(arrayForDiscoverPeopleData[i][@"postCaption"]),
                                                 @"postedByuserName": _ListViewdata[@"username"],
                                                 @"profilePicUrl":  flStrForObj(_ListViewdata[@"profilePicUrl"]),
                                                 @"place": flStrForObj( arrayForDiscoverPeopleData[i][@"place"]),
                                                 @"comments":flStrForObj(arrayForDiscoverPeopleData[i][@"comments"]),
                                                 @"epochValue":flStrForObj(arrayForDiscoverPeopleData[i][@"postedOn"])
                                                 }];
            }
        }
        else if ([_listViewForPostsOf isEqualToString:@"ListViewForHashTags"]) {
            arrayForHashTagData =[[NSMutableArray alloc] init];
            arrayForHashTagData = _dataForListView;
            self.navigationItem.title = self.navTitle;
            commonDeatilsArray = [NSMutableArray array];
            for (int i = 0 ; i != arrayForHashTagData.count ; i++) {
                [commonDeatilsArray addObject: @{
                                                 @"postId" : flStrForObj(arrayForHashTagData[i][@"postId"]),
                                                 @"postType" : flStrForObj(arrayForHashTagData[i][@"postType"]),
                                                 @"likeStatus": flStrForObj(arrayForHashTagData[i][@"likeFlag"]),
                                                 @"mainUrl":  flStrForObj(arrayForHashTagData[i][@"mainUrl"]),
                                                 @"numberOfLikes":flStrForObj(arrayForHashTagData[i][@"likes"]),
                                                 @"postCaption": flStrForObj(arrayForHashTagData[i][@"postCaption"]),
                                                 @"postedByuserName": flStrForObj(arrayForHashTagData[i][@"username"]),
                                                 @"profilePicUrl": flStrForObj(arrayForHashTagData[i][@"profilePicUrl"]),
                                                 @"place": flStrForObj(arrayForHashTagData[i][@"place"]),
                                                 @"comments":flStrForObj(arrayForHashTagData[i][@"comments"]),
                                                 @"epochValue":flStrForObj(arrayForHashTagData[i][@"postedOn"])
                                                 }];
            }
        }
        else {
            self.navigationItem.title =@"EXPLORE";
            
            //from explore page.
            NSMutableArray *justForCountOfSections = _dataForListView[0];
            for (int i = 0 ; i != justForCountOfSections.count ; i++) {
                [commonDeatilsArray addObject: @{
                                                 @"postId" : flStrForObj(_dataForListView[0][i][@"postData"][0][@"postId"]),
                                                 @"postType" : flStrForObj(_dataForListView[0][i][@"postData"][0][@"postType"]),
                                                 @"likeStatus": @"0",
                                                 @"mainUrl":  flStrForObj(_dataForListView[0][i][@"postData"][0][@"mainUrl"]),
                                                 @"numberOfLikes":[NSString stringWithFormat:@"%@",flStrForObj(_dataForListView[0][i][@"postData"][0][@"likes"])],
                                                 @"postCaption": flStrForObj(_dataForListView[0][i][@"postData"][0][@"postCaption"]),
                                                 @"postedByuserName": flStrForObj(_dataForListView[0][i][@"postedByuserName"]),
                                                 @"profilePicUrl": flStrForObj(_dataForListView[0][i][@"profilePicUrl"]),
                                                 @"place": flStrForObj(_dataForListView[0][i][@"postData"][0][@"place"]),
                                                 @"comments": flStrForObj(_dataForListView[0][i][@"postData"][0][@"comments"]),
                                                 @"epochValue": flStrForObj(_dataForListView[0][i][@"postData"][0][@"postedOn"]),
                                                 }];
            }
        }

    });

}

-(void)updatedCommentsdata:(NSNotification *)noti {
    NSInteger updateCellNumber  = [noti.object[@"newCommentsData"][@"selectedCell"] integerValue];
    NSString *updatedComment = flStrForObj(noti.object[@"newCommentsData"][@"data"][0][@"Posts"][@"properties"][@"commenTs"]);

    //update comment value here.
    
    [commonDeatilsArray setObject:@{
                                    @"postId" : flStrForObj(commonDeatilsArray[updateCellNumber][@"postId"]),
                                    @"postType" : flStrForObj(commonDeatilsArray[updateCellNumber][@"postType"]),
                                    @"likeStatus":  flStrForObj(commonDeatilsArray[updateCellNumber][@"likeStatus"]),
                                    @"mainUrl":  flStrForObj(commonDeatilsArray[updateCellNumber][@"mainUrl"]),
                                    @"numberOfLikes":flStrForObj(commonDeatilsArray[updateCellNumber][@"numberOfLikes"]),
                                    @"postCaption": flStrForObj(commonDeatilsArray[updateCellNumber][@"postCaption"]),
                                     @"comments":flStrForObj(updatedComment),
                                    @"profilePicUrl": flStrForObj(commonDeatilsArray[updateCellNumber][@"profilePicUrl"]),
                                    @"postedByuserName": flStrForObj(commonDeatilsArray[updateCellNumber][@"postedByuserName"]),
                                    @"place": flStrForObj(commonDeatilsArray[updateCellNumber][@"place"]),
                                    @"epochValue": flStrForObj(commonDeatilsArray[updateCellNumber][@"epochValue"]),
                                    } atIndexedSubscript:updateCellNumber];
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:updateCellNumber] withRowAnimation:UITableViewRowAnimationNone];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
//    CGRect sectionRect = [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_movetoRowNumber]];
//    CGPoint offset =_tableView.contentOffset;
//    offset.y = sectionRect.origin.y;
//    _tableView.contentOffset = offset;

    

    
//    NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:0 inSection:_movetoRowNumber];
//    [[self tableView] scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}


-(void)jumpToSection {
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(changeColor) userInfo:nil repeats:NO];
}

-(void)changeColor {
    CGRect sectionRect = [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_movetoRowNumber]];
    CGPoint offset =_tableView.contentOffset;
    offset.y = sectionRect.origin.y;
    _tableView.contentOffset = offset;
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

/*-------------------------------------------------------------------------*/
  //tableview delegates and data source.
/*------------------------------------------------------------------------*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if([_listViewForPostsOf isEqualToString:@"listViewForFb"]) {
        return arrayForFbListData.count;
    }
    else  if([_listViewForPostsOf isEqualToString:@"listViewForDiscoverPeople"]) {
        return arrayForDiscoverPeopleData.count;
       }
    else  if([_listViewForPostsOf isEqualToString:@"ListViewForHashTags"]) {
        return arrayForHashTagData.count;
    }
    else {
        NSMutableArray *justForCountOfSections = _dataForListView[0];
         return justForCountOfSections.count;
    }
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
    [UserNamelabel setFont:[UIFont fontWithName:RobotoMedium size:14]];
    UserNamelabel.textColor = [UIColor colorWithRed:0.1568 green:0.1568 blue:0.1568 alpha:1.0];
    
    UIButton *locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *placeName;
    NSString *profilePicImageUrl;
    
    placeName = flStrForObj(commonDeatilsArray[section][@"place"]);
    UserNamelabel.text = flStrForObj(commonDeatilsArray[section][@"postedByuserName"]);
    profilePicImageUrl = flStrForObj(commonDeatilsArray[section][@"profilePicUrl"]);
   
    if ([placeName isEqualToString:@"[object Object]"]) {
        placeName = @"";
        locationButton.enabled = NO;
    }
    else {
          locationButton.enabled = YES;
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
    
    timeLabel.text = @"";
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
    [UserImageView sd_setImageWithURL:[NSURL URLWithString:profilePicImageUrl]
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
    
    Listcell = [tableView dequeueReusableCellWithIdentifier:@"ListViewCell"
                                           forIndexPath:indexPath];
    
    
    
    //giving height for imageview but its is not fixed it must be vary on every image height.
    Listcell.imageViewHeightConstraint.constant = 320;
    
    //downloading image and updating in imageview by using sd_webimage(it is very fast).
    //if image is not downloaded then default loading image will shown(it is gif formated).
    
    UIView *view = (UIView *)[Listcell viewWithTag:12345];
    [view removeFromSuperview];
    NSString *mainNailUrl;
    NSString *numberOfLikes;
    NSString *postedUser;
    
    mainNailUrl =     flStrForObj(commonDeatilsArray[indexPath.section][@"mainUrl"]);
    numberOfLikes = [NSString stringWithFormat:@"%@",  flStrForObj(commonDeatilsArray[indexPath.section][@"numberOfLikes"])];
    comment =     flStrForObj(commonDeatilsArray[indexPath.section][@"postCaption"]);
    postedUser = flStrForObj(commonDeatilsArray[indexPath.section][@"postedByuserName"]);
     Listcell.timeLabelOutlet.text =  [self convertEpochToNormalTime:flStrForObj(commonDeatilsArray[indexPath.section][@"epochValue"])]; 
    
    [Listcell.postedImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:mainNailUrl]
                                                                                       placeholderImage:[UIImage sd_animatedGIFNamed:@"loading"]];
    Listcell.personsLikedinfoLabelOutlet.text = numberOfLikes;
    
                                                 
    [Listcell.listOfPeopleLikedThePostButton addTarget:self action:@selector(listOfAllLikesButton:) forControlEvents:UIControlEventTouchUpInside];
    [Listcell.shareButtonOutlet addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
        //customizing CaptionLabel.
        //user name with status and changing the color and font  for username and status.
       
        // comment = _dataForListView[indexPath.section][@"node2"][@"properties"][@"postCaption"];
        NSString *commentWithUserName = [postedUser stringByAppendingFormat:@"  %@",comment];
        NSMutableAttributedString * attributtedComment = [[NSMutableAttributedString alloc] initWithString:commentWithUserName];
       [attributtedComment addAttribute:NSForegroundColorAttributeName
                                                                            value:[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]
                                                                            range:NSMakeRange(0,postedUser.length)];
        [attributtedComment addAttribute:NSFontAttributeName
                                                                            value:[UIFont fontWithName:RobotoRegular size:14]
                                                                            range:NSMakeRange(0, postedUser.length)];
    [Listcell.userNameWithCaptionOutlet setAttributedText:attributtedComment];
     [self showCommentsOnPost:indexPath.section];
    
    [self updateLikeButtonStatus:indexPath.section ];                                          
    //setting Tags For  Different Items
    //alloting tag for every button and imageView.
    Listcell.moreButtonOutlet.tag = 1000 + indexPath.section;
    Listcell.viewAllCommentsButtonOutlet.tag = 3000 + indexPath.section;
    Listcell.commentButtonOutlet.tag = 4000 + indexPath.section;
    Listcell.postedImageViewOutlet.tag = 5000 + indexPath.section;
    Listcell.listOfPeopleLikedThePostButton.tag = 6000 +indexPath.section;
    Listcell.shareButtonOutlet.tag = 7000+indexPath.section;
    
    //in posts details it contains 4 fixed buttons(for every post). they are like,shrae,comment and more.
    [Listcell.moreButtonOutlet addTarget:self
                              action:@selector(moreButtnAction:)
                    forControlEvents:UIControlEventTouchUpInside];
    
    [Listcell.viewAllCommentsButtonOutlet addTarget:self action:@selector(viewAllCommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [Listcell.commentButtonOutlet addTarget:self action:@selector(CommentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //setting heightContsraintFor Label and cell(according to labels height).
    [self HeightConstraintForLabels:Listcell];
    
    //handling hashTags and UserNames.
    Listcell.userNameWithCaptionOutlet.userInteractionEnabled =YES;
    [self handlingHashTags];
    [self handlingURLLink];
    [self handlinguserName];
    
    //CreatingTapGestureDoubleTapForImage
//    [self CreatingTapGestureDoubleTapForImage];
    [self creatingTapGesturePostedImage:Listcell.postedImageViewOutlet];
    return Listcell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return heightOfTheRow;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected section  %ld",(long)indexPath.section);
}

/*----------------------------------------------------------------------------*/
// tableview Header Buttons And Actions.
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
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkProfileOfUserNmae = flStrForObj(commonDeatilsArray[selectedHeaderButton.tag%10000][@"postedByuserName"]);
    newView.checkingFriendsProfile = YES;
    [self.navigationController pushViewController:newView animated:YES];
}



//***
/*-------------------------------------------------------------------------------*/
// ImageTapGesture and HeightConstraints.
/*-------------------------------------------------------------------------------*/

-(void)CreatingTapGestureDoubleTapForImage {
    //adding tapgesture for every image for double tapping like.
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTwoTaps)];
    doubleTap.numberOfTapsRequired = 2;
    [Listcell.postedImageViewOutlet addGestureRecognizer:doubleTap];
    Listcell.postedImageViewOutlet.userInteractionEnabled = YES;
}

-(void)HeightConstraintForLabels:(id)sender {
    HomeViewTableViewCell *receivedCell = (HomeViewTableViewCell *)sender;
    
    //setting height constraints.
    
    CGFloat dynamicHeightOfuserNameWithCaptionLabel;
    CGFloat dynamicHeightOfSecondCommentLabel = 0;
    CGFloat dynamicHeightOffirstCommentLabel =0;
    
    if([comment isEqualToString:@"null"]) {
        receivedCell.userNameWithCaptionHeightConstraint.constant = 0;
    }
    else {
        // for caption label.
        dynamicHeightOfuserNameWithCaptionLabel =  [self heightOfText:receivedCell.userNameWithCaptionOutlet];
        receivedCell.userNameWithCaptionHeightConstraint.constant = dynamicHeightOfuserNameWithCaptionLabel;
    }
    
    if([receivedCell.commentLabelOne.text isEqualToString:@""]) {
        receivedCell.firstCommentHeightConstraint.constant = 0;
    }
    else {
        //for first comment label.
        dynamicHeightOffirstCommentLabel =  [self heightOfText:receivedCell.commentLabelOne];
        receivedCell.firstCommentHeightConstraint.constant = dynamicHeightOffirstCommentLabel;
    }
    
    if([receivedCell.commentLabelOne.text isEqualToString:@""]) {
        receivedCell.secondCommentHeightConstraint.constant = 0;
    }
    else {
        //for secondComments Label.
        dynamicHeightOfSecondCommentLabel = [self heightOfText:receivedCell.commentLabelTwo];
        receivedCell.secondCommentHeightConstraint.constant = dynamicHeightOfSecondCommentLabel;
    }
    
    //need to check.
    if (![receivedCell.commentLabelOne.text isEqualToString:@""] && ![receivedCell.commentLabelTwo.text isEqualToString:@""]) {
        receivedCell.viewAllCommentsButtonHeightConstraint.constant = 20;
        receivedCell.viewAllCommentsButtonOutlet.hidden = NO;
    }
    else {
        receivedCell.viewAllCommentsButtonHeightConstraint.constant = 0;
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
    receivedCell.captionAndCommentHeightConstraint.constant = dynamicHeightOfuserNameWithCaptionLabel + dynamicHeightOffirstCommentLabel +dynamicHeightOfSecondCommentLabel + receivedCell.timeLabelHeightConstraint.constant + receivedCell.viewAllCommentsButtonOutlet.frame.size.height;
    
    //totallikeButtonsViewWithCommentsandCaptionView it is
    receivedCell.totallikeButtonsViewWithCommentsandCaptionViewHeightConstraint.constant = receivedCell.captionAndCommentHeightConstraint.constant + receivedCell.LikeViewHeightConstraint.constant;
    
    //total height of the section including with image,header and comments section(40 is tableview header height and it is fixed).
    heightOfTheRow = receivedCell.totallikeButtonsViewWithCommentsandCaptionViewHeightConstraint.constant + 15 + receivedCell.imageViewHeightConstraint.constant + 40 ;
}


/*------------------------------------------------*/
//  Like
/*-----------------------------------------------*/

-(void)updateLikeButtonStatus :(NSInteger )section  {
   
    //temp later change depending on
    if ([commonDeatilsArray[section][@"likeStatus"] isEqualToString:@"0"]) {
        Listcell.likeButtonOutlet  .selected = NO;
    }
    else  {
        Listcell.likeButtonOutlet .selected = YES;
    }
    Listcell.likeButtonOutlet.tag = 12365 + section;
    [Listcell.likeButtonOutlet addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)likeButtonAction:(id)sender {
    
    UIButton *selectedButton = (UIButton *)sender;
    //getting which cell is selected.
    NSIndexPath *selectedCellForLike = [_tableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    if (selectedButton.selected) {
        selectedButton.selected = NO;
        [self unlikeAPost:selectedCellForLike.section];
        
        
        //updating new number of likes and like status in response
        
        NSInteger newNumberOfLikes = [commonDeatilsArray[selectedCellForLike.section][@"numberOfLikes"] integerValue];
        newNumberOfLikes --;
        
        
        //update comment value here.
        
        [commonDeatilsArray setObject:@{
                                        @"postId" : flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"postId"]),
                                        @"postType" : flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"postType"]),
                                        @"likeStatus": @"0",
                                       @"mainUrl":  flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"mainUrl"]),
                                       @"numberOfLikes":flStrForObj([@(newNumberOfLikes) stringValue]),
                                        @"postCaption": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"postCaption"]),
                                          @"comments":flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"comments"]),
                                        @"profilePicUrl": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"profilePicUrl"]),
                                        @"postedByuserName": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"postedByuserName"]),
                                        @"place": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"place"]),
                                        @"epochValue": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"epochValue"])
                                        } atIndexedSubscript:selectedCellForLike.section];
        
        
        NSArray *subviews =   [[[[sender superview] superview] superview] subviews];
        NSArray *subviw2 = [subviews[0] subviews];
        NSArray *subview3 =  [subviw2[4] subviews];
        NSArray *subview4 =  [subview3[0] subviews];
        
        UILabel *totalLikeslabel =  (UILabel *)subview4[0];
        totalLikeslabel.text = [NSString stringWithFormat:@"%@", flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"numberOfLikes"])];
        
    }
    else {
        selectedButton.selected = YES;
        [self likeAPost:selectedCellForLike.section];
       
        //updating new number of likes and like status in response
        NSInteger newNumberOfLikes = [commonDeatilsArray[selectedCellForLike.section][@"numberOfLikes"] integerValue];
        newNumberOfLikes ++;

        [commonDeatilsArray setObject:@{
                                        @"postId" : flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"postId"]),
                                        @"postType" : flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"postType"]),
                                        @"likeStatus": @"1",
                                        @"mainUrl":  flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"mainUrl"]),
                                        @"numberOfLikes":flStrForObj([@(newNumberOfLikes) stringValue]),
                                        @"postCaption": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"postCaption"]),
                                        @"comments":flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"comments"]),
                                        @"profilePicUrl": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"profilePicUrl"]),
                                        @"postedByuserName": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"postedByuserName"]),
                                        @"place": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"place"]),
                                        @"epochValue": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"epochValue"])
                                        } atIndexedSubscript:selectedCellForLike.section];
        
        NSArray *subviews =   [[[[sender superview] superview] superview] subviews];
        NSArray *subviw2 = [subviews[0] subviews];
        NSArray *subview3 =  [subviw2[4] subviews];
        NSArray *subview4 =  [subview3[0] subviews];
        
        UILabel *totalLikeslabel =  (UILabel *)subview4[0];
        totalLikeslabel.text =  [NSString stringWithFormat:@"%@", flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"numberOfLikes"])];
    }
}

//list of all persons who liked the post button.
-(void)listOfAllLikesButton:(id)sender {
    UIButton *selectedButton = (UIButton *)sender;
    int selectedIndex = selectedButton.tag % 6000;
    LikeViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"likeStoryBoardId"];
    newView.navigationTitle = @"Likers";
    newView.postType = flStrForObj(commonDeatilsArray[selectedIndex][@"postType"]);
    newView.postId = flStrForObj(commonDeatilsArray[selectedIndex][@"postId"]);
    [self.navigationController pushViewController:newView animated:YES];
}

/*-----------------------------------------------------*/
// MORE BUTTON
/*----------------------------------------------------*/

- (void)moreButtnAction:(id)sender {
    
    
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Report" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Nil otherButtonTitles:@"Share to Facebook", @"Copy Share URL", @"Turn on Post Notifications", nil];
    [sheet showInView:self.view];
}
                          
/*-------------------------------------------*/
//COMMENT
/*------------------------------------------*/

-(void)viewAllCommentButtonAction:(id)sender {
    HomeViewCommentsViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsStoryBoardId"];
    
    NSIndexPath *selectedCellForViewAllComments = [_tableView indexPathForCell:(UITableViewCell *)[[[[sender superview] superview] superview] superview]];
    
    newView.postId =  flStrForObj(commonDeatilsArray[selectedCellForViewAllComments.section][@"postId"]);
    newView.postType =  flStrForObj(commonDeatilsArray[selectedCellForViewAllComments.section][@"postType"]);
    newView.postCaption =   flStrForObj(commonDeatilsArray[selectedCellForViewAllComments.section][@"postCaption"]);
    newView.imageUrlOfPostedUser = flStrForObj(commonDeatilsArray[selectedCellForViewAllComments.section][@"profilePicUrl"]);
    newView.selectedCellIs =selectedCellForViewAllComments.section;
    newView.userNameOfPostedUser =flStrForObj(commonDeatilsArray[selectedCellForViewAllComments.section][@"postedByuserName"]);
    [self.navigationController pushViewController:newView animated:YES];
}

-(void)CommentButtonAction:(id)sender {
    
    //getting which cell is selected.
    NSIndexPath *selectedCellForViewAllComments = [_tableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    
    //passing data for comments.
    HomeViewCommentsViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsStoryBoardId"];
    
    newView.postId =  flStrForObj(commonDeatilsArray[selectedCellForViewAllComments.section][@"postId"]);
    newView.postType =  flStrForObj(commonDeatilsArray[selectedCellForViewAllComments.section][@"postType"]);
    newView.postCaption =   flStrForObj(commonDeatilsArray[selectedCellForViewAllComments.section][@"postCaption"]);
    newView.imageUrlOfPostedUser = flStrForObj(commonDeatilsArray[selectedCellForViewAllComments.section][@"profilePicUrl"]);
    newView.selectedCellIs =selectedCellForViewAllComments.section;
    newView.userNameOfPostedUser =flStrForObj(commonDeatilsArray[selectedCellForViewAllComments.section][@"postedByuserName"]);
    
    
    [self.navigationController pushViewController:newView animated:YES];
 }

/*----------------------------------------------*/
// share
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
// Handling Hashtags,URL and UserNames.
/*------------------------------------------------------------------------------*/

-(void)handlingHashTags {
    // Attach a block to be called when the user taps a hashtag.
    
    Listcell.userNameWithCaptionOutlet.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
        newView.navTittle = string;
        [self.navigationController pushViewController:newView animated:YES];
    };
}

-(void)handlinguserName {
    // Attach a block to be called when the user taps a user handle.
    
    Listcell.userNameWithCaptionOutlet.userHandleLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
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
    Listcell.userNameWithCaptionOutlet.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        NSLog(@"URL tapped %@", string);
    };
}

/*---------------------------------------------------*/
// DoubleTap For PostLike.
/*----------------------------------------------------*/

- (void)oneFingerTwoTaps{
    Listcell.likeImage.hidden = NO;
    Listcell.likeImage.alpha = 1;
    int duration = 2;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        Listcell.likeImage.hidden = YES;
        Listcell.likeImage.alpha = 0;
    });
}

/*-------------------------------------------------------*/
// labelHeightDynamically.
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
    
    NSDictionary *responseDict = (NSDictionary*)response;
    if (requestType == RequestTypeLikeAPost) {
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                        message:responseDict[@"message"]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else if (requestType == RequestTypeUnlikeAPost) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                        message:responseDict[@"message"]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
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
        Listcell.likeImage.hidden = YES;
        Listcell.likeImage.alpha = 0;
        for (UIButton *eachButton in Listcell.postedImageViewOutlet.subviews) {
            [UIView transitionWithView:Listcell.postedImageViewOutlet
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
//    NSArray *namesOfTaggedPeople = [responseData[view.tag%5000][@"usersTagged"] componentsSeparatedByString:@","];
    NSArray *namesOfTaggedPeople = [[NSArray alloc] initWithObjects:@"dinesh",@"suresh", nil];
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
            [customButton setFrame:CGRectMake(60, (i+1)*50, stringsize.width + 50, 40)];
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

/*---------------------------------------------------*/
// DoubleTap For PostLike.
/*----------------------------------------------------*/

- (void) animateLike :(UITapGestureRecognizer *)sender{
    
    for (UIButton *eachButton in Listcell.postedImageViewOutlet.subviews) {
        [UIView transitionWithView:Listcell.postedImageViewOutlet
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
    
    NSString *likeStatus =  [NSString stringWithFormat:@"%@", commonDeatilsArray[selectedCellForLike.section][@"likeStatus"]];
    
    if ([likeStatus  isEqualToString:@"0"]) {
        selectedButton.selected = YES;
        [self likeAPost:selectedCellForLike.section];
        
        NSInteger newNumberOfLikes = [commonDeatilsArray[selectedCellForLike.section][@"likes"] integerValue];
        newNumberOfLikes ++;

        //just updating the keys of numberoflikes and like status in commonDeatilsArray for particulkar object.
        
        [commonDeatilsArray setObject:@{
                                        @"postId" : flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"postId"]),
                                        @"postType" : flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"postType"]),
                                        @"likeStatus": @"1",
                                        @"mainUrl":  flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"mainUrl"]),
                                        @"numberOfLikes":flStrForObj([@(newNumberOfLikes) stringValue]),
                                        @"postCaption": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"postCaption"]),
                                        @"comments":flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"comments"]),
                                        @"profilePicUrl": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"profilePicUrl"]),
                                        @"postedByuserName": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"postedByuserName"]),
                                        @"place": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"place"]),
                                        @"epochValue": flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"epochValue"])
                                        } atIndexedSubscript:selectedCellForLike.section];
        
        NSArray *subviews =   [[[[sender superview] superview] superview] subviews];
        NSArray *subviw2 = [subviews[0] subviews];
        NSArray *subview3 =  [subviw2[4] subviews];
        NSArray *subview4 =  [subview3[0] subviews];
        
        //subview4[0] is the label for displaying number of likes.
        UILabel *totalLikeslabel =  (UILabel *)subview4[0];
        totalLikeslabel.text =  [NSString stringWithFormat:@"%@", flStrForObj(commonDeatilsArray[selectedCellForLike.section][@"numberOfLikes"])];
    }
}

/*-----------------------------------------------------*/
#pragma mark - Request For Services.
/*----------------------------------------------------*/
-(void)likeAPost:(NSInteger)selectedIndex
{
    NSDictionary *requestDict;
    NSString *postId =flStrForObj(commonDeatilsArray[selectedIndex][@"postId"]);
    NSString *postType = flStrForObj(commonDeatilsArray[selectedIndex][@"postType"]);
   
    // 1 is for video and 0 is for photo.
    
    if ([postType isEqualToString:@"1"]) {
        requestDict = @{
                        mauthToken:flStrForObj(userToken),
                        mpostid:postId,
                        mLabel:@"Video"
                        };
    }
    else {
        requestDict = @{
                        mauthToken:flStrForObj(userToken),
                        mpostid:postId,
                        mLabel:@"Photo"
                        };
    }
    [WebServiceHandler likeAPost:requestDict andDelegate:self];
}

-(void)unlikeAPost:(NSInteger)selectedIndex {
    NSDictionary *requestDict;
    NSString *postId = flStrForObj(commonDeatilsArray[selectedIndex][@"postId"]);
    NSString *postType = flStrForObj(commonDeatilsArray[selectedIndex][@"postType"]);
   
    if ([postType isEqualToString:@"1"]) {
        requestDict = @{
                        mauthToken:flStrForObj(userToken),
                        mpostid:postId,
                        mLabel:@"Video",
                        mUserName:userName
                        };
    }
    else {
        requestDict = @{
                        mauthToken:flStrForObj(userToken),
                        mpostid:postId,
                        mLabel:@"Photo",
                        mUserName:userName
                        };
    }
    [WebServiceHandler unlikeAPost:requestDict andDelegate:self];
}

-(void)showCommentsOnPost:(NSInteger )section {
    NSArray *response =  [flStrForObj(commonDeatilsArray[section][@"comments"]) componentsSeparatedByString:@"^^"];
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
        Listcell.commentLabelOne.text = @"";
        Listcell.commentLabelTwo.text = @"";
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
        [Listcell.commentLabelOne setAttributedText:attributtedPostComment1];
        Listcell.commentLabelTwo.text = @"";
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
        [Listcell.commentLabelOne setAttributedText:attributtedPostComment1];
        [Listcell.commentLabelTwo setAttributedText:attributtedPostComment2];
    }
}

-(NSString *)convertEpochToNormalTime :(NSString *)epochTime{
    //getting date(including time) from epochTime.
    
    // Convert NSString to NSTimeInterval
    NSTimeInterval seconds = [epochTime doubleValue];
    // (Step 1) Create NSDate object
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:(seconds/1000)];
    // (Step 2) Use NSDateFormatter to display epochNSDate in local time zone
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    //getting present time.
    
    NSDate *todayDate = [NSDate date]; // get today date
    NSDateFormatter *dateFormatte = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date..
    [dateFormatte setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"]; //Here we can set the format which we need
    //getting duration between posted time to the present time.
    NSTimeInterval secondsBetween = [todayDate timeIntervalSinceDate:epochNSDate];
    NSString *timeStamp = [self PostedTimeSincePresentTime:secondsBetween];
    return timeStamp;
}

/* -----------------------------------------------------------------------*/
#pragma mark
#pragma mark - TimeConverting  From EpochValue
/* ----------------------------------------------------------------------*/

//converting seconds into minutes or hours or  days or weeks based on number of seconds.
-(NSString *)PostedTimeSincePresentTime:(NSTimeInterval)seconds {
    if(seconds < 60)
    {
        NSInteger time = round(seconds);
        //showing timestamp in seconds.
        
        if(seconds < 1)
        {
            seconds = 2;
        }
        NSString *secondsInstringFormat = [NSString stringWithFormat:@"%ld", (long)time];
        NSString *secondsWithSuffixS;
        if (time >1) {
            secondsWithSuffixS = [secondsInstringFormat stringByAppendingString:@"seconds ago"];
        }
        else {
            secondsWithSuffixS = [secondsInstringFormat stringByAppendingString:@"second ago"];
        }
        
        return secondsWithSuffixS;
    }
    
    else if (seconds >= 60 && seconds <= 60 *60) {
        //showing timestamp in minutes.
        NSInteger numberOfMinutes = seconds / 60;
        NSString *minutesInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfMinutes];
        NSString *minutesWithSuffixM;
        
        if (numberOfMinutes >1) {
            minutesWithSuffixM = [minutesInstringFormat stringByAppendingString:@"minutes ago"];
        }
        else {
            minutesWithSuffixM = [minutesInstringFormat stringByAppendingString:@"minute ago"];
        }
        
        return minutesWithSuffixM;
    }
    else if (seconds >= 60 *60 && seconds <= 60*60*24) {
        //showing timestamp in hours.
        NSInteger numberOfHours = seconds /(60*60);
        
        NSString *hoursInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfHours];
        NSString *hoursWithSuffixH;
        if (numberOfHours >1) {
            hoursWithSuffixH = [hoursInstringFormat stringByAppendingString:@"hours ago"];
        }
        else {
            hoursWithSuffixH = [hoursInstringFormat stringByAppendingString:@"hour ago"];
        }
        
        return hoursWithSuffixH;
    }
    else if (seconds >= 24 *60 *60 && seconds <= 60*60*24*7) {
        //showing timestamp in days.
        NSInteger numberOfDays = seconds/(60*60*24);
        NSString *daysInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfDays];
        NSString *daysWithSuffix;
        if (numberOfDays >1) {
            daysWithSuffix = [daysInstringFormat stringByAppendingString:@"days ago"];
        }
        else {
            daysWithSuffix = [daysInstringFormat stringByAppendingString:@"day ago"];
        }
        return daysWithSuffix;
    }
    else if (seconds >= 60*60*24*7) {
        //showing timestamp in weeks.
        NSInteger numberOfWeeks = seconds /(60*60*24*7);
        NSString *weeksInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfWeeks];
        NSString *weeksWithSuffixS;
        if (numberOfWeeks >1) {
            weeksWithSuffixS = [weeksInstringFormat stringByAppendingString:@"weeks ago"];
        }
        else {
            weeksWithSuffixS = [weeksInstringFormat stringByAppendingString:@"week ago"];
        }
        return weeksWithSuffixS;
    }
    return @"";
}

@end
