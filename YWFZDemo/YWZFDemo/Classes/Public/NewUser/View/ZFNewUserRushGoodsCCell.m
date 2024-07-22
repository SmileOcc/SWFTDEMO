//
//  ZFNewUserRushGoodsCCell.m
//  ZZZZZ
//
//  Created by mac on 2019/1/10.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import "ZFNewUserRushGoodsCCell.h"
#import "ZFPriceView.h"
#import "UIImage+ZFExtended.h"
#import "ZFBaseGoodsModel.h"
#import "ZFNewUserSecckillModel.h"
#import "ZFNewUserBoardGoodsModel.h"
#import "ZFColorDefiner.h"
#import "Masonry.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFFrameDefiner.h"
#import "ZFLocalizationString.h"
#import "ZFThemeManager.h"

@interface ZFNewUserRushGoodsCCell ()

@property (nonatomic, strong) UIImageView           *goodsImageView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) ZFPriceView           *priceView;
@property (nonatomic, strong) UILabel               *descLabel;
@property (nonatomic, strong) UIProgressView        *processView;
@property (nonatomic, strong) UIButton              *buyButton;
@property (nonatomic, strong) UIButton              *soldOutButton;

@end

@implementation ZFNewUserRushGoodsCCell

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
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.priceView];
    [self.contentView addSubview:self.buyButton];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.processView];
    [self.goodsImageView addSubview:self.soldOutButton];
}

- (void)zfAutoLayoutView {
    
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.contentView).offset(12);
        make.size.mas_equalTo(CGSizeMake(90, 120));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(12);
        make.left.equalTo(self.goodsImageView.mas_right).offset(12);
        make.right.equalTo(self.contentView).offset(-12);
        make.height.mas_equalTo(30);
    }];

    [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.right.equalTo(self.titleLabel);
        make.height.mas_equalTo(30);
    }];

    [self.buyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self.contentView).offset(-12);
        make.size.mas_equalTo(CGSizeMake(110, 32));
    }];

    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.priceView.mas_bottom).offset(30);
        make.left.equalTo(self.titleLabel);
        make.right.equalTo(self.buyButton.mas_left).offset(-12);
        make.height.mas_equalTo(15);
    }];

    [self.processView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descLabel.mas_bottom).offset(5);
        make.left.right.equalTo(self.descLabel);
        make.height.mas_equalTo(6);
    }];
    
    [self.soldOutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.goodsImageView);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(20);
    }];
}

#pragma mark - setter
- (void)setGoodsModel:(ZFNewUserSecckillGoodsListModel *)goodsModel {
    _goodsModel = goodsModel;
    
    [self.goodsImageView.layer removeAnimationForKey:@"fadeAnimation"];
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:_goodsModel.goodsImg]
                                placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                    options:YYWebImageOptionAvoidSetImage
                                 completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                     if (image && stage == YYWebImageStageFinished) {
                                         self.goodsImageView.image = image;
                                         if (from != YYWebImageFromMemoryCacheFast) {
                                             CATransition *transition = [CATransition animation];
                                             transition.duration = KImageFadeDuration;
                                             transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                             transition.type = kCATransitionFade;
                                             [self.goodsImageView.layer addAnimation:transition forKey:@"fadeAnimation"];
                                         }
                                     }
                                 }];
    
    self.titleLabel.text = _goodsModel.goodsTitle;
    self.priceView.model = [self adapterModel:_goodsModel];
    self.descLabel.text = _goodsModel.goodsLeftDesc;
    self.processView.progress = _goodsModel.leftPercent / 100;
    
    if (self.goodsModel.left > 0 && self.isNotStart == NO) {
        self.soldOutButton.hidden = YES;
        self.descLabel.hidden = NO;
        self.processView.hidden = NO;
        self.buyButton.backgroundColor = ZFC0x2D2D2D();
        [_buyButton setTitle:ZFLocalizedString(@"snap_up_now", nil) forState:UIControlStateNormal];
    } else if (self.goodsModel.left > 0 && self.isNotStart == YES) {
        self.descLabel.hidden = YES;
        self.processView.hidden = YES;
        self.buyButton.backgroundColor = ZFC0x2D2D2D();
        [_buyButton setTitle:ZFLocalizedString(@"text_starting_soon", nil) forState:UIControlStateNormal];
    } else {
        self.soldOutButton.hidden = NO;
        self.descLabel.hidden = YES;
        self.processView.hidden = YES;
        self.buyButton.backgroundColor = ZFC0xCCCCCC();
        [_buyButton setTitle:ZFLocalizedString(@"text_gone", nil) forState:UIControlStateNormal];
    }
}

- (void)setBoardGoodsList:(ZFNewUserBoardGoodsGoodsList *)boardGoodsList {
    _boardGoodsList = boardGoodsList;
    
    [self.goodsImageView.layer removeAnimationForKey:@"fadeAnimation"];
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:_boardGoodsList.goods_thumb]
                                placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                    options:YYWebImageOptionAvoidSetImage
                                 completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                     if (image && stage == YYWebImageStageFinished) {
                                         self.goodsImageView.image = image;
                                         if (from != YYWebImageFromMemoryCacheFast) {
                                             CATransition *transition = [CATransition animation];
                                             transition.duration = KImageFadeDuration;
                                             transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                             transition.type = kCATransitionFade;
                                             [self.goodsImageView.layer addAnimation:transition forKey:@"fadeAnimation"];
                                         }
                                     }
                                 }];
    
    self.titleLabel.text = _boardGoodsList.goods_title;
    self.priceView.model = [self boardGoodsListModel:_boardGoodsList];
    self.descLabel.text = _boardGoodsList.seckill_info.goods_left_desc;
    self.processView.progress = _boardGoodsList.seckill_info.left_percent / 100;
    
    // 状态：0:抢购中 1抢光了, 2 即将抢购
    switch ((NSInteger)_boardGoodsList.seckill_info.seckill_status) {
        case 0:
            self.soldOutButton.hidden = YES;
            self.descLabel.hidden = NO;
            self.processView.hidden = NO;
            self.buyButton.backgroundColor = ZFC0x2D2D2D();
            [_buyButton setTitle:ZFLocalizedString(@"snap_up_now", nil) forState:UIControlStateNormal];
            break;
        case 1:
            self.soldOutButton.hidden = NO;
            self.descLabel.hidden = YES;
            self.processView.hidden = YES;
            self.buyButton.backgroundColor = ZFC0xCCCCCC();
            [_buyButton setTitle:ZFLocalizedString(@"text_gone", nil) forState:UIControlStateNormal];
            break;
        case 2:
            self.soldOutButton.hidden = YES;
            self.descLabel.hidden = NO;
            self.processView.hidden = NO;
            self.buyButton.backgroundColor = ZFC0x2D2D2D();
            [_buyButton setTitle:ZFLocalizedString(@"text_starting_soon", nil) forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (ZFBaseGoodsModel *)adapterModel:(ZFNewUserSecckillGoodsListModel *)goodsModel {
    ZFBaseGoodsModel *model     = [[ZFBaseGoodsModel alloc] init];
    model.shopPrice             = goodsModel.price;
    model.marketPrice           = goodsModel.marketPrice;
    return model;
}

- (ZFBaseGoodsModel *)boardGoodsListModel:(ZFNewUserBoardGoodsGoodsList *)goodsModel {
    ZFBaseGoodsModel *model     = [[ZFBaseGoodsModel alloc] init];
    model.shopPrice             = goodsModel.shop_price;
    model.marketPrice           = goodsModel.market_price;
    return model;
}


#pragma mark - getter
- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] init];
    }
    return _goodsImageView;
}

- (UIButton *)buyButton {
    if (!_buyButton) {
        _buyButton = [[UIButton alloc] init];
        _buyButton.backgroundColor = ZFC0x2D2D2D();
        _buyButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _buyButton.userInteractionEnabled = NO;
        [_buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buyButton setTitle:ZFLocalizedString(@"snap_up_now", nil) forState:UIControlStateNormal];
    }
    return _buyButton;
}

- (ZFPriceView *)priceView {
    if (!_priceView) {
        _priceView = [[ZFPriceView alloc] init];
    }
    return _priceView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment   = NSTextAlignmentLeft;
        _titleLabel.textColor       = [UIColor blackColor];
        _titleLabel.font            = [UIFont systemFontOfSize:12.0f];
        _titleLabel.numberOfLines   = 2;
        _titleLabel.userInteractionEnabled = YES;
    }
    return _titleLabel;
}

- (UIProgressView *)processView {
    if (!_processView) {
        _processView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _processView.trackTintColor = ColorHex_Alpha(0xEEEEEE, 1.0);
        _processView.progressTintColor = ZFC0x2D2D2D_04();
        _processView.layer.cornerRadius = 3;
        _processView.layer.masksToBounds = YES;
    }
    return _processView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] init];
        _descLabel.textAlignment   = NSTextAlignmentLeft;
        _descLabel.textColor       = ZFC0x999999();
        _descLabel.font            = [UIFont systemFontOfSize:12.0f];
        _descLabel.numberOfLines   = 0;
        _descLabel.userInteractionEnabled = YES;
    }
    return _descLabel;
}

- (UIButton *)soldOutButton {
    if (!_soldOutButton) {
        _soldOutButton = [[UIButton alloc] init];
        _soldOutButton.hidden = YES;
        _soldOutButton.backgroundColor = ZFC0x000000_04();
        _soldOutButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _soldOutButton.userInteractionEnabled = NO;
        _soldOutButton.layer.cornerRadius = 10;
        _soldOutButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        [_soldOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_soldOutButton setTitle:ZFLocalizedString(@"Detail_Product_SoldOut", nil) forState:UIControlStateNormal];
    }
    return _soldOutButton;
}

@end
