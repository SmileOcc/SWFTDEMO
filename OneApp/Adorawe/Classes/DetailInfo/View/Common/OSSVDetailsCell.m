//
//  OSSVDetailsCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailsCell.h"
#import "STLCLineLabel.h"
#import "OSSVGoodssPricesView.h"
@interface OSSVDetailsCell ()

@property (nonatomic, strong) YYAnimatedImageView   *contentImageView; // 商品图片
@property (nonatomic, strong) OSSVGoodssPricesView     *priceView; // 价格容器
@property (nonatomic, strong) STLCLineLabel         *originalPriceLabel; // 原价
@property (nonatomic, strong) YYAnimatedImageView   *activityTipImgView; //商品活动水印标签
@property (nonatomic, strong) UIButton              *collectButton;   //收藏按钮
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView *activityStateView;
@end

@implementation OSSVDetailsCell

+(OSSVDetailsCell*)goodsDetailsCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[OSSVDetailsCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVDetailsCell.class)];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVDetailsCell.class) forIndexPath:indexPath];
}

#pragma mark
#pragma mark - Initialize subView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        
        [self.contentView addSubview:self.contentImageView];
        
        [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.top.and.leading.and.trailing.mas_equalTo(@0);
        }];
        
        
        [self.contentView addSubview:self.activityStateView];

        //闪购标签
        [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView.mas_leading);
            make.top.equalTo(self.contentView.mas_top);
        }];
        
       
        [self.contentView addSubview:self.priceView];
        
        [self.priceView mas_makeConstraints:^(MASConstraintMaker *make){
            make.bottom.and.leading.and.trailing.mas_equalTo(@0);
            make.height.mas_equalTo(@(kHomeCellBottomViewHeight));
            make.top.equalTo(self.contentImageView.mas_bottom);
        }];
        
        //收藏按钮
        [self.contentView addSubview:self.collectButton];
        [self.collectButton  mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentImageView.mas_trailing).mas_offset(@(-8));
            make.top.mas_equalTo(self.contentImageView.mas_bottom).mas_offset(@(8));
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];

        
        [self.contentImageView addSubview:self.activityTipImgView];
        [self.activityTipImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.contentImageView);
            make.bottom.equalTo(self.contentImageView.mas_bottom);
            make.height.equalTo(@(24*kScale_375));
        }];
    }
    return self;
}

- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleNormal];
//        _activityStateView.samllImageShow = YES;
//        _activityStateView.flashImageSize = 17;
//        _activityStateView.fontSize = 12;
        _activityStateView.hidden = YES;
    }
    return _activityStateView;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
//    if (!_activityStateView.isHidden && _activityStateView.size.height > 0) {
        
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
//        } else {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
//        }
//    }
}

#pragma mark ----收藏按钮
-(void)collectionGood:(UIButton *)sender {
    
    if (_delegate &&[_delegate respondsToSelector:@selector(userCollectAction:buttonSelected:)]) {
        [_delegate userCollectAction:self.model buttonSelected:sender];
    }
}
#pragma mark - Returns the height of each cell
+ (CGFloat)recommendItemRowHeightForGoodsDetailsRecommendArrayModel:(OSSVGoodsListModel *)model {
    
    if (model.goods_img_w > 0) {
        
        CGFloat fullHeight = model.goodsListPriceHeight;
        //满减活动
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
        return kGoodsWidth / model.goods_img_w  * model.goods_img_h  + fullHeight;
    }
    return 0.01;
}

#pragma mark - Set Model
- (void)setModel:(OSSVGoodsListModel *)model {
    _model = model;
    // 商品图片
    [self.contentImageView yy_setImageWithURL:[NSURL URLWithString:model.goodsImg]
                                  placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                      options:kNilOptions
                                     progress:nil
                                    transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                            if (model.goods_img_w > 0 && model.goods_img_h > 0) {
                                                image = [image yy_imageByResizeToSize:CGSizeMake(kGoodsWidth, kGoodsWidth / model.goods_img_w  * model.goods_img_h) contentMode:UIViewContentModeScaleAspectFill];
                                            }
                                    
                                                return image;
                                            }
                                   completion:nil];
    [self.priceView price:STLToString(model.shop_price_converted)
            originalPrice:STLToString(model.market_price_converted)
              activityMsg:STLToString(model.tips_reduction)
           activityHeight:model.goodsListFullActitityHeight
                    title:STLToString(model.goodsTitle)];
    
    [self.priceView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(model.goodsListPriceHeight);
    }];
    
    if (APP_TYPE == 3) {
        self.priceView.originalPriceLabel.hidden = YES;
    }
    //////折扣标 闪购标
    self.activityStateView.hidden = YES;
    if ([model.show_discount_icon integerValue] == 1 && !STLIsEmptyString(model.discount) && [model.discount floatValue] > 0) {
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(model.discount)];
        if (APP_TYPE == 3) {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_9F5123;
            self.priceView.originalPriceLabel.hidden = NO;
        } else {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }
    } else if (model.flash_sale && [model.flash_sale isOnlyFlashActivity]) {
        self.priceView.priceLabel.text = STLToString(model.flash_sale.active_price_converted);
        if (APP_TYPE == 3) {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_9F5123;
            self.priceView.originalPriceLabel.hidden = NO;
        } else {
            self.priceView.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(model.flash_sale.active_discount)];
    } else {
        self.priceView.priceLabel.text = STLToString(model.shop_price_converted);
        self.priceView.priceLabel.textColor = [OSSVThemesColors col_0D0D0D];
    }
    
    if (STLToString(model.markImgUrlString).length) {
        self.activityTipImgView.hidden = NO;
        [self.activityTipImgView yy_setImageWithURL:[NSURL URLWithString:STLToString(model.markImgUrlString)] placeholder:nil];
    } else {
        self.activityTipImgView.hidden = YES;
    }
    
    //收藏按钮是否为选中状态
    NSInteger isCollect =  STLToString(model.isCollect).integerValue;
    if (isCollect == 1) {
        self.collectButton.selected = YES;
    } else {
        self.collectButton.selected = NO;
    }
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.contentImageView yy_cancelCurrentImageRequest];
    self.contentImageView.image = nil;
    self.originalPriceLabel.text = nil;
}


- (YYAnimatedImageView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView = [[YYAnimatedImageView alloc] init];
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView.clipsToBounds = YES;
        _contentImageView.userInteractionEnabled = YES;
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

-(YYAnimatedImageView *)activityTipImgView {
    if (!_activityTipImgView) {
        _activityTipImgView = [[YYAnimatedImageView alloc] init];
        _activityTipImgView.backgroundColor = [UIColor clearColor];
    }
    return _activityTipImgView;
}

- (UIButton *)collectButton {
    if (!_collectButton) {
        _collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collectButton setBackgroundImage:[UIImage imageNamed:@"flash_collectIcon_gray"] forState:UIControlStateNormal];
        [_collectButton setBackgroundImage:[UIImage imageNamed:@"flash_collectIcon_red"] forState:UIControlStateSelected];
        [_collectButton addTarget:self action:@selector(collectionGood:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _collectButton;
}

@end

