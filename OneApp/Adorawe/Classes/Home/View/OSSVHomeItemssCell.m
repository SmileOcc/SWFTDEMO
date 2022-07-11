//
//  HomeItemCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeItemssCell.h"
#import "OSSVHomeGoodsListModel.h"
#import "STLCLineLabel.h"
#import "CommendModel.h"
#import "OSSVGoodssPricesView.h"
#import "UIButton+STLCategory.h"

@interface OSSVHomeItemssCell ()

@property (nonatomic, strong) OSSVGoodssPricesView           *priceView; // 底部背景View


//活动水印标签
@property (nonatomic, strong) YYAnimatedImageView           *activityTipImgView;
////折扣标 闪购
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;

@property (nonatomic,strong) UILabel *isNewLbl;
@end

@implementation OSSVHomeItemssCell

+ (OSSVHomeItemssCell *)homeItemCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [collectionView registerClass:[OSSVHomeItemssCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVHomeItemssCell.class)];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVHomeItemssCell.class) forIndexPath:indexPath];
}

+ (CGFloat)homeItemRowHeightForHomeGoodListModel:(OSSVHomeGoodsListModel *)model {
    
    if (!model) {
        return kGoodsWidth * 4.0 / 3.0 + kHomeCellBottomViewHeight;

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

+ (CGFloat)homeItemRowHeightOneModel:(OSSVHomeGoodsListModel *)model twoModel:(OSSVHomeGoodsListModel *)twoModel{
    
    if (APP_TYPE == 3) {
        
        if (!model) {
            return kGoodsWidth + kHomeCellBottomViewHeight;

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
        
        //满减活动
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
        
    } else {
        if (!model) {
            return kGoodsWidth * 4.0 / 3.0 + kHomeCellBottomViewHeight;

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
    
}


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self.contentView addSubview:self.contentImageView];
        [self.contentView addSubview:self.priceView];
        [self.contentView addSubview:self.activityTipImgView];
        
        [self.contentView addSubview:self.activityStateView];
        
        [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.and.leading.and.trailing.mas_equalTo(@0);
        }];
        
        [self.priceView mas_makeConstraints:^(MASConstraintMaker *make){
            make.bottom.and.leading.and.trailing.mas_equalTo(@0);
            make.height.mas_equalTo(@(kHomeCellBottomViewHeight));
            make.top.equalTo(self.contentImageView.mas_bottom);
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
        
        
        [self.contentView addSubview:self.collecBtn];
        [self.collecBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentImageView.mas_bottom).offset(6);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-6);
        }];
        
        [self.contentView addSubview:self.isNewLbl];
        
        CGSize size = [self.isNewLbl sizeThatFits:CGSizeMake(MAXFLOAT, 18)];
        if (APP_TYPE == 3) {
            [self.isNewLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(self.contentView.mas_leading).offset(6);
                make.top.equalTo(self.contentView.mas_top).offset(6);
                make.height.equalTo(16);
                make.size.width.equalTo(size.width + 7);
            }];
        } else {
            [self.isNewLbl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.top.equalTo(self.contentView);
                make.height.equalTo(18);
                make.size.width.equalTo(size.width + 7);
            }];
        }
        
        [self.collecBtn setEnlargeEdgeWithTop:8 right:8 bottom:10 left:10];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.contentImageView yy_cancelCurrentImageRequest];
    self.contentImageView.image = nil;
    self.isNewLbl.hidden = YES;
}

//标签不需要圆角了

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    if (!_activityStateView.isHidden && _activityStateView.size.height > 0) {
//
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
//        } else {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
//        }
//    }
//}

- (void)collectAction:(UIButton *)sender{
    if (self.collectBlock) {
        self.collectBlock(_model);
    }
}

#pragma mark - LazyLoad

- (void)setModel:(OSSVHomeGoodsListModel *)model {
    _model = model;
    [self.contentImageView yy_setImageWithURL:[NSURL URLWithString:model.goodsImageUrl]
                                  placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                      options:kNilOptions
                                     progress:nil
                                    transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
//                                                if (model.goods_img_w > 0 && model.goods_img_h > 0) {
//                                                    image = [image yy_imageByResizeToSize:CGSizeMake(kGoodsWidth, kGoodsWidth / model.goods_img_w * model.goods_img_h) contentMode:UIViewContentModeScaleAspectFit];
//                                                }
                                                
                                                return image;
                                            }
                                   completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
    }];

    self.priceView.priceLabel.textColor = [OSSVThemesColors col_0D0D0D];
    [self.priceView price:STLToString(model.shop_price_converted) originalPrice:STLToString(model.market_price_converted) activityMsg:STLToString(model.tips_reduction) activityHeight:model.goodsListFullActitityHeight title:STLToString(model.goodsTitle)];
    
    [self.priceView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(model.goodsListPriceHeight);
    }];
    self.activityStateView.hidden = YES;    
    // 是否显示 折扣icon, 同时防止后台返回莫名其妙 cutOffRate 数据过来
    BOOL isDiscount = [model.show_discount_icon integerValue] && [model.cutOffRate integerValue] > 0 && [model.cutOffRate integerValue] < 100;
    if (APP_TYPE == 3) {    
        self.priceView.originalPriceLabel.hidden = YES;
    }
    if (isDiscount) {
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(model.cutOffRate)];
        if (APP_TYPE == 3) {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_9F5123;
            self.priceView.originalPriceLabel.hidden = NO;
        } else {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }
    }
    
    //////折扣标 闪购标
    BOOL isFlashSale = model.flash_sale && [model.flash_sale isOnlyFlashActivity];
    if (isFlashSale) {
        
        if (APP_TYPE == 3) {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_9F5123;
            self.priceView.originalPriceLabel.hidden = NO;
        } else {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }
        self.priceView.priceLabel.text = STLToString(model.flash_sale.active_price_converted);
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(model.flash_sale.active_discount)];
    }
    
    if (!isDiscount && !isFlashSale){
        self.isNewLbl.hidden = model.is_new != 1;
    }
    
    NSString *markImgUrlStr = STLToString(model.markImgUrl);
    if (markImgUrlStr.length) {
        self.activityTipImgView.hidden = NO;
        [self.activityTipImgView yy_setImageWithURL:[NSURL URLWithString:markImgUrlStr] placeholder:nil];
    }else {
        self.activityTipImgView.hidden = YES;
    }
    
    self.collecBtn.hidden = NO;
    if (model.is_collect) {
        self.collecBtn.selected = YES;
    }else{
        self.collecBtn.selected = NO;
    }
   
}

- (void)setCommendModel:(CommendModel *)commendModel {
    _commendModel = commendModel;
    
    
//    NSString *imageUrl = !STLIsEmptyString(commendModel.coverImgUrl) ? commendModel.coverImgUrl : commendModel.goodsBigImg;
    NSString *imageUrl = commendModel.goodsBigImg;
//    @weakify(self)
    [self.contentImageView yy_setImageWithURL:[NSURL URLWithString:imageUrl]
                                  placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                      options:kNilOptions
                                     progress:nil
                                    transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                        return image;
                                    }
                                   completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                          
//                                            if (image) {
//
//                                                CGFloat flatW = image.size.width;
//                                                CGFloat flatH = image.size.height;
//                                                if (flatH > flatW) {
//                                                    flatH = kGoodsWidth * 4 / 3.0;
//                                                    flatW = flatH / 4.0 * 3.0;
//                                                } else {
//                                                    flatW = kGoodsWidth;
//                                                    flatH = flatW * 4 / 3.0;
//                                                }
//
//                                                image = [image yy_imageByResizeToSize:CGSizeMake(flatW, flatH) contentMode:UIViewContentModeScaleAspectFit];;
//                                                @strongify(self)
//                                                self.contentImageView.image = image;
//                                            }
                                   }];
    self.priceView.priceLabel.text = STLToString(commendModel.shop_price_converted);
    self.priceView.originalPriceLabel.text = STLToString(commendModel.market_price_converted);
    self.priceView.titleLabel.text = STLToString(commendModel.goodsTitle);
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
        _contentImageView.autoresizesSubviews = YES;
        _contentImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
   
        _contentImageView.clipsToBounds = YES;
        _contentImageView.backgroundColor = [UIColor whiteColor];
    }
    return _contentImageView;
}

- (OSSVGoodssPricesView *)priceView {
    if (!_priceView) {
        _priceView = [[OSSVGoodssPricesView alloc] initWithFrame:CGRectZero isShowIcon:YES];
        _priceView.backgroundColor = [UIColor whiteColor];
    }
    return _priceView;
}

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

- (UIButton *)collecBtn{
    if (!_collecBtn) {
        _collecBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collecBtn setImage:[UIImage imageNamed:@"goods_like18"] forState:UIControlStateNormal];
        [_collecBtn setImage:[UIImage imageNamed:@"goods_liked18"] forState:UIControlStateSelected];
        [_collecBtn addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];
        _collecBtn.hidden = YES;
    }
    return _collecBtn;
}

-(UILabel *)isNewLbl{
    if (!_isNewLbl) {
        _isNewLbl = [UILabel new];
        if (APP_TYPE == 3) {
            _isNewLbl.font = [UIFont systemFontOfSize:10];
            _isNewLbl.backgroundColor = OSSVThemesColors.stlWhiteColor;
            _isNewLbl.textColor = OSSVThemesColors.col_26652C;
        } else {
            _isNewLbl.font = [UIFont boldSystemFontOfSize:12];
            _isNewLbl.backgroundColor = OSSVThemesColors.col_60CD8E;
            _isNewLbl.textColor = UIColor.whiteColor;
        }
        _isNewLbl.text = STLLocalizedString_(@"new_goods_mark", nil).uppercaseString;
        _isNewLbl.textAlignment = NSTextAlignmentCenter;
        _isNewLbl.hidden = YES;
    }
    return _isNewLbl;
}

@end
