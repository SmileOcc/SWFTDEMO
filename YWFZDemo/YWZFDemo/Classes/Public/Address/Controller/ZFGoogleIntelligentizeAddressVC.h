//
//  ZFGoogleIntelligentizeVC.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFGoogleAddressModel.h"
#import "ZFAddressInfoModel.h"

@interface ZFGoogleIntelligentizeAddressVC : ZFBaseViewController

@property (nonatomic, copy) void (^selectedAddressModel)(ZFGoogleDetailAddressModel *detailAddressModel);

@property (nonatomic, copy) NSString *country_code;
@property (nonatomic, copy) NSString *key;

@property (nonatomic, strong) ZFAddressInfoModel                    *model;

/**
 控制器视图显示到其他控制器上

 @param parentController 目标控制器
 @param completeBlock 显示完成操作
 */
- (void)googleIntelligentizeAddressShowController:(UIViewController *)parentController completion:(void(^)(BOOL flag))completeBlock;

/**
 视图隐藏
 */
- (void)googleIntelligentizeAddressHideCompletion:(void(^)(BOOL flag))completeBlock;

@end
