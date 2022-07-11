//
//  OSSVThemeGoodsItesRankCCell.m
// OSSVThemeGoodsItesRankCCell
//
//  Created by odd on 2021/4/1.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVThemeGoodsItesRankCCell.h"
#import "UIImage+Extend.h"
#import "UIButton+STLCategory.h"


@interface OSSVThemeGoodsItesRankCCell()



@property (nonatomic, strong) YYAnimatedImageView     *rangeImageView;
@property (nonatomic, strong) UILabel                 *rangeLabel;

@property (nonatomic, strong) YYAnimatedImageView     *rangeNumberImageView;
@property (nonatomic, strong) UILabel                 *rangeNumberLabel;

@property (nonatomic, strong) UILabel                 *titleLab;
@property (nonatomic, strong) UILabel                 *priceLabel;
@property (nonatomic, strong) UILabel                 *marketLabel;
@property (nonatomic, strong) UIImageView             *hotImageView;


@property (nonatomic, strong) UIButton                *favourButton;

////折扣标 闪购
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;

@end

@implementation OSSVThemeGoodsItesRankCCell
@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize channelId = _channelId;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.contentView addSubview:self.bgView];
        [self.contentView addSubview:self.goodsImageView];
        [self.contentView addSubview:self.rangeImageView];
        [self.contentView addSubview:self.rangeLabel];
        [self.contentView addSubview:self.rangeNumberImageView];
        [self.contentView addSubview:self.rangeNumberLabel];
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.priceLabel];
        [self.contentView addSubview:self.marketLabel];
        [self.contentView addSubview:self.hotImageView];
        [self.contentView addSubview:self.hotNumLabel];
        [self.contentView addSubview:self.favourButton];
        [self.contentView addSubview:self.favourNumLabel];
        [self.contentView addSubview:self.addCartButton];
        [self.contentView addSubview:self.activityStateView];
        
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.top.mas_equalTo(self.contentView.mas_top).offset(12);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
        
        [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bgView.mas_leading).offset(12);
            make.top.mas_equalTo(self.bgView.mas_top).offset(12);
            make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-12);
            make.width.mas_equalTo(self.goodsImageView.mas_height).multipliedBy(3/4.0);
        }];
        
        [self.rangeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.mas_equalTo(self.bgView);
        }];
        
        [self.rangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.rangeImageView.mas_centerX);
            make.centerY.mas_equalTo(self.rangeImageView.mas_centerY).offset(2);
        }];
        
        [self.rangeNumberImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgView.mas_top).offset(4);
            make.leading.mas_equalTo(self.bgView.mas_leading);
            make.height.mas_equalTo(18);
        }];
        
        [self.rangeNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.rangeNumberImageView.mas_centerY);
            make.leading.mas_equalTo(self.rangeNumberImageView.mas_leading).offset(3);
            make.trailing.mas_equalTo(self.rangeNumberImageView.mas_trailing).offset(-5);
        }];
        
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.goodsImageView.mas_trailing).offset(8);
            make.top.mas_equalTo(self.goodsImageView.mas_top);
            make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-12);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLab.mas_leading);
            make.top.mas_equalTo(self.titleLab.mas_bottom).offset(4);
        }];
        
        
        [self.marketLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.priceLabel.mas_centerY);
            make.leading.mas_equalTo(self.priceLabel.mas_trailing).offset(4);
        }];
        
        [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.priceLabel.mas_top).offset(0);
            make.leading.mas_equalTo(self.marketLabel.mas_trailing).offset(2);
            make.centerY.mas_equalTo(self.priceLabel.mas_centerY);
            make.height.mas_equalTo(12);
        }];
        
        [self.hotImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLab.mas_leading);
            make.bottom.mas_equalTo(self.goodsImageView.mas_bottom);
        }];
        
        [self.hotNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.hotImageView.mas_trailing).offset(2);
            make.centerY.mas_equalTo(self.hotImageView.mas_centerY);
        }];
        
        
        [self.addCartButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-12);
            make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-12);
            make.height.width.mas_equalTo(24);
        }];
        
        /// 这里同上 显示在同一个位置 根据排行类型来显示
        [self.favourButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.addCartButton.mas_leading).offset(-12);
            make.centerY.mas_equalTo(self.addCartButton.mas_centerY);
            make.width.height.mas_equalTo(24);
        }];
        
        [self.favourNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.hotNumLabel.mas_leading);
            make.centerY.mas_equalTo(self.hotImageView.mas_centerY).offset (1);
        }];
        
        [_favourButton.superview layoutIfNeeded];
        [_favourButton setEnlargeEdge:30];
//        [self.bgView stlAddCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(4, 4)];
    }
    return self;
}

#pragma mark - action

- (void)actionAddCart:(UIButton *)sender {
    
    STLHomeCGoodsModel *goodsModel = nil;
    if (self.model && [self.model isKindOfClass:[STLHomeCGoodsModel class]]) {//商品排名集合模块
        goodsModel = (STLHomeCGoodsModel *)self.model;

    } else if(self.model && [self.model isKindOfClass:[OSSVThemeItemsGoodsRanksCCellModel class]]) {//商品列表
        
        OSSVThemeItemsGoodsRanksCCellModel *rankModel = (OSSVThemeItemsGoodsRanksCCellModel *)self.model;
        if ([rankModel.dataSource isKindOfClass:[STLHomeCGoodsModel class]]) {
            goodsModel = (STLHomeCGoodsModel *)rankModel.dataSource;
        }
    }
    
    if (goodsModel && self.delegate && [self.delegate respondsToSelector:@selector(stl_themeGoodsRankCCell:addCart:)]) {
        [self.delegate stl_themeGoodsRankCCell:self addCart:goodsModel];
    }
}

- (void)actionAddWishlist:(UIButton *)sender{
    STLHomeCGoodsModel *goodsModel = nil;
    if (self.model && [self.model isKindOfClass:[STLHomeCGoodsModel class]]) {//商品排名集合模块
        goodsModel = (STLHomeCGoodsModel *)self.model;

    } else if(self.model && [self.model isKindOfClass:[OSSVThemeItemsGoodsRanksCCellModel class]]) {//商品列表
        
        OSSVThemeItemsGoodsRanksCCellModel *rankModel = (OSSVThemeItemsGoodsRanksCCellModel *)self.model;
        if ([rankModel.dataSource isKindOfClass:[STLHomeCGoodsModel class]]) {
            goodsModel = (STLHomeCGoodsModel *)rankModel.dataSource;
        }
    }
    
    if (goodsModel && self.delegate && [self.delegate respondsToSelector:@selector(stl_themeGoodsRankCCell:addWishList:)]) {
        [self.delegate stl_themeGoodsRankCCell:self addWishList:goodsModel];
    }
}

-(void)setHomeGoodsModel:(STLHomeCGoodsModel *)model{
    [self setModel:model];
    
    if (model.ranking != 0) {
        if (model.rankType == 2) {
            self.favourButton.hidden = NO;
            self.favourNumLabel.hidden = NO;
            self.hotImageView.hidden = NO;
            self.hotImageView.image = STLImageWithName(@"wish_selected");
        }else{
            self.hotImageView.hidden = NO;
            self.hotNumLabel.hidden = NO;
            self.hotImageView.image = [UIImage imageNamed:@"sold_hot"];
        }
    }
}

#pragma mark - setter/getter

-(void)setModel:(id<CollectionCellModelProtocol>)model
{
    _model = model;
    self.activityStateView.hidden = YES;
    self.rangeLabel.hidden = YES;
    self.rangeImageView.hidden = YES;
    self.rangeNumberImageView.hidden = YES;
    self.rangeNumberLabel.hidden = YES;
    self.hotImageView.hidden = YES;
    self.hotNumLabel.hidden = YES;
    self.favourButton.hidden = YES;
    self.favourNumLabel.hidden = YES;
    
    self.priceLabel.textColor = [OSSVThemesColors col_0D0D0D];

    STLHomeCGoodsModel *goodsModel = nil;
    
    if (model && [model isKindOfClass:[STLHomeCGoodsModel class]]) {//商品排名集合模块
        goodsModel = (STLHomeCGoodsModel *)model;
        
    } else if(model && [model isKindOfClass:[OSSVThemeItemsGoodsRanksCCellModel class]]) {//商品列表
        
        OSSVThemeItemsGoodsRanksCCellModel *rankModel = (OSSVThemeItemsGoodsRanksCCellModel *)model;
        if ([rankModel.dataSource isKindOfClass:[STLHomeCGoodsModel class]]) {
            goodsModel = (STLHomeCGoodsModel *)rankModel.dataSource;
            
            if (goodsModel.ranking != 0) {
                if (goodsModel.rankType == 2) {
                    self.favourButton.hidden = NO;
                    self.favourNumLabel.hidden = NO;
                    self.hotImageView.hidden = NO;
                    self.hotImageView.image = STLImageWithName(@"wish_selected");
//                    [self.addCartButton setTitle:nil forState:UIControlStateNormal];
//                    [self.addCartButton setImage:STLImageWithName(@"cart_bag") forState:UIControlStateNormal];
//
////                    self.addCartButton.backgroundColor = [OSSVThemesColors stlWhiteColor];
//                    self.addCartButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
                }else{
                    self.hotImageView.hidden = NO;
                    self.hotNumLabel.hidden = NO;
                    self.hotImageView.image = [UIImage imageNamed:@"sold_hot"];
//                    [self.addCartButton setTitle:[STLLocalizedString_(@"addToCart", nil) uppercaseString] forState:UIControlStateNormal];
//                    [self.addCartButton setImage:nil forState:UIControlStateNormal];
                    
//                    self.addCartButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
//                    self.addCartButton.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
                }
            }
        }
    }
    
    if (goodsModel) {
        
        [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:goodsModel.goods_img] placeholder:[UIImage imageNamed:@"ProductImageLogo"]];
        self.titleLab.text = STLToString(goodsModel.goods_title);
        self.priceLabel.text = STLToString(goodsModel.shop_price_converted);
        
        if (STLIsEmptyString(goodsModel.lineMarketPrice.string)) {
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:STLToString(goodsModel.market_price_converted)
                                                                                        attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
            goodsModel.lineMarketPrice = attrStr;
        }
        self.marketLabel.attributedText = goodsModel.lineMarketPrice;
        
        
        ////折扣标 闪购标
        if ([goodsModel.show_discount_icon integerValue] && STLToString(goodsModel.discount).intValue > 0) {
            self.activityStateView.hidden = NO;
            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
            [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(goodsModel.discount)];
        }
        
        if (goodsModel.flash_sale && [goodsModel.flash_sale isOnlyFlashActivity]) {
            self.priceLabel.text = STLToString(goodsModel.flash_sale.active_price_converted);
            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
            self.activityStateView.hidden = NO;
            [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(goodsModel.flash_sale.active_discount)];
        }
        
        self.hotNumLabel.text = [NSString stringWithFormat:@"%@ %@",STLToString(goodsModel.sale_num),STLLocalizedString_(@"theme_orders", nil)];
        
        self.favourButton.selected = goodsModel.is_collect;
        self.favourNumLabel.text = [NSString stringWithFormat:@"%@ %@", STLToString(goodsModel.collect_count), STLLocalizedString_(@"likes", nil)];
        //单列商品排名
        if (goodsModel.ranking != 0) {//显示排序
            if (goodsModel.rankIndex == 1) {
                self.rangeImageView.image = [UIImage imageNamed:@"rank_1"];
                self.rangeImageView.hidden = NO;

            } else if(goodsModel.rankIndex == 2) {
                self.rangeImageView.image = [UIImage imageNamed:@"rank_2"];
                self.rangeImageView.hidden = NO;

            } else if(goodsModel.rankIndex == 3) {
                self.rangeImageView.image = [UIImage imageNamed:@"rank_3"];
                self.rangeImageView.hidden = NO;

            } else if(goodsModel.rankIndex <= 20){
                
                self.rangeImageView.image = [UIImage imageNamed:@"rank_gray"];
                self.rangeLabel.text = [NSString stringWithFormat:@"%ld",goodsModel.rankIndex];
                self.rangeImageView.hidden = NO;
                self.rangeLabel.hidden = NO;
                
            } else {
                
//                self.rangeNumberLabel.text = [NSString stringWithFormat:@"%ld",goodsModel.rankIndex];;
//                self.rangeNumberImageView.hidden = NO;
//                self.rangeNumberLabel.hidden = NO;
            }
        }
    }
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor =  [OSSVThemesColors stlWhiteColor];
        _bgView.layer.cornerRadius = 4;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (YYAnimatedImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[YYAnimatedImageView alloc] init];
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.layer.borderWidth = 0.5;
        _goodsImageView.clipsToBounds = YES;
        _goodsImageView.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
    }
    return _goodsImageView;
}

- (YYAnimatedImageView *)rangeImageView {
    if (!_rangeImageView) {
        _rangeImageView = [[YYAnimatedImageView alloc] init];
        _rangeImageView.contentMode = UIViewContentModeScaleAspectFill;
        _rangeImageView.clipsToBounds = YES;
        _rangeImageView.hidden = YES;
    }
    return _rangeImageView;
}

- (YYAnimatedImageView *)rangeNumberImageView {
    if (!_rangeNumberImageView) {
        _rangeNumberImageView = [[YYAnimatedImageView alloc] init];
        _rangeNumberImageView.image = [UIImage resizeWithImageName:@"rank_bg"];
        [_rangeNumberImageView convertUIWithARLanguage];

        _rangeNumberImageView.hidden = YES;
    }
    return _rangeNumberImageView;
}

- (UILabel *)rangeLabel {
    if (!_rangeLabel) {
        _rangeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _rangeLabel.font = [UIFont boldSystemFontOfSize:10];
        _rangeLabel.textColor = [OSSVThemesColors col_454545];
        _rangeLabel.hidden = YES;
    }
    return _rangeLabel;
}

- (UILabel *)rangeNumberLabel {
    if (!_rangeNumberLabel) {
        _rangeNumberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _rangeNumberLabel.font = [UIFont systemFontOfSize:10];
        _rangeNumberLabel.textColor = [OSSVThemesColors col_454545];
        _rangeNumberLabel.hidden = YES;

    }
    return _rangeNumberLabel;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLab.textColor = [OSSVThemesColors col_666666];
        _titleLab.font = [UIFont systemFontOfSize:11];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLab.textAlignment = NSTextAlignmentRight;
        } else {
            _titleLab.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _titleLab;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _priceLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    return _priceLabel;
}

- (UILabel *)marketLabel {
    if (!_marketLabel) {
        _marketLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _marketLabel.textColor = [OSSVThemesColors col_999999];
        _marketLabel.font = [UIFont systemFontOfSize:11];
    }
    return _marketLabel;
}


- (UIImageView *)hotImageView {
    if (!_hotImageView) {
        _hotImageView = [[UIImageView alloc] init];
        _hotImageView.image = [UIImage imageNamed:@"sold_hot"];
        _hotImageView.hidden = YES;
    }
    return _hotImageView;
}

- (UILabel *)hotNumLabel {
    if (!_hotNumLabel) {
        _hotNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        _hotNumLabel.textColor = OSSVThemesColors.col_B62B21;
        _hotNumLabel.textColor = OSSVThemesColors.col_6C6C6C;
        _hotNumLabel.font = [UIFont boldSystemFontOfSize:11];
        _hotNumLabel.hidden = YES;
    }
    
    return _hotNumLabel;
}

- (UIButton *)favourButton{
    if (!_favourButton) {
        _favourButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_favourButton setBackgroundImage:STLImageWithName(@"wish_unselected") forState:UIControlStateNormal];
//        [_favourButton setBackgroundImage:STLImageWithName(@"wish_selected") forState:UIControlStateSelected];
        [_favourButton setImage:STLImageWithName(@"wish_unselected_big")  forState:UIControlStateNormal];
        [_favourButton setImage:STLImageWithName(@"wish_selected_big") forState:UIControlStateSelected];
        [_favourButton addTarget:self action:@selector(actionAddWishlist:) forControlEvents:UIControlEventTouchUpInside];
        _favourButton.hidden = YES;
    }
    return  _favourButton;
}

- (UILabel *)favourNumLabel{
    if (!_favourNumLabel) {
        _favourNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _favourNumLabel.textColor = [OSSVThemesColors col_666666];
        _favourNumLabel.font = [UIFont boldSystemFontOfSize:11];
        _favourNumLabel.hidden = YES;
    }
    return _favourNumLabel;
}

- (UIButton *)addCartButton {
    if (!_addCartButton) {
        _addCartButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_addCartButton setTitle:[STLLocalizedString_(@"addToCart", nil) uppercaseString] forState:UIControlStateNormal];
        [_addCartButton setImage:[UIImage imageNamed:@"add_to_bag_img"] forState:UIControlStateNormal];
//        _addCartButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
        _addCartButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
//        _addCartButton.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
        [_addCartButton addTarget:self action:@selector(actionAddCart:) forControlEvents:UIControlEventTouchUpInside];
        _addCartButton.layer.cornerRadius = 2;
        _addCartButton.layer.masksToBounds = YES;
    }
    return _addCartButton;
}

- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleNormal];
//        _activityStateView.samllImageShow = 12;
//        _activityStateView.fontSize = 9;
//        _activityStateView.flashImageSize = 12;
        _activityStateView.hidden = YES;
    }
    return _activityStateView;
}
@end
