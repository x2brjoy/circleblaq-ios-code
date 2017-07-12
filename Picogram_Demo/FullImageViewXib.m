//
//  FullImageViewXib.m
//  Picogram
//
//  Created by Rahul Sharma on 5/21/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "FullImageViewXib.h"

@implementation FullImageViewXib

- (instancetype)init{
    
    self = [super init];
    self = [[[NSBundle mainBundle] loadNibNamed:@"FullImageViewXib"
                                          owner:self
                                        options:nil] firstObject];
    return self;
}
- (void)showFullImage:(UIImage *)image onWindow:(UIWindow *)window; {
   
    
    self.viewForPlayingVideo.hidden = YES;
    self.imageView.hidden = NO;
        self.frame = window.frame;
        self.imageView.image = image;
        self.imageviewHeight.constant = 0;
        self.imageViewWidthConstraint.constant = 0;
        self.imageViewtrailingConstraint.constant = window.frame.size.width -10;
        self.imageViewTopConstraint.constant = window.frame.size.height /4;
        [self layoutIfNeeded];
        [UIView animateWithDuration:0.75 animations:^{
            self.imageViewWidthConstraint.constant = window.frame.size.width;
            self.imageViewtrailingConstraint.constant = 0;
            self.imageviewHeight.constant = window.frame.size.height *0.5;
            self.imageViewTopConstraint.constant = window.frame.size.height /4;
            [window addSubview:self];
            [self layoutIfNeeded];
        }];
 }

- (void)PlayVideo:(SCRecordSession *)session  onWindow:(UIWindow *)window {
    
    self.imageView.hidden = YES;
    self.viewForPlayingVideo.hidden = NO;
    
    self.frame = window.frame;
    self.viewForPlayingVideoHeight.constant = 0;
    self.viewForPlayingVideoWidth.constant = 0;
    self.viewForPlayingVideoTrailingConstraint.constant = window.frame.size.width -10;
    self.viewForPlayingVideoTopConstraint.constant = window.frame.size.height /4;
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.1 animations:^{
        self.viewForPlayingVideoWidth.constant = window.frame.size.width;
        self.viewForPlayingVideoTrailingConstraint.constant = 0;
        self.viewForPlayingVideoHeight.constant = window.frame.size.height *0.5;
        self.viewForPlayingVideoTopConstraint.constant = window.frame.size.height /4;
       
        [window addSubview:self];
        [self layoutIfNeeded];
        
       // self.viewForFirstBaselineLayout.backgroundColor =[UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    }];
    
    
    _player = [SCPlayer player];
    [_player setItemByAsset:session.assetRepresentingSegments];
    _player.delegate = self;
    SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
    
    playerView.frame = CGRectMake(0,0,self.viewForPlayingVideo.frame.size.width,self.viewForPlayingVideo.frame.size.height);
    [self.viewForPlayingVideo addSubview:playerView];
    
    [_player play];
    self.player.muted = NO;
    _player.loopEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(startorstopaudio)];
    tap.delegate = self;
    [self.viewForPlayingVideo addGestureRecognizer:tap];
    _videoplaying = YES;
}
- (void)PlayVideoPath:(NSString *)session  onWindow:(UIWindow *)window {
    
    self.imageView.hidden = YES;
    self.viewForPlayingVideo.hidden = NO;
    
    self.frame = window.frame;
    self.viewForPlayingVideoHeight.constant = 0;
    self.viewForPlayingVideoWidth.constant = 0;
    self.viewForPlayingVideoTrailingConstraint.constant = window.frame.size.width -10;
    self.viewForPlayingVideoTopConstraint.constant = window.frame.size.height /4;
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.1 animations:^{
        self.viewForPlayingVideoWidth.constant = window.frame.size.width;
        self.viewForPlayingVideoTrailingConstraint.constant = 0;
        self.viewForPlayingVideoHeight.constant = window.frame.size.height *0.5;
        self.viewForPlayingVideoTopConstraint.constant = window.frame.size.height /4;
        
        [window addSubview:self];
        [self layoutIfNeeded];
        
        // self.viewForFirstBaselineLayout.backgroundColor =[UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    }];
    
    
    _player = [SCPlayer player];
    [_player setItemByUrl:[NSURL URLWithString:session]];
    _player.delegate = self;
    SCVideoPlayerView *playerView = [[SCVideoPlayerView alloc] initWithPlayer:_player];
    
    playerView.frame = CGRectMake(0,0,self.viewForPlayingVideo.frame.size.width,self.viewForPlayingVideo.frame.size.height);
    [self.viewForPlayingVideo addSubview:playerView];
    
    
    [_player play];
    self.player.muted = NO;
    _player.loopEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(startorstopaudio)];
    tap.delegate = self;
    [self.viewForPlayingVideo addGestureRecognizer:tap];
    _videoplaying = YES;
}
-(void)startorstopaudio {
    
    if ( _videoplaying) {
        [_player pause];
       // self.player.muted = YES;
        _videoplaying = NO;
        self.pauseVideoImageViewOutlet.hidden =NO;
        [self.viewForPlayingVideo bringSubviewToFront:self.pauseVideoImageViewOutlet];
    }
    else {
        [_player play];
      //   self.player.muted = NO;
        _videoplaying = YES;
         self.pauseVideoImageViewOutlet.hidden = YES;
         [self.viewForPlayingVideo sendSubviewToBack:self.pauseVideoImageViewOutlet];
    }
}

- (IBAction)tapGestureForImageRemoval:(id)sender {
    [self removeFromSuperview];
    if (!_sendingImage)
    {
        [_player pause];
    }
}

@end
