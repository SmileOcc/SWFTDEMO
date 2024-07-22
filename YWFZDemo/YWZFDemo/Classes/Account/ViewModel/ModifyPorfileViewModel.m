//
//  ModifyPorfileViewModel.m
//  ZZZZZ
//
//  Created by DBP on 17/2/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ModifyPorfileViewModel.h"
#import "ProfileEditApi.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFRequestModel.h"
#import "AccountManager.h"
#import "ZFPubilcKeyDefiner.h"
#import "YWLocalHostManager.h"
#import "ZFApiDefiner.h"
#import "YWCFunctionTool.h"

@implementation ModifyPorfileViewModel

- (void)requestSaveInfo:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    NSDictionary *dict = parmaters;
    ShowLoadingToView(dict);
    ProfileEditApi *api = [[ProfileEditApi alloc] initWithDic:parmaters];
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(dict);
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(api.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            
            if ([requestJSON[ZFResultKey][@"error"] integerValue] == 0) {
                ShowToastToViewWithText(dict, requestJSON[ZFResultKey][@"msg"]);
                if (completion) {
                    completion(nil);
                }
            }else{
                ShowToastToViewWithText(dict, requestJSON[ZFResultKey][@"msg"]);
            }
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        ShowToastToViewWithText(dict, ZFLocalizedString(@"Global_Network_Not_Available",nil));
    }];
}

@end

