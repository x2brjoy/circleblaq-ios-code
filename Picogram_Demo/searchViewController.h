//
//  searchViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 4/12/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "searchViewCollectionViewCell.h"
#import "TLYShyNavBarManager.h"
#import "TLYShyNavBar.h"
#import "AddLocationTableViewCell.h"

@interface searchViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate,UITableViewDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *movableDividerLeadingConstraintOutlet;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewOutlet;

@property (weak, nonatomic) IBOutlet UIView *ScoralableViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *BaseScrollViewOutlet;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;


@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property int currentIndex;

@property (weak, nonatomic) IBOutlet UIButton *topButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *peopleButtonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *tagButonOutlet;
@property (weak, nonatomic) IBOutlet UIButton *placesButtonOutlet;
@property (strong, nonatomic) IBOutlet UIButton *categoryButtonOutlet;
@property (nonatomic, assign) NSInteger openSectionIndex;

- (IBAction)topButtonAction:(id)sender;
- (IBAction)PeopleButtonAction:(id)sender;
- (IBAction)tagButtonAction:(id)sender;
- (IBAction)placesButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *hashTagTableView;
@property (weak, nonatomic) IBOutlet UITableView *PeopleTableView;
@property (weak, nonatomic) IBOutlet UITableView *topTableView;
@property (weak, nonatomic) IBOutlet UITableView *placesTableView;
@property (strong, nonatomic) IBOutlet UITableView *categoryTableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintOfBaseScrollView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *categoryWidthconstrainOutlet;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topbuttonWidthOutlet;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *categoryBtnWidthOutlet;
@property (strong, nonatomic) IBOutlet UIView *basecontentview;

#define searchedHashTagData   @"searchedHasgTagData"

@end
