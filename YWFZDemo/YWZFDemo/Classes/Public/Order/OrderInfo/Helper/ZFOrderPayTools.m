//
//  ZFOrderPayTools.m
//  ZZZZZ
//
//  Created by YW on 2018/10/31.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFOrderPayTools.h"
#import <GGPaySDK/GGPaySDK.h>
#import "ZFPaymentViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFOrderInformationViewModel.h"
#import "ZFContactUsViewController.h"
#import "YWLocalHostManager.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "YSAlertView.h"
#import "ZFThemeManager.h"
#import "ZFActionSheetView.h"
#import "ZFRequestModel.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFWebViewViewController.h"

@interface ZFOrderPayTools()

@end

@implementation ZFOrderPayTools

+(instancetype)paytools
{
    ZFOrderPayTools *tools = [[self alloc] init];
    return tools;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.payModel = 1;
        self.channel = PayChannel_PayModel;
        self.walletPasswordUrl = @"";
    }
    return self;
}

#pragma mark - public method

-(void)startPay
{
    //判断使用原生支付还是H5支付，需要后台返回的数据和 ADHOC两个数据同时判断
    if (self.channel == PayChannel_PayModel) {
        //payModel   1:使用原生支付模式 0:使用H5支付模式
        if (self.payModel == 1) {
            //使用原生支付
            [self showNativePay];
        }else {
            //使用H5支付
            [self showH5Pay];
        }
    }else{
        [self showDefaultPay];
    }
}

#pragma mark - private method

- (void)showNativePay
{
    GGPaySDKConfiguration *configuration = [GGPaySDKConfiguration shareConfiguration];
    configuration.merchantName = @"ZZZZZ";
    if (![YWLocalHostManager isOnlineRelease]) {
        configuration.merchantIdentifier = @"merchant.ZZZZZ.TEST";
    }else{
        configuration.merchantIdentifier = @"merchant.ZZZZZ";
    }
    configuration.baseLocalizeable = @"en";
    
    configuration.UIConfiguration.customUIAlertBlock = ^(GGPaySDKUIAlertConfiguration * _Nonnull alertConfiguration) {
        
        NSString *sheetTitle = ZFLocalizedString(@"Question_SureBack", nil);
        
        NSArray *titles = @[
            ZFLocalizedString(@"PaySDK_PaymentSurvey", nil),
            ZFLocalizedString(@"PaySDK_GoBackNow", nil)
        ];
        
        /// 取消按钮品牌升级: (红色+加粗)
        NSString *cancelTitle = ZFLocalizedString(@"PaySDK_ContinuePayment", nil);
        NSMutableAttributedString *cancelAttr = [[NSMutableAttributedString alloc] initWithString:cancelTitle];
        UIFont *font = [UIFont boldSystemFontOfSize:16];
        NSRange range = NSMakeRange(0, cancelTitle.length);
        [cancelAttr addAttribute:NSFontAttributeName value:font range:range];
        [cancelAttr addAttribute:NSForegroundColorAttributeName value:ZFC0xFE5269() range:range];
        
        [ZFActionSheetView actionSheetByBottomCornerRadius:^(NSInteger buttonIndex, id title) {
            if (buttonIndex == 0) {
                if (self.paymentSurveyHandle) {
                    self.paymentSurveyHandle();
                } else {
                    if (self.parentViewController.navigationController) {
                        [self.parentViewController.navigationController popViewControllerAnimated:YES];
                    }
                }
            } else {
                //点击弹框按钮的索引 如果有调查问卷入口-1代表取消按钮，无调查问卷入口的-0代表取消文本
                if (buttonIndex == (titles.count - 1)) {
                    alertConfiguration.alertCompletionHandle(1);
                }
            }
        } cancelButtonBlock:nil
                 sheetTitle:sheetTitle
          cancelButtonTitle:cancelAttr
        otherButtonTitleArr:titles];
    };

    GGPayCashierViewController *payViewController = [[GGPayCashierViewController alloc] initWithNibName:nil bundle:nil];
    payViewController.fd_interactivePopDisabled = YES;
    payViewController.redirectUrl = self.payUrl;
    @weakify(self)
    payViewController.paySuccessResultCompletionHandle = ^BOOL(GGPayResultModel *model) {
        [self requestQueryOrderInfo:model.payResultURL];
        return YES;
    };
    payViewController.payFailureCompletionHandle = ^(NSInteger code, NSString *msg) {
        @strongify(self)
        if (self.payFailureCompletionHandle) {
            self.payFailureCompletionHandle();
        }
    };
    payViewController.payCancelCompolementHandle = ^{
        @strongify(self)
        if (self.payCancelCompolementHandle) {
            self.payCancelCompolementHandle();
        }
    };
    payViewController.didClickSupportCenterCompletionHandle = ^{
        //支持中心回调
        @strongify(self)
        ZFContactUsViewController *vc = [[ZFContactUsViewController alloc] init];
        NSString *lang = [ZFLocalizationString shareLocalizable].nomarLocalizable;
        vc.link_url = [NSString stringWithFormat:[YWLocalHostManager contactUsURL], lang];
        [self.parentViewController.navigationController pushViewController:vc animated:YES];
    };
    payViewController.didClickpaySurveyCompletionHandle = ^{
        //支付问卷调查
        @strongify(self)
        if (self.paymentSurveyHandle) {
            self.paymentSurveyHandle();
        }
    };
    
    /**
     点击电子钱包设置或忘记密码
     @param isSetPassword 是否是设置密码 YES 设置密码 NO 忘记密码
     */
    @weakify(payViewController)
    payViewController.didClickSetOrForgetPasswordCompletionHandle = ^(BOOL isSetPassword) {
        @strongify(self)
        if (!ZFIsEmptyString(self.walletPasswordUrl)) {
            //跳转到电子钱包修改密码的页面
            ZFWebViewViewController *web = [[ZFWebViewViewController alloc] init];
            web.link_url = self.walletPasswordUrl;
            web.walletChangePasswordBlock = ^{
                //更新GGPaySDK 密码更改状态
                @strongify(payViewController)
                [payViewController ggSetWalletPasswordCompeltion:YES];
            };
            [self.parentViewController.navigationController pushViewController:web animated:YES];
        }
    };
 
    if (self.parentViewController) {
        [self.parentViewController.navigationController pushViewController:payViewController animated:YES];
    }
}

- (void)showH5Pay
{
    ZFPaymentViewController *paymentView = [[ZFPaymentViewController alloc] init];
    //H5支付的链接是特殊的，目前只针对提交订单页面必传
    if (self.payUrlH5) {
        paymentView.url = self.payUrlH5;
    }else{
        paymentView.url = self.payUrl;
    }
    __block NSString *url = paymentView.url;
    @weakify(self);
    paymentView.block = ^(PaymentStatus status){
        @strongify(self);
        switch (status) {
            case PaymentStatusDone: {
                // 支付打点
                if (self.paySuccessCompletionHandle) {
                    [self requestQueryOrderInfo:url];
                }
            }
                break;
            case PaymentStatusFail: {
                if (self.payFailureCompletionHandle) {
                    self.payFailureCompletionHandle();
                }
            }
                break;
            case PaymentStatusUnknown:
            case PaymentStatusCancel: { // 取消付款
                // 支付打点
                if (self.payCancelCompolementHandle) {
                    self.payCancelCompolementHandle();
                }
            }
                break;
        }
    };
    
    paymentView.loadBlock = ^{
        if (self.loadH5PaymentHandle) {
            self.loadH5PaymentHandle();
        }
    };
    if (self.parentViewController) {
        [self.parentViewController.navigationController pushViewController:paymentView animated:YES];
    }
}

//获取原生支付信息
- (void)showDefaultPay
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(@"order/get_pay_before_info");
    requestModel.tryAgainTimesWhenFailure = 5;
    requestModel.parmaters = @{
                               @"order_id" : ZFToString(self.orderId)
                               };
    ShowLoadingToView(nil);
    @weakify(self)
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        @strongify(self)
        HideLoadingFromView(nil);
        if (ZFJudgeNSDictionary(responseObject)) {
            NSDictionary *params = (NSDictionary *)responseObject;
            NSDictionary *result = params[@"result"];
            NSInteger payModel = [result[@"pay_mode"] integerValue];
            self.walletPasswordUrl = result[@"wallet_password_url"];
            if (payModel == 1) {
                //后台支付等于1 并且AB测试等于0 进入原生支付SDK
                NSString *payUrl = result[@"pay_url"];
                self.payUrl = payUrl;
                [self showNativePay];
            }else{
                [self showH5Pay];
            }
        }else{
            if (self.payFailureCompletionHandle) {
                self.payFailureCompletionHandle();
            }
        }
    } failure:^(NSError *error) {
        YWLog(@"%@", error);
        HideLoadingFromView(nil);
        if (self.payFailureCompletionHandle) {
            self.payFailureCompletionHandle();
        }
    }];
}

- (void)AppsflyerTrackFail:(ZFOrderPayResultModel *)resultModel
{
    NSString *ordersn = self.orderId;
    if (ZFToString(resultModel.parentOrderSn).length) {
        ordersn = resultModel.parentOrderSn;
    }
    NSDictionary *params = @{
                             @"af_reciept_id" : ZFToString(self.orderId),
                             @"af_extra_fail_info" : @{
                                     @"payCurrencyAmount" : ZFToString(resultModel.payCurrencyAmount),
                                     @"errorMsg" : ZFToString(resultModel.errorMsg),
                                     @"payChannelCode" : ZFToString(resultModel.payChannelCode)
                                     },
                             };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_purchase_fail" withValues:params];
}

- (NSString *)GBPayLanguageMap:(NSString *)appLanguageCode
{
    if (!ZFToString(appLanguageCode).length) {
        return @"en";
    }
    NSDictionary *params = @{
                             @"pt" : @"pt-PT",
                             @"th" : @"th-TH",
                             @"zh-tw" : @"zh-Hant-TW"
                             };
    NSString *ggLanguage = params[appLanguageCode];
    if (!ZFToString(ggLanguage).length) {
        ggLanguage = appLanguageCode;
    }
    return ggLanguage;
}

/**
 *  调取后台接口，获取支付状态
 */
- (void)requestQueryOrderInfo:(NSString *)payUrl
{
    NSURLComponents *componests = [[NSURLComponents alloc] initWithString:payUrl];
    __block NSString *paysn = @"";
    [componests.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:@"pay_sn"]) {
            paysn = obj.value;
        }
        if ([obj.name isEqualToString:@"pn"]) {
            paysn = obj.value;
        }
    }];
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(@"order/query_pay_info");
    requestModel.tryAgainTimesWhenFailure = 5;
    requestModel.parmaters = @{
                               @"pay_sn" : ZFToString(paysn),
                               @"order_id" : ZFToString(self.orderId)
                               };
    ShowLoadingToView(nil);
    @weakify(self)
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        @strongify(self)
        HideLoadingFromView(nil);
        NSDictionary *result = responseObject[ZFResultKey];
        //pay_status：1-completed，2-pending，3-failure，4-refund
        NSInteger statusCode = [result[@"pay_status"] integerValue];
        ZFOrderPayResultModel *resultModel = [ZFOrderPayResultModel yy_modelWithJSON:result[@"pay_info"]];
        resultModel.five_th_info = [ZFFiveThModel yy_modelWithJSON:result[@"five_th_info"]];
        if (statusCode == 1 || statusCode == 2) {
            ///SOA 支付成功
            if (self.paySuccessCompletionHandle) {
                self.paySuccessCompletionHandle(resultModel);
            }
        } else if (statusCode == 3) {
            ///SOA 失败
            if (self.payFailureCompletionHandle) {
                self.payFailureCompletionHandle();
            }
            [self AppsflyerTrackFail:resultModel];
        } else if (statusCode == 4) {
            ///退款状态
        } else {
            ///SOA 失败
            if (self.payFailureCompletionHandle) {
                self.payFailureCompletionHandle();
            }
            [self AppsflyerTrackFail:resultModel];
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        ///SOA接口请求失败
        if (self.payFailureCompletionHandle) {
            self.payFailureCompletionHandle();
        }
        ZFOrderPayResultModel *resultModel = [[ZFOrderPayResultModel alloc] init];
        resultModel.parentOrderSn = self.orderId;
        resultModel.errorMsg = ZFToString(error.description);
        [self AppsflyerTrackFail:resultModel];
    }];
}

@end
