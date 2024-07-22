//
//  ZFOrderShippingListCell.m
//  ZZZZZ
//
//  Created by YW on 19/10/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderShippingListCell.h"
#import "ZFInitViewProtocol.h"
#import "FilterManager.h"
#import "ShippingListModel.h"
#import "ZFLabel.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "YSAlertView.h"
#import "YWCFunctionTool.h"
#import "ZFBTSManager.h"

@interface ZFOrderShippingListCell()<ZFInitViewProtocol>
@property (nonatomic, strong) UIButton              *selectButton;
@property (nonatomic, strong) UILabel               *infoLabel;
@property (nonatomic, strong) UIButton              *amountLabel;
@property (nonatomic, strong) ZFLabel               *recommendLabel;
@property (nonatomic, strong) UIButton              *tipsButton;
@property (nonatomic, strong) UILabel               *deliverytimeLabel;  // 物流时效
@property (nonatomic, strong) MASConstraint         *deliverytimeLabelHeightCons;
@end

@implementation ZFOrderShippingListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - Public method
+ (NSString *)queryReuseIdentifier {
    return NSStringFromClass([self class]);
}

#pragma mark - Setter
- (void)setIsChoose:(BOOL)isChoose {
    _isChoose = isChoose;
    self.selectButton.selected = isChoose;
}

- (void)setShippingListModel:(ShippingListModel *)shippingListModel {
    _shippingListModel = shippingListModel;
    ZFBTSModel *deliverytimeBtsModel = [ZFBTSManager getBtsModel:kZFBtsIosdeliverytime defaultPolicy:@"0"];
    if ([deliverytimeBtsModel.policy isEqualToString:@"1"]) {
        self.deliverytimeLabel.hidden = NO;
        self.deliverytimeLabelHeightCons.mas_equalTo(18);
        self.infoLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        self.infoLabel.text = shippingListModel.ship_name;
        self.deliverytimeLabel.text = shippingListModel.ship_desc;
    } else {
        self.deliverytimeLabel.hidden = YES;
        self.deliverytimeLabelHeightCons.mas_equalTo(0);
        self.infoLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        self.infoLabel.text = [NSString stringWithFormat:@"%@(%@)",shippingListModel.ship_name,shippingListModel.ship_desc];
        self.deliverytimeLabel.text = nil;
    }
    
    if (shippingListModel.ship_price.floatValue == 0.0) {
        [self.amountLabel setTitle:ZFLocalizedString(@"OrderInfo_page_free", nil) forState:UIControlStateNormal];
        [self.amountLabel setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        self.amountLabel.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    } else {
        [self.amountLabel setTitleColor:ZFCOLOR(51, 51, 51, 1) forState:UIControlStateNormal];
        NSString *title = [FilterManager adapterCodWithAmount:shippingListModel.ship_price andCod:self.isCod priceType:PriceType_ShippingCost];
        [self.amountLabel setTitle:title forState:UIControlStateNormal];
        self.amountLabel.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    self.recommendLabel.hidden = [shippingListModel.default_select boolValue] ? NO : YES;
    
    // 偏远地区邮费提醒
    self.tipsButton.hidden = ZFIsEmptyString(shippingListModel.ship_tips) ? YES : NO;
    
    /* 暂时不需要用到,请不要删除
        self.recommendLabel.text = [NSString stringWithFormat:@"(%@%% %@)",shippingListModel.ship_save,ZFLocalizedString(@"CartOrderInfo_ShippingMethodSubCell_Cell_OFF",nil)];
     */
}

#pragma mark - Action
- (void)showInfo {
    NSString *help = self.shippingListModel.ship_tips;
    ShowAlertSingleBtnView(nil, help, ZFLocalizedString(@"OK",nil));
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    self.contentView.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    [self.contentView addSubview:self.selectButton];
    [self.contentView addSubview:self.infoLabel];
    [self.contentView addSubview:self.amountLabel];
    [self.contentView addSubview:self.recommendLabel];
    [self.contentView addSubview:self.tipsButton];
    [self.contentView addSubview:self.deliverytimeLabel];
}

- (void)zfAutoLayoutView {
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading).offset(12);
        make.top.equalTo(self.contentView).offset(12);
    }];
    
    [self.deliverytimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.top.mas_equalTo(self.infoLabel.mas_bottom).offset(1.5);
        self.deliverytimeLabelHeightCons = make.height.mas_equalTo(0);
        make.trailing.mas_equalTo(self.selectButton.mas_leading).offset(5);
    }];
    
    [self.amountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.infoLabel.mas_leading);
        make.top.equalTo(self.deliverytimeLabel.mas_bottom).offset(1.5);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
    
    [self.recommendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.amountLabel.mas_trailing).offset(8);
        make.centerY.equalTo(self.amountLabel);
    }];
    
    [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.tipsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.amountLabel.mas_trailing).mas_offset(4);
        make.size.mas_equalTo(CGSizeMake(18, 18));
        make.centerY.mas_equalTo(self.amountLabel.mas_centerY);
    }];
}

#pragma mark - Getter
- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setImage:[UIImage imageNamed:@"order_unchoose"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"order_choose"] forState:UIControlStateSelected];
        _selectButton.userInteractionEnabled = NO;
    }
    return _selectButton;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.font = [UIFont systemFontOfSize:14];
        _infoLabel.textColor = ZFC0x2D2D2D();
    }
    return _infoLabel;
}

- (UIButton *)amountLabel {
    if (!_amountLabel) {
        _amountLabel = [[UIButton alloc] init];
        _amountLabel.titleLabel.font = [UIFont systemFontOfSize:14];
        [_amountLabel setTitleColor:ZFCOLOR(51, 51, 51, 1) forState:UIControlStateNormal];
    }
    return _amountLabel;
}

- (ZFLabel *)recommendLabel {
    if (!_recommendLabel) {
        _recommendLabel = [[ZFLabel alloc] init];
        _recommendLabel.font = ZFFontSystemSize(12);
        _recommendLabel.textColor = ZFC0xFE5269();
        _recommendLabel.layer.borderColor = ZFC0xFE5269().CGColor;
        _recommendLabel.layer.borderWidth = 1;
        _recommendLabel.layer.cornerRadius = 2;
        _recommendLabel.layer.masksToBounds = YES;
//        _recommendLabel.backgroundColor = ZFC0xFE5269();
        _recommendLabel.edgeInsets = UIEdgeInsetsMake(1, 6, 1, 6);
        _recommendLabel.text = ZFLocalizedString(@"GoodsSortViewController_Type_Recommend", nil);
        _recommendLabel.hidden = YES;
    }
    return _recommendLabel;
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

- (UILabel *)deliverytimeLabel {
    if (!_deliverytimeLabel) {
        _deliverytimeLabel = [[UILabel alloc] init];
        _deliverytimeLabel.font = [UIFont systemFontOfSize:12];
        _deliverytimeLabel.textColor = ZFCOLOR(153, 153, 153, 1);
    }
    return _deliverytimeLabel;
}

@end
