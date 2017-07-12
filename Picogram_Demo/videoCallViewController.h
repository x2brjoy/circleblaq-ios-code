//
//  videoCallViewController.h
//  Sup
//
//  Created by MacMini on 28/02/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTCEAGLVideoView.h"
#import "ARDStatsView.h"
#import "UIImage+ARDUtilities.h"

@class videoCallViewController;
@protocol ARDVideoCallViewDelegate <NSObject>

// Called when the camera switch button is pressed.
- (void)videoCallViewDidSwitchCamera:(videoCallViewController *)view;

// Called when the hangup button is pressed.
- (void)videoCallViewDidHangup:(videoCallViewController *)view;

// Called when stats are enabled by triple tapping.
- (void)videoCallViewDidEnableStats:(videoCallViewController *)view;

@end

@interface videoCallViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *videoScopeLabel;
- (void)initForRoom:(NSString *)room
                 isLoopback:(BOOL)isLoopback
                isAudioOnly:(BOOL)isAudioOnly;
@property(nonatomic, weak) id<ARDVideoCallViewDelegate> delegate;
@property (nonatomic,strong) NSDictionary *infoDictionary;
@property (strong, nonatomic) IBOutlet UILabel *callerName;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;

@property (strong, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) IBOutlet UIButton *endCallButton;
@property (strong, nonatomic) IBOutlet UIButton *muteButton;
@property (strong, nonatomic) IBOutlet RTCEAGLVideoView *localVideoView;
@property (strong, nonatomic) IBOutlet RTCEAGLVideoView *callerVideoView;
@property (assign)    BOOL isDialing;
@property (assign)    BOOL isSpeakerMode;
@property (assign)    BOOL isWithoutVideo;
- (IBAction)switchCamera:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *switchBtn;
- (IBAction)backAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *userImagView;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *videoConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localVideoviewYconstant;

@property (assign)    BOOL isMute;
@property (weak, nonatomic) IBOutlet UIView *buttonMainView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remoteViewRightConstraint;

@property (strong) NSMutableArray *friendesList;

@end
