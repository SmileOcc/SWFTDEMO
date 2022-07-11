//
//  OSSVShowErrorManager.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVShowErrorManager.h"
#import "Adorawe-Swift.h"

@implementation OSSVShowErrorManager

-(void)modalErrorMessage:(UIViewController *)viewController baseModel:(id<STLBaseModelErrorMessageProtocol>)model
{
    if ([model isKindOfClass:[OSSVCartCheckModel class]]) {
        //当statusCode == 202的时候，是输入优惠券不可用
        OSSVCartCheckModel *checkModel = (OSSVCartCheckModel *)model;
        NSString *message = checkModel.message;
        
//        if (checkModel.statusCode == 202) {
//            STLViewController *alertController = [STLViewController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
//            [alertController addAction:[UIAlertAction actionWithTitle:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] style:UIAlertActionStyleDefault handler:nil]];
//            [viewController presentViewController:alertController animated:YES completion:^{}];
//            return;
//        }
        
        if (checkModel.statusCode == kStatusCode_205) {
            
            [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:message buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                
            }];
            return;
        }
        switch (checkModel.flag) {
            case CartCheckOutResultEnumTypeNoAddress:
            {
                NSArray *upperTitle = @[STLLocalizedString_(@"cancel",nil).uppercaseString,STLLocalizedString_(@"add",nil).uppercaseString];
                NSArray *lowserTitle = @[STLLocalizedString_(@"cancel",nil),STLLocalizedString_(@"add",nil)];
                
                [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:@"" message:message buttonTitles:APP_TYPE == 3 ? lowserTitle : upperTitle buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                    if (index == 1) {
                        OSSVEditAddressVC *newAddress = [OSSVEditAddressVC new];
//                        newAddress.isPresentVC = YES;
                        newAddress.getAddressModelBlock = ^(OSSVAddresseBookeModel *addressModel){
                            STLLog(@"test model name == %@",addressModel.lastName);
                        };
                        OSSVNavigationVC *nav = [[OSSVNavigationVC alloc] initWithRootViewController:newAddress];
                        [viewController presentViewController:nav animated:YES completion:nil];
                    }
                }];
            }
                break;
            case CartCheckOutResultEnumTypeNoGoods:
            {
                
                [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:message buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                    [viewController.navigationController popViewControllerAnimated:YES];
                }];
            }
                break;
            case CartCheckOutResultEnumTypeNoShipping:
            {
                
                [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:message buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                    [viewController.navigationController popViewControllerAnimated:YES];
                }];
            }
                break;
            case CartCheckOutResultEnumTypeNoPayment:
            {
                [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:message buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                }];
            }
                break;
            case CartCheckOutResultEnumTypeShelvesed:
            {
                [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:message buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                    [viewController.navigationController popViewControllerAnimated:YES];
                }];
            }
                break;
            case CartCheckOutResultEnumTypeNoStock:
            {
                [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:message buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                    [viewController.navigationController popViewControllerAnimated:YES];
                }];
            }
                break;
            case CartCheckOutResultEnumTypeNoSupportPayment:
            {
                [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:message buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                }];
            }
                break;
            default:
                message.length ? [self alertMessage:message] : nil;
                break;
        }
    }
}

- (void)alertMessage:(NSString *)info {
    
    if ([info isKindOfClass:[NSNull class]]) {
        info = @"error";
    }
    [HUDManager showHUDWithMessage:info];
}


@end
