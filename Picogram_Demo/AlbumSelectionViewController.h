//
//  AlbumSelectionViewController.h
//  Zuri
//
//  Created by Rahul_Sharma on 15/02/17.
//  Copyright © 2017 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol albumsSelected<NSObject>
-(void)itemSelected:(PHFetchResult *)selctedPhotosAssests andHeaderTitle:(NSString *)headerTitle;
@end

@interface AlbumSelectionViewController : UIViewController
@property (nonatomic, weak) id <albumsSelected>delegate;
@property (weak, nonatomic) IBOutlet UITableView *albumTableView;
@property (strong,nonatomic) NSString *titleText;

@property (strong,nonatomic) NSString *selectedAlbumFor;

@end
