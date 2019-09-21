//
//  RCBannerCell.m
//  XFT
//
//  Created by 夏增明 on 2019/8/27.
//  Copyright © 2019 夏增明. All rights reserved.
//

#import "RCBannerCell.h"
#import "RCHouseBanner.h"

@implementation RCBannerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setBanner:(RCHouseBanner *)banner
{
    _banner = banner;
    [self.contentImg sd_setImageWithURL:[NSURL URLWithString:_banner.headPic]];
}
@end
