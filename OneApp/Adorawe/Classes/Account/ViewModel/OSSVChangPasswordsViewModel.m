//
//  OSSVChangPasswordsViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVChangPasswordsViewModel.h"
#import "OSSVChangesPasswordsAip.h"

NSString *const ChangePasswordKeyOfOldWord = @"oldPassword";
NSString *const ChangePasswordKeyOfNewWord = @"newPassword";

@implementation OSSVChangPasswordsViewModel

#pragma mark - Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        NSDictionary *dict = (NSDictionary *)parmaters;
        OSSVChangesPasswordsAip *passwordsAip = [[OSSVChangesPasswordsAip alloc] initWithChangeNewPassword:dict[ChangePasswordKeyOfNewWord] oldPassword:dict[ChangePasswordKeyOfOldWord]];
        STLRequestAccessory *accessory = [[STLRequestAccessory alloc] init];
        [passwordsAip.accessoryArray addObject:accessory];
        [passwordsAip  startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            NSString *userId = (NSString *)[self dataAnalysisFromJson: requestJSON request:passwordsAip];
            if (completion) {
                if ([userId isEqualToString:[OSSVAccountsManager sharedManager].account.userid]) {
                     completion(@YES);
                }
                else {
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
    if ([request isKindOfClass:[OSSVChangesPasswordsAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            NSDictionary *dic = json[kResult];
            NSString *userID = [NSString stringWithFormat:@"%@",dic[@"user_id"]];
            return userID;
        }
        else {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}


@end
