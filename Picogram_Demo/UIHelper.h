//
//  UIHelper.h
//  MENUSE
//
//  Created by Rathore on 07/02/15.
//  Copyright (c) 2015 3Embed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIHelper : NSObject

+ (void) showMessage:(NSString*)message withTitle:(NSString*)title;
+ (CGFloat)measureHeightLabel: (UILabel *)label;
+(void)setToLabel:(UILabel*)lbl Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size Color:(UIColor*)color;
+(void)setButton:(UIButton*)btn Text:(NSString*)txt WithFont:(NSString*)font FSize:(float)_size TitleColor:(UIColor*)t_color ShadowColor:(UIColor*)s_color;
@end
