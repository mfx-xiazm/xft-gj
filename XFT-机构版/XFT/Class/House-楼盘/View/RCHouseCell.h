//
//  RCHouseCell.h
//  XFT
//
//  Created by 夏增明 on 2019/9/2.
//  Copyright © 2019 夏增明. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class RCHouseList;
@interface RCHouseCell : UITableViewCell
/* 房源 */
@property(nonatomic,strong) RCHouseList *house;
@end

NS_ASSUME_NONNULL_END
