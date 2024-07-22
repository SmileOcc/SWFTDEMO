//
//  ZFGoodsDetailNormalArrowsCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailNormalArrowsCell.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFGoodsDetailCellTypeModel.h"
#import "GoodsDetailModel.h"
#import "ZFGoodsDetailEnumDefiner.h"

@interface ZFGoodsDetailNormalArrowsCell ()
@property (nonatomic, strong) UIImageView   *iconImageView;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UIImageView   *arrowImageView;
@property (nonatomic, strong) UIView        *lineView;
@end

@implementation ZFGoodsDetailNormalArrowsCell

@synthesize cellTypeModel = _cellTypeModel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addTapCellGesture];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.arrowImageView];
    [self.contentView addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.iconImageView.mas_trailing).offset(8);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-40);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.iconImageView);
        make.trailing.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - Setter

- (void)addTapCellGesture {
    @weakify(self);
    [self.contentView addTapGestureWithComplete:^(UIView * _Nonnull view) {
        @strongify(self);
        if (self.cellTypeModel.detailCellActionBlock) {
            self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, self.cellTypeModel, self.titleLabel.text);
        }
    }];
}

- (void)setCellTypeModel:(ZFGoodsDetailCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;
    UIImage *iconImage = nil;
    NSString *titleText = @"";
    
    switch (cellTypeModel.cellType) {
        case ZFGoodsDetailCellTypeShippingTips: {
            titleText = ZFLocalizedString(@"Detail_Product_Shipping_Tips",nil);
        }
            break;
            
        case ZFGoodsDetailCellTypeDescription: {
            titleText = ZFLocalizedString(@"Detail_Product_Description",nil);
        }
            break;
            
        case ZFGoodsDetailCellTypeModelStats: {
            titleText = ZFLocalizedString(@"Detail_Product_ModelStats",nil);
        }
            break;
            
        case ZFGoodsDetailCellTypeCoupon: {
            iconImage = [UIImage imageNamed:@"detail_coupon_icon"];
            titleText = ZFLocalizedString(@"Detail_Product_Coupons_Tips", nil);
        }
            break;
        default:
            break;
    }
    self.iconImageView.image = iconImage;
    
    self.titleLabel.text = ZFToString(titleText);
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.iconImageView.mas_trailing).offset(iconImage ? 8 : -14);
    }];
}

#pragma mark - Getter

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *arrowIImage = [UIImage imageNamed:@"size_arrow_right"];
        _arrowImageView.image = arrowIImage;
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _lineView;
}

@end

