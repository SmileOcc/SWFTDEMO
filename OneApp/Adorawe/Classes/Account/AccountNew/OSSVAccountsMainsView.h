//
//  OSSVAccountsMainsView.h
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVAccountsVCProtocol.h"
#import "OSSVAccountHeadCellTypeModel.h"

@interface STLAccountTableView : UITableView <UIGestureRecognizerDelegate>
@end

NS_ASSUME_NONNULL_BEGIN

@interface OSSVAccountsMainsView : UIView

@property (nonatomic, strong) STLAccountTableView                    *tableView;
@property (nonatomic, strong) OSSVAccountsHeadView                   *tableHeaderView;
@property (nonatomic, assign) BOOL                                   canScroll;

- (instancetype)initWithVCProtocol:(id<OSSVAccountsVCProtocol>)actionProtocol;

/** 表格Cell数据源类型 */
@property (nonatomic, strong) NSArray<OSSVAccountHeadCellTypeModel *> *sectionTypeModelArr;


@property (nonatomic, copy) void (^accountHeaderEventBlock)(AccountEventOperate event);
@property (nonatomic, copy) void (^accountHeaderBindPhoeBlock)(AccountBindPhoneOperate event);
@property (nonatomic, copy) void (^accountHeaderServicesBlock)(AccountServicesOperate service, NSString *title);
@property (nonatomic, copy) void (^accountHeaderTypeBlock)(AccountTypeOperate type, NSString *title);
@property (nonatomic, copy) void (^accountHeadeOrderBlock)(AccountOrderOperate type, NSString *title);
//@property (nonatomic, copy) void (^accountHeadeCoinCenterBlock)(NSString *urlString);

///点击Tabbar滚动到顶部
- (void)setTableViewScrollToTop;


/// 个人中心头部换肤
- (void)refreshHeadViewSkin;

/// 刷新个人中心头部头像
- (void)refreshHeadUserImage:(UIImage *)userImage;

/// 刷新浏览历史记录
- (void)refreshHistoryData;

/// 切换刷新表格
- (void)reloadAccountTableView;

/// 刷新订单信息
- (void)refreCategoryItemCell;

/// 结束刷新表格
- (void)endRefreshingData;

@end

NS_ASSUME_NONNULL_END
