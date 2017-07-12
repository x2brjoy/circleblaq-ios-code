//
//  InstaTableViewCellForProfileVc.h
//  Picogram
//
//  Created by Rahul_Sharma on 04/11/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZOWVideoView.h"
#import "InstagramVideoView.h"
@protocol MyTableViewCellDelegateForUserProfile;

@interface InstaTableViewCellForProfileVc : UITableViewCell
@property (assign, nonatomic) id <MyTableViewCellDelegateForUserProfile> delegate;



-(void)notifyCompletelyVisible;
-(void)notifyNotCompletelyVisible;
-(void)loadImageForCell;
-(void)loadVideoForCellFromLinkwithUrl:(NSString *)urlString;
@property (strong, nonatomic) InstagramVideoView *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *VideoBackgroundViewOutlet;
- (IBAction)showTagsButtonAction:(id)sender;

//@property (strong,nonatomic) AVPlayer *player;
//@property (strong, nonatomic) AVPlayerItem* videoItem;
//@property (strong, nonatomic) AVPlayerLayer* avLayer;

@property (nonatomic,assign) BOOL isDataTypeIsVideo;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewOutlet;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *placeHolderUrl;
@property (nonatomic,strong) UIImage *placeHolderImage;
@property (weak, nonatomic) IBOutlet UIImageView *popUpImageViewOutlet;
@property NSString *postType;
@property (weak, nonatomic) IBOutlet UIButton *showTagsButtonOutlet;

@end

@protocol MyTableViewCellDelegateForUserProfile <NSObject>

- (void)delegateForSingleTapCell:(InstaTableViewCellForProfileVc *)cell;
-(void)delegateFordoubLeTapCell:(InstaTableViewCellForProfileVc *)cell;
@end
