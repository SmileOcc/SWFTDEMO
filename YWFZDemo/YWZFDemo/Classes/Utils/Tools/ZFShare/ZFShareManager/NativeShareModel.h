//
//  NativeShareModel.h
//  ZZZZZ
//
//  Created by YW on 31/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * 分享来自哪个页面类型
 */
typedef NS_ENUM(NSUInteger, ZFSharePageType) {
    ZFSharePage_H5_ShareType = 0,               //H5调原生分享: H5_Share
    ZFSharePage_NativeBannerType,               //原生专题: ThematicTemplate
    ZFSharePage_GroupPurchaseType,              //原生的团购: GroupPurchase
    ZFSharePage_ProductDetailType,              //商品详情: ProductDetail
    ZFSharePage_CommunityTopicsDetailType,      //社区话题详情：Community_Topics_Detail
    ZFSharePage_CommunityTopicsDetailListType,  //社区话题详情的帖子列表: Community_Topics_Detail_List（旧的页面，已不显示）
    ZFSharePage_CommunityFavesType,             //社区Faves列表: Community_Faves（旧的页面，已不显示）
    ZFSharePage_CommunityPostDetailType,        //社区帖子详情: Community_Post_Detail
    ZFSharePage_Live_DetailType,                //社区视频详情: Live_Detail
    ZFSharePage_CommunityStyleCenterType,       //社区个人中心: Community_Style_Center
    ZFSharePage_CommunitySearchFriendsType,     //社区个人中心搜索朋友: Community_Search_Friends
};

@interface NativeShareModel : NSObject
/**
 * 分享标题
 */
@property (nonatomic, copy) NSString   *share_title;
/**
 * 分享描述
 */
@property (nonatomic, copy) NSString   *share_description;

/**
 * 分享图片链接(其他平台)
 * 这个属性主要用于测试环境,fb构建分享的时候,此字段已失效,但不传会分享失败
 */
@property (nonatomic, copy) NSString   *share_imageURL;

/**
 * 分享链接
 */
@property (nonatomic, copy) NSString   *share_url;

/**
 * facebook 专用
 */
@property (nonatomic, weak) UIViewController   *fromviewController;

/**
 * 分享来自哪个页面类型 (用于分享链接追踪参数)
 */
@property (nonatomic, assign) ZFSharePageType   sharePageType;


/// 分享页面追踪参数
- (NSString *)fetchSharePageTypeString;

@end

