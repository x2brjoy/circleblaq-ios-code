//
//  TWImageScrollView.h
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <SCRecorder/SCPlayer.h>
#import <SCRecorder/SCVideoPlayerView.h>
#import  <SCRecorder/SCRecordSession.h>

@interface TWImageScrollView : UIScrollView

- (void)displayImage:(UIImage *)image;
- (void)displayVideo:(NSURL *)url h:(float)hight w:(float)width;
- (UIImage *)capture;
-(void)dealloci;
@end

