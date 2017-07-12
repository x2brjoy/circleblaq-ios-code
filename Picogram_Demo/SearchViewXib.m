//
//  SearchViewXib.m
//  
//
//  Created by Rahul Sharma on 4/12/16.
//
//

#import "SearchViewXib.h"

@implementation SearchViewXib

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@synthesize delegate;

- (instancetype)init{
    
    self = [super init];
    self = [[[NSBundle mainBundle] loadNibNamed:@"SearchViewXib"
                                          owner:self
                                        options:nil] firstObject];
    return self;
}

- (void)showHeader:(UIWindow *)window {
    
    
    CGRect frameOfSelf = self.frame;
    frameOfSelf.size.width = CGRectGetWidth(window.frame);
    self.frame = window.frame;
    //
    //
    //
    //    self.frame = window.frame;
    //    [window addSubview:self];
    [self layoutIfNeeded];
}


@end
