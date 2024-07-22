//
//  ZFOrderShippingV390Cell.m
//  ZZZZZ
//
//  Created by YW on 2018/9/11.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFOrderShippingV390Cell.h"
#import "FilterManager.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "YSAlertView.h"
#import "YWCFunctionTool.h"
#import "ZFBTSManager.h"

@interface ZFOrderShippingV390Cell()

@property (nonatomic, strong) UILabel *shippingNameLabel;
@property (nonatomic, strong) UIButton *shippingPriceLabel;
@property (nonatomic, strong) UILabel *shippingTipsInfoLabel;
@property (nonatomic, strong) UIButton *taxTipsLabel;           ///因为要内外边距，所以使用按钮
@property (nonatomic, strong) UIImageView *arrowImage;
@property (nonatomic, strong) UIButton *tipsButton;
@property (nonatomic, strong) UIView   *separatorLine;
@end

@implementation ZFOrderShippingV390Cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
//        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self.contentView addSubview:self.shippingNameLabel];
        [self.contentView addSubview:self.shippingPriceLabel];
        [self.contentView addSubview:self.shippingTipsInfoLabel];
        [self.contentView addSubview:self.taxTipsLabel];
        [self.contentView addSubview:self.arrowImage];
        [self.contentView addSubview:self.tipsButton];
        [self.contentView addSubview:self.separatorLine];
        
        [self.shippingNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(16);
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(12);
        }];
        
        [self.shippingPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.shippingNameLabel);
            make.leading.mas_equalTo(self.shippingNameLabel.mas_trailing).mas_offset(5);
            make.height.mas_equalTo(self.shippingNameLabel);
        }];
        
        [self.shippingTipsInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.shippingNameLabel.mas_bottom).mas_offset(8);
            make.leading.mas_equalTo(self.shippingNameLabel);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-42);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-16);
        }];
        
        [self.taxTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.shippingNameLabel);
            make.leading.mas_equalTo(self.shippingPriceLabel.mas_trailing).mas_offset(12);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-42);
        }];
        
        [self.arrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
            make.centerY.mas_equalTo(self.contentView);
        }];
        
        [self.tipsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.shippingPriceLabel.mas_trailing).mas_offset(4);
            make.size.mas_equalTo(CGSizeMake(18, 18));
            make.centerY.mas_equalTo(self.shippingPriceLabel.mas_centerY);
        }];
        
        [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.trailing.mas_equalTo(0);
            make.leading.mas_equalTo(12);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.shippingNameLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.shippingNameLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.shippingPriceLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        [self.shippingPriceLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.taxTipsLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    }
    return self;
}

+ (NSString *)queryReuseIdentifier
{
    return NSStringFromClass(self.class);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self zfAddCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(8, 8)];
}

#pragma mark - Action
- (void)showInfo {
    NSString *help = self.model.ship_tips;
    ShowAlertSingleBtnView(nil, help, ZFLocalizedString(@"OK",nil));
}

#pragma mark - setter and getter

-(void)setModel:(ShippingListModel *)model
{
    _model = model;
    
    NSString *price = [FilterManager adapterCodWithAmount:_model.ship_price andCod:self.isCod priceType:PriceType_Insurance];
    
    self.shippingNameLabel.text = [NSString stringWithFormat:@"%@", _model.ship_name];
    self.taxTipsLabel.hidden = !self.isShowTax;
    if (![model.iD isEqualToString:@"1"]) {
        //1 代表 Standard Shipping, 不是Standard就隐藏税号显示显示
        self.taxTipsLabel.hidden = YES;
    }
    
    // 偏远地区邮费提醒
    self.tipsButton.hidden = ZFIsEmptyString(model.ship_tips) ? YES : NO;
    
    if (model.ship_price.floatValue == 0.0) {
        [self.shippingPriceLabel setTitle:ZFLocalizedString(@"OrderInfo_page_free", nil) forState:UIControlStateNormal];
        [self.shippingPriceLabel setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
    } else {
        [self.shippingPriceLabel setTitle:price forState:UIControlStateNormal];
        [self.shippingPriceLabel setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
    }
    
    if (_model.iD.integerValue == 4 && [self.checkOutModel.address_info isCanadaCountry]) {
        //加拿大，且物流为 EXPRESS SHIPPING
        self.shippingTipsInfoLabel.text = ZFLocalizedString(@"CheckOrder_ShippingInfo_CA", nil);
    } else {
        ZFBTSModel *deliverytimeBtsModel = [ZFBTSManager getBtsModel:kZFBtsIosdeliverytime defaultPolicy:@"0"];
        if ([deliverytimeBtsModel.policy isEqualToString:@"1"]) {
            self.shippingTipsInfoLabel.text = model.ship_desc;
        } else {
            self.shippingTipsInfoLabel.text = ZFLocalizedString(@"shipping_info", nil);
        }
    }
    
    if (!self.isCod) {
        self.arrowImage.hidden = NO;
//        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        self.arrowImage.hidden = YES;
//        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

-(UILabel *)shippingNameLabel
{
    if (!_shippingNameLabel) {
        _shippingNameLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = ZFCOLOR(45, 45, 45, 1);
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _shippingNameLabel;
}

-(UIButton *)shippingPriceLabel
{
    if (!_shippingPriceLabel) {
        _shippingPriceLabel = ({
            UIButton *button = [[UIButton alloc] init];
            button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            [button setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
            button.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
            button.userInteractionEnabled = NO;
            button;
        });
    }
    return _shippingPriceLabel;
}

- (UILabel *)shippingTipsInfoLabel
{
    if (!_shippingTipsInfoLabel) {
        _shippingTipsInfoLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = ZFLocalizedString(@"shipping_info", nil);
            label.textColor = ZFCOLOR(153, 153, 153, 1);
            label.font = [UIFont systemFontOfSize:12];
            label.numberOfLines = 2;
            label.preferredMaxLayoutWidth = KScreenWidth - 68;
            [label convertTextAlignmentWithARLanguage];
            label;
        });
    }
    return _shippingTipsInfoLabel;
}

-(UIButton *)taxTipsLabel
{
    if (!_taxTipsLabel) {
        _taxTipsLabel = ({
            UIButton *label = [[UIButton alloc] init];
            [label setTitle:ZFLocalizedString(@"checkout_shipping_tax_remind", nil) forState:UIControlStateNormal];
            [label setTitleColor:ZFC0xFE5269() forState:UIControlStateNormal];
            label.titleLabel.font = [UIFont systemFontOfSize:12];
            label.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
            label.userInteractionEnabled = NO;
            label.layer.borderColor = ZFC0xFE5269().CGColor;
            label.layer.borderWidth = 1;
            label;
        });
    }
    return _taxTipsLabel;
}

- (UIImageView *)arrowImage
{
    if (!_arrowImage) {
        _arrowImage = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.image = [UIImage imageNamed:@"account_arrow_right"];
            [img convertUIWithARLanguage];
            img;
        });
    }
    return _arrowImage;
}

- (UIButton *)tipsButton
{
    if (!_tipsButton) {
        _tipsButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"nationalID"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"nationalID"] forState:UIControlStateSelected];
            button.userInteractionEnabled = YES;
            [button addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
            [button setEnlargeEdge:10];
            button.hidden = YES;
            button;
        });
    }
    return _tipsButton;
}

- (UIView *)separatorLine {
    if (!_separatorLine) {
        _separatorLine = [[UIView alloc] init];
        _separatorLine.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    }
    return _separatorLine;
}

@end
