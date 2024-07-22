//
//  ZFPaySuccessDetailCell.m
//  ZZZZZ
//
//  Created by YW on 7/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFPaySuccessDetailCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "NSStringUtils.h"

@interface ZFPaySuccessDetailCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel   *peopleLabel;
//@property (nonatomic, strong) UILabel   *phoneLabel;
@property (nonatomic, strong) UILabel   *addressLabel;
@property (nonatomic, strong) UILabel   *accountLabel;
@property (nonatomic, strong) UIButton  *orderListButton;
@property (nonatomic, strong) UIButton  *homeButton;

//COD确认地址
@property (nonatomic, strong) UIView *tipConentView;
@property (nonatomic, strong) UILabel *codCheckAddressLabel;

//拆单提示
@property (nonatomic, strong) UILabel *partHintLabel;

//offline 视图
@property (nonatomic, strong) UIView *containView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIButton *checkTokenButton;   ///查看线下token按钮
@end

@implementation ZFPaySuccessDetailCell
+ (instancetype)detailCellWith:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    self.selectionStyle = UITableViewCellSeparatorStyleNone;
    [self.contentView addSubview:self.peopleLabel];
//    [self.contentView addSubview:self.phoneLabel];
    [self.contentView addSubview:self.addressLabel];
    [self.contentView addSubview:self.accountLabel];
    [self.contentView addSubview:self.orderListButton];
    [self.contentView addSubview:self.homeButton];
    
    [self.contentView addSubview:self.containView];
    [self.containView addSubview:self.tipsLabel];
    [self.containView addSubview:self.checkTokenButton];
    
    [self.contentView addSubview:self.tipConentView];
    [self.tipConentView addSubview:self.codCheckAddressLabel];
    [self.contentView addSubview:self.partHintLabel];
}

- (void)zfAutoLayoutView {
    [self.peopleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
        make.top.mas_equalTo(12);
    }];
    
//    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(self.peopleLabel.mas_trailing).offset(5);
//        make.centerY.equalTo(self.peopleLabel);
//    }];
    
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.peopleLabel.mas_leading);
        make.top.equalTo(self.peopleLabel.mas_bottom).offset(2);
        make.trailing.mas_equalTo(-2);
    }];
    
    [self.accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.peopleLabel.mas_leading);
        make.top.equalTo(self.addressLabel.mas_bottom).offset(2);
        make.trailing.mas_equalTo(-2);
    }];
    
    // COD地址确认提示
    [self.tipConentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.accountLabel.mas_bottom).offset(12);
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-12);
    }];
    
    [self.codCheckAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(8, 12, 8, 12));
    }];
    
    // 拆单提示
    [self.partHintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipConentView.mas_bottom).offset(12);
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-12);
    }];
    
    //offline 视图
    {
        [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(12);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
            make.top.mas_equalTo(self.partHintLabel.mas_bottom).mas_offset(24);
        }];
        
        [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containView.mas_top).mas_offset(12);
            make.leading.mas_equalTo(self.containView.mas_leading).mas_offset(12);
            make.trailing.mas_equalTo(self.containView.mas_trailing).mas_offset(-12);
        }];
        
        [self.checkTokenButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tipsLabel.mas_bottom).mas_offset(12);
            make.centerX.mas_equalTo(self.containView);
            make.height.mas_offset(36);
            make.bottom.mas_equalTo(self.containView.mas_bottom).mas_offset(-12);
        }];
    }
    
    CGFloat buttonWidth = (KScreenWidth - 12 * 3) / 2.0;
    
    [self.orderListButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.peopleLabel.mas_leading);
        make.top.equalTo(self.containView.mas_bottom).offset(24);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-22);
        make.size.mas_equalTo(CGSizeMake(buttonWidth, 35));
    }];
    
    [self.homeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.orderListButton);
        make.size.mas_equalTo(CGSizeMake(buttonWidth, 35));
    }];
}

#pragma mark - Action
- (void)buttonClick:(UIButton *)sender {
    if (self.buttonHandler) {
        self.buttonHandler(sender);
    }
}

- (void)checkTokenButtonClick
{
    if (self.checkTokenButtonHandler) {
        self.checkTokenButtonHandler();
    }
}

#pragma mark - Setter
- (void)setModel:(ZFPaySuccessModel *)model {
    _model = model;
    if (!_model) {
        return;
    }
    NSString *userInfo = [NSString stringWithFormat:@"%@  %@", model.user_name, model.phone];
    self.peopleLabel.attributedText = [self queryTitle:[NSString stringWithFormat:@"%@:",ZFLocalizedString(@"People", nil)] value:userInfo];
//    self.phoneLabel.text = model.phone;
    self.addressLabel.attributedText = [self queryTitle:[NSString stringWithFormat:@"%@:",ZFLocalizedString(@"Address", nil)] value:model.address];
    
    NSString *payName = nil;
    if ([model.pay_name isEqualToString:@"Cod"]) {
        payName = [NSString stringWithFormat:@"%@:",ZFLocalizedString(@"GoodsSortViewController_Type_COD", nil)];
    }else{
        payName = [NSString stringWithFormat:@"%@:",ZFLocalizedString(@"TotalPrice_Cell_GrandTotal", nil)];
    }
    self.accountLabel.attributedText = [self queryTitle:payName value:model.account];
    
    // COD地址确认
    if (model.confirm_btn_show) {
        self.tipConentView.hidden = NO;
    } else {
        self.tipConentView.hidden = YES;
        [self.tipConentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
            make.top.mas_equalTo(self.accountLabel.mas_bottom);
        }];
    }
    
    // 拆单
    if (!ZFIsEmptyString(model.order_part_hint)) {
        self.partHintLabel.text = model.order_part_hint;
        self.partHintLabel.hidden = NO;
    } else {
        self.partHintLabel.hidden = YES;
        [self.partHintLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tipConentView.mas_bottom);
            make.height.mas_equalTo(0);
        }];
    }
    
    if (ZFIsEmptyString(_model.offlineLink)) {
        self.checkTokenButton.hidden = YES;
        self.containView.hidden = YES;
        self.tipsLabel.hidden = YES;
        //不是线下支付，显示正常视图
        CGFloat buttonWidth = (KScreenWidth - 12 * 3) / 2.0;
        [self.orderListButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.peopleLabel.mas_leading);
            make.top.equalTo(self.partHintLabel.mas_bottom).offset(24);
            make.bottom.mas_equalTo(-22);
            make.size.mas_equalTo(CGSizeMake(buttonWidth, 35));
        }];
        
        [self.homeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.orderListButton);
            make.size.mas_equalTo(CGSizeMake(buttonWidth, 35));
        }];
    } else {
        self.checkTokenButton.hidden = NO;
        self.containView.hidden = NO;
        self.tipsLabel.hidden = NO;
        
        if ([_model.offlineLink containsString:@"oxxo"]) {
            // oxxo 文案
            [self.checkTokenButton setTitle:@"Imprimir info oxxo" forState:UIControlStateNormal];
            self.tipsLabel.text = @"Ahora debería :Recuerde sus códigos de pago y pague su pedido en la tienda OXXO más cercana. Recuerde que su vale OXXO vence en tres días.";
        } else {
            // boleto
            [self.checkTokenButton setTitle:@"Imprima o boleto" forState:UIControlStateNormal];
            self.tipsLabel.text = @"Pagar-lo em qualquer banco, loja de loteria ou em seu Bancário na Internet, você tem 1-3 dias  para completar seu pagamento.";
        }
   
        CGFloat buttonWidth = (KScreenWidth - 12 * 3) / 2.0;
        [self.orderListButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.peopleLabel.mas_leading);
            make.top.equalTo(self.containView.mas_bottom).offset(24);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-22);
            make.size.mas_equalTo(CGSizeMake(buttonWidth, 35));
        }];
        
        [self.homeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.orderListButton);
            make.size.mas_equalTo(CGSizeMake(buttonWidth, 35));
        }];
    }
}

#pragma mark - Private method
- (NSMutableAttributedString *)queryTitle:(NSString *)title value:(NSString *)value {
    NSString *content = [title stringByAppendingString:[NSString stringWithFormat:@" %@",value]];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:content];
    NSRange range = [content rangeOfString:title];
    [attString addAttribute:NSForegroundColorAttributeName value:ZFCOLOR(153, 153, 153, 1) range:range];
    return attString;
}

#pragma mark - Getter
- (UILabel *)peopleLabel {
    if (!_peopleLabel) {
        _peopleLabel = [[UILabel alloc] init];
        _peopleLabel.font = ZFFontSystemSize(14);
        _peopleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _peopleLabel.numberOfLines = 0;
    }
    return _peopleLabel;
}

//- (UILabel *)phoneLabel {
//    if (!_phoneLabel) {
//        _phoneLabel = [[UILabel alloc] init];
//        _phoneLabel.font = ZFFontSystemSize(14);
//        _phoneLabel.textColor = ZFCOLOR(45, 45, 45, 1);
//    }
//    return _phoneLabel;
//}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [[UILabel alloc] init];
        _addressLabel.font = ZFFontSystemSize(14);
        _addressLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _addressLabel.numberOfLines = 0;
        _addressLabel.preferredMaxLayoutWidth = KScreenWidth - 24;
    }
    return _addressLabel;
}

- (UILabel *)accountLabel {
    if (!_accountLabel) {
        _accountLabel = [[UILabel alloc] init];
        _accountLabel.font = ZFFontSystemSize(14);
        _accountLabel.textColor = ZFCOLOR(45, 45, 45, 1);
    }
    return _accountLabel;
}

- (UIButton *)orderListButton {
    if (!_orderListButton) {
        _orderListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _orderListButton.layer.cornerRadius = 2;
        _orderListButton.layer.masksToBounds = YES;
        _orderListButton.backgroundColor = ZFC0x2D2D2D();
        [_orderListButton setTitle:ZFLocalizedString(@"orderListButton", nil) forState:UIControlStateNormal];
        [_orderListButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        _orderListButton.titleLabel.font = ZFFontSystemSize(14);
        _orderListButton.tag = OrderFinishActionTypeOrderList;
        [_orderListButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _orderListButton;
}

- (UIButton *)homeButton {
    if (!_homeButton) {
        _homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _homeButton.layer.cornerRadius = 2;
        _homeButton.layer.masksToBounds = YES;
        _homeButton.backgroundColor = ZFCOLOR_WHITE;
        [_homeButton setTitle:ZFLocalizedString(@"homeButton", nil) forState:UIControlStateNormal];
        _homeButton.titleLabel.font = ZFFontSystemSize(14);
        [_homeButton setTitleColor:ZFCOLOR_BLACK forState:UIControlStateNormal];
        [_homeButton showCurrentViewBorder:0.5 color:ZFCOLOR_BLACK];
        _homeButton.tag = OrderFinishActionTypeHome;
        [_homeButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _homeButton;
}

- (UIView *)containView
{
    if (!_containView) {
        _containView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = ZFC0xF2F2F2();
            view;
        });
    }
    return _containView;
}

-(UILabel *)tipsLabel
{
    if (!_tipsLabel) {
        _tipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = @"Pague em qualquer banco, casas lotéricas ou em sua pelo seu banco na online, você tem 3 dias para completar seu pagamento.";
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentLeft;
            label;
        });
    }
    return _tipsLabel;
}

-(UIButton *)checkTokenButton
{
    if (!_checkTokenButton) {
        _checkTokenButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = ZFC0x2D2D2D();
            [button setTitle:@"Verifique o Boleto Bancario" forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
            [button addTarget:self action:@selector(checkTokenButtonClick) forControlEvents:UIControlEventTouchUpInside];
            button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
            button.layer.cornerRadius = 2;
            button.layer.masksToBounds = YES;
            button;
        });
    }
    return _checkTokenButton;
}

- (UIView *)tipConentView {
    if (!_tipConentView) {
        _tipConentView = [[UIView alloc] init];
        _tipConentView.backgroundColor = ColorHex_Alpha(0xFEF0F2, 1.0);
        _tipConentView.hidden = YES;
    }
    return _tipConentView;
}

- (UILabel *)codCheckAddressLabel {
    if (!_codCheckAddressLabel) {
        _codCheckAddressLabel = [[UILabel alloc] init];
        _codCheckAddressLabel.font = [UIFont systemFontOfSize:12];
        _codCheckAddressLabel.textColor = ZFCOLOR(254, 82, 105, 1);
        _codCheckAddressLabel.numberOfLines = 0;
        _codCheckAddressLabel.text = ZFLocalizedString(@"OrderSucess_Address_tips", nil);
    }
    return _codCheckAddressLabel;
}

- (UILabel *)partHintLabel {
    if (!_partHintLabel) {
        _partHintLabel = [[UILabel alloc] init];
        _partHintLabel.font = [UIFont systemFontOfSize:12];
        _partHintLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        _partHintLabel.numberOfLines = 0;
        _partHintLabel.hidden = YES;
    }
    return _partHintLabel;
}

@end
