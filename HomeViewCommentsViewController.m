//
//  HomeViewCommentsViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 4/4/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "HomeViewCommentsViewController.h"
#import "WebServiceHandler.h"
#import "TinderGenericUtility.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"
#import "ProgressIndicator.h"
#import "HomeViewTableViewController.h"
#import "FontDetailsClass.h"
#import "UserProfileViewController.h"
#import "HashTagViewController.h"
#import "Helper.h"
#import "UITextView+Placeholder.h"
#import "UserNameSuggestionTableViewCell.h"




@interface HomeViewCommentsViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,WebServiceHandlerDelegate,UIGestureRecognizerDelegate,UITextViewDelegate> {
    int keyboardHeight;
   
    NSMutableArray *responseArray;
    NSMutableArray *userSuggestionArray;
    UIRefreshControl *refreshControl;
    CGFloat heightOfRow;
    UIView *customizedTableviewHeader;
    NSInteger *offset;
    NSInteger index;
    
    NSString *laststring;
    
    BOOL onlyFirstTimeMoveToBottom;
    BOOL dataAvailable;
    BOOL needToShowHeaderForMorePosts;
    BOOL PostsAreMoreThanTwenty;
    
    CGFloat tableviewCurrentYoffset;
}

@end

@implementation HomeViewCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //customizing navigationBar.
    
     [self.navigationController.interactivePopGestureRecognizer setDelegate:nil];
    self.navigationController.navigationItem.title = @"Comments";
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    
    [self.sendButtonOutlet setEnabled:NO];
    
    // creating navigationBar left buttton.
    [self createNavLeftButton];
    
    self.commentTextView.text =@"";
    self.commentTextView.placeholder = @"Add a comment..";
    self.commentTextView.placeholderColor = [UIColor lightGrayColor];
    self.commentTextView.textColor = [UIColor blackColor];
   
    
//    //tapGesture hiding keyBoard.
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                          action:@selector(dismissKeyboard)];
//    tap.delegate = self;
//    [self.view addGestureRecognizer:tap];
    
    // customizing textField placeHolder color.
    
//    [self.commentTextView setValue:[UIColor colorWithRed:0.6247 green:0.6246 blue:0.6246 alpha:0.5]
//                         forKeyPath:@"_placeholderLabel.textColor"];
    
    
    
    //  KeyboardWillShowNotification.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //when keyboard appears this will  notifiy.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:self.commentTextView];
    
    
    self.bottomCommentView.layer.borderWidth = 0.5;
    self.bottomCommentView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    onlyFirstTimeMoveToBottom = YES;
    
    needToShowHeaderForMorePosts = YES;
    PostsAreMoreThanTwenty = NO;
    
    responseArray =[[NSMutableArray alloc] init];
    userSuggestionArray= [[NSMutableArray alloc] init];
    
    self.sendButtonOutlet.enabled = NO;
}





#pragma mark
#pragma mark -TextField Delgates.

- (BOOL)checkForMandatoryField {
    if (self.commentTextView.text.length != 0 ) {
        return YES;
    }
    return NO;
}



-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text containsString:@"\n"]){
        NSString *newwwText = [self.commentTextView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
           self.commentTextView.text = newwwText;
           [self dismissKeyboard];
    }
    else {
        if ([self checkForMandatoryField]) {
            [self.sendButtonOutlet setEnabled:YES];
        }
        else {
            [self.sendButtonOutlet setEnabled:NO];
        }

        //From here you can get the last text entered by the user
        NSArray *stringsSeparatedBySpace = [textView.text componentsSeparatedByString:@" "];
        
        //then you can check whether its one of your userstrings and trigger the event
        laststring = [stringsSeparatedBySpace lastObject];
        bool isValidForTagFriends = [laststring containsString:@"@"];
        
        if(isValidForTagFriends) {
            if (laststring.length > 2) {
                [self requestForTagFriends];
                self.commentsTableViewOutlet.hidden = YES;
            }
            else {
                self.commentsTableViewOutlet.hidden = NO;
            }
        }
        else {
            self.commentsTableViewOutlet.hidden = NO;
        }
        
        CGRect newFramae = self.commentTextView.frame;
        newFramae.size.height = self.commentTextView.contentSize.height;
        
        if(newFramae.size.height + 20 > 54 )
        {
            
            if (newFramae.size.height < 108) {
                self.textViewSuperViewHeightConstraint.constant = newFramae.size.height + 20;
                self.commentTextViewHeightConstraint.constant = newFramae.size.height + 2;
            }
            
            NSLog(@"heigh of view constranit:%f",self.textViewSuperViewHeightConstraint.constant);
            NSLog(@"frame of textview:%f",textView.frame.size.height);
            
        }
        else {
            
            self.textViewSuperViewHeightConstraint.constant = 54;
            self.commentTextViewHeightConstraint.constant = 34;
            
            NSLog(@"heigh of view constranit:%f",self.textViewSuperViewHeightConstraint.constant);
            NSLog(@"frame of textview:%f",textView.frame.size.height);
        }
        
        if (self.commentsTableViewOutlet.contentSize.height > self.commentsTableViewOutlet.frame.size.height)
        {
            CGPoint newPosition = CGPointMake(0, self.commentsTableViewOutlet.contentSize.height - self.commentsTableViewOutlet.frame.size.height );
            [self.commentsTableViewOutlet setContentOffset:newPosition animated:NO];
        }
        [self adjustContentSize:self.commentTextView];
    }
}

-(void)requestForTagFriends {
    NSString  *stringToSearchForTagFriend = [laststring substringFromIndex:1];
    NSDictionary *requestDict = @{
                                  muserTosearch :stringToSearchForTagFriend,
                                  mauthToken :[Helper userToken],
                                  };
    [WebServiceHandler getUserNameSuggestion:requestDict andDelegate:self];
    [self.commentsTableViewOutlet reloadData];
}


-(void)textViewDidChangeSelection:(UITextView *)textView
{
    
}

-(void)adjustContentSize:(UITextView*)tv{
    CGFloat deadSpace = ([tv bounds].size.height - [tv contentSize].height);
    CGFloat inset = MAX(0, deadSpace/2.0);
    tv.contentInset = UIEdgeInsetsMake(inset, tv.contentInset.left, inset, tv.contentInset.right);
}

-(void)textFieldTextChanged:(id)sender {
    if ([self checkForMandatoryField]) {
        [self.sendButtonOutlet setEnabled:YES];
    }
    else {
        [self.sendButtonOutlet setEnabled:NO];
    }
}
-(void)textViewDidBeginEditing:(UITextView *)textView {
    if(dataAvailable) {
        [self changeThePositionOfTableview];
    }
}

-(void)changeThePositionOfTableview {
    
    [self.timerIvar invalidate];
    self.timerIvar =  nil;
    
    if (self.commentsTableViewOutlet.contentSize.height > self.commentsTableViewOutlet.frame.size.height)
    {
        CGPoint newPosition = CGPointMake(0, self.commentsTableViewOutlet.contentSize.height - self.commentsTableViewOutlet.frame.size.height );
        [self.commentsTableViewOutlet setContentOffset:newPosition animated:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    
    if (onlyFirstTimeMoveToBottom) {
        if (responseArray.count == 0) {
            ProgressIndicator *PI = [ProgressIndicator sharedInstance];
            [PI showPIOnView:self.view withMessage:@"Loading..."];
            [self getPostComments:index];

        }
    }
}

/*-----------------------------------------------------------------------*/
#pragma mark
#pragma mark - tableview delegates and data source.
/*-----------------------------------------------------------------------*/

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 2) {
        return NO;
    }
    else {
        if (indexPath.section == 1) {
            if ([responseArray[indexPath.row][@"username"] isEqualToString:[Helper userName]]) {
                return YES;
            }
            else {
                return NO;
            }
        }
        else {
            return NO;
        }
    }
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    //username and commented username same then user can delete d comment otherwise he can do direct message to commented user.
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        //insert your deleteAction here.
        NSDictionary *requestDict = @{
                                      mauthToken:flStrForObj([Helper userToken]),
                                      mpostid:_postId,
                                      mLabel:@"Video",
                                      mcommentId:responseArray[indexPath.row][@"commentNodeId"],
                                      mtype:_postType
                                      };
        
        [WebServiceHandler deleteComment:requestDict andDelegate:self];
        
        [responseArray removeObjectAtIndex:indexPath.row];
        [_commentsTableViewOutlet deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }];
    
    deleteAction.backgroundColor = [UIColor redColor];
    return @[deleteAction];
    
    
    
    
//    if ([responseArray[indexPath.row][@"username"] isEqualToString:[Helper userName]]) {
//        UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
//            //insert your editAction here
//        }];
//        editAction.backgroundColor = [UIColor blueColor];
//        
//        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Delete"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
//            
//            //insert your deleteAction here.
//            NSDictionary *requestDict = @{
//                                          mauthToken:flStrForObj([Helper userToken]),
//                                          mpostid:_postId,
//                                          mLabel:@"Video",
//                                          mcommentId:responseArray[indexPath.row][@"commentNodeId"],
//                                          mtype:_postType
//                                          };
//            
//            [WebServiceHandler deleteComment:requestDict andDelegate:self];
//            
//            [responseArray removeObjectAtIndex:indexPath.row];
//            [_commentsTableViewOutlet deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
//        }];
//        
//        deleteAction.backgroundColor = [UIColor redColor];
//        return @[deleteAction,editAction];
//    }
//    else {
//        UITableViewRowAction *ReportAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Report" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
//            //insert your editAction here
//        }];
//        ReportAction.backgroundColor = [UIColor blueColor];
//        
//        UITableViewRowAction *ShareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Share"  handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
//            
//            //insert your shareAction here.
//            
//        }];
//        
//        ShareAction.backgroundColor = [UIColor redColor];
//        return @[ReportAction,ShareAction];
//    }
 
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView.tag == 2) {
         return 1;
    }
    else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    if(tableView.tag == 2) {
        return userSuggestionArray.count;
    }
    else {
        if (section == 0) {
            if ([self.postCaption isEqualToString:@"null"]) {
                return 0;
            }
            else {
                // if  there is no caption then no need to show the above posted user name with post caption row.
                return 1;
            }
        }
        else {
            return responseArray.count;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 2 ) {
        //for selected row the username will add with the space and intiall letter with @ letter.
        
        NSString *cellText = [userSuggestionArray[indexPath.row][@"username"] stringByAppendingString:@" "];
        NSString *cellTextWithSymbol =@"@";
        cellTextWithSymbol = [cellTextWithSymbol stringByAppendingString:cellText];
        self.commentTextView.text = [self.commentTextView.text stringByReplacingCharactersInRange:[self.commentTextView.text rangeOfString:laststring options:NSBackwardsSearch] withString:@""];
        
        self.commentTextView.text = [self.commentTextView.text stringByAppendingString:cellTextWithSymbol];
        
        self.commentsTableViewOutlet.hidden = NO;
        [userSuggestionArray removeAllObjects];
        [self.userNameSuggestionView reloadData];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag == 2) {
        //user name suggestion table view
        UserNameSuggestionTableViewCell *commentcell = [tableView dequeueReusableCellWithIdentifier:@"userNameSuggestionTableViewCellIdentifier" forIndexPath:indexPath];
        
        
        [commentcell layoutIfNeeded];
        commentcell.profilePicImageView.layer.cornerRadius = commentcell.profilePicImageView.frame.size.height/2;
        commentcell.profilePicImageView.clipsToBounds = YES;
        
      
        
        NSString *profilePicUrl = flStrForObj(userSuggestionArray[indexPath.row][@"profilePicUrl"]);
        
        
        [commentcell.profilePicImageView sd_setImageWithURL:[NSURL URLWithString:profilePicUrl]
                                              placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
        
        commentcell.userNameLabelOutlet.text = flStrForObj(userSuggestionArray[indexPath.row][@"username"]);
        commentcell.fullNameLabelOutlet.text = flStrForObj(userSuggestionArray[indexPath.row][@"fullName"]);
        
        return commentcell;
    }
    else {
        //comments tableview
        
        
        
        
        HomeViewCommentsTableViewCell *commentcell = [tableView dequeueReusableCellWithIdentifier:@"commentsCell" forIndexPath:indexPath];
        
        
        [commentcell layoutIfNeeded];
        commentcell.profileImageViewOutlet.layer.cornerRadius = commentcell.profileImageViewOutlet.frame.size.height/2;
        commentcell.profileImageViewOutlet.clipsToBounds = YES;
        
        if (indexPath.section == 0) {
            [commentcell.userNameButtonOutlet setTitle:flStrForObj(_userNameOfPostedUser) forState:UIControlStateNormal];
            [commentcell.profileImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:flStrForObj(self.imageUrlOfPostedUser)]
                                                  placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
            
            if ([flStrForObj(self.postCaption) isEqualToString:@"null"]) {
                commentcell.commentLabelOutlet.text = @"";
                heightOfRow = 50;
            }
            else {
                commentcell.commentLabelOutlet.text = flStrForObj(self.postCaption);
                //[self heightOfLabel:commentcell];
                [commentcell changeHeightOfCommentLabel:flStrForObj(self.postCaption) andFrame:self.view.frame];
            }
        }
        else
        {
            [commentcell.profileImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:flStrForObj(responseArray[indexPath.row][@"profilePicUrl"])]
                                                  placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
            [commentcell.userNameButtonOutlet setTitle: flStrForObj(responseArray[indexPath.row][@"username"]) forState:UIControlStateNormal];
            
            commentcell.commentLabelOutlet.text = flStrForObj(responseArray[indexPath.row][@"commentBody"]);
            //[self heightOfLabel:commentcell];
            [commentcell changeHeightOfCommentLabel:flStrForObj(responseArray[indexPath.row][@"commentBody"]) andFrame:self.view.frame];
            commentcell.timeLabelOutlet.text = [self convertTimeFormat:responseArray[indexPath.row][@"commentedOn"]];
        }
        
        commentcell.commentLabelOutlet.userInteractionEnabled = YES;
        
        [self handlingHashTags:commentcell];
        [self handlinguserName:commentcell];
        return commentcell;
    }
}

-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if(tableView.tag == 2) {
        return 50;
    } else {
        HomeViewCommentsTableViewCell *cell = (HomeViewCommentsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"commentsCell"];
        
        NSString *commentWithUserName;
        
        if (indexPath.section == 0) {
            if ([flStrForObj(self.postCaption) isEqualToString:@"null"]) {
                commentWithUserName = @"";
                heightOfRow = 50;
            }
            else {
                commentWithUserName = flStrForObj(self.postCaption);
            }
        }
        else
        {
            commentWithUserName = flStrForObj(responseArray[indexPath.row][@"commentBody"]);
        }
        
        
        UILabel*captionlbl=[[UILabel alloc]initWithFrame:cell.commentLabelOutlet.bounds];
        captionlbl.font=cell.commentLabelOutlet.font;
        
        // NSString *commentWithUserName =   flStrForObj(responseArray[indexPath.row][@"commentBody"]);
        
        NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        commentWithUserName = [commentWithUserName stringByTrimmingCharactersInSet:ws];
        
        
        CGRect frame=captionlbl.frame;
        frame.size.width= self.view.frame.size.width - 65 ;
        captionlbl.frame=frame;
        
        captionlbl.text =commentWithUserName;
        
        CGFloat heightOfCaption;
        
        //claculating the height of text and if the text is empty directly making the respective label or button height as zero otherwise calculating height of text by using measureHieightLabel method.
        //+5 ids for spacing for the labels.
        
        if ([captionlbl.text  isEqualToString:@""]) {
            heightOfCaption = 0;
        }
        else {
            heightOfCaption = [Helper measureHieightLabel:captionlbl] + 5;
        }
        
        // 20 --- > for posted time label height.
        CGFloat totalHeightOfRow =  heightOfCaption + 35;
        
        return totalHeightOfRow;
    }
}

-(void)heightOfLabel:(id)sender {
    HomeViewCommentsTableViewCell *receivedCell = (HomeViewCommentsTableViewCell *)sender;
    
    CGFloat dynamicHeightOfCommentLabel =  [Helper measureHieightLabel:receivedCell.commentLabelOutlet];
    receivedCell.commentLabelHeightConstraint.constant = dynamicHeightOfCommentLabel + 5;
    heightOfRow  =  dynamicHeightOfCommentLabel  + 40;
}

-(NSString *)convertTimeFormat:(NSString *)str {
    NSTimeInterval seconds = [str doubleValue];
    NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:(seconds/1000)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatte = [[NSDateFormatter alloc] init];
    [dateFormatte setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSTimeInterval secondsBetween = [todayDate timeIntervalSinceDate:epochNSDate];
    NSString *timeStamp = [self PostedTimeSincePresentTime:secondsBetween];
  
    return timeStamp;
}


/* ---------------------------------------------------------------------*/
#pragma mark
#pragma mark - TimeConverting  From EpochValue
/* --------------------------------------------------------------------*/

//converting seconds into minutes or hours or  days or weeks based on number of seconds.

-(NSString *)PostedTimeSincePresentTime:(NSTimeInterval)seconds {
    if(seconds < 60)
    {
        NSInteger time = round(seconds);
        //showing timestamp in seconds.
        if(seconds < 3)
        {
            return @"now";
        }
        else {
            NSString *secondsInstringFormat = [NSString stringWithFormat:@"%ld", (long)time];
            NSString *secondsWithSuffixS = [secondsInstringFormat stringByAppendingString:@"s"];
            return secondsWithSuffixS;
        }
    }
    
    else if (seconds >= 60 && seconds <= 60 *60) {
        //showing timestamp in minutes.
        NSInteger numberOfMinutes = seconds / 60;
        
        NSString *minutesInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfMinutes];
        NSString *minutesWithSuffixM = [minutesInstringFormat stringByAppendingString:@"m"];
        return minutesWithSuffixM;
    }
    else if (seconds >= 60 *60 && seconds <= 60*60*24) {
        //showing timestamp in hours.
        NSInteger numberOfHours = seconds /(60*60);
        
        NSString *hoursInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfHours];
        NSString *hoursWithSuffixH = [hoursInstringFormat stringByAppendingString:@"h"];
        return hoursWithSuffixH;
    }
    else if (seconds >= 24 *60 *60 && seconds <= 60*60*24*7) {
        //showing timestamp in days.
        NSInteger numberOfDays = seconds/(60*60*24);
        
        NSString *daysInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfDays];
        NSString *daysWithSuffixD = [daysInstringFormat stringByAppendingString:@"d"];
        return daysWithSuffixD;
    }
    else if (seconds >= 60*60*24*7) {
        //showing timestamp in weeks.
        NSInteger numberOfWeeks = seconds /(60*60*24*7);
        NSString *weeksInstringFormat = [NSString stringWithFormat:@"%ld", (long)numberOfWeeks];
        NSString *weeksWithSuffixS = [weeksInstringFormat stringByAppendingString:@"w"];
        return weeksWithSuffixS;
    }
    return @"";
}


#pragma mark - navigation bar buttons

- (void)createNavLeftButton
{
    UIButton *navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
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

- (void)backButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark
#pragma mark - keyBoard

- (void)dismissKeyboard
{
    
    
    /**
     *  here we are changing the position of view to (0,0) by giving view x,y postions to zero.
     */
    [UIView animateWithDuration:0
                     animations:^{
                          self.textFieldSuperViewBottomConstraint.constant = 0;
                          [self.commentTextView resignFirstResponder];
                         //[self.view layoutIfNeeded];
                     }];
 }

- (void)keyboardWillShown:(NSNotification*)notification {
    // Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //Given size may not account for screen rotation
    keyboardHeight = MIN(keyboardSize.height,keyboardSize.width);
    [self viewMoveUp];
}

-(void)viewMoveUp {
    //moving view position based on keyBoard height and tabBar(this viewController is coming from tabBar).
    self.textFieldSuperViewBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.4
                     animations:^{
                            self.textFieldSuperViewBottomConstraint.constant = keyboardHeight;
                            [self.view layoutIfNeeded];
                     }];
//    if (self.commentsTableViewOutlet.contentSize.height > self.commentsTableViewOutlet.frame.size.height) {
//        CGPoint newPosition = CGPointMake(0, tableviewCurrentYoffset - keyboardHeight  );
//        [self.commentsTableViewOutlet setContentOffset:newPosition animated:YES];
//    }
}

- (IBAction)sendButtonAction:(id)sender {
    
    [userSuggestionArray removeAllObjects];
    [self.commentsTableViewOutlet reloadData];
    self.commentsTableViewOutlet.hidden = NO;
    
    
    
    if ([self.sendButtonOutlet.titleLabel.text isEqualToString:@"Post"]) {
        if (self.commentTextView.text.length) {
            [self commentOnPost:self.commentTextView.text];
            self.commentTextView.text = @"";
            [self.sendButtonOutlet setEnabled:NO];
            self.textViewSuperViewHeightConstraint.constant = 54;
        }
    }
    else
        NSLog(@"Send direct message service");
}

-(void)viewDidDisappear:(BOOL)animated {
    [self setHidesBottomBarWhenPushed:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [self setHidesBottomBarWhenPushed:NO];
}


- (IBAction)directButtonAction:(id)sender {
    
//    UIButton *button = (UIButton *)sender;
//    
//    if (button.selected) {
//        button.selected = NO;
//        
//        self.commentTextField.text = @"";
//        [self.sendButtonOutlet setTitle:@"Post" forState:UIControlStateNormal];
//        [self.sendButtonOutlet setTitle:@"Post" forState:UIControlStateSelected];
//    }
//    else
//    {
//        button.selected = YES;
//        
//        self.commentTextField.text = @"@";
//        [self.sendButtonOutlet setTitle:@"Send" forState:UIControlStateNormal];
//        [self.sendButtonOutlet setTitle:@"Send" forState:UIControlStateSelected];
//    }

}

/*----------------------------------------*/
#pragma mark
#pragma mark - WebServiceDelegate
/*----------------------------------------*/

//service request

-(void)commentOnPost :(NSString *)comment
{
    NSArray * words = [self.commentTextView.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSMutableArray *WordsForHashTags = [NSMutableArray new];
    for (NSString * word in words){
        if ([word length] > 1 && [word characterAtIndex:0] == '#'){
            NSString * editedWord = [word substringFromIndex:1];
            [WordsForHashTags addObject:editedWord];
        }
    }
    
    NSString *hashTagsString = [[WordsForHashTags valueForKey:@"description"] componentsJoinedByString:@","];
    NSString *hashTagsInLowerCase = [hashTagsString lowercaseString];
    
    
    
    NSDictionary *requestDict = @{
                                  mauthToken:flStrForObj([Helper userToken]),
                                  mcomment:flStrForObj(comment),
                                  mpostid:flStrForObj(self.postId),
                                  mtype:_postType,
                                  mhashTags:flStrForObj(hashTagsInLowerCase),
                                  };
    [WebServiceHandler commentOnPost:requestDict andDelegate:self];
}

-(void)getPostComments :(NSInteger )offse
{
    NSDictionary *requestDict = @{
                                  mauthToken:flStrForObj([Helper userToken]),
                                  mpostid:flStrForObj(self.postId),
                                  moffset:flStrForObj([NSNumber numberWithInteger:index*20]),
                                  mlimit:flStrForObj([NSNumber numberWithInteger:20])
                                  };
    
    [WebServiceHandler getCommentsOnPost:requestDict andDelegate:self];
}

//-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if([text isEqualToString:@"\n"])
//        [textView resignFirstResponder];
//    return YES;
//}

-(void)getSomeComments :(NSInteger )offse
{
    NSDictionary *requestDict = @{
                                  mauthToken:flStrForObj([Helper userToken]),
                                  mpostid:flStrForObj(self.postId),
                                  moffset:flStrForObj([NSNumber numberWithInteger:0]),
                                  mlimit:flStrForObj([NSNumber numberWithInteger:20*offse])
                                  };
    [WebServiceHandler getCommentsOnPost:requestDict andDelegate:self];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        if (PostsAreMoreThanTwenty ) {
            // creating custom header view
            if (needToShowHeaderForMorePosts) {
                customizedTableviewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
                customizedTableviewHeader.backgroundColor =[UIColor whiteColor];
                
                UIView *boarderLine = [[UIView alloc] initWithFrame:CGRectMake( 50,customizedTableviewHeader.frame.size.height - 1,tableView.frame.size.width,1)];
                boarderLine.backgroundColor =[UIColor colorWithRed:0.5003 green:0.5002 blue:0.5003 alpha:0.3];
                
                /* Create custom view to display section header... */
                
                //creating user name label
                UILabel *messageLabel = [[UILabel alloc] init];
                messageLabel.text = @"Load More comments";
                [messageLabel setFont:[UIFont fontWithName:RobotoMedium size:14]];
                messageLabel.textColor =[UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0];
                messageLabel.frame=CGRectMake(0, 0, self.view.frame.size.width , 40);
                messageLabel.textAlignment = NSTextAlignmentCenter;
                messageLabel.backgroundColor = [UIColor clearColor];
                
                //creating  total  header  as button
                UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [headerButton addTarget:self
                                 action:@selector(headerButtonClicked:)
                       forControlEvents:UIControlEventTouchUpInside];
                headerButton.backgroundColor =[UIColor clearColor];
                headerButton.frame = CGRectMake(0, 0, tableView.frame.size.width,40);
                
                // adding  headerButton,UserImageView,timeLabel,UserNamelabel to the customized tableView  Section Header.
                
                [customizedTableviewHeader addSubview:headerButton];
                [customizedTableviewHeader addSubview:messageLabel];
                [customizedTableviewHeader addSubview:boarderLine];
                return customizedTableviewHeader;
            }
            else {
                UIView *emptyview= [[UIView alloc] init];
                emptyview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
                return emptyview;
            }
        }
        else{
            UIView *emptyview= [[UIView alloc] init];
            emptyview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
            return emptyview;
        }
    }
        else {
            UIView *emptyview= [[UIView alloc] init];
            emptyview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 0)];
            return emptyview;
        }
}

-(CGFloat )tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        if (PostsAreMoreThanTwenty && needToShowHeaderForMorePosts) {
            return 40.0;
        }
        else {
            return 0;
        }
    }
    else {
        return 0;
    }
}

-(void)headerButtonClicked:(id)sender {
    UIView *footerView = [[UIView alloc] init];
    [footerView setBackgroundColor:[UIColor whiteColor]];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(self.view.frame.size.width/2-20,0, 40, 40.0);
    [footerView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    NSArray *subviewsfff = [[sender superview] subviews];
    [subviewsfff[0] removeFromSuperview];
    [subviewsfff[1] removeFromSuperview];
    [customizedTableviewHeader addSubview:footerView];

     index++;
    [self getPostComments:index];
}

//handling response.

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    
    [[ProgressIndicator sharedInstance] hideProgressIndicator];
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSMutableDictionary *responseDict = (NSMutableDictionary *)response;
    if (requestType == RequestTypePostComment ) {
     customizedTableviewHeader.backgroundColor =[UIColor whiteColor];
        switch ([responseDict[@"code"] integerValue]) {
            case 200:
            {
                
               [responseDict setObject:[NSString stringWithFormat:@"%ld",(long)self.selectedCellIs]  forKey:@"selectedCell"];
                
                [responseArray addObject: @{
                                            @"commentBody" :responseDict[@"data"][0][@"commentData"][0][@"commentBody"],
                                            @"commentedOn": responseDict[@"data"][0][@"commentData"][0][@"commentedOn"],
                                            @"username":flStrForObj([Helper userName]),
                                            @"commentNodeId":responseDict[@"data"][0][@"commentData"][0][@"commentId"],
                                            @"profilePicUrl":responseDict[@"data"][0][@"profilePicUrl"]
                                            }];
                [self addnewRow:responseArray.count-1];

                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"passingUpdatedComments" object:[NSMutableDictionary dictionaryWithObject:responseDict forKey:@"newCommentsData"]];
            }
                break;
            default:
                break;
        }
    }
    else if (requestType == RequestTypedeleteComments ) {
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200:
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"passingUpdatedComments" object:[NSMutableDictionary dictionaryWithObject:responseDict forKey:@"newCommentsData"]];
            }
                break;
            default:
                break;
        }
    }
    else if (requestType == RequestTypeGetTagFriendsSuggestion) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                userSuggestionArray = responseDict[@"data"];
                if (userSuggestionArray.count > 0) {
                    self.commentsTableViewOutlet.hidden =  YES;
                    [self.userNameSuggestionView reloadData];
                   
                } else {
                    self.commentsTableViewOutlet.hidden = NO;
                    [self.userNameSuggestionView reloadData];
                }
            }
                break;
            case 19031: {
                
            }
            case 19032: {
               
            }
        }
    }
    
    else if (requestType == RequestTypeGetCommentsOnPost) {
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                NSArray *newData = responseDict[@"result"];
                if (index >= 1) {
                    responseArray=[[[responseArray reverseObjectEnumerator] allObjects] mutableCopy];
                    [responseArray addObjectsFromArray:newData];
                    responseArray=[[[responseArray reverseObjectEnumerator] allObjects] mutableCopy];
                }
                else {
                    newData=[[[newData reverseObjectEnumerator] allObjects] mutableCopy];
                    [responseArray addObjectsFromArray:newData];
                }
                
                if([responseDict[@"result"] count]) {
                    
                    if ([responseDict[@"result"] count] < 19) {
                        PostsAreMoreThanTwenty =NO;
                    }
                    else {
                        PostsAreMoreThanTwenty =YES;
                    }
                    
                    //[self.commentsTableViewOutlet reloadData];
                    
                    if (onlyFirstTimeMoveToBottom) {
                        onlyFirstTimeMoveToBottom =  NO;
                        self.timerIvar  =   [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(changeThePositionOfTableview) userInfo:nil repeats:YES];
                        [self.commentTextView becomeFirstResponder];
                        dataAvailable = YES;
                        [self.commentsTableViewOutlet reloadData];
                    }
                    else {
                          [self.commentsTableViewOutlet reloadData];
                    }
                }
                else {
                    NSLog(@"no posts found **********");
                    needToShowHeaderForMorePosts = NO;
                     [self.commentsTableViewOutlet reloadData];
                }
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
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)addnewRow:(NSInteger )atIndex {
    //here adding new data (single comment details )to old data.
    [_commentsTableViewOutlet beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:atIndex inSection:1];
    [self.commentsTableViewOutlet insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [_commentsTableViewOutlet endUpdates];
  
    if (self.commentsTableViewOutlet.contentSize.height > self.commentsTableViewOutlet.frame.size.height) {
        
        CGRect frame = [self.commentsTableViewOutlet rectForRowAtIndexPath:indexPath];
        NSLog(@"row height : %f", frame.size.height);
        
        
        CGPoint newPosition = CGPointMake(0, self.commentsTableViewOutlet.contentSize.height - self.commentsTableViewOutlet.frame.size.height + frame.size.height );
        [self.commentsTableViewOutlet setContentOffset:newPosition animated:YES];
    }
}




/*-----------------------------------------------------------------------------*/
#pragma
#pragma mark - Handling Hashtags,URL and UserNames.
/*------------------------------------------------------------------------------*/

-(void)handlingHashTags:(id)sender {
    
    HomeViewCommentsTableViewCell *receivedCell = (HomeViewCommentsTableViewCell *)sender;
    receivedCell.commentLabelOutlet.userInteractionEnabled = YES;
    
     //Attach a block to be called when the user taps a hashtag.
    receivedCell.commentLabelOutlet.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        if ([string isEqualToString:@"#"]) {
            //nothing to do
        }
        else {
            HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
            newView.navTittle = string;
            [self.navigationController pushViewController:newView animated:NO];
        }
    };
}

-(void)handlinguserName:(id)sender {
    
    HomeViewCommentsTableViewCell *receivedCell = (HomeViewCommentsTableViewCell *)sender;
    // Attach a block to be called when the user taps a user handle.
    
    receivedCell.commentLabelOutlet.userHandleLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        
        if ([string isEqualToString:@"@"]) {
            //nothing to do
        }
        else {
          [self goToProfileOfTheUserName:string];
        }
    };
}

-(void)goToProfileOfTheUserName:(NSString *)string {
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    
    //removing @ from string.
    NSString *stringWithoutspecialCharacter;
    if([string hasPrefix:@"@"]) {
        stringWithoutspecialCharacter = [string substringFromIndex:1];
    }
    else {
        stringWithoutspecialCharacter = string;
    }
    
    
    newView.checkProfileOfUserNmae = stringWithoutspecialCharacter;
    newView.checkingFriendsProfile = YES;
    [self.navigationController pushViewController:newView animated:NO];
}


-(void)handlingURLLink :(id)sender {
    HomeViewCommentsTableViewCell *receivedCell = (HomeViewCommentsTableViewCell *)sender;
    // Attach a block to be called when the user taps a URL
    receivedCell.commentLabelOutlet.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        NSLog(@"URL tapped %@", string);
    };
}


/*-------------------------------------------------------------*/
#pragma
#pragma mark - ScrollView Delegate(For Update Posts).(PAGING)
/*-------------------------------------------------------------*/


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
//     CGFloat currentOffset = scrollView.contentOffset.y;
//    
//    // tag 1 for tableview is tableview`s scrollview.
//    if (scrollView.tag == 1 ) {
//        tableviewCurrentYoffset = currentOffset + CGRectGetHeight(self.commentsTableViewOutlet.frame);
//    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat currentOffset = scrollView.contentOffset.y;
//    
// 
//    if (scrollView.tag == 1 ) {
//        tableviewCurrentYoffset = currentOffset + CGRectGetHeight(self.commentsTableViewOutlet.frame);
//    }
}

- (IBAction)userNameButtonAction:(id)sender {
    
    UIButton *selectedButton = (UIButton *)sender;
    NSString *nameOfUser = selectedButton.titleLabel.text;
    [self goToProfileOfTheUserName:nameOfUser];
}

@end
