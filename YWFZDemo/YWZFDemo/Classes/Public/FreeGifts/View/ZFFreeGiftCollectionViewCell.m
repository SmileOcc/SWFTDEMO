//
//  ZFFreeGiftCollectionViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/5/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFFreeGiftCollectionViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFPriceView.h"
#import "ZFBaseGoodsModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFFreeGiftCollectionViewCell() <ZFInitViewProtocol>

@property (nonatomic, strong) ZFPriceView               *priceView;

@end

@implementation ZFFreeGiftCollectionViewCell
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.goodsImageView yy_cancelCurrentImageRequest];
    self.goodsImageView.image = nil;
    [self.priceView clearAllData];
}

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.priceView];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.contentView);
        CGFloat width = (KScreenWidth - 36) / 2.0;
        make.size.mas_equalTo(CGSizeMake(width, (width / KImage_SCALE)));
    }];
    
    [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.goodsImageView.mas_bottom).offset(12);
        make.bottom.mas_equalTo(-24);
    }];
}

#pragma mark - setter
- (void)setModel:(ZFFreeGiftGoodsModel *)model {
    _model = model;
    [self.goodsImageView  yy_setImageWithURL:[NSURL URLWithString:model.wp_image]
                                 placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                     options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                    progress:nil
                                   transform:nil
                                  completion:nil];
    
    self.priceView.model = [self adapterModel:model];
}

- (ZFBaseGoodsModel *)adapterModel:(ZFFreeGiftGoodsModel *)goodsModel {
    ZFBaseGoodsModel *model = [[ZFBaseGoodsModel alloc] init];
    model.shopPrice         = goodsModel.shop_price;
    model.marketPrice       = goodsModel.market_price;
    model.tagsArray         = goodsModel.tagsArray;
    model.isHideMarketPrice = goodsModel.isHideMarketPrice;
    model.isShowCollectButton  = goodsModel.isShowCollectButton;
    model.isCollect         = goodsModel.is_collect;
    return model;
}

#pragma mark - getter
- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _goodsImageView;
}

- (ZFPriceView *)priceView {
    if (!_priceView) {
        _priceView = [[ZFPriceView alloc] initWithFrame:CGRectZero];
        @weakify(self);
        _priceView.CollectCompletionHandler = ^(BOOL collect) {
            @strongify(self);
            if (self.freeGiftCollectCompletionHandler) {
                self.freeGiftCollectCompletionHandler(collect);
            }
        };
    }
    return _priceView;
}

@end
