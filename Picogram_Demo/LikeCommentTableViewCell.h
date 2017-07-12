//
//  LikeCommentTableViewCell.h
//  InstaVideoPlayerExample
//
//  Created by Rahul Sharma on 13/09/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LikeCommentTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *likeButtonOutlet;

@property (weak, nonatomic) IBOutlet UIButton *commentButtonOutlet;

@property (weak, nonatomic) IBOutlet UIButton *moreButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *shareButtonOutlet;

-(void)updateLikeButtonStatus :(NSInteger )section data:(NSArray *)responseData;
@property (strong, nonatomic) IBOutlet UIButton *sharePostButtonOutlet;

@end
