//
//  OSSVMultiPGoodsSPecialCCell.m
// OSSVMultiPGoodsSPecialCCell
//
//  Created by odd on 2021/1/11.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVMultiPGoodsSPecialCCell.h"

#import "YYLabel.h"
#import "STLCLineLabel.h"
#import "OSSVGoodssPricesView.h"

@interface OSSVMultiPGoodsSPecialCCell ()

@property (nonatomic, strong) YYAnimatedImageView   *goodsImageView;
@property (nonatomic, strong) UIView                *bottomView;
@property (nonatomic, strong) UILabel               *priceLabel;
@property (nonatomic, strong) UILabel               *marketPriceLabel;


@end

@implementation OSSVMultiPGoodsSPecialCCell
@synthesize model = _model;
@synthesize delegate = _delegate;
@synthesize channelId = _channelId;



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self.contentView addSubview:self.goodsImageView];
        [self.contentView addSubview:self.bottomView];
        
        [self.bottomView addSubview:self.priceLabel];
        [self.bottomView addSubview:self.marketPriceLabel];
        [self.contentView addSubview:self.activityStateView];
                
        [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(self.contentView);
            make.height.mas_equalTo(self.goodsImageView.mas_width).multipliedBy(145.0 / 109.0);
        }];
        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.contentView);
            make.top.mas_equalTo(self.goodsImageView.mas_bottom);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.bottomView.mas_centerY).offset(2);
            make.trailing.mas_equalTo(self.bottomView);
            make.leading.mas_equalTo(self.bottomView.mas_leading).offset(4);
        }];
        
        [self.marketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bottomView.mas_centerY).offset(2);
            make.trailing.mas_equalTo(self.bottomView);
            make.leading.mas_equalTo(self.bottomView.mas_leading).offset(4);
        }];
        
        //闪购标签
        [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView.mas_leading);
            make.top.equalTo(self.contentView.mas_top);
        }];
        
    }
    return self;
}

#pragma mark - setter and getter


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
    
    self.activityStateView.hidden = YES;
    if ([_model.dataSource isKindOfClass:[OSSVHomeGoodsListModel class]]) {
        
        OSSVHomeGoodsListModel *goodsModel = (OSSVHomeGoodsListModel *)_model.dataSource;
        
        [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:goodsModel.goodsImageUrl]
                                      placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                          options:kNilOptions
                                       completion:nil];
        
//        NSString *price = [ExchangeManager transforPrice:goodsModel.shop_price];
//        NSString *marketPrice = [ExchangeManager transforPrice:goodsModel.originalMarketPrice];
        NSString *price = STLToString(goodsModel.shop_price_converted);
        NSString *marketPrice = STLToString(goodsModel.market_price_converted);
        self.priceLabel.textColor = [OSSVThemesColors col_0D0D0D];
        self.priceLabel.text = price;
        
        //加一个删除线
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:marketPrice
                                                                                    attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
        self.marketPriceLabel.attributedText = attrStr;
        
        
        ////折扣标 闪购标
        if ([goodsModel.show_discount_icon integerValue] && !STLIsEmptyString(goodsModel.cutOffRate) && [goodsModel.cutOffRate floatValue] > 0) {
            self.activityStateView.hidden = NO;
            [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(goodsModel.cutOffRate)];
            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }
        if (goodsModel.flash_sale && [goodsModel.flash_sale isOnlyFlashActivity]) {
            
            price = goodsModel.flash_sale.active_price_converted;
            self.priceLabel.text = price;
            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
            self.activityStateView.hidden = NO;
            [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(goodsModel.flash_sale.active_discount)];
        }
    }
    
    if ([_model.dataSource isKindOfClass:[STLHomeCGoodsModel class]]) {
        STLHomeCGoodsModel *goodsModel = (STLHomeCGoodsModel *)_model.dataSource;
        
        [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:goodsModel.goods_img]
                                      placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                          options:kNilOptions
                                       completion:nil];
        
//        NSString *price = [ExchangeManager transforPrice:goodsModel.shopPrice];
//        NSString *marketPrice = [ExchangeManager transforPrice:goodsModel.marketPrice];
        
        NSString *price = STLToString(goodsModel.shop_price_converted);
        NSString *marketPrice = STLToString(goodsModel.market_price_converted);
        
        self.priceLabel.textColor = [OSSVThemesColors col_0D0D0D];
        self.priceLabel.text = price;
        
        //加一个删除线
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:marketPrice
                                                                                    attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
        self.marketPriceLabel.attributedText = attrStr;
        
        
        if ([goodsModel.show_discount_icon integerValue] && !STLIsEmptyString(goodsModel.discount) && [goodsModel.discount floatValue] > 0) {
            self.activityStateView.hidden = NO;
            [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(goodsModel.discount)];
            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }
       
        if (goodsModel.flash_sale && !STLIsEmptyString(goodsModel.flash_sale.active_discount) && [goodsModel.flash_sale.active_discount floatValue] > 0) {
            price = goodsModel.flash_sale.active_price_converted;
            self.priceLabel.text = price;
            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
            self.activityStateView.hidden = NO;
            [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(goodsModel.flash_sale.active_discount)];
        }

    }
    
    [self setNeedsDisplay];
}

-(void)setHomeCGoodsModel:(STLHomeCGoodsModel *)goodsModel{
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:goodsModel.goods_img]
                                  placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                      options:kNilOptions
                                   completion:nil];
    
//        NSString *price = [ExchangeManager transforPrice:goodsModel.shopPrice];
//        NSString *marketPrice = [ExchangeManager transforPrice:goodsModel.marketPrice];
    
    NSString *price = STLToString(goodsModel.shop_price_converted);
    NSString *marketPrice = STLToString(goodsModel.market_price_converted);
    
    self.priceLabel.textColor = [OSSVThemesColors col_0D0D0D];
    self.priceLabel.text = price;
    
    //加一个删除线
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:marketPrice
                                                                                attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
    self.marketPriceLabel.attributedText = attrStr;
    
    
    if ([goodsModel.show_discount_icon integerValue] && !STLIsEmptyString(goodsModel.discount) && [goodsModel.discount floatValue] > 0) {
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(goodsModel.discount)];
        self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
    }
   
    if (goodsModel.flash_sale && !STLIsEmptyString(goodsModel.flash_sale.active_discount) && [goodsModel.flash_sale.active_discount floatValue] > 0) {
        price = goodsModel.flash_sale.active_price_converted;
        self.priceLabel.text = price;
        self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(goodsModel.flash_sale.active_discount)];
    }
    [self setNeedsDisplay];
}

#pragma mark - LazyLoad


-(YYAnimatedImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[YYAnimatedImageView alloc] init];
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.clipsToBounds = YES;
    }
    return _goodsImageView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = OSSVThemesColors.col_FFFFFF;
    }
    return _bottomView;
}

- (UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = [OSSVThemesColors col_0D0D0D];
            label.font = [UIFont boldSystemFontOfSize:13];
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                label.textAlignment = NSTextAlignmentRight;
            } else {
                label.textAlignment = NSTextAlignmentLeft;
            }
            label;
        });
    }
    return _priceLabel;
}

-(UILabel *)marketPriceLabel
{
    if (!_marketPriceLabel) {
        _marketPriceLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = OSSVThemesColors.col_999999;
            label.font = [UIFont systemFontOfSize:9];
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                label.textAlignment = NSTextAlignmentRight;
            } else {
                label.textAlignment = NSTextAlignmentLeft;
            }
            label;
        });
    }
    return _marketPriceLabel;
}


- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleVertical];
        _activityStateView.hidden = YES;
    }
    return _activityStateView;
}

@end
