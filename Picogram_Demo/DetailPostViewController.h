//
//  DetailPostViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 6/7/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface DetailPostViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

@property UIImage *selectedImage;
@property NSString *selectedImageUrl;
@property NSString *postedUser;
@property NSString *postedTime;
@property NSString *mainIMageUrl;
@property NSString *likeStaus;
@property NSString *location;
@property NSString *profileImageUrl;
@property NSString *caption;
@property NSString *postId;
@property NSString *postType;
@property NSString *userToken;
@property NSString *userName;
@property NSString *numberOfLikes;
@property NSString *commentsOndPost;
@property NSString *taggedPeople;



@property (weak, nonatomic) IBOutlet UITableView *detailPostTableView;
@property NSDictionary *singlePostDetails;
@property NSDictionary *selectedPostNumber;
@end
