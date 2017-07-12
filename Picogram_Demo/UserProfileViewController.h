//
//  UserProfileViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/30/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfileCollectionViewCell.h"
#import "ProfileViewXib.h"
#import "UserProfileViewTableViewCell.h"
// Chat Start
#import "LRPageHomeViewController.h"
#import "PageContentViewController.h"
// Chat End

@interface UserProfileViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *topContentView;
/**
 *  profile photo imageView outlet.
  */
@property (weak, nonatomic) IBOutlet UIImageView *profilePhotoOutlet;
/**
 *  collectionView and tableView heightOutlet and its acommon for both collection and table view.
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;

/**
 *  outlet for scrollView.
 */
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

/**
 *  oulet for map button.
 */

@property (weak, nonatomic) IBOutlet UIButton *mapButtonOutlet;

/**
 *  outlet for collectionView.
 */

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)postedPhotosButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *postedPhotosButtonOutlet;

/**
 *  outlet for tableView.
 */
@property (weak, nonatomic) IBOutlet UITableView *customTableView;
/**
 *  collectionView button outlet
 */

@property (weak, nonatomic) IBOutlet UIButton *collectionViewButtonOutlet;

/**
 *  tableView button outlet
 */
@property (weak, nonatomic) IBOutlet UIButton *tableViewButtonOutlet;

/**
 *  button action for collectionView.
 *
 *  @param sender it will open collection view.
 */
- (IBAction)collectionViewButtonAction:(id)sender;
/**
 *  button action for tableView.
 *
 *  @param sender it will open table view.
 */
- (IBAction)tableViewButtonAction:(id)sender;

/**
 *  button action for tableView.
 *
 *  @param sender it will open map view.
 */

@property (weak, nonatomic) IBOutlet UIButton *editProfileButtonOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *noPhotosAvailableImageViewOutlet;

@property (weak, nonatomic) IBOutlet UILabel *numberOfPostsLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *numberOfFollowersLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *numberOfFollowingLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabelOutlet;
@property (weak, nonatomic) IBOutlet UILabel *webSiteUrlLabelOutlet;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *websiteLabelHeightConstr;
@property (weak, nonatomic) IBOutlet UILabel *biodataLabelOutlet;
@property (weak, nonatomic) IBOutlet UIView *labelsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNameLabelHeightConstr;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *biodatalabelHeightConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContentViewHeightConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfLabelsView;

@property bool  checkingFriendsProfile;
@property NSString *checkProfileOfUserNmae;
@property (weak, nonatomic) IBOutlet UIView *mainActivityViewController;
@property (weak, nonatomic) IBOutlet UIView *mainTableAndCollectionViewSuperView;
@property (weak, nonatomic) IBOutlet UILabel *noPhotosAvailableLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actiVityViewIndicator;

@property (weak, nonatomic) IBOutlet UIButton *followingButtonOutlet;

@property (weak, nonatomic) IBOutlet UIButton *followersButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *photosOfYouButtonOutlet;

@property NSString *privateAccountState;


//
@property (weak, nonatomic) IBOutlet UIView *FollowRequestAcceptOrRejectView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabelForFollowRequest;
@property (weak, nonatomic) IBOutlet UIButton *rejectButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *acceptButtonOutlet;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *followRequestMessageHeightConstraint;


- (IBAction)sendPostButtonAction:(id)sender;

- (IBAction)likeButtonAction:(id)sender;
- (IBAction)commentButtonAction:(id)sender;
- (IBAction)moreButtonAction:(id)sender;
- (IBAction)viewAllCommentButtonAction:(id)sender;
- (IBAction)listOfLikesButtonAction:(id)sender;
- (IBAction)acceptButtonAction:(id)sender;
- (IBAction)rejectButtonAction:(id)sender;
- (IBAction)mapButtonAction:(id)sender;
- (IBAction)followingButtonAction:(id)sender;
- (IBAction)followersButtonAction:(id)sender;
- (IBAction)postsButtonAction:(id)sender;
- (IBAction)editProfileButtonAction:(id)sender;

//bussiness
- (IBAction)contactButtonAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *contactButtonOutlet;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *contactButtonWidthConstaraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *EditProfileLeadingConstraibnt;
@property (strong, nonatomic) IBOutlet UIView *EditProfileAndContactSuperView;
- (IBAction)captionUserNameButtonAction:(id)sender;

- (IBAction)firstCommentUserNameButtonAction:(id)sender;

- (IBAction)secondCommentUserNameButtonAction:(id)sender;

// Chat Start
@property (strong) NSMutableArray *friendesList;
@property (strong, nonatomic) PageContentViewController *pageViewController;
// Chat End

@end
