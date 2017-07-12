//
//  ConversationListViewController1.h
//  Sup
//
//  Created by Rahul Sharma on 10/22/15.
//  Copyright © 2015 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>


//@protocol ATLParticipantTableViewControllerDelegate;

@interface ConversationListViewController1 : UIViewController<UIAlertViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *serachBar;
@property (strong, nonatomic) IBOutlet UITableView *tableVIewOutlet;

- (IBAction)newGroupCliked:(id)sender;
- (IBAction)broadcastCliked:(id)sender;


- (IBAction)createChatButton:(id)sender;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *newchatButton;



@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButtonOutlet;

- (IBAction)backButtonAction:(id)sender;



- (IBAction)navCallBtncliked:(id)sender;
@end
