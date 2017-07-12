//
//  SearchViewXib.h
//  
//
//  Created by Rahul Sharma on 4/12/16.
//
//

#import <UIKit/UIKit.h>

@protocol profileViewDelegate <NSObject>


@end

@interface SearchViewXib : UIView

@property (nonatomic, weak) id <profileViewDelegate> delegate;

- (void)showHeader:(UIWindow *)window;

@end
