//
//  ZFUnpaidOrderAlertView.m
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFUnpaidOrderAlertView.h"
#import <YYWebImage/YYWebImage.h>
#import "MyOrdersModel.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFLocalizationString.h"
#import "ZFMyOrderListGoodsImageView.h"
#import "UIView+ZFViewCategorySet.h"
#import "MyOrderGoodListModel.h"
#import "NSString+Extended.h"
#import "ZFAppsflyerAnalytics.h"
#import "AccountManager.h"
#import "YWCFunctionTool.h"
#import "NSDate+ZFExtension.h"
#import "NSStringUtils.h"
#import "SystemConfigUtils.h"

@interface ZFUnpaidOrderAlertView ()
@property (nonatomic, strong) MyOrdersModel         *orderModel;
@property (nonatomic, copy) UnpaidOrderAlertBlock   unpaidOrderAlertBlock;
@property (nonatomic, strong) UIView                *contentView;
@property (nonatomic, strong) UIImageView           *userImageView;
@property (nonatomic, strong) YYAnimatedImageView   *bannerImageView;
@property (nonatomic, strong) UILabel               *descLabel;
@property (nonatomic, strong) UIView                *goodsImageView;
@property (nonatomic, strong) UILabel               *totalLabel;
@property (nonatomic, strong) UIView                *lineView1;
@property (nonatomic, strong) UIButton              *cancelButton;
@property (nonatomic, strong) UIView                *lineView2;
@property (nonatomic, strong) UIButton              *payButton;
@end

@implementation ZFUnpaidOrderAlertView

+ (void)showUnpaidOrderAlertView:(MyOrdersModel *)orderModel
           unpaidOrderAlertBlock:(void(^)(ZFUnpaidOrderAlertViewActionType type))unpaidOrderAlertBlock
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    //防止走两次
    UIView *oldAdvertView = [window viewWithTag:kZFUnpaidOrderViewTag];
    if (oldAdvertView && [oldAdvertView isKindOfClass:[ZFUnpaidOrderAlertView class]]) {
        [oldAdvertView removeFromSuperview];
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    ZFUnpaidOrderAlertView *AlertView = [[ZFUnpaidOrderAlertView alloc] initWithFrame:screenRect];
    AlertView.tag = kZFUnpaidOrderViewTag;
    [AlertView zfInitView];
    [AlertView zfAutoLayoutView:orderModel.goods.count];
    AlertView.orderModel = orderModel;
    AlertView.unpaidOrderAlertBlock = unpaidOrderAlertBlock;
    [window addSubview:AlertView];
    
    // appflyer统计
    NSDictionary *appsflyerParams = @{
                                      @"af_content_type"    : @"Home_Alert_View",
                                      @"af_reciept_id"      : ZFToString(orderModel.order_sn),
                                      @"af_country_code"    : ZFToString([AccountManager sharedManager].accountCountryModel.region_code)
                                      };
    
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_unpaid_Alert_impression" withValues:appsflyerParams];
}

- (void)zfInitView {
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.bannerImageView];
    [self addSubview:self.userImageView];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.totalLabel];
    [self.contentView addSubview:self.lineView1];
    [self.contentView addSubview:self.cancelButton];
    [self.contentView addSubview:self.lineView2];
    [self.contentView addSubview:self.payButton];
}

- (void)zfAutoLayoutView:(NSInteger)goodsCount {
    CGFloat offsetY = 47;
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY).offset(offsetY/2);
        make.width.mas_equalTo(self.mas_width).multipliedBy(270/KScreenWidth);
    }];
    
    CGFloat userImageSize = 56;
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(-userImageSize/2);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(userImageSize, userImageSize));
    }];
    
    [self.bannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(userImageSize);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bannerImageView.mas_bottom).offset(5);
        make.leading.mas_equalTo(self.contentView).offset(24);
        make.trailing.mas_equalTo(self.contentView).offset(-24);
    }];
    
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(12);
        make.leading.trailing.mas_equalTo(self.contentView);
//        make.centerX.mas_equalTo(self.contentView.mas_centerX).multipliedBy(0.2);
        make.height.mas_equalTo(92).priorityHigh();
    }];
    
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsImageView.mas_bottom).offset(12);
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
    }];
    
    [self.lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalLabel.mas_bottom).offset(15);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineView1.mas_bottom).offset(0);
        make.leading.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView.mas_width).multipliedBy(0.5);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(44);
    }];
    
    [self.lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineView1.mas_bottom).offset(0);
        make.leading.mas_equalTo(self.cancelButton.mas_trailing);
        make.width.mas_equalTo(1);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [self.payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.lineView1.mas_bottom).offset(0);
        make.leading.mas_equalTo(self.lineView2.mas_trailing);
        make.width.mas_equalTo(self.contentView.mas_width).multipliedBy(0.5);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(44);
    }];
    
    CGFloat width = 270;//后面采用约束
    if (goodsCount >= 4) {//只显示最多3个
        goodsCount = 3;
    }
    for (int idx = 0; idx < goodsCount; idx++) {
        ZFMyOrderListGoodsImageView *imageView = [[ZFMyOrderListGoodsImageView alloc] initWithFrame:CGRectZero];
        imageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        imageView.hidden = YES;
        imageView.tag = 2018 + idx;
        
        CGFloat imageViewX = 0.0;
        if (goodsCount == 1) {
            imageViewX = (width-60)/2;
        } else if (goodsCount == 2) {
            if (idx == 0) {
                imageViewX = width/2-(60+5);
            } else {
                imageViewX = width/2+5;
            }
        }  else if (goodsCount == 3) {
            if (idx == 0) {
                imageViewX = width/2- 60/2 - 5 -60;
            } else if (idx == 1) {
                imageViewX = width/2- 60/2;
            } else {
                imageViewX = width/2- 60/2 + 5 + 60;
            }
        }
        if ([SystemConfigUtils isRightToLeftShow]) {
            imageViewX = width - imageViewX - 60;
        }
        imageView.frame = CGRectMake(imageViewX, 12, 60, 80);
        
        @weakify(self);
        [imageView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.unpaidOrderAlertBlock) {
                self.unpaidOrderAlertBlock(ZFCarHeaderAction_GoOrderDetail);
            }
            [self removeFromSuperview];
        }];
        [self.goodsImageView addSubview:imageView];
    }
}
- (void)setOrderModel:(MyOrdersModel *)orderModel {
    _orderModel = orderModel;
    
    [self.userImageView yy_setImageWithURL:[NSURL URLWithString:orderModel.avatar]
                               placeholder:[UIImage imageNamed:@"unpaid_order_user"]
                                   options:YYWebImageOptionAvoidSetImage
                                completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                    if (image && stage == YYWebImageStageFinished) {
                                        self.userImageView.image = image;
                                    }
                                }];
    
    NSInteger goodsCount = orderModel.goods.count;
    NSInteger goods_number = 0;
    for (int idx = 0; idx <goodsCount; idx++) {
        ZFMyOrderListGoodsImageView *imageView = [self.goodsImageView viewWithTag:2018 + idx];
        if ([imageView isKindOfClass:[ZFMyOrderListGoodsImageView class]]) {
            imageView.hidden = NO;
            MyOrderGoodListModel *goodListModel = orderModel.goods[idx];
            imageView.imageUrl = goodListModel.wp_image;
            goods_number += goodListModel.goods_number.integerValue;
        }
    }
    self.descLabel.text = orderModel.order_message;
    
    NSString *totalStr = [NSString stringWithFormat:@"%@ ", ZFLocalizedString(@"Bag_Total", nil)];
    NSString *goodsCountStr = [NSString stringWithFormat:@"%ld",goods_number];
    NSString *itemsStr = [ZFLocalizedString(@"list_item", nil) stringByReplacingOccurrencesOfString:@"%@" withString:@""];
    
    NSArray *textArray = @[totalStr, goodsCountStr, itemsStr];
    NSArray *fontArray = @[ZFFontSystemSize(14), ZFFontSystemSize(16), ZFFontSystemSize(14)];
    NSArray *colorArray = @[ZFCOLOR(153, 153, 153, 1), ZFCOLOR(45, 45, 45, 1),
                          ZFCOLOR(153, 153, 153, 1)];
    self.totalLabel.attributedText = [NSString getAttriStrByTextArray:textArray
                                                              fontArr:fontArray
                                                             colorArr:colorArray
                                                          lineSpacing:0
                                                            alignment:0];;
}

#pragma mark - UIButton Action

- (void)buttonAction:(UIButton *)buttom {
    if (self.unpaidOrderAlertBlock) {
        self.unpaidOrderAlertBlock(buttom.tag);
    }
    [self removeFromSuperview];
}

#pragma mark - Init View

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = ZFCOLOR_WHITE;
        _contentView.layer.cornerRadius = 8;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UIImageView *)userImageView {
    if (!_userImageView) {
        _userImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userImageView.backgroundColor = [UIColor clearColor];
        _userImageView.contentMode = UIViewContentModeScaleAspectFill;
        _userImageView.layer.borderWidth = 2;
        _userImageView.layer.borderColor = ZFCOLOR_WHITE.CGColor;
        _userImageView.layer.cornerRadius = 56/2;
        _userImageView.layer.masksToBounds = YES;
    }
    return _userImageView;
}

- (YYAnimatedImageView *)bannerImageView {
    if (!_bannerImageView) {
        _bannerImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _bannerImageView.backgroundColor = [UIColor clearColor];
        _bannerImageView.image = [UIImage imageNamed:@"unpaid_order_banner"];
        _bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _bannerImageView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.font = [UIFont systemFontOfSize:14];
        _descLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.numberOfLines = 2;
        //_descLabel.text = @"You have an unpaid order, please pay as soon as possible";
    }
    return _descLabel;
}

- (UIView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _goodsImageView;
}

- (UILabel *)totalLabel {
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totalLabel.textAlignment = NSTextAlignmentCenter;
        _totalLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _totalLabel.font = [UIFont systemFontOfSize:14];
        _totalLabel.textAlignment = NSTextAlignmentCenter;
        //_totalLabel.text = @"Total: x products";
    }
    return _totalLabel;
}

- (UIView *)lineView1 {
    if (!_lineView1) {
        _lineView1 = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView1.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    }
    return _lineView1;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setTitle:ZFLocalizedString(@"Cancel", nil) forState:0];
        _cancelButton.titleLabel.font = ZFFontSystemSize(16);
        _cancelButton.tag = ZFCarHeaderAction_CancelButton;
    }
    return _cancelButton;
}

- (UIView *)lineView2 {
    if (!_lineView2) {
        _lineView2 = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView2.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    }
    return _lineView2;
}

- (UIButton *)payButton {
    if (!_payButton) {
        _payButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_payButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_payButton setTitle:ZFLocalizedString(@"CartOrderInfo_TotalPrice_Cell_PayNow", nil) forState:0];
        [_payButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
        _payButton.titleLabel.font = ZFFontBoldSize(16);
        _payButton.tag = ZFCarHeaderAction_PayButton;
    }
    return _payButton;
}

@end
