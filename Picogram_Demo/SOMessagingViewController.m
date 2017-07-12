//
//  SOMessagingViewController.m
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

#import "SOMessagingViewController.h"
#import "SOMessage.h"
#import "SOMessageCell.h"
#import "MessageStorage.h"
#import "AppDelegate.h"
#import "HashTagViewController.h"
#import "NSString+Calculation.h"
#import "UserProfileViewController.h"

#import "SOImageBrowserView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
//#import "ShowLocationViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ChatHelper.h"
#import "ProgressIndicator.h"
#import "MBProgressHUD.h"
#define kMessageMaxWidth self.view.frame.size.width-100

@interface SOMessagingViewController () <UITableViewDelegate, SOMessageCellDelegate>
{

}

@property (strong, nonatomic) UIImage *balloonSendImage;
@property (strong, nonatomic) UIImage *balloonReceiveImage;

//@property (strong, nonatomic) UIView *tableViewHeaderView;
//@property (strong, nonatomic) UIButton *previousMessagesButton;

@property (strong, nonatomic) NSMutableArray *conversation;


@property (strong, nonatomic) SOImageBrowserView *imageBrowser;
@property (strong, nonatomic) AVPlayer *avplayer;
@property (strong, nonatomic) AVPlayerViewController *playerViewController;

@end

@implementation SOMessagingViewController {
    dispatch_once_t onceToken;
}
@synthesize avplayer;
- (void)setup
{
    self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableViewHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
    self.previousMessagesButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width,50)];
    self.previousMessagesButton.backgroundColor = [UIColor colorWithRed:(48.0/255.0) green:(201.0/255.0) blue:(232.0/255.0) alpha:0.3];
    [self.previousMessagesButton addTarget:self action:@selector(previousMessagesAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.previousMessagesButton setTitle:@"Load Previous Messages" forState:UIControlStateNormal];
    [self.previousMessagesButton setFont:[UIFont fontWithName:@"Roboto-Regular" size:15]];
    
    [self.tableViewHeaderView addSubview:self.previousMessagesButton];
    self.tableViewHeaderView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.tableViewHeaderView;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.tableView];
    
    self.messageInputView = [[SOMessageInputView alloc] init];
    self.messageInputView.delegate = self;
    self.messageInputView.tableView = self.tableView;
    [self.view addSubview:self.messageInputView];
    [self.messageInputView adjustPosition];
}

#pragma mark - View lifecicle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    
    self.balloonSendImage    = [self balloonImageForSending];
    self.balloonReceiveImage = [self balloonImageForReceiving];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.conversation = [self grouppedMessages];
    
    
    [self.tableView reloadData];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    dispatch_once(&onceToken, ^{
        if ([self.conversation count]) {
            NSInteger section = self.conversation.count - 1;
            NSInteger row = [self.conversation[section] count] - 1;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
             if ( indexPath.row !=-1) {
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
             }
        }
    });
}

// This code will work only if this vc hasn't navigation controller
- (BOOL)shouldAutorotate
{
    if (self.messageInputView.viewIsDragging) {
        return NO;
    }
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSLog(@"%lu",(unsigned long)self.conversation.count);
    return self.conversation.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < 0) {
        return 0;
    }
    // Return the number of rows in the section.
    return [self.conversation[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    NSArray *temp = [[NSArray alloc] initWithArray:self.conversation[indexPath.section]];
    if (temp.count ==0) {
        
    }else{
    
    id<SOMessage> message = self.conversation[indexPath.section][indexPath.row];
    int index = (int)[[self messages] indexOfObject:message];
    height = [self heightForMessageForIndex:index];
    }
    return height +5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self intervalForMessagesGrouping])
        return 40;
    
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (![self intervalForMessagesGrouping])
        return nil;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    view.backgroundColor = [UIColor clearColor];
    
    id<SOMessage> firstMessageInGroup = [self.conversation[section] firstObject];
    NSDate *date = [firstMessageInGroup date];
    
    NSDateFormatter *formatter = [self DateFormatter];
    UILabel *label = [[UILabel alloc] init];
    label.text = [formatter stringFromDate:date];
    
    label.textColor = [UIColor grayColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    [label sizeToFit];
    
    label.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [view addSubview:label];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"sendCell";

    SOMessageCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
   // if (!cell) {
        cell = [[SOMessageCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:cellIdentifier
                                    messageMaxWidth:[self messageMaxWidth]];
        [cell setMediaImageViewSize:[self mediaThumbnailSize]];
        [cell setUserImageViewSize:[self userImageSize]];
        cell.tableView = self.tableView;
        cell.balloonMinHeight = [self balloonMinHeight];
        cell.balloonMinWidth  = [self balloonMinWidth];
    
        cell.messageFont = [self messageFont];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
  //  }
    
   
    NSArray *temp = [[NSArray alloc] initWithArray:self.conversation[indexPath.section]];
    if (temp.count ==0) {
        
    }else{
        
        id<SOMessage> message = self.conversation[indexPath.section][indexPath.row];
        cell.delegate = self;
        cell.balloonImage = message.fromMe ? self.balloonSendImage : self.balloonReceiveImage;
        cell.textView.textColor = message.fromMe ? [UIColor blackColor] : [UIColor blackColor];
        cell.message = message;
        // For user customization
        int index = (int)[[self messages] indexOfObject:message];
        //    NSLog(@"Index Somessaging: %d", index);
        [self configureMessageCell:cell forMessageAtIndex:index];
        [cell adjustCell];
        
    }
    
    return cell;
}

#pragma mark - SOMessaging datasource
- (NSMutableArray *)messages
{
    return nil;
}

- (CGFloat)heightForMessageForIndex:(NSInteger)index
{
    CGFloat height;
    
    id<SOMessage> message = [self messages][index];
    
    if (message.type == SOMessageTypeText) {
        CGSize size = [message.text usedSizeForMaxWidth:[self messageMaxWidth] withFont:[self messageFont]];
        if (message.attributes) {
            size = [message.text usedSizeForMaxWidth:[self messageMaxWidth] withAttributes:message.attributes];
        }
        
        if (self.balloonMinWidth) {
            CGFloat messageMinWidth = self.balloonMinWidth - [SOMessageCell messageLeftMargin] - [SOMessageCell messageRightMargin];
            if (size.width <  messageMinWidth) {
                size.width = messageMinWidth;

                CGSize newSize = [message.text usedSizeForMaxWidth:messageMinWidth withFont:[self messageFont]];
                if (message.attributes) {
                    newSize = [message.text usedSizeForMaxWidth:messageMinWidth withAttributes:message.attributes];
                }
                
                size.height = newSize.height;
            }
        }
        
        CGFloat messageMinHeight = self.balloonMinHeight - ([SOMessageCell messageTopMargin] + [SOMessageCell messageBottomMargin]);
        if ([self balloonMinHeight] && size.height < messageMinHeight) {
            size.height = messageMinHeight;
        }
        
        size.height += [SOMessageCell messageTopMargin] + [SOMessageCell messageBottomMargin];
        
        if (!CGSizeEqualToSize([self userImageSize], CGSizeZero)) {
            if (size.height < [self userImageSize].height) {
                size.height = [self userImageSize].height;
            }
        }
        
        height = size.height + kBubbleTopMargin + kBubbleBottomMargin;
        
    } else {
        CGSize size = [self mediaThumbnailSize];
        if (size.height < [self userImageSize].height) {
            size.height = [self userImageSize].height;
        }
        height = size.height + kBubbleTopMargin + kBubbleBottomMargin;
    }
    return height;
}

- (CGFloat)heightForMessageForMessage:(id<SOMessage>)message
{
    CGFloat height;
    
//    id<SOMessage> message = msg;
    
    if (message.type == SOMessageTypeText) {
        CGSize size = [message.text usedSizeForMaxWidth:[self messageMaxWidth] withFont:[self messageFont]];
        if (message.attributes) {
            size = [message.text usedSizeForMaxWidth:[self messageMaxWidth] withAttributes:message.attributes];
        }
        
        if (self.balloonMinWidth) {
            CGFloat messageMinWidth = self.balloonMinWidth - [SOMessageCell messageLeftMargin] - [SOMessageCell messageRightMargin];
            if (size.width <  messageMinWidth) {
                size.width = messageMinWidth;
                
                CGSize newSize = [message.text usedSizeForMaxWidth:messageMinWidth withFont:[self messageFont]];
                if (message.attributes) {
                    newSize = [message.text usedSizeForMaxWidth:messageMinWidth withAttributes:message.attributes];
                }
                
                size.height = newSize.height;
            }
        }
        
        CGFloat messageMinHeight = self.balloonMinHeight - ([SOMessageCell messageTopMargin] + [SOMessageCell messageBottomMargin]);
        if ([self balloonMinHeight] && size.height < messageMinHeight) {
            size.height = messageMinHeight;
        }
        
        size.height += [SOMessageCell messageTopMargin] + [SOMessageCell messageBottomMargin];
        
        if (!CGSizeEqualToSize([self userImageSize], CGSizeZero)) {
            if (size.height < [self userImageSize].height) {
                size.height = [self userImageSize].height;
            }
        }
        
        height = size.height + kBubbleTopMargin + kBubbleBottomMargin;
        
    } else {
        CGSize size = [self mediaThumbnailSize];
        if (size.height < [self userImageSize].height) {
            size.height = [self userImageSize].height;
        }
        height = size.height + kBubbleTopMargin + kBubbleBottomMargin;
    }
    return height;
}


- (NSTimeInterval)intervalForMessagesGrouping
{
    return 0;
}

- (UIImage *)balloonImageForReceiving
{
    UIImage *bubble = [UIImage imageNamed:@"bubbleReceive.png"];
    UIColor *color = [UIColor whiteColor];
//    bubble = [self tintImage:bubble withColor:color];
    
    return [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(17, 27, 21, 17)];
}

- (UIImage *)balloonImageForSending
{
    UIImage *bubble = [UIImage imageNamed:@"bubble.png"];
    UIColor *color = [UIColor colorWithRed:235.0/255.0 green:234.0/255.0 blue:235.0/255.0 alpha:1.0];
    bubble = [self tintImage:bubble withColor:color];
    return [bubble resizableImageWithCapInsets:UIEdgeInsetsMake(17, 21, 16, 27)];
}

- (void)configureMessageCell:(SOMessageCell *)cell forMessageAtIndex:(NSInteger)index
{

}

- (CGFloat)messageMaxWidth
{
    return kMessageMaxWidth;
}

- (CGFloat)balloonMinHeight
{
    return 0;
}

- (CGFloat)balloonMinWidth
{
    return 0;
}

- (UIFont *)messageFont
{
    return [UIFont fontWithName:@"Roboto-Regular" size:14]; //16
}

- (CGSize)mediaThumbnailSize
{
    return CGSizeMake(self.view.frame.size.width -80, self.view.frame.size.width -80);
}

- (CGSize)userImageSize
{
    return CGSizeMake(0, 0);
}

#pragma mark - Public methods
- (void)sendMessage:(id<SOMessage>) message
{
    message.fromMe = YES;
    NSMutableArray *messages = [self messages];
    [messages addObject:message];

    [self refreshMessages];
}

- (void)receiveMessage:(id<SOMessage>) message
{
    message.fromMe = NO;
    NSMutableArray *messages = [self messages];
    [messages addObject:message];
    
    [self refreshMessages];
}

- (void)refreshMessages
{
    self.conversation = [self grouppedMessages];
    [self.tableView reloadData];
//    [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[[self.conversation lastObject] count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];
    
    NSInteger section = [self numberOfSectionsInTableView:self.tableView] - 1;
    NSInteger row     = [self tableView:self.tableView numberOfRowsInSection:section] - 1;

    if (row >= 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)refreshMessagesReloadTable {
    
    self.conversation = [self grouppedMessages];
        [self.tableView reloadData];
//    [self.tableView beginUpdates];
//    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[[self.conversation lastObject] count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [self.tableView endUpdates];
//    
//    NSInteger section = [self numberOfSectionsInTableView:self.tableView] - 1;
//    NSInteger row     = [self tableView:self.tableView numberOfRowsInSection:section] - 1;
//    
//    if (row >= 0) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
//        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }

}

#pragma mark - Private methods
- (NSMutableArray *)grouppedMessages
{
    NSMutableArray *conversation = [NSMutableArray new];
    
    if (![self intervalForMessagesGrouping]) {
        if ([self messages]) {
            [conversation addObject:[self messages]];
        }
    } else {
        int groupIndex = 0;
        NSMutableArray *allMessages = [self messages];

        for (int i = 0; i < allMessages.count; i++) {
            if (i == 0) {
                NSMutableArray *firstGroup = [NSMutableArray new];
                [firstGroup addObject:allMessages[i]];
                [conversation addObject:firstGroup];
            } else {
                id<SOMessage> prevMessage    = allMessages[i-1];
                id<SOMessage> currentMessage = allMessages[i];
                
                NSDate *prevMessageDate    = prevMessage.date;
                NSDate *currentMessageDate = currentMessage.date;
                
                NSTimeInterval interval = [currentMessageDate timeIntervalSinceDate:prevMessageDate];
                if (interval < [self intervalForMessagesGrouping]) {
                    NSMutableArray *group = conversation[groupIndex];
                    [group addObject:currentMessage];
                    
                } else {
                    NSMutableArray *newGroup = [NSMutableArray new];
                    [newGroup addObject:currentMessage];
                    [conversation addObject:newGroup];
                    groupIndex++;
                }
            }
        }
    }
    
    return conversation;
}

#pragma mark - SOMessaging delegate
- (void)messageCell:(SOMessageCell *)cell didTapMedia:(NSData *)media
{
    [self didSelectMedia:media inMessageCell:cell];
}

-(void)messageCell:(SOMessageCell *)cell didTapPost:(NSDictionary *)media
{
    [self didSelectPost:media inMessageCell:cell];
}


- (void)didSelectPost:(NSDictionary *)media inMessageCell:(SOMessageCell *)cell
{
    if (cell.message.type == SOMessageTypePost) {
        
        if (cell.message.fromMe == YES && cell.message.isUrlDownloaded == YES) {
            
            NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir  = [documentPaths objectAtIndex:0];
            NSString *movieName = [NSString stringWithFormat:@"%@.jpg",cell.message.messageID];
            NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
            UIImage *image = [UIImage imageWithContentsOfFile:moviePath];
            
            self.imageBrowser = [[SOImageBrowserView alloc] init];
            self.imageBrowser.image = image;
            self.imageBrowser.startFrame = [cell convertRect:cell.containerView.frame toView:self.view];
            [self.imageBrowser show];
        }else{
            
            if (cell.message.isUrlDownloaded == NO) {
                // NSLog(@"cell.message.media =%@",cell.message.media);
                NSDictionary *postedata = cell.message.postData;
                NSLog(@"%@",cell.message.postData);
                //                NSDictionary *postedata = [postedat firstObject];
                //                NSString *url = [ChatHelper decodedStringFrom64:[NSString stringWithFormat:@"%@",cell.message.media]];
                NSString *url = [postedata objectForKey:@"thumbnailImageUrl"];
                //                url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:cell.mediaImageView animated:YES];
                hud.mode = MBProgressHUDModeIndeterminate;
                hud.color = [UIColor clearColor];
                
                __weak typeof(self) weakSelf = self;
                
                SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
                [downloader downloadImageWithURL:[NSURL URLWithString:url]
                                         options:SDWebImageContinueInBackground | SDWebImageRetryFailed
                                        progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                            // progression tracking code
                                            // NSLog(@"progress =%ld",(long)receivedSize);
                                        }
                                       completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                               [hud hide:YES];
                                           }];
                                           
                                           if (image && finished) {
                                               // do something with image
                                               
                                               NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                                               
                                               if (data == nil) {
                                               }else{
                                                   
                                                   NSData  *pathData = [self storeImageinMemeory:data messageID:cell.message.messageID];
                                                   
                                                   cell.message.media = pathData;
                                                   cell.message.isUrlDownloaded = YES;
                                                   
                                                   
                                                   [self updateMediaInDatabase:indexPath fromNum:cell.message.fromNum mediaData:pathData messageID:cell.message.messageID thumbnail:nil type:cell.message.type groupID:cell.message.groupID];
                                                   
                                                   [self saveImageToalbum:image];
                                                   
                                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                       
                                                       cell.message.media = pathData;
                                                       cell.message.isUrlDownloaded = YES;
                                                       NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                                                       NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                                                       [weakSelf.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                                                       
                                                   }];
                                                   
                                                   
                                                   
                                               }
                                               
                                           }
                                       }];
                
                
                
                
                
                
            }else{
                
                
                NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDir  = [documentPaths objectAtIndex:0];
                NSString *movieName = [NSString stringWithFormat:@"%@.jpg",cell.message.messageID];
                NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
                
                //    NSString *path = [[NSString alloc]
                //   initWithData:cell.message.media encoding:NSUTF8StringEncoding];
                
                self.imageBrowser = [[SOImageBrowserView alloc] init];
                self.imageBrowser.image =  [UIImage imageWithContentsOfFile:moviePath];//[UIImage imageWithData:cell.message.media];
                self.imageBrowser.startFrame = [cell convertRect:cell.containerView.frame toView:self.view];
                [self.imageBrowser show];
            }
            
        }
        
    }
}


- (void)didSelectMedia:(NSData *)media inMessageCell:(SOMessageCell *)cell
{
   // NSLog(@"%u",cell.message.type);
    //  NSLog(@"%@",cell.message.media);
    //  NSLog(@"%u",cell.message.isUrlDownloaded);
    
    
    if (cell.message.type == SOMessageTypePhoto) {
        
        if (cell.message.fromMe == YES) {
            
            NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir  = [documentPaths objectAtIndex:0];
            NSString *movieName = [NSString stringWithFormat:@"%@.jpg",cell.message.messageID];
            NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
           UIImage *image = [UIImage imageWithContentsOfFile:moviePath];

            self.imageBrowser = [[SOImageBrowserView alloc] init];
            self.imageBrowser.image = image;
            self.imageBrowser.startFrame = [cell convertRect:cell.containerView.frame toView:self.view];
            [self.imageBrowser show];
        }else{
           
            if (cell.message.isUrlDownloaded == NO) {
               // NSLog(@"cell.message.media =%@",cell.message.media);
                NSString *url = [ChatHelper decodedStringFrom64:[NSString stringWithFormat:@"%@",cell.message.media]];
                url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:cell.mediaImageView animated:YES];
                hud.mode = MBProgressHUDModeIndeterminate;
                hud.color = [UIColor clearColor];
                
                 __weak typeof(self) weakSelf = self;

                SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
                [downloader downloadImageWithURL:[NSURL URLWithString:url]
                                         options:SDWebImageContinueInBackground | SDWebImageRetryFailed
                                        progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                            // progression tracking code
                                            // NSLog(@"progress =%ld",(long)receivedSize);
                                        }
                                       completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                               [hud hide:YES];
                                           }];

                                           if (image && finished) {
                                               // do something with image
                                               
                                               NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                                               
                                               if (data == nil) {
                                               }else{
                                                   
                                                   NSData  *pathData = [self storeImageinMemeory:data messageID:cell.message.messageID];
                                                   
                                                   cell.message.media = pathData;
                                                   cell.message.isUrlDownloaded = YES;
                                                   
                                                   
                                                   [self updateMediaInDatabase:indexPath fromNum:cell.message.fromNum mediaData:pathData messageID:cell.message.messageID thumbnail:nil type:cell.message.type groupID:cell.message.groupID];
                                                   
                                                   [self saveImageToalbum:image];
                                                   
                                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                  
                                                       cell.message.media = pathData;
                                                       cell.message.isUrlDownloaded = YES;
                                                       NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                                                       NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                                                       [weakSelf.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                                                       
                                                   }];

                                                   
                                                  
                                               }
                                               
                                           }
                                       }];
                
                
                
                
                
                
        }else{
            
        
            NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir  = [documentPaths objectAtIndex:0];
            NSString *movieName = [NSString stringWithFormat:@"%@.jpg",cell.message.messageID];
            NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
            
        //    NSString *path = [[NSString alloc]
                                  //   initWithData:cell.message.media encoding:NSUTF8StringEncoding];

        self.imageBrowser = [[SOImageBrowserView alloc] init];
        self.imageBrowser.image =  [UIImage imageWithContentsOfFile:moviePath];//[UIImage imageWithData:cell.message.media];
        self.imageBrowser.startFrame = [cell convertRect:cell.containerView.frame toView:self.view];
        [self.imageBrowser show];
        }
        
        }
        
        
    } else if (cell.message.type == SOMessageTypeVideo) {
        
        if (cell.message.fromMe == YES) {
            
            NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir  = [documentPaths objectAtIndex:0];
            NSString *movieName = [NSString stringWithFormat:@"%@.mp4",cell.message.messageID];
            NSString *appFile    = [documentsDir stringByAppendingPathComponent:movieName];
           // NSString *appFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"video.mp4"];
            //[cell.message.media writeToFile:appFile atomically:YES];
            
            
            avplayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:appFile]];
            _playerViewController = [AVPlayerViewController new];
            _playerViewController.player = avplayer;
            [self presentViewController:_playerViewController animated:YES completion:nil];
            
        }
        else
        {
            
            if (cell.message.isUrlDownloaded == NO) {
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:cell.mediaImageView animated:YES];
                hud.mode = MBProgressHUDModeIndeterminate;
                hud.color = [UIColor clearColor];
                
                __weak typeof(self) weakSelf = self;

                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                  //  NSLog(@"Downloading Started");
                    NSString *urlToDownload = [ChatHelper decodedStringFrom64:[NSString stringWithFormat:@"%@",cell.message.media]];
                    urlToDownload = [urlToDownload stringByReplacingOccurrencesOfString:@" " withString:@""];
                    NSURL  *url = [NSURL URLWithString:urlToDownload];
                   // NSData *urlData = [NSData dataWithContentsOfURL:url];
                    NSURLResponse *response = nil;
                    NSError *error = nil;
                    NSMutableURLRequest *req = [[NSMutableURLRequest alloc]initWithURL:url];
                    NSData *urlData  = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
                    
                    
                     UIImage *thumbnailImage;
                    if (urlData)
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [hud hide:YES];
                        }];
                        
                        NSData *data = urlData;
                        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDir  = [documentPaths objectAtIndex:0];
                       // NSString *movieName = [NSString stringWithFormat:@"movie.MOV"];
                        NSString *movieName = [NSString stringWithFormat:@"%@.mp4",cell.message.messageID];
                        NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
                        // NSLog(@"%@",moviePath);
                        if([data writeToFile:moviePath atomically:YES]) {
                            
                            NSURL *url = [[NSURL alloc] initFileURLWithPath:moviePath];
                            
                            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
                            AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                            NSError *err = NULL;
                            CMTime requestedTime = CMTimeMake(1, 60);     // To create thumbnail image
                            CGImageRef imgRef = [generator copyCGImageAtTime:requestedTime actualTime:NULL error:&err];
                            // NSLog(@"err = %@, imageRef = %@", err, imgRef);
                            
                            thumbnailImage = [[UIImage alloc] initWithCGImage:imgRef];
                            CGImageRelease(imgRef);    // MUST release explicitly to avoid memory leak
                            
                            NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",cell.message.messageID];
                            NSString *moviePath1    = [documentsDir stringByAppendingPathComponent:movieName];
                            
                            NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
                            if([thumbnailImageData writeToFile:moviePath1 atomically:YES]) {

                            }
                        }
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [hud hide:YES];
                        }];
                        
                        
                        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                        if (data == nil) {
                        }else{
                        
                            NSData *data1 = [moviePath dataUsingEncoding:NSUTF8StringEncoding];
                        [self updateMediaInDatabase:indexPath fromNum:cell.message.fromNum mediaData:data1 messageID:cell.message.messageID thumbnail:thumbnailImage type:cell.message.type groupID:cell.message.groupID];
                            
                            [self saveVideoToalbum:[NSString stringWithFormat:@"%@",moviePath]];
                            
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                cell.message.media = data1;
                                cell.message.isUrlDownloaded = YES;
                                cell.message.thumbnail = thumbnailImage;
                                NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                                NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                                [weakSelf.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                                
                            }];
                        }
                    }else{
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [hud hide:YES];
                        }];
                    }
                });
            }
            else{
                
                NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDir  = [documentPaths objectAtIndex:0];
                NSString *movieName = [NSString stringWithFormat:@"%@.mp4",cell.message.messageID];
                NSString *appFile    = [documentsDir stringByAppendingPathComponent:movieName];
               // NSString *appFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"video.mp4"];
               // [cell.message.media writeToFile:appFile atomically:YES];
                
                avplayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:appFile]];
                _playerViewController = [AVPlayerViewController new];
                _playerViewController.player = avplayer;
                [self presentViewController:_playerViewController animated:YES completion:nil];
                
            }
            
        }
        
    } else if (cell.message.type == SOMessageTypePost) {
        
        if (cell.message.fromMe == YES && cell.message.isUrlDownloaded == YES) {
            
            NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDir  = [documentPaths objectAtIndex:0];
            NSString *movieName = [NSString stringWithFormat:@"%@.jpg",cell.message.messageID];
            NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
            UIImage *image = [UIImage imageWithContentsOfFile:moviePath];
            
            self.imageBrowser = [[SOImageBrowserView alloc] init];
            self.imageBrowser.image = image;
            self.imageBrowser.startFrame = [cell convertRect:cell.containerView.frame toView:self.view];
            [self.imageBrowser show];
        }else{
            
            if (cell.message.isUrlDownloaded == NO) {
                // NSLog(@"cell.message.media =%@",cell.message.media);
                NSDictionary *postedata = cell.message.postData;
                NSLog(@"%@",cell.message.postData);
//                NSDictionary *postedata = [postedat firstObject];
//                NSString *url = [ChatHelper decodedStringFrom64:[NSString stringWithFormat:@"%@",cell.message.media]];
                NSString *url = [postedata objectForKey:@"thumbnailImageUrl"];
//                url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:cell.mediaImageView animated:YES];
                hud.mode = MBProgressHUDModeIndeterminate;
                hud.color = [UIColor clearColor];
                
                __weak typeof(self) weakSelf = self;
                
                SDWebImageDownloader *downloader = [SDWebImageDownloader sharedDownloader];
                [downloader downloadImageWithURL:[NSURL URLWithString:url]
                                         options:SDWebImageContinueInBackground | SDWebImageRetryFailed
                                        progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                            // progression tracking code
                                            // NSLog(@"progress =%ld",(long)receivedSize);
                                        }
                                       completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                               [hud hide:YES];
                                           }];
                                           
                                           if (image && finished) {
                                               // do something with image
                                               
                                               NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                                               
                                               if (data == nil) {
                                               }else{
                                                   
                                                   NSData  *pathData = [self storeImageinMemeory:data messageID:cell.message.messageID];
                                                   
                                                   cell.message.media = pathData;
                                                   cell.message.isUrlDownloaded = YES;
                                                   
                                                   
                                                   [self updateMediaInDatabase:indexPath fromNum:cell.message.fromNum mediaData:pathData messageID:cell.message.messageID thumbnail:nil type:cell.message.type groupID:cell.message.groupID];
                                                   
                                                   [self saveImageToalbum:image];
                                                   
                                                   [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                                       
                                                       cell.message.media = pathData;
                                                       cell.message.isUrlDownloaded = YES;
                                                       NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                                                       NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
                                                       [weakSelf.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                                                       
                                                   }];
                                                   
                                                   
                                                   
                                               }
                                               
                                           }
                                       }];
                
                
                
                
                
                
            }else{
                
                
                NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDir  = [documentPaths objectAtIndex:0];
                NSString *movieName = [NSString stringWithFormat:@"%@.jpg",cell.message.messageID];
                NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
                
                //    NSString *path = [[NSString alloc]
                //   initWithData:cell.message.media encoding:NSUTF8StringEncoding];
                
                self.imageBrowser = [[SOImageBrowserView alloc] init];
                self.imageBrowser.image =  [UIImage imageWithContentsOfFile:moviePath];//[UIImage imageWithData:cell.message.media];
                self.imageBrowser.startFrame = [cell convertRect:cell.containerView.frame toView:self.view];
                [self.imageBrowser show];
            }
            
        }
        
    }
    

}

-(void)hashtagTapped:(NSString *)selectedHashtAG {
    HashTagViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"hashTagStoryBoardId"];
    newView.navTittle = selectedHashtAG;
    [self.navigationController pushViewController:newView animated:YES];
}

-(void)userNameClicked:(NSString *)userName{
    UserProfileViewController *newView = [self.storyboard instantiateViewControllerWithIdentifier:@"userProfileStoryBoardId"];
    newView.checkingFriendsProfile = YES;
    newView.checkProfileOfUserNmae = userName;
    [self.navigationController pushViewController:newView animated:YES];
}

-(void)saveImageToalbum:(UIImage*)image{
    
    UIImageWriteToSavedPhotosAlbum(image,
                                   nil,
                                   nil,
                                   nil);
    
}

-(void)saveVideoToalbum:(NSString*)path{
    
    UISaveVideoAtPathToSavedPhotosAlbum(path,nil,nil, nil);

}



/*store image to memory*/
-(NSData*)storeImageinMemeory:(NSData*)data messageID:(NSString*)messageID{
    
    
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir  = [documentPaths objectAtIndex:0];
    NSString *movieName = [NSString stringWithFormat:@"%@.jpg",messageID];
    NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
     NSLog(@"%@",moviePath);
    NSData *data1;
    if([data writeToFile:moviePath atomically:YES]) {
       // NSURL *url = [[NSURL alloc] initFileURLWithPath:moviePath];
       data1 = [moviePath dataUsingEncoding:NSUTF8StringEncoding];
    
    }

    
    return data1;
}


-(void)updateMediaInDatabase:(NSIndexPath*)indexPath fromNum:(NSString*)fromNum mediaData:(NSData *)data messageID:(NSString*)messageID thumbnail:(UIImage*)thubimg type:(SOMessageType)type groupID:(NSString*)groupID{
    
   // NSLog(@"update media in db");
    
    AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    CBLManager* bgMgr = [appdel.manager copy];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        
        @synchronized(self) {
            NSError *error;
            CBLDatabase* bgDB = [bgMgr databaseNamed: @"couchbasenew" error: &error];
            MessageStorage *messageStorage = [MessageStorage sharedInstance];
            NSString *docID ;
            if (groupID.length>0) {
                docID = [ChatHelper getDocumentIDWithGroupID:groupID onDatabase:bgDB];
            }else{
              docID  = [ChatHelper getDocumentIDWithSenderID:fromNum onDatabase:bgDB];
            }
           
            messageStorage.docInfo = [[messageStorage getDocumentInfoForID:docID forDatabase:bgDB] mutableCopy];
            
            NSString *message = [data base64EncodedStringWithOptions:kNilOptions];
            NSMutableArray *tempTestArr = [[NSMutableArray alloc] initWithArray:messageStorage.docInfo[@"messages"]];
            
            NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"messageID contains[cd] %@",messageID];
            
            NSArray *messageObject = [tempTestArr filteredArrayUsingPredicate:bPredicate];
            if (messageObject.count>0) {
                NSDictionary *dict = [messageObject lastObject];
                NSMutableDictionary *dictMutable = [dict mutableCopy];
        
            [dictMutable setObject:@"YES" forKey:@"isUrlDownloaded"];
            [dictMutable setObject:message forKey:@"media"];
                
                if (type  == SOMessageTypeVideo) {
                    NSData *thumbnailImageData = UIImagePNGRepresentation(thubimg);
                    NSString *thumbnailImage = [thumbnailImageData base64EncodedStringWithOptions:kNilOptions];
                    if (thumbnailImage.length ==0) {
                        UIImage *thumb = [UIImage imageNamed:@"default_568h"];
                        NSData *thumbnailImageData = UIImagePNGRepresentation(thumb);
                        NSString *thumbnailImage = [thumbnailImageData base64EncodedStringWithOptions:kNilOptions];
                        [dictMutable setObject:thumbnailImage forKey:@"thumbnail"];
                        
                    }else{
                        
                        NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsDir  = [documentPaths objectAtIndex:0];
                        NSString *movieName = [NSString stringWithFormat:@"%@thumbnail.jpg",messageID];
                        NSString *moviePath    = [documentsDir stringByAppendingPathComponent:movieName];
                        NSString *thumbnailImage = [ChatHelper encodeStringTo64:moviePath];
                        [dictMutable setObject:thumbnailImage forKey:@"thumbnail"];
                    
                    }
                }
                
               NSMutableArray *tempBuffer = [[NSMutableArray alloc] initWithArray:tempTestArr];
                NSInteger indexOfdict = [tempBuffer indexOfObject:dict];
                
                if (dictMutable) {
                    [tempTestArr replaceObjectAtIndex:indexOfdict withObject:[dictMutable copy]];
                }
                
                messageStorage.docInfo[@"messages"] = tempTestArr ;
                [messageStorage updateDocumentWithID:docID withMessages:[tempTestArr copy] onDatabase:bgDB];
                
            }
           
//            if (messageStorage.delegate && [messageStorage.delegate respondsToSelector:@selector(reloadTableForMessageID:andDocID:status:)]) {
//                [messageStorage.delegate reloadTableForMessageID:messageID andDocID:docID status:@""];
//            }

            
        }
    });
    
    
    
    
    
    
    
    
    
}


#pragma mark - Helper methods
- (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSDateFormatter *)DateFormatter {
    
    //EEE - day(eg: Thu)
    //MMM - month (eg: Nov)
    // dd - date (eg 01)
    // z - timeZone
    
    //eg : @"EEE MMM dd HH:mm:ss z yyyy"
    
    
    static NSDateFormatter *formatter;
    static dispatch_once_t onceTokenNew;
    dispatch_once(&onceTokenNew, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd MMM, eee, HH:mm"];
    });
    return formatter;
}

-(IBAction)previousMessagesAction:(id)sender {
    
    // Implemented by Subclass
}
@end
