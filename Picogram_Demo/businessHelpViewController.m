//
//  businessHelpViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 24/10/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "businessHelpViewController.h"
#import "Helper.h"
#import "FontDetailsClass.h"
#import "businessSetupViewController.h"

#define h [[UIScreen mainScreen] bounds].size.height;
#define w [[UIScreen mainScreen] bounds].size.width;
@interface businessHelpViewController ()<UIScrollViewDelegate>
{
    NSMutableArray *contentArray1,*contentArray2,*contentArray3,*contentArray;
    NSArray *titleArray,*imageArray,*content2DArray;
    UIView *baseView;
    UIScrollView *helpscrollView;
    UIImageView *businessImgView;
    UILabel *titleLbl;
    UILabel *contentLbl1;
    UILabel *contentLbl2;
    UILabel *contentLbl3;
    UIPageControl *pageControl;
    UIButton *infoLblBtn;
    BOOL measuredHeight;
}

@end

@implementation businessHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     //self.tabBarController.tabBar.hidden = YES;
    
    if (([[UIScreen mainScreen]bounds].size.height) < 520) {
        measuredHeight = YES;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self stillButtons];
    
    titleArray = [[NSArray alloc] initWithObjects:@"Picogram for business",@"Business Profile",@"Insights", nil];
    NSLog(@"Title:%@",titleArray);
    imageArray = [[NSArray alloc] initWithObjects:@"picogram_business_icon",@"business_profile_user_icon",@"insight_inshgit_icon", nil];

    
    content2DArray = @[@[@"Connect your online shop to Picogram",@"and leverage your social followers",@"to get more business."],@[@"Add a phone number email and location so",@"customers can reach you directly from a",@"button on your profile"],@[@"Learn about your followers and",@"see how your posts are performing",@""]];
    contentArray = [[NSMutableArray alloc]init];
    
    [self createHelpView];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
   // self.tabBarController.hidesBottomBarWhenPushed = YES;
    self.hidesBottomBarWhenPushed = YES;
    BOOL chk = [[NSUserDefaults standardUserDefaults]boolForKey:@"BussinessSuccess"];
    if (chk) {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    
    [self.navigationController.navigationBar setHidden:NO];
    
}
-(void)stillButtons
{
    UIButton *crossBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 20, 40, 40)];
    [crossBtn setImage:[UIImage imageNamed:@"settings_back_icon_off.png"] forState:UIControlStateNormal];
    [crossBtn setImage:[UIImage imageNamed:@"settings_back_icon_on.png"] forState:UIControlStateHighlighted];
    [crossBtn addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:crossBtn];
    
    
    UIButton *countinueBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, [[UIScreen mainScreen]bounds].size.height-60, [[UIScreen mainScreen]bounds].size.width-40, 40)];
    countinueBtn.layer.cornerRadius = 5.0f;
    //countinueBtn.backgroundColor = [UIColor colorWithRed:225/255.0f green:48/255.0f blue:108/255.0f alpha:1.0f];
    
    
    countinueBtn.titleLabel.textColor = [UIColor whiteColor];
    [countinueBtn setImage:[UIImage imageNamed:@"setupBtnOff"] forState:UIControlStateNormal];
    [countinueBtn setImage:[UIImage imageNamed:@"setupBtnOn"] forState:UIControlStateHighlighted];
    [countinueBtn addTarget:self action:@selector(countinueBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:countinueBtn];
    UILabel *btnLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width-40, 40)];
    btnLbl.backgroundColor = [UIColor clearColor];
    btnLbl.textAlignment = NSTextAlignmentCenter;
    [Helper setToLabel:btnLbl Text:@"SETUP BUSINESS PROFILE" WithFont:RobotoMedium FSize:11 Color:[UIColor whiteColor]];
    [countinueBtn addSubview:btnLbl];
    


}

-(void)createHelpView
{
    if (measuredHeight)
        helpscrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,80,  [[UIScreen mainScreen]bounds].size.width,  [[UIScreen mainScreen]bounds].size.width)];
    else
        helpscrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,100,  [[UIScreen mainScreen]bounds].size.width,  [[UIScreen mainScreen]bounds].size.width)];
    helpscrollView.delegate = self;
    [self.view addSubview:helpscrollView];
    self.myscrollView.showsVerticalScrollIndicator = NO;
    [helpscrollView setContentSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width*3, [[UIScreen mainScreen]bounds].size.width)];
    //helpscrollView.scrollEnabled = YES;
    //helpscrollView.backgroundColor = [UIColor yellowColor];
    helpscrollView.showsHorizontalScrollIndicator = NO;
    helpscrollView.pagingEnabled = YES;
    if (measuredHeight) {
     pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0,[[UIScreen mainScreen]bounds].size.height-130 , [[UIScreen mainScreen]bounds].size.width, 40)];
    infoLblBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, [[UIScreen mainScreen]bounds].size.height-130, [[UIScreen mainScreen]bounds].size.width, 40)];
    }
    else
    {
    pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, 400, [[UIScreen mainScreen]bounds].size.width, 40)];
    infoLblBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 400, [[UIScreen mainScreen]bounds].size.width, 40)];
    }
    pageControl.numberOfPages = 3;
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
    [pageControl setHidden:YES];
    [self.view addSubview:pageControl];
    
    [Helper setButton:infoLblBtn Text:@"View Features >" WithFont:RobotoMedium FSize:14 TitleColor:[UIColor colorWithRed:77/255.0f green:179/255.0f blue:223/225.0f alpha:1.0f] ShadowColor:nil];
    [infoLblBtn addTarget:self action:@selector(changePageOnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:infoLblBtn];
    
    
    
    int i;
    
    for (i = 0; i<3; i++) {
        
        contentArray = [content2DArray[i] copy];
        baseView = [[UIView alloc]initWithFrame:CGRectMake(i*[[UIScreen mainScreen]bounds].size.width, 0,  [[UIScreen mainScreen]bounds].size.width,  [[UIScreen mainScreen]bounds].size.width)];
        
         [helpscrollView addSubview:baseView];
        UIImage *businessImage = [UIImage imageNamed:imageArray[i]];
        businessImgView = [[UIImageView alloc] initWithImage:businessImage];
       
        businessImgView.contentMode = UIViewContentModeScaleAspectFill;
        [baseView addSubview:businessImgView];
        
       
        if (measuredHeight)
        {
         businessImgView.frame = CGRectMake( [[UIScreen mainScreen]bounds].size.width/2-35, 50, 70, 70);
         titleLbl = [[UILabel alloc]initWithFrame: CGRectMake(0,CGRectGetMaxY(businessImgView.frame)+20,baseView.frame.size.width, 50)];
          contentLbl1 = [[UILabel alloc]initWithFrame:CGRectMake(5,CGRectGetMaxY(titleLbl.frame)+5,baseView.frame.size.width-10, 30)];
          contentLbl2 = [[UILabel alloc]initWithFrame:CGRectMake(5,CGRectGetMaxY(contentLbl1.frame)-15,baseView.frame.size.width-10, 30)];
          contentLbl3 = [[UILabel alloc]initWithFrame:CGRectMake(5,CGRectGetMaxY(contentLbl2.frame)-15,baseView.frame.size.width-10,30)];
            
        
        }   else
        {
         businessImgView.frame = CGRectMake( [[UIScreen mainScreen]bounds].size.width/2-35, 64, 70, 70);
          titleLbl = [[UILabel alloc]initWithFrame: CGRectMake(0,CGRectGetMaxY(businessImgView.frame)+40,baseView.frame.size.width,50)];
          contentLbl1 = [[UILabel alloc]initWithFrame:CGRectMake(5,CGRectGetMaxY(titleLbl.frame)+10,baseView.frame.size.width-10, 30)];
          contentLbl2 = [[UILabel alloc]initWithFrame:CGRectMake(5,CGRectGetMaxY(contentLbl1.frame)-15,baseView.frame.size.width-10, 30)];
          contentLbl3 = [[UILabel alloc]initWithFrame:CGRectMake(5,CGRectGetMaxY(contentLbl2.frame)-15,baseView.frame.size.width-10, 30)];
        }
    
        [baseView addSubview:titleLbl];
        titleLbl.numberOfLines = 0;
        [Helper setToLabel:titleLbl Text:titleArray[i] WithFont:RobotoLight FSize:26.06f Color:[UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f]];
        titleLbl.textAlignment = NSTextAlignmentCenter;
        
        
        
        contentLbl1.numberOfLines = 0 ;
        [Helper setToLabel:contentLbl1 Text:contentArray[0] WithFont:RobotoMedium FSize:12 Color:[UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f]];
        [Helper setToLabel:contentLbl2 Text:contentArray[1] WithFont:RobotoMedium FSize:12 Color:[UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f]];
        [Helper setToLabel:contentLbl3 Text:contentArray[2] WithFont:RobotoMedium FSize:12 Color:[UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1.0f]];
        contentLbl1.textAlignment = NSTextAlignmentCenter;
        contentLbl2.textAlignment = NSTextAlignmentCenter;
        contentLbl3.textAlignment = NSTextAlignmentCenter;
        //contentLbl.backgroundColor = [UIColor redColor];
        [baseView addSubview:contentLbl1];
        [baseView addSubview:contentLbl2];
        [baseView addSubview:contentLbl3];
        
               
    }
    
    
}

#pragma mark - scrollView delegates

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = scrollView.contentOffset.x / scrollView.frame.size.width;
    
    pageControl.currentPage = page;
    if(page == 0)
    {
        [pageControl setHidden:YES];
        [infoLblBtn setHidden:NO];
    }
    else
    {
        [pageControl setHidden:NO];
        [infoLblBtn setHidden:YES];
    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

}

#pragma mark - CloseBtn Action
-(void)closeBtnAction
{
   // self.hidesBottomBarWhenPushed = NO;
    if (_fromController) {
        [UIView transitionWithView:self.view.window
                          duration:1.0f
                           options:UIViewAnimationOptionTransitionCurlUp
                        animations:^{
                            self.tabBarController.hidesBottomBarWhenPushed = NO;

                            [self.navigationController popViewControllerAnimated:NO];
                            
                        }
                        completion:NULL];
    }else
        [self.navigationController popViewControllerAnimated:YES];
        //[self.navigationController popToRootViewControllerAnimated:YES];
      
    
    
   // [businessVC.navigationController setNavigationBarHidden:YES];
    
// [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)countinueBtnAction
{
    businessSetupViewController *businessVC = [[businessSetupViewController alloc] init];
    businessVC.fromController = _fromController;
    self.tabBarController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:businessVC animated:YES];
    [businessVC.navigationController setNavigationBarHidden:YES];
    
}


- (IBAction)changePage:(id)sender {
    UIPageControl *pages=sender;
    int page = (int)pages.currentPage;
    CGRect frame = helpscrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [helpscrollView scrollRectToVisible:frame animated:YES];
}

- (IBAction)changePageOnClick:(id)sender {
    
    int page = 1;
    CGRect frame = helpscrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [helpscrollView scrollRectToVisible:frame animated:YES];
}
@end
