//
//  AddContactsViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 2/22/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PGAddContactsViewController.h"
#import "PGTableViewCell.h"
#import "WebServiceConstants.h"
#import "WebServiceHandler.h"
#import "FBLoginHandler.h"
#import "PGFindContactsViewController.h"
#import "FindFaceBookContactsViewController.h"
#import "TinderGenericUtility.h"
#import "UIImageView+WebCache.h"
#import "FontDetailsClass.h"
#import "PicogramSocketIOWrapper.h"
#import "PGFindContactsViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "ProgressIndicator.h"
#import "Helper.h"
#import "TinderGenericUtility.h"


@interface PGAddContactsViewController ()<WebServiceHandlerDelegate,SocketWrapperDelegate> {
    
    NSString *sync;
    
    NSMutableArray *temp;
    NSMutableArray *arrayOfFollowingStaus;
    
    UIActivityIndicatorView *activityView;
    NSString *resultString ;
    NSDictionary *contactDic;
    
    
    NSMutableArray *phoneContactsSyncResponseData;
}
@property (strong, nonatomic) PicogramSocketIOWrapper *client;
@end

@implementation PGAddContactsViewController

#pragma mark
#pragma mark - viewcontroller

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatingFollowButtonBoarder];
    
    self.client = [PicogramSocketIOWrapper sharedInstance];
    self.client.socketdelegate = self;
    activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setFrame:CGRectMake(0,0,50,30)];
    [self.view addSubview:activityView];
    activityView.tag  = 1;
    [activityView startAnimating];
    self.followContactsTableView.backgroundView = activityView;
    
    sync =[[NSUserDefaults standardUserDefaults]stringForKey:@"syncingContacts"];
   
    arrayOfFollowingStaus =[[NSMutableArray alloc] init];
    
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
    //request for contacts syncing.
    if ( [sync isEqualToString:@"syncOnlyPhoneContacs"]) {
        
       
        //passing parameters(contacts list and token)
        [self loadPhoneContacts];
        self.titleLabelOutlet.text = @"Contacts";
        //        if (_phoneContactsSyncResponseDataa) {
        //            [self loadPhoneContacts];
        //            //[self gotResponseFromCallChannel:_phoneContactsSyncResponseDataa];
        //        }
    }
    else {
        self.titleLabelOutlet.text = @"Facebook";
        // request for facebook contact syncing.
        //getting list of faceBook friends id.
        NSString *listOfFaceBookIds = [[NSUserDefaults standardUserDefaults]
                                       stringForKey:@"preferenceName"];
        //passing parameters(faceBookids list and token)
        NSDictionary *requestDict = @{mfaceBookId     :listOfFaceBookIds,
                                      mauthToken      :flStrForObj([Helper userToken]),
                                      };
        //requesting the service and passing parametrs.
        [WebServiceHandler faceBookContactSync:requestDict andDelegate:self];
    }
}

-(void)showingProgressindicator {
    //showing progress indicator and requesting for posts.
    ProgressIndicator *HomePI = [ProgressIndicator sharedInstance];  [HomePI showPIOnView:self.view withMessage:@"Loading..."];
}


-(void)creatingFollowButtonBoarder {
    
    /**
     *  setting follow button boareder and color for boarder.
     */
    
    _followButtonOutlet.layer.cornerRadius = 3;
    _followButtonOutlet.layer.borderWidth = 1;
    _followButtonOutlet.layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
}

#pragma mark
#pragma mark - buttons

- (IBAction)followButtonAction:(id)sender {
    //    //passing parameters.
    //    NSDictionary *requestDict = @{muserNameToUnFollow     : flStrForObj(temp[selectedButton.tag %1000][@"username"]),
    //                                  mauthToken            :userToken,
    //                                  };
    //
    //    //requesting the service and passing parametrs.
    //    [WebServiceHandler unFollow:requestDict andDelegate:self];
    
}

- (IBAction)nextButtonAction:(id)sender {
    
    if ( ![sync isEqualToString:@"syncOnlyPhoneContacs"]) {
        PGFindContactsViewController *FindVc = [self.storyboard instantiateViewControllerWithIdentifier:@"phoneVC"];
        [self.navigationController pushViewController:FindVc animated:YES];
    }
    else {
        [self performSegueWithIdentifier:@"tabBarSegue" sender:self];
    }
}

#pragma mark
#pragma mark - table view delegate methods

/**
 *  no of rows in section  decalre here.
 */

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( ![sync isEqualToString:@"syncOnlyPhoneContacs"]) {
        return  [temp count];
    }
    else {
        return  [phoneContactsSyncResponseData count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PGTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                            forIndexPath:indexPath];
    //if fb sync.
    if ( ![sync isEqualToString:@"syncOnlyPhoneContacs"]) {
        cell.userNameLabelOutlet.text  = flStrForObj(temp[indexPath.row][@"membername"]);
        cell.fullNameLabelOutlet.text = flStrForObj(temp[indexPath.row][@"fullname"]);
        [cell.profileImageViewOutlet sd_setImageWithURL:[NSURL URLWithString:flStrForObj(temp[indexPath.row][@"profilePicUrl"]]) placeholderImage:[UIImage imageNamed:@"contacts_profile_default_image_frame"]];
         [cell.cellFollowButtonOutlet addTarget:self
                                         action:@selector(cellFollowButtonAction:)
                               forControlEvents:UIControlEventTouchUpInside];
         [cell updateFollowButtonTitleForContacts:flStrForObj(arrayOfFollowingStaus[indexPath.row]) andIndexPath:indexPath.row];
         }
         //phone contacts sync
         else {
             cell.userNameLabelOutlet.text = flStrForObj(phoneContactsSyncResponseData[indexPath.row][@"membername"]);
             [cell.profileImageViewOutlet sd_setImageWithURL: [NSURL URLWithString:flStrForObj(phoneContactsSyncResponseData[indexPath.row][@"profilePicUrl"]]) placeholderImage:[UIImage imageNamed:@"defaultpp.png"]];
              cell.fullNameLabelOutlet.text =  flStrForObj(phoneContactsSyncResponseData[indexPath.row][@"fullName"]);
              [cell updateFollowButtonTitleForContacts:flStrForObj(arrayOfFollowingStaus[indexPath.row]) andIndexPath:indexPath.row];
              
              [cell.cellFollowButtonOutlet addTarget:self
                                              action:@selector(cellFollowButtonActionForPhoneContscts:)
                                    forControlEvents:UIControlEventTouchUpInside];
        }
              
              [cell layoutIfNeeded];
              cell.profileImageViewOutlet.layer.cornerRadius = cell.profileImageViewOutlet.frame.size.height/2;
              cell.profileImageViewOutlet.clipsToBounds = YES;
              cell.cellFollowButtonOutlet.tag = 1000 + indexPath.row;
              
              return cell;
}
              
-(void)cellFollowButtonAction:(id)sender {
                  
    UIButton *selectedButton = (UIButton *)sender;
    NSIndexPath *selectedCellForLike = [_followContactsTableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    
    // _privateAccountState ----> 1 for account is private
    // _privateAccountState ----> 0 for account is public
    
    //  if follow status is 0 ---> title as "Requested"
    //  if follow status is 1 ---> title as "Following"
    //  if follow status is nil ---> title as "Follow"
    
    NSString *memberPrivateAccountState = flStrForObj(temp[selectedCellForLike.row][@"isPrivate"]);
    
    //PGTableViewCell *selectedCell = [self.followContactsTableView cellForRowAtIndexPath:selectedCellForLike];
    
    
    if ([memberPrivateAccountState isEqualToString:@"1"]) {
        
        //actions for when the account is private.
        // if the button title is follow then we should request for follow request and otherwise unfollow request.
        
        if ([selectedButton.titleLabel.text isEqualToString:@" FOLLOW"]) {
            arrayOfFollowingStaus[selectedCellForLike.row] = @"0";
            
            [selectedButton  setTitle:@" REQUESTED" forState:UIControlStateNormal];
            [selectedButton setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
            
            [selectedButton setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
            
           
            selectedButton.backgroundColor = requstedButtonBackGroundColor;
            selectedButton .layer.borderColor = [UIColor clearColor].CGColor;
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :flStrForObj(temp[selectedCellForLike.row][@"membername"]),
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
        else if ([selectedButton.titleLabel.text isEqualToString:@" FOLLOWING"])  {
            
            [self showUnFollowAlert:[UIImage imageNamed:@"defaultpp.png"] and:flStrForObj(temp[selectedButton.tag%1000][@"membername"])  and:sender];
            
        }
        else {
            // cancel request for follow.
            
            [selectedButton  setTitle:@" FOLLOW" forState:UIControlStateNormal];
            [selectedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
            [selectedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
            selectedButton.backgroundColor = followButtonBackGroundColor;
            selectedButton .layer.borderColor =  [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
            
            
            arrayOfFollowingStaus[selectedCellForLike.row] = @"2";
            NSDictionary *requestDict = @{muserNameToUnFollow     : flStrForObj(temp[selectedCellForLike.row][@"membername"]),
                                          mauthToken            :[Helper userToken],
                                          };
            [WebServiceHandler unFollow:requestDict andDelegate:self];
        }
    }
    //actions for when the account is public.
    else {
        if ([selectedButton.titleLabel.text isEqualToString:@" FOLLOWING"]) {
            
            [self showUnFollowAlert:[UIImage imageNamed:@"defaultpp.png"] and:flStrForObj(temp[selectedButton.tag%1000][@"membername"])  and:sender];
            
        }
        else {
            arrayOfFollowingStaus[selectedCellForLike.row] = @"1";
            
            [selectedButton  setTitle:@" FOLLOWING" forState:UIControlStateNormal];
            
            [selectedButton setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];
             [selectedButton setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
           
            selectedButton.backgroundColor = followingButtonBackGroundColor;
            selectedButton.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
            
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :flStrForObj(temp[selectedCellForLike.row][@"membername"]),
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
    }
}
              
              /*-----------------------------------------------------*/
#pragma mark -
#pragma mark - CustomActionSheet
             /*----------------------------------------------------*/
- (void)showUnFollowAlert:(UIImage *)profieImage and:(NSString *)profileName  and:(id)sender{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    CGFloat margin = 8.0F;
    UIView *customView;
    customView = [[UIView alloc] initWithFrame:CGRectMake(margin, margin, alertController.view.bounds.size.width - margin * 4.0F, 80)];
    
    UIImageView *UserImageView =[[UIImageView alloc] init];
    UserImageView.image = profieImage;
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
        
        if ( [sync isEqualToString:@"syncOnlyPhoneContacs"]) {
            [self unfollowActionForContacts:sender];
        }
        else {
            [self unfollowAction:sender];
        }
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    [alertController addAction:actionForUnfollow];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:^{}];
}
              
              
-(void)unfollowActionForContacts:(id)sender  {
    NSLog(@"unfollow clicked");
    UIButton *selectedButton = (UIButton *)sender;
    
    [selectedButton  setTitle:@" FOLLOW" forState:UIControlStateNormal];
    
    arrayOfFollowingStaus[selectedButton.tag%1000] = @"2";
    [selectedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
   
    selectedButton.backgroundColor =followButtonBackGroundColor;
    
    
    [selectedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
    selectedButton .layer.borderColor =  [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
    
    
    //passing parameters.
    NSDictionary *requestDict = @{muserNameToUnFollow: flStrForObj(phoneContactsSyncResponseData[selectedButton.tag%1000][@"membername"]),
                                  mauthToken            :flStrForObj([Helper userToken]),
                                  };
    //requesting the service and passing parametrs.
    [WebServiceHandler unFollow:requestDict andDelegate:self];
}
              
-(void)unfollowAction:(id)sender {
    NSLog(@"unfollow clicked");
    UIButton *selectedButton = (UIButton *)sender;
    
    [selectedButton  setTitle:@" FOLLOW" forState:UIControlStateNormal];
    [selectedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
    arrayOfFollowingStaus[selectedButton.tag%1000] = @"2";
 
    selectedButton.backgroundColor = followButtonBackGroundColor;
    
    
    [selectedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
    selectedButton .layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
    
    
    //passing parameters.
    NSDictionary *requestDict = @{muserNameToUnFollow: flStrForObj(temp[selectedButton.tag %1000][@"membername"]),
                                  mauthToken            :flStrForObj([Helper userToken]),
                                  };
    //requesting the service and passing parametrs.
    [WebServiceHandler unFollow:requestDict andDelegate:self];
}
              
              
              
#pragma mark - WebServiceDelegate
              
- (void) didFinishLoadingRequest:(RequestType)requestType withResponse:(id)response error:(NSError*)error {
    
    [[ProgressIndicator sharedInstance] hideProgressIndicator];
    [activityView stopAnimating];
    
    // handling response.
    
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil,nil];
        [alert show];
        [self backGrounViewWithImageAndTitle:[error localizedDescription]];
        return;
    }
    
    //storing response data  in dictonary.
    NSDictionary *responseDict = (NSDictionary*)response;
    //checking the request type and handling response.
    if (requestType == RequestTypeLoginfaceBookContactSync ) {
        //checking the response  code and handling error message or success message by depending on code.
        switch ([responseDict[@"code"] integerValue]) {
            case 200: {
                //successs response.
                temp =responseDict[@"facebookUsers"];
                
                for(int i = 0; i< temp.count;i++) {
                    NSString *followingstatus = flStrForObj(temp[i][@"Following"]);
                    [arrayOfFollowingStaus addObject:followingstatus];
                }
                NSString *numberOfContacsSynced =[NSString stringWithFormat:@"%lu", (unsigned long)temp.count];
                
                if(temp.count >1) {
                    self.numberOfContactsSyncedLabelOutlet.text =[numberOfContacsSynced stringByAppendingString:@" of your friends are on"];
                }
                else {
                    self.numberOfContactsSyncedLabelOutlet.text =[numberOfContacsSynced stringByAppendingString:@" of your friend is in"];
                }
                
                
                [self.followContactsTableView reloadData];
            }
                break;
                //failure responses.
            case 2021: {
                // [self errorAlert:responseDict[@"message"]];
                self.followContactsTableView.backgroundView =[self backGroundViewForEmptyTable:responseDict[@"message"]];
                [activityView stopAnimating];
            }
                break;
            case 2022: {
                //[self errorAlert:@"None of your friends are on Picogram"];
                self.numberOfContactsSyncedLabelOutlet.text =[@"None" stringByAppendingString:@" of your friends are on"];
                self.followContactsTableView.backgroundView =[self backGroundViewForEmptyTable:@"None of your friends are on Picogram"];
            }
                break;
            case 2023: {
                
                self.followContactsTableView.backgroundView =[self backGroundViewForEmptyTable:@"None of your friends are on Picogram"];
                self.numberOfContactsSyncedLabelOutlet.text =[@"None" stringByAppendingString:@" of your friends are on"];
            }
                break;
            case 2024: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 2025: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 2026: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 2027: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            case 2028: {
                [self errorAlert:responseDict[@"message"]];
            }
                break;
            default:
                break;
        }
    }
    
    
    //checking the request type and handling response.
    if (requestType == RequestTypePhoneContactSync ) {
        
        [self.client syncContacts:resultString];
        
        /*switch ([responseDictForPhoneContactSync[@"code"] integerValue]) {
         case 200: {
         //successs response.
         NSLog(@"response for phoneBookSync %@",responseDictForPhoneContactSync);
         NSMutableArray *arrayOfUserNames =[[NSMutableArray alloc] init];
         NSArray *userName = responseDictForPhoneContactSync[@"resultArr"];
         NSLog(@"usename of phoneBook friends....%@",userName);
         for(int i = 0; i< userName.count;i++) {
         NSString *userNameOfFollower = responseDictForPhoneContactSync[@"resultArr"][i][@"userName"];
         [arrayOfUserNames addObject:userNameOfFollower];
         }
         [self.followContactsTableView reloadData];
         }
         //failure responses.
         break;
         case 2021: {
         self.followContactsTableView.backgroundView =[self backGroundViewForEmptyTable:responseDictForPhoneContactSync[@"message"]];
         [activityView stopAnimating];
         //[self errorAlert:responseDictForPhoneContactSync[@"message"]];
         }
         break;
         case 2022: {
         self.followContactsTableView.backgroundView =[self backGroundViewForEmptyTable:@"None of your friends are on Picogram"];
         self.numberOfContactsSyncedLabelOutlet.text =[@"None" stringByAppendingString:@" of your Contacts are on"];
         
         }
         break;
         case 2023: {
         [self errorAlert:responseDictForPhoneContactSync[@"message"]];
         }
         break;
         case 2024: {
         [self errorAlert:responseDictForPhoneContactSync[@"message"]];
         }
         break;
         case 2025: {
         [self errorAlert:responseDictForPhoneContactSync[@"message"]];
         }
         break;
         case 2026: {
         [self errorAlert:responseDictForPhoneContactSync[@"message"]];
         }
         break;
         case 2027: {
         [self errorAlert:responseDictForPhoneContactSync[@"message"]];
         }
         break;
         case 2028: {
         [self errorAlert:responseDictForPhoneContactSync[@"message"]];
         }
         break;
         default:
         break;
         }*/
    }
}
              
- (void)errorAlert:(NSString *)message {
    //showing error alert for failure response.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil,nil];//Send via SMS
    [alert show];
}
              
              
              
              
              
-(void)cellFollowButtonActionForPhoneContscts:(id)sender {
    
    UIButton *selectedButton = (UIButton *)sender;
    NSIndexPath *selectedCellForLike = [_followContactsTableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    
    
    // _privateAccountState ----> 1 for account is private
    // _privateAccountState ----> 0 for account is public
    
    
    //  if follow status is 0 ---> title as "Requested"
    //  if follow status is 1 ---> title as "Following"
    //  if follow status is nil ---> title as "Follow"
    
    
    NSString *memberPrivateAccountState = flStrForObj(phoneContactsSyncResponseData[selectedCellForLike.row][@"memberPrivate"]);
    
    //PGTableViewCell *selectedCell = [self.followContactsTableView cellForRowAtIndexPath:selectedCellForLike];
    
    
    if ([memberPrivateAccountState isEqualToString:@"1"]) {
        
        //actions for when the account is private.
        // if the button title is follow then we should request for follow request and otherwise unfollow request.
        
        if ([selectedButton.titleLabel.text isEqualToString:@" FOLLOW"]) {
            arrayOfFollowingStaus[selectedCellForLike.row] = @"0";
            
            [selectedButton  setTitle:@" REQUESTED" forState:UIControlStateNormal];
            
            [selectedButton setImage:[UIImage imageNamed:@"edit_profile_two_timing_icon"] forState:UIControlStateNormal];
            
            [selectedButton setTitleColor:requestedButtonTextColor forState:UIControlStateNormal];
            selectedButton.backgroundColor = requstedButtonBackGroundColor;
            selectedButton .layer.borderColor = [UIColor clearColor].CGColor;
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :flStrForObj(phoneContactsSyncResponseData[selectedButton.tag%1000][@"membername"]),
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
        else if ([selectedButton.titleLabel.text isEqualToString:@" FOLLOWING"])  {
            
            [self showUnFollowAlert:[UIImage imageNamed:@"defaultpp.png"] and:flStrForObj(phoneContactsSyncResponseData[selectedButton.tag%1000][@"membername"])  and:sender];
        }
        else {
            // cancel request for follow.
            
            [selectedButton  setTitle:@" FOLLOW" forState:UIControlStateNormal];
            [selectedButton setImage:[UIImage imageNamed:@"contacts_plus_icon"] forState:UIControlStateNormal];
         [selectedButton setTitleColor:followButtonTextColor forState:UIControlStateNormal];
            selectedButton.backgroundColor = followButtonBackGroundColor;
            selectedButton .layer.borderColor =[UIColor colorWithRed:0.2392 green:0.3216 blue:0.5922 alpha:1.0].CGColor;
            
            
            arrayOfFollowingStaus[selectedCellForLike.row] = @"2";
            NSDictionary *requestDict = @{muserNameToUnFollow     : flStrForObj(phoneContactsSyncResponseData[selectedButton.tag%1000][@"membername"]),
                                          mauthToken            :[Helper userToken],
                                          };
            [WebServiceHandler unFollow:requestDict andDelegate:self];
        }
    }
    //actions for when the account is public.
    else {
        if ([selectedButton.titleLabel.text isEqualToString:@" FOLLOWING"]) {
            
            [self showUnFollowAlert:[UIImage imageNamed:@"defaultpp.png"] and:flStrForObj(phoneContactsSyncResponseData[selectedButton.tag%1000][@"membername"])  and:sender];
        }
        else {
            arrayOfFollowingStaus[selectedCellForLike.row] = @"1";
            
            [selectedButton  setTitle:@" FOLLOWING" forState:UIControlStateNormal];
            [selectedButton setTitleColor:followingButtonTextColor forState:UIControlStateNormal];
            [selectedButton setImage:[UIImage imageNamed:@"contact_correct_icon"] forState:UIControlStateNormal];
            
            selectedButton.backgroundColor = followingButtonBackGroundColor;
            selectedButton.layer.borderColor = [UIColor clearColor].CGColor;
            
            
            //passing parameters.
            NSDictionary *requestDict = @{muserNameTofollow     :flStrForObj(phoneContactsSyncResponseData[selectedButton.tag%1000][@"membername"]),
                                          mauthToken            :flStrForObj([Helper userToken]),
                                          };
            //requesting the service and passing parametrs.
            [WebServiceHandler follow:requestDict andDelegate:self];
        }
    }
    
    
    
    
    
    //    UIButton *selectedButton = (UIButton *)sender;
    //    NSIndexPath *selectedRow = [_followContactsTableView indexPathForCell:(UITableViewCell *)[[[sender superview] superview] superview]];
    //
    //    if (selectedButton.selected) {
    //
    //
    //        [arrayOfFollowingStaus replaceObjectAtIndex:selectedButton.tag %1000 withObject:@"0"];
    //
    //        selectedButton.selected = NO;
    //        selectedButton.backgroundColor=[UIColor whiteColor];
    //        selectedButton.layer.borderColor = [UIColor colorWithRed:0.1786 green:0.5036 blue:0.925 alpha:1.0].CGColor;
    //        NSDictionary *requestDict = @{muserNameToUnFollow     : phoneContactsSyncResponseData[selectedButton.tag%1000][@"username"],
    //                                      mauthToken            :userToken,
    //                                      };
    //        //requesting the service and passing parametrs.
    //        [WebServiceHandler unFollow:requestDict andDelegate:self];
    //    }
    //    else {
    //        [arrayOfFollowingStaus replaceObjectAtIndex:selectedButton.tag %1000 withObject:@"1"];
    //
    //        selectedButton.selected = YES;
    //        selectedButton.backgroundColor =[UIColor colorWithRed:0.4 green:0.7412 blue:0.1804 alpha:1.0];
    //        selectedButton.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
    //
    //        //passing parameters.
    //        NSDictionary *requestDict = @{muserNameTofollow     :phoneContactsSyncResponseData[selectedButton.tag%1000][@"username"],
    //                                      mauthToken            :userToken,
    //                                      };
    //
    //        //requesting the service and passing parametrs.
    //        [WebServiceHandler follow:requestDict andDelegate:self];
    //    }
}
              
              
              
              
              //-(void)gotResponseFromCallChannel:(NSNotification *)userInfo
-(void)gotResponseFromCallChannel:(NSDictionary *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        [activityView stopAnimating];
        NSLog(@"Socket Data:%@",userInfo);
        NSDictionary *responseDictionary =userInfo;
        switch ([responseDictionary[@"code"] integerValue]) {
            case 200: {
                //successs response.
                phoneContactsSyncResponseData = [[NSMutableArray alloc] init];
                phoneContactsSyncResponseData = responseDictionary[@"data"];
                
                for(int i = 0; i< phoneContactsSyncResponseData.count;i++) {
                    NSString *followStatus = flStrForObj(phoneContactsSyncResponseData[i][@"followRequestStatus"]);// flStrForObj(phoneContactsSyncResponseData[i][@"followingFlag"]);
                    [arrayOfFollowingStaus addObject:followStatus];
                }
                
                
                NSString *numberOfContacsSynced =[NSString stringWithFormat:@"%lu", (unsigned long)phoneContactsSyncResponseData.count];
                
                if(temp.count >1) {
                    self.numberOfContactsSyncedLabelOutlet.text =[numberOfContacsSynced stringByAppendingString:@" of your friends are on"];
                }
                else {
                    self.numberOfContactsSyncedLabelOutlet.text =[numberOfContacsSynced stringByAppendingString:@" of your friend is in"];
                }
                
                //            self.numberOfContactsSyncedLabelOutlet.text =[numberOfContacsSynced stringByAppendingString:@" of your Contacts are on"];
                [activityView stopAnimating];
                [self.followContactsTableView reloadData];
            }
                //failure responses.
                break;
            case 2021: {
                // [self errorAlert:responseDictionary[@"message"]];
                
                self.followContactsTableView.backgroundView =[self backGroundViewForEmptyTable:responseDictionary[@"message"]];
                [activityView stopAnimating];
                
            }
                break;
            case 2022: {
                //[self errorAlert:responseDictionary[@"message"]];
                self.followContactsTableView.backgroundView =[self backGroundViewForEmptyTable:@"None of your friends are on Picogram"];
                self.numberOfContactsSyncedLabelOutlet.text =[@"None" stringByAppendingString:@" of your Contacts are on"];
                [activityView stopAnimating];
                
            }
                break;
            case 2023: {
                [self errorAlert:responseDictionary[@"message"]];
            }
                break;
            case 2024: {
                [self errorAlert:responseDictionary[@"message"]];
            }
                break;
            case 2025: {
                [self errorAlert:responseDictionary[@"message"]];
            }
                break;
            case 2026: {
                [self errorAlert:responseDictionary[@"message"]];
            }
                break;
            case 2027: {
                [self errorAlert:responseDictionary[@"message"]];
            }
                break;
            case 2028: {
                [self errorAlert:responseDictionary[@"message"]];
            }
                break;
            default:
                break;
        }
        
    });
}
              
-(UIView *)backGroundViewForEmptyTable:(NSString *)message {
    UILabel *labelForNoPostsMessage = [[UILabel alloc] init];
    labelForNoPostsMessage.text = message;
    labelForNoPostsMessage.textColor = [UIColor whiteColor];
    labelForNoPostsMessage.frame = CGRectMake(0, self.view.frame.size.height/2 - 20, self.view.frame.size.width, 40);
    [labelForNoPostsMessage setFont:[UIFont fontWithName:RobotoMedium size:15]];
    labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
    self.followContactsTableView.backgroundView = labelForNoPostsMessage;
    
    return labelForNoPostsMessage;
}
              
#pragma mark- SocketDelegate
-(void)responseFromChannels:(NSDictionary *)responseDictionary {
    NSLog(@"Contact Response:%@",responseDictionary);
    [self gotResponseFromCallChannel:responseDictionary];
    //                 [[NSNotificationCenter defaultCenter] postNotificationName:@"getResponseFromCallChannel" object:nil userInfo:responseDictionary];
}
              
#pragma marks - Contact fetching
              
-(void)loadPhoneContacts{
    
    UIAlertView *alloc = [[UIAlertView alloc] initWithTitle:@"Picogram Would Like to Access Contacts" message:@"Picogram would like to use your contacts.Your contacts are periodically synced and stored securely on our servers." delegate:self cancelButtonTitle:@"Don't Allow" otherButtonTitles:@"Ok", nil];
    alloc.tag = 200;
    [alloc show];
}
              
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
        if (alertView.tag == 200) {
        if(buttonIndex == 0)//cancel pressed
        {
            if ( ![sync isEqualToString:@"syncOnlyPhoneContacs"]) {
                PGFindContactsViewController *FindVc = [self.storyboard instantiateViewControllerWithIdentifier:@"phoneVC"];
                [self.navigationController pushViewController:FindVc animated:YES];
            }
            else {
                [self performSegueWithIdentifier:@"tabBarSegue" sender:self];
            }
        }
        else if(buttonIndex == 1)//confirm delete  pressed.
        {
            ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
            if (status == kABAuthorizationStatusDenied) {
                
                [activityView stopAnimating];
                
                [[[UIAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                return;
            }
            CFErrorRef error = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
            if (error) {
                
                NSLog(@"ABAddressBookCreateWithOptions error: %@", CFBridgingRelease(error));
                
                if (addressBook) CFRelease(addressBook);
                
                return;
                
            }
            if (status == kABAuthorizationStatusNotDetermined) {
                // present the user the UI that requests permission to contacts ...
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                    if (error) {
                        NSLog(@"ABAddressBookRequestAccessWithCompletion error: %@", CFBridgingRelease(error));
                    }
                    if (granted) {
                        // if they gave you permission, then just carry on
                        [self listPeopleInAddressBook:addressBook];
                    } else {
                        
                        // however, if they didn't give you permission, handle it gracefully, for example...
                        
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [[[UIAlertView alloc] initWithTitle:nil message:@"This app requires access to your contacts to function properly. Please visit to the \"Privacy\" section in the iPhone Settings app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                        });
                    }
                    if (addressBook) CFRelease(addressBook);
                });
            } else if (status == kABAuthorizationStatusAuthorized) {
                [self listPeopleInAddressBook:addressBook];
                if (addressBook) CFRelease(addressBook);
            }
        }
    }
}

              
- (void)listPeopleInAddressBook:(ABAddressBookRef)addressBook {
    self.client = [PicogramSocketIOWrapper sharedInstance];
    self.client.socketdelegate = self;
    NSString *phoneNumber;
    NSInteger numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    NSArray *allPeople = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSMutableArray  *onlyPhoneNumbers = [[NSMutableArray alloc] init];;
    for (NSInteger i = 0; i < numberOfPeople; i++) {
        ABRecordRef person = (__bridge ABRecordRef)allPeople[i];
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSLog(@"Name:%@ %@", firstName, lastName);
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
        for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
            phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
            NSLog(@"  phone:%@", phoneNumber);
        }
        CFRelease(phoneNumbers);
        NSLog(@"=============================================");
        if (phoneNumber) {
            [onlyPhoneNumbers addObject:phoneNumber];
        }
        
    }
    
    NSLog(@"number of contacts:%lu",(unsigned long)onlyPhoneNumbers.count);
    self.greeting = [onlyPhoneNumbers componentsJoinedByString:@","];
    NSLog(@"%@",self.greeting);
    
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789,+"] invertedSet];
    resultString = [[self.greeting componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
    NSLog (@"Result: %@", resultString);
    
    
    NSDictionary *requestDict = @{
                                    mauthToken      :flStrForObj([Helper userToken]),
                                  };
    //requesting the service and passing parametrs.
    [WebServiceHandler phoneContactSync:requestDict andDelegate:self];
    
    //[self.client syncContacts:resultString];
}
              
-(void)backGrounViewWithImageAndTitle:(NSString *)mesage{
    
    UIView *viewWhenNoPosts = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIImageView *image =[[UIImageView alloc] init];
    image.image = [UIImage imageNamed:@"ip5"];
    image.frame =  CGRectMake(self.view.frame.size.width/2 - 45, self.view.frame.size.height/2 - 90, 90, 90);
    [viewWhenNoPosts addSubview:image];
    
    UILabel *labelForNoPostsMessage = [[UILabel alloc] init];
    labelForNoPostsMessage.text = mesage;
    labelForNoPostsMessage.numberOfLines =0;
    labelForNoPostsMessage.frame = CGRectMake(8, CGRectGetMaxY(image.frame) + 10, self.view.frame.size.width-16, 40);
    [labelForNoPostsMessage setFont:[UIFont fontWithName:RobotoRegular size:15]];
    labelForNoPostsMessage.textAlignment = NSTextAlignmentCenter;
    [viewWhenNoPosts addSubview:labelForNoPostsMessage];
    
    self.followContactsTableView.backgroundView = viewWhenNoPosts;
}
              
@end
              
