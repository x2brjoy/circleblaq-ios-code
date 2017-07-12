//
//  PhotoDetailViewController.h
//  Picogram_Demo
//
//  Created by Rahul Sharma on 3/14/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol senddataProtocol <NSObject>

-(void)sendDataToA:(NSMutableArray *)array andPositions:(NSMutableArray *)positionsArray;

@end

@interface PGTagPeopleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

//imageView outlets
@property (weak, nonatomic) IBOutlet UIImageView *tagImageViewOutlet;

@property (strong,nonatomic) UIImage *tagPeopleImage;

@property NSMutableArray *arrayOfTaggedFriends;
@property NSMutableArray *arrayOfTaggedFriendsPositions;

@property (weak, nonatomic) IBOutlet UIButton *tagFriendsButtonOutlet;

@property (weak, nonatomic) IBOutlet UIView *viewForImage;
@property (weak, nonatomic) IBOutlet UIView *TagPeopleViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *TagPeopleSearchView;
@property (weak, nonatomic) IBOutlet UITableView *tagPeopleTableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBarForTag;
- (IBAction)tagPeopleButtonAction:(id)sender;

@property(nonatomic,assign)id delegate;

@property (weak, nonatomic) IBOutlet UILabel *dragToMoveMessageLabel;


@end
