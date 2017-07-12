//
//  FiltersViewController.h
//  Picogram
//
//  Created by Rahul Sharma on 4/25/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FiltersViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *filtersButtonOutlet;

- (IBAction)filtersButtonAction:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *brightnessButtonOutlet;
- (IBAction)brightnessButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *settingsButtonOutlet;

- (IBAction)settingsButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *colorsEffectViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *settingsViewOutlet;
@property (weak, nonatomic) IBOutlet UIView *BrightnessViewOutlet;
@property (weak, nonatomic) IBOutlet UIImageView *tappedImageView;
@property (weak,nonatomic) UIImage *receivedImage;

@property (weak, nonatomic) IBOutlet UIView *buttonsView;


//brightness(second button)
- (IBAction)brightnessOKButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *brightnessCancelButtonOutlet;

- (IBAction)cancelBrightnessButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *broighnessOKButtonOutlet;

@property (weak, nonatomic) IBOutlet UISlider *sliderForBrightness;





@end
