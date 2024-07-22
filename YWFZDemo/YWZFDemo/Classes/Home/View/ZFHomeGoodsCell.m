//
//  ZFHomeGoodsCell.m
//  ZZZZZ
//
//  Created by YW on 18/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFHomeGoodsCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFPriceView.h"
#import "ZFBaseGoodsModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFGoodsListCountDownView.h"

@interface ZFHomeGoodsCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) ZFPriceView               *priceView;
@property (nonatomic, strong) ZFGoodsListCountDownView  *countDownView;
@end

@implementation ZFHomeGoodsCell
+ (ZFHomeGoodsCell *)homeGoodsCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    ZFHomeGoodsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.priceView];
    [self.goodsImageView addSubview:self.countDownView];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat width = self.bounds.size.width;
        CGFloat height = width / KImage_SCALE;
        make.top.leading.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(width,height));
    }];
    
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
    }];
    
    [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.top.equalTo(self.goodsImageView.mas_bottom).offset(12);
        make.bottom.mas_equalTo(-24);
    }];
}

#pragma mark - Setter
- (void)setGoodsModel:(ZFGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    
    if ([goodsModel.countDownTime integerValue] > 0) {
        self.countDownView.hidden = NO;
        [self.countDownView startTimerWithStamp:goodsModel.countDownTime timerKey:[NSString stringWithFormat:@"GoodsList_%@", goodsModel.goods_id]];
    } else {
        self.countDownView.hidden = YES;
    }
    
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:goodsModel.wp_image]
                                     placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                          options:YYWebImageOptionAvoidSetImage
                                       completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                           if (image && stage == YYWebImageStageFinished) {
                                               self.goodsImageView.image = image;
                                           }
                                       }];
    
    self.priceView.model = [self adapterModel:goodsModel];
}

- (ZFBaseGoodsModel *)adapterModel:(ZFGoodsModel *)goodsModel {
    ZFBaseGoodsModel *model = [[ZFBaseGoodsModel alloc] init];
    model.shopPrice         = goodsModel.shop_price;
    model.marketPrice       = goodsModel.market_price;
    model.tagsArray         = goodsModel.tagsArray;
    model.isHideMarketPrice = goodsModel.isHideMarketPrice;
    model.isShowCollectButton  = goodsModel.isShowCollectButton;
    model.isCollect         = goodsModel.is_collect;
    model.price_type        = goodsModel.price_type;
    model.RRPAttributedPriceString = goodsModel.RRPAttributedPriceString;
    return model;
}

#pragma mark - Private method
- (void)dropShadowWithOffset:(CGSize)offset
                      radius:(CGFloat)radius
                       color:(UIColor *)color
                     opacity:(CGFloat)opacity {
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    self.contentView.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;
    self.clipsToBounds = NO;
}

#pragma mark - Getter
- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] init];
    }
    return _goodsImageView;
}

- (ZFPriceView *)priceView {
    if (!_priceView) {
        _priceView = [[ZFPriceView alloc] init];
        @weakify(self)
        _priceView.CollectCompletionHandler = ^(BOOL collect) {
            @strongify(self)
            if (self.collectClick) {
                self.collectClick(collect);
            }
        };
    }
    return _priceView;
}

- (ZFGoodsListCountDownView *)countDownView {
    if (!_countDownView) {
        _countDownView = [[ZFGoodsListCountDownView alloc] init];
        _countDownView.hidden = YES;
    }
    return _countDownView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.goodsImageView.image = nil;
    [self.priceView clearAllData];
}

@end
