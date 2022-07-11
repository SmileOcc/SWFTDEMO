//
//  YXKlineTabView.h
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/10/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXStockDetailUtility.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXKlineTabView : UIView
///是否有分时的子选项
@property (nonatomic, assign) BOOL hasTsExpand;
///是否有分K的子选项
@property (nonatomic, assign) BOOL hasMinKExpand;
///大类型
@property (nonatomic, assign) YXRtLineType rtLineType;
///子分时选中
@property (nonatomic, assign) YXTimeShareLineType subTsType;
///子分K选中
@property (nonatomic, assign) YXKLineSubType subKlineType;
///是否是期权的
@property (nonatomic, assign) BOOL isOption;


@property (nonatomic, copy) void (^updateTypeCallBack)(YXKlineTabView *tabView);


@end

NS_ASSUME_NONNULL_END
