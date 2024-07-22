
//
//  HelpViewModel.m
//  ZZZZZ
//
//  Created by YW on 18/9/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "HelpViewModel.h"
#import "HelpApi.h"
#import "HelpModel.h"
#import "NSStringUtils.h"
#import "ZFRequestModel.h"
#import "ZFPubilcKeyDefiner.h"

@interface HelpViewModel ()
@property (nonatomic, strong) NSMutableArray * dataArray;
@end

@implementation HelpViewModel

- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure
{
    HelpApi * helpApi = [[HelpApi alloc]init];
    [helpApi startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        
        id requestJosn = [NSStringUtils desEncrypt:request api:NSStringFromClass(helpApi.class)];
        self->_dataArray = [self dataAnalysisFromJson:requestJosn request:helpApi];
        if (completion) {
            completion(self->_dataArray);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request {
    //分类数据
    if ([request isKindOfClass:[HelpApi class]]) {
        if ([json[@"statusCode"] integerValue] == 200) {
            return [NSArray  yy_modelArrayWithClass:[HelpModel class]json:json[ZFResultKey]];
        }
    }    
    return nil;
}

@end
