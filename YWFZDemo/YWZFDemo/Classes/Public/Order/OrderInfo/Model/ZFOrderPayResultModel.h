//
//  ZFOrderPayResultModel.h
//  ZZZZZ
//
//  Created by YW on 2019/9/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFFiveThModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFOrderPayResultModel : NSObject

@property (nonatomic, copy) NSString *checkoutType;
@property (nonatomic, copy) NSString *completedTime;
@property (nonatomic, copy) NSString *currencyCode;
@property (nonatomic, copy) NSString *currencyRate;
@property (nonatomic, copy) NSString *ebanxUrl;
@property (nonatomic, copy) NSString *errorCode;
@property (nonatomic, copy) NSString *errorMsg;
@property (nonatomic, copy) NSString *feeAmount;
@property (nonatomic, copy) NSString *hasWallet;
@property (nonatomic, copy) NSString *installmentInterestAmount;
@property (nonatomic, copy) NSString *orderPaidAmount;
@property (nonatomic, copy) NSString *parentOrderSn;
@property (nonatomic, copy) NSString *payAmount;
@property (nonatomic, copy) NSString *payChannelCode;
@property (nonatomic, copy) NSString *payChannelName;
@property (nonatomic, copy) NSString *payChannelType;
@property (nonatomic, copy) NSString *payDeductAmount;
@property (nonatomic, copy) NSString *payFailType;
@property (nonatomic, copy) NSString *payPendingType;
@property (nonatomic, copy) NSString *paySn;
@property (nonatomic, copy) NSString *payStatus;
@property (nonatomic, copy) NSString *tradeSn;
@property (nonatomic, copy) NSString *walletAmount;
@property (nonatomic, copy) NSString *walletCurrencyAmount;

///boleto 条形码生成
@property (nonatomic, copy) NSString *boletoBarcodeRaw;
///boleto 付款码
@property (nonatomic, copy) NSString *boletoBarcode;
///boleto 支付本币
@property (nonatomic, copy) NSString *payCurrencyAmount;
///boleto 货币符号
@property (nonatomic, copy) NSString *currencySign;
///boleto 货币符号位置 0 左边 1右边
@property (nonatomic, copy) NSString *currencyPosition;
///boleto 货币币种精度
@property (nonatomic, copy) NSString *exponent;
///boleto 到期时间
@property (nonatomic, copy) NSString *dueDate;

///oxxo 条形码生成
@property (nonatomic, copy) NSString *ebanxBarcodeRaw;

///oxxo 付款码
@property (nonatomic, copy) NSString *ebanxBarcode;

@property (nonatomic, strong) ZFFiveThModel *five_th_info;

- (BOOL)isOXXOPayment;

- (BOOL)isBoletoPayment;

- (BOOL)isPagoefePayment;

@end

NS_ASSUME_NONNULL_END
