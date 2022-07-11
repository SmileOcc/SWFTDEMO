//
//  NSSimpleTimeLine.h
//  LIne
//
//  Created by Kelvin on 2019/4/4.
//  Copyright © 2019年 Kelvin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXTimeLineModel;
@class YXV2Quote;
NS_ASSUME_NONNULL_BEGIN

@interface YXSimpleTimeLine : UIView

//model
@property (nonatomic, strong) YXTimeLineModel *timeModel;
//@property (nonatomic, copy) NSString *market;

//market
@property (nonatomic, copy) NSString *market;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, strong) YXV2Quote *quote;
@property (nonatomic, assign) NSInteger dashPointCount;
@property (nonatomic, assign) BOOL enableLongPress;

//init
- (instancetype)initWithFrame:(CGRect)frame market:(NSString *)market minute:(NSInteger)minute;
- (instancetype)initWithFrame:(CGRect)frame market:(NSString *)market;

@end

NS_ASSUME_NONNULL_END
