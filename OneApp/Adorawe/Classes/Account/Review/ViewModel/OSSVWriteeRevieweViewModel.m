//
//  OSSVWriteeRevieweViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVWriteeRevieweViewModel.h"
#import "OSSVWriteeRevieweAip.h"
#import "STLNetworkStateManager.h"

@implementation OSSVWriteeRevieweViewModel

- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure
{
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVWriteeRevieweAip *api = [[OSSVWriteeRevieweAip alloc] initWithDict:parmaters];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            BOOL isSussess = NO;
            
            if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200)     // 评论成功
            {
                isSussess = YES;
                [self alertMessage:requestJSON[@"message"]];
            } else {
                [self alertMessage:requestJSON[@"message"]];
            }

            
            if (completion) {
                completion(@(isSussess));
            }
            
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil);
            }
            STLLog(@"failure:%@", error);
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request
{
    if ([request isKindOfClass:[OSSVWriteeRevieweAip class]]) {
        return json[kResult];
    }
    return nil;
}

@end
