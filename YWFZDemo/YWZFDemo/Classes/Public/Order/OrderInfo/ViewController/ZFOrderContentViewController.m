//
//  ZFOrderInformationViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/11/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderContentViewController.h"
#import "ZFOrderInfoViewController.h"
#import "ZFLocalizationString.h"
#import "ZFBTSManager.h"

@interface ZFOrderContentViewController ()<UINavigationControllerDelegate>
@end

@implementation ZFOrderContentViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"CartOrderInfo_VC_Title",nil);
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadSubViewController];
    self.navigationController.delegate = self;
}


#pragma mark - Private method

- (void)loadSubViewController {
    switch (self.paymentProcessType) {
        // 直接走老流程,就是 ZFOrderInfoViewController , ZFPayMethodsViewController 切换
        case PaymentProcessTypeOld:
        {
            ZFOrderInfoViewController *singleOrderVC = [[ZFOrderInfoViewController alloc] init];
            singleOrderVC.payCode       = self.payCode;
            singleOrderVC.checkOutModel = self.checkoutModel;
            singleOrderVC.detailFastBuyInfo = self.detailFastBuyInfo; //从商详一键(快速)购买过来时带入参数到cart/done
            [self addChildViewController:singleOrderVC];
            [singleOrderVC didMoveToParentViewController:self];
            [self.view addSubview:singleOrderVC.view];
        }
            break;
            break;
        default:
            break;
    }
}

@end
