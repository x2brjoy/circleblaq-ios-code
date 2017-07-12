//
//  FiltersViewController.m
//  Picogram
//
//  Created by Rahul Sharma on 4/25/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "FiltersViewController.h"
#import "CLImageEditor.h"
#import "PGShareViewController.h"
#import  "FontDetailsClass.h"

@interface FiltersViewController ()

@end

@implementation FiltersViewController
UIButton *navCancelButton;
UIImage *originalImage;
UIButton *navNextButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tappedImageView.image = _receivedImage;
    originalImage = _receivedImage;
    [self.sliderForBrightness addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventTouchUpInside];
    self.filtersButtonOutlet.selected = YES;
    self.navigationController.navigationBar.barTintColor  = [UIColor colorWithRed:0.0588 green:0.0588 blue:0.0588 alpha:1.0];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    
    
    self.navigationItem.title = @"FILTERS";
    self.navigationItem.hidesBackButton = YES;
    [self createNavLeftButton];
    [self createNavRightButton];
}

#pragma mark
#pragma mark - filter buttons


- (IBAction)brightnessButtonAction:(id)sender {
    [self brightnessButtonTapped];
}

- (IBAction)filtersButtonAction:(id)sender {
    [self filtersButtonTapped];
}

- (IBAction)settingsButtonAction:(id)sender {
    [self settingsButtonTapped];
}

-(void)brightnessButtonTapped {
    self.BrightnessViewOutlet.hidden = NO;
    self.colorsEffectViewOutlet.hidden = YES;
    self.settingsViewOutlet.hidden = YES;
    self.brightnessButtonOutlet.selected = YES;
    self.filtersButtonOutlet.selected = NO;
    self.settingsButtonOutlet.selected = NO;
    self.buttonsView.hidden = YES;
    self.navigationItem.title = @"LUX";
    navCancelButton.hidden = YES;
    navNextButton.hidden = YES;
}

-(void)filtersButtonTapped {
    self.BrightnessViewOutlet.hidden = YES;
    self.colorsEffectViewOutlet.hidden = NO;
    self.settingsViewOutlet.hidden = YES;
    self.brightnessButtonOutlet.selected = NO;
    self.filtersButtonOutlet.selected = YES;
    self.settingsButtonOutlet.selected = NO;
    self.navigationItem.title = @"FILTERS";
    navCancelButton.hidden = NO;
    navNextButton.hidden = NO;
}

-(void)settingsButtonTapped {
    self.BrightnessViewOutlet.hidden = YES;
    self.colorsEffectViewOutlet.hidden = YES;
    self.settingsViewOutlet.hidden = NO;
    self.brightnessButtonOutlet.selected = NO;
    self.filtersButtonOutlet.selected = NO;
    self.settingsButtonOutlet.selected = YES;
    self.navigationItem.title = @"TOOLS";
    navCancelButton.hidden = NO;
    navNextButton.hidden = NO;
}

#pragma mark
#pragma mark - navigation bar back button

- (void)createNavLeftButton {
    navCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_off"]
                     forState:UIControlStateNormal];
    [navCancelButton setImage:[UIImage imageNamed:@"comments_back_icon_on"]
                     forState:UIControlStateSelected];
    [navCancelButton addTarget:self
                        action:@selector(backButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
      [navCancelButton setFrame:CGRectMake(10.0f,0.0f,40,40)];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navCancelButton];
     UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -14;// it was -6 in iOS 6
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

- (void)backButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark - navigation bar next button

- (void)createNavRightButton
{
    navNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navNextButton setTitle:@"NEXT"
                   forState:UIControlStateNormal];
    [navNextButton setTitleColor:[UIColor colorWithRed:0.2022 green:0.4257 blue:0.8057 alpha:1.0]
                        forState:UIControlStateNormal];
    [navNextButton setTitleColor:[UIColor colorWithRed:0.2022 green:0.4257 blue:0.8057 alpha:1.0]
                        forState:UIControlStateHighlighted];
    navNextButton.titleLabel.font = [UIFont fontWithName:RobotoRegular size:13];
    [navNextButton setFrame:CGRectMake(0,0,50,30)];
    [navNextButton addTarget:self action:@selector(NextButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *containingcancelButton = [[UIBarButtonItem alloc] initWithCustomView:navNextButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer,containingcancelButton, nil] animated:NO];
}

- (void)NextButtonAction:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"shareSegue" sender:nil];
}

#pragma mark
#pragma mark - Sending Data Through Segue.

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"shareSegue"]) {
        PGShareViewController *shareVC = [segue destinationViewController];
        shareVC.image2 = _receivedImage;
    }
}

#pragma mark
#pragma mark - brightness button implementation (second button)

- (IBAction)brightnessOKButtonAction:(id)sender {
    self.BrightnessViewOutlet.hidden = YES;
    self.brightnessButtonOutlet.hidden = NO;
    self.buttonsView.hidden = NO;
    self.navigationItem.title = @"FILTERS";
    navCancelButton.hidden = NO;
    navNextButton.hidden = NO;
    [self filtersButtonTapped];
}

- (IBAction)cancelBrightnessButtonAction:(id)sender {
    self.BrightnessViewOutlet.hidden = YES;
    self.brightnessButtonOutlet.hidden = NO;
    self.buttonsView.hidden = NO;
    [self filtersButtonTapped];
}

#pragma mark
#pragma mark - slider for brightness increase or decrease.

- (IBAction) sliderMoved:(id)sender
{
    NSLog(@"%f",self.sliderForBrightness.value);
    
}

@end
