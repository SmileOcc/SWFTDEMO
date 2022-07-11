//
//  OSSVHomeCThemeModel.m
// OSSVHomeCThemeModel
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeCThemeModel.h"

@implementation OSSVHomeCThemeModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"modeImg"   : [STLAdvEventSpecialModel class],
             @"couponButton"  : [STLAdvEventSpecialModel class],
             @"goodsList" : [STLHomeCGoodsModel class],
             @"channel"   : [STLHomeCThemeChannelModel class],
             @"slideList" : [OSSVHomeGoodsListModel class],
             @"giftList"  : [OSSVNewUserPrGoodsModel class],
             @"exchange"  : [OSSVThemeZeroPrGoodsModel class],
             @"coupon_items": [Coupon_item class]
             };
}



@end

@implementation Coupon_item

@end

@implementation STLHomeCGoodsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
           @"mark_img" : @"mark_img",
             };
}
-(OSSVHomeGoodsListModel *)exchangeHomeGoodsListModel {
    OSSVHomeGoodsListModel *homeModel = [[OSSVHomeGoodsListModel alloc] init];
    homeModel.market_price = self.market_price;
    homeModel.shop_price = self.shop_price;
    homeModel.goodsImageUrl = self.goods_img;
    homeModel.markImgUrl = self.mark_img;
    homeModel.show_discount_icon = self.show_discount_icon;
    homeModel.wid = self.wid;
    if (!STLIsEmptyString(self.goodsId)) {
        homeModel.goodsId = self.goodsId;
    }
    if (!STLIsEmptyString(self.goods_id)) {
        homeModel.goodsId = self.goods_id;
    }
    return homeModel;
}

@end


@implementation STLHomeCThemeChannelModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"goodsList" : [STLHomeCGoodsModel class]};
}

@end
