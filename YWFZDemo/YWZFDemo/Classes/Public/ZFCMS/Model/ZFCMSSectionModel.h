//
//  ZFCMSSectionModel.h
//  ZZZZZ
//
//  Created by YW on 2018/12/8.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFBannerModel.h"
#import "ZFCMSCouponModel.h"

NS_ASSUME_NONNULL_BEGIN

/** CMS 主页组件类型 */
typedef NS_ENUM(NSInteger, ZFHomeCMSModuleType) {
    ZFCMS_BannerPop_Type        = 101,   // 弹窗
    ZFCMS_SlideBanner_Type      = 102,   // 滑动banner (此类型需要考虑子类型:ZFHomeCMSModuleSubType)
    ZFCMS_CycleBanner_Type      = 103,   // 轮播banner
    ZFCMS_BranchBanner_Type     = 105,   // 多分馆即固定
    ZFCMS_GridMode_Type         = 106,   // 平铺,格子模式 (此类型需要考虑子类型:ZFHomeCMSModuleSubType)
    ZFCMS_DropDownBanner_Type   = 107,   // 下拉banner
    ZFCMS_FloatingGBanner_Type  = 108,   // 浮窗banner
    ZFCMS_RecommendGoods_Type   = 109,   // 推荐商品栏
    ZFCMS_TextModule_Type       = 110,   // 纯文本栏目
    ZFCMS_SecKillModule_Type    = 111,   // 秒杀组件
    ZFCMS_VerCycleBanner_Type   = 112,   // 上下滑动轮播
    ZFCMS_VideoPlayer_Type      = 113,   // 视频播放组件
    ZFCMS_CouponModule_Type     = 114,   // 优惠券组件
};

/** CMS 主页组件子类型 */
typedef NS_ENUM(NSInteger, ZFHomeCMSModuleSubType) {
    ZFCMS_SkuBanner_SubType       = 1,   // 商品类型
    ZFCMS_NormalBanner_SubType    = 2,   // banner类型
    ZFCMS_HistorSku_SubType       = 3,   // 商品历史浏览记录
    ZFCMS_SkuSelection_SubType    = 4,   // 商品运营平台选品
};

/** CMS组件对齐方式，1：上左，2：上中，3：上右，4：居左，5：居中，6：居右，7：下左，8：下中，9：下右 */
typedef NS_ENUM(NSInteger, ZFCMSModulePosition) {
    /**上左*/
    ZFCMSModulePositionTopLeft = 1,
    /**上中*/
    ZFCMSModulePositionTopCenter,
    /**上右*/
    ZFCMSModulePositionTopRight,
    /**中左*/
    ZFCMSModulePositionCenterLeft,
    /**中*/
    ZFCMSModulePositionCenter,
    /**中右*/
    ZFCMSModulePositionCenterRight,
    /**下左*/
    ZFCMSModulePositionBottomLeft,
    /**下中*/
    ZFCMSModulePositionBottomCenter,
    /**下右*/
    ZFCMSModulePositionBottomRight,
};

@interface ZFCMSItemModel : NSObject
/** 坑位ID （APP用于上传大数据） */
@property (nonatomic, copy)   NSString *col_id;
/** 广告ID （APP用于上传大数据）goods_sn */
@property (nonatomic, copy)   NSString *ad_id;
/** (ZZZZZ暂时无用) */
@property (nonatomic, copy)   NSString *point_name;
/** 商品价格(后台会进行动态修改，广告为0.00) */
@property (nonatomic, copy)   NSString *shop_price;
/** 划线价格 */
@property (nonatomic, copy)   NSString *market_price;
/** 图片URL */
@property (nonatomic, copy)   NSString *image;
/** 子跳转类型(目前只有rg用到) */
@property (nonatomic, copy)   NSString *node_type;
/** 标题 */
@property (nonatomic, copy)   NSString *name;
/** Deeplink主跳转类型 */
@property (nonatomic, copy)   NSString *actionType;
/** Deeplink 跳转参数URL */
@property (nonatomic, copy)   NSString *url;
/** 倒计时总秒数，如果有倒计时则应大于0，反之没有倒计时 */
@property (nonatomic, copy)   NSString *countdown_time;
/** 父id */
@property (nonatomic, copy)   NSString *component_id;
/** 视频组件id*/
@property (nonatomic, copy)   NSString *video_id;

@property (nonatomic, copy)   NSString *coupon_id;

/**自定义*/
@property (nonatomic, strong) ZFCMSCouponModel *couponModel;


/** ================== 以下字段非服务端返回 ================== */

/** 在请求到数据发现有倒计时定时器时才创建,页面上去直接取这个key取对应的定时器 */
@property (nonatomic, copy) NSString    *countDownCMSTimerKey;
/** 可能为空, 目前只有在浏览历史记录类型的数据才有 */
@property (nonatomic, strong)   ZFGoodsModel *goodsModel;

/** 上层传入颜色*/
@property (nonatomic, strong) UIColor *textSaleColor;


// 自定义
+ (CGFloat)cmsCouponSpace;
+ (CGFloat)cmsCouponWidth:(CGFloat)width calculatHeight:(NSInteger)count;
@end



@interface ZFCMSAttributesModel : NSObject

/** 倒计时上边距 */
@property (nonatomic, assign) CGFloat countdown_padding_top;
/** 倒计时左边距 */
@property (nonatomic, assign) CGFloat countdown_padding_left;
/** 倒计时下边距 */
@property (nonatomic, assign) CGFloat countdown_padding_bottom;
/** 倒计时右边距 */
@property (nonatomic, assign) CGFloat countdown_padding_right;
/** 子项目上内边距 */
@property (nonatomic, assign) CGFloat padding_top;
/** 子项目左内边距 */
@property (nonatomic, assign) CGFloat padding_left;
/** 子项目下内边距 */
@property (nonatomic, assign) CGFloat padding_bottom;
/** 子项目右内边距 */
@property (nonatomic, assign) CGFloat padding_right;

/** 文本对齐方式，1：上左，2：上中，3：上右，4：居左，5：居中，6：居右，7：下左，8：下中，9：下右 */
@property (nonatomic, copy)   NSString *text_align;
/** 文本颜色，必须是十六进字符串，以"#"开头 */
@property (nonatomic, copy)   NSString *text_color;
/** 文本颜色UIColor对象,Cell中直接使用不用每次都重绘 */
@property (nonatomic, strong) UIColor *textColor;
/** 文本Sale颜色，必须是十六进字符串，以"#"开头 */
@property (nonatomic, copy)   NSString *text_sale_color;
/** 文本Sale颜色UIColor对象,Cell中直接使用不用每次都重绘 */
@property (nonatomic, strong) UIColor *textSaleColor;
/** 文本字体大小，单位：安卓以sp为单位，ios以pt为单位 */
@property (nonatomic, assign)  NSInteger text_size;
/** 文本内容 */
@property (nonatomic, copy)   NSString *text;

/** 优惠券*/
// 样式选择，0：默认样式、1：自定义，新增
@property (nonatomic, assign) NSInteger selection_style;
// 剩余数量，0：不显示、1：显示，新增
@property (nonatomic, assign) NSInteger remain;

///按钮文字颜色:
@property (nonatomic, copy)   NSString *btn_text_color;
///按钮未领取按钮颜色:
@property (nonatomic, copy)   NSString *not_btn_color;
///按钮已领取按钮颜色:
@property (nonatomic, copy)   NSString *got_btn_color;
///按钮已领完按钮颜色:
@property (nonatomic, copy)   NSString *finished_btn_color;
//进度条
///剩余数量文字颜色:
@property (nonatomic, copy)   NSString *range_text_color;

@property (nonatomic, copy)   NSString *cannot_text_color;
///背景色:
@property (nonatomic, copy)   NSString *range_bg_color;
///前景色:
@property (nonatomic, copy)   NSString *range_fg_color;

///背景色:
@property (nonatomic, copy)   NSString *cannot_range_color;
/** 倒计时对齐方式，1：上左，2：上中，3：上右，4：居左，5：居中，6：居右，7：下左，8：下中，9：下右 */
@property (nonatomic, copy)   NSString *countdown_align;
/** 背景颜色，必须是十六进字符串，以"#"开头 */
@property (nonatomic, copy)   NSString *bg_color;
/** 背景颜色UIColor对象,Cell中直接使用不用每次都重绘 */
@property (nonatomic, strong) UIColor *bgColor;

@end



@interface ZFCMSSectionModel : NSObject

// type:组件类型  101:弹窗   102:滑动 <考虑子类型>  103: 轮播   105:多分馆即固定   106:商品平铺 <考虑子类型>  107:下拉banner  108:浮窗banner
@property (nonatomic, assign) ZFHomeCMSModuleType type;

// subType:组件子类型  1:商品类型  2:banner类型
@property (nonatomic, assign) ZFHomeCMSModuleSubType subType;

/** 显示几列 */
@property (nonatomic, copy) NSString *display_count;
/** 图片宽高比 - 宽 */
@property (nonatomic, copy) NSString *prop_w;
/** 图片宽高比 - 高 */
@property (nonatomic, copy) NSString *prop_h;
/** 每个子项的margin-top */
@property (nonatomic, assign) CGFloat padding_top;
/** 组件的padding，左 */
@property (nonatomic, assign) CGFloat padding_left;
/** 组件的padding，下 */
@property (nonatomic, assign) CGFloat padding_bottom;
/** 组件的padding，右 */
@property (nonatomic, assign) CGFloat padding_right;

/** 每个子项的margin-left (此属性ZZZZZ已废弃, 返回是因为兼容RG) */
//@property (nonatomic, assign) CGFloat item_left;
///** 每个子项的margin-top (此属性ZZZZZ已废弃, 返回是因为兼容RG) */
//@property (nonatomic, assign) CGFloat item_top;

/** 每个坑位显示模型 */
@property (nonatomic, strong) NSMutableArray<ZFCMSItemModel *> *list;
/** 子项目属性列表 */
@property (nonatomic, strong) ZFCMSAttributesModel *attributes;
/** 组件ID （APP用于上传大数据） */
@property (nonatomic, copy)   NSString *component_id;
/** 是否是SKU  */
@property (nonatomic, assign) NSInteger is_sku;
/** 组件的背景色 */
@property (nonatomic, copy) NSString *bg_color;
/** 组件的背景色UIColor对象 */
@property (nonatomic, strong) UIColor *bgColor;
/** 组件的背景图片 */
@property (nonatomic, copy)   NSString *bg_img;
/** 推荐商品类型 */
@property (nonatomic, copy)   NSString *recommendContent;
/** 推荐商品类型 0:获取大数据推荐数据  1:实体分类数据  2:虚拟分类数据 3：固定页 4：商品运营平台选品 */
@property (nonatomic, copy)   NSString *recommendType;

/** "recommend" 推荐组件、滑动组件的排序类型 (recommend、new、hot、price_low_to_high、price_high_to_low) */
@property (nonatomic, copy)   NSString *sku_sort;
/** 滑动组件商品数量: 默认30个 */
@property (nonatomic, copy)   NSString *sku_limit;
/** 商品运营平台选品规则ID（多个用英文逗号隔开）1,2,3 */
@property (nonatomic, copy)   NSString *sku_ruleId;

// 样式选择，0：默认样式、1：自定义，新增
@property (nonatomic, assign) NSInteger selection_style;
// 剩余数量，0：不显示、1：显示，新增
@property (nonatomic, assign) NSInteger remain;


/** ================== 以下字段非服务端返回 ================== */
/** CMS列表:当前模型的Section所对应的Item个数 */
@property (nonatomic, assign) NSInteger sectionItemCount;
/** CMS列表:当前模型的Section所对应的Item大小 */
@property (nonatomic, assign) CGSize sectionItemSize;
/** 防止 滑动banner和sku模式下的collectionViewCell重用时偏移量位置不准确 */
@property (nonatomic, assign) CGFloat sliderScrollViewOffsetX;

//FIXME: occ v4.6.0
/** CMS列表:当前模型的Section cell 两行之间的上下间距 */
@property (nonatomic, assign) CGFloat              sectionMinimumLineSpacing;
/** CMS列表:当前模型的Section 两个cell之间的左右间距 */
@property (nonatomic, assign) CGFloat              sectionMinimumInteritemSpacing;
/** CMS列表:当前模型的Section 组边距 */
@property (nonatomic, assign) UIEdgeInsets         sectionInsetForSection;


// 配置Deeplink跳转模型
- (ZFBannerModel *)configDeeplinkBannerModel;

@end


NS_ASSUME_NONNULL_END
