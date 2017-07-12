//
//  SOMessageCell.m
//  SOMessaging
//
// Created by : arturdev
// Copyright (c) 2014 SocialObjects Software. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#import "SOMessageCell.h"
#import "NSString+Calculation.h"
#import "MBProgressHUD.h"
#import "ProgressIndicator.h"
#import "KILabel.h"
#import "Helper.h"


@interface SOMessageCell() < UIGestureRecognizerDelegate>
{
    BOOL isHorizontalPan;
}
@property (nonatomic) CGSize mediaImageViewSize;
@property (nonatomic) CGSize userImageViewSize;
@property (nonatomic) CGSize postImageViewSize;

@end

@implementation SOMessageCell

static CGFloat messageTopMargin;
static CGFloat messageBottomMargin;
static CGFloat messageLeftMargin;
static CGFloat messageRightMargin;

static CGFloat maxContentOffsetX;
static CGFloat contentOffsetX;

static CGFloat initialTimeLabelPosX;
static BOOL cellIsDragging;

+ (void)load
{
    [self setDefaultConfigs];
}

+ (void)setDefaultConfigs
{
    messageTopMargin = 9;
    messageBottomMargin = 9;
    messageLeftMargin = 15;
    messageRightMargin = 15;
    
    contentOffsetX = 0;
    maxContentOffsetX = 50;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier messageMaxWidth:(CGFloat)messageMaxWidth
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.messageMaxWidth = messageMaxWidth;
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.panGesture.delegate = self;
        [self addGestureRecognizer:self.panGesture];
        
        [self setInitialSizes];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationWillChandeNote:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    }
    
    return self;
}

- (void)setInitialSizes
{
    if (self.containerView) {
        [self.containerView removeFromSuperview];
    }
    if (self.timeLabel) {
        [self.timeLabel removeFromSuperview];
    }
    
    if (!self.userImageView) {
        self.userImageView = [[UIImageView alloc] init];
    }
    self.userImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    if (!self.textView) {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.messageMaxWidth, 0)];
    }
    if (!self.timeLabel) {
        self.timeLabel = [[UILabel alloc] init];
    }
    if (!self.mediaImageView) {
        self.mediaImageView = [[UIImageView alloc] init];
    }
    if (!self.mediaOverlayView) {
        self.mediaOverlayView = [[UIView alloc] init];
    }
    if (!self.balloonImageView) {
        self.balloonImageView = [[UIImageView alloc] init];
      
    }
    
    // For Post use
    
    if (!self.postOverlayView) {
        self.postOverlayView = [[UIView alloc]init];
    }
    if (!self.postImageView) {
        self.postImageView = [[UIImageView alloc]init];
    }
    if (!self.postContentTopView) {
        self.postContentTopView = [[UIView alloc]init];
    }
    if (!self.postContentDownView) {
        self.postContentDownView = [[UIView alloc]init];
    }
    
    if (!CGSizeEqualToSize(self.userImageViewSize, CGSizeZero)) {
        CGRect frame = self.userImageView.frame;
        frame.size = self.userImageViewSize;
        self.userImageView.frame = frame;
    }
    
    self.userImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.userImageView.clipsToBounds = YES;
    self.userImageView.backgroundColor = [UIColor clearColor];
    self.userImageView.layer.cornerRadius = 5;
    
    if (!CGSizeEqualToSize(self.mediaImageViewSize, CGSizeZero)) {
        CGRect frame = self.mediaImageView.frame;
        frame.size = self.mediaImageViewSize;
        self.mediaImageView.frame = frame;
    }
    if (!CGSizeEqualToSize(self.postImageViewSize, CGSizeZero)) {
        CGRect frame = self.postImageView.frame;
        frame.size = self.postImageViewSize;
        self.postImageView.frame = frame;
    }
    self.postImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.postImageView.clipsToBounds = YES;
    self.postImageView.backgroundColor = [UIColor clearColor];
    self.postImageView.userInteractionEnabled = YES;
    //    self.mediaImageView.layer.cornerRadius = 10;
    UITapGestureRecognizer *tapPost = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handelPostTapped:)];
    [self.postImageView addGestureRecognizer:tapPost];
    
    self.postContentTopView.backgroundColor = [UIColor grayColor];
    [self.mediaImageView addSubview:self.postContentTopView];
    
    self.postContentDownView.backgroundColor = [UIColor grayColor];
    [self.mediaImageView addSubview:self.postContentDownView];
    
    
    self.mediaImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.mediaImageView.clipsToBounds = YES;
    self.mediaImageView.backgroundColor = [UIColor clearColor];
    self.mediaImageView.userInteractionEnabled = YES;
    //    self.mediaImageView.layer.cornerRadius = 10;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMediaTapped:)];
    [self.mediaImageView addGestureRecognizer:tap];
    
    self.mediaOverlayView.backgroundColor = [UIColor clearColor];
    [self.mediaImageView addSubview:self.mediaOverlayView];
    
    self.textView.textColor = [UIColor whiteColor];
    self.textView.backgroundColor = [UIColor clearColor];
    [self.textView setTextContainerInset:UIEdgeInsetsZero];
    self.textView.textContainer.lineFragmentPadding = 0;
    
    [self hideSubViews];
    
    if (!self.containerView) {
        self.containerView = [[UIView alloc] initWithFrame:self.contentView.bounds];
    }
    
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    [self.contentView addSubview:self.containerView];
    
    [self.containerView addSubview:self.balloonImageView];
    [self.containerView addSubview:self.textView];
    [self.containerView addSubview:self.mediaImageView];
    [self.containerView addSubview:self.userImageView];
    
    [self.contentView addSubview:self.timeLabel];
    
    self.contentView.clipsToBounds = NO;
    self.clipsToBounds = NO;
    
    self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    self.timeLabel.textColor = [UIColor grayColor];
    self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    
    
    
}

- (void)hideSubViews
{
    self.userImageView.hidden = YES;
    self.textView.hidden = YES;
    self.mediaImageView.hidden = YES;
}

- (void)setMediaImageViewSize:(CGSize)size
{
    _mediaImageViewSize = size;
    CGRect frame = self.mediaImageView.frame;
    frame.size = size;
    self.mediaImageView.frame = frame;
}

-(void)setPostImageViewSize:(CGSize)size
{
    _postImageViewSize = size;
    CGRect frame = self.postImageView.frame;
    frame.size = size;
    self.postImageView.frame = frame;
}

- (void)setUserImageViewSize:(CGSize)size
{
    _userImageViewSize = size;
    CGRect frame = self.userImageView.frame;
    frame.size = size;
    self.userImageView.frame = frame;
}

- (void)setUserImage:(UIImage *)userImage
{
    _userImage = userImage;
    if (!userImage) {
        self.userImageViewSize = CGSizeZero;
    }
    [self adjustCell];
}
#pragma mark -
- (void)handleMediaTapped:(UITapGestureRecognizer *)tap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:didTapMedia:)]) {
        [self.delegate messageCell:self didTapMedia:self.message.media];
    }
}
- (void)handelPostTapped:(UITapGestureRecognizer *)tap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCell:didTapPost:)]) {
        [self.delegate messageCell:self didTapPost:self.message.postData];
    }
}
#pragma mark -
- (void)setMessage:(id<SOMessage>)message
{
    _message = message;
    
    [self setInitialSizes];
    //    [self adjustCell];
}

- (void)adjustCell
{
    [self hideSubViews];
    
    if (self.message.type == SOMessageTypeText) {
        self.textView.hidden = NO;
        [self adjustForTextOnly];
    } else if (self.message.type == SOMessageTypePhoto) {
        self.mediaImageView.hidden = NO;
        self.mediaOverlayView.hidden = YES;
        [self adjustForPhotoOnly];
    } else if (self.message.type == SOMessageTypeVideo) {
        self.mediaImageView.hidden = NO;
        self.mediaOverlayView.hidden = NO;
        [self adjustForVideoOnly];
    }else if (self.message.type == SOMessageTypeLocation){
        self.mediaImageView.hidden = NO;
        self.mediaOverlayView.hidden = YES;
        [self adjustForPhotoOnly];
    }
    else if (self.message.type  == SOMessageTypeContact){
        self.mediaImageView.hidden = NO;
        self.mediaOverlayView.hidden = YES;
        [self adjustForPhotoOnly];
    }
    else if (self.message.type == SOMessageTypeVoice){
        self.mediaImageView.hidden = NO;
        self.mediaOverlayView.hidden = YES;
        [self adjustForPhotoOnly];
    }
    else if (self.message.type == SOMessageTypePost) {
        self.mediaImageView.hidden = NO;
        self.mediaOverlayView.hidden = YES;
        
        
        
        //         10000000
        [self adjustForSharePostOnly];
    }
    else if (self.message.type == SOMessageTypeOther) {
        if (!CGSizeEqualToSize(self.userImageViewSize, CGSizeZero) && self.userImage) {
            self.userImageView.hidden = NO;
        }
    }
    
    
    self.containerView.autoresizingMask = self.message.fromMe ? UIViewAutoresizingFlexibleLeftMargin : UIViewAutoresizingFlexibleRightMargin;
    initialTimeLabelPosX = self.timeLabel.frame.origin.x;
    /*
     --  Not implemented ---
     else if (self.message.type & (SOMessageTypePhoto | SOMessageTypeText)) {
     self.textView.hidden = NO;
     self.mediaImageView.hidden = NO;
     } else if (self.message.type & (SOMessageTypeVideo | SOMessageTypeText)) {
     self.textView.hidden = NO;
     self.mediaImageView.hidden = NO;
     }
     */
    
}

- (void)adjustForTextOnly
{
    CGFloat userImageViewLeftMargin = 3;
    
    CGRect usedFrame = [self usedRectForWidth:self.messageMaxWidth];;
    if (self.balloonMinWidth) {
        CGFloat messageMinWidth = self.balloonMinWidth - messageLeftMargin - messageRightMargin;
        if (usedFrame.size.width <  messageMinWidth) {
            usedFrame.size.width = messageMinWidth;
            usedFrame.size.height = [self usedRectForWidth:messageMinWidth].size.height;
        }
    }
    
    CGFloat messageMinHeight = self.balloonMinHeight - messageTopMargin - messageBottomMargin;
    
    if (self.balloonMinHeight && usedFrame.size.height < messageMinHeight) {
        usedFrame.size.height = messageMinHeight;
    }
    
    self.textView.font = self.messageFont;
    self.textView.textColor = [UIColor colorWithRed:40.0f/255.0f green:40.0f/255.0f blue:40.0f/255.0f alpha:1.0f];
    CGRect frame = self.textView.frame;
    frame.size.width  = usedFrame.size.width;
    frame.size.height = usedFrame.size.height;
    frame.origin.y = messageTopMargin;
    
    CGRect balloonFrame = self.balloonImageView.frame;
    balloonFrame.size.width = frame.size.width + messageLeftMargin + messageRightMargin;
    balloonFrame.size.height = frame.size.height + messageTopMargin + messageBottomMargin;
    balloonFrame.origin.y = 0;
    frame.origin.x = self.message.fromMe ? messageLeftMargin : (balloonFrame.size.width - frame.size.width - messageLeftMargin);
    if (!self.message.fromMe && self.userImage) {
        frame.origin.x += userImageViewLeftMargin + self.userImageViewSize.width;
        balloonFrame.origin.x = userImageViewLeftMargin + self.userImageViewSize.width;
    }
    
    frame.origin.x += self.contentInsets.left - self.contentInsets.right;
    
    self.textView.frame = frame;
    
    CGRect userRect = self.userImageView.frame;
    
    if (!CGSizeEqualToSize(userRect.size, CGSizeZero) && self.userImage) {
        if (balloonFrame.size.height < userRect.size.height) {
            balloonFrame.size.height = userRect.size.height;
        }
    }
    
    self.balloonImageView.frame = balloonFrame;
    self.balloonImageView.backgroundColor = [UIColor clearColor];
    self.balloonImageView.image = self.balloonImage;
    
    self.textView.editable = NO;
    self.textView.scrollEnabled = NO;
    self.textView.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber;
    
    
    
    if (self.userImageView.autoresizingMask & UIViewAutoresizingFlexibleTopMargin) {
        userRect.origin.y = balloonFrame.origin.y + balloonFrame.size.height - userRect.size.height;
    } else {
        userRect.origin.y = 0;
    }
    
    if (self.message.fromMe) {
        userRect.origin.x = balloonFrame.origin.x + userImageViewLeftMargin + balloonFrame.size.width;
    } else {
        userRect.origin.x = balloonFrame.origin.x - userImageViewLeftMargin - userRect.size.width;
    }
    self.userImageView.frame = userRect;
    self.userImageView.image = self.userImage;
    
    CGRect frm = self.containerView.frame;
    frm.origin.x = self.message.fromMe ? self.contentView.frame.size.width - balloonFrame.size.width - kBubbleRightMargin : kBubbleLeftMargin;
    frm.origin.y = kBubbleTopMargin;
    frm.size.height = balloonFrame.size.height;
    frm.size.width = balloonFrame.size.width;
    if (!CGSizeEqualToSize(userRect.size, CGSizeZero) && self.userImage) {
        self.userImageView.hidden = NO;
        frm.size.width += userImageViewLeftMargin + userRect.size.width;
        if (self.message.fromMe) {
            frm.origin.x -= userImageViewLeftMargin + userRect.size.width;
        }
    }
    
    
    if (frm.size.height < self.userImageViewSize.height) {
        CGFloat delta = self.userImageViewSize.height - frm.size.height;
        frm.size.height = self.userImageViewSize.height;
        
        for (UIView *sub in self.containerView.subviews) {
            CGRect fr = sub.frame;
            fr.origin.y += delta;
            sub.frame = fr;
        }
    }
    self.containerView.frame = frm;
    
    // Adjusing time label
    NSDateFormatter *formatter = [self DateFormatter];
    self.timeLabel.frame = CGRectZero;
    self.timeLabel.text = [formatter stringFromDate:self.message.date];
    
    [self.timeLabel sizeToFit];
    CGRect timeLabel = self.timeLabel.frame;
    timeLabel.origin.x = self.contentView.frame.size.width + 5;
    self.timeLabel.frame = timeLabel;
    self.timeLabel.center = CGPointMake(self.timeLabel.center.x, self.containerView.center.y);
    
}

- (CGRect)usedRectForWidth:(CGFloat)width
{
    CGRect usedFrame = CGRectZero;
    
    if (self.message.attributes) {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.message.text attributes:self.message.attributes];
        self.textView.attributedText = attributedText;
        usedFrame.size = [self.message.text usedSizeForMaxWidth:width withAttributes:self.message.attributes];
    } else {
        self.textView.text = self.message.text;
        usedFrame.size = [self.message.text usedSizeForMaxWidth:width withFont:self.messageFont];
    }
    
    return usedFrame;
}

- (void)adjustForPostOnly
{
    CGFloat userImageViewLeftMargin = 3;
    _postDataComp = [[NSDictionary alloc]init];
    
    NSArray *singlePostDetails  = [[NSArray alloc]initWithObjects:self.message.postData,nil];
    //    NSLog(@"%@",cell.message.media);
    if([singlePostDetails count ] == 0)
    {
        singlePostDetails  = [[NSArray alloc]initWithObjects:self.message.media,nil];
    }
    
    //Download Photo
    NSLog(@"%@",self.message.postData);
    
    _postDataComp = [singlePostDetails firstObject];
    NSString *url = _postDataComp[@"thumbnailImageUrl"];
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            // WARNING: is the cell still using the same data by this point??
            self.mediaImageView.image = [UIImage imageWithData: data];
        });
        
    });
    
    
    
    
    
    
    CGRect frame = CGRectZero;
    frame.size = self.mediaImageViewSize;
    
    if (!self.message.fromMe && self.userImage) {
        frame.origin.x += userImageViewLeftMargin + self.userImageViewSize.width;
    }
    
    self.mediaImageView.frame = frame;
    self.balloonImageView.frame = frame;
    self.balloonImageView.image = self.balloonImage;
    
    CGRect userRect = self.userImageView.frame;
    if (self.userImageView.autoresizingMask & UIViewAutoresizingFlexibleTopMargin) {
        userRect.origin.y = frame.origin.y + frame.size.height - userRect.size.height;
    } else {
        userRect.origin.y = 0;
    }
    
    if (self.message.fromMe) {
        userRect.origin.x = frame.origin.x + userImageViewLeftMargin + frame.size.width;
    } else {
        userRect.origin.x = frame.origin.x - userImageViewLeftMargin - userRect.size.width;
    }
    self.userImageView.frame = userRect;
    self.userImageView.image = self.userImage;
    
    CGRect frm = self.containerView.frame;
    frm.origin.x = self.message.fromMe ? self.contentView.frame.size.width - frame.size.width - kBubbleRightMargin : kBubbleLeftMargin;
    frm.origin.y = kBubbleTopMargin;
    frm.size.width = frame.size.width;
    if (!CGSizeEqualToSize(userRect.size, CGSizeZero) && self.userImage) {
        self.userImageView.hidden = NO;
        frm.size.width += userImageViewLeftMargin + userRect.size.width;
        if (self.message.fromMe) {
            frm.origin.x -= userImageViewLeftMargin + userRect.size.width;
        }
    }
    
    frm.size.height = frame.size.height;
    if (frm.size.height < self.userImageViewSize.height) {
        CGFloat delta = self.userImageViewSize.height - frm.size.height;
        frm.size.height = self.userImageViewSize.height;
        
        for (UIView *sub in self.containerView.subviews) {
            CGRect fr = sub.frame;
            fr.origin.y += delta;
            sub.frame = fr;
        }
    }
    self.containerView.frame = frm;
    
    //Masking mediaImageView with balloon image
    CALayer *layer = self.balloonImageView.layer;
    layer.frame    = (CGRect){{0,0},self.balloonImageView.layer.frame.size};
    self.mediaImageView.layer.mask = layer;
    [self.mediaImageView setNeedsDisplay];
    
    
    // Adjusing time label
    NSDateFormatter *formatter = [self DateFormatter];
    self.timeLabel.frame = CGRectZero;
    self.timeLabel.text = [formatter stringFromDate:self.message.date];
    
    [self.timeLabel sizeToFit];
    CGRect timeLabel = self.timeLabel.frame;
    timeLabel.origin.x = self.contentView.frame.size.width + 5;
    self.timeLabel.frame = timeLabel;
    self.timeLabel.center = CGPointMake(self.timeLabel.center.x, self.containerView.center.y);
    
}


- (void)adjustForPhotoOnly
{
    CGFloat userImageViewLeftMargin = 3;
    NSLog(@"%@",self.message.postData);
    if (self.message.fromMe == YES) {
        
        UIImage *image = self.message.thumbnail;
        if (!image) {
            
            NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir  = [documentPaths objectAtIndex:0];
            NSString *movieName = [NSString stringWithFormat:@"%@.jpg",self.message.messageID];
            NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
            image = [UIImage imageWithContentsOfFile:moviePath];
            
            // image = [[UIImage alloc] initWithData:self.message.media];
        }
        self.mediaImageView.image = image;
        
        
    }else{
        
        if (self.message.isUrlDownloaded == YES) {
            
            NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir  = [documentPaths objectAtIndex:0];
            NSString *movieName = [NSString stringWithFormat:@"%@.jpg",self.message.messageID];
            NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
            self.mediaImageView.image = [UIImage imageWithContentsOfFile:moviePath];
            
            //self.mediaImageView.image = [[UIImage alloc] initWithData:self.message.media];
            
            if (self.message.type == SOMessageTypeVideo ) {
                UIImage *image = self.message.thumbnail;
                self.mediaImageView.image = image;
                
            }
            if (self.message.type == SOMessageTypePost ) {
                UIImage *image = @"";
                self.mediaImageView.image = image;
                
            }
            
        }else{
            
            
            
            if (self.message.type == SOMessageTypePhoto || self.message.type ==SOMessageTypeVideo ) {
                
                self.mediaImageView.image = self.message.thumbnail;
                UIImageView *downloadImg = [[UIImageView alloc]initWithFrame:CGRectMake(self.mediaImageView.frame.size.width/2 -15,self.mediaImageView.frame.size.height/2-15,30,30)];
                downloadImg.image = [UIImage imageNamed:@"download_new_icon"];
                [self.mediaImageView addSubview:downloadImg];
                [self.mediaImageView bringSubviewToFront:downloadImg];
                
                UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0,downloadImg.frame.size.height+downloadImg.frame.origin.y-4,self.mediaImageView.frame.size.width,30)];
                lbl.textColor = [UIColor whiteColor];
                lbl.font = [UIFont fontWithName:@"Roboto-Bold" size:10];
                lbl.textAlignment = UITextAlignmentCenter;
                NSInteger size =   [self.message.dataSize integerValue];
                NSString *kb= @"kb";
                //  NSLog(@"size =%ld",(long)size);
                size = size/1024;
                
                if (size>1024) {
                    size = size/1024;
                    kb = @"mb";
                }
                lbl.text = [NSString stringWithFormat:@"%ld %@",(long)size,kb];
                [self.mediaImageView addSubview:lbl];
                
            }if(self.message.type ==SOMessageTypePost)
            {
              
                self.mediaImageView.image = nil;
                
            }
            else{
                
                UIImage *image = self.message.thumbnail;
                if (!image) {
                    image = [[UIImage alloc] initWithData:self.message.media];
                }
                self.mediaImageView.image = image;
                
            }
            
            
            
        }
    }
    
    
    
    CGRect frame = CGRectZero;
    frame.size = self.mediaImageViewSize;
    
    if (!self.message.fromMe && self.userImage) {
        frame.origin.x += userImageViewLeftMargin + self.userImageViewSize.width;
    }
    
    self.mediaImageView.frame = frame;
    self.balloonImageView.frame = frame;
    self.balloonImageView.image = self.balloonImage;
    
    CGRect userRect = self.userImageView.frame;
    if (self.userImageView.autoresizingMask & UIViewAutoresizingFlexibleTopMargin) {
        userRect.origin.y = frame.origin.y + frame.size.height - userRect.size.height;
    } else {
        userRect.origin.y = 0;
    }
    
    if (self.message.fromMe) {
        userRect.origin.x = frame.origin.x + userImageViewLeftMargin + frame.size.width;
    } else {
        userRect.origin.x = frame.origin.x - userImageViewLeftMargin - userRect.size.width;
    }
    self.userImageView.frame = userRect;
    self.userImageView.image = self.userImage;
    
    CGRect frm = self.containerView.frame;
    frm.origin.x = self.message.fromMe ? self.contentView.frame.size.width - frame.size.width - kBubbleRightMargin : kBubbleLeftMargin;
    frm.origin.y = kBubbleTopMargin;
    frm.size.width = frame.size.width;
    if (!CGSizeEqualToSize(userRect.size, CGSizeZero) && self.userImage) {
        self.userImageView.hidden = NO;
        frm.size.width += userImageViewLeftMargin + userRect.size.width;
        if (self.message.fromMe) {
            frm.origin.x -= userImageViewLeftMargin + userRect.size.width;
        }
    }
    
    frm.size.height = frame.size.height;
    if (frm.size.height < self.userImageViewSize.height) {
        CGFloat delta = self.userImageViewSize.height - frm.size.height;
        frm.size.height = self.userImageViewSize.height;
        
        for (UIView *sub in self.containerView.subviews) {
            CGRect fr = sub.frame;
            fr.origin.y += delta;
            sub.frame = fr;
        }
    }
    self.containerView.frame = frm;
    
    //Masking mediaImageView with balloon image
    CALayer *layer = self.balloonImageView.layer;
    layer.frame    = (CGRect){{0,0},self.balloonImageView.layer.frame.size};
    self.mediaImageView.layer.mask = layer;
    [self.mediaImageView setNeedsDisplay];
    
    
    // Adjusing time label
    NSDateFormatter *formatter = [self DateFormatter];
    self.timeLabel.frame = CGRectZero;
    self.timeLabel.text = [formatter stringFromDate:self.message.date];
    
    [self.timeLabel sizeToFit];
    CGRect timeLabel = self.timeLabel.frame;
    timeLabel.origin.x = self.contentView.frame.size.width + 5;
    self.timeLabel.frame = timeLabel;
    self.timeLabel.center = CGPointMake(self.timeLabel.center.x, self.containerView.center.y);
}

- (void)adjustForVideoOnly
{
    [self adjustForPhotoOnly];
    
    CGRect frame = self.mediaOverlayView.frame;
    frame.origin = CGPointZero;
    frame.size   = self.mediaImageView.frame.size;
    self.mediaOverlayView.frame = frame;
    
    [self.mediaOverlayView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = self.mediaImageView.bounds;
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.4f;
    [self.mediaOverlayView addSubview:bgView];
    
    UIImageView *playButtonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_button.png"]];
    playButtonImageView.contentMode = UIViewContentModeScaleAspectFit;
    playButtonImageView.clipsToBounds = YES;
    playButtonImageView.backgroundColor = [UIColor clearColor];
    CGRect playFrame = playButtonImageView.frame;
    playFrame.size   = CGSizeMake(20, 20);
    playButtonImageView.frame = playFrame;
    playButtonImageView.center = CGPointMake(self.mediaOverlayView.frame.size.width/2 + self.contentInsets.left - self.contentInsets.right, self.mediaOverlayView.frame.size.height/2);
    [self.mediaOverlayView addSubview:playButtonImageView];
}

- (void)adjustForSharePostOnly
{
    //    10000000
    [self adjustForPostOnly];
    self.backgroundView.backgroundColor = [UIColor lightGrayColor];
    CGRect frame = self.postOverlayView.frame;
    frame.origin = CGPointZero;
    frame.size   = self.postImageView.frame.size;
    self.postOverlayView.frame = frame;
    
    UIImageView *playButtonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play_button.png"]];
    playButtonImageView.contentMode = UIViewContentModeScaleAspectFit;
    playButtonImageView.clipsToBounds = YES;
    playButtonImageView.backgroundColor = [UIColor clearColor];
    CGRect playFrame = playButtonImageView.frame;
    playFrame.size   = CGSizeMake(20, 20);
    playButtonImageView.frame = playFrame;
    playButtonImageView.center = CGPointMake(self.postOverlayView.frame.size.width/2 + self.contentInsets.left - self.contentInsets.right, self.postOverlayView.frame.size.height/2);
    [self.postOverlayView addSubview:playButtonImageView];
    UIView *postTop ;
    UIView *postButtom ;
    
    
    if(self.message.fromMe)
    {
        postButtom = [[UIView alloc] initWithFrame:CGRectMake(3, self.containerView.frame.size.height-40 , self.containerView.frame.size.width-6, 40)];
        postTop = [[UIView alloc] initWithFrame:CGRectMake(3, 0, self.containerView.frame.size.width-6, 30)];
        postButtom.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:234.0/255.0 blue:235.0/255.0 alpha:1.0];
        postTop.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:234.0/255.0 blue:235.0/255.0 alpha:1.0];
    }
    else
    {
        postButtom = [[UIView alloc] initWithFrame:CGRectMake(3, self.containerView.frame.size.height-40 , self.containerView.frame.size.width-6, 40)];
        postTop = [[UIView alloc] initWithFrame:CGRectMake(3, 0, self.containerView.frame.size.width-6, 30)];
        postButtom.backgroundColor = [UIColor whiteColor];
        postTop.backgroundColor = [UIColor whiteColor];
        [postButtom.layer setBorderColor: [[UIColor colorWithRed:235.0/255.0 green:234.0/255.0 blue:235.0/255.0 alpha:1.0] CGColor]];
        [postButtom.layer setBorderWidth: 1.0];
        [postTop.layer setBorderColor: [[UIColor colorWithRed:235.0/255.0 green:234.0/255.0 blue:235.0/255.0 alpha:1.0] CGColor]];
        [postTop.layer setBorderWidth: 1.0];
    }
    
    [self.containerView addSubview:postTop];
    [self.containerView addSubview:postButtom];
  
    
    [self.mediaImageView.layer setBorderColor: [[UIColor colorWithRed:235.0/255.0 green:234.0/255.0 blue:235.0/255.0 alpha:1.0] CGColor]];
    [self.mediaImageView.layer setBorderWidth: 1.0];

    
    UIImageView *userPhoto = [[UIImageView alloc]initWithFrame:CGRectMake(10,8,14,14)];
    
    NSString *userUrl = _postDataComp[@"profilePicUrl"];
    if(![userUrl isEqualToString:@"<null>"])
    {
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: userUrl]];
            if ( data == nil )
                return;
            dispatch_async(dispatch_get_main_queue(), ^{
                // WARNING: is the cell still using the same data by this point??
                userPhoto.image = [UIImage imageWithData: data];
                userPhoto.layer.cornerRadius = userPhoto.frame.size.width/2;
                
                [self layoutIfNeeded];
            });
            
        });
    }
    else
    {
        userPhoto.image = [UIImage imageNamed:@"DefaultContactImage"];
    }
    UIBezierPath *maskPathPhoto = [UIBezierPath
                                   bezierPathWithRoundedRect:userPhoto.bounds
                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft)
                                   cornerRadii:CGSizeMake(userPhoto.frame.size.width/2,userPhoto.frame.size.width/2)
                                   ];
    
    CAShapeLayer *maskLayerPhoto = [CAShapeLayer layer];
    
    
    maskLayerPhoto.frame = self.bounds;
    maskLayerPhoto.path = maskPathPhoto.CGPath;
    
    userPhoto.layer.mask = maskLayerPhoto;
    
    userPhoto.backgroundColor = [UIColor clearColor];
    [self.containerView addSubview:userPhoto];
    
    
    UIImageView *arrowPhoto = [[UIImageView alloc]initWithFrame:CGRectMake(self.containerView.frame.size.width-20,11,9,9)];
    arrowPhoto.image = [UIImage imageNamed:@"discovery_people_next_arrow_icon_on"];
    arrowPhoto.layer.cornerRadius = userPhoto.frame.size.width/2;
    arrowPhoto.backgroundColor = [UIColor clearColor];
    [self.containerView addSubview:arrowPhoto];
    
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:postTop.bounds
                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                              cornerRadii:CGSizeMake(5,5)
                              ];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    postTop.layer.mask = maskLayer;
    
    
    UIButton *namebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [namebutton addTarget:self
                   action:@selector(nameClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    [namebutton setTitle:_postDataComp[@"postedByUserName"] forState:UIControlStateNormal];
    namebutton.frame = CGRectMake(userPhoto.frame.size.width+16, 8, postTop.frame.size.width - 35,postTop.frame.size.height - 16 );
    [namebutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    namebutton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    namebutton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:15]; //[UIFont systemFontOfSize:13.0];
    [self.containerView addSubview:namebutton];
    //Buttom view Customerize
    
    
    UIBezierPath *maskPathButtom = [UIBezierPath
                                    bezierPathWithRoundedRect:postButtom.bounds
                                    byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                    cornerRadii:CGSizeMake(5,5)
                                    ];
    
    CAShapeLayer *maskLayerButtom = [CAShapeLayer layer];
    
    maskLayerButtom.frame = self.bounds;
    maskLayerButtom.path = maskPathButtom.CGPath;
    
    postButtom.layer.mask = maskLayerButtom;
    
    NSString *userNamepostCaption = self.postDataComp[@"postedByUserName"];
    NSString *postCaption = self.postDataComp[@"postCaption"];
    
    
    
    KILabel *nameButtom = [[KILabel alloc]initWithFrame:CGRectMake(5 , postButtom.frame.size.height - 30 , postButtom.frame.size.width - 10,20)];
    nameButtom.lineBreakMode = NSLineBreakByWordWrapping;
    nameButtom.numberOfLines = 2;
    nameButtom.text = @"#SLocalizedDescription=An SSL error has occurred and a secure connection to the server cannot be made";
    nameButtom.textColor = [UIColor blackColor];
    nameButtom.font = [UIFont fontWithName:@"Roboto-Medium" size:13]; //[UIFont boldSystemFontOfSize:13.0f];
    
    nameButtom.userHandleLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        //removing @ from string.
        
    };
    
    nameButtom.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        [_delegate hashtagTapped:string];
    };
    
    [postButtom addSubview:nameButtom];
    
    if(postCaption.length == 0 || [postCaption isEqualToString:@"<null>"] || [postCaption isEqualToString:@"null"])
    {
        postButtom.hidden = YES;
        //        nameFirst.hidden = YES;
        nameButtom.hidden = YES;
    }
    else
    {
        postButtom.hidden = NO;
        //        nameFirst.hidden = NO;
        nameButtom.hidden = NO;
        
        NSString *writeData = [NSString stringWithFormat:@"%@",postCaption];
        if([writeData isEqualToString:@"<null>"])
        {
            {
                postButtom.hidden = YES;
                //                nameFirst.hidden = YES;
                nameButtom.hidden = YES;
            }
        }else
        {
            //        nameFirst.text =[NSString stringWithFormat:@"%@",userNamepostCaption];
            nameButtom.text = [NSString stringWithFormat:@"%@  %@",userNamepostCaption,postCaption];
        }
    }
    
    
    
    
}

-(void)nameClicked:(UIButton*)sender
{
    NSString *name = _postDataComp[@"postedByUserName"];
    [_delegate userNameClicked:name];
}

#pragma mark - GestureRecognizer delegates
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    CGPoint velocity = [self.panGesture velocityInView:self.panGesture.view];
    if (self.panGesture.state == UIGestureRecognizerStateBegan) {
        isHorizontalPan = fabs(velocity.x) > fabs(velocity.y);
    }
    
    return !isHorizontalPan;
}

#pragma mark -
- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    CGPoint velocity = [pan velocityInView:pan.view];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        isHorizontalPan = fabs(velocity.x) > fabs(velocity.y);
        
        if (!cellIsDragging) {
            initialTimeLabelPosX = self.timeLabel.frame.origin.x;
        }
    }
    
    if (isHorizontalPan) {
        NSArray *visibleCells = [self.tableView visibleCells];
        
        if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
            cellIsDragging = NO;
            [UIView animateWithDuration:0.25 animations:^{
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                for (SOMessageCell *cell in visibleCells) {
                    
                    contentOffsetX = 0;
                    CGRect frame = cell.contentView.frame;
                    frame.origin.x = contentOffsetX;
                    cell.contentView.frame = frame;
                    
                    if (!cell.message.fromMe) {
                        CGRect timeframe = cell.timeLabel.frame;
                        timeframe.origin.x = initialTimeLabelPosX;
                        cell.timeLabel.frame = timeframe;
                    }
                }
            }];
        } else {
            cellIsDragging = YES;
            
            CGPoint translation = [pan translationInView:pan.view];
            CGFloat delta = translation.x * (1 - fabs(contentOffsetX / maxContentOffsetX));
            contentOffsetX += delta;
            if (contentOffsetX > 0) {
                contentOffsetX = 0;
            }
            if (fabs(contentOffsetX) > fabs(maxContentOffsetX)) {
                contentOffsetX = -fabs(maxContentOffsetX);
            }
            for (SOMessageCell *cell in visibleCells) {
                if (cell.message.fromMe) {
                    CGRect frame = cell.contentView.frame;
                    frame.origin.x = contentOffsetX;
                    cell.contentView.frame = frame;
                } else {
                    CGRect frame = cell.timeLabel.frame;
                    frame.origin.x = initialTimeLabelPosX - fabs(contentOffsetX);
                    cell.timeLabel.frame = frame;
                }
            }
        }
    }
    
    [pan setTranslation:CGPointZero inView:pan.view];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    CGRect frame = self.contentView.frame;
    frame.origin.x = contentOffsetX;
    self.contentView.frame = frame;
}

- (void)handleOrientationWillChandeNote:(NSNotification *)note
{
    self.panGesture.enabled = NO;
    self.panGesture.enabled = YES;
}

#pragma mark - Getters and Setters
+ (CGFloat) messageTopMargin
{
    return messageTopMargin;
}

+ (void) setMessageTopMargin:(CGFloat)margin
{
    messageTopMargin = margin;
}

+ (CGFloat) messageBottomMargin;
{
    return messageBottomMargin;
}

+ (void) setMessageBottomMargin:(CGFloat)margin
{
    messageBottomMargin = margin;
}

+ (CGFloat) messageLeftMargin
{
    return messageLeftMargin;
}

+ (void) setMessageLeftMargin:(CGFloat)margin
{
    messageLeftMargin = margin;
}

+ (CGFloat) messageRightMargin
{
    return messageRightMargin;
}

+ (void) setMessageRightMargin:(CGFloat)margin
{
    messageRightMargin = margin;
}

+ (CGFloat)maxContentOffsetX
{
    return maxContentOffsetX;
}

+ (void)setMaxContentOffsetX:(CGFloat)offsetX
{
    maxContentOffsetX = offsetX;
}

#pragma mark -
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSDateFormatter *)DateFormatter {
    
    //EEE - day(eg: Thu)
    //MMM - month (eg: Nov)
    // dd - date (eg 01)
    // z - timeZone
    
    //eg : @"EEE MMM dd HH:mm:ss z yyyy"
    
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        
    });
    return formatter;
}

@end
