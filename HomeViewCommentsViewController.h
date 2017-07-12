//
//  HomeViewCommentsViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 4/4/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewCommentsTableViewCell.h"

#import "MBAutoGrowingTextView.h"






@interface HomeViewCommentsViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *commentTextField;


@property (weak, nonatomic) IBOutlet UITextView *commentTextView;

@property (weak, nonatomic) IBOutlet UITableView *commentsTableViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *bottomCommentView;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIButton *directButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *sendButtonOutlet;

- (IBAction)directButtonAction:(id)sender;
- (IBAction)sendButtonAction:(id)sender;

@property NSString *postId;
@property NSString *postCaption;
@property NSString *postType;
@property NSString *imageUrlOfPostedUser;
@property  NSInteger selectedCellIs;
@property  NSString *userNameOfPostedUser;

- (IBAction)userNameButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldSuperViewBottomConstraint;
@property  NSTimer *timerIvar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewSuperViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentTextViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UITableView *userNameSuggestionView;

@end
