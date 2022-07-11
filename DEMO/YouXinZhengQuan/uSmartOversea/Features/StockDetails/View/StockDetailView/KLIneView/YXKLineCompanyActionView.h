//
//  YXKLineCompanyActionView.h
//  YouXinZhengQuan
//
//  Created by youxin on 2021/3/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YXKLine;
@class YXKLineInsideEvent;
@interface YXKLineCompanyActionView : UIView

- (instancetype)initWithFrame:(CGRect)frame andType:(int)type;

@property (nonatomic, strong) NSString *market;

@property (nonatomic, strong) NSArray<YXKLineInsideEvent *> *events;

@property (nonatomic, strong) NSString *dateString;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, copy) void (^clickToDetailBlock)(NSArray<YXKLineInsideEvent *> *events, NSString *dateString);

@end

NS_ASSUME_NONNULL_END
