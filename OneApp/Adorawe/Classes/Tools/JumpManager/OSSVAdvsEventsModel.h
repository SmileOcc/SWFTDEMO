//
//  OSSVAdvsEventsModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RateModel;
@class STLAdvEventSpecialModel;
@interface OSSVAdvsEventsModel : NSObject <NSCoding>

#define DeepLinkModel @"kDeepLinkModel"

@property (nonatomic, assign) AdvEventType actionType; // 跳转类型
@property (nonatomic, copy) NSString *url; // 很多东西。(HTML5页面URL 或 频道id) goodsId + wid,（不只是一个简单类型）
@property (nonatomic, copy) NSString *webtype; // h5_invite...网页类型  （暂时只用于商品详情）
@property (nonatomic, copy) NSString *name; // 跳转后的标题 导购词
@property (nonatomic, copy) NSString *startTime; // 活动开始时间
@property (nonatomic, copy) NSString *endTime; // 活动结束时间
@property (nonatomic, copy) NSString *bannerId; //  (banner主键)
@property (nonatomic, copy) NSString *banner_name; //  (banner主键)
@property (nonatomic, assign) BOOL isShare; // 是否分享  == (是否分享 0否 1是)
@property (nonatomic, copy) NSString *shareTitle; // 分享标题
@property (nonatomic, copy) NSString *imageURL; // 图片的路径 展示
//@property (nonatomic, copy) NSString *arImageURL; // 图片的路径 展示
@property (nonatomic, copy) NSString *shareImageURL; // 分享小图片链接
@property (nonatomic, copy) NSString *shareLinkURL; // 分享地址
@property (nonatomic, copy) NSString *shareDoc; // 分享文案

@property (nonatomic, copy) NSString *leftTime; // 剩余时间
@property (nonatomic, copy) NSString *serverTime; // 服务器时间，我们要做倒计时

@property (nonatomic, copy) NSString *width; // (频道 banner宽)
@property (nonatomic, copy) NSString *height; // (频道 banner高)

@property (nonatomic, copy) NSString *popupNumber; // 广告弹窗次数

@property (nonatomic, strong) NSDictionary *info;// banner 字典

//卡片活动标识
@property (nonatomic, copy) NSString *popupType;

//自定义
@property (nonatomic, assign) AdverType     advType;
@property (nonatomic, copy) NSString *sourceDeeplinkUrl;
//***跑马灯新增字段*****//
//字体颜色
@property (nonatomic, copy) NSString *marqueeColor;
//背景颜色
@property (nonatomic, copy) NSString *marqueeBgColor;
//文字内容
@property (nonatomic, copy) NSString *marqueeText;

@property (nonatomic, copy) NSString        *popupShowNumber; //广告弹窗还能显示次数

///自定义 消息中心id
@property (nonatomic, copy) NSString *msgId;
///自定义 分馆父类ID
@property (nonatomic, copy) NSString *parentId;

@property (nonatomic, assign) CGFloat    paoMaDengWidt;

///自定义
@property (nonatomic, copy) NSString *banner_height;
@property (nonatomic, copy) NSString *banner_width;

@property (nonatomic, copy) NSString *keyCotent;

///国家IP
@property (nonatomic, copy) NSString *country_site;

///H5 推荐ID
@property (nonatomic, copy) NSString *request_id;

-(instancetype)initWhtiSpecialModel:(STLAdvEventSpecialModel *)model;

- (AdvEventType)advActionType;
- (NSString *)advActionUrl;
@end


//原生自定义专题跳转模型

@interface STLAdvEventSpecialModel : NSObject
@property (nonatomic, copy) NSString *images;
@property (nonatomic, assign) AdvEventType pageType;
@property (nonatomic, copy) NSString *shareImg;
@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, copy) NSString *imagesWidth;
@property (nonatomic, copy) NSString *isShare;
@property (nonatomic, copy) NSString *shareUrl;
@property (nonatomic, copy) NSString *imagesHeight;
@property (nonatomic, copy) NSString *shareDoc;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL   hasRule;

//当pageType为8，表示一键领取coupon
@property (nonatomic, copy) NSString *coupon;
@end



