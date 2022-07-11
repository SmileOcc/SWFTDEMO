//
//  YXKLineSecondaryView.m
//  uSmartOversea
//
//  Created by youxin on 2020/6/16.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXKLineSecondaryView.h"
#import "YXKLineUtility.h"
#import <CoreText/CoreText.h>
#import <YYCategories/NSString+YYAdd.h>
#import "MMKV.h"
#import "YXDateToolUtility.h"
#import "YXStockDetailUtility.h"
#import "YXStockLineMenuView.h"
#import "YXKlineSettingBtn.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "YXKLineConfigManager.h"
#import "UILabel+create.h"
#import "YYCategoriesMacro.h"

@interface YXKLineSecondaryView()

//layer生成器
@property (nonatomic, strong) YXLayerGenerator *generator;
//title生成器
@property (nonatomic, strong) YXAccessoryTitleGenerator *titleGenerator;

@property (nonatomic, strong) UIView *topMaskView;

@end


@implementation YXKLineSecondaryView

- (instancetype)initWithFrame:(CGRect)frame
                    subStatus:(YXStockSubAccessoryStatus)status
               titleGenerator:(YXAccessoryTitleGenerator *)titleGenerator
               layerGenerator:(YXLayerGenerator *)generator {

    if (self = [super initWithFrame:frame]) {
        self.subStatus = status;
        self.generator = generator;
        self.titleGenerator = titleGenerator;
        [self initUI];
    }
    return self;
}

- (void)initUI {

    self.backgroundColor = UIColor.clearColor;
    self.userInteractionEnabled = NO;

//    UIColor *color = [UIColor qmui_colorWithHexString:@"#F3F3F3"];

    //横3
//    NSInteger horizonCount = 3;
//    NSInteger verticalCount = 4;
//    CGFloat verticalSpace = (self.frame.size.height - kSecondaryTopFixMargin) / (horizonCount - 1);
//    NSMutableArray *verticlaArray = [NSMutableArray array];
//    for (int i = 0; i < horizonCount; i ++) {
//        UIView *lineView = [[UIView alloc] init];
//        lineView.backgroundColor = color;
//        [self addSubview:lineView];
//        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.equalTo(self);
//            make.height.mas_equalTo(1);
//            make.top.equalTo(self).offset(kSecondaryTopFixMargin + i * verticalSpace - 0.5);
//        }];
//    }
//    //竖4
//    for (int i = 0; i < verticalCount; i ++) {
//        UIView *lineView = [[UIView alloc] init];
//        lineView.backgroundColor = color;
//        [self addSubview:lineView];
//        [verticlaArray addObject:lineView];
//    }
//
//    [verticlaArray mas_distributeViewsAlongAxis:(MASAxisTypeHorizontal) withFixedItemLength:1 leadSpacing:0 tailSpacing:0];
//    [verticlaArray mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self).offset(kSecondaryTopFixMargin);
//        make.bottom.equalTo(self);
//    }];

    [self addSubview:self.topMaskView];
    [self.topMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(kSecondaryTopFixMargin);
    }];

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.userInteractionEnabled = NO;
    [self addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self).offset(kSecondaryTopFixMargin);
        make.bottom.equalTo(self);
    }];
    
    [self addTitleLabel];
    [self addSubAccessoryLayer];

    [self addSubview:self.subMaxPriceLabel];
    [self addSubview:self.subMidPriceLabel];
    [self addSubview:self.subMinPriceLabel];

    [self.subMaxPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self).offset(1 + kSecondaryTopFixMargin);
        make.right.lessThanOrEqualTo(self);
        make.height.mas_equalTo(15);
    }];

    [self.subMidPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self).offset(kSecondaryTopFixMargin + (self.frame.size.height - kSecondaryTopFixMargin) / 2.0 - 7.5);
        make.right.lessThanOrEqualTo(self);
        make.height.mas_equalTo(15);
    }];

    [self.subMinPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.bottom.equalTo(self).offset(-1);
        make.right.lessThanOrEqualTo(self);
        make.height.mas_equalTo(15);
    }];

}

- (void)addTitleLabel {

    UILabel *label = nil;
    switch (self.subStatus) {
        case YXStockSubAccessoryStatus_MAVOL: //新添加了vol参数
            label = self.titleGenerator.MACD_VOL_Label;
            break;

        case YXStockSubAccessoryStatus_MACD:
            label = self.titleGenerator.MACDTitleLabel;
            break;
        case YXStockSubAccessoryStatus_KDJ:
            label = self.titleGenerator.KDJLabel;
            break;

        case YXStockSubAccessoryStatus_RSI:
            label = self.titleGenerator.RSILabel;
            break;
        case YXStockSubAccessoryStatus_DMA:
            label = self.titleGenerator.DMALabel;
            break;
        case YXStockSubAccessoryStatus_ARBR:
            label = self.titleGenerator.ARBRLabel;
            break;
        case YXStockSubAccessoryStatus_WR:
            label = self.titleGenerator.WRLabel;
            break;
        case YXStockSubAccessoryStatus_EMV:
            label = self.titleGenerator.EMVLabel;
            break;
        case YXStockSubAccessoryStatus_CR:
            label = self.titleGenerator.CRLabel;
            break;
        default:
            break;
    }

    if (label != nil) {
        self.titleLabel = label;
        [self.topMaskView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(kSecondaryTopFixMargin - 15);
            make.leading.equalTo(self);
            make.height.mas_equalTo(15);
            make.trailing.equalTo(self);
        }];
    }
}

- (void)addSubAccessoryLayer {
    CALayer *superLayer = self.scrollView.layer;
    // 副指标
    switch (self.subStatus) {
        case YXStockSubAccessoryStatus_MAVOL: //新添加了vol参数
            //VOL
            [superLayer addSublayer:self.generator.greenVolumeLayer];
            [superLayer addSublayer:self.generator.redVolumeLayer];
            [superLayer addSublayer:self.generator.volumn5_Layer];
            [superLayer addSublayer:self.generator.volumn10_Layer];
            [superLayer addSublayer:self.generator.volumn20_Layer];
            break;

        case YXStockSubAccessoryStatus_MACD:
            //MACD
            [superLayer addSublayer:self.generator.redMACDLayer];
            [superLayer addSublayer:self.generator.greenMACDLayer];
            [superLayer addSublayer:self.generator.difLayer];
            [superLayer addSublayer:self.generator.deaLayer];
            break;
        case YXStockSubAccessoryStatus_KDJ:
            //KDJ
            [superLayer addSublayer:self.generator.kdj_k_layer];
            [superLayer addSublayer:self.generator.kdj_d_layer];
            [superLayer addSublayer:self.generator.kdj_j_layer];
            break;

        case YXStockSubAccessoryStatus_RSI:
            //RSI
            [superLayer addSublayer:self.generator.RSI_6_layer];
            [superLayer addSublayer:self.generator.RSI_12_layer];
            [superLayer addSublayer:self.generator.RSI_24_layer];
            break;
        case YXStockSubAccessoryStatus_DMA:
            //DMA
            [superLayer addSublayer:self.generator.D_DIF_layer];
            [superLayer addSublayer:self.generator.D_AMA_layer];
            break;
        case YXStockSubAccessoryStatus_ARBR:
            //ARBR
            [superLayer addSublayer:self.generator.AR_layer];
            [superLayer addSublayer:self.generator.BR_layer];
            break;
        case YXStockSubAccessoryStatus_WR:
            //WR
            [superLayer addSublayer:self.generator.WR1_layer];
            [superLayer addSublayer:self.generator.WR2_layer];
            break;
        case YXStockSubAccessoryStatus_EMV:
            //EMV
            [superLayer addSublayer:self.generator.EMV_layer];
            [superLayer addSublayer:self.generator.AEMV_layer];
            break;
        case YXStockSubAccessoryStatus_CR:
            // CR
            [superLayer addSublayer:self.generator.CR_layer];
            [superLayer addSublayer:self.generator.CR1_layer];
            [superLayer addSublayer:self.generator.CR2_layer];
            [superLayer addSublayer:self.generator.CR3_layer];
            [superLayer addSublayer:self.generator.CR4_layer];
            break;
        default:
            break;
    }

}

#pragma mark - Setter


#pragma mark - Lazy Load

- (UIView *)topMaskView {
    if (!_topMaskView) {
        _topMaskView = [[UIView alloc] init];
        _topMaskView.backgroundColor = QMUITheme.foregroundColor;
    }
    return _topMaskView;
}

- (UILabel *)subMaxPriceLabel {
    if (!_subMaxPriceLabel) {
        _subMaxPriceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular] textAlignment:NSTextAlignmentLeft];
    }
    return _subMaxPriceLabel;
}

- (UILabel *)subMidPriceLabel {
    if (!_subMidPriceLabel) {
        _subMidPriceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular] textAlignment:NSTextAlignmentLeft];
    }
    return _subMidPriceLabel;
}

- (UILabel *)subMinPriceLabel {
    if (!_subMinPriceLabel) {
        _subMinPriceLabel = [UILabel labelWithText:@"--" textColor:[QMUITheme textColorLevel3] textFont:[UIFont systemFontOfSize:10 weight:UIFontWeightRegular] textAlignment:NSTextAlignmentLeft];
    }
    return _subMinPriceLabel;
}

@end
