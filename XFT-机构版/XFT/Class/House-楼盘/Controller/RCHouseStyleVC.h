//
//  RCHouseStyleVC.h
//  XFT
//
//  Created by 夏增明 on 2019/8/30.
//  Copyright © 2019 夏增明. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class RCHouseDetail;
@interface RCHouseStyleVC : HXBaseViewController
/* 楼盘uuid */
@property(nonatomic,copy) NSString *uuid;
/** 楼盘全部详情数据 */
@property(nonatomic,strong) RCHouseDetail *houseDetail;
@end

NS_ASSUME_NONNULL_END
