//
//  ZFOrderDetailOrderGoodsHeaderCell.m
//  ZZZZZ
//
//  Created by YW on 2018/9/20.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFOrderDetailOrderGoodsHeaderCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFOrderDetailOrderGoodsHeaderCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel           *orderNumLabel;
@property (nonatomic, strong) UIButton          *buyAgainButton;
@property (nonatomic, assign) ButtonType         type;
@end

@implementation ZFOrderDetailOrderGoodsHeaderCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)copyCodeButtonAction:(UIButton *)sender {
    if (self.orderDetailOrderBackToCartCompletionHandler) {
        self.orderDetailOrderBackToCartCompletionHandler(self.type);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.orderNumLabel];
    [self.contentView addSubview:self.buyAgainButton];
    
//    UIView *bottomLine = [[UIView alloc] init];
//    bottomLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
//    [self.contentView addSubview:bottomLine];
//    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.trailing.mas_equalTo(self.contentView);
//        make.height.mas_offset(1);
//        make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-1);
//    }];
}

- (void)zfAutoLayoutView {
    [self.orderNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(15);
        make.trailing.mas_equalTo(self.buyAgainButton.mas_leading).offset(-10);
    }];
    
    [self.buyAgainButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
//        make.size.mas_equalTo(CGSizeMake(90, 25));
        make.height.mas_equalTo(25);
    }];
}

#pragma mark - setter
- (void)setModel:(ZFOrderDeatailListModel *)model {
    _model = model;
    
    NSString *item = ZFLocalizedString(@"CartOrderInfo_Goods_Item", nil);
    
    if ([model.child_order count] > 1) {
        item = ZFLocalizedString(@"CartOrderInfo_Goods_Items", nil);
    }
    
    self.orderNumLabel.text = [NSString stringWithFormat:@"%ld %@", [model.child_order count], item];
    if (model.main_order.add_to_cart.integerValue == 1) {
        self.type = ButtonType_BuyAgain;
        self.buyAgainButton.hidden = NO;
    }else{
        self.buyAgainButton.hidden = YES;
    }
    if ([model.main_order isOfflinePayment]) {
        self.buyAgainButton.hidden = NO;
        self.type = ButtonType_OpenOfflineToken;
        NSString *lowPayName = model.main_order.pay_name.lowercaseString;
        if ([lowPayName containsString:@"boleto"]) {
            [self.buyAgainButton setTitle:ZFLocalizedString(@"OrderDetail_TotalPrice_Cell_Check", nil) forState:UIControlStateNormal];
        }
        if ([lowPayName containsString:@"oxxo"]) {
            [self.buyAgainButton setTitle:ZFLocalizedString(@"ABRE TU BOLETA OXXO", nil) forState:UIControlStateNormal];
        }
        NSInteger orderStatus = model.main_order.order_status.integerValue;
        if (orderStatus == 13  || orderStatus == 0) {
            //付款失败或者未付款显示 bugAgain按钮
            self.type = ButtonType_BuyAgain;
            [_buyAgainButton setTitle:ZFLocalizedString(@"ReturnToBag", nil) forState:UIControlStateNormal];
        }
    }
}

#pragma mark - getter
- (UILabel *)orderNumLabel {
    if (!_orderNumLabel) {
        _orderNumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _orderNumLabel.textColor = ZFC0x2D2D2D();
        _orderNumLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _orderNumLabel;
}

- (UIButton *)buyAgainButton {
    if (!_buyAgainButton) {
        _buyAgainButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buyAgainButton setTitle:ZFLocalizedString(@"ReturnToBag", nil) forState:UIControlStateNormal];
        [_buyAgainButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _buyAgainButton.layer.borderWidth = .8f;
        _buyAgainButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        _buyAgainButton.layer.cornerRadius = 2;
        _buyAgainButton.layer.masksToBounds = YES;
        _buyAgainButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_buyAgainButton addTarget:self action:@selector(copyCodeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_buyAgainButton setContentEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    }
    return _buyAgainButton;
}

@end
