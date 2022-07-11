//
//  OSSVCategorysSpecialssCCell.m
// XStarlinkProject
//
//  Created by odd on 2020/9/15.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategorysSpecialssCCell.h"
#import "STLCLineLabel.h"
#import "OSSVGoodssPricesView.h"

@interface OSSVCategorysSpecialssCCell ()

@property (nonatomic, strong) YYAnimatedImageView         *contentImageView; // 内容图片
//@property (nonatomic, strong) UIView                      *bottomBackView; // 底部背景View
//@property (nonatomic, strong) UILabel                     *priceLabel; // 现价
//@property (nonatomic, strong) STLCLineLabel               *originalPriceLabel; // 原价
//活动水印标签
@property (nonatomic, strong) YYAnimatedImageView           *activityTipImgView;
////折扣标 闪购
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;
@property (nonatomic, strong) OSSVGoodssPricesView     *priceView;


@end

@implementation OSSVCategorysSpecialssCCell


+ (OSSVCategorysSpecialssCCell *)categorySpecialCCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [collectionView registerClass:[OSSVCategorysSpecialssCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVCategorysSpecialssCCell.class)];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVCategorysSpecialssCCell.class) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self.contentView addSubview:self.contentImageView];
//        [self.contentView addSubview:self.bottomBackView];
        [self.contentView addSubview:self.activityTipImgView];
        [self.contentView addSubview:self.activityStateView];
        [self.contentView addSubview:self.priceView];

//        [self.bottomBackView addSubview:self.priceLabel];
//        [self.bottomBackView addSubview:self.originalPriceLabel];

        
//        CGFloat imageHeight = frame.size.height - kHomeCellBottomViewHeight;
        
        [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make){
//            make.top.and.leading.and.trailing.mas_equalTo(@0);
            make.leading.trailing.top.mas_equalTo(self.contentView);
//            make.height.mas_offset(imageHeight);
        }];
        
        [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentImageView.mas_bottom);
            make.bottom.leading.trailing.mas_equalTo(self.contentView);
            make.height.mas_equalTo(kHomeCellBottomViewHeight);
        }];

        [self.activityTipImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(@0);
            make.bottom.equalTo(self.contentImageView.mas_bottom);
            make.height.equalTo(@(24*kScale_375));
        }];

        //闪购标签
        if (APP_TYPE == 3) {
            [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.contentView.mas_leading).offset(6);
                make.top.equalTo(self.contentView.mas_top).offset(6);
            }];
        } else {
            [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.contentView.mas_leading);
                make.top.equalTo(self.contentView.mas_top);
            }];
        }
        

        
//        [self.bottomBackView mas_makeConstraints:^(MASConstraintMaker *make){
//            make.bottom.and.leading.and.trailing.mas_equalTo(@0);
//            make.height.mas_equalTo(@(kHomeCellBottomViewHeight));
//            make.top.equalTo(self.contentImageView.mas_bottom);
//        }];
        
        
        //-----------------------------------------------------------//
        
        
//        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make){
//            make.top.mas_equalTo(self.bottomBackView.mas_top).offset(8);
//            make.trailing.mas_equalTo(self.bottomBackView);
//            make.leading.mas_equalTo(self.bottomBackView.mas_leading).offset(8);
//        }];
//
//        [self.originalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make){
//            make.bottom.mas_equalTo(self.bottomBackView.mas_bottom).offset(-8);
//            make.trailing.mas_equalTo(self.bottomBackView);
//            make.leading.mas_equalTo(self.bottomBackView.mas_leading).offset(8);
//        }];
        

    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (!_activityStateView.isHidden && _activityStateView.size.height > 0) {
        
        if (APP_TYPE == 3) {
            
        } else {
            
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
            } else {
                [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
            }
        }
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.contentImageView yy_cancelCurrentImageRequest];
    self.contentImageView.image = nil;
}

+ (CGFloat)categorySpecialCCellRowHeightOneModel:(OSSVThemeZeroPrGoodsModel *)model twoModel:(OSSVThemeZeroPrGoodsModel *)twoModel {
    
    if (APP_TYPE == 3) {
        
        if (model.goods_img_w == 0) {
            return 0.01;
        }
        
        //满减活动
        CGFloat activityHeight = model.goodsListFullActitityHeight;
        CGFloat onefullHeight = model.goodsListPriceHeight;
        CGFloat oneMaxHeight = 0;

        if (!(model.flash_sale && [model.flash_sale isOnlyFlashActivity]) && !model.hadHandlePriceHeight) {
            model.hadHandlePriceHeight = YES;
            activityHeight = [OSSVGoodssPricesView activithHeight:model.tips_reduction contentWidth:kGoodsWidth];
            onefullHeight = [OSSVGoodssPricesView contentHeight:activityHeight];
            model.goodsListPriceHeight = onefullHeight;
            model.goodsListFullActitityHeight = activityHeight;
        }
        
//        if (model.goods_img_w == 0 || model.goods_img_h == 0) {
            oneMaxHeight = kGoodsWidth + onefullHeight;
//        } else {
//            oneMaxHeight = kGoodsWidth / model.goods_img_w * model.goods_img_h + onefullHeight;
//        }
        
        CGFloat twofullHeight = 0;
        CGFloat twoMaxHeight = 0;

        if (twoModel) {
            twofullHeight = twoModel.goodsListPriceHeight;
            CGFloat twoActivityHeight = twoModel.goodsListFullActitityHeight;
            
            if (!(twoModel.flash_sale && [twoModel.flash_sale isOnlyFlashActivity]) && !twoModel.hadHandlePriceHeight) {
                twoModel.hadHandlePriceHeight = YES;
                twoActivityHeight = [OSSVGoodssPricesView activithHeight:twoModel.tips_reduction contentWidth:kGoodsWidth];
                twofullHeight = [OSSVGoodssPricesView contentHeight:twoActivityHeight];
                twoModel.goodsListPriceHeight = twofullHeight;
                twoModel.goodsListFullActitityHeight = twoActivityHeight;
            }
            
            
//            if (twoModel.goods_img_w == 0 || twoModel.goods_img_h == 0) {
                twoMaxHeight = kGoodsWidth + twofullHeight;
//            } else {
//                twoMaxHeight = kGoodsWidth / twoModel.goods_img_w * twoModel.goods_img_h + twofullHeight;
//            }
            
            if (twoMaxHeight > oneMaxHeight) {
                model.goodsListPriceHeight = twofullHeight;
                model.goodsListFullActitityHeight = twoActivityHeight;
            } else {
                twoModel.goodsListPriceHeight = onefullHeight;
                twoModel.goodsListFullActitityHeight = activityHeight;
            }
        }
        CGFloat maxFullHeight = MAX(oneMaxHeight, twoMaxHeight);
        return maxFullHeight;
    }
    
    if (model.goods_img_w == 0) {
        return 0.01;
    }
    
    //满减活动
    CGFloat fullHeight = model.goodsListPriceHeight;
    if (!(model.flash_sale && [model.flash_sale isOnlyFlashActivity]) && !model.hadHandlePriceHeight) {
        model.hadHandlePriceHeight = YES;
        CGFloat activityHeight = [OSSVGoodssPricesView activithHeight:model.tips_reduction contentWidth:kGoodsWidth];
        fullHeight = [OSSVGoodssPricesView contentHeight:activityHeight];
        model.goodsListPriceHeight = fullHeight;
        model.goodsListFullActitityHeight = activityHeight;
    }
    if (model.goods_img_w == 0 || model.goods_img_h == 0) {
        return kGoodsWidth * 4.0 / 3.0 + fullHeight;
    }
    return kGoodsWidth / model.goods_img_w * model.goods_img_h + fullHeight;
}

#pragma mark - LazyLoad

- (void)setModel:(OSSVThemeZeroPrGoodsModel *)model {
    _model = model;

    [self.contentImageView yy_setImageWithURL:[NSURL URLWithString:model.goods_img]
                                  placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                      options:kNilOptions
                                     progress:nil
                                    transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                                return image;
                                            }
                                   completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
    }];

    if (APP_TYPE == 3) {
        self.priceView.originalPriceLabel.hidden = YES;
    }
    //0元商品会返回exchange_price_converted 这个字段
    if (STLIsEmptyString(model.exchange_price_converted)) {
        
        self.priceView.priceLabel.textColor = OSSVThemesColors.col_0D0D0D;
        [self.priceView price:STLToString(model.shop_price_converted)
                originalPrice:STLToString(model.market_price_converted)
                  activityMsg:STLToString(model.tips_reduction)
               activityHeight:model.goodsListFullActitityHeight
                        title:STLToString(model.goods_title)];

        [self.priceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(model.goodsListPriceHeight);
        }];
    } else {
        self.priceView.priceLabel.textColor = [OSSVThemesColors col_E63D2E];
        [self.priceView price:STLToString(model.exchange_price_converted)
                originalPrice:STLToString(model.shop_price_converted)
                  activityMsg:@""
               activityHeight:model.goodsListFullActitityHeight
                        title:STLToString(model.goods_title)];

        [self.priceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(model.goodsListPriceHeight);
        }];

    }
    
    self.activityStateView.hidden = YES;
    // 是否显示 折扣icon,
    if ([model.show_discount_icon integerValue] && [model.discount integerValue] > 0 && [model.discount integerValue] < 100) {
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(model.discount)];
        if (APP_TYPE == 3) {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_9F5123;
            self.priceView.originalPriceLabel.hidden = NO;
        }
    }
    
    //////折扣标 闪购标
    if (model.flash_sale && [model.flash_sale isOnlyFlashActivity]) {
        
        self.priceView.priceLabel.text = STLToString(model.flash_sale.active_price_converted);
        if (APP_TYPE == 3) {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_9F5123;
            self.priceView.originalPriceLabel.hidden = NO;
        } else {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_E63D2E;
        }
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(model.flash_sale.active_discount)];
    }

    //水印
    if (!STLIsEmptyString(model.mark_img)) {
        self.activityTipImgView.hidden = NO;
        [self.activityTipImgView yy_setImageWithURL:[NSURL URLWithString:STLToString(model.mark_img)] placeholder:nil];
    }else {
        self.activityTipImgView.hidden = YES;
    }
    
    [self setNeedsDisplay];

}


- (YYAnimatedImageView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView = [[YYAnimatedImageView alloc] init];
        _contentImageView.userInteractionEnabled = YES;
        /**
         此处是否后期需要调整呢？目前此处是这样理解和处理的
         UIViewContentModeCenter是为了让 placeholder 的正常显示，
         clipsToBounds = YES，为了防止图片溢出
         但是，当图片的宽或者高比frame的宽高更小的时候，可能出现空白的情况。
         背景颜色，暂时这样设置，后期可以删掉
         
         */
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView.clipsToBounds = YES;
        _contentImageView.backgroundColor = [UIColor whiteColor];
    }
    return _contentImageView;
}


//- (UIView *)bottomBackView {
//    if (!_bottomBackView) {
//        _bottomBackView = [[UIView alloc] init];
//        _bottomBackView.backgroundColor = [UIColor whiteColor];
//    }
//    return _bottomBackView;
//}

//- (UILabel *)priceLabel {
//    if (!_priceLabel) {
//        _priceLabel = [[UILabel alloc] init];
//        _priceLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
//        _priceLabel.font = [UIFont boldSystemFontOfSize:15];
//        _priceLabel.textColor = [OSSVThemesColors col_E63D2E];
//        _priceLabel.adjustsFontSizeToFitWidth = YES;
//    }
//    return _priceLabel;
//}
//
//- (STLCLineLabel *)originalPriceLabel {
//    if (!_originalPriceLabel) {
//        _originalPriceLabel = [[STLCLineLabel alloc] init];
//        _originalPriceLabel.font = [UIFont systemFontOfSize:11];
//        _originalPriceLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
//        _originalPriceLabel.textColor = [OSSVThemesColors col_999999];
//        _originalPriceLabel.adjustsFontSizeToFitWidth = YES;
//    }
//    return _originalPriceLabel;
//}

- (YYAnimatedImageView *)activityTipImgView {
    if (!_activityTipImgView) {
        _activityTipImgView = [YYAnimatedImageView new];
        _activityTipImgView.backgroundColor = [UIColor clearColor];
    }
    return _activityTipImgView;
}

- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleVertical];
        _activityStateView.hidden = YES;
    }
    return _activityStateView;
}

- (OSSVGoodssPricesView *)priceView {
    if (!_priceView) {
        _priceView = [[OSSVGoodssPricesView alloc] initWithFrame:CGRectZero isShowIcon:NO];
    }
    return _priceView;
}

@end
