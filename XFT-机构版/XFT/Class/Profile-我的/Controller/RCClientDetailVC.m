//
//  RCClientDetailVC.m
//  XFT
//
//  Created by 夏增明 on 2019/9/2.
//  Copyright © 2019 夏增明. All rights reserved.
//

#import "RCClientDetailVC.h"
#import "RCClientDetailHeader.h"
#import "RCClientDetailInfoVC.h"
#import "RCGoHouseVC.h"
#import "RCPageMainTable.h"
#import <JXCategoryView.h>
#import "RCClientDetailNoteVC.h"
#import "RCMyClient.h"
#import "zhAlertView.h"
#import <zhPopupController.h>

@interface RCClientDetailVC ()<UITableViewDelegate,UITableViewDataSource,JXCategoryViewDelegate>
@property (weak, nonatomic) IBOutlet RCPageMainTable *tableView;
/* 头视图 */
@property(nonatomic,strong) RCClientDetailHeader *header;
/** 子控制器承载scr */
@property (nonatomic,strong) UIScrollView *scrollView;
/** 子控制器数组 */
@property (nonatomic,strong) NSArray *childVCs;
/** 是否可以滑动 */
@property(nonatomic,assign)BOOL isCanScroll;
/** 切换控制器 */
@property (strong, nonatomic) JXCategoryTitleView *categoryView;
/** 客户基本信息 */
@property(nonatomic,strong) RCMyClient *clientInfo;
@end

@implementation RCClientDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"客户详情"];
    
    self.isCanScroll = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MainTableScroll:) name:@"MainTableScroll" object:nil];
    [self setUpMainTable];
    [self getClientDetail];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.header.frame = CGRectMake(0, -(205.f), HX_SCREEN_WIDTH, 205.f);
}
-(RCClientDetailHeader *)header
{
    if (_header == nil) {
        _header = [RCClientDetailHeader loadXibView];
        _header.frame = CGRectMake(0,0, HX_SCREEN_WIDTH, 205.f);
        hx_weakify(self);
        _header.clientDetailCall = ^(NSInteger index) {
            hx_strongify(weakSelf);
            if (index == 1) {
                zhAlertView *alert = [[zhAlertView alloc] initWithTitle:@"提示" message:strongSelf.clientInfo.phone constantWidth:HX_SCREEN_WIDTH - 50*2];
                zhAlertButton *cancelButton = [zhAlertButton buttonWithTitle:@"取消" handler:^(zhAlertButton * _Nonnull button) {
                    [strongSelf.zh_popupController dismiss];
                }];
                zhAlertButton *okButton = [zhAlertButton buttonWithTitle:@"拨打" handler:^(zhAlertButton * _Nonnull button) {
                    [strongSelf.zh_popupController dismiss];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",strongSelf.clientInfo.phone]]];
                }];
                cancelButton.lineColor = UIColorFromRGB(0xDDDDDD);
                [cancelButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
                okButton.lineColor = UIColorFromRGB(0xDDDDDD);
                [okButton setTitleColor:HXControlBg forState:UIControlStateNormal];
                [alert adjoinWithLeftAction:cancelButton rightAction:okButton];
                strongSelf.zh_popupController = [[zhPopupController alloc] init];
                [strongSelf.zh_popupController presentContentView:alert duration:0.25 springAnimated:NO];
            }else if (index == 2) {
                NSString *phoneStr = [NSString stringWithFormat:@"%@",strongSelf.clientInfo.phone];//发短信的号码
                NSString *urlStr = [NSString stringWithFormat:@"sms://%@", phoneStr];
                NSURL *url = [NSURL URLWithString:urlStr];
                [[UIApplication sharedApplication] openURL:url];
            }else{
                RCGoHouseVC *hvc = [RCGoHouseVC new];
                hvc.cusUuid = strongSelf.clientInfo.cusUuid;
                [strongSelf.navigationController pushViewController:hvc animated:YES];
            }
        };
    }
    return _header;
}
-(JXCategoryTitleView *)categoryView
{
    if (_categoryView == nil) {
        _categoryView = [[JXCategoryTitleView alloc] init];
        _categoryView.frame = CGRectMake(0, 0, HX_SCREEN_WIDTH, 44);
        _categoryView.backgroundColor = [UIColor whiteColor];
        _categoryView.titles = @[@"基本信息", @"客户轨迹"];
        _categoryView.titleFont = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        _categoryView.titleColor = UIColorFromRGB(0x666666);
        _categoryView.titleSelectedColor = HXControlBg;
        _categoryView.delegate = self;
        _categoryView.contentScrollView = self.scrollView;
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.verticalMargin = 5.f;
        lineView.indicatorColor = HXControlBg;
        _categoryView.indicators = @[lineView];
    }
    return _categoryView;
}
-(NSArray *)childVCs
{
    if (_childVCs == nil) {
        NSMutableArray *vcs = [NSMutableArray array];
        
        RCClientDetailInfoVC *cvc = [RCClientDetailInfoVC new];
        [self addChildViewController:cvc];
        [vcs addObject:cvc];
        
        RCClientDetailNoteVC *cvc0 = [RCClientDetailNoteVC new];
        [self addChildViewController:cvc0];
        [vcs addObject:cvc0];
        _childVCs = vcs;
    }
    return _childVCs;
}
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 44, HX_SCREEN_WIDTH, HX_SCREEN_HEIGHT-self.HXNavBarHeight-self.HXButtomHeight - 44);
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(HX_SCREEN_WIDTH*self.childVCs.count, 0);
        // 加第一个视图
        UIViewController *targetViewController = self.childVCs.firstObject;
        targetViewController.view.frame = CGRectMake(0, 0, HX_SCREEN_WIDTH, _scrollView.hxn_height);
        [_scrollView addSubview:targetViewController.view];
    }
    return  _scrollView;
}
-(void)setUpMainTable
{
    // 针对 11.0 以上的iOS系统进行处理
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    } else {
        // 针对 11.0 以下的iOS系统进行处理
        // 不要自动调整inset
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableView.estimatedRowHeight = 100;//预估高度
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    
    self.tableView.contentInset = UIEdgeInsetsMake(205.f,0, 0, 0);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 设置背景色为clear
    self.tableView.backgroundColor = HXGlobalBg;
    
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView addSubview:self.header];
    
    self.tableView.hidden = YES;
}
#pragma mark -- 请求客户详情
-(void)getClientDetail
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    // 执行循序1
    hx_weakify(self);
    dispatch_group_async(group, queue, ^{
        hx_strongify(weakSelf);
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"cusUuid"] = self.cusUuid;
        parameters[@"data"] = data;
        
        [HXNetworkTool POST:HXRC_M_URL action:@"cus/cus/mechanism/getCustInfo" parameters:parameters success:^(id responseObject) {
            if ([responseObject[@"code"] integerValue] == 0) {
                strongSelf.clientInfo = [RCMyClient yy_modelWithDictionary:responseObject[@"data"]];
            }else{
                [MBProgressHUD showTitleToView:nil postion:NHHUDPostionCenten title:responseObject[@"msg"]];
            }
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSError *error) {
            [MBProgressHUD showTitleToView:nil postion:NHHUDPostionCenten title:error.localizedDescription];
            dispatch_semaphore_signal(semaphore);
        }];
    });
//    // 执行循序2
//    dispatch_group_async(group, queue, ^{
//        // 请求客户轨迹的接口
//        hx_strongify(weakSelf);
//        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//        NSMutableDictionary *data = [NSMutableDictionary dictionary];
//        data[@"cusUuid"] = self.cusUuid;
//        parameters[@"data"] = data;
//
//        [HXNetworkTool POST:@"http://192.168.199.249:9000/open/api/" action:@"cus/cus/mechanism/getCustInfo" parameters:parameters success:^(id responseObject) {
//            if ([responseObject[@"code"] integerValue] == 0) {
//                strongSelf.clientInfo = [RCMyClient yy_modelWithDictionary:responseObject[@"data"]];
//            }else{
//                [MBProgressHUD showTitleToView:nil postion:NHHUDPostionCenten title:responseObject[@"msg"]];
//            }
//            dispatch_semaphore_signal(semaphore);
//        } failure:^(NSError *error) {
//            [MBProgressHUD showTitleToView:nil postion:NHHUDPostionCenten title:error.localizedDescription];
//            dispatch_semaphore_signal(semaphore);
//        }];
//    });
    dispatch_group_notify(group, queue, ^{
        // 执行循序4
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        // 执行顺序6
//        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        // 执行顺序10
        hx_strongify(weakSelf);
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.tableView.hidden = NO;
            strongSelf.header.clientInfo = strongSelf.clientInfo;
            RCClientDetailInfoVC *ivc = (RCClientDetailInfoVC *)strongSelf.childVCs.firstObject;
            ivc.clientInfo = strongSelf.clientInfo;
            [strongSelf.tableView reloadData];
        });
    });
}
#pragma mark -- 主视图滑动通知处理
-(void)MainTableScroll:(NSNotification *)user{
    self.isCanScroll = YES;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.tableView) {
        CGFloat tabOffsetY = [self.tableView rectForSection:0].origin.y;
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY>=tabOffsetY) {
            self.isCanScroll = NO;
            scrollView.contentOffset = CGPointMake(0, 0);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"childScrollCan" object:nil];
        }else{
            if (!self.isCanScroll) {
                [scrollView setContentOffset:CGPointZero];
            }
        }
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - JXCategoryViewDelegate
// 滚动和点击选中
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index
{
    if (self.childVCs.count <= index) {return;}
    
    UIViewController *targetViewController = self.childVCs[index];
    // 如果已经加载过，就不再加载
    if ([targetViewController isViewLoaded]) return;
    
    targetViewController.view.frame = CGRectMake(HX_SCREEN_WIDTH * index, 0, HX_SCREEN_WIDTH, self.scrollView.hxn_height);
    
    [self.scrollView addSubview:targetViewController.view];
}
#pragma mark -- UITableView数据源和代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return tableView.hxn_height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 添加pageView
    [cell.contentView addSubview:self.scrollView];
    [cell.contentView addSubview:self.categoryView];
    
    return cell;
}

@end
