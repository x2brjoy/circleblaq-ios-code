//
//  ImagePreviewViewController.m
//  Sup
//
//  Created by Rahul Sharma on 2/4/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "ImagePreviewViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "UIImageView+AFNetworking.h"
#import <UIKit/UIKit.h>


@interface ImagePreviewViewController ()<UIScrollViewDelegate>
{
    UIScrollView *imageScrollView;
    BOOL first;
    BOOL close;
}
@property (strong, nonatomic) AVPlayer *avplayer;
@property (strong, nonatomic) AVPlayerViewController *playerViewController;
@property (strong, nonatomic) UIButton *avplayerBtn;

@end

@implementation ImagePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    first = YES;
    close = NO;
    self.navigationController.navigationBar.translucent = NO;
    _avplayerBtn = [[UIButton alloc]init];
    [self plottingDataOnScrollView];
    
    // _mediaList = [[NSMutableArray alloc]init];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    if (close)
        close = NO;
    else
        self.navigationController.navigationBar.translucent = YES;
    
}

-(void)plottingDataOnScrollView
{
    int weidth = [[UIScreen mainScreen] bounds].size.width;
    int hight = [[UIScreen mainScreen] bounds].size.height;
    NSInteger pageCount = _mediaList.count+1;
    
    imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, hight/2-((weidth/2)+32), weidth, weidth)];
    imageScrollView.delegate = self;
    //imageScrollView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:imageScrollView];
    
    
    
    imageScrollView.showsVerticalScrollIndicator = NO;
    imageScrollView.showsHorizontalScrollIndicator = NO;
    imageScrollView.scrollEnabled = YES;
    
    
    imageScrollView.pagingEnabled = YES;
    imageScrollView.contentSize = CGSizeMake(weidth*pageCount, weidth);
    
    
    for (int i = 0; i < pageCount; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.userInteractionEnabled = YES;
        imageView.frame = CGRectMake(weidth*i, 0, weidth, weidth);
        UIButton *avplayerBtn = [[UIButton alloc]initWithFrame:CGRectMake( (imageView.bounds.size.width/2)-15, (imageView.bounds.size.height/2)-15, 30, 30)];
        [avplayerBtn setImage:[UIImage imageNamed:@"play_button"] forState:UIControlStateNormal];
        [imageView addSubview:avplayerBtn];
        [imageView bringSubviewToFront:avplayerBtn];
        avplayerBtn.hidden = YES;
        if (first) {
            imageView.image = _selectedImage;
            first = NO;
        }
        else
        {//int j =i-1;
            avplayerBtn.hidden = NO;
            if ([_mediaList[i-1][@"Types"]intValue] == 2)
            {
                avplayerBtn.tag = i-1;
                [avplayerBtn addTarget:self action:@selector(playClicked:) forControlEvents:UIControlEventTouchUpInside];
                imageView.image = [UIImage imageWithData:_mediaList[i-1][@"Thumbnail"]];
                //
                //                NSData *data = _mediaList[i][@"Image"];
                //                NSString *appFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"video.mp4"];
                //                [data writeToFile:appFile atomically:YES];
                //                _avplayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:appFile]];
                //                /************/
                //                AVPlayerLayer* playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avplayer];
                //               imageView.frame = imageView.bounds;
                //                [imageView.layer addSublayer:playerLayer];
            }
            else
            {
                avplayerBtn.hidden = YES;
                
                if([_mediaList[i-1][@"Types"]integerValue] == 8)
                {
                    NSURL *imageUrl =[NSURL URLWithString:_mediaList[i-1][@"Image"]];
                    NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
                    UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
                    [imageView setImageWithURLRequest:request
                                             placeholderImage:placeholderImage
                                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                         imageView.image = image;
                                                      } failure:nil];
                    
                }
                else
                {
                imageView.image = [UIImage imageWithData:_mediaList[i-1][@"Image"]];
                }
            }
            //imageView.frame = CGRectMake(weidth*i, 0, weidth, weidth);
        }
        imageView.contentMode = UIViewContentModeScaleToFill;
        [imageScrollView addSubview:imageView];
        
        
        // }
    }
    
}

#pragma mak - UIScrollViewDelegates
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if (sender.contentOffset.x != 0) {
        CGPoint offset = sender.contentOffset;
        offset.y = 0;
        sender.contentOffset = offset;
    }
    
    // NSLog(@"ScrollView delegate");
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    UIImageView *imageview;
    if (page == 0)
    {
        imageview.image = _selectedImage;
        
    }
    else
    {
        // imageview.image = _selectedImage;
        
        //imageview.image = [UIImage imageWithData:_mediaList[page][@"Image"]];
        
    }
    
}

-(void)playClicked:(id)sender
{
    close = YES;
    UIButton *selectedButton = (UIButton *)sender;
    
    
  //  NSLog(@"Selected button tag is %d", selectedButton.tag);
    NSData *data = _mediaList[selectedButton.tag][@"Image"] ;
    NSString *appFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"video.mp4"];
    [data writeToFile:appFile atomically:YES];
    _avplayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:appFile]];
    _playerViewController = [AVPlayerViewController new];
    _playerViewController.player = _avplayer;
    [self presentViewController:_playerViewController animated:YES completion:nil];
}

@end
