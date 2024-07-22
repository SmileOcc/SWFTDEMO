//
//  ZFCartNoDataEmptyView.m
//  ZZZZZ
//
//  Created by YW on 2017/9/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCarPiecingOrderBottomView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCarPiecingOrderBottomView () <ZFInitViewProtocol>

@property (nonatomic, strong) UILabel *topTipsLabel;
@property (nonatomic, strong) UILabel *bottomTipsLabel;
@end

@implementation ZFCarPiecingOrderBottomView

#pragma mark - init methods 
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self addDropShadowWithOffset:CGSizeMake(0, -2)
                           radius:2
                            color:[UIColor blackColor]
                          opacity:0.1];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.topTipsLabel];
    [self addSubview:self.bottomTipsLabel];
}

- (void)zfAutoLayoutView {
    [self.topTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(9);
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
    }];
    
    [self.bottomTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topTipsLabel.mas_bottom).offset(4);
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-8);
    }];
}

- (void)setTopPrice:(NSString *)topPrice {
    _topPrice = topPrice;
    if (ZFIsEmptyString(topPrice)) return;
    NSString *bagStr = ZFLocalizedString(@"Bag_Total", nil);
    NSString *totalAmount = [NSString stringWithFormat:@"%@ %@", bagStr, [ExchangeManager transforPrice:topPrice]];
    self.topTipsLabel.text = totalAmount;
    
//    // 高亮显示价格 (V4.5.1价格不要高亮颜色了)
//    NSMutableAttributedString *totolAttrString = [[NSMutableAttributedString alloc] initWithString:totalAmount ];
//    NSInteger colorTh = totalAmount.length - bagStr.length;
//    [totolAttrString setAttributes:@{NSForegroundColorAttributeName: ZFCOLOR(183, 96, 42, 1), NSFontAttributeName: ZFFontBoldSize(16)} range:NSMakeRange(bagStr.length, colorTh)];
//    self.topTipsLabel.attributedText = totolAttrString;
}

- (void)setBottomPrice:(NSString *)bottomPrice {
    _bottomPrice = bottomPrice;
    NSString *allTipStr = ZFLocalizedString(@"CarPiecing_QualifiesTips", nil);
    NSString *rangePrice = @"";
    if ([bottomPrice floatValue] > 0) {
        rangePrice = [ExchangeManager transforPrice:bottomPrice];
        allTipStr = [NSString stringWithFormat:ZFLocalizedString(@"CarPiecing_PayMoreTips", nil), rangePrice];
    }
    
    NSMutableAttributedString *bottomTipsString = [[NSMutableAttributedString alloc] initWithString:allTipStr];
    NSInteger colorLocation = [[allTipStr componentsSeparatedByString:rangePrice] firstObject].length;
    [bottomTipsString setAttributes:@{NSForegroundColorAttributeName: ZFC0xFE5269(), NSFontAttributeName: ZFFontSystemSize(12)} range:NSMakeRange(colorLocation, rangePrice.length)];
    self.bottomTipsLabel.attributedText = bottomTipsString;
}

#pragma mark - getter

- (UILabel *)topTipsLabel {
    if (!_topTipsLabel) {
        _topTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topTipsLabel.font = ZFFontBoldSize(16);
        _topTipsLabel.textColor = ZFC0x2D2D2D();
    }
    return _topTipsLabel;
}

- (UILabel *)bottomTipsLabel {
    if (!_bottomTipsLabel) {
        _bottomTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _bottomTipsLabel.font = ZFFontSystemSize(12);
        _bottomTipsLabel.numberOfLines = 0;
        _bottomTipsLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _bottomTipsLabel.preferredMaxLayoutWidth = KScreenWidth - 16*2;
        _bottomTipsLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
    }
    return _bottomTipsLabel;
}

@end
