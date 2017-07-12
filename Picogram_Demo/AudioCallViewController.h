//
//  AudioCallViewController.h
//  Sup
//
//  Created by Mac on 23/02/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARDAppClient.h"

@interface AudioCallViewController : UIViewController
{
    
}
@property (assign) BOOL isDialing;
@property (strong, nonatomic) NSMutableDictionary *dataDictionary;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UIButton *muteButton;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (strong, nonatomic) IBOutlet UIButton *speakerButton;
@property (strong, nonatomic) IBOutlet UIButton *endCallButton;
@property (assign)    BOOL isSpeakerMode;
@property (weak, nonatomic) IBOutlet UILabel *muteLbl;
@property (weak, nonatomic) IBOutlet UILabel *speakerLbl;
@property (weak, nonatomic) IBOutlet UILabel *videoLbl;

//IBActions/Selectors
- (IBAction)endMyCall:(id)sender;
- (IBAction)muteMyCall:(id)sender;
- (IBAction)sendMessage:(id)sender;
- (IBAction)enableLoudSpearker:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *audioView;

@property (assign)    BOOL isMute;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endBtnHeightContstant;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageCont;

@property (strong) NSMutableArray *friendesList;

@end
