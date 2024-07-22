//
//  ZFOrderDetailOrderPriceInfoTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderDetailOrderPriceInfoTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "FilterManager.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "AccountManager.h"

@interface ZFOrderDetailOrderPriceInfoTableViewCell() <ZFInitViewProtocol>

@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *priceLabel;
@property (nonatomic, strong) UIView                *topLine;

@end

@implementation ZFOrderDetailOrderPriceInfoTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - private methods
- (NSString *)showCurrency:(NSString *)price {
    NSString *priceString;
    priceString = [ExchangeManager transAppendPrice:price currency:self.model.main_order.order_currency rateModel:self.model.main_order.order_exchange];
    return priceString;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.topLine];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
        make.leading.mas_equalTo(self.contentView).offset(12);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-15);
    }];
    
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-14);
        make.height.mas_offset(1);
    }];
}

#pragma mark - setter
- (void)setPriceModel:(ZFOrderDetailPriceModel *)priceModel {
    _priceModel = priceModel;

    NSString *student = ZFLocalizedString(@"OrderInfo_priceList_student_discount", nil);
    NSInteger studentLevel = [AccountManager sharedManager].account.student_level;
    if (studentLevel == 2) {
        //超级学生优惠
        student = ZFLocalizedString(@"OrderInfo_priceList_supermeStudent_discount", nil);
    }
    
    NSArray *textList = @[ZFLocalizedString(@"OrderInfo_priceList_subtotal_total", nil),
                          ZFLocalizedString(@"OrderInfo_priceList_deliver", nil),
                          ZFLocalizedString(@"OrderInfo_priceList_insurance", nil),
                          ZFLocalizedString(@"OrderInfo_priceList_cod_fee", nil),
                          ZFLocalizedString(@"OrderInfo_priceList_online_payment_discount", nil),
                          student,
                          ZFLocalizedString(@"OrderInfo_priceList_event_discount", nil),
                          ZFLocalizedString(@"OrderInfo_priceList_coupon_discount", nil),
                          ZFLocalizedString(@"OrderInfo_priceList_zpoints", nil),
                          ZFLocalizedString(@"OrderInfo_priceList_grandTotal", nil),
                          ZFLocalizedString(@"OrderInfo_priceList_cod", nil),
                          ZFLocalizedString(@"Account_Wallet", nil),
                          ZFLocalizedString(@"ZFPaymentOnline", nil)];

    if (_priceModel.type < textList.count) {
        self.titleLabel.text = textList[_priceModel.type];
    }
    
    if (_priceModel.type == ZFOrderDetailPriceTypeWallet || _priceModel.type == ZFOrderDetailPriceTypeOnlinePayment) {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.priceLabel.font = [UIFont boldSystemFontOfSize:14];
    } else {
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.priceLabel.font = [UIFont systemFontOfSize:14];
    }
    
    if (_priceModel.type == ZFOrderDetailPriceTypeWallet) {
        self.topLine.hidden = NO;
    } else {
        self.topLine.hidden = YES;
    }
}

- (void)setModel:(ZFOrderDeatailListModel *)model {
    _model = model;
    OrderDetailOrderModel *orderModel = model.main_order;
    self.priceLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
    switch (self.priceModel.type) {
        case ZFOrderDetailPriceTypeProductTotal:
        {
            self.priceLabel.text = [self showCurrency:orderModel.subtotal];
            NSString *totalString = ZFLocalizedString(@"OrderInfo_priceList_subtotal_total", nil);
            NSString *items = ZFLocalizedString(@"CartOrderInfo_Goods_Items", nil);
            if (self.model.totalGoodsNums == 1) {
                items = ZFLocalizedString(@"CartOrderInfo_Goods_Item", nil);
            }
            totalString = [NSString stringWithFormat:@"%@ (%ld %@)", totalString, self.model.totalGoodsNums, items];
            self.titleLabel.text = totalString;
        }
            break;
        case ZFOrderDetailPriceTypeShipping:
            if (orderModel.shipping_fee.floatValue > 0) {
                self.priceLabel.attributedText = nil;
                self.priceLabel.text = [self showCurrency:orderModel.shipping_fee];
            } else {
                self.priceLabel.text = nil;
                self.priceLabel.attributedText = [self boldAttriString:ZFLocalizedString(@"OrderInfo_page_free", nil)];
            }
            break;
        case ZFOrderDetailPriceTypeInsurance:
            self.priceLabel.text = [self showCurrency:orderModel.insure_fee];
            break;
        case ZFOrderDetailPriceTypeCodCost:
        {
            if (orderModel.formalities_fee.floatValue > 0) {
                self.priceLabel.attributedText = nil;
                self.priceLabel.text = [self showCurrency:orderModel.formalities_fee];
            } else {
                self.priceLabel.text = nil;
                self.priceLabel.attributedText = [self boldAttriString:ZFLocalizedString(@"OrderInfo_page_free", nil)];
            }
        }
            break;
        case ZFOrderDetailPriceTypeEventDiscount:
            self.priceLabel.textColor = ZFC0xFE5269();
            self.priceLabel.text = [NSString stringWithFormat:@"-%@", [self showCurrency:orderModel.other_discount]];
            break;
        case ZFOrderDetailPriceTypeCoupon:
            self.priceLabel.textColor = ZFC0xFE5269();
            self.priceLabel.text = [NSString stringWithFormat:@"-%@", [self showCurrency:orderModel.coupon]];
            break;
        case ZFOrderDetailPriceTypeZPoints:
            self.priceLabel.textColor = ZFC0xFE5269();
            self.priceLabel.text = [NSString stringWithFormat:@"-%@", [self showCurrency:orderModel.z_point]];
            break;
        case ZFOrderDetailPriceTypeGrandTotal:
            self.priceLabel.text = [self showCurrency:orderModel.grand_total];
            break;
        case ZFOrderDetailPriceTypeCODDiscount:         
            if ([orderModel.cod_orientation integerValue] == CashOnDeliveryTruncTypeUp) { //向上取整
                self.titleLabel.text = ZFLocalizedString(@"OrderInfo_priceList_insurance_discount", nil);
                self.priceLabel.text =  [NSString stringWithFormat:@"+%@", [self showCurrency:orderModel.cod_discount]];
            } else {    //向下取整
                self.priceLabel.textColor = ZFC0xFE5269();
                self.titleLabel.text = ZFLocalizedString(@"OrderInfo_priceList_cod", nil);
                self.priceLabel.text =  [NSString stringWithFormat:@"-%@", [self showCurrency:orderModel.cod_discount]];
            }
            break;
        case ZFOrderDetailPriceTypeStudentDiscount:
            self.priceLabel.textColor = ZFC0xFE5269();
            self.priceLabel.text = [NSString stringWithFormat:@"-%@", [self showCurrency:orderModel.student_discount]];
            break;
        case ZFOrderDetailPriceTypeOnlinePayDiscount:
            self.priceLabel.textColor = ZFC0xFE5269();
            self.priceLabel.text = [NSString stringWithFormat:@"-%@", [self showCurrency:orderModel.pay_deduct]];
            break;
        case ZFOrderDetailPriceTypeOnlinePayment:
            self.priceLabel.textColor = ZFCOLOR_BLACK;
            self.priceLabel.text = [NSString stringWithFormat:@"%@", [self showCurrency:orderModel.online_payment]];
            break;
        case ZFOrderDetailPriceTypeWallet:
            self.priceLabel.textColor = ZFCOLOR_BLACK;
            self.priceLabel.text = [NSString stringWithFormat:@"-%@", [self showCurrency:orderModel.used_wallet]];
            break;
        default:
            break;
    }
}

- (NSAttributedString *)boldAttriString:(NSString *)value
{
    NSDictionary *attribtDic = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14]};
    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc] initWithString:value attributes:attribtDic];
    return attribtStr.copy;
}

#pragma mark - getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont systemFontOfSize:14];
         _priceLabel.textAlignment = NSTextAlignmentRight;
    }
    return _priceLabel;
}

- (UIView *)topLine
{
    if (!_topLine) {
        _topLine = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = ZFC0xDDDDDD();
            view.hidden = YES;
            view;
        });
    }
    return _topLine;
}


@end
