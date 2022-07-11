//
//  OSSVCheckeRevieweViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCheckeRevieweViewModel.h"
#import "CheckReviewApi.h"
#import "OSSVChecksReviewssModel.h"

@implementation OSSVCheckeRevieweViewModel

- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure
{
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        CheckReviewApi *api = [[CheckReviewApi alloc] initWithDict:parmaters];
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [api startWithBlockSuccess:^(__kindof STLBaseRequest *request) {
            @strongify(self)
            
            id requestJSON = [NSStringTool desEncrypt:request];
            OSSVChecksReviewssModel *model = [self dataAnalysisFromJson:requestJSON request:api];
            BOOL isSussess = NO;
            if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {// 获取评论成功
                isSussess = YES;
            } else {
                [self alertMessage:STLToString(requestJSON[@"message"])];
            }
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:@(isSussess) forKey:@"status"];
            if (model)
            {
                [dict setValue:model forKey:@"model"];
            }
            
            if (completion) {
                completion(dict);
            }
            
        } failure:^(__kindof STLBaseRequest *request, NSError *error) {
            if (failure) {
                failure(nil);
            }
            STLLog(@"failure");
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(STLBaseRequest *)request
{
    if ([request isKindOfClass:[CheckReviewApi class]]) {
        return [OSSVChecksReviewssModel yy_modelWithJSON:json[kResult]];
    }
    return nil;
}

@end
