//
//  FullImageViewXib.h
//  Picogram
//
//  Created by Rahul Sharma on 5/21/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SCRecorder/SCPlayer.h>
#import <SCRecorder/SCVideoPlayerView.h>
#import  <SCRecorder/SCRecordSession.h>

@interface FullImageViewXib : UIView<SCPlayerDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (void)showFullImage:(UIImage *)image onWindow:(UIWindow *)window;
- (void)PlayVideo:(SCRecordSession *)session  onWindow:(UIWindow *)window;
- (void)PlayVideoPath:(NSString *)session  onWindow:(UIWindow *)window;
- (IBAction)tapGestureForImageRemoval:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageviewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewtrailingConstraint;
@property BOOL sendingImage;

@property (weak, nonatomic) IBOutlet UIView *viewForPlayingVideo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewForPlayingVideoTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewForPlayingVideoTrailingConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewForPlayingVideoWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewForPlayingVideoHeight;

@property NSString *pathOfVideo;
@property SCRecordSession *recordsession;
@property (nonatomic,strong) SCPlayer *player;
@property BOOL videoplaying;

@property (weak, nonatomic) IBOutlet UIImageView *pauseVideoImageViewOutlet;

@end
