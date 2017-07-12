//
//  InstaVideoTableViewCell.m
//  InstaVideoPlayerExample
//
//  Created by Rahul Sharma on 22/07/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "InstaVideoTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "FontDetailsClass.h"
#import "UserProfileViewController.h"

@interface InstaVideoTableViewCell () <InstagramVideoViewTapDelegate>

@end

@implementation InstaVideoTableViewCell

@synthesize delegate = _delegate;


- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.delegate = nil;
}

- (void)buttonAction {
    
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)pauseVideo:(id)sender {
    [self.videoView pause];
    [self.videoView performSelector:@selector(videoPlayerDidStuck:) withObject:nil];
}

- (void)playVideo:(id)sender {
    [self.videoView resume];
}

- (void)muteVideo:(id)sender {
    if (self.videoView.videoPlayer.mute) {
        [self.videoView unmute];
    } else {
        [self.videoView mute];
    }
}

-(void)notifyCompletelyVisible
{
    [self.videoView resume];
}

-(void)notifyNotCompletelyVisible
{
    //    [self.player pause];
    if(![self isKindOfClass:[InstaVideoTableViewCell class]])
    {
        return;
    }
    [self.videoView pause];
    self.videoView.playingURL = nil;
}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
//{
//    if (object == _videoItem && [keyPath isEqualToString:@"playbackBufferEmpty"])
//    {
//        if (_videoItem.playbackBufferEmpty)
//        {
//            // show loading indicator
//
//            self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
//            NSLog(@"Loading");
//        }
//    }
//
//    if (object == _videoItem && [keyPath isEqualToString:@"playbackLikelyToKeepUp"])
//    {
//        if (_videoItem.playbackLikelyToKeepUp)
//        {
//            // hide loading indicator
//
//            [self.indicator startAnimating];
//
//            NSLog(@"Hide Loading");
//
//            if (_videoItem.status == AVPlayerItemStatusReadyToPlay) {
//                // start playing
//
//                NSLog(@"Start Playing");
//
//            }
//            else if (_videoItem.status == AVPlayerStatusFailed) {
//                // handle failed
//                NSLog(@"failed Playing");
//
//            }
//            else if (_videoItem.status == AVPlayerStatusUnknown) {
//                // handle unknown
//                NSLog(@"failed by unknown error");
//            }
//        }
//    }
//}

-(void)loadImageForCell
{
    
//    NSURL *imageURL = [NSURL URLWithString:_url];
//    
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    [manager downloadImageWithURL:imageURL
//                          options:SDWebImageRefreshCached
//                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                             CGFloat domandeFloat = [[NSNumber numberWithInt:(int) receivedSize] floatValue];
//                             CGFloat corretteFloat = [[NSNumber numberWithInt: (int)expectedSize] floatValue];
//                             
//                             NSLog(@"downloaded size:%f",domandeFloat);
//                             NSLog(@"corrette size:%f",corretteFloat);
//                             self.progressLabel.progress = domandeFloat/corretteFloat;
//                             self.progressLabel.progressWidth = 2;
//                             self.progressLabel.progressColor = [UIColor redColor];
//                             self.progressLabel.trackColor = [UIColor lightGrayColor];
//                             self.progressLabel.text = @"";
//                         }
//                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//                            dispatch_async(dispatch_get_main_queue(), ^{
//                                            [self.imageViewOutlet sd_setImageWithURL:imageURL];
//                                        });
//                          
//        }];
    
    
    
    
    NSURL *imageURL = [NSURL URLWithString:_url];
    
    NSURL *placeholder = [NSURL URLWithString:_placeHolderUrl];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:placeholder];
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            _placeHolderImage = [UIImage imageWithData:imageData];
            _placeHolderImage = [UIImage imageNamed:@""];
        });
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
    });
    if([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:_url]]){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.imageViewOutlet setImage: [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_url]];
        });
    }
    else
    {
        [self.imageViewOutlet sd_setImageWithURL:imageURL placeholderImage:_placeHolderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageViewOutlet.image = image;
            });
        }];
    }
}

-(void)loadVideoForCellFromLinkwithUrl:(NSString *)urlString
{
    if(!urlString)
    {
        NSLog(@"URL is not available");
    }
    urlString = [urlString stringByReplacingCharactersInRange:NSMakeRange(urlString.length-3, 3) withString:@"mp4"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoView playVideoWithURL:[NSURL URLWithString:urlString]];
    });
}

-(InstagramVideoView *)videoView
{
    if(!_videoView)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            _videoView = [[InstagramVideoView alloc] initWithFrame:self.contentView.frame];
            [self.contentView addSubview:_videoView];
            
            _videoView.delegate = self;
        });
    }
    return _videoView;
}

- (IBAction)showTagsButtonAction:(id)sender {
}

- (void)videoViewDidSingleTap:(InstagramVideoView *)view {
    if ([self.postType isEqualToString:@"0"]) {
            if ([self.delegate respondsToSelector:@selector(delegateForSingleTapCell:)])
                [self.delegate delegateForSingleTapCell:self];
    }
}

- (void)videoViewDidDoubleTap:(InstagramVideoView *)view {
    
    if ([self.delegate respondsToSelector:@selector(delegateFordoubLeTapCell:)])
        [self.delegate delegateFordoubLeTapCell:self];
}


@end
