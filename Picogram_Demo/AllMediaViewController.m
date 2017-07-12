//
//  AllMediaViewController.m
//  Sup
//
//  Created by Rahul Sharma on 2/4/16.
//  Copyright © 2016 3embed. All rights reserved.
//

#import "AllMediaViewController.h"
#import "AllMediaCell.h"
#import "ImagePreviewViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ProgressIndicator.h"
#import <AVKit/AVKit.h>
#import "UIImage+ARDUtilities.h"
#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"


@interface AllMediaViewController ()

@property(nonatomic,strong)NSMutableArray *allCategoryKeys;
@property (strong, nonatomic) AVPlayer *avplayer;
@property (strong, nonatomic) AVPlayerViewController *playerViewController;

@end


@implementation AllMediaViewController
@synthesize allCategoryKeys;
@synthesize mediaList;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_mediaCollection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self rearrangingMediaKey:self.mediaList];
    
   
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor]}];
  
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:247.0f/255.0f green:248.0f/255.0f blue:247.0f/255.0f alpha:1.0];
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:247.0f/255.0f green:248.0f/255.0f blue:247.0f/255.0f alpha:1.0];
    [self.navigationController.navigationBar setTranslucent:NO];
}

-(void)rearrangingMediaKey:(NSArray *)arr
{
    _mediaListInfo = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dic in arr) {
        NSString *date = [dic objectForKey:@"Date"];
        /* NSRange range = [newString rangeOfString:@" "];
         NSString *date = [newString substringWithRange:NSMakeRange(0, range.location-3)];
         NSLog(@"Date:%@",date);*/
        
        if ([_mediaListInfo objectForKey:date]) {
            NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_mediaListInfo[date]];
            [array addObject:dic];
            [_mediaListInfo setObject:array forKey:date];
        }
        else{
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:dic];
            [_mediaListInfo setObject:array forKey:date];
        }
        
    }
    allCategoryKeys = [[NSMutableArray alloc] initWithArray:[_mediaListInfo allKeys]];
    ProgressIndicator *progressIndicator = [ProgressIndicator sharedInstance];
    [progressIndicator hideProgressIndicator];
    [_mediaCollection reloadData];
    
   // NSLog(@"memberDict %@",_mediaListInfo);
    
}

#pragma mark - CollectionView
#pragma mark DataSource

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return -7.0; // This is the minimum inter item spacing, can be more
}


- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    
//    return 5.0;
//}


//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
//    
//    
//    return 0;
//}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return allCategoryKeys.count;
    //return [self.mediaList count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_mediaListInfo[allCategoryKeys[section]] count];
    //return [self.mediaList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AllMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    // NSData *data = [[NSData alloc]initWithBase64EncodedString:self.mediaList[indexPath.row] options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSDictionary *object = _mediaListInfo[allCategoryKeys[indexPath.section]][indexPath.item];
    //int type = [self.mediaList[indexPath.item][@"Types"]intValue];
    int type = [object[@"Types"]intValue];
    UIImage *image;
    cell.playBtn.tag = indexPath.section;
    if(type == 8)
    {
        [cell.playBtn setHidden:YES];
    
            NSURL *imageUrl =[NSURL URLWithString:object[@"Image"]];
            NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
            UIImage *placeholderImage = [UIImage imageNamed:@"DefaultContactImage"];
        
        
        
            [cell.mediaImg setImageWithURLRequest:request
                                     placeholderImage:placeholderImage
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                  
                                                  cell.mediaImg.image = image;
                                                  cell.mediaImg.clipsToBounds = YES;
                                                  [cell setNeedsLayout];
                                              } failure:nil];
            
        

    }
    else
    {
    if (type == 2) {
        
        [cell.playBtn setHidden:NO];
        //image= [UIImage imageWithData:self.mediaList[indexPath.item][@"Thumbnail"]];
        image= [UIImage imageWithData:object[@"Thumbnail"]];
    }
    else
    {
        [cell.playBtn setHidden:YES];
        image= [UIImage imageWithData:object[@"Image"]];
    }
    }
    
    cell.mediaImg.image = image;
    
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *reusableview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        if (reusableview == nil) {
            reusableview=[[UICollectionReusableView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            reusableview.backgroundColor = [UIColor yellowColor];
            
        }
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        //NSMutableDictionary *dic = mediaList[indexPath.row];
        label.text = allCategoryKeys[indexPath.section];//dic[@"Date"];
        //label.text = @"Today";
        [reusableview addSubview:label];
        
        return reusableview;
    }
    return nil;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
   // NSLog(@"Selected Cell %ld",(long)indexPath.row);
    //UIButton *btn =
//    int i = indexPath.section;
//    int j = indexPath.item;
    NSDictionary *object = _mediaListInfo[allCategoryKeys[indexPath.section]][indexPath.row];
    if ([object[@"Types"]intValue] == 2)
    {
        NSData *data = object[@"Image"];
        NSString *appFile = [NSTemporaryDirectory() stringByAppendingPathComponent:@"video.mp4"];
        [data writeToFile:appFile atomically:YES];
        _avplayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:appFile]];
        _playerViewController = [AVPlayerViewController new];
        _playerViewController.player = _avplayer;
        [self presentViewController:_playerViewController animated:YES completion:nil];
    }
    else
        [self performSegueWithIdentifier:@"mediaToPreview" sender:indexPath];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)sender {
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    NSDictionary *object = _mediaListInfo[allCategoryKeys[sender.section]][sender.row];
    if ([segue.identifier isEqualToString:@"mediaToPreview"]) {
        ImagePreviewViewController *vc = [segue destinationViewController];
        
        int type = [object[@"Types"]intValue];
       
        if(type == 8)
        {
        NSURL *url = [NSURL URLWithString:object[@"Image"]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data] ;
            vc.selectedImage = img;
        }
        else
        {
        vc.selectedImage = [UIImage imageWithData:object[@"Image"]];
        }
            for (int i=0; i<mediaList.count; i++) {
            
            if (![object[@"Image"] isEqual:(mediaList[i][@"Image"])])
            {
                
                [arr addObject:mediaList[i]];
                
            }
            
        }
        
        vc.mediaList = arr;
        
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
