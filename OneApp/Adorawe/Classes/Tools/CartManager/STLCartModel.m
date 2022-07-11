//
//  STLCartModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLCartModel.h"

@implementation STLCartModel


- (void)handleCartGoodsCount {
    [self allValidGoods];
    
}
- (NSMutableArray<CartModel*> *)allValidGoods {
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    
    __block NSInteger allValidGoodsNumber = 0;

    [self.groupList enumerateObjectsUsingBlock:^(STLCartGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.type == CartGroupModelTypeActivity) {
            STLCatrActivityModel *activityModel = (STLCatrActivityModel *)obj.data;
            [activityModel.goodsList enumerateObjectsUsingBlock:^(CartModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
                [tempArr addObject:model];
                allValidGoodsNumber += model.goodsNumber;
            }];
        } else if(obj.type == CartGroupModelTypeNormal) {
            NSArray *otherGoodsList = (NSArray *)obj.data;
            [otherGoodsList enumerateObjectsUsingBlock:^(CartModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
                [tempArr addObject:model];
                allValidGoodsNumber += model.goodsNumber;
            }];
            
        }
//        else if(obj.type == CartGroupModelTypeFree) {
//            NSArray *freeGoodsList = (NSArray *)obj.data;
//            [freeGoodsList enumerateObjectsUsingBlock:^(CartModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
//                [tempArr addObject:model];
//                allValidGoodsNumber += model.goodsNumber;
//            }];
//        }
    }];
    
    [[OSSVCartsOperateManager sharedManager] cartSaveValidGoodsAllCount:allValidGoodsNumber];

    return tempArr;
}

- (NSMutableArray<CartModel*> *)allSelectGoods {
    NSMutableArray *allGoods = [self allValidGoods];
    NSMutableArray *selectGoods = [[NSMutableArray alloc] init];
    [allGoods enumerateObjectsUsingBlock:^(CartModel * _Nonnull cartModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (cartModel.isChecked) {
            [selectGoods addObject:cartModel];
        }
    }];
    
    return selectGoods;
}


- (void)handleGroupData {
    
    //满减活动提示语
    NSArray *bundGoodsList = self.bundGoodsList;
    [bundGoodsList enumerateObjectsUsingBlock:^(STLCatrActivityModel   * _Nonnull activityModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (activityModel.activityInfo) {
            [activityModel.activityInfo compareHeaderHeight];
        }
    }];
    
    
    //推荐同类
    NSMutableArray *likeGoodsArr = [[NSMutableArray alloc] init];
    __block NSMutableArray *tempArr = nil;
    [self.likeGoods.goods
 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx % 2 == 0) {
            tempArr = [[NSMutableArray alloc] init];
            [likeGoodsArr addObject:tempArr];
        }
        [tempArr addObject:obj];
    }];
    self.likeGoodsArray = likeGoodsArr;
    
    NSMutableArray *tempGroups = [[NSMutableArray alloc] init];
    //排序字段
    NSArray *positonArr = [self.positionSort componentsSeparatedByString:@","];
    for (NSString *str in positonArr) {
        if ([str isEqualToString:@"bundGoodsList"]) {//满减活动
            [self.bundGoodsList enumerateObjectsUsingBlock:^(STLCatrActivityModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.goodsList.count > 0) {
                    STLCartGroupModel *groupModel = [[STLCartGroupModel alloc] init];
                    groupModel.type = CartGroupModelTypeActivity;
                    groupModel.data = obj;
                    [tempGroups addObject:groupModel];
                }
            }];
        } else if ([str isEqualToString:@"goods_list"]) {
            if (self.otherGoodsList.count > 0) {
                STLCartGroupModel *groupModel = [[STLCartGroupModel alloc] init];
                groupModel.type = CartGroupModelTypeNormal;
                groupModel.data = self.otherGoodsList;
                [tempGroups addObject:groupModel];
            }
        }
//        else if ([str isEqualToString:@"freeGiftList"]) {
//            if (self.freeGiftList.count > 0) {
//                STLCartGroupModel *groupModel = [[STLCartGroupModel alloc] init];
//                groupModel.type = CartGroupModelTypeFree;
//                groupModel.data = self.freeGiftList;
//                [tempGroups addObject:groupModel];
//            }
//        }
    }
    
    //失效商品
    if(self.failureGoodsList.count > 0) {
        STLCartGroupModel *groupModel = [[STLCartGroupModel alloc] init];
        groupModel.type = CartGroupModelTypeFailure;
        groupModel.data = self.failureGoodsList;
        [tempGroups addObject:groupModel];
    }
    
    //添加空视图: 如果只有推荐商品
    if (tempGroups.count == 0 && self.likeGoodsArray.count > 0) {
        STLCartGroupModel *groupModel = [[STLCartGroupModel alloc] init];
        groupModel.type = CartGroupModelTypeEmpty;
        [tempGroups addObject:groupModel];
    }

    //推荐同类
    if(self.likeGoodsArray.count > 0) {
        STLCartGroupModel *groupModel = [[STLCartGroupModel alloc] init];
        groupModel.type = CartGroupModelTypeRecommend;
        groupModel.data = self.likeGoodsArray;
        groupModel.titleModel = self.likeGoods.title;
        [tempGroups addObject:groupModel];
    }
    
    self.groupList = [[NSArray alloc] initWithArray:tempGroups];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"bundGoodsList" : @"bundGoodsList",
             @"otherGoodsList" : @"goods_list",
             @"failureGoodsList": @"failureGoodsList",
             @"likeGoods" : @"likeGoods",
//             @"freeGiftList" : @"freeGiftList",
             @"positionSort": @"positionSort",
             @"cartTips" : @"cart_tip",
             @"cartInfo" : @"cartInfo",
             @"codConf"  : @"codConf",
             @"needBuy"  : @"needBuy",
             @"userid" : @"userid",
             @"discountMsg" : @"max_discount_msg",
             @"discountValue" : @"max_discount_value",
             @"freeShippingTip": @"shipping_tip",
             @"vivaiaFreeShipping": @"free_shipping_info"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"bundGoodsList"      : [STLCatrActivityModel class],
             @"otherGoodsList"     : [CartModel class],
             @"failureGoodsList"   : [CartModel class],
             @"likeGoods"          : [STLCartLikeGoodsModel class],
//             @"freeGiftList"       : [CartModel class],
             @"cartInfo"           : [CartInfoModel class],
             @"needBuy"            : [CartNeedBuyModel class],
             @"codConf"            : [CodConfModel class],
             @"freeShippingTip"    : [OSSVCartFreeShippingModel class],
             @"vivaiaFreeShipping" : [OSSVVivaiaCartFreeShippingModel class]
             };
}


// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[
             @"bundGoodsList",
             @"otherGoodsList",
             @"failureGoodsList",
             @"likeGoods",
//             @"freeGiftList",
             @"positionSort",
             @"cartTips",
             @"cartInfo",
             @"codConf",
             @"needBuy",
             @"userid",
             @"top_notice",
             @"discountMsg",
             @"discountValue",
             @"freeShippingTip",
             @"vivaiaFreeShipping"
             ];
}


@end


///////////////////=== 表示集合Model ===//////////////////////

@implementation STLCartGroupModel


@end;



// ============================== 购物车金额 =========================== //
@implementation CartInfoModel

@end;


// ============================== 限制金额提示 =========================== //
@implementation CodConfModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"minAmount" : @"min_amount",
             @"maxAmount" : @"max_amount"
             };
}

@end;


// ============================== 限制金额提示 =========================== //
@implementation CartNeedBuyModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"content" : @"content",
             @"idx"     : @"id",
             @"title"   : @"title",
             };
}

@end;


