//
//  STLTabbarViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLTabbarViewModel.h"

@implementation STLTabbarViewModel

- (void)loadOnlineIconCompletion:(void (^)(id obj))completion
                         failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        STLTabbarApi *api = [[STLTabbarApi alloc] init];
        // 取缓存数据
        if (api.cacheJSONObject) {
            id requestJSON = api.cacheJSONObject;
            STLTabbarModel *model = [self dataAnalysisFromJson: requestJSON request:api];
            if (model) {
                if (completion) {
                    model.isCache = YES;
                    completion(model);
                }
            }
        }
        @weakify(self)
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            STLTabbarModel *model = [self dataAnalysisFromJson: requestJSON request:api];
            
            if (model) {
                if (completion) {
                    model.isCache = NO;
                    completion(model);
                }
            }
        }failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
           if (failure) {
               failure(nil);
           }
        }];
        }exception:^{
          if (failure) {
              failure(nil);
          }
      }];
}

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[STLTabbarApi class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [STLTabbarModel yy_modelWithJSON:json[kResult]];
        } else {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}

- (void)alertMessage:(NSString *)info {
    
    if ([info isKindOfClass:[NSNull class]]) {
        info = @"error";
    }
    [HUDManager showHUDWithMessage:info margin:10];
}

@end
