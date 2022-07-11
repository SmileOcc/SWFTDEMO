//
//  YSMsgViewModel.m
//  YoshopPro
//
//  Created by hky on 2018/5/23.
//  Copyright © 2018年 yoshop. All rights reserved.
//

#import "YSMsgListApi.h"
#import "YSMsgViewModel.h"

@implementation YSMsgViewModel

#pragma mark public methods

-(void)requestNetwork:(id)parmaters
           completion:(void (^)(id))completion
              failure:(void (^)(id))failure {
    @weakify(self)
    [[YSNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        YSMsgListApi *api = [[YSMsgListApi alloc] init];
        [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
            @strongify(self)
            id requestJSON = [NSStringUtils desEncrypt:request];
            self.model = [self dataAnalysisFromJson: requestJSON request:api];
            if (completion)
            {
                completion(self.model);
            }
        }
                           failure:^(__kindof SYBaseRequest *request, NSError *error) {
                               if (failure)
                               {
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

- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request
{
    if ([request isKindOfClass:[YSMsgListApi class]])
    {
        if ([json[@"statusCode"] integerValue] == 200)
        {
            return [YSMsgListModel yy_modelWithJSON:json[@"result"]];
        }
        else
        {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}


@end
