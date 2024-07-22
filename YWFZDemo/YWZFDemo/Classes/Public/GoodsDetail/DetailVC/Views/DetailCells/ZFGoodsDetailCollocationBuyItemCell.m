//
//  ZFGoodsDetailCollocationBuyItemCell.m
//  ZZZZZ
//
//  Created by YW on 2019/8/7.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailCollocationBuyItemCell.h"
#import "ZFInitViewProtocol.h"
#import "GoodsDetailModel.h"
#import "ZFCollocationBuyModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFGoodsDetailCollocationBuyItemCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView     *goodsImageView;
@property (nonatomic, strong) UIImageView     *addImageView;
@end

@implementation ZFGoodsDetailCollocationBuyItemCell

+ (ZFGoodsDetailCollocationBuyItemCell *)ShowListCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFGoodsDetailCollocationBuyItemCell class]  forCellWithReuseIdentifier:NSStringFromClass([self class])];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.addImageView];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.bottom.equalTo(self.contentView);
        make.width.mas_equalTo(90);
    }];
    
    [self.addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.goodsImageView.mas_trailing).offset(11);
        make.size.mas_equalTo(CGSizeMake(28, 28));
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
}

#pragma mark - Setter
- (void)setModel:(ZFCollocationGoodsModel *)model {
    _model = model;
    
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:model.goods_grid_app]
                                placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:nil
                                  transform:nil
                                 completion:nil];
}

#pragma mark - Getter

- (UIImageView *)addImageView {
    if (!_addImageView) {
        _addImageView = [[UIImageView alloc] initWithImage:ZFImageWithName(@"add_collocation_buy")];
        _addImageView.contentMode = UIViewContentModeScaleAspectFill;
        _addImageView.backgroundColor = ZFCOLOR_WHITE;
        _addImageView.clipsToBounds = YES;
    }
    return _addImageView;
}

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] init];
        _goodsImageView.backgroundColor = ZFCOLOR_WHITE;
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.clipsToBounds = YES;
    }
    return _goodsImageView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.goodsImageView.image = nil;
}

@end
