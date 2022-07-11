//
//  OSSVTransportcSplitccViewModel.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/27.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVTransportcSplitccViewModel.h"
#import "OSSVTransporteSpliteAip.h"
#import "OSSVTransporteSpliteTotalModel.h"
@interface OSSVTransportcSplitccViewModel ()
@property (nonatomic, strong) NSDictionary *dataDic;
@end

@implementation OSSVTransportcSplitccViewModel

-(void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {

   NSString *orderNumber = (NSString *)parmaters;
   @weakify(self)
   [[STLNetworkStateManager sharedManager] networkState:^{
       @strongify(self)
       @weakify(self)
       OSSVTransporteSpliteAip   *transportSplitApi = [[OSSVTransporteSpliteAip alloc] initWithOrderNumber:orderNumber];
       [transportSplitApi  startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
           @strongify(self)
           id requestJSON = [OSSVNSStringTool desEncrypt:request];
           self.dataDic = [self dataAnalysisFromJson: requestJSON request:transportSplitApi];
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
   
   if ([request isKindOfClass:[OSSVTransporteSpliteAip class]]) {
       
       if ([json[kStatusCode] integerValue] == kStatusCode_200) {
           return [OSSVTransporteSpliteTotalModel yy_modelWithJSON:json[kResult]];
//           NSArray *modellist = [NSArray yy_modelArrayWithClass:[OSSVTransporteSpliteTotalModel class] json:json[kResult]];
//           return modellist;
       }
       else {
           [self alertMessage:json[@"message"]];
       }
   }
   return nil;
}
@end
