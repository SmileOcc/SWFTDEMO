//
//  STLShareViewModel.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/17.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLShareViewModel.h"
#import "STLShareAndEarnApi.h"
#import "STLShareEarnModel.h"

@implementation STLShareViewModel

- (void)requestShareAndEarnNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure{
    [[STLNetworkStateManager sharedManager] networkState:^{
        NSDictionary *dic = (NSDictionary *)parmaters;
        NSString *type = [dic.allKeys containsObject:@"type"] ? parmaters[@"type"] : nil;
        NSString *h_url = [dic.allKeys containsObject:@"h_url"] ? parmaters[@"h_url"] : nil;
        NSString *sku = [dic.allKeys containsObject:@"sku"] ? parmaters[@"sku"] : nil;
        
        STLShareAndEarnApi *shareApi = [[STLShareAndEarnApi alloc] initWithType:type h_url:h_url sku:sku];
        [shareApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            STLShareEarnModel *shareModel = [self dataAnalysisFromJson: requestJSON request:shareApi];
            if (completion) {
                completion(shareModel);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        
    }];
    
}

- (id)dataAnalysisFromJson:(id)json  request:(OSSVBasesRequests *)request{
    if ([request isKindOfClass:[STLShareAndEarnApi class]])
    {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return [STLShareEarnModel yy_modelWithJSON:json[kResult]];
        }
        else
        {
            [self alertMessage:json[kMessagKey]];
        }
    }
    return nil;
}

@end
