//
//  TWImageScrollView.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "TWImageScrollView.h"

@interface TWImageScrollView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate,SCPlayerDelegate>
{
    CGSize _imageSize;
    UIImage *selectedImage;
    int type;
    SCPlayer* player;
    BOOL videoPlaying;
}
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) SCVideoPlayerView *videoView;
@end

@implementation TWImageScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = YES;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter;
    if (type==1) {
        frameToCenter= self.imageView.frame;
    }else{
        frameToCenter= self.videoView.frame;
    }
    
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    if (type==1) {
        self.imageView.frame = frameToCenter;
    }else{
        self.videoView.frame = frameToCenter;
    }
}

- (UIImage *)capture {
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
    
    [self drawViewHierarchyInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)displayImage:(UIImage *)image
{
    type=1;
    [player pause];
    player=nil;
    [self.imageView removeFromSuperview];
    [self.videoView removeFromSuperview];
    self.imageView = nil;
    self.videoView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    //self.zoomScale = 1.0;
    
    // make a new UIImageView for the new image
    self.imageView = [[UIImageView alloc] initWithImage:image];
    self.imageView.clipsToBounds = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.imageView];
    
    CGRect frame = self.imageView.frame;
    if (image.size.height > image.size.width) {
        frame.size.width = self.bounds.size.width;
        frame.size.height = (self.bounds.size.width / image.size.width) * image.size.height;
    } else {
        frame.size.height = self.bounds.size.height;
        frame.size.width = (self.bounds.size.height / image.size.height) * image.size.width;
    }
    frame.size.height =320;
    frame.size.width = 320;
    if (image.size.height>image.size.width) {
        frame.size.height =self.bounds.size.height;
        frame.size.width=(self.bounds.size.height*image.size.width)/image.size.height;
        frame.origin.y=0;
        frame.origin.x=(self.bounds.size.width-frame.size.width)/2;
    }else if(image.size.height<image.size.width){
        frame.size.height =(self.bounds.size.width*image.size.height)/image.size.width;
        frame.size.width=self.bounds.size.width;
        frame.origin.y=(self.bounds.size.height-frame.size.height)/2;
        frame.origin.x=0;
    }else{
        frame.size.height =self.bounds.size.height;
        frame.size.width=self.bounds.size.width;
        frame.origin.y=0;
        frame.origin.x=0;
    }
    self.imageView.frame = frame;
    [self configureForImageSize:self.imageView.bounds.size];
}

- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    self.contentSize = imageSize;

//    self.contentOffset = CGPointMake((self.bounds.size.width-imageSize.width)/2, (self.bounds.size.height-imageSize.height)/2);
    
    [self setMaxMinZoomScalesForCurrentBounds];
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    float scaleWidth=self.bounds.size.width/_imageSize.width;
    float scaleHeight=self.bounds.size.height/_imageSize.height;
    float scale=scaleWidth;
    if (scaleHeight>scaleWidth) {
        scale=scaleHeight;
    }else if(scaleHeight==scaleWidth){
        scale=1;
    }
//    if (scale>1) {
//        scale-=1;
//    }
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 3.0;
    self.zoomScale=scale;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (type==1) {
        return self.imageView;
    }
    return self.videoView;
}



- (void)displayVideo:(NSURL *)url h:(float)hight w:(float)width
{
    type=2;
    // clear the previous image
    [player pause];
    player=nil;
    [self.imageView removeFromSuperview];
    [self.videoView removeFromSuperview];
    self.imageView = nil;
    self.videoView = nil;
    
    // make a new UIImageView for the new image
    self.videoView = [[SCVideoPlayerView alloc] init];
    self.videoView.clipsToBounds = NO;
    self.videoView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.videoView];
    
    CGRect frame = self.videoView.frame;
    if (hight > width) {
        frame.size.width = self.bounds.size.width;
        frame.size.height = (self.bounds.size.width / width) * hight;
    } else {
        frame.size.height = self.bounds.size.height;
        frame.size.width = (self.bounds.size.height / hight) * width;
    }
    frame.size.height =320;
    frame.size.width = 320;
    if (hight>width) {
        frame.size.height =self.bounds.size.height;
        frame.size.width=(self.bounds.size.height*width)/hight;
        frame.origin.y=0;
        frame.origin.x=(self.bounds.size.width-frame.size.width)/2;
    }else if(hight<width){
        frame.size.height =(self.bounds.size.width*hight)/width;
        frame.size.width=self.bounds.size.width;
        frame.origin.y=(self.bounds.size.height-frame.size.height)/2;
        frame.origin.x=0;
    }else{
        frame.size.height =self.bounds.size.height;
        frame.size.width=self.bounds.size.width;
        frame.origin.y=0;
        frame.origin.x=0;
    }
    self.videoView.frame = frame;
    player = [SCPlayer player];
    [player setItemByUrl:url];
    player.delegate = self;
    _videoView.player = player;
    [player play];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(startorstopvideoplaying)];
    tap.delegate = self;
    [_videoView addGestureRecognizer:tap];
    videoPlaying = YES;
    player.loopEnabled = YES;
    player.muted = NO;
  //  [self configureForImageSize:self.videoView.bounds.size];
}


-(void)startorstopvideoplaying{
    if ( videoPlaying) {
        [player pause];
        videoPlaying = NO;
    }
    else {
        [player play];
        videoPlaying = YES;
    }
}
-(void)dealloci{
    [player pause];
}
@end


