//
//  CommendModel.m
//  Yoshop
//
//  Created by YW on 16/6/18.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "CommendModel.h"
#import "ZFPubilcKeyDefiner.h"

@implementation CommendModel

+(NSString*)tableName
{
    return kCommendTableName;
}

+(NSDictionary*)tableEntityMapping
{
    return @{
             @"rowid"           :BCSqliteTypeMakeTextPrimaryKey(@"rowid", NO),
             @"goodsId"         :BCSqliteTypeMakeText(@"goodsId", YES),
             @"goods_number"    :BCSqliteTypeMakeText(@"goods_number", YES),
             @"is_on_sale"    :BCSqliteTypeMakeText(@"is_on_sale", YES),
             @"groupId"         :BCSqliteTypeMakeText(@"groupId", YES),
             @"goodsName"       :BCSqliteTypeMakeText(@"goodsName", YES),
             @"goodsPrice"      :BCSqliteTypeMakeText(@"goodsPrice", YES),
             @"promotePrice"    :BCSqliteTypeMakeText(@"promotePrice", YES),
             @"goodsAttr"       :BCSqliteTypeMakeText(@"goodsAttr", YES),
             @"goodsThumb"      :BCSqliteTypeMakeText(@"goodsThumb", YES),
             @"modify"          :BCSqliteTypeMakeText(@"modify", YES),
             @"wp_image"        :BCSqliteTypeMakeText(@"wp_image",YES),
             @"goods_img"       :BCSqliteTypeMakeText(@"goods_img",YES),
             @"is_collect"      :BCSqliteTypeMakeText(@"is_collect",YES),
             @"is_promote"      :BCSqliteTypeMakeText(@"is_promote",YES),
             @"promote_zhekou"  :BCSqliteTypeMakeText(@"promote_zhekou",YES),
             @"is_mobile_price" :BCSqliteTypeMakeText(@"is_mobile_price",YES),
             @"is_cod"          :BCSqliteTypeMakeText(@"is_cod",YES),
             };
}

- (NSString *)description {
    return [NSString stringWithFormat:@"goodsId = %@/n,groupId = %@/n,goodsName = %@/n,goodsAttr = %@/n,goodsPrice = %@/n,promotePrice = %@/n,modify = %@/n,goodsThumb = %@/n,wp_image = %@\n,is_cod = %d",self.goodsId,self.groupId,self.goodsName,self.goodsAttr,self.goodsPrice,self.promotePrice,self.modify,self.goodsThumb,self.wp_image,self.is_cod];
}
@end
