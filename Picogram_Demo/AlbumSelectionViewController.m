//
//  AlbumSelectionViewController.m
//  Zuri
//
//  Created by Rahul_Sharma on 15/02/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

#import "AlbumSelectionViewController.h"
#import "AlbumSelectionTableViewCell.h"
#import "FontDetailsClass.h"
#import <Photos/Photos.h>

static float const kAlbumGradientHeight = 20.0f;
static CGSize const kAlbumThumbnailSize1 = {70.0f , 70.0f};
static CGSize const kAlbumThumbnailSize2 = {66.0f , 66.0f};
static CGSize const kAlbumThumbnailSize3 = {62.0f , 62.0f};

@interface AlbumSelectionViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong) NSArray *collectionsFetchResults;
@property (strong) NSArray *collectionsFetchResultsAssets;
@property (strong) NSArray *collectionsFetchResultsTitles;
@property (strong) PHCachingImageManager *imageManager;
@end

@implementation AlbumSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavRightButton];
    self.imageManager = [[PHCachingImageManager alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Fetch PHAssetCollections:
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    self.collectionsFetchResults = @[topLevelUserCollections, smartAlbums];
    
    [self updateFetchResults];
    
    self.navigationItem.title = self.titleText;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor]};
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)updateFetchResults
{
    //What I do here is fetch both the albums list and the assets of each album.
    //This way I have acces to the number of items in each album, I can load the 3
    //thumbnails directly and I can pass the fetched result to the gridViewController.
    
    self.collectionsFetchResultsAssets=nil;
    self.collectionsFetchResultsTitles=nil;
    
    //Fetch PHAssetCollections:
    PHFetchResult *topLevelUserCollections = [self.collectionsFetchResults objectAtIndex:0];
    PHFetchResult *smartAlbums = [self.collectionsFetchResults objectAtIndex:1];
    
    //All album: Sorted by descending creation date.
    NSMutableArray *allFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *allFetchResultLabel = [[NSMutableArray alloc] init];
    {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *assetsFetchResult;
        if ([self.selectedAlbumFor isEqualToString:@"itisForProfilePhoto"]) {
            //only images
            assetsFetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        }
        else {
            assetsFetchResult =   [PHAsset fetchAssetsWithOptions:options];
            // assetsFetchResult = [PHAsset fetchAssetsWithOptions:options];
        }
        
        [allFetchResultArray addObject:assetsFetchResult];
        [allFetchResultLabel addObject:@"All photos"];
    }
    
    //User albums:
    NSMutableArray *userFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *userFetchResultLabel = [[NSMutableArray alloc] init];
    for(PHCollection *collection in topLevelUserCollections)
    {
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            //Albums collections are allways PHAssetCollectionType=1 & PHAssetCollectionSubtype=2
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            if ([self.selectedAlbumFor isEqualToString:@"itisForProfilePhoto"]) {
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
            }
//            else {
//                options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
//            }
            
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            [userFetchResultArray addObject:assetsFetchResult];
            [userFetchResultLabel addObject:collection.localizedTitle];
        }
    }
    
    
    
    //Smart albums: Sorted by descending creation date.
    NSMutableArray *smartFetchResultArray = [[NSMutableArray alloc] init];
    NSMutableArray *smartFetchResultLabel = [[NSMutableArray alloc] init];
    for(PHCollection *collection in smartAlbums)
    {
        if ([collection isKindOfClass:[PHAssetCollection class]])
        {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            //Smart collections are PHAssetCollectionType=2;
            
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            if ([self.selectedAlbumFor isEqualToString:@"itisForProfilePhoto"]) {
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
            }
//            else {
//                options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
//            }
            
            PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            if(assetsFetchResult.count>0)
            {
                [smartFetchResultArray addObject:assetsFetchResult];
                [smartFetchResultLabel addObject:collection.localizedTitle];
            }
        }
    }
    
    self.collectionsFetchResultsAssets= @[allFetchResultArray,userFetchResultArray,smartFetchResultArray];
    self.collectionsFetchResultsTitles= @[allFetchResultLabel,userFetchResultLabel,smartFetchResultLabel];
}

#pragma mark - Cell Subtitle

- (NSString *)tableCellSubtitle:(PHFetchResult*)assetsFetchResult
{
    // Just return the number of assets. Album app does this:
    return [NSString stringWithFormat:@"%ld", (long)[assetsFetchResult count]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"albumCell";
    
    AlbumSelectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    // Increment the cell's tag
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    // Set the label
    
    cell.albumTitleLabel.text = (self.collectionsFetchResultsTitles[indexPath.section])[indexPath.row];
    
    
    // Retrieve the pre-fetched assets for this album:
    PHFetchResult *assetsFetchResult = (self.collectionsFetchResultsAssets[indexPath.section])[indexPath.row];
    
    // Display the number of assets
    cell.numberOfAssestsAvailLabel.text = [self tableCellSubtitle:assetsFetchResult];
    
    
    // Set the 3 images (if exists):
    if ([assetsFetchResult count] > 0) {
        CGFloat scale = [UIScreen mainScreen].scale;
        
        //Compute the thumbnail pixel size:
        CGSize tableCellThumbnailSize1 = CGSizeMake(kAlbumThumbnailSize1.width*scale, kAlbumThumbnailSize1.height*scale);
        PHAsset *asset = assetsFetchResult[0];
        //        [cell setVideoLayout:(asset.mediaType==PHAssetMediaTypeVideo)];
        [self.imageManager requestImageForAsset:asset
                                     targetSize:tableCellThumbnailSize1
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      if (cell.tag == currentTag) {
                                          cell.thumbimageview.image = result;
                                      }
                                  }];
        
        // Second & third images:
        // TODO: Only preload the 3pixels height visible frame!
        if ([assetsFetchResult count] > 1) {
            //Compute the thumbnail pixel size:
            CGSize tableCellThumbnailSize2 = CGSizeMake(kAlbumThumbnailSize2.width*scale, kAlbumThumbnailSize2.height*scale);
            PHAsset *asset = assetsFetchResult[1];
            [self.imageManager requestImageForAsset:asset
                                         targetSize:tableCellThumbnailSize2
                                        contentMode:PHImageContentModeAspectFill
                                            options:nil
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                                          if (cell.tag == currentTag) {
                                              cell.thumbimageview.image = result;
                                          }
                                      }];
        } else {
            cell.thumbimageview.image = nil;
        }
        
        if ([assetsFetchResult count] > 2) {
            CGSize tableCellThumbnailSize3 = CGSizeMake(kAlbumThumbnailSize3.width*scale, kAlbumThumbnailSize3.height*scale);
            PHAsset *asset = assetsFetchResult[2];
            [self.imageManager requestImageForAsset:asset
                                         targetSize:tableCellThumbnailSize3
                                        contentMode:PHImageContentModeAspectFill
                                            options:nil
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                                          if (cell.tag == currentTag) {
                                              cell.thumbimageview.image = result;
                                          }
                                      }];
        } else {
            cell.thumbimageview.image = nil;
        }
    } else {
        
        cell.thumbimageview.image = [UIImage imageNamed:@"GMEmptyFolder"];
        cell.thumbimageview.image = [UIImage imageNamed:@"GMEmptyFolder"];
        cell.thumbimageview.image = [UIImage imageNamed:@"GMEmptyFolder"];
    }
    
    return cell;
}

-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    //  Use the prefetched assets!
    PHFetchResult *assetsFetchResults;
    assetsFetchResults = [[_collectionsFetchResultsAssets objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    
    
    if (assetsFetchResults.count >0) {
        [self.delegate itemSelected:assetsFetchResults andHeaderTitle:(self.collectionsFetchResultsTitles[indexPath.section])[indexPath.row]];
        
        // Remove selection so it looks better on slide in
        [tableView deselectRowAtIndexPath:indexPath animated:true];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:@"No files available" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
    [self.albumTableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.contentView.backgroundColor = [UIColor clearColor];
    header.backgroundView.backgroundColor = [UIColor clearColor];
    
    // Default is a bold font, but keep this styled as a normal font
    header.textLabel.textColor = [UIColor blueColor];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //Tip: Returning nil hides the section header!
    
    NSString *title = nil;
    if (section > 0) {
        // Only show title for non-empty sections:
        PHFetchResult *fetchResult = self.collectionsFetchResultsAssets[section];
        if (fetchResult.count > 0) {
            title =  @"it is Header";
        }
    }
    return title;
}

-(CGFloat )tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

//method for creating navigation bar right button.
- (void)createNavRightButton {
    
    UIButton *navDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navDoneButton setTitle:@"Done"
                   forState:UIControlStateNormal];
    [navDoneButton setTitleColor:[UIColor blackColor]
                        forState:UIControlStateNormal];
    navDoneButton.titleLabel.font = [UIFont fontWithName:RobotoRegular size:17];
    [navDoneButton setFrame:CGRectMake(0,0,50,30)];
    [navDoneButton addTarget:self action:@selector(DoneButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navDoneButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

-(void)DoneButtonAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.collectionsFetchResultsAssets.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PHFetchResult *fetchResult = self.collectionsFetchResultsAssets[section];
    return fetchResult.count;
}



@end
