//
//  CartOperationViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "CartOperationViewModel.h"
#import "CartAddApi.h"
#import "CartEditApi.h"
#import "CartDelApi.h"
#import "CartUploadApi.h"
#import "STLCartUncheckApi.h"
#import "CartModel.h"
#import "Adorawe-Swift.h"
@import FirebasePerformance;

@interface CartOperationViewModel ()
@property (strong,nonatomic) FIRTrace *trace;
@end

@implementation CartOperationViewModel

- (void)requestCartAddNetwork:(CartModel *)cartModel completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    CartAddApi *api = [[CartAddApi alloc] initWithWid:cartModel.wid goodsId:cartModel.goodsId goodsNum:cartModel.goodsNumber isChecked:cartModel.isChecked flag:cartModel.stateType specialId:cartModel.specialId activeId:cartModel.activeId replace_free:cartModel.cart_exits];
    
    NSString* sizeCode = [STLPreference objectForKey:STLPreference.keySelectedSizeCode];
    api.size_country_code = sizeCode;
    [api.accessoryArray addObject:[[STLRequestAccessory alloc] init]];
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        STLLog(@"%@", requestJSON);
        if (completion) {
            completion(requestJSON);
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        STLLog(@"%@", error);
    }];

}

//- (void)requestCartEditNetwork:(CartModel *)cartModel completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
//    
//        CartEditApi *api = [[CartEditApi alloc] initWithWid:cartModel.wid goodsId:cartModel.goodsId goodsNum:cartModel.goodsNumber];
//        [api.accessoryArray addObject:[[STLRequestAccessory alloc] init]];
//        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
//            
//            id requestJSON = [OSSVNSStringTool desEncrypt:request];
//            STLLog(@"%@", requestJSON);
//            if (completion) {
//                completion(requestJSON);
//            }
//        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
//            
//        }];
//
//}

//- (void)requestCartDelNetwork:(CartModel *)cartModel completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
//    
//        CartDelApi *api = [[CartDelApi alloc] initWithWid:cartModel.wid goodsId:cartModel.goodsId];
//        [api.accessoryArray addObject:[[STLRequestAccessory alloc] init]];
//        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
//            if (completion) {
//                completion(nil);
//            }
//        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
//            
//        }];
//
//}

- (void)requestCartUploadNetwork:(id)parmaters showView:(UIView *)showView completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
        _trace = [FIRPerformance startTraceWithName:@"cart_view"];
        CartUploadApi *api = [[CartUploadApi alloc] initWithGoodsList:parmaters];
        if (showView) {
            [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:showView]];
        }

        @weakify(self)
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            [self.trace stop];
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            NSDictionary *result = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(result);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            @strongify(self)
            [self.trace stop];
            
            if (failure) {
                failure(error);
            }

        }];

}

- (void)requestCartUncheckNetwork:(id)parmaters showView:(UIView *)showView completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    STLCartUncheckApi *api = [[STLCartUncheckApi alloc] initWithCartsIds:parmaters];
        if (showView) {
            [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:showView]];
        }

        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            NSDictionary *result = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(result);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(error);
            }

        }];

}

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    
    if ([request isKindOfClass:[CartUploadApi class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            if ([json[kResult] isKindOfClass:[NSDictionary class]]) {
                return json[kResult];
            }
        } else if ([json[kStatusCode] integerValue] == kStatusCode_205) {
            [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:json[kMessagKey] buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok", @"ok")] : @[STLLocalizedString_(@"ok", @"ok").uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                
            }];

        } else {
            if (![OSSVNSStringTool isEmptyString:json[@"message"]]) {
                [self alertMessage:json[@"message"]];
            }
        }
    } else if ([request isKindOfClass:[STLCartUncheckApi class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            if ([json[kResult] isKindOfClass:[NSDictionary class]]) {
                return json[kResult];
            }
        } else if ([json[kStatusCode] integerValue] == kStatusCode_205) {
            [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:json[kMessagKey] buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok", @"ok")] : @[STLLocalizedString_(@"ok", @"ok").uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                
            }];

        } else {
            if (![OSSVNSStringTool isEmptyString:json[@"message"]]) {
                [self alertMessage:json[@"message"]];
            }
        }
    }
    return nil;
}
@end
