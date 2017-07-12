//
//  soundHelper.h
//  Sup
//
//  Created by MacMini on 26/02/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface soundHelper : NSObject<AVAudioSessionDelegate>
{
   AVAudioPlayer *avPlayer;
}
@property (nonatomic,strong) AVAudioPlayer *avPlayer;
-(void)playAudioWithUrl:(NSURL*)url repeat:(BOOL)value;
//-(void)switchSpeakerMode:(NSString*)mode;
-(void)switchSpeakerMode:(NSString*)mode isMute:(Boolean)isMute;

@end
