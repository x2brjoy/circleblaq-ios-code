//
//  PostSharingViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 19/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostSharingViewController : UIViewController
@property(nonatomic,strong)NSArray *postDetails;
@property(nonatomic,strong)NSDictionary *postDetailsDic;
@property (strong, nonatomic) IBOutlet UIButton *tumblrBtn;
- (IBAction)fbBtnAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *fbBtnOutlet;
@property (strong, nonatomic) IBOutlet UIButton *flickerBtnOutlet;
@property (strong, nonatomic) IBOutlet UIButton *twitterBtnOutlet;
@property (strong, nonatomic) IBOutlet UIButton *twitterBtnAction;
- (IBAction)emailAdressAction:(id)sender;
- (IBAction)copyLinkAction:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *postCaption;
- (IBAction)flickerBtnAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *postImageView;


@property(nonatomic,strong)NSDictionary *postUsersDetail;
@end
