//
//  InstaVideoTableViewCell.h
//  InstaVideoPlayerExample
//
//  Created by Rahul Sharma on 22/07/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <AVFoundation/AVFoundation.h>
#import "ZOWVideoView.h"
#import "InstagramVideoView.h"
#import "KAProgressLabel.h"
@protocol MyTableViewCellDelegate;



@interface InstaVideoTableViewCell : UITableViewCell



@property (assign, nonatomic) id <MyTableViewCellDelegate> delegate;



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
@property (weak, nonatomic) IBOutlet KAProgressLabel *progressLabel;

@end

@protocol MyTableViewCellDelegate <NSObject>



- (void)delegateForSingleTapCell:(InstaVideoTableViewCell *)cell;
-(void)delegateFordoubLeTapCell:(InstaVideoTableViewCell *)cell;

@end


