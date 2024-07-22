//
//  ZFWishListVerticalStyleCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/22.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFWishListVerticalStyleCell.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "UIColor+ExTypeChange.h"
#import "YYLabel.h"
#import "ExchangeManager.h"
#import "ZFRRPLabel.h"
#import "UIButton+ZFButtonCategorySet.h"

#import <Masonry/Masonry.h>
#import <YYWebImage/YYWebImage.h>

@interface ZFWishListVerticalStyleCell ()

@property (nonatomic, strong) UIImageView *productImageView;
@property (nonatomic, strong) YYLabel *titleLabel;
@property (nonatomic, strong) UIView *tagsView;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) ZFRRPLabel *marketPriceLabel;
//@property (nonatomic, strong) UILabel *sizeLabel;
@property (nonatomic, strong) UIButton *findRelatedButton;
@property (nonatomic, strong) UIButton *addCartBagButton;
//卖光了提示label
@property (nonatomic, strong) UILabel *soldOutLabel;
@end

@implementation ZFWishListVerticalStyleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *contentView = self.contentView;
        
        [contentView addSubview:self.productImageView];
        [contentView addSubview:self.titleLabel];
        [contentView addSubview:self.tagsView];
        [contentView addSubview:self.priceLabel];
        [contentView addSubview:self.marketPriceLabel];
//        [contentView addSubview:self.sizeLabel];
        [contentView addSubview:self.findRelatedButton];
        [contentView addSubview:self.addCartBagButton];
        [contentView addSubview:self.soldOutLabel];
        
        CGFloat padding4 = 4;
        CGFloat padding12 = 12;
        CGFloat padding9 = 9;

        [self.productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(contentView).mas_offset(padding12);
            make.top.mas_equalTo(contentView).mas_offset(padding12);
            make.bottom.mas_equalTo(contentView).mas_offset(-padding12);
            make.size.mas_offset(CGSizeMake(90, 120));
        }];
        
        [self.soldOutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.productImageView);
            make.centerX.mas_equalTo(self.productImageView);
            make.width.mas_offset(80);
            make.height.mas_offset(20);
        }];
        self.soldOutLabel.layer.cornerRadius = 10;
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.productImageView);
            make.leading.mas_equalTo(self.productImageView.mas_trailing).mas_offset(padding9);
            make.trailing.mas_equalTo(contentView.mas_trailing).mas_offset(-padding12);
        }];
        self.titleLabel.preferredMaxLayoutWidth = KScreenWidth - (KScreenWidth * 0.24) - padding12 - padding12 - padding9 - padding12;
        
        [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(padding4);
            make.leading.mas_equalTo(self.titleLabel);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tagsView.mas_bottom).mas_offset(padding4);
            make.leading.mas_equalTo(self.titleLabel);
        }];
        
        [self.marketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.priceLabel.mas_centerY);
            make.leading.mas_equalTo(self.priceLabel.mas_trailing).mas_offset(padding4);
        }];
        
        //        [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.leading.mas_equalTo(self.titleLabel);
        //            make.top.mas_equalTo(self.priceLabel.mas_bottom).mas_offset(padding4);
        //        }];
        
        [self.findRelatedButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.productImageView);
            make.leading.mas_equalTo(self.titleLabel);
            make.height.mas_equalTo(28);
        }];
        
        [self.addCartBagButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.titleLabel);
            make.bottom.mas_equalTo(self.findRelatedButton);
            make.size.mas_offset(CGSizeMake(24, 24));
        }];
    }
    return self;
}

#pragma mark - target

- (void)findRelatedButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFWishListVerticalStyleCellDidClickFindRelated:)]) {
        [self.delegate ZFWishListVerticalStyleCellDidClickFindRelated:self.goodsModel];
    }
}

- (void)addCartBagButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFWishListVerticalStyleCellDidClickAddCartBag:)]) {
        [self.delegate ZFWishListVerticalStyleCellDidClickAddCartBag:self.goodsModel];
    }
}

#pragma mark - private method

- (void)handleTagsView
{
//    NSMutableArray *testTags = [[NSMutableArray alloc] init];
//    for (int i = 0; i < 3; i++) {
//        ZFGoodsTagModel *model = [ZFGoodsTagModel new];
//        model.tagTitle = @"123";
//        model.fontSize = 12;
//        model.tagColor = @"CE0E61";
//        model.borderColor = @"CE0E61";
//        [testTags addObject:model];
//    }
//    if (test) {
//        test = false;
//        _goodsModel.tagsArray = nil;
//    } else {
//        test = true;
//        _goodsModel.tagsArray = testTags.copy;
//    }
    //计算tag位置
    [self.tagsView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    if ([_goodsModel.tagsArray count]) {
        __block NSUInteger totalCount = _goodsModel.tagsArray.count;
        [_goodsModel.tagsArray enumerateObjectsUsingBlock:^(ZFGoodsTagModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.enabled = NO;
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            button.layer.borderColor = [UIColor colorWithHexString:obj.tagColor].CGColor;
            button.layer.borderWidth = 1;
            button.layer.cornerRadius = 2;
            button.layer.masksToBounds = YES;
            button.contentEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
            [button setTitleColor:[UIColor colorWithHexString:obj.tagColor] forState:UIControlStateNormal];
            [button setTitle:obj.tagTitle forState:UIControlStateNormal];
            [self.tagsView addSubview:button];
            if (idx == 0) {
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.mas_equalTo(self.tagsView);
                    make.top.mas_equalTo(self.tagsView.mas_top).offset(2);
                    make.bottom.mas_equalTo(self.tagsView.mas_bottom).offset(-2);
                }];
            } else {
                UIButton *perLabel = self.tagsView.subviews[idx - 1];
                [button mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.bottom.mas_equalTo(perLabel);
                    make.leading.mas_equalTo(perLabel.mas_trailing).mas_offset(4);
                    make.width.priorityLow();
                    if (idx == totalCount - 1) {
                        make.trailing.mas_equalTo(self.tagsView.mas_trailing);
                    }
                }];
            }
        }];
        [self.priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tagsView.mas_bottom).mas_offset(4);
        }];
    } else {
        [self.priceLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tagsView.mas_bottom).mas_offset(0);
        }];
    }
}

#pragma mark - Property Method

- (void)setGoodsModel:(ZFGoodsModel *)goodsModel
{
    _goodsModel = goodsModel;
    
//    [self.productImageView.layer removeAnimationForKey:@"fadeAnimation"];
    [self.productImageView yy_setImageWithURL:[NSURL URLWithString:_goodsModel.wp_image]
                                placeholder:[UIImage imageNamed:@"index_banner_loading"]
                                    options:YYWebImageOptionSetImageWithFadeAnimation
                                 completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                 }];
    
    [self handleTagsView];
 
    self.titleLabel.text = _goodsModel.goods_title;
    self.priceLabel.text = [ExchangeManager transforPrice:_goodsModel.shop_price];
    self.marketPriceLabel.attributedText = [_goodsModel gainMarkPriceAttributedString];

    //1.非失效商品，黑色字体和边框
    //2.失效商品呢，红色字体和边框
    //0正常商品 1失效商品
    if (!_goodsModel.is_disabled) {
        _findRelatedButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        [_findRelatedButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        _addCartBagButton.hidden = NO;
        self.titleLabel.textColor = ZFC0x999999();
//        self.priceLabel.textColor = ZFCThemeColor();
        self.marketPriceLabel.textColor = ZFC0x999999();
        if ([_goodsModel showMarketPrice]) {
            self.priceLabel.textColor = ZFC0xFE5269();
            self.marketPriceLabel.hidden = NO;
        } else {
            self.priceLabel.textColor = ZFCOLOR_BLACK;
            self.marketPriceLabel.hidden = YES;
        }
    } else {
        _findRelatedButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        [_findRelatedButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        _addCartBagButton.hidden = YES;
        self.titleLabel.textColor = ZFC0xCCCCCC();
        self.priceLabel.textColor = ZFC0xCCCCCC();
        self.marketPriceLabel.textColor = ZFC0xCCCCCC();
    }
    self.soldOutLabel.hidden = !_goodsModel.is_disabled;
    
    //无相似商品的时候隐藏按钮
//    _findRelatedButton.hidden = !_goodsModel.is_similar;
}

///商详穿搭关联商品公用此Cell时刷新部分UI
- (void)refreshUIStyleFromGoodsDetailOutfits {
    
    //下架，没有货 显示找相似
    self.findRelatedButton.hidden = (self.goodsModel.goods_number.integerValue > 0) ? YES : NO;
    self.soldOutLabel.hidden = self.findRelatedButton.isHidden;
    self.addCartBagButton.hidden = !self.findRelatedButton.isHidden;
    self.findRelatedButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
    [self.findRelatedButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
}

#pragma mark - Getter

- (UIImageView *)productImageView
{
    if (!_productImageView) {
        _productImageView = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.contentMode = UIViewContentModeScaleAspectFill;
            img.clipsToBounds = YES;
            img;
        });
    }
    return _productImageView;
}

-(YYLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
            YYLabel *label = [[YYLabel alloc] init];
            label.textVerticalAlignment = YYTextVerticalAlignmentTop;
            label.numberOfLines = 1;
            label.textColor = ZFC0x999999();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _titleLabel;
}

- (UIView *)tagsView
{
    if (!_tagsView) {
        _tagsView = ({
            UIView *view = [[UIView alloc] init];
            view;
        });
    }
    return _tagsView;
}


-(UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 1;
            label.text = @"$14.99";
            label.textColor = ZFC0xFE5269();
            label.font = [UIFont boldSystemFontOfSize:14];
            label;
        });
    }
    return _priceLabel;
}

-(ZFRRPLabel *)marketPriceLabel
{
    if (!_marketPriceLabel) {
        _marketPriceLabel = ({
            ZFRRPLabel *label = [[ZFRRPLabel alloc] init];
            label.numberOfLines = 1;
            label.textColor = ZFC0x999999();
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _marketPriceLabel;
}

//-(UILabel *)sizeLabel
//{
//    if (!_sizeLabel) {
//        _sizeLabel = ({
//            UILabel *label = [[UILabel alloc] init];
//            label.numberOfLines = 1;
//            label.textColor = ZFC0x2D2D2D();
//            label.font = [UIFont systemFontOfSize:12];
//            label;
//        });
//    }
//    return _sizeLabel;
//}

- (UIButton *)findRelatedButton {
    if (!_findRelatedButton) {
        _findRelatedButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.layer.cornerRadius = 2;
            button.layer.masksToBounds = YES;
            button.layer.borderColor = ZFC0x2D2D2D().CGColor;
            button.layer.borderWidth = 1;
            button.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
            [button setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
            [button setTitle:ZFLocalizedString(@"cart_unline_findsimilar_tag", nil) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(findRelatedButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _findRelatedButton;
}

- (UIButton *)addCartBagButton {
    if (!_addCartBagButton) {
        _addCartBagButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"community_cart_add"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(addCartBagButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [button setEnlargeEdgeWithTop:20 right:20 bottom:10 left:20];
            button;
        });
    }
    return _addCartBagButton;
}

-(UILabel *)soldOutLabel
{
    if (!_soldOutLabel) {
        _soldOutLabel = ({
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.backgroundColor = ZFCOLOR(0, 0, 0, 0.4f);
            label.textColor = ZFCOLOR_WHITE;
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = ZFLocalizedString(@"cart_soldOut", nil);
            label.numberOfLines = 1;
            label.clipsToBounds = YES;
            label.hidden = YES;
            label;
        });
    }
    return _soldOutLabel;
}

@end
