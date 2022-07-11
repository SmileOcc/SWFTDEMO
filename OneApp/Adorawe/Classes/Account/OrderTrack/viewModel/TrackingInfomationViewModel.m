//
//  OSSVTrackingccInfomatViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVTrackingccInfomatViewModel.h"
#import "OSSVTrackingeInformationeAip.h"
#import "OSSVTrackingcInformationcModel.h"

@interface OSSVTrackingccInfomatViewModel ()

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation OSSVTrackingccInfomatViewModel

#pragma mark - Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    NSString *trackVal = STLToString((NSDictionary *)parmaters[@"trackVal"]);
    NSString *trackType = STLToString((NSDictionary *)parmaters[@"trackType"]);
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVTrackingeInformationeAip *OSSVTrackingeInformationeAip = [[OSSVTrackingeInformationeAip alloc] initWithTrackVal:trackVal trackType:trackType];
        [OSSVTrackingeInformationeAip.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [OSSVTrackingeInformationeAip  startWithBlockSuccess:^(__kindof STLBaseRequest *request) {
            @strongify(self)
            id requestJSON = [NSStringTool desEncrypt:request];
            self.dataArray = [self dataAnalysisFromJson: requestJSON request:OSSVTrackingeInformationeAip];
            if (completion) {
                completion(self.dataArray);
            }

        } failure:^(__kindof STLBaseRequest *request, NSError *error) {
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

- (id)dataAnalysisFromJson:(id)json request:(STLBaseRequest *)request {
    
    if ([request isKindOfClass:[OSSVTrackingeInformationeAip class]]) {
        
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            NSDictionary *resultDic = json[kResult];

            if (STLJudgeNSArray(resultDic)) {
                NSArray *resultsArray = (NSArray *)resultDic;
                
                NSDictionary *firstData = resultsArray.firstObject;
                if (STLJudgeNSDictionary(firstData) && STLJudgeNSArray(firstData[@"tracking_detail"])) {
                    return [NSArray yy_modelArrayWithClass:[OSSVTrackingcMessagecModel class] json:firstData[@"tracking_detail"]];
                    
                }
            }
            return @[];
        }
        else {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}

@end
