//
//  YXStockFilterGroupCell.h
//  uSmartOversea
//
//  Created by youxin on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXTableViewCell.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YXStockFilterGroupOperateType) {
    YXStockFilterGroupOperateTypeModify = 0,
    YXStockFilterGroupOperateTypeRename,
    YXStockFilterGroupOperateTypeDelete,
};

@class YXStockFilterUserFilterList;
@interface YXStockFilterGroupCell : YXTableViewCell

@property (nonatomic, strong) YXStockFilterUserFilterList *model;
@property (nonatomic, copy) void (^operateBlock) (YXStockFilterGroupOperateType type);
@end

NS_ASSUME_NONNULL_END
