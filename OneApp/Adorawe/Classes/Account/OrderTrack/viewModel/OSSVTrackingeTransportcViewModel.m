//
//  OSSVTrackingeTransportcViewModel.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
//  -----新的物流信息-----------

#import "OSSVTrackingeTransportcViewModel.h"
#import "OSSVTrackingeInformationeAip.h"
#import "OSSVTrackingcTotalInformcnModel.h"

@interface OSSVTrackingeTransportcViewModel ()
@property (nonatomic, strong) NSDictionary *dataDic;
@end
@implementation OSSVTrackingeTransportcViewModel

- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    NSString *trackVal = STLToString((NSDictionary *)parmaters[@"trackVal"]);
    NSString *trackType = STLToString((NSDictionary *)parmaters[@"trackType"]);
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVTrackingeInformationeAip *traInformationeAip = [[OSSVTrackingeInformationeAip alloc] initWithTrackVal:trackVal trackType:trackType];
        [traInformationeAip  startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            self.dataDic = [self dataAnalysisFromJson: requestJSON request:traInformationeAip];
            if (completion) {
                completion(self.dataDic);
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
    
    if ([request isKindOfClass:[OSSVTrackingeInformationeAip class]]) {
        
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [OSSVTrackingcTotalInformcnModel yy_modelWithJSON:json[kResult][@"tracking_list"]];
        }
        else {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}
@end
