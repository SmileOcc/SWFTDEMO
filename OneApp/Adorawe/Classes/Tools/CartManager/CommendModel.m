//
//  CommendModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "CommendModel.h"

@implementation CommendModel

- (NSString *)showImageUrl {
    if (_coverImgUrl.length > 0) {
        return _coverImgUrl;
    }
    
    if (_goodsThumb.length > 0) {
        return _goodsThumb;
    }
    return _goodsBigImg;
}
+(NSString*)tableName
{
    return kCommendTableName;
}

+(NSDictionary*)tableEntityMapping
{
    return @{
             @"rowid"     :BCSqliteTypeMakeTextPrimaryKey(@"rowid", NO),
             @"goodsId"     :BCSqliteTypeMakeText(@"goodsId", YES),
             @"goodsSn"     :BCSqliteTypeMakeText(@"goodsSn", YES),
             @"goodsGroupId":BCSqliteTypeMakeText(@"goodsGroupId", YES),
             @"goodsTitle"   :BCSqliteTypeMakeText(@"goodsTitle", YES),
             @"shop_price"   :BCSqliteTypeMakeText(@"shop_price", YES),
             @"goodsPrice"   :BCSqliteTypeMakeText(@"goodsPrice", YES),
             @"goodsAttr"   :BCSqliteTypeMakeText(@"goodsAttr", YES),
             @"goodsThumb"   :BCSqliteTypeMakeText(@"goodsThumb", YES),
             @"coverImgUrl"   :BCSqliteTypeMakeText(@"coverImgUrl", YES),
             @"goodsBigImg"   :BCSqliteTypeMakeText(@"goodsBigImg", YES),
             @"modify"   :BCSqliteTypeMakeText(@"modify", YES),
//             @"warehouseCode"   :BCSqliteTypeMakeText(@"warehouseCode", YES),
             @"wid"   :BCSqliteTypeMakeText(@"wid", YES),
             @"cat_name"     :BCSqliteTypeMakeText(@"cat_name", YES),
             @"cat_id"     :BCSqliteTypeMakeText(@"cat_id", YES),
             @"shop_price_converted"     :BCSqliteTypeMakeText(@"shop_price_converted", YES),
             @"market_price_converted"     :BCSqliteTypeMakeText(@"market_price_converted", YES),
             };
}

- (NSString *)description {
    return [NSString stringWithFormat:@"goodsId = %@/n,goodsSn = %@/n,goodsTitle = %@/n,goodsAttr = %@/n,shop_price = %@/n,goodsPrice = %@/n,modify = %@/n,wid = %@/n,goodsThumb = %@/n,coverImgUrl = %@/n,goodsBigImg = %@/n,catName = %@/n,catId = %@/n,market_price_converted=%@/n,market_price_converted=%@/n",self.goodsId,self.goodsSn,self.goodsTitle,self.goodsAttr,self.shop_price,self.goodsPrice,self.modify,self.wid,self.goodsThumb,self.coverImgUrl,self.goodsBigImg,self.cat_name,self.cat_id,self.shop_price_converted,self.market_price_converted];
}


-(instancetype)initWith:(OSSVGoodsListModel *)goodListModel{
    if( self = [super init]){
        self.goodsBigImg = goodListModel.goodsImg;
        self.goodsTitle = goodListModel.goodsTitle;
        self.wid = goodListModel.wid;
        self.goodsSn = goodListModel.goods_sn;
        self.shop_price_converted = goodListModel.shop_price_converted;
        self.market_price_converted = goodListModel.market_price_converted;
        self.goodsId = goodListModel.goodsId;
    }
    return self;
    
}
@end
