//
//  STLGetPhoneAreaCode.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVGetPhoneeAreaeCodeeViewModel.h"
#import "OSSVGetePhoneAreaeCodeAip.h"
#import "OSSVPhoneeAreaeCodeModel.h"

@interface OSSVGetPhoneeAreaeCodeeViewModel ()
@property (nonatomic, strong)NSDictionary *dateDic;
@end
@implementation OSSVGetPhoneeAreaeCodeeViewModel

- (void)requestPhoneAreaCodeForCountryCodeWithParmater:(NSString *)countryCode completion:(void (^)(id))completion failure:(void (^)(id))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVGetePhoneAreaeCodeAip *api = [[OSSVGetePhoneAreaeCodeAip alloc] initGetPhoneAreaCodeForCountryCode:countryCode];

        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)

            id requestJSON = [OSSVNSStringTool desEncrypt:request];

            self.dateDic = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(self.dateDic);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[OSSVGetePhoneAreaeCodeAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVPhoneeAreaeCodeModel yy_modelWithJSON:json[kResult]];
        } else {
            [self alertMessage:json[@"message"]];
          }
        }
    return nil;
    }

@end
