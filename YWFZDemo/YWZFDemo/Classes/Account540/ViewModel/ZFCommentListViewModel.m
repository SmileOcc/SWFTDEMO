//
//  ZFCommentListViewModel.m
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommentListViewModel.h"
#import "ZFRequestModel.h"
#import "YWCFunctionTool.h"
#import "ZFApiDefiner.h"
#import "YWLocalHostManager.h"

@interface ZFCommentListViewModel ()
@end

@implementation ZFCommentListViewModel

///获取待评论列表
- (void)requestWaitCommentPort:(BOOL)isFirstPage
                    completion:(void (^)(NSArray *))completion
{
    if (isFirstPage) {
        self.currentPage = 1;
    } else {
        self.currentPage = ++self.currentPage;
    }
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_UserNotReviewList);
    requestModel.parmaters = @{
        @"page"         : @(self.currentPage),
        @"page_size"    : @"20",
    };
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *resultDic = responseObject[ZFResultKey];
        
        NSArray *modelArray = nil;
        if (ZFJudgeNSDictionary(resultDic)) {
            self.totalCount = [resultDic[@"total"] integerValue];
            
            modelArray = [NSArray yy_modelArrayWithClass:[ZFWaitCommentModel class] json:resultDic[@"list"]];
        } else {
            --self.currentPage;
        }
        if (completion) {
            completion(modelArray);
        }
    } failure:^(NSError *error) {
        --self.currentPage;
        if (completion) {
            completion(nil);
        }
    }];
}


///获取我的已评论列表
- (void)requestMyCommentPort:(BOOL)isFirstPage
                  completion:(void (^)(NSArray *))completion
{
    if (isFirstPage) {
        self.currentPage = 1;
    } else {
        self.currentPage = ++self.currentPage;
    }
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_UserReviewedList);
    requestModel.parmaters = @{
        @"page"         : @(self.currentPage),
        @"page_size"    : @"20",
    };
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSDictionary *resultDic = responseObject[ZFResultKey];
        
        NSArray *modelArray = nil;
        if (ZFJudgeNSDictionary(resultDic)) {
            self.totalCount = [resultDic[@"total"] integerValue];
            
            modelArray = [NSArray yy_modelArrayWithClass:[ZFMyCommentModel class] json:resultDic[@"list"]];
        } else {
            --self.currentPage;
        }
        if (completion) {
            completion(modelArray);
        }
    } failure:^(NSError *error) {
        --self.currentPage;
        if (completion) {
            completion(nil);
        }
    }];
}

@end
