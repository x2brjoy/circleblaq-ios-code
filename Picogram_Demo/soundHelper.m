//
//  soundHelper.m
//  Sup
//
//  Created by MacMini on 26/02/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "soundHelper.h"

@implementation soundHelper
@synthesize avPlayer;

-(soundHelper*)init
{
    return self;
}
-(void)beginInterruption
{
   // NSLog(@"interrupted");
}
-(void)playAudioWithUrl:(NSURL*)url repeat:(BOOL)value
{
    if(avPlayer.playing)
    {
        [avPlayer stop];
    }
        if(url)
        {
        NSError *error = nil;
        avPlayer = [[AVAudioPlayer alloc]
                    initWithContentsOfURL:url
                    error:&error];
        if (error)
        {
            NSLog(@"Error in audioPlayer: %@",[error localizedDescription]);
        }
        else
        {
            //avPlayer.delegate = self;
            [avPlayer play];
            if(value)
            [avPlayer setNumberOfLoops:INT16_MAX]; // for continuous play
        }
        }
}
//-(void)switchSpeakerMode:(NSString*)mode
-(void)switchSpeakerMode:(NSString*)mode isMute:(Boolean)isMute
{

    NSError *error = nil;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
   // [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if(isMute)
    {
        [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    } else
    {
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    }
    [session setActive: YES error:nil];
    
    AVAudioSessionPortDescription *routePort = session.currentRoute.outputs.firstObject;
    
    NSString *portType = routePort.portType;
    
   // NSLog(@"Port Type = %@", portType);
    
    if ([mode isEqualToString:@"Receiver"])
    {
       BOOL result = [session  overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        
        //        NSLog(@"Loud Speaker Activated.....");
    }
    else if ([mode isEqualToString:@"Speaker"])
    {
        [session  overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        
        //        NSLog(@"Loud Speaker Activated.....");
    }
    else
    {
        [session  overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        
        //        NSLog(@"Loud Speaker Not Activated.....");
    }
    if(error)
    NSLog(@"%@",error);
    
}

@end
