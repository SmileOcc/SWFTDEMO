//
//  BannerModel.h
//  ZZZZZ
//
//  Created by DBP on 16/10/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFCollectionCellDatasourceProtocol.h"

@interface ZFBannerModel : NSObject
<
    NSCoding,
    NSCopying,
    ZFCollectionCellDatasourceProtocol
>
/**
 * banner 高度 (需要除以 2)
 */
@property (nonatomic, copy) NSString    *banner_height;

/**
 * banner 宽度 (需要除以 2)
 */
@property (nonatomic, copy) NSString    *banner_width;
/**
 * 跳转链接
 */
@property (nonatomic, copy) NSString    *deeplink_uri;
/**
 * 剩余秒数
 */
@property (nonatomic, copy) NSString    *bannerCountDown;
/**
 * 是否显示倒计时
 */
@property (nonatomic, copy) NSString    *isShowCountDown;
/**
 * 浮窗显示次数
 */
@property (nonatomic, copy) NSString    *popupNumber;

/** 本地已经显示过的次数, [非服务端返回] */
@property (nonatomic, assign) NSInteger hasShowPopupNum;


@property (nonatomic, copy) NSString    *sortNumbers;
/**
 * 图片链接
 */
@property (nonatomic, copy) NSString    *image;
/**
 * banner标识位
 */
@property (nonatomic, copy) NSString    *banner_id;

@property (nonatomic, copy) NSString    *coupon_get_status;//用户是否已经领取优惠   2已经领过 >  3过期 4领取完 1可领取

@property (nonatomic, copy) NSString    *coupon_center_id;//

@property (nonatomic, copy) NSString    *coupon;//点击使用coupon时带过来的coupon

@property (nonatomic, copy) NSString    *name;

/**
 * 改了字段,只能兼容增加字段社区
 */
@property (nonatomic, copy) NSString    *community_deeplink_uri;

@property (nonatomic, copy) NSString    *pic_url;


/**
 * 非服务端返回 ,在请求到数据发现有倒计时定时器时才创建,页面上去接取这个key取对应的定时器
 */
@property (nonatomic, copy) NSString    *countDownTimerKey;

//自定义 保存大小
@property (nonatomic, assign) CGSize    calculateSize;

//组件Id
@property (nonatomic, copy) NSString    *componentId;

//坑位id
@property (nonatomic, copy) NSString    *colid;

//菜单id
@property (nonatomic, copy) NSString    *menuid;

@end


@interface ZFNewBannerModel : NSObject

@property (nonatomic, strong) NSArray <ZFBannerModel *>*banners;
@property (nonatomic, copy) NSString *branch;

@end
