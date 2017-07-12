//
//  MediaEditViewController.m
//  VIND
//
//  Created by Vinay Raja on 24/08/14.
//
//

#import "MediaEditViewController.h"
#import "SCAssetExportSession.h"
#import "SCVideoPlayerView.h"
#import "SCFilterSwitcherView.h"
#import "SCRecorder.h"
#import "ISColorWheel.h"
#import "MediaShareViewController.h"
#import <ActionSheetPicker-3.0/ActionSheetStringPicker.h>

@interface MediaEditViewController () <SCPlayerDelegate, UITextFieldDelegate, ISColorWheelDelegate,UIAlertViewDelegate>
{
    SCPlayer *_player;
    NSArray *ciFilters;
    
    NSInteger selectedFilterIndex;
}

@property (weak, nonatomic) IBOutlet SCFilterSwitcherView *filterSwitcherView;
@property (weak, nonatomic) IBOutlet UIButton *overlayButton;
@property (weak, nonatomic) IBOutlet UIButton *textButton;
@property (weak, nonatomic) IBOutlet UIButton *addFilterButton;
@property (weak, nonatomic) IBOutlet UIScrollView *filterSelecter;
@property (weak, nonatomic) IBOutlet UIButton *colorChooser;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIView *colorPickerView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *sizePickerView;
@property (weak, nonatomic) IBOutlet UIButton *sizePickerButton;
@property (weak, nonatomic) IBOutlet UIButton *normalSizePickerButton;
@property (weak, nonatomic) IBOutlet UIButton *largerSizePickerButton;
@property (weak, nonatomic) IBOutlet UIButton *smallerSizePickerButton;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UITextField *overlayTextField;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIView *smallerOverlayView;
@property (weak, nonatomic) IBOutlet UITextField *smallerOverlayTextField;
@property (weak, nonatomic) IBOutlet UIImageView *smallerLogoImageView;
@property (weak, nonatomic) IBOutlet UIView *largerOverlayView;
@property (weak, nonatomic) IBOutlet UITextField *largerOverlayTextField;
@property (weak, nonatomic) IBOutlet UIImageView *largerLogoImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) UIView *selectedSizeView;
@property (weak, nonatomic) UIImageView *selectedSizeImageView;
@property (weak, nonatomic) UITextField *selectedSizeTextField;
@property (strong, nonatomic) NSString *selectedSizeLogoName;


@property (weak, nonatomic) IBOutlet UIView *tagView;
@property (weak, nonatomic) IBOutlet UIView *searchBG;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITextField *textFeildPrice;
@property (weak, nonatomic) IBOutlet UITextField *textFeildCurrency;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (nonatomic,strong) NSMutableArray *brandNames;
@property (strong, nonatomic) NSMutableArray* filteredTableData;
@property (nonatomic,assign)BOOL isFiltered;
@property (weak, nonatomic) IBOutlet UIButton *buttonDone;
@property (assign, nonatomic) CGPoint lastTouchPoint;
@property (strong, nonatomic) UIView *selectedTagView;
@property (strong, nonatomic) NSMutableArray *tags;


@property (nonatomic, strong) ISColorWheel *cPicker;

@end

@implementation MediaEditViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _overlayButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    _overlayButton.layer.borderWidth = 2;
    
    _textButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    _textButton.layer.borderWidth = 2;
    
    _addFilterButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    _addFilterButton.layer.borderWidth = 2;
    
    selectedFilterIndex = 0;
    
    _selectedSizeImageView = _logoImageView;
    _selectedSizeTextField = _overlayTextField;
    _selectedSizeView = _overlayView;
    _selectedSizeLogoName = @"overlayGLogo";
    [_buttonDone setTitle:@"Next" forState:UIControlStateNormal];
    
    _overlayView.hidden = YES;
    _normalSizePickerButton.selected = YES;
    
    [_titleLabel setFont:[UIFont fontWithName:Aharoni_Bold size:18]];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"Brand"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            _brandNames = [[NSMutableArray alloc] init];
            for(PFObject *object in objects){
                [_brandNames addObject:[object objectForKey:@"brandName"]];
            }
            
            [_tableview reloadData];
        }
        else {
            _brandNames = [[NSMutableArray alloc] initWithObjects:@"Nike",@"Adidas",@"Reebok",@"Puma",@"Jordan",@"Under Armour",@"Converse",@"Vans",@"New Balance",@"FILA",@"Asics",@"Skechers",@"Lotto",@"Woodland",@"Saucony",@"Sparx",@"Mizuno",@"K-Swiss",@"Keds",@"Supra", nil];
        }
    }];
    
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tap.numberOfTapsRequired = 1;
    // [_previewView addGestureRecognizer:tap];
    
}

-(void)handleTapGesture:(UIGestureRecognizer*)gesture{
    
    
    _isFiltered = NO;
    _searchBar.text = @"";
    _textFeildCurrency.text = @"$";
    _textFeildPrice.text = @"";
    
    
    [_buttonDone setTitle:@"Done" forState:UIControlStateNormal];
    _lastTouchPoint = [gesture locationInView:_previewImageView];
    
    [UIView animateWithDuration:.2 animations:^{
        _tagView.alpha = 1.0;
        _tagView.hidden = NO;
        _buttonDone.hidden = NO;
    }];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self setupFilters];
    });
    
    if (IS_IOS7) {
        ciFilters = @[[NSNull null], @"CIPhotoEffectNoir", @"CIPhotoEffectChrome", @"CIPhotoEffectInstant", @"CIPhotoEffectTonal", @"CIPhotoEffectFade"];
        
    }
    else {
        ciFilters = nil;
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Filters not available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        
    }
    
    
    //[self scrollviewForImageFilters];
    
    if (_isMediaTypeImage) {
        _filterSwitcherView.hidden = YES;
        _previewImageView.hidden = NO;
        
        _playButton.hidden = YES;
        _previewImageView.image = [UIImage imageWithContentsOfFile:_mediaPath];
        [_previewImageView setContentMode:UIViewContentModeScaleAspectFill];
        
    }
    else {
        _filterSwitcherView.hidden = NO;
        _previewImageView.hidden = YES;
        
        if (IS_IOS7) {
            self.filterSwitcherView.filterGroups = @[
                                                     [NSNull null],
                                                     [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectNoir"]],
                                                     [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectChrome"]],
                                                     [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectInstant"]],
                                                     [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectTonal"]],
                                                     [SCFilterGroup filterGroupWithFilter:[SCFilter filterWithName:@"CIPhotoEffectFade"]]
                                                     ];
        }
        else {
            self.filterSwitcherView.filterGroups = nil;
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Filters not available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }
        
        
        self.filterSwitcherView.disabled = NO;;
        _player = [SCPlayer player];
        if (!_mediaPath) {
            [_player setItemByAsset:_recordSession.assetRepresentingRecordSegments];
            
        }
        else {
            [_player setItemByStringPath:_mediaPath];
        }
        
        self.filterSwitcherView.player = _player;
        self.filterSwitcherView.SCImageView.viewMode = SCImageViewModeFillAspectRatio;
        
        
        _player.shouldLoop = NO;
        
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        _playButton.hidden = YES;
        
        [_player play];
        
    }
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    if (!_isMediaTypeImage) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}


/**
 *  This method will let the recorded video play and hide the play button until it playing
 *
 *  @param sender
 */
- (IBAction)playVideo:(id)sender
{
    [_player seekToTime:kCMTimeZero];
    [_player play];
    
    _playButton.hidden = YES;
    _previewImageView.hidden = YES;
}


/**
 *  video completed playing
 *
 *  @param notif video reached its end
 */

-(void)itemDidFinishPlaying:(NSNotification*)notif {
    NSLog(@"finish playing");
    _playButton.hidden = NO;
    
    if (!_previewImageView.image)
    {
        _previewImageView.image = [self firstFrameOfVideo];
        
    }
    
}

/**
 *  image filters for enhancing images
 */
- (void) setupFilters
{
    UIImage *origImage = nil;
    if (_isMediaTypeImage) {
        origImage = [UIImage imageWithContentsOfFile:_mediaPath];
    }
    else {
        origImage = [self firstFrameOfVideo];
    }
    
    UIImage *squareImage = [self squareImageFromImage:origImage scaledToSize:40];
    
    CIImage *original = [CIImage imageWithCGImage:squareImage.CGImage];
    
    for (NSInteger tag = 0; tag < 6; tag++) {
        CIImage *result = original;
        if (IS_IOS7) {
            if (tag != 0) {
                CIFilter *ciFilter = [CIFilter filterWithName:[ciFilters objectAtIndex:tag]];
                [ciFilter setValue:result forKey:kCIInputImageKey];
                result = [ciFilter valueForKey:kCIOutputImageKey];
            }
        }
        
        CGImageRef moi3 = [[CIContext contextWithOptions:nil]
                           createCGImage:result
                           fromRect:original.extent];
        UIImage *moi4 = [UIImage imageWithCGImage:moi3];
        CGImageRelease(moi3);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *subview = [_filterSelecter viewWithTag:tag];
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *btn = (UIButton*)subview;
                [btn setImage:moi4 forState:UIControlStateNormal];
                [btn setTitle:@"" forState:UIControlStateNormal];
                btn.layer.borderWidth = 2;
                btn.layer.borderColor = [UIColor whiteColor].CGColor;
            }
        });
    }
    
    
}
/**
 *   croping image to square
 *
 *  @param image   original image
 *  @param newSize cropped  image
 *
 *  @return newsized image
 */
- (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


- (UIImage*)firstFrameOfVideo
{
    AVAsset *asset = nil;
    if (_mediaPath) {
        asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:_mediaPath]];
    }
    else {
        asset = _recordSession.assetRepresentingRecordSegments;
    }
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMake(1, 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationUp];
    
    return thumbnail;
    
}


- (IBAction)toggleOverlay:(UIButton*)sender
{
    if (!_filterSelecter.hidden) {
        [self toggleFilterView:nil];
    }
    
    [self toggleColorPicker:_colorChooser];
    
    //    if (sender.selected) {
    //        sender.selected = NO;
    //        _overlayView.hidden = NO;
    //        _colorChooser.hidden = NO;
    //        //_textButton.enabled = YES;
    //    }
    //    else {
    //        sender.selected = YES;
    //        _overlayView.hidden = YES;
    //        _colorChooser.hidden = YES;
    //        //_textButton.enabled = NO;
    //
    //    }
}

- (IBAction)editText:(UIButton*)sender
{
    if (!_filterSelecter.hidden) {
        [self toggleFilterView:nil];
    }
    if ([_selectedSizeTextField isFirstResponder]) {
        [_selectedSizeTextField resignFirstResponder];
    }
    else {
        [_selectedSizeTextField becomeFirstResponder];
    }
}

/**
 *  move to previous controller
 *
 *  @param sender back button press
 */
- (IBAction)backButtonAction:(id)sender
{
    if ([_tagView isHidden]) {
        [_player pause];
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        _tagView.hidden = YES;
    }
    
}

- (IBAction)toggleFilterView:(UIButton*)sender
{
    _filterSelecter.hidden = !_filterSelecter.hidden;
    
    if (!_filterSelecter.hidden) {
        //_addFilterButton.layer.borderColor = [[UIColor redColor] CGColor];
        _addFilterButton.layer.borderColor = [[UIColor colorWithRed:85/255.0 green:153/255.0 blue:235/255.0 alpha:1.0] CGColor ];
        _overlayButton.hidden = YES;
        _textButton.hidden = YES;
        _sizePickerButton.hidden = YES;
    }
    else {
        _addFilterButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        _overlayButton.hidden = NO;
        _textButton.hidden = NO;
        _sizePickerButton.hidden = NO;
    }
    
    //_colorChooser.hidden = !_colorChooser.hidden;
    
}

- (IBAction)toggleSizePickerView:(UIButton*)sender
{
    _sizePickerView.hidden = !_sizePickerView.hidden;
    
    if (!_sizePickerView.hidden) {
        _overlayButton.hidden = YES;
        _textButton.hidden = YES;
        _addFilterButton.hidden = YES;
        sender.selected = YES;
        
    }
    else {
        _overlayButton.hidden = NO;
        _textButton.hidden = NO;
        _addFilterButton.hidden = NO;
        sender.selected = NO;
    }
    
    //_colorChooser.hidden = !_colorChooser.hidden;
    
}


- (IBAction)toggleColorPicker:(id)sender
{
    if (self.cPicker == nil) {
        
        CGSize size = _colorPickerView.bounds.size;
        
        CGSize wheelSize = CGSizeMake(size.width * .6, size.width * .6 );
        
        float topOffset = 0.05;
        if (!IS_IPHONE_5) {
            topOffset = 0.01;
        }
        
        _cPicker = [[ISColorWheel alloc] initWithFrame:CGRectMake(size.width / 2 - wheelSize.width / 2,
                                                                  size.height * topOffset,
                                                                  wheelSize.width,
                                                                  wheelSize.height)];
        _cPicker.delegate = self;
        _cPicker.continuous = true;
        [_colorPickerView addSubview:_cPicker];
        
        UISlider *_brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(size.width * .65,
                                                                                 size.height * .45,
                                                                                 size.width * .5,
                                                                                 size.height * .1)];
        
        CGAffineTransform trans = CGAffineTransformMakeRotation(-M_PI * 0.5);
        _brightnessSlider.transform = trans;
        
        _brightnessSlider.minimumValue = 0.0;
        _brightnessSlider.maximumValue = 1.0;
        _brightnessSlider.value = 1.0;
        _brightnessSlider.continuous = true;
        [_brightnessSlider addTarget:self action:@selector(changeBrightness:) forControlEvents:UIControlEventValueChanged];
        [_colorPickerView addSubview:_brightnessSlider];
    }
    
    _colorPickerView.hidden = !_colorPickerView.hidden;
}

- (IBAction)changeSize:(UIButton*)sender
{
    if ([_smallerSizePickerButton isEqual:sender]) {
        _largerSizePickerButton.selected = NO;
        _normalSizePickerButton.selected = NO;
        
        _smallerOverlayView.hidden = NO;
        _overlayView.hidden = YES;
        _largerOverlayView.hidden = YES;
        
        _smallerOverlayTextField.text = _selectedSizeTextField.text;
        
        _selectedSizeView = _smallerOverlayView;
        _selectedSizeImageView = _smallerLogoImageView;
        _selectedSizeTextField = _smallerOverlayTextField;
        _selectedSizeLogoName = @"overlayGLogo_smaller";
        
    }
    else if ([_largerSizePickerButton isEqual:sender]) {
        _smallerSizePickerButton.selected = NO;
        _normalSizePickerButton.selected = NO;
        
        _smallerOverlayView.hidden = YES;
        _overlayView.hidden = YES;
        _largerOverlayView.hidden = NO;
        
        _largerOverlayTextField.text = _selectedSizeTextField.text;
        
        _selectedSizeView = _largerOverlayView;
        _selectedSizeImageView = _largerLogoImageView;
        _selectedSizeTextField = _largerOverlayTextField;
        _selectedSizeLogoName = @"overlayGLogo_larger";
        
        
    }
    else if ([_normalSizePickerButton isEqual:sender]) {
        _largerSizePickerButton.selected = NO;
        _smallerSizePickerButton.selected = NO;
        
        _smallerOverlayView.hidden = YES;
        _overlayView.hidden = NO;
        _largerOverlayView.hidden = YES;
        
        _overlayTextField.text = _selectedSizeTextField.text;
        
        _selectedSizeView = _overlayView;
        _selectedSizeImageView = _logoImageView;
        _selectedSizeTextField = _overlayTextField;
        _selectedSizeLogoName = @"overlayGLogo";
        
    }
    sender.selected = YES;
    [self colorWheelDidChangeColor:_cPicker];
    
}

- (IBAction)selectFilter:(UIButton*)sender
{
    NSInteger tag = sender.tag;
    
    if (tag == selectedFilterIndex) {
        return;
    }
    
    selectedFilterIndex = tag;
    
    if (_isMediaTypeImage) {
        CIImage *original = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:_mediaPath]];
        CIImage *result = original;
        if (IS_IOS7) {
            if (tag != 0) {
                CIFilter *ciFilter = [CIFilter filterWithName:[ciFilters objectAtIndex:tag]];
                [ciFilter setValue:result forKey:kCIInputImageKey];
                result = [ciFilter valueForKey:kCIOutputImageKey];
            }
        }
        
        CGImageRef moi3 = [[CIContext contextWithOptions:nil]
                           createCGImage:result
                           fromRect:original.extent];
        UIImage *moi4 = [UIImage imageWithCGImage:moi3];
        CGImageRelease(moi3);
        _previewImageView.image = moi4;
        [_previewImageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    else {
        CIImage *original = _previewImageView.image.CIImage;
        if (!original) {
            original = [CIImage imageWithCGImage:_previewImageView.image.CGImage];
        }
        CIImage *result = original;
        if (IS_IOS7) {
            if (tag != 0) {
                CIFilter *ciFilter = [CIFilter filterWithName:[ciFilters objectAtIndex:tag]];
                [ciFilter setValue:result forKey:kCIInputImageKey];
                result = [ciFilter valueForKey:kCIOutputImageKey];
            }
        }
        
        CGImageRef moi3 = [[CIContext contextWithOptions:nil]
                           createCGImage:result
                           fromRect:original.extent];
        UIImage *moi4 = [UIImage imageWithCGImage:moi3];
        CGImageRelease(moi3);
        _previewImageView.image = moi4;
        
        [_filterSwitcherView selectFilterAtIndex:tag];
    }
}



/**
 *  sending media file path for further sharing
 *
 *  @param mPath filepath with its extensions
 */
- (void) goToMediaShareViewWithMediaPath:(NSString*)mPath
{
    MediaShareViewController *shareCtrl = nil;
    if (IS_IPHONE_5) {
        shareCtrl = [[MediaShareViewController alloc] initWithNibName:@"MediaShareViewController" bundle:nil];
    }
    else
    {
        shareCtrl = [[MediaShareViewController alloc] initWithNibName:@"MediaShareViewController_ip3" bundle:nil];
    }
    
    [self.navigationController pushViewController:shareCtrl animated:YES];
    shareCtrl.brandTags = _tags;
    shareCtrl.isMediaTypeImage = _isMediaTypeImage;
    shareCtrl.mediaPath = mPath;
    
}

-(CGPoint)getCorrectPoints{
    
    CGPoint newPoint;
    if (_lastTouchPoint.y < 15) {
        
        newPoint.y = 35;
        newPoint.x = _lastTouchPoint.x;
    }
    else if(_lastTouchPoint.y > (_previewImageView.bounds.size.height - 15)){
        newPoint.y = (_previewImageView.bounds.size.height - 35);
        newPoint.x = _lastTouchPoint.x;
    }
    //    else if(_lastTouchPoint.x < 100){
    //        newPoint.y = _lastTouchPoint.y;
    //        newPoint.x = 120;
    //    }
    else if(_lastTouchPoint.x > (_previewImageView.bounds.size.width - 110)){
        newPoint.x = (_previewImageView.bounds.size.width - 120);
        newPoint.y = _lastTouchPoint.y;
    }
    else {
        newPoint = _lastTouchPoint;
    }
    return newPoint;
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        [_selectedTagView removeFromSuperview];
    }
    
}
-(void)buttonTagViewClicked:(UIButton*)sender{
    
    _selectedTagView = sender.superview;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this tag" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
    [alert show];
    
    
}
-(UIImage*)getViewAsImage:(UIView*)template
{
    UIGraphicsBeginImageContextWithOptions(template.bounds.size, NO, [[UIScreen mainScreen] scale]);
    // UIGraphicsBeginImageContext(topImg.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // CGContextTranslateCTM(ctx, topImg.frame.size.width * 0.5f, topImg.frame.size.height  * 0.5f);
    CGFloat angle = atan2(template.transform.b, template.transform.a);
    CGContextRotateCTM(ctx, angle);
    //[img drawInRect:CGRectMake(- topImg.frame.size.width * 0.5f, -(topImg.frame.size.height  * 0.5f), topImg.frame.size.width, topImg.frame.size.height)];
    [template.layer renderInContext:ctx];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(UIImage *)mergeImage:(UIImage*)image{
    
    UIImage *bottomImage = _previewImageView.image;
    
    UIImage *topImage = image;
    
    UIGraphicsBeginImageContext(bottomImage.size);
    
    [bottomImage drawInRect:CGRectMake(0, 0, bottomImage.size.width, bottomImage.size.height)];
    [topImage drawInRect:CGRectMake(0,0,480,480)];
    
    
    
    
    UIImage *newImage2 = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage2;
    
}
- (void) detectPan:(UIPanGestureRecognizer *) uiPanGestureRecognizer
{
    
    CGPoint point = [uiPanGestureRecognizer locationInView:_previewView];
    
    if (point.y + 20 > _previewView.frame.size.height || point.x + 20 > _previewView.frame.size.height || point.x< 20 || point.y < 20) {
        
    }
    else {
        uiPanGestureRecognizer.view.center = [uiPanGestureRecognizer locationInView:_previewView];
    }
    
    
}

/**
 *  done button action
 *
 *  @param sender button pressed
 */
- (IBAction)doneButtonAction:(UIButton*)sender
{
    
    if ([sender.titleLabel.text isEqualToString:@"Done"]) {
        
        if ([_searchBar.text length] == 0) {
            _tagView.hidden = YES;
            return;
        }
        
        [_textFeildPrice resignFirstResponder];
        [_searchBar resignFirstResponder];
        
        _tagView.hidden = YES;
        [sender setTitle:@"Next" forState:UIControlStateNormal];
        
        CGPoint newpoint = [self getCorrectPoints];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(newpoint.x, newpoint.y, 110, 30)];
        view.backgroundColor = [UIColor clearColor];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(detectPan:)];
        [view addGestureRecognizer:panRecognizer];
        
        UIImageView *imagearrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 30)];
        imagearrow.image = [UIImage imageNamed:@"tag_bg_left"];
        [view addSubview:imagearrow];
        
        UIImageView *imageBG = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 95, 30)];
        imageBG.image = [UIImage imageNamed:@"tag_bg"];
        [view addSubview:imageBG];
        
        UILabel *labelBrand = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, 95, 15)];
        [view addSubview:labelBrand];
        labelBrand.tag = 10;
        labelBrand.textColor = [UIColor whiteColor];
        labelBrand.textAlignment = NSTextAlignmentCenter;
        labelBrand.font = [UIFont fontWithName:@"Helvetica" size:10];
        labelBrand.text = _searchBar.text;
        labelBrand.backgroundColor = [UIColor clearColor];
        
        UILabel *labelPrice = [[UILabel alloc] initWithFrame:CGRectMake(15,13, 95, 15)];
        [view addSubview:labelPrice];
        labelPrice.tag = 11;
        if (_textFeildPrice.text.length == 0) {
            labelPrice.text = @"";
        }
        else{
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
            NSString *numberAsString = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:[_textFeildPrice.text floatValue]]];
            
            
            numberAsString = [numberAsString stringByReplacingOccurrencesOfString:@"," withString:@"."];
            
            labelPrice.text = [NSString stringWithFormat:@"%@ %@",numberAsString,_textFeildCurrency.text];
        }
        
        labelPrice.textAlignment = NSTextAlignmentCenter;
        labelPrice.font = [UIFont fontWithName:@"Helvetica" size:10];
        labelPrice.backgroundColor = [UIColor clearColor];
        labelPrice.textColor = [UIColor whiteColor];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 110, 30);
        [button addTarget:self action:@selector(buttonTagViewClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        if (_lastTouchPoint.x > 200) {
            imagearrow.image = [UIImage imageNamed:@"tag_bg_right"];
            imagearrow.frame = CGRectMake(110-17, 0, 15, 30);
            imageBG.frame = CGRectMake(0, 0, 95, 30);
            labelPrice.frame = CGRectMake(2, 13, 95, 15);
            labelBrand.frame = CGRectMake(2, 2, 95, 15);
            
        }
        
        
        
        [_previewView addSubview:view];
        
        
        
        
    }
    else {
        
        
        
        NSString *finalMediaPath = nil;
        if (_isMediaTypeImage) {
            
            _tags = [[NSMutableArray alloc] init];
            for(UIView *view in _previewView.subviews){
                
                
                
                //NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                UILabel *brand = (UILabel*)[view viewWithTag:10];
                //UILabel *price = (UILabel*)[view viewWithTag:11];
                
                [_tags addObject:brand.text];
                
                //[dict setObject:price.text forKey:@"price"];
                //[dict setObject:brand.text forKey:@"brand"];
                //[dict setObject:[NSNumber numberWithInteger:view.frame.origin.x] forKey:@"x"];
                //[dict setObject:[NSNumber numberWithInteger:view.frame.origin.y] forKey:@"y"];
                
                //[_tags addObject:dict];
                
                
            }
            
            UIImage *image = [self getViewAsImage:_previewView];
            
            
            
            
            UIImage *finalImage = [self mergeImage:image];//_previewImageView.image;
            
            /*
             if (!_selectedSizeView.hidden) {
             UIImage *fgImage = [self imageWithView:_selectedSizeView];
             UIImage *bgImage = _previewImageView.image;
             CGSize fgSize = fgImage.size;
             CGSize bgSize = bgImage.size;
             
             CGPoint center = CGPointMake(bgSize.width / 4, bgSize.height / 4);
             
             //finalImage = [self drawImage:fgImage inImage:bgImage atPoint:CGPointMake(center.x - fgSize.width / 2, center.y - fgSize.height / 2)];
             CGRect a = [_selectedSizeView convertRect:_selectedSizeView.bounds toView:_previewImageView];
             if (! IS_IPHONE_5) {
             float factor = 320.0 / 230.0;
             a = CGRectMake(a.origin.x * factor, a.origin.y * factor, a.size.width * factor, a.size.height * factor);
             }
             finalImage = [self drawImage:fgImage inImage:bgImage atPoint:CGPointMake(a.origin.x, a.origin.y)];
             
             }*/
            
            
            finalMediaPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"final.jpg"];
            NSData *imgData = UIImageJPEGRepresentation(finalImage, 1);
            [imgData writeToFile:finalMediaPath atomically:YES];
            
            [self goToMediaShareViewWithMediaPath:finalMediaPath];
        }
        else {
            
            
            [_player pause];
            [[ProgressIndicator sharedInstance] showPIOnView:self.view withMessage:@"Processing..."];
            
            finalMediaPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"final.mp4"];
            
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
            
            
            void(^completionHandler)(NSError *error) = ^(NSError *error) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                if (error == nil) {
                    //[self.recordSession saveToCameraRoll];
                    
                    
                    if (_selectedSizeView.hidden) {
                        [[ProgressIndicator sharedInstance] hideProgressIndicator];
                        
                        [self goToMediaShareViewWithMediaPath:finalMediaPath];
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self videoOutput:[AVAsset assetWithURL:[NSURL fileURLWithPath:finalMediaPath]]];
                        });
                    }
                    
                    
                } else {
                    [[ProgressIndicator sharedInstance] hideProgressIndicator];
                    
                    [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                }
            };
            
            
            AVAsset *vAsset;
            
            if (!_mediaPath) {
                vAsset = _recordSession.assetRepresentingRecordSegments;
            }
            else {
                vAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:_mediaPath]];
            }
            
            SCFilterGroup *selectedFG = nil;
            
            if ([_filterSwitcherView.selectedFilterGroup isEqual:[NSNull null]]){
                selectedFG = nil;
            }
            else {
                selectedFG = _filterSwitcherView.selectedFilterGroup;
            }
            
            SCAssetExportSession *exportSession = [[SCAssetExportSession alloc] initWithAsset:vAsset];
            exportSession.filterGroup = selectedFG;
            exportSession.sessionPreset = SCAssetExportSessionPresetHighestQuality;
            exportSession.outputUrl = [NSURL fileURLWithPath:finalMediaPath];
            exportSession.outputFileType = AVFileTypeMPEG4;
            exportSession.keepVideoSize = NO;
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                completionHandler(exportSession.error);
            }];
            
            
            
        }
    }
    
    
}

- (void)videoOutput:(AVAsset*)videoAsset
{
    // 1 - Early exit if there's no video file selected
    if (!videoAsset) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Load a Video Asset First"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // 2 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // 3 - Video track
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                        ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0]
                         atTime:kCMTimeZero error:nil];
    
    
    // 3.1 - Create AVMutableVideoCompositionInstruction
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    // 3.2 - Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
    BOOL isVideoAssetPortrait_  = NO;
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ =  UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ =  UIImageOrientationUp;
    }
    if (videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    //[videolayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videolayerInstruction setOpacity:0.0 atTime:videoAsset.duration];
    
    
    // 3.3 - Add instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videolayerInstruction,nil];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    //videoTrack.preferredTransform = CGAffineTransformMake(videoTransform.a, videoTransform.b, videoTransform.c, videoTransform.d, 0, 0);
    
    CGAffineTransform applyTransform = videoTransform;
    
    if (videoTransform.tx != 0) {
        if (videoTransform.tx != videoAssetTrack.naturalSize.width) {
            applyTransform.tx = videoAssetTrack.naturalSize.width;
        }
    }
    if (videoTransform.ty != 0) {
        if (videoTransform.ty != videoAssetTrack.naturalSize.height) {
            applyTransform.ty = videoAssetTrack.naturalSize.height;
        }
    }
    
    [videolayerInstruction setTransform:applyTransform atTime:kCMTimeZero];
    
    CGSize naturalSize;
    if(isVideoAssetPortrait_){
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    } else {
        naturalSize = videoAssetTrack.naturalSize;
        
    }
    
    float renderWidth, renderHeight, renderScale;
    
    
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    //mainCompositionInst.renderScale = renderScale;
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize];
    
    //Audio Track
    AVMutableCompositionTrack *audioTrack = nil;
    
    
    
    
    if([[videoAsset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        audioTrack = [videoAsset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    if (audioTrack) {
        AVMutableCompositionTrack *audioCompositionTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioCompositionTrack insertTimeRange:audioTrack.timeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    }
    
    // 4 - Get path
    //    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs =  [NSTemporaryDirectory() stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"FinalVideo.mp4"]];
    [[NSFileManager defaultManager] removeItemAtPath:myPathDocs error:nil];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    // 5 - Create exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetMediumQuality];
    exporter.outputURL=url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:exporter];
        });
    }];
}

- (void)exportDidFinish:(AVAssetExportSession*)session {
    
    if (session.status == AVAssetExportSessionStatusCompleted) {
        
        [[ProgressIndicator sharedInstance] hideProgressIndicator];
        NSURL *outputURL = session.outputURL;
        
        [self goToMediaShareViewWithMediaPath:outputURL.resourceSpecifier];
    }
    
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    // 1 - set up the overlay
    CALayer *overlayLayer = [CALayer layer];
    
    float widthScale = size.width / _filterSwitcherView.frame.size.width;
    float heightScale = size.height / _filterSwitcherView.frame.size.height;
    
    //[self changeScaleforView:_overlayView scale:2];
    UIImage *overlayImage = [self imageWithView:_selectedSizeView];
    
    [overlayLayer setContents:(id)[overlayImage CGImage]];
    
    CGSize fgSize = CGSizeMake(overlayImage.size.width * widthScale, overlayImage.size.height * heightScale);
    
    CGPoint center = CGPointMake(size.width / 2, size.height / 2);
    
    overlayLayer.frame = CGRectMake(center.x - fgSize.width / 2, center.y - fgSize.height / 2, fgSize.width, fgSize.height);
    
    CGRect a = [_selectedSizeView convertRect:_selectedSizeView.bounds toView:_previewImageView];
    if (! IS_IPHONE_5) {
        float factor = 320.0 / 230.0;
        a = CGRectMake(a.origin.x * factor, a.origin.y * factor, a.size.width * factor, a.size.height * factor);
    }
    
    overlayLayer.frame = CGRectMake( a.origin.x * widthScale, (320 - a.size.height - a.origin.y) * heightScale, a.size.width * widthScale, a.size.height * heightScale);
    
    //[overlayLayer setMasksToBounds:YES];
    
    // 2 - set up the parent layer
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];
    
    // 3 - apply magic
    composition.animationTool = [AVVideoCompositionCoreAnimationTool
                                 videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
}


- (UIImage *) imageWithView:(UIView *)view
{
    //[self changeScaleforView:view scale:2];
    
    CGSize size = view.bounds.size;
    if (! IS_IPHONE_5) {
        float factor = 320.0 / 230.0;
        size = CGSizeMake(size.width * factor, size.height * factor);
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)changeScaleforView:(UIView *)aView scale:(CGFloat)scale
{
    [aView.subviews enumerateObjectsUsingBlock:^void(UIView *v, NSUInteger idx, BOOL *stop)
     {
         if([v isKindOfClass:[UITextField class]]) {
             v.layer.contentsScale = scale;
         } else
             if([v isKindOfClass:[UIImageView class]]) {
                 // labels and images
                 // v.layer.contentsScale = scale; won't work
                 
                 // if the image is not "@2x", you could subclass UIImageView and set the name of the @2x
                 // on it as a property, then here you would set this imageNamed as the image, then undo it later
             } else
                 if([v isMemberOfClass:[UIView class]]) {
                     // container view
                     [self changeScaleforView:v scale:scale];
                 }
     } ];
}

- (UIImage*) drawImage:(UIImage*) fgImage
               inImage:(UIImage*) bgImage
               atPoint:(CGPoint)  point
{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(bgImage.size.width/2, bgImage.size.height/2), FALSE, 2);
    [bgImage drawInRect:CGRectMake( 0, 0, bgImage.size.width/2, bgImage.size.height/2)];
    
    float factor = 1;
    if (! IS_IPHONE_5) {
        factor = 320.0 / 230.0;
    }
    
    [fgImage drawInRect:CGRectMake( point.x, point.y, fgImage.size.width * factor, fgImage.size.height * factor)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)changeBrightness:(UISlider*)sender
{
    [_cPicker setBrightness:sender.value];
    [_cPicker updateImage];
    [self colorWheelDidChangeColor:_cPicker];
}



#pragma mark - UITextFieldDelegate

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    NSUInteger newLength = [textField.text length] + [string length] - range.length;
//    return (newLength > 12) ? NO : YES;
//}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)colorWheelDidChangeColor:(ISColorWheel *)colorWheel
{
    if (!colorWheel) {
        _selectedSizeImageView.image = [self imageNamed:_selectedSizeLogoName withColor:[UIColor whiteColor]];
        _selectedSizeTextField.textColor = [UIColor whiteColor];
        
    }
    else {
        _selectedSizeImageView.image = [self imageNamed:_selectedSizeLogoName withColor:colorWheel.currentColor];
        _selectedSizeTextField.textColor = colorWheel.currentColor;
        
    }
}



#pragma mark - Util

-(UIImage *)imageNamed:(NSString*)name withColor:(UIColor *)color {
    // load the image
    
    UIImage *img = [UIImage imageNamed:name];
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

#pragma mark
#pragma mark TableView DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(self.isFiltered)
        return  _filteredTableData.count;
    else
        return  _brandNames.count;
    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    
    if(_isFiltered)
        cell.textLabel.text = [_filteredTableData objectAtIndex:indexPath.row];
    else
        cell.textLabel.text = [_brandNames objectAtIndex:indexPath.row];
    
    
    
    return cell;
    
}

#pragma mark
#pragma mark TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(_isFiltered){
        _searchBar.text = _filteredTableData[indexPath.row];
    }
    else {
        _searchBar.text = _brandNames[indexPath.row];
    }
    
    
    
    
}

#pragma mark
#pragma mark TextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 100) {
        
        NSArray *colors = [NSArray arrayWithObjects:@"$",@"€",@"£",@"RB",@"₼", nil];
        
        UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
        [done setTitle:@"Done" forState:UIControlStateNormal];
        [done setFrame:CGRectMake(0, 0, 50, 40)];
        [done setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancel setFrame:CGRectMake(0, 0, 60, 40)];
        [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:done];
        UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
        
        ActionSheetStringPicker *picker =       [[ActionSheetStringPicker alloc] initWithTitle:@"Select a Currency" rows:colors initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            _textFeildCurrency.text = colors[selectedIndex];
            
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            
        } origin:textField];
        [picker setDoneButton:doneItem];
        [picker setCancelButton:cancelItem];
        [picker showActionSheetPicker];
        
        //        [ActionSheetStringPicker showPickerWithTitle:@"Select a Currency"
        //                                                rows:colors
        //                                    initialSelection:0
        //                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        //                                               NSLog(@"Picker: %@, Index: %ld, value: %@",
        //                                                     picker, (long)selectedIndex, selectedValue);
        //                                               _textFeildCurrency.text = colors[selectedIndex];
        //                                           }
        //                                         cancelBlock:^(ActionSheetStringPicker *picker) {
        //                                             NSLog(@"Block Picker Canceled");
        //                                         }
        //                                              origin:textField];
        
        return NO;
        
        
    }
    else
        return YES;
}
-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        _isFiltered = FALSE;
    }
    else
    {
        _isFiltered = true;
        _filteredTableData = [[NSMutableArray alloc] init];
        
        for (NSString *string in _brandNames)
        {
            NSRange nameRange = [string rangeOfString:text options:NSCaseInsensitiveSearch];
            
            if(nameRange.location != NSNotFound)
            {
                [_filteredTableData addObject:string];
            }
        }
    }
    
    [_tableview reloadData];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    [searchBar setShowsCancelButton:YES animated:YES];
    [searchBar resignFirstResponder];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

@end
