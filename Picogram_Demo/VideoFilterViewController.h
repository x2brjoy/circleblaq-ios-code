//
//  PlayVideoViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 06/07/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <SCRecorder/SCPlayer.h>
#import <SCRecorder/SCVideoPlayerView.h>
#import  <SCRecorder/SCRecordSession.h>

@interface VideoFilterViewController : UIViewController
{
   
}

@property (strong, nonatomic) IBOutlet SCVideoPlayerView *playerView;

@property NSString *pathOfVideo;
@property NSData* videoData;
@property SCRecordSession *recordsession;
@property (nonatomic,strong) SCPlayer *player;
@property BOOL videoplaying;
@property (weak, nonatomic) IBOutlet UIView *viewForPlayingVideo;
@property NSString *thumbnailimageForVideoPath;
@property UIImage *videoimgthumb;
- (IBAction)soundenablebuttonaction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *soundbuttonoutlet;

@property (weak, nonatomic) IBOutlet UIImageView *playImageViewOutlet;

@property (weak,nonatomic) NSString *videoRecorded;
@end
