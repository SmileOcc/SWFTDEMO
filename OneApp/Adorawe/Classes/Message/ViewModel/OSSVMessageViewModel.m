//
//  OSSVMessageViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageListAip.h"
#import "OSSVMessageViewModel.h"

@implementation OSSVMessageViewModel

#pragma mark public methods

-(void)requestNetwork:(id)parmaters
           completion:(void (^)(id))completion
              failure:(void (^)(id))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVMessageListAip *api = [[OSSVMessageListAip alloc] init];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            self.model = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion){
                completion(self.model);
            }
        }
           failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
               if (failure){
                   failure(nil);
               }
           }];
    
        }
      exception:^{
          if (failure) {
              failure(nil);
          }
      }];
}

#pragma mark private methods

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[OSSVMessageListAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVMessageListModel yy_modelWithJSON:json[kResult]];
        } else {
            if (json && json[@"message"]) {
                 [self alertMessage:json[@"message"]];
            }
        }
    }
    return nil;
}


@end
