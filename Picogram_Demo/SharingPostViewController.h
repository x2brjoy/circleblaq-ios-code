//
//  SharingPostViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 23/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharingPostViewController : UIViewController
@property(nonatomic,strong)NSArray *postDetails;
@property(nonatomic,strong)NSDictionary *postDetailsDic;
@property (strong, nonatomic) IBOutlet UIButton *tumblrBtn;
- (IBAction)fbBtnAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *fbBtnOutlet;
@property (strong, nonatomic) IBOutlet UIButton *flickerBtnOutlet;
@property (strong, nonatomic) IBOutlet UIButton *twitterBtnOutlet;
- (IBAction)twitterBtnAction:(id)sender;
- (IBAction)instagramButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *instgramButtonOutlet;

- (IBAction)emailAdressAction:(id)sender;
- (IBAction)copyLinkAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *postCaption;
- (IBAction)flickerBtnAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) IBOutlet UITextField *twitterLbl;
@property (strong, nonatomic) IBOutlet UITextField *flickerLbl;
@property (strong, nonatomic) IBOutlet UITextField *facebookLbl;

@property(nonatomic,strong)NSDictionary *postUsersDetail;
@end
