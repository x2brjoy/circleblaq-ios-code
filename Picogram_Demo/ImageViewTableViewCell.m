//
//  ImageViewTableViewCell.m
//  InstaVideoPlayerExample
//
//  Created by Rahul Sharma on 24/07/16.
//  Copyright © 2016 Rahul Sharma. All rights reserved.
//

#import "ImageViewTableViewCell.h"
#import <UIImageView+AFNetworking.h>

@implementation ImageViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)loadImageForCell
{
    __weak UIImageView *imaage = self.imageView;
    
    NSURL *imageURL = [NSURL URLWithString:_url];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height)];
    [self.imageView addSubview:indicator];
    indicator.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
    [indicator startAnimating];
    
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:imageURL];
    [self.imageView setImageWithURLRequest:imageRequest
                          placeholderImage:[UIImage imageNamed:@""]
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         imaage.image = image;
         [indicator stopAnimating];
     }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
     {
         [indicator stopAnimating];
     }];

}

@end
