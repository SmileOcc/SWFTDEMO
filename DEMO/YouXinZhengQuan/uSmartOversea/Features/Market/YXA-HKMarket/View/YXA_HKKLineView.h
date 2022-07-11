//
//  YXA_HKKLineView.h
//  uSmartOversea
//
//  Created by youxin on 2020/3/24.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    YXA_HKKLineDirectionSouth,
    YXA_HKKLineDirectionNorth
} YXA_HKKLineDirection;

@interface YXA_HKKLineView : UIView

@property (nonatomic, strong) NSArray *dataSource;

#pragma mark - 配置属性
/**
 显示的数量
 */
@property (nonatomic, assign, readwrite) NSUInteger visibleCount;

/**
 显示的最小数量
 */
@property (nonatomic, assign, readwrite) NSUInteger visibleMinCount;

/**
 显示的最大数量
 */
@property (nonatomic, assign, readwrite) NSUInteger visibleMaxCount;

/**
 间隔
 */
@property (nonatomic, assign, readwrite) double space;


- (void)resetData;

/**
 加载更多
 */
@property (nonatomic, copy) void (^loadMoreCallBack)(void);


- (instancetype)initWithFrame:(CGRect)frame andType:(YXA_HKKLineDirection)type;

@end

NS_ASSUME_NONNULL_END
