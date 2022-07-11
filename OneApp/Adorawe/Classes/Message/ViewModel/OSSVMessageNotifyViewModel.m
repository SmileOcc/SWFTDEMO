//
//  OSSVMessageNotifyViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageAip.h"
#import "OSSVMessageNotifyViewModel.h"

@interface OSSVMessageNotifyViewModel()

@property(nonatomic, assign) NSInteger curPage;

@end

@implementation OSSVMessageNotifyViewModel

-(void)requestNetwork:(id)parmaters
           completion:(void (^)(id))completion
              failure:(void (^)(id))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        NSString *refreshOrLoadMore = (NSString *)[(NSDictionary *)parmaters objectForKey:@"refreshOrLoadmore"];
        NSString *type = (NSString *)[(NSDictionary *)parmaters objectForKey:@"type"];
        if ([refreshOrLoadMore isEqualToString:STLRefresh]) {
            self.curPage = 1;
        }
        if ([refreshOrLoadMore isEqualToString:STLLoadMore])
        {
            self.curPage ++ ;
        }
        OSSVMessageAip *api = [[OSSVMessageAip alloc] initWithPage:self.curPage type:type];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            NSArray *tempArray = [self dataAnalysisFromJson: requestJSON request:api];
            if (self.curPage == 1)
            {
                self.dataArray = [NSMutableArray arrayWithArray:tempArray];
            }
            else
            {
                [self.dataArray addObjectsFromArray:tempArray];
            }
            if (completion)
            {
                completion(tempArray);
            }
        }
                           failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
                               if (failure)
                               {
                                   failure(nil);
                               }
                           }];
    }
                                              exception:^{
                                                  if (failure)
                                                  {
                                                      failure(nil);
                                                  }
                                              }];
}

#pragma mark private methods

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request
{
    if ([request isKindOfClass:[OSSVMessageAip class]])
    {
        if ([json[kStatusCode] integerValue] == kStatusCode_200)
        {
            return [NSArray yy_modelArrayWithClass:OSSVMessageModel.class json:json[kResult]];
        }
        else
        {
            if (json && json[@"message"])
            {
                [self alertMessage:json[@"message"]];
            }
        }
    }
    return @[];
}


@end
