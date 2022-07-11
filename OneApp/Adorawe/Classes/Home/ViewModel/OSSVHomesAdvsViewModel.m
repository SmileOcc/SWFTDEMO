//
//  HomeAdvModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomesAdvsViewModel.h"
#import "OSSVHomeAdvsAip.h"

@implementation OSSVHomesAdvsViewModel

#pragma mark - Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVHomeAdvsAip *api = [[OSSVHomeAdvsAip alloc] init];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            id result = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion) {
                completion(result);
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
    
    if ([request isKindOfClass:[OSSVHomeAdvsAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            if ([json[kResult] isKindOfClass:[NSDictionary class]]) {
                return json[kResult];
            }
        } else {
            //            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}
@end
