//
//  OSSVPaymentsStatussViewModel.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/22.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVPaymentsStatussViewModel.h"
#import "OSSVPaymentsStatusAip.h"

@implementation OSSVPaymentsStatussViewModel

-(void)checkOrderStatus:(id)parmaters completion:(void (^)(id obj, NSString *msg))completion failure:(void (^)(id obj, NSString *msg))failure{
    [[STLNetworkStateManager sharedManager] networkState:^{
        OSSVPaymentsStatusAip *api = [[OSSVPaymentsStatusAip alloc] initWithParam:parmaters];

        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            if ([requestJSON[kStatusCode] integerValue] != 200) {
                if (failure) {
                    failure(nil,STLLocalizedString_(@"networkFailed", nil));
                }
            }else{
                if (completion) {
                    completion(requestJSON,nil);
                }
            }
            
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            STLLog(@"%@", error);
            if (failure) {
                failure(nil,STLLocalizedString_(@"networkFailed", nil));
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil,STLLocalizedString_(@"networkFailed", nil));
        }
    }];
}
@end
