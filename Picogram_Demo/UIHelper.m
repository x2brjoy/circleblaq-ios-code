//
//  UIHelper.m
//  MENUSE
//
//  Created by Rathore on 07/02/15.
//  Copyright (c) 2015 3Embed. All rights reserved.
//

#import "UIHelper.h"

@implementation UIHelper
+ (void) showMessage:(NSString*)message withTitle:(NSString*)title {
    
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}
/**
 *  To get Label height Dynamically
 *
 *  @param label label whose height wiil be measure(1st set the text in label before call this method)
 *
 *  @return Label height in float
 */
+ (CGFloat)measureHeightLabel: (UILabel *)label
{
    CGSize constrainedSize = CGSizeMake(label.frame.size.width  , 9999);
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:label.font.fontName size:label.font.pointSize], NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:label.text attributes:attributesDictionary];
    
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    if (requiredHeight.size.width > label.frame.size.width) {
        requiredHeight = CGRectMake(0,0, label.frame.size.width, requiredHeight.size.height);
    }
    CGRect newFrame = label.frame;
    newFrame.size.height = requiredHeight.size.height;
    return  newFrame.size.height;
}
+(void)setToLabel:(UILabel*)lbl Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size Color:(UIColor*)color
{
    lbl.backgroundColor = [UIColor clearColor];
    lbl.textColor = color;
    
    if (txt != nil) {
        lbl.text = txt;
    }
    
    
    if (font != nil) {
        lbl.font = [UIFont fontWithName:font size:_size];
    }
    
}

+(void)setButton:(UIButton*)btn Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size TitleColor:(UIColor*)t_color ShadowColor:(UIColor*)s_color
{
    [btn setTitle:txt forState:UIControlStateNormal];
    
    [btn setTitleColor:t_color forState:UIControlStateNormal];
    
    if (s_color != nil) {
        [btn setTitleShadowColor:s_color forState:UIControlStateNormal];
    }
    
    
    if (font != nil) {
        btn.titleLabel.font = [UIFont fontWithName:font size:_size];
    }
    else
    {
        btn.titleLabel.font = [UIFont systemFontOfSize:_size];
    }
}
@end
