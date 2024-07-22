//
//  JumpModel.h
//  ZZZZZ
//
//  Created by DBP on 16/10/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

//跳转页面类型 (推送,deeplink)
typedef NS_ENUM(NSInteger, JumpActionType) {
    JumpCustomDeeplinkActionType    = -2,   // 自定义deeplink类型，完整的deeplink拼接在url里
    JumpDefalutActionType           =  0,   // 默认备注，后台没有返回
    JumpHomeActionType              =  1,   // 首页
    JumpCategoryActionType          =  2,   // 分类列表类
    JumpGoodDetailActionType        =  3,   // 商品详情页
    JumpSearchActionType            =  4,   // 搜索结果页
    JumpInsertH5ActionType          =  5,   // 嵌入H5
    JumpCommunityActionType         =  6,   // 社区
    JumpExternalLinkActionType      =  7,   // 外部链接
    JumpMessageActionType           =  8,   // 消息列表
    JumpCouponActionType            =  9,   // 优惠券列表
    JumpOrderListActionType         =  10,  // 订单列表
    JumpOrderDetailActionType       =  11,  // 订单详情
    JumpCartActionType              =  12,  // 购物车列表
    JumpCollectionActionType        =  13,  // 收藏夹列表
    JumpVirtualCategoryActionType   =  14,  // 虚拟分类
    JumpNativeBannerActionType      =  15,  // 原生专题
    JumpAddToCartActionType         =  16,  // 一键加入购物车(针对推送)
    JumpChannelActionType           =  17,  // 跳转首页某个频道(针对推送)
    JumpPointsActionType            =  18,  // 积分列表页
    JumpMyShareActionType           =  19,  // 我的分享页面
    JumpNewUserActivetType          =  20,  // 新人专享RN
    JumpLiveChatActionType          =  21,  // 跳转LiveChat客服页面
    JumpHandpickGoodsListType       =  22,  // 跳转到精选商品列表页面
    JumpHandpickLiveListType        =  23,  // 跳转到视频直播列表
    JumpHandpickLiveBroadcastType   =  24,  // 跳转到视频直播播放
    JumpMultipleActionType          =  25,  // 多重嵌套跳转（多个页面叠加）
    JumpOrderReviewsActionType      =  26,  // 跳转到订单评论页
    JumpOrderAddressEidtActionType  =  27,  // 跳转到订单地址编辑页
    JumpHandpickZegoLiveBroadcastType  =  28,  // 跳转到视频直播播放(ZEGO直播)
    JumpGeshopNewNativeThemeType    =  29,  // 跳转到Geshop新原生专题页面

};

///推送新增 pts 参数，用于后台AI 实验
@interface ZFPushPtsModel : NSObject

@property (nonatomic, copy) NSString *plancode;
@property (nonatomic, copy) NSString *versionid;
@property (nonatomic, copy) NSString *bucketid;
@property (nonatomic, copy) NSString *planid;
@property (nonatomic, copy) NSString *policy;

@end


@interface JumpModel : NSObject <NSCoding>

@property (nonatomic, assign) JumpActionType actionType; // 跳转类型
@property (nonatomic, copy) NSString *url;  // 很多东西。(HTML5页面URL 或 频道id) goodsId + wid,（不只是一个简单类型）
@property (nonatomic, copy) NSString *name; // 跳转后的标题 导购词
///深度链接来源,用于统计
@property (nonatomic, copy) NSString *source;
///分类页/搜索结果页SKU置顶显示
@property (nonatomic, copy) NSString *featuring;

//实验参数
@property (nonatomic, copy) NSString *bucketid;
@property (nonatomic, copy) NSString *versionid;
@property (nonatomic, copy) NSString *planid;


@property (nonatomic, copy) NSString *startTime; // 活动开始时间
@property (nonatomic, copy) NSString *endTime; // 活动结束时间
@property (nonatomic, copy) NSString *bannerId; //  (banner主键)


@property (nonatomic, assign) BOOL isShare; // 是否分享  == (是否分享 0否 1是)
@property (nonatomic, copy) NSString *shareTitle; // 分享标题
@property (nonatomic, copy) NSString *imageURL; // 图片的路径 展示
@property (nonatomic, copy) NSString *shareImageURL; // 分享小图片链接
@property (nonatomic, copy) NSString *shareLinkURL; // 分享地址
@property (nonatomic, copy) NSString *shareDoc; // 分享文案

@property (nonatomic, copy) NSString *leftTime; // 剩余时间
@property (nonatomic, copy) NSString *serverTime; // 服务器时间，我们要做倒计时

@property (nonatomic, copy) NSString   *refine;
@property (nonatomic, copy) NSString   *sort;
@property (nonatomic, copy) NSString   *minprice;
@property (nonatomic, copy) NSString   *maxprice;

@property (nonatomic, assign) BOOL  isCouponListDeeplink; //是否为优惠券列表的deeplink

@property (nonatomic, strong) ZFPushPtsModel *pushPtsModel;

@property (nonatomic, copy) NSString   *giftId; //V4.4增加跳商详满赠id

@property (nonatomic, copy) NSString   *coupon; //V4.5.5增加coupon使用的deeplink带过来的参数

@property (nonatomic, assign) BOOL img_is_show; // 搜索推荐热词是否显示图标

@property (nonatomic, copy) NSString *imgSrc; // 搜索热词图标

@property (nonatomic, copy) NSString *color; // 搜索热词文字颜色

@property (nonatomic, assign) BOOL noNeedAnimated;  // 不需要转场动画

@end
