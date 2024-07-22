//
//  ZFGoodsDetailOutfitsItemCell.m
//  ZZZZZ
//
//  Created by YW on 2019/9/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailOutfitsItemCell.h"
#import "ZFInitViewProtocol.h"
#import "GoodsDetailModel.h"
#import "ZFCollocationBuyModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFGoodsDetailOutfitsModel.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFGoodsDetailOutfitsItemCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UIButton        *itemButton;
@property (nonatomic, strong) UIImageView     *goodsImageView;
@end

@implementation ZFGoodsDetailOutfitsItemCell

+ (ZFGoodsDetailOutfitsItemCell *)outfitsCellWith:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFGoodsDetailOutfitsItemCell class]  forCellWithReuseIdentifier:NSStringFromClass([self class])];
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
    [self.contentView addSubview:self.itemButton];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(110, 110));
    }];
    
    [self.itemButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.goodsImageView.mas_bottom).offset(10);
        make.centerX.mas_equalTo(self.goodsImageView.mas_centerX);
        make.height.mas_equalTo(24);
    }];
}

#pragma mark - Setter
- (void)setOutfitsModel:(ZFGoodsDetailOutfitsModel *)outfitsModel {
    _outfitsModel = outfitsModel;
    
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:outfitsModel.picModel.big_pic]
                                placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:nil
                                  transform:nil
                                 completion:nil];
}

- (void)itemButtonAction:(UIButton *)button {
    if (self.itemButtonBlock) {
        self.itemButtonBlock(self.outfitsModel);
    }
}

#pragma mark - Getter

- (UIButton *)itemButton {
    if (!_itemButton) {
        _itemButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _itemButton.backgroundColor = ZFCOLOR_WHITE;
        _itemButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_itemButton setTitleColor:ZFC0x2D2D2D() forState:0];
        [_itemButton setTitle:ZFLocalizedString(@"Community_outfit_goods", nil) forState:0];
        _itemButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
        _itemButton.layer.cornerRadius = 3;
        _itemButton.layer.borderWidth = 0.5;
        _itemButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        _itemButton.layer.masksToBounds = YES;
        [_itemButton addTarget:self action:@selector(itemButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _itemButton;
}

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] init];
        _goodsImageView.backgroundColor = ZFCOLOR_WHITE;
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.clipsToBounds = YES;
        _goodsImageView.layer.borderWidth = 0.5;
        _goodsImageView.layer.borderColor = ZFCOLOR(221, 221, 221, 1).CGColor;
    }
    return _goodsImageView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.goodsImageView.image = nil;
}

@end
