//
//  ZFAccountTableDataView.h
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFAccountVCProtocol.h"
#import "ZFAccountHeaderCellTypeModel.h"

@interface ZFAccountTableView : UITableView <UIGestureRecognizerDelegate>
@end

NS_ASSUME_NONNULL_BEGIN

@interface ZFAccountTableDataView : UIView

@property (nonatomic, strong) ZFAccountTableView                    *tableView;

- (instancetype)initWithVCProtocol:(id<ZFAccountVCProtocol>)actionProtocol;

/** 表格Cell数据源类型 */
@property (nonatomic, strong) NSArray<ZFAccountHeaderCellTypeModel *> *sectionTypeModelArr;

///点击Tabbar滚动到顶部
- (void)setTableViewScrollToTop;

///刷新用户登录状态
- (void)reloadUserLoginStatus;

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
