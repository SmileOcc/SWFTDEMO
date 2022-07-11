//
//  OSSVEditsProfiledViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVEditsProfiledViewModel.h"
#import "OSSVEditProfilesAip.h"

NSString *const EditKeyOfNickName = @"nickName";
NSString *const EditKeyOfSex = @"sex";
NSString *const EditKeyOfBirthday = @"birthday";
NSString *const EditKeyOfAvatar = @"avatar";

@implementation OSSVEditsProfiledViewModel

#pragma mark - Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        NSDictionary *dict = (NSDictionary *)parmaters;
        OSSVEditProfilesAip *editApi = [[OSSVEditProfilesAip alloc] initWithNickName:dict[EditKeyOfNickName] sex:dict[EditKeyOfSex] birthday:dict[EditKeyOfBirthday] avatar:dict[EditKeyOfAvatar]];
        // 增加一个Uploading 提示
        STLRequestAccessory *accessory = [[STLRequestAccessory alloc] init];
        accessory.title = STLLocalizedString_(@"uploading", nil);
        [editApi.accessoryArray addObject:accessory];
        // 开始请求
        [editApi  startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            AccountModel *userModel = [self dataAnalysisFromJson: requestJSON request:editApi];
            //更新单例数据
            if (userModel) {
                if (userModel.sex != [OSSVAccountsManager sharedManager].account.sex) {
                    // 改变性别通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_HomeChannel object:nil];
                }
                [[OSSVAccountsManager sharedManager] updateUserInfo:userModel];
            }
            if (completion) {
                if(userModel) {
                    completion(@(YES));
                }else {
                    completion(nil);
                }
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
    if ([request isKindOfClass:[OSSVEditProfilesAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [AccountModel yy_modelWithJSON:json[kResult]];
        }
        else {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}

@end
