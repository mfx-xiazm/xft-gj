//
//  RCSearchClientVC.h
//  XFT
//
//  Created by 夏增明 on 2019/9/2.
//  Copyright © 2019 夏增明. All rights reserved.
//

#import "HXBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCSearchClientVC : HXBaseViewController
/* 数据类型 1客户 2经纪人 3门店*/
@property(nonatomic,assign) NSInteger dataType;
/* 搜索客户时传递的项目的uuid */
@property(nonatomic,copy) NSString *proUuid;
@end

NS_ASSUME_NONNULL_END
