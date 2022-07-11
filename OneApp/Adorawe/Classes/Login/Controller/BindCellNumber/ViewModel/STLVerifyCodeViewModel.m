//
//  STLVerifyCodeViewModel.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/8/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLVerifyCodeViewModel.h"
#import "STLSendCodeApi.h"
#import "STLVerifiCodeApi.h"

@implementation STLVerifyCodeViewModel

// 发送验证码
-(void)requestCodeInfo:(void (^)())completion failure:(void (^)())failure{
    [[STLNetworkStateManager sharedManager] networkState:^{
        STLSendCodeApi *sendApi = [[STLSendCodeApi alloc] initWithParam:@{}];
        [sendApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            BOOL isSuccess = [[self dataAnalysisFromJson:requestJSON request:request] boolValue];
            if (isSuccess) {
                if (completion) {
                    completion();
                }
            }else{
                if (failure) {
                    failure();
                }
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure();
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil, nil);
        }
    }];
}


// 验证验证码
-(void)requestVerifiCode:(id)parms completion:(void (^)(id))completion failure:(void (^)())failure{
    [[STLNetworkStateManager sharedManager] networkState:^{
        STLVerifiCodeApi *verifiApi = [[STLVerifiCodeApi alloc] initWithParam:parms];
        [verifiApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            BOOL isSuccess = [[self dataAnalysisFromJson:requestJSON request:request] boolValue];
            if (isSuccess) {
                if (completion) {
                    completion(requestJSON);
                }
            }else{
                if (failure) {
                    failure();
                }
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure();
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil, nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request{
    if ([request isKindOfClass:[STLSendCodeApi class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            [self alertMessage:json[@"message"]];
            self.countDown = json[kResult][@"countdown"];
            return @(YES);
        } else {
            [self alertMessage:json[@"message"]];
            self.countDown = @"";
            return @(NO);
          }
        } else if ([request isKindOfClass:[STLVerifiCodeApi class]]){
            if ([json[kStatusCode] integerValue] == kStatusCode_200) {
                [self alertMessage:json[@"message"]];
                return @(YES);
            }
        } else {
            [self alertMessage:json[@"message"]];
            return @(NO);
        }
    return nil;
}

@end
