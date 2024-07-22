//
//  ZFCommunitySuggestedUsersListModel.m
//  ZZZZZ
//
//  Created by YW on 2017/7/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunitySuggestedUsersListModel.h"
#import "ZFCommunitySuggestedUsersModel.h"
@implementation ZFCommunitySuggestedUsersListModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"suggestedList" : [ZFCommunitySuggestedUsersModel class]
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"suggestedList"       : @"list",
             @"pageCount"        : @"pageCount",
             @"curPage"          : @"curPage"
             };
}
@end
