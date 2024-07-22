//
//  ZFZegoMessageInfo.h
//  ZZZZZ
//
//  Created by YW on 2019/8/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZegoLiveRoom/ZegoLiveRoomApiDefines-IM.h>

#import "ZFThemeManager.h"

typedef NS_ENUM(NSInteger, ZegoMessageInfoType) {
    /** 用户消息*/
    ZegoMessageInfoTypeUser = -1,
    
    ZegoMessageInfoTypeUnknow = 0,
    /** 商品数据*/
    ZegoMessageInfoTypeGoods = 1,
    /** 优惠券数据*/
    ZegoMessageInfoTypeCoupon,
    /** 点赞*/
    ZegoMessageInfoTypeLike,
    /** 评论*/
    ZegoMessageInfoTypeComment,
    /** 加购*/
    ZegoMessageInfoTypeCart,
    /** 下单成功*/
    ZegoMessageInfoTypeOrder,
    /** 付款*/
    ZegoMessageInfoTypePay,
    /** 系统交互信息*/
    ZegoMessageInfoTypeSystem,
    /** 直播结束*/
    ZegoMessageInfoTypeLiveEnd,
};
NS_ASSUME_NONNULL_BEGIN

@interface ZFZegoMessageInfo : NSObject

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) id content;
@property (nonatomic, copy) NSString *live_id;
@property (nonatomic, copy) NSString *add_time;
@property (nonatomic, strong) NSDictionary *contentObj;

@property (nonatomic, assign) ZegoMessageInfoType infoType;

@property (nonatomic, strong) ZegoUserState *userState;

@property (nonatomic, copy) NSMutableAttributedString    *normalAttributeString;
/** 用于横屏*/
@property (nonatomic, copy) NSMutableAttributedString    *specialAttributeString;
/** 移动消息*/
@property (nonatomic, copy) NSMutableAttributedString    *moveAttributeString;

@end

NS_ASSUME_NONNULL_END

/**
1=>'商品数据',2=>'优惠券数据',3=>'点赞',4=>'评论',5=>'加购',6=>'下单成功',7=>'付款',8=>'系统交互信息'


商品数据
{
    "type": 1,
    "content": {
        "goods_id": "559431",
        "goods_sn": "270988310",
        "cat_id": "34",
        "cat_name": "Hats",
        "title": "Fashion Unisex Classic Trucker Baseball Golf Mesh Cap Hat vintage question mark women men hip-hop baseball cap",
        "market_price": "38.37",
        "url": "http://www.pc-ZZZZZ.com.master.php5.egomsl.com/fashion-unisex-classic-trucker-baseball-golf-mesh-cap-hat-vintage-question-mark-women-men-hip-hop-baseball-cap-p_559431.html",
        "pic_url": "https://gloimg.ywzf.com/ZZZZZ/pdm-product-pic/Maiyang/2018/06/07/goods-img/1535309257901554836.jpg",
        "goods_cate_detail": {
            "parent_cat_list": [
                                {
                                "cat_id": "4",
                                "cat_name": "Accessories"
                                }
                                ],
            "child_cat_list": []
        },
        "goods_is_on_sale": 1,
        "shop_price": "27.49"
    }
conteObj: {
}
}


优惠券数据
{
    "type": 2,
    "content": {
        "couponId": "1153",
        "endTime": "Aug. 29, 2019 at 11:00:00 AM",
        "discounts": "$2 off $9+ ",
        "preferentialHead": "",
        "preferentialFirst": "$2 off $9+ ",
        "noMail": "0",
        "couponStats": 1
    }
}

点赞
{
    "type": 3,
    "content": 14
}

评论
{
    "type": 4,
    "nickname": "0*****7",
    "content": "test"
}

加购
{
    "type": 5,
    "nickname": "B*****a",
    "content": "Added successfully"
}

下单成功
{
    "type": 6,
    "nickname": "N*****e",
    "content": "Order submitted"
}

付款
{
    "type": 7,
    "nickname": "A*****p",
    "content": "Paid successfully"
}

系统交互信息
{
    "type": 8,
    "nickname": "B*****h",
    "content": "Enter livestream room. Will purchase the item soon."
}
 */
