//
//  ZFSubmitReviewViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSubmitReviewViewModel.h"
#import "ZFOrderReviewApi.h"
#import "WriteReviewApi.h"
#import "ZFWriteReviewResultModel.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFRequestModel.h"
#import "ZFPubilcKeyDefiner.h"
#import "YWCFunctionTool.h"

@interface ZFSubmitReviewViewModel()
@end

@implementation ZFSubmitReviewViewModel
#pragma mark - request methods
- (void)requestOrderReviewListNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    NSString *order_id = @"";
    NSString *goods_id = @"";
    if (ZFJudgeNSDictionary(parmaters)) {
        order_id = parmaters[@"order_id"];
        goods_id = parmaters[@"goods_id"];
    }
    
    ZFOrderReviewApi *api = [[ZFOrderReviewApi alloc] initWithOrderId:ZFToString(order_id) goodsId:ZFToString(goods_id)];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        NSDictionary *result = requestJSON;
        self.model = [ZFOrderReviewListModel yy_modelWithJSON:result[ZFResultKey]];
        NSInteger statusCode = [result[@"statusCode"] integerValue];
        if (statusCode == 200) {
            if (completion) {
                completion(self.model);
            }
        } else {
            if (failure) {
                failure(nil);
            }
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)requestWriteReview:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    NSDictionary *dict = parmaters;
    ShowLoadingToView(dict);
    WriteReviewApi *api = [[WriteReviewApi alloc] initWithDict:parmaters];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(dict);
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        ZFWriteReviewResultModel *model = [ZFWriteReviewResultModel yy_modelWithJSON:requestJSON[ZFResultKey]];
        BOOL isSuccess = NO;
        if ([requestJSON[@"statusCode"] integerValue] == 200 && model.error == 0) {
            isSuccess = YES;
            if (completion) {
                completion(model);
            }
        }
        ShowToastToViewWithText(dict, model.msg);
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(dict);
        ShowToastToViewWithText(dict, ZFLocalizedString(@"Failed", nil));
        if (failure) {
            failure(nil);
        }
    }];
}

#pragma mark - deal data methods

@end
