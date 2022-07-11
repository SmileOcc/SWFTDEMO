//
//  OSSVSearchAssociateViewModel.m
// XStarlinkProject
//
//  Created by odd on 2020/10/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVSearchAssociateViewModel.h"
#import "OSSVSearchAssociateAip.h"

@interface OSSVSearchAssociateViewModel()

@property (nonatomic, strong) OSSVSearchAssociateAip *api;

@end

@implementation OSSVSearchAssociateViewModel

- (void)associateRequest:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    if (self.api) {
        [self.api.sessionDataTask cancel];
    }
    self.api = [[OSSVSearchAssociateAip alloc] initWithKeyWord:parmaters[@"keyword"]];
    [self.api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        OSSVSearchAssociateModel *associateModel;
        if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
            associateModel = [OSSVSearchAssociateModel yy_modelWithJSON:requestJSON[kResult]];
        }
        if (completion) {
            completion(associateModel);
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}
@end
