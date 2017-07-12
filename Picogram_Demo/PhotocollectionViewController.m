//
//  PhotocollectionViewController.m
//  Picogram_Demo
//
//  Created by Rahul Sharma on 4/5/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "PhotocollectionViewController.h"



#import "TLYShyNavBar.h"
#import "TLYShyNavBarManager.h"



@interface PhotocollectionViewController ()
{

 PhotoCollectionViewCell *cell;
    
}
@property (nonatomic, strong) NSArray *data;
@end

@implementation PhotocollectionViewController

 static NSString * const reuseIdentifier = @"CCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
   
    
    
    self.data = @[@"No Game No Life",
                  @"Ookami Kodomo no Ame to Yuki",
                  @"Owari no Seraph",
                  @"Prince of Tennis",
                  @"Psycho-Pass",
                  @"Psycho-Pass 2",
                  @"School Rumble",
                  @"Sen to Chihiro no Kamikakushi",
                  @"Shijou Saikyou no Deshi Kenichi",
                  @"Shingeki no Kyojin",
                  @"Soul Eater",
                  @"Steins;Gate",
                  @"Summer Wars",
                  @"Sword Art Online",
                  @"Sword Art Online II",
                  @"Tenkuu no Shiro Laputa",
                  @"Toki wo Kakeru Shoujo",
                  @"Tokyo Ghoul",
                  @"Tonari no Totoro",
                  @"Uchuu Kyoudai",
                  @"Yakitate!! Japan",
                  @"Zankyou ",
                  ];
    
    

    
    UIView *view = view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40.f)];
    view.backgroundColor = [UIColor redColor];
    
    
    
    /* Library code */
    self.shyNavBarManager.scrollView = self.collectionView;
    self.shyNavBarManager.scrollView=self.scrlView;
   
    /* Can then be remove by setting the ExtensionView to nil */
    [self.shyNavBarManager setExtensionView:view];
    [self.shyNavBarManager setExtensionView:self.NORMALtESTINGvIEW];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    
    cell.label.text = self.data[indexPath.item];
    
    return cell;
}

@end
