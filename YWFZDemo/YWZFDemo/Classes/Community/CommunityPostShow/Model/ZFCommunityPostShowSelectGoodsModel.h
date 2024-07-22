//
//  ZFCommunityPostShowSelectGoodsModel.h
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CommunityGoodsType) {
    CommunityGoodsTypeHot,
    CommunityGoodsTypeWish,
    CommunityGoodsTypeBag,
    CommunityGoodsTypeOrder,
    CommunityGoodsTypeRecent
};

@interface ZFCommunityPostShowSelectGoodsModel : NSObject

@property (nonatomic,copy) NSString *imageURL;

@property (nonatomic,copy) NSString *goodsID;

@property (nonatomic, copy) NSString  *shop_price;

@property (nonatomic,assign) CommunityGoodsType goodsType;

@end
