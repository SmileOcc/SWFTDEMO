//
//  OSSVOrdersStatussViewModel.m
// XStarlinkProject
//
//  Created by odd on 2020/8/11.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVOrdersStatussViewModel.h"
#import "OSSVOrdersStatusAip.h"

@implementation OSSVOrdersStatussViewModel
- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    OSSVOrdersStatusAip *api = [[OSSVOrdersStatusAip alloc] init];
    [api startWithBlockSuccess:^(__kindof STLBaseRequest *request) {
        
        id requestJSON = [NSStringTool desEncrypt:request];
        NSArray *results = [self dataAnalysisFromJson: requestJSON request:api];
        if (completion) {
            completion(results);
        }
    } failure:^(__kindof STLBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(STLBaseRequest *)request {
    if ([request isKindOfClass:[OSSVOrdersStatusAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [NSArray yy_modelArrayWithClass:[OSSVOrdersStatussModel class] json:json[kResult]];
        } else {
//            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}
@end
