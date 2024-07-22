//
//  ZFGoodsDetailGroupBuyModel.m
//  ZZZZZ
//
//  Created by YW on 2019/1/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailGroupBuyModel.h"

//@implementation ZFGroupBuyStartTeamModel
//@end




@implementation ZFGroupBuyMemberModel
@end



@implementation ZFGroupBuyTeamModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"team_members" : [ZFGroupBuyMemberModel class]
             };
}
@end



@implementation ZFGoodsDetailGroupBuyModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"team_detail" : [ZFGroupBuyTeamModel class]
             };
}
@end
