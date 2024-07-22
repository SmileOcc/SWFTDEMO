//
//  ZFGeshopSectionModel.h
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ZFGeshopSectionModel, ZFGeshopSectionListModel;
typedef void(^GeshopClickCycleBannerBlock)(ZFGeshopSectionListModel *);
typedef void(^GeshopClickNavigationItemBlock)(ZFGeshopSectionListModel *, CGFloat );
typedef void(^GeshopClickSiftItemBlock)(ZFGeshopSectionModel *, CGFloat, NSInteger, BOOL);

typedef NS_ENUM(NSInteger, ZFGeshopCellType) {
    ZFGeshopBaseCellType            = 0,
    ZFGeshopTextImageCellType       = 100,      // 文本(标题栏)组件
    ZFGeshopCycleBannerCellType     = 101,      // 轮播组件
    ZFGeshopNavigationCellType      = 102,      // 水平导航组件
    ZFGeshopGridGoodsCellType       = 103,      // 商品组件
    ZFGeshopSiftGoodsCellType       = 104,      // 筛选组件
    ZFGeshopSecKillSuperCellType    = 105,      // 秒杀组件
};

@interface ZFGeshopSectionListModel : NSObject

/** 导航组件(非服务端返回) */
@property (nonatomic, assign) CGFloat navigatorItemWidth;
/** 导航组件id */
@property (nonatomic, copy) NSString *component_id;
/** 导航文本 */
@property (nonatomic, copy) NSString *component_title;
////导航组件Item:是否已经选中
@property (nonatomic, assign) BOOL isActiveNavigatorItem;
@property (nonatomic) NSRange selectedRange;

/** 组件跳转地址 */
@property (nonatomic, copy) NSString *link_app;///恶心的Geshop,字段都不统一
@property (nonatomic, copy) NSString *jump_link;
/** 组件显示图片地址 */
@property (nonatomic, copy) NSString *image;
/** 以下为商品的模型属性 */
@property (nonatomic, copy) NSString *goods_title;
@property (nonatomic, copy) NSString *goods_id;
@property (nonatomic, copy) NSString *goods_sn;
@property (nonatomic, copy) NSString *goods_img;
@property (nonatomic, assign) NSInteger goods_number;
@property (nonatomic, copy) NSString *is_on_sale;

@property (nonatomic, assign) NSInteger discount;//(市场价/秒杀价) * 100
@property (nonatomic, assign) NSInteger stock_num;//可销售库存
@property (nonatomic, assign) NSInteger tsk_total_num;//秒杀总数量
@property (nonatomic, assign) NSInteger tsk_sale_num;//已秒杀数量
@property (nonatomic, copy) NSString *tsk_price;//秒杀价格

@property (nonatomic, copy) NSString *market_price;
@property (nonatomic, copy) NSString *shop_price;
@property (nonatomic, copy) NSString *catid;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *goods_left;
@property (nonatomic, assign) NSInteger left_percent;

/** GIO统计字段 */
@property (nonatomic, copy) NSString *ad_name;
@property (nonatomic, copy) NSString *ad_id;
@property (nonatomic, copy) NSString *floor_id;
@end


@interface ZFGeshopSiftItemModel : NSObject
@property (nonatomic, copy) NSString *ad_id;
@property (nonatomic, copy) NSString *ad_name;
@property (nonatomic, copy) NSString *item_id;
@property (nonatomic, copy) NSString *item_type;
@property (nonatomic, copy) NSString *item_title;
@property (nonatomic, copy) NSString *item_count;
@property (nonatomic, copy) NSString *item_color_code;
@property (nonatomic, copy) NSString *price_max;//是价格栏才有值
@property (nonatomic, copy) NSString *price_min;//是价格栏才有值
@property (nonatomic, strong) NSArray <ZFGeshopSiftItemModel *> *child_item;

/**==================== 以下字段非服务端返回 ====================*/

/// 每个Section下的所有itemModel
@property (nonatomic, strong) NSMutableArray <ZFGeshopSiftItemModel *> *selectionAllChildItemArr;
@property (nonatomic, strong) NSArray <ZFGeshopSiftItemModel *> *lastSelectionAllOpenChildItemArr;

/// 价格类型:只用于价格
@property (nonatomic, assign) BOOL               typePrice;
@property (nonatomic, assign) BOOL               hasOpenChild;// 是否打开了子级
@property (nonatomic, assign) NSInteger          childLevel;//层级

/**==================== 筛选弹窗 ====================*/
///是否选中组头
@property (nonatomic, assign) BOOL               isHeaderSelected;
///是否选中
@property (nonatomic, assign) BOOL               isCurrentSelected;
///计算内容大小
@property (nonatomic, assign) CGSize             itemsSize;
///自定义编辑 区间大小
@property (nonatomic, copy) NSString             *editMin;
@property (nonatomic, copy) NSString             *editMax;
///默认值本地化显示
@property (nonatomic, copy) NSString             *localCurrencyMin;
@property (nonatomic, copy) NSString             *localCurrencyMax;
/// 拼接item_title + item_count
@property (nonatomic, copy) NSString             *editName;

/// 筛选弹窗 首次是否显示一行
@property (nonatomic, assign) BOOL               isFirstShowLine;
/// 筛选弹窗 是否支持显示多行
@property (nonatomic, assign) BOOL               isMultiLine;
/// 筛选弹窗 首次显示一行时，对应显示个数
@property (nonatomic, assign) NSInteger          firstShowCounts;

/// 弹窗选择对应子集
@property (nonatomic, strong) NSArray <ZFGeshopSiftItemModel *> *selectItems;
@end


@interface ZFGeshopPaginationModel : NSObject
@property (nonatomic, assign) NSInteger page_num;
@property (nonatomic, assign) NSInteger total_count;
@property (nonatomic, assign) NSInteger page_size;
@end

@interface ZFGeshopComponentDataModel : NSObject
/** 组件文案 */
@property (nonatomic, copy) NSString *title;
/** 点击组件跳转地址 */
@property (nonatomic, copy) NSString *jump_link;
/** 新老用户人群 */
@property (nonatomic, copy) NSString *userGroup;
/** GIO统计字段 */
@property (nonatomic, copy) NSString *ad_name;
@property (nonatomic, copy) NSString *ad_id;
@property (nonatomic, copy) NSString *floor_id;

/** 秒杀组件倒计时字段 */
@property (nonatomic, copy) NSString *tsk_begin_time;
@property (nonatomic, copy) NSString *tsk_end_time;
@property (nonatomic, copy) NSString *countdown_time;
@property (nonatomic, copy) NSString *geshopCountDownTimerKey;
/** 秒杀状态(非服务端返回): 0:默认 1:还未开始 2:已经开始 3:已经结束 */
@property (nonatomic, assign) NSInteger countDownStatus;

/** 筛选组件的关联商品组件id */
@property (nonatomic, copy) NSString *connection;

/** 新版本的list全部放在component_data的list里面 */
@property (nonatomic, strong) NSMutableArray<ZFGeshopSectionListModel *> *list;

/** 筛选组件字段:Category */
@property (nonatomic, strong) NSArray <ZFGeshopSiftItemModel *> *category_list;

/** 筛选组件字段:Sort */
@property (nonatomic, strong) NSArray <ZFGeshopSiftItemModel *> *sort_list;

/** 筛选组件字段:Refine */
@property (nonatomic, strong) NSArray <ZFGeshopSiftItemModel *> *refine_list;
@end


@interface ZFGeshopComponentStyleModel : NSObject
/** 组件背景图片 */
@property (nonatomic, copy)  NSString *bg_img;
/** 组件背景颜色，必须是十六进字符串，以"#"开头 */
@property (nonatomic, copy) NSString *bg_color;
//组件上边距，默认值为0，单位：安卓以dp为单位，ios以pt为单位
@property (nonatomic, assign) CGFloat margin_top;
//组件下边距，默认值为0，
@property (nonatomic, assign) CGFloat margin_bottom;
//文本字体大小，
@property (nonatomic, assign) CGFloat text_size;
//文本颜色，必须是十六进字符串，以"#"开头
@property (nonatomic, copy) NSString *text_color;
//文本样式，是否加粗，1加粗，0正常显示
@property (nonatomic, assign) NSInteger text_style;
//子项目宽度，图片宽度和高度正确比例即可，默认值为1，忽略单位
@property (nonatomic, assign) CGFloat width;
//子项目高度，图片宽度和高度正确比例即可，默认值为1，忽略单位
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat padding_top;
@property (nonatomic, assign) CGFloat padding_bottom;
//导航组件左内边距，默认值为0，
@property (nonatomic, assign) CGFloat padding_left;
//导航组件右内边距，默认值为0，
@property (nonatomic, assign) CGFloat padding_right;
//导航组件选中的文字颜色
@property (nonatomic, copy) NSString *active_text_color;
//导航组件选中的背景颜色
@property (nonatomic, copy) NSString *active_bg_color;
//商品组件:是否显示整体样式，1显示整体样式，0显示单个样式
@property (nonatomic, assign) NSInteger box_is_whole;
//商品组件:最外层背景圆角
@property (nonatomic, assign) CGFloat bg_radius;
//商品组件: 单个商品圆角半径，默认值为0
@property (nonatomic, assign) CGFloat item_radius;

@property (nonatomic, copy) NSString *time_text_color;
@property (nonatomic, copy) NSString *time_text_bg_color;
@property (nonatomic, copy) NSString *text_bg_color;
@property (nonatomic, copy) NSString *shop_price_color;
@property (nonatomic, copy) NSString *market_price_color;
@property (nonatomic, copy) NSString *bar_bg_color;
@property (nonatomic, copy) NSString *bar_left_bg_color;
@property (nonatomic, copy) NSString *bar_text_color;
@property (nonatomic, copy) NSString *buynow_bg_color;
@property (nonatomic, copy) NSString *buynow_text_color;
@end


@interface ZFGeshopShopPriceStyleModel : NSObject
/** 销售价文本颜色，必须是十六进字符串，以"#"开头 */
@property (nonatomic, copy)   NSString *text_color;
/** 销售价文本内容 */
@property (nonatomic, copy) NSString *text;
@end


@interface ZFGeshopDiscountStyleModel : NSObject
/** 是否显示折扣标:1为显示，0不显示 */
@property (nonatomic, assign) NSInteger show;
/** 折扣标显示格式: [0: **%， 1： **%OFF] */
@property (nonatomic, assign) NSInteger type;
//折扣标宽度，图片宽度和高度正确比例即可，默认值为1，忽略单位
@property (nonatomic, assign) CGFloat width;
//折扣标高度，图片宽度和高度正确比例即可，默认值为1，忽略单位
@property (nonatomic, assign) CGFloat height;
//折扣标上外边距，默认值为0，单位：安卓以dp为单位，ios以pt为单位
@property (nonatomic, assign) CGFloat margin_top;
//折扣标右外边距，默认值为0，单位：安卓以dp为单位，ios以pt为单位
@property (nonatomic, assign) CGFloat margin_right;
//组件背景图片
@property (nonatomic, copy) NSString *bg_img;
//组件背景颜色，必须是十六进字符串，以"#"开头
@property (nonatomic, copy) NSString *bg_color;
//文本颜色，必须是十六进字符串，以"#"开头
@property (nonatomic, copy) NSString *text_color;
//文本字体大小，单位：安卓以sp为单位，ios以pt为单位
@property (nonatomic, assign) CGFloat text_size;
//折扣标上内边距，折扣文本距离折扣黑色背景边距
@property (nonatomic, assign) CGFloat padding_top;
//折扣标右内边距，折扣文本距离折扣黑色背景边距
@property (nonatomic, assign) CGFloat padding_right;
@end





@interface ZFGeshopSectionModel : NSObject


/** 列表Section类型 */
@property (nonatomic, assign) ZFGeshopCellType component_type;
/** 组件id */
@property (nonatomic, copy) NSString *component_id;
/** 组件名 */
@property (nonatomic, copy) NSString *component_name;

/** 组件里面的内容 */
@property (nonatomic, strong) ZFGeshopComponentDataModel *component_data;

/** 筛选商品时返回的分页 */
@property (nonatomic, strong) ZFGeshopPaginationModel *pagination;

/** 组件样式列表 */
@property (nonatomic, strong) ZFGeshopComponentStyleModel *component_style;

/** 商品组件中价格样式内容 */
@property (nonatomic, strong) ZFGeshopShopPriceStyleModel *shopPrice_style;

/** 商品组件中:折扣价样式内容 */
@property (nonatomic, strong) ZFGeshopDiscountStyleModel *discount_style;


/** ================== 以下字段非服务端返回 ================== */

/** CMS列表:当前模型的Section所对应的Item个数 */
@property (nonatomic, assign) NSInteger            sectionItemCount;

/** CMS列表:当前模型的Section所对应的Item大小 */
@property (nonatomic, assign) CGSize               sectionItemSize;

/** Section所对应的Item cell类型 */
@property (nonatomic, assign) Class                 sectionItemCellClass;

/** CMS列表:当前模型的Section cell 两行之间的上下间距 */
@property (nonatomic, assign) CGFloat              sectionMinimumLineSpacing;

/** CMS列表:当前模型的Section 两个cell之间的左右间距 */
@property (nonatomic, assign) CGFloat              sectionMinimumInteritemSpacing;

/** CMS列表:当前模型的Section 组边距 */
@property (nonatomic, assign) UIEdgeInsets         sectionInsetForSection;

/** 页面专题id */
@property (nonatomic, copy)NSString                 *nativeThemeId;
/** 页面专题标题 */
@property (nonatomic, copy)NSString                 *nativeThemeName;

///轮播组件点击回调
@property (nonatomic, copy) GeshopClickCycleBannerBlock clickCycleBannerBlock;

///水平导航组件点击回调
@property (nonatomic, copy) GeshopClickNavigationItemBlock clickNavigationItemBlock;

///筛选商品组件点击回调
@property (nonatomic, copy) GeshopClickSiftItemBlock clickSiftItemBlock;


/** 防止 秒杀组件下的collectionViewCell重用时偏移量位置不准确 */
@property (nonatomic, assign) CGFloat sliderScrollViewOffsetX;

/** 防止配置多个水平导航组件来标记此模型是否是第一个水平导航组件 */
@property (nonatomic, assign) BOOL isMultipartNavigation;

/** 记录水平导航第一个标签滚动区域 */
@property (nonatomic) NSRange firstSelectedRange;

/** 筛选组件中已经选中的组件模型 */
@property (nonatomic, strong) ZFGeshopSiftItemModel *checkedCategorySiftModel;
@property (nonatomic, strong) ZFGeshopSiftItemModel *checkedSortSiftModel;

+ (NSArray<NSDictionary *> *)fetchGeshopAllCellTypeArray;

@end
