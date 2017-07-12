//
//  PhotoDetailViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/14/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGTagPeopleViewController.h"
#import "PGShareViewController.h"
#import "TagPeopleTableViewCell.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "UIView+draggable.h"
#import "TinderGenericUtility.h"
#import "UIImageView+WebCache.h"
#import "UIImage+GIF.h"
#import "FontDetailsClass.h"
#import "Helper.h"

@interface PGTagPeopleViewController ()<UISearchBarDelegate,UIGestureRecognizerDelegate,WebServiceHandlerDelegate> {
    BOOL buttonFirstTimedTapped;
    int count;
    CGPoint touchPoint;
   
    UITapGestureRecognizer *tapForFindingLocation;
    TagPeopleTableViewCell *cell;
    
    NSDictionary *tagFriendsData;
    
    NSMutableArray *arrayOfUserNames;
    NSMutableArray *userNmaeresponseData;
    
  
    NSMutableArray *arrayOfFullNames;
    NSMutableArray *arrayOfProfilePicUrl;
    
    
    
    
    UIView *viewForUserNameAndCloseButton;
    UIView *viewForBGI;
    UILabel *nameOfUserLabel;
    UIButton *buttonForClose;
    UIImageView *bGImage;
}

@end

@implementation PGTagPeopleViewController

/*---------------------------------------------------*/
#pragma mark
#pragma mark - viewcontroller
/*---------------------------------------------------*/

- (void)viewDidLoad {
    [super viewDidLoad];
    //nav bar customization.
    [self  setUpNavigationBar];
    //searchbar(searchbartextfield) customization.
    [self  customizedSearchBarTextField];
    [self.viewForImage addSubview:self.tagFriendsButtonOutlet];
    //creating tapgesture for image.(to show searchbar to select friend.)
    [self  creatingTapGestureForTagFriends];
    
    count = 1;
    self.dragToMoveMessageLabel.hidden =YES;
   
    if (!_arrayOfTaggedFriends) {
        _arrayOfTaggedFriends = [[NSMutableArray alloc] init];
        _arrayOfTaggedFriendsPositions =[[NSMutableArray alloc] init];
    }
}

-(void)viewDidAppear:(BOOL)animated {
     [self createButtons];
}


-(void)createButtons {
    for (int i=0; i< self.arrayOfTaggedFriends.count; i++) {
        
        self.dragToMoveMessageLabel.hidden =NO;
        _tagFriendsButtonOutlet.hidden = NO;
        
        //creating a view and adding label and image as subviews.
        UIView *backgroundView = [[UIView alloc] init];
        UILabel *tagNameLabel = [[UILabel alloc] init];

        //alloting text for the label and color.
        tagNameLabel.text = self.arrayOfTaggedFriends[i];
        tagNameLabel.textAlignment = NSTextAlignmentCenter;
        tagNameLabel.textColor = [UIColor whiteColor];
        tagNameLabel.font = [UIFont fontWithName:RobotoRegular size:15];
        [tagNameLabel sizeToFit];
        tagNameLabel.tag = i;
        //
        //creating tapgesture for label to handle  if user taps label.
        //
        [self createTapGesture:tagNameLabel];
        tagNameLabel.userInteractionEnabled = YES;
        
        
        //image for view.
        UIImageView *backgroundImageView = [[UIImageView alloc] init];
        backgroundImageView.image = [UIImage imageNamed:@"tag_people_tittle_btn"];
        
        //setting frame for label.
        CGRect taglabelFrame = tagNameLabel.frame;
        taglabelFrame.origin.x = 5;
        taglabelFrame.origin.y = 2;
        taglabelFrame.size.height = 40;
        tagNameLabel.frame = taglabelFrame;
        
        NSValue *val = [_arrayOfTaggedFriendsPositions objectAtIndex:i];
        CGPoint createButtonAt = [val CGPointValue];
        
        
        
        //setting frame for view and image view.
        backgroundView.frame = CGRectMake(createButtonAt.x,createButtonAt.y,tagNameLabel.frame.size.width+ 10,35);

        if (createButtonAt.x + backgroundView.frame.size.width > self.tagImageViewOutlet.frame.size.width -20 || createButtonAt.y + backgroundView.frame.size.height > self.tagImageViewOutlet.frame.size.height -20) {
            
            if (createButtonAt.x + backgroundView.frame.size.width > self.tagImageViewOutlet.frame.size.width - 20 && createButtonAt.y + backgroundView.frame.size.height > self.tagImageViewOutlet.frame.size.height - 20) {
                [backgroundView setFrame:CGRectMake(createButtonAt.x - ((createButtonAt.x + backgroundView.frame.size.width) - self.tagImageViewOutlet.frame.size.width +20),createButtonAt.y - ((createButtonAt.y + backgroundView.frame.size.height) - self.tagImageViewOutlet.frame.size.height+40), tagNameLabel.frame.size.width+ 10, 35)];
                
                //setting frame for label.
                CGRect taglabelFrame = tagNameLabel.frame;
                taglabelFrame.origin.x = 5;
                taglabelFrame.origin.y = 2;
                taglabelFrame.size.height = 40;
                tagNameLabel.frame = taglabelFrame;
                
                NSLog(@"custom button is out of view along both horizontal and vertical");
            }
            else {
                NSLog(@"custom button is out of view");
                if (createButtonAt.x + backgroundView.frame.size.width > self.tagImageViewOutlet.frame.size.width - 20) {
                    NSLog(@"custom button is out of view along horizontal");
                    [backgroundView setFrame:CGRectMake(createButtonAt.x - ((createButtonAt.x + backgroundView.frame.size.width) - self.tagImageViewOutlet.frame.size.width +40 ),createButtonAt.y, tagNameLabel.frame.size.width+ 10, 35)];
                    
                    CGRect taglabelFrame = tagNameLabel.frame;
                    taglabelFrame.origin.x = 5;
                    taglabelFrame.origin.y = 2;
                    taglabelFrame.size.height = 40;
                    tagNameLabel.frame = taglabelFrame;
                }
                else {
                    NSLog(@"custom button is aligned properly along horizontal");
                }
                
                if(createButtonAt.y + backgroundView.frame.size.height > self.tagImageViewOutlet.frame.size.height -20) {
                    NSLog(@"custom button is out of view along vertical");
                    //[customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
                    
                    [backgroundView setFrame:CGRectMake(createButtonAt.x,createButtonAt.y - ((createButtonAt.y + backgroundView.frame.size.height) - self.tagImageViewOutlet.frame.size.height+20), tagNameLabel.frame.size.width+ 10, 35)];
                    
                    //setting frame for label.
                    CGRect taglabelFrame = tagNameLabel.frame;
                    taglabelFrame.origin.x = 5;
                    taglabelFrame.origin.y = 2;
                    taglabelFrame.size.height = 40;
                    tagNameLabel.frame = taglabelFrame;
                }
                else {
                    NSLog(@"custom button is aligned properly along vertical");
                }
            }
        }
        else {
            backgroundView.frame = CGRectMake(createButtonAt.x,createButtonAt.y,tagNameLabel.frame.size.width+ 10, 35);
        }

        
        
        backgroundImageView.frame = CGRectMake(0,0,tagNameLabel.frame.size.width + 10, backgroundView.frame.size.height);
        
        //adding imageview to view as subview.
        [backgroundView addSubview:backgroundImageView];
        
        //adding view on main imageview.
        [self.tagImageViewOutlet addSubview:backgroundView];
        [backgroundView addSubview:tagNameLabel];
        [backgroundView bringSubviewToFront:tagNameLabel];
        
        //setting view as movable.
        [backgroundView enableDragging];
        
        //specifying view will can movable upto the imageview frame.
        backgroundView.cagingArea = CGRectMake(0, 0, self.tagImageViewOutlet.frame.size.width -15, self.tagImageViewOutlet.frame.size.height-30);
        
        //hiding searchbar view and unhiding superview of imageview.
        self.TagPeopleSearchView.hidden = YES;
        self.TagPeopleViewOutlet.hidden = NO;
        
        //hiding navigationbar.
        self.navigationController.navigationBarHidden = NO;
        
        //hiding search bar.
        [self.searchBarForTag resignFirstResponder];
        
        //hiding tableview.
        self.tagPeopleTableView.hidden = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    buttonFirstTimedTapped= YES;

    //to get friends or to get hashtag suggestions we need to pass token so getting token details(it may be from registration or login).
   
    
    
    self.TagPeopleSearchView.hidden = YES;
    self.TagPeopleViewOutlet.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
}

-(void)dragEnded {
    
}

/*---------------------------------------------------*/
#pragma mark
#pragma mark - Methods defination in vieDidLoad.
/*---------------------------------------------------*/

-(void)setUpNavigationBar {
    //setting nav bar background color.
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9753 green:0.9753 blue:0.9753 alpha:1.0];
    //hiding nav bar backbutton.
    [self.navigationItem setHidesBackButton:YES];
    //setting imageview with selected image.
    _tagImageViewOutlet.image =_tagPeopleImage;
   //seeting nav bar tittle as TAG PEOPLE
    self.navigationItem.title = @"Tag People";
    //calling createNavRightButton method to create nav bar right button.
    [self createNavRightButton];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)customizedSearchBarTextField {
    //customizing search bar(background color and textcolor and plceholder label color).
    UITextField *txfSearchField = [self.searchBarForTag valueForKey:@"_searchField"];
    [txfSearchField setBackgroundColor:[UIColor colorWithRed:0.859 green:0.8634 blue:0.8732 alpha:1.0]];
    [txfSearchField setLeftViewMode:UITextFieldViewModeNever];
    [txfSearchField setRightViewMode:UITextFieldViewModeNever];
    txfSearchField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [txfSearchField setPlaceholder:@"Search for a person"];
    [txfSearchField setValue:[UIColor grayColor]
                  forKeyPath:@"_placeholderLabel.textColor"];
    [txfSearchField setTextColor:[UIColor blackColor]];
    [txfSearchField setBorderStyle:UITextBorderStyleRoundedRect];
    txfSearchField.layer.borderColor = [UIColor blackColor].CGColor;
    txfSearchField.clearButtonMode=UITextFieldViewModeNever;
    [self.searchBarForTag setTintColor:[UIColor blackColor]];
    self.searchBarForTag.delegate = self;
}

-(void)creatingTapGestureForTagFriends {
    //creating tapgesture for image to show searchbar(to tag friends).
    tapForFindingLocation = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapForFindingLocation.numberOfTapsRequired = 1;
    tapForFindingLocation.delegate = self;
    _tagImageViewOutlet.userInteractionEnabled = YES;
    [_tagImageViewOutlet addGestureRecognizer:tapForFindingLocation];
}

-(void)handleTapGesture:(id)sender {
    //if user taps on image then this method will call.(here we are getting the user tapped location to create button.)
    touchPoint = [tapForFindingLocation locationInView:_tagImageViewOutlet];
    self.TagPeopleSearchView.hidden = NO;
    self.TagPeopleViewOutlet.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    [self.searchBarForTag becomeFirstResponder];
    self.tagPeopleTableView.hidden = NO;
}

/*---------------------------------------------------*/
#pragma mark
#pragma mark - movableButtonAction
/*---------------------------------------------------*/

- (IBAction)draggedOut: (id)sender withEvent: (UIEvent *) event {
    UIButton *selected = (UIButton *)sender;
   selected.center = [[[event allTouches] anyObject] locationInView:self.viewForImage];
}

/*---------------------------------------------------*/
#pragma mark
#pragma mark - navigation bar  buttons
/*---------------------------------------------------*/

- (void)createNavRightButton {
    //creating navigation bar button.
    UIButton *navDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navDoneButton setTitle:@"Done"
                   forState:UIControlStateNormal];
    [navDoneButton setTitleColor:[UIColor colorWithRed:0.2196 green:0.5922 blue:0.9412 alpha:1.0]
                        forState:UIControlStateNormal];
    [navDoneButton setTitleColor:[UIColor colorWithRed:0.2196 green:0.5922 blue:0.9412 alpha:1.0]
                        forState:UIControlStateHighlighted];
    navDoneButton.titleLabel.font = [UIFont fontWithName:RobotoMedium size:16];
    
   
    
    [navDoneButton setFrame:CGRectMake(0,0,50,30)];
    //craeting button action for navigation bar button.
    [navDoneButton addTarget:self action:@selector(doneButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navDoneButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

- (void) doneButtonAction:(UIButton *)sender {
    //navbar right button action.
    

   [_delegate sendDataToA:_arrayOfTaggedFriends andPositions:_arrayOfTaggedFriendsPositions];
    
   [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickForTagPeopleButtonAction:(id)sender {
    NSLog(@"Tapped tagButtonTapped");
}

/*---------------------------------------------------*/
#pragma mark - Table View Data source and delegates.
/*---------------------------------------------------*/

// table view delegate and data sources methods.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arrayOfUserNames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellID";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TagPeopleTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    //populating data in tableViewCell.
    
    
    
    //userNameLabel is fullname and userIdLabelOutlet is usename.
    
    cell.userNameLabel.text = arrayOfFullNames[indexPath.row];
    cell.userIdLabelOutlet.text =arrayOfUserNames[indexPath.row];
    //creating roundimage.
    
    [ cell.userImageViewoutlet  sd_setImageWithURL:[NSURL URLWithString:[arrayOfProfilePicUrl objectAtIndex:indexPath.row]]
                             placeholderImage:[UIImage imageNamed:@"defaultpp"]];
    [cell layoutIfNeeded];
    cell.userImageViewoutlet.layer.cornerRadius = ( cell.userImageViewoutlet.frame.size.width)/2;
    cell.userImageViewoutlet.clipsToBounds = YES;
    cell.userImageViewoutlet.layer.masksToBounds = YES;
    
    return cell;
}

/*--------------------------------------------------------------------------*/
#pragma mark - creating  customized tag friend button
/*--------------------------------------------------------------------------*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat TagedNamesViewXposition;
    CGFloat TagedNamesViewYposition;
    
    TagedNamesViewXposition = touchPoint.x ;
    TagedNamesViewYposition = touchPoint.y;
    
    //checking if the selected username is there or not and if the selected element is present we need to remove old one and update the loaction(touchpoint where user wants to add the name.)
    BOOL isTheNameAlreadyAdded = [_arrayOfTaggedFriends containsObject:[arrayOfUserNames objectAtIndex:indexPath.row]];
    
    //if username is already added then we need to remove the previous one.
    if(isTheNameAlreadyAdded) {
        
        NSUInteger indexOfNameAddedAlready = [_arrayOfTaggedFriends indexOfObject:[arrayOfUserNames objectAtIndex:indexPath.row]];
        [self.arrayOfTaggedFriends removeObjectAtIndex:indexOfNameAddedAlready];
        [_arrayOfTaggedFriendsPositions removeObjectAtIndex:indexOfNameAddedAlready];
        
        NSArray *numberOfTaggedPersons =  [self.tagImageViewOutlet subviews];
        
        
        
        //check already name is selected or not
        
        for (int i =0 ; i<numberOfTaggedPersons.count; i++) {
            //get which name is registered.
            
            NSArray *listOfLabels = [[self.tagImageViewOutlet subviews][i] subviews];
            UILabel *labelAlreadyExists = (UILabel *)listOfLabels[1];
            
            if ([labelAlreadyExists.text isEqualToString:arrayOfUserNames[indexPath.row]]) {
               
                //remove particular already existed sUbview.
                UIView *alreadyExistedView = (UIView *)[self.tagImageViewOutlet subviews][i];
                [alreadyExistedView removeFromSuperview];
                break;
            }
        }
    }
   
    NSString *str = [arrayOfUserNames objectAtIndex:indexPath.row];
    [self creatingTagView:str tag:count touchPoint:touchPoint];
    count++;
    
    
    
    self.searchBarForTag.text =@"";
}


-(void)creatingTagView:(NSString *) tagText tag:(NSInteger) tagNumber touchPoint:(CGPoint) position {

    //creating a view and adding label and image as subviews.
    
    UIView *backgroundView = [[UIView alloc] init];
    UILabel *tagNameLabel = [[UILabel alloc] init];
    
    
    //alloting text for the label and color.
    tagNameLabel.text = tagText;
    tagNameLabel.textAlignment = NSTextAlignmentCenter;
    tagNameLabel.textColor = [UIColor whiteColor];
    tagNameLabel.font = [UIFont fontWithName:RobotoMedium size:15];
    [tagNameLabel sizeToFit];
    tagNameLabel.tag = tagNumber;
    //
    //creating tapgesture for label to handle  if user taps label.
    //
    [self createTapGesture:tagNameLabel];
    tagNameLabel.userInteractionEnabled = YES;
    
    
    //image for view.
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    backgroundImageView.image = [UIImage imageNamed:@"tag_people_tittle_btn"];
    
    backgroundImageView.contentMode = UIViewContentModeRedraw;
    backgroundImageView.clipsToBounds = YES;
    
    
    //setting frame for label.
    CGRect taglabelFrame = tagNameLabel.frame;
    taglabelFrame.origin.x = 5;
    taglabelFrame.origin.y = 2;
    taglabelFrame.size.height = 40;
    tagNameLabel.frame = taglabelFrame;
    
    //setting frame for view and image view.
    backgroundView.frame = CGRectMake(position.x,position.y,tagNameLabel.frame.size.width+ 10, 45);
    
    if (position.x + backgroundView.frame.size.width > self.tagImageViewOutlet.frame.size.width -20 || position.y + backgroundView.frame.size.height > self.tagImageViewOutlet.frame.size.height -20) {
        
        if (position.x + backgroundView.frame.size.width > self.tagImageViewOutlet.frame.size.width - 20 && position.y + backgroundView.frame.size.height > self.tagImageViewOutlet.frame.size.height - 20) {
            [backgroundView setFrame:CGRectMake(position.x - ((position.x + backgroundView.frame.size.width) - self.tagImageViewOutlet.frame.size.width +20),position.y - ((position.y + backgroundView.frame.size.height) - self.tagImageViewOutlet.frame.size.height+40), tagNameLabel.frame.size.width+ 10, 35)];
            
            //setting frame for label.
            CGRect taglabelFrame = tagNameLabel.frame;
            taglabelFrame.origin.x = 5;
            taglabelFrame.origin.y = 2;
            taglabelFrame.size.height = 40;
            tagNameLabel.frame = taglabelFrame;
            
            NSLog(@"custom button is out of view along both horizontal and vertical");
        }
        else {
            NSLog(@"custom button is out of view");
            if (position.x + backgroundView.frame.size.width > self.tagImageViewOutlet.frame.size.width - 20) {
                NSLog(@"custom button is out of view along horizontal");
                [backgroundView setFrame:CGRectMake(position.x - ((position.x + backgroundView.frame.size.width) - self.tagImageViewOutlet.frame.size.width +40 ),position.y, tagNameLabel.frame.size.width+ 10, 35)];
                
                CGRect taglabelFrame = tagNameLabel.frame;
                taglabelFrame.origin.x = 5;
                taglabelFrame.origin.y = 2;
                taglabelFrame.size.height = 40;
                tagNameLabel.frame = taglabelFrame;
            }
            else {
                NSLog(@"custom button is aligned properly along horizontal");
            }
            
            if(position.y + backgroundView.frame.size.height > self.tagImageViewOutlet.frame.size.height -20) {
                NSLog(@"custom button is out of view along vertical");
                //[customButton setFrame:CGRectMake(fromPoint.x,fromPoint.y, stringsize.width + 50, 35)];
                
                [backgroundView setFrame:CGRectMake(position.x,position.y - ((position.y + backgroundView.frame.size.height) - self.tagImageViewOutlet.frame.size.height+20), tagNameLabel.frame.size.width+ 10, 35)];
                
                //setting frame for label.
                CGRect taglabelFrame = tagNameLabel.frame;
                taglabelFrame.origin.x = 5;
                taglabelFrame.origin.y = 2;
                taglabelFrame.size.height = 40;
                tagNameLabel.frame = taglabelFrame;
            }
            else {
                NSLog(@"custom button is aligned properly along vertical");
            }
        }
    }
    else {
       backgroundView.frame = CGRectMake(position.x,position.y,tagNameLabel.frame.size.width+ 10, 35);
    }
    
    backgroundImageView.frame = CGRectMake(0,0,tagNameLabel.frame.size.width + 10, backgroundView.frame.size.height);
    
    //adding imageview to view as subview.
    [backgroundView addSubview:backgroundImageView];
    
    //adding view on main imageview.
    [self.tagImageViewOutlet addSubview:backgroundView];
    [backgroundView addSubview:tagNameLabel];
    [backgroundView bringSubviewToFront:tagNameLabel];
    
    [self addingTaggedFriendsDetails:tagNameLabel.text andLoaction:position];
    
    //setting view as movable.
   
    [backgroundView enableDragging];
    
    [backgroundView.draggingEndedBlock enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
        [self dragEnded];
    }];
    
    
    
    //specifying view will can movable upto the imageview frame.
    backgroundView.cagingArea = CGRectMake(0, 0, self.tagImageViewOutlet.frame.size.width -15, self.tagImageViewOutlet.frame.size.height-30);
    
    //hiding searchbar view and unhiding superview of imageview.
    self.TagPeopleSearchView.hidden = YES;
    self.TagPeopleViewOutlet.hidden = NO;
    
    _tagFriendsButtonOutlet.hidden = NO;
    self.dragToMoveMessageLabel.hidden =NO;
    
    //hiding navigationbar.
    self.navigationController.navigationBarHidden = NO;
    
    //hiding search bar.
    [self.searchBarForTag resignFirstResponder];
    
    //hiding tableview.
    self.tagPeopleTableView.hidden = YES;
}



-(void)createTapGesture:(UILabel *)tagLabel {
    //creating and adding tapgesture for created view(nameofthe tagged person with close button).
    UITapGestureRecognizer *tapForRemoveTaggedPerson = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapRemoveTaggedPerson:)];
    tapForRemoveTaggedPerson.numberOfTapsRequired = 1;
    tapForRemoveTaggedPerson.delegate = self;
    [tagLabel addGestureRecognizer:tapForRemoveTaggedPerson];
}

-(void)createTapGesture {
    //creating and adding tapgesture for created view(nameofthe tagged person with close button).
    UITapGestureRecognizer *tapForRemoveTaggedPerson = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapRemoveTaggedPerson:)];
    tapForRemoveTaggedPerson.numberOfTapsRequired = 1;
    tapForRemoveTaggedPerson.delegate = self;
    [viewForUserNameAndCloseButton addGestureRecognizer:tapForRemoveTaggedPerson];
}

-(void)handletapRemoveTaggedPerson:(id)sender {
    //if the user taps first time on tagged person then it will show close button and if the user clicks on second time then close button will hide.
    
    UILabel *label =(UILabel *)[sender view];
    UIView *backgroundView = (UIView *)[label superview];
    UIImageView *backgroundImageView = [(UIImageView *)[label superview] subviews][0];
    
    //count of view(superview of label) is 2 if user dont tap on label(only label and image)
    //if user taps on first time then close button also present in view(superview of label)
    //so count incremented to 3.
    
    if ([[[label superview] subviews] count] == 2) {
        UIButton *closeButton = [[UIButton alloc] init];
        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton addTarget:self
                           action:@selector(removeButton:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setImage:[UIImage imageNamed:@"tag_cross_icon_on"]  forState:UIControlStateNormal];
        closeButton.frame = CGRectMake(label.frame.size.width+10,15,15,15);
        CGRect backgroundViewFrame = backgroundView.frame;
        backgroundViewFrame.size.width = 5 +label.frame.size.width + 10 + closeButton.frame.size.width;
        backgroundView.frame = backgroundViewFrame;
        CGRect backgroundImageViewFrame = backgroundImageView.frame;
        backgroundImageViewFrame.size.width = 5 +label.frame.size.width + 10 + closeButton.frame.size.width;
        backgroundImageView.frame = backgroundImageViewFrame;
        [backgroundView addSubview:closeButton];
    }
    else {
        UIButton *closeButton = (UIButton *)[[[label superview] subviews] lastObject];
        [closeButton removeFromSuperview];
        CGRect backgroundViewFrame = backgroundView.frame;
        backgroundViewFrame.size.width = label.frame.size.width + 10 ;
        backgroundView.frame = backgroundViewFrame;
        CGRect backgroundImageViewFrame = backgroundImageView.frame;
        backgroundImageViewFrame.size.width = label.frame.size.width + 10;
        backgroundImageView.frame = backgroundImageViewFrame;
    }
}

-(void)removeButton:(id)sender {
    //removing total customized view.
    UILabel *removingUserDetailsLabel =  [(UILabel *)[sender superview] subviews][1];
    NSString *nameOfTheUserRemoving = removingUserDetailsLabel.text;
    
    NSUInteger index;
    index = [_arrayOfTaggedFriends indexOfObject:nameOfTheUserRemoving];
    
    [_arrayOfTaggedFriends removeObjectAtIndex:index];
    [_arrayOfTaggedFriendsPositions removeObjectAtIndex:index];
    
    [UIView transitionWithView:self.tagImageViewOutlet
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [[sender superview] removeFromSuperview];
                        [self.view layoutIfNeeded];
                    }
                    completion:NULL];
    
    
    if (_arrayOfTaggedFriends.count >0) {
          _tagFriendsButtonOutlet.hidden = NO;
        self.dragToMoveMessageLabel.hidden =NO;
    }
    else {
          _tagFriendsButtonOutlet.hidden = YES;
        self.dragToMoveMessageLabel.hidden =YES;
    }
}

-(void)addingTaggedFriendsDetails :(NSString *)selectedFriend  andLoaction:(CGPoint )position{
    [_arrayOfTaggedFriends addObject:selectedFriend];
    [_arrayOfTaggedFriendsPositions addObject:[NSValue valueWithCGPoint:position]];
}

/*--------------------------------------*/
#pragma mark -searchBarDelegates.
/*--------------------------------------*/

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBarForTag resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.TagPeopleSearchView.hidden = YES;
    self.TagPeopleViewOutlet.hidden = NO;
    self.navigationController.navigationBarHidden = NO;
    [self.searchBarForTag resignFirstResponder];
    self.tagPeopleTableView.hidden = YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
   
    if (searchText.length == 0) {
        [arrayOfUserNames removeAllObjects];
        [self.tagPeopleTableView reloadData];
    }
    else {
        NSDictionary *requestDict = @{
                                      muserTosearch :searchText,
                                      mauthToken :[Helper userToken],
                                      };
        [WebServiceHandler getUserNameSuggestion:requestDict andDelegate:self];
    }
}

//handling response
/*----------------------------------*/
#pragma mark -
#pragma mark - WebServiceDelegate
/*----------------------------------*/

- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    // [[ProgressIndicator sharedInstance] hideProgressIndicator];
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];//Send via SMS
        [alert show];
        return;
    }
    NSDictionary *responseDict = (NSDictionary*)response;
    if (requestType == RequestTypeGetTagFriendsSuggestion ) {
        
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                tagFriendsData =responseDict;
                [self handlingSuccessResponseOfUserNamesSuggestionapi];
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
                                          otherButtonTitles:nil,nil];//Send via SMS
    [alert show];
}

-(void)handlingSuccessResponseOfUserNamesSuggestionapi {
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
            NSString *profilePicUrl = flStrForObj(userNmaeresponseData[i][@"profilePicUrl"]);
            
            [arrayOfFullNames addObject:fullName];
            [arrayOfProfilePicUrl addObject:profilePicUrl];
            
            
            //adding names and count value to the array.
            [arrayOfUserNames addObject:userName];
    }
    [self.tagPeopleTableView reloadData];
}

- (IBAction)tagPeopleButtonAction:(id)sender {
//    NSArray *subViews = self.tagImageViewOutlet.subviews;
//    
//    if (self.tagFriendsButtonOutlet.selected) {
//        self.tagFriendsButtonOutlet.selected = NO;
//        for (int i =0; i<subViews.count;i++ ) {
//            UIView *singleSubView = (UIView *)subViews[i];
//            [singleSubView setHidden:NO];
//        }
//    }
//    else {
//        
//        //hide all tag  view
//        self.tagFriendsButtonOutlet.selected = YES;
//        for (int i =0; i<subViews.count;i++ ) {
//            UIView *singleSubView = (UIView *)subViews[i];
//            [singleSubView setHidden:YES];
//        }
//    }

    //    if user taps on image then this method will call.(here we are getting the user tapped location to create button.)
    
    touchPoint = CGPointMake(self.tagFriendsButtonOutlet.frame.origin.x,self.tagFriendsButtonOutlet.frame.origin.y);
    self.TagPeopleSearchView.hidden = NO;
    self.TagPeopleViewOutlet.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
    [self.searchBarForTag becomeFirstResponder];
    self.tagPeopleTableView.hidden = NO;
    
}

@end
