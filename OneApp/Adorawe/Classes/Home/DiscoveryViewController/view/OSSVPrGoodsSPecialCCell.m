//
//  OSSVPrGoodsSPecialCCell.m
// OSSVPrGoodsSPecialCCell
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVPrGoodsSPecialCCell.h"
#import "YYLabel.h"
#import "STLCLineLabel.h"
#import "OSSVGoodssPricesView.h"

@interface OSSVPrGoodsSPecialCCell ()

@property (nonatomic, strong) YYAnimatedImageView   *goodsImageView;
@property (nonatomic, strong) OSSVGoodssPricesView     *priceView;
@property (nonatomic, strong) YYAnimatedImageView   *activityTipImgView;
////折扣标 闪购
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;

@property (nonatomic,strong) UILabel *isNewLbl;
@end

@implementation OSSVPrGoodsSPecialCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self.contentView addSubview:self.goodsImageView];
        [self.contentView addSubview:self.priceView];
        [self.contentView addSubview:self.activityTipImgView];
        [self.contentView addSubview:self.activityStateView];
        
        CGFloat imageHeight = frame.size.height - kHomeCellBottomViewHeight;
        
        [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(self.contentView);
            make.height.mas_offset(imageHeight);
        }];
        
        [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.leading.trailing.mas_equalTo(self.contentView);
            make.height.mas_equalTo(kHomeCellBottomViewHeight);
        }];
        
        [self.activityTipImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(@0);
            make.bottom.equalTo(self.goodsImageView.mas_bottom);
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
        
    }
    return self;
}

#pragma mark - setter and getter

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


- (void)setModel:(OSSVProGoodsCCellModel *)model
{
    _model = model;
    
    CGFloat imageHeight = self.frame.size.height - kHomeCellBottomViewHeight;
    self.activityStateView.hidden = YES;
    if (APP_TYPE == 3) {
        self.priceView.originalPriceLabel.hidden = YES;
    }
    if ([_model.dataSource isKindOfClass:[OSSVHomeGoodsListModel class]]) {
        
        OSSVHomeGoodsListModel *goodsModel = (OSSVHomeGoodsListModel *)_model.dataSource;
        
        [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:goodsModel.goodsImageUrl]
                                      placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                          options:kNilOptions
                                       completion:nil];
        
        self.priceView.priceLabel.textColor = [OSSVThemesColors col_0D0D0D];
        imageHeight = self.frame.size.height - goodsModel.goodsListPriceHeight;
        [self.priceView price:STLToString(goodsModel.shop_price_converted)
                originalPrice:STLToString(goodsModel.market_price_converted)
                  activityMsg:STLToString(goodsModel.tips_reduction)
               activityHeight:goodsModel.goodsListFullActitityHeight
                        title:STLToString(goodsModel.goodsTitle)];
        
        [self.priceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(goodsModel.goodsListPriceHeight);
        }];
        
        NSString *markImgUrlStr = STLToString(goodsModel.markImgUrl);
        if (markImgUrlStr.length) {
            self.activityTipImgView.hidden = NO;
            [self.activityTipImgView yy_setImageWithURL:[NSURL URLWithString:markImgUrlStr] placeholder:nil];
        }else {
            self.activityTipImgView.hidden = YES;
        }
        
        ////折扣标 闪购标
        BOOL isDiscount = [goodsModel.show_discount_icon integerValue] && !STLIsEmptyString(goodsModel.cutOffRate) && [goodsModel.cutOffRate floatValue] > 0;
        if (isDiscount) {
            self.activityStateView.hidden = NO;
            [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(goodsModel.cutOffRate)];
            if (APP_TYPE == 3) {
                self.priceView.priceLabel.textColor = OSSVThemesColors.col_9F5123;
                self.priceView.originalPriceLabel.hidden = NO;
            } else {
                self.priceView.priceLabel.textColor = OSSVThemesColors.col_B62B21;
            }
        }
        BOOL isFlashSale = goodsModel.flash_sale && [goodsModel.flash_sale isOnlyFlashActivity];
        if (isFlashSale) {
            self.priceView.priceLabel.text = STLToString(goodsModel.flash_sale.active_price_converted);
            if (APP_TYPE == 3) {
                self.priceView.priceLabel.textColor = OSSVThemesColors.col_9F5123;
                self.priceView.originalPriceLabel.hidden = NO;
            } else {
                self.priceView.priceLabel.textColor = OSSVThemesColors.col_B62B21;
            }
            self.activityStateView.hidden = NO;
            [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(goodsModel.flash_sale.active_discount)];
        }
        
        if (!isDiscount && !isFlashSale){
            self.isNewLbl.hidden = goodsModel.is_new != 1;
        }
    }
    
    if ([_model.dataSource isKindOfClass:[STLHomeCGoodsModel class]]) {
        STLHomeCGoodsModel *goodsModel = (STLHomeCGoodsModel *)_model.dataSource;
        
        [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:goodsModel.goods_img]
                                      placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                          options:kNilOptions
                                       completion:nil];
        
        
        self.priceView.priceLabel.textColor = [OSSVThemesColors col_0D0D0D];
        
        imageHeight = self.frame.size.height - goodsModel.goodsListPriceHeight;
        [self.priceView price:STLToString(goodsModel.shop_price_converted)
                originalPrice:STLToString(goodsModel.market_price_converted)
                  activityMsg:STLToString(goodsModel.tips_reduction)
               activityHeight:goodsModel.goodsListFullActitityHeight
                        title:STLToString(goodsModel.goods_title)];
        
        [self.priceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(goodsModel.goodsListPriceHeight);
        }];
        
        NSString *markImgUrlStr = STLToString(goodsModel.mark_img);
        if (markImgUrlStr.length) {
            self.activityTipImgView.hidden = NO;
            [self.activityTipImgView yy_setImageWithURL:[NSURL URLWithString:markImgUrlStr] placeholder:nil];
        }else {
            self.activityTipImgView.hidden = YES;
        }
        
        BOOL isDiscount = [goodsModel.show_discount_icon integerValue] && !STLIsEmptyString(goodsModel.discount) && [goodsModel.discount floatValue] > 0;
        if (isDiscount) {
            self.activityStateView.hidden = NO;
            [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(goodsModel.discount)];
            if (APP_TYPE == 3) {
                self.priceView.priceLabel.textColor = OSSVThemesColors.col_9F5123;
                self.priceView.originalPriceLabel.hidden = NO;
            } else {
                self.priceView.priceLabel.textColor = OSSVThemesColors.col_B62B21;
            }
        }
       
        BOOL isFlashSale = goodsModel.flash_sale && !STLIsEmptyString(goodsModel.flash_sale.active_discount) && [goodsModel.flash_sale.active_discount floatValue] > 0;
        if (isFlashSale) {
            self.priceView.priceLabel.text = STLToString(goodsModel.flash_sale.active_price_converted);
            if (APP_TYPE == 3) {
                self.priceView.priceLabel.textColor = OSSVThemesColors.col_9F5123;
                self.priceView.originalPriceLabel.hidden = NO;
            } else {
                self.priceView.priceLabel.textColor = OSSVThemesColors.col_B62B21;
            }
            self.activityStateView.hidden = NO;
            [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(goodsModel.flash_sale.active_discount)];
        }
        
        if (!isDiscount && !isFlashSale){
            self.isNewLbl.hidden = goodsModel.is_new != 1;
        }

    }
    [self.goodsImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(imageHeight);
    }];
    
    [self setNeedsDisplay];
}

-(YYAnimatedImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[YYAnimatedImageView alloc] init];
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _goodsImageView.clipsToBounds = YES;
    }
    return _goodsImageView;
}

- (OSSVGoodssPricesView *)priceView {
    if (!_priceView) {
        _priceView = [[OSSVGoodssPricesView alloc] initWithFrame:CGRectZero isShowIcon:NO];
//        _priceView.backgroundColor = [UIColor orangeColor];
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
        _activityStateView.backgroundColor = [UIColor clearColor];
    }
    return _activityStateView;
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

-(void)prepareForReuse{
    [super prepareForReuse];
    self.isNewLbl.hidden = YES;
}

@end
