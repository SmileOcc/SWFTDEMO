//
//  ZFPostDetailSimilarGoodsCell.m
//  ZZZZZ
//
//  Created by YW on 2018/7/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFPostDetailSimilarGoodsCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "Masonry.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFPostDetailSimilarGoodsCell ()<ZFInitViewProtocol>

@property (nonatomic, strong) UIImageView        *goodsImageView;
@property (nonatomic, strong) UILabel            *priceLabel;
@property (nonatomic, strong) UIButton           *similarTagButton;
@property (nonatomic, strong) UIButton           *shopButton;

@end

@implementation ZFPostDetailSimilarGoodsCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - Action

- (void)shopAction {
    if (self.addCartBlock) {
        self.addCartBlock(self.model);
    }
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.similarTagButton];
    [self.contentView addSubview:self.shopButton];
}

- (void)zfAutoLayoutView {
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.goodsImageView.mas_width).multipliedBy(145.0 / 109.0);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.goodsImageView.mas_bottom).offset(8.0);
        make.height.mas_equalTo(14.0);
    }];
    
    [self.similarTagButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(6);
        make.trailing.offset(0);
        make.height.mas_equalTo(18);
    }];
    
    [self.shopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceLabel.mas_bottom).offset(8);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_greaterThanOrEqualTo(72);
    }];
}

- (void)setGoodsImageURL:(NSString *)url {
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:url]
                                placeholder:[UIImage imageNamed:@"community_loading_product"]];
}

- (void)setGoodsPrice:(NSString *)price {
    self.priceLabel.text = price;
}

- (void)setGoodsIsSimilar:(BOOL)isSimilar {
    self.similarTagButton.hidden = !isSimilar;
}

- (void)setShopCartShow:(BOOL)showCart {
    self.shopButton.hidden = !showCart;
}

#pragma mark - getter/setter
- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] init];
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.layer.masksToBounds = YES;
    }
    return _goodsImageView;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font          = [UIFont boldSystemFontOfSize:14.0];
        _priceLabel.textColor     = [UIColor colorWithHex:0x2d2d2d];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _priceLabel;
}

- (UIButton *)similarTagButton{
    if (!_similarTagButton) {
        _similarTagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_similarTagButton setTitle:ZFLocalizedString(@"community_post_simalar", nil) forState:UIControlStateNormal];
        _similarTagButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_similarTagButton setTitleColor:ZFC0xFE5269() forState:UIControlStateNormal];
        _similarTagButton.layer.borderWidth = 1;
        _similarTagButton.layer.borderColor = ZFC0xFE5269().CGColor;
        _similarTagButton.layer.cornerRadius = 2;
        _similarTagButton.layer.masksToBounds = YES;
        _similarTagButton.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
        _similarTagButton.backgroundColor = ZFC0xFFFFFF();
        _similarTagButton.hidden = YES;
    }
    return _similarTagButton;
}


- (UIButton *)shopButton {
    if (!_shopButton) {
        _shopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shopButton.layer.cornerRadius = 2;
        _shopButton.layer.masksToBounds = YES;
        _shopButton.layer.borderWidth = 1;
        _shopButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        _shopButton.backgroundColor = ZFC0xFFFFFF();
        [_shopButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        _shopButton.titleLabel.font = ZFFontSystemSize(12);
        [_shopButton setTitle:ZFLocalizedString(@"community_Buy", nil) forState:UIControlStateNormal];
        [_shopButton setContentEdgeInsets:UIEdgeInsetsMake(5, 8, 5, 8)];
        [_shopButton addTarget:self action:@selector(shopAction) forControlEvents:UIControlEventTouchUpInside];
        _shopButton.hidden = YES;
    }
    return _shopButton;
}

@end







@interface ZFTopicDetailSimilarGoodsMoreCell ()

@property (nonatomic, strong) UIView         *bgView;
@property (nonatomic, strong) UIView         *itemView;

@property (nonatomic, strong) UIImageView    *moreImageView;
@property (nonatomic, strong) UILabel        *msgLabel;

@end

@implementation ZFTopicDetailSimilarGoodsMoreCell

+ (ZFTopicDetailSimilarGoodsMoreCell *)viewAllCellWith:(UICollectionView *)collectionView
                                             indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[ZFTopicDetailSimilarGoodsMoreCell class]  forCellWithReuseIdentifier:NSStringFromClass([self class])];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupView];
        [self layout];
    }
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.itemView];
    [self.itemView addSubview:self.moreImageView];
    [self.itemView addSubview:self.msgLabel];
}

- (void)layout {
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.bgView.mas_width).multipliedBy(145.0 / 109.0);
    }];
    
    [self.itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView.mas_centerY);
        make.centerX.mas_equalTo(self.bgView.mas_centerX);
    }];
    
    [self.moreImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.itemView);
        make.top.mas_equalTo(self.itemView.mas_top);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
    
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.itemView.mas_centerX);
        make.top.mas_equalTo(self.moreImageView.mas_bottom).offset(10.0);
        make.bottom.mas_equalTo(self.itemView.mas_bottom);
    }];
}

- (void)setMsgTip:(NSString *)msgTip {
    if (!ZFIsEmptyString(msgTip)) {
        self.msgLabel.text = msgTip;
    }
}

#pragma mark - getter/setter

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = ZFC0xF2F2F2();
    }
    return _bgView;
}

- (UIView *)itemView {
    if (!_itemView) {
        _itemView = [[UIView alloc] initWithFrame:CGRectZero];
        _itemView.backgroundColor = ZFCClearColor();
    }
    return _itemView;
}
- (UIImageView *)moreImageView {
    if (!_moreImageView) {
        _moreImageView = [[UIImageView alloc] init];
        _moreImageView.image = [UIImage imageNamed:@"community_similar_more"];
        _moreImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_moreImageView convertUIWithARLanguage];
    }
    return _moreImageView;
}

- (UILabel *)msgLabel {
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.font          = [UIFont systemFontOfSize:14.0];
        _msgLabel.textColor     = [UIColor colorWithHex:0x999999];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.text = ZFLocalizedString(@"community_post_simalar_more", nil);
    }
    return _msgLabel;
}

@end
