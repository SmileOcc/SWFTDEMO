
//
//  ZFSearchResultPriceSortView.m
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchResultPriceSortView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFSearchResultPriceSortView() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *priceLabel;
@property (nonatomic, strong) UIImageView       *iconImageView;
@end

@implementation ZFSearchResultPriceSortView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        @weakify(self);
        [self addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.searchResultPriceSortCompletionHandler) {
                self.sortType = !self.sortType;
                self.searchResultPriceSortCompletionHandler(self.sortType);
            }
        }];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.priceLabel];
    [self addSubview:self.iconImageView];
}

- (void)zfAutoLayoutView {
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.centerY.mas_equalTo(self);
        make.width.mas_equalTo(KScreenWidth / 5.0);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.leading.mas_equalTo(self.priceLabel.mas_trailing).offset(4);
    }];
    
}

#pragma mark - setter
- (void)setSortType:(ZFSearchResultPriceSortType)sortType {
    _sortType = sortType;

    switch (_sortType) {
        case ZFSearchResultPriceSortTypeNormal: {
            self.priceLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
            self.priceLabel.font = [UIFont systemFontOfSize:14];
            self.iconImageView.image = [UIImage imageNamed:@"price_normal"];
        }
            break;
        case ZFSearchResultPriceSortTypeHighToLow: {
            self.priceLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
            self.priceLabel.font = [UIFont boldSystemFontOfSize:14];
            self.iconImageView.image = [UIImage imageNamed:@"price_low"];
        }
            break;
        case ZFSearchResultPriceSortTypeLowToHigh: {
            self.priceLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
            self.priceLabel.font = [UIFont boldSystemFontOfSize:14];
            self.iconImageView.image = [UIImage imageNamed:@"price_High"];
        }
            break;

    }
}

#pragma mark - getter
- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont systemFontOfSize:14];
        _priceLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _priceLabel.textAlignment = NSTextAlignmentRight;
        _priceLabel.text = ZFLocalizedString(@"GoodsSort_Price", nil);
        [_priceLabel sizeToFit];
    }
    return _priceLabel;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.image = [UIImage imageNamed:@"price_normal"];
        _iconImageView.userInteractionEnabled = YES;
    }
    return _iconImageView;
}

@end
