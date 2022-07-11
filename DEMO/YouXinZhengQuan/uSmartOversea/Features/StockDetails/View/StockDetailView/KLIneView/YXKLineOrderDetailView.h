//
//  YXKLineOrderDetailView.h
//  uSmartOversea
//
//  Created by youxin on 2020/7/21.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YXKLine;
@class YXTimeLine;
@interface YXKLineOrderDetailView : UIView

- (instancetype)initWithFrame:(CGRect)frame andType:(int)type;

@property (nonatomic, strong) NSString *market;

@property (nonatomic, strong) YXKLine *kLineSingleModel;
@property (nonatomic, strong) YXTimeLine *timelineSingleModel;

@property (nonatomic, copy) void (^clickToDetailBlock)(NSString *date, int32_t orderType);
@end

NS_ASSUME_NONNULL_END
