//
//  OSSVGoodssPricesView.h
// XStarlinkProject
//
//  Created by odd on 2020/12/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STLCLineLabel.h"
#import "OSSVDetailsActivityFullReductionView.h"
NS_ASSUME_NONNULL_BEGIN

@interface OSSVGoodssPricesView : UIView

@property (nonatomic, strong) UILabel                               *titleLabel;
@property (nonatomic, strong) UILabel                               *priceLabel; // 现价
@property (nonatomic, strong) STLCLineLabel                         *originalPriceLabel; // 原价
@property (nonatomic, strong) OSSVDetailsActivityFullReductionView     *activityFullReductionView;
@property (nonatomic, copy) NSString                                *activityMsg;

- (instancetype)initWithFrame:(CGRect)frame isShowIcon:(BOOL)isShow;

- (void)price:(NSString *)price originalPrice:(NSString *)originPrice activityMsg:(NSString *)activityMsg activityHeight:(CGFloat)activityHeight title:(NSString *)title;

+ (CGFloat)activithHeight:(NSString *)msg contentWidth:(CGFloat)width;
+ (CGFloat)contentHeight:(CGFloat)activityHeight;
@end

NS_ASSUME_NONNULL_END
