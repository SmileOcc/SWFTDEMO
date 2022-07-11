//
//  STLAttributeSheetGoodsInfoReusableView.m
// XStarlinkProject
//
//  Created by odd on 2020/12/7.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLAttributeSheetGoodsInfoReusableView.h"
#import "ExchangeManager.h"

@interface STLAttributeSheetGoodsInfoReusableView()

@end

@implementation STLAttributeSheetGoodsInfoReusableView

+ (STLAttributeSheetGoodsInfoReusableView *)attributeGoodsInfoViewWithCollectionView:(UICollectionView *)collectionView kind:(NSString*)kind indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[STLAttributeSheetGoodsInfoReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:@"STLAttributeSheetGoodsInfoReusableView"];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"STLAttributeSheetGoodsInfoReusableView" forIndexPath:indexPath];
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
                
        [self addSubview:self.goodsTitleLabel];
        [self addSubview:self.goodsPriceLabel];
        [self addSubview:self.grayPrice];
        
        [self addSubview:self.detablLabel];
        [self addSubview:self.detailArrowImageView];
        [self addSubview:self.eventBtn];
        [self addSubview:self.activityStateView];
        
        
        [self.goodsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.top.mas_equalTo(self.mas_top).mas_offset(8);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
            make.height.mas_equalTo(@15);
        }];
        
        [self.goodsPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(12);
            make.top.mas_equalTo(self.goodsTitleLabel.mas_bottom).mas_offset(4);
            make.height.mas_offset(@18);
        }];
        
        [self.grayPrice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.goodsPriceLabel.mas_trailing).offset(4);
            make.centerY.mas_equalTo(self.goodsPriceLabel.mas_centerY);
        }];
        
        
        [self.detailArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.size.mas_equalTo(CGSizeMake(24, 24));
            make.centerY.mas_equalTo(self.grayPrice.mas_centerY);
        }];
        
        [self.detablLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.detailArrowImageView.mas_centerY);
            make.trailing.mas_equalTo(self.detailArrowImageView.mas_leading);
        }];
        
        [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.goodsPriceLabel.mas_leading);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-8);
        }];
        
        [self.eventBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.detailArrowImageView.mas_trailing);
            make.top.bottom.mas_equalTo(self.detailArrowImageView);
            make.leading.mas_equalTo(self.detablLabel.mas_leading);
        }];

    }
    
    return self;
}

- (void)setBaseInfoModel:(OSSVDetailsBaseInfoModel *)baseInfoModel {
    _baseInfoModel = baseInfoModel;
    
    self.goodsPriceLabel.textColor = [OSSVThemesColors col_0D0D0D];
    self.goodsPriceLabel.text = STLToString(baseInfoModel.shop_price_converted);
    self.grayPrice.text = STLToString(baseInfoModel.market_price_converted);
    self.goodsTitleLabel.text = baseInfoModel.goodsTitle;
    
    self.activityStateView.hidden = YES;

    if ([baseInfoModel.showDiscountIcon isEqualToString:@"0"] || [OSSVNSStringTool isEmptyString:baseInfoModel.goodsDiscount] || [baseInfoModel.goodsDiscount isEqualToString:@"0"]) {
        
    } else {// 价格
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(baseInfoModel.goodsDiscount)];
    }
    
    //和鲍勇再次确认完全可以拿着is_can_buy 字段来判断用户能否按照闪购价继续购买，以及闪购背景置灰和 价格不为红色
    // 0 > 闪购 > 满减
    if (STLIsEmptyString(baseInfoModel.specialId) && baseInfoModel.flash_sale &&  [baseInfoModel.flash_sale.is_can_buy isEqualToString:@"1"] && [baseInfoModel.flash_sale.active_status isEqualToString:@"1"]) {
        
        self.activityStateView.hidden = NO;
        self.goodsPriceLabel.text = STLToString(baseInfoModel.flash_sale.active_price_converted);
        self.goodsPriceLabel.textColor = OSSVThemesColors.col_B62B21;
        [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(baseInfoModel.flash_sale.active_discount)];
    }
    
    if (self.activityStateView.isHidden) {
        [self.detailArrowImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.grayPrice.mas_centerY);
        }];
    } else {
        [self.detailArrowImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.grayPrice.mas_centerY).mas_offset(@(12));
        }];
    }
}

- (void)setIsShowArrow:(BOOL)isShowArrow {
    _isShowArrow = isShowArrow;
    self.detailArrowImageView.hidden = !isShowArrow;
    self.detablLabel.hidden = !isShowArrow;
    self.eventBtn.hidden = !isShowArrow;
}

- (UILabel *)detablLabel {
    if (!_detablLabel) {
        _detablLabel = [[UILabel alloc] init];
        _detablLabel.textColor = [OSSVThemesColors col_999999];
        _detablLabel.font = [UIFont systemFontOfSize:11];
        
        _detablLabel.text = STLLocalizedString_(@"AttributeSheetDetail", nil);
        _detablLabel.hidden = YES;
    }
    return _detablLabel;
}

- (UIImageView *)detailArrowImageView {
    if (!_detailArrowImageView) {
        _detailArrowImageView = [[UIImageView alloc]init];
        _detailArrowImageView.image = [UIImage imageNamed:@"detail_right_arrow"];
        _detailArrowImageView.hidden = YES;
        [_detailArrowImageView convertUIWithARLanguage];
    }
    return _detailArrowImageView;
}


- (UILabel *)goodsPriceLabel {
    if (!_goodsPriceLabel) {
        _goodsPriceLabel = [UILabel new];
        _goodsPriceLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _goodsPriceLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    return _goodsPriceLabel;
}

- (STLCLineLabel *)grayPrice {
    if (!_grayPrice) {
        _grayPrice = [[STLCLineLabel alloc] init];
        _grayPrice.textColor = [OSSVThemesColors col_999999];
        _grayPrice.font = [UIFont systemFontOfSize:11];
    }
    return _grayPrice;
}

- (UILabel *)goodsTitleLabel {
    if (!_goodsTitleLabel) {
        _goodsTitleLabel = [UILabel new];
        _goodsTitleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _goodsTitleLabel.numberOfLines = 1;
        _goodsTitleLabel.font = [UIFont systemFontOfSize:11];
    }
    return _goodsTitleLabel;
}


- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleNormal];
        _activityStateView.samllImageShow = 12;
        _activityStateView.fontSize = 9;
        _activityStateView.flashImageSize = 12;
        _activityStateView.hidden = YES;
    }
    return _activityStateView;
}

- (UIButton *)eventBtn {
    if (!_eventBtn) {
        _eventBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eventBtn addTarget:self action:@selector(eventBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        _eventBtn.hidden = YES;
    }
    return _eventBtn;
}

- (void)eventBtnTouch:(UIButton*)sender {
    if (self.goodsDetailBlock) {
        self.goodsDetailBlock();
    }
}
@end
