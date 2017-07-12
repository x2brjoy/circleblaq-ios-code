//
//  PlayVideoViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 06/07/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "VideoFilterViewController.h"
#import "PGShareViewController.h"
#import "FontDetailsClass.h"
#import "ProgressIndicator.h"

@interface VideoFilterViewController ()<SCPlayerDelegate,UIGestureRecognizerDelegate>{
    
}

@end

@implementation VideoFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createNavLeftButton];
    [self createNavRightButton];
    
//    UIImage *image = [UIImage imageNamed:@"comments_back_icon_on"];
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
    self.navigationItem.title =@"Filters";
    [self setNavigationBarTitle];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.9804 green:0.9804 blue:0.9804 alpha:1.0];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.1176 green:0.1176 blue:0.1176 alpha:1.0]}];

    
    
    
    _player = [SCPlayer player];
    
    [_player setItemByUrl:[NSURL URLWithString:_pathOfVideo]];
    if (_recordsession) {
        [_player setItemByAsset:_recordsession.assetRepresentingSegments];
    }
    
    _player.delegate = self;
    
    _playerView.player = _player;
    [_player play];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(startorstopvideoplaying)];
    tap.delegate = self;
    [_playerView addGestureRecognizer:tap];
    _videoplaying = YES;
    _player.loopEnabled = YES;
    self.player.muted = NO;
}

- (void)setNavigationBarTitle {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"video_share_sound_icon_off"] forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:@"video_share_sound_icon_on"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(soundenablebuttonaction:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 40, 40);
    self.navigationItem.titleView = button;
    [_soundbuttonoutlet removeFromSuperview];
}

-(void)viewWillAppear:(BOOL)animated {
   self.navigationController.navigationBarHidden = NO;
}
-(void)viewWillDisappear:(BOOL)animated {
    [_player pause];
}

-(void)startorstopvideoplaying{
    if ( _videoplaying) {
        [_player pause];
        _videoplaying = NO;
        self.playImageViewOutlet.hidden = NO;
    }
    else {
        [_player play];
        self.playImageViewOutlet.hidden = YES;
         _videoplaying = YES;
    }
}
/*--------------------------------------------------------*/
#pragma mark
#pragma mark - navigation bar buttons
/*--------------------------------------------------------*/

- (void)createNavLeftButton {
   UIButton * navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_on"]
                     forState:UIControlStateSelected];
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    [navCancelButton setFrame:CGRectMake(10.0f,0.0f,40,40)];
    // Create a container bar button
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
    // UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithCustomView:segmentView];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

- (void)backButtonClicked {
    if ([self.videoRecorded isEqualToString:@"VideoRecorded"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

//method for creating navigation bar right button.
- (void)createNavRightButton {
    UIButton *navOkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navOkButton setTitle:@"Next"
                 forState:UIControlStateNormal];
    
    [navOkButton setTitleColor:[UIColor colorWithRed:0.1569 green:0.1569 blue:0.1569 alpha:1.0] forState:UIControlStateNormal];
    
    navOkButton.titleLabel.font = [UIFont fontWithName:RobotoMedium size:15];
    [navOkButton setFrame:CGRectMake(0,0,50,30)];
    [navOkButton addTarget:self action:@selector(OKButtonAction:)
          forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navOkButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

-(void)OKButtonAction:(id)sender {
    [_player pause];
    [self performSegueWithIdentifier:@"videoFilterToShareScreenSegue" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue identifeir:cameravideoscreentosharesegue
    if([segue.identifier isEqualToString:@"videoFilterToShareScreenSegue"]) {
        PGShareViewController *videoVC = [segue destinationViewController];
        videoVC.pathOfVideo = self.pathOfVideo;
        videoVC.recordsession = self.recordsession;
        if (_videoData) {
            videoVC.videoData=_videoData;
        }
        videoVC.imageForVideoThumabnailpath = self.thumbnailimageForVideoPath;
        videoVC.videoimg = self.videoimgthumb;
    }
}

-(void)dealloc {
    _player = nil;
}

- (IBAction)soundenablebuttonaction:(UIButton*)sender {
    ProgressIndicator* pi=[[ProgressIndicator alloc]init];
    ProgressIndicator *pi2 =[[ProgressIndicator alloc]init];
    if (self.player.muted) {
        self.player.muted = NO;
        sender.selected=NO;
        [pi2 hideProgressIndicator];
        [pi showMessage:@"Sound On" On:self.playerView];
    }
    else {
        self.player.muted = YES;
        sender.selected=YES;
        [pi hideProgressIndicator];
        [pi2 showMessage:@"Sound Off" On:self.playerView];
    }
}

@end
