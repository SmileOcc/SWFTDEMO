//
//  ZFRecentlyTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2019/6/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  个人中心历史记录cell

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFCMSItemModel;
typedef void(^RecentlyClearButtonHandler)(void);
typedef void(^RecentlyDidClickProductHandler)(ZFCMSItemModel *itemModel);
@interface ZFRecentlyTableViewCell : UITableViewCell

@property (nonatomic, strong) NSArray<ZFCMSItemModel *> *dataList;

@property (nonatomic, copy) RecentlyClearButtonHandler clearButtonHandler;

@property (nonatomic, copy) RecentlyDidClickProductHandler didClickProductHandler;

@end

NS_ASSUME_NONNULL_END
