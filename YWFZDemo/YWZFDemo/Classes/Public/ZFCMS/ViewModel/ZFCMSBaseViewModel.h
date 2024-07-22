//
//  ZFCMSBaseViewModel.h
//  ZZZZZ
//
//  Created by YW on 2019/6/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFCMSSectionModel.h"
#import "ZFTimerManager.h"
#import "UIColor+ExTypeChange.h"
#import "ZFPiecingOrderViewModel.h"
#import "YWLocalHostManager.h"
#import "JumpModel.h"
#import "ZFThemeManager.h"
#import "AppDelegate.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import "NSStringUtils.h"
#import "ZFAnalytics.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "ZFBannerModel.h"
#import "Constants.h"
#import "Configuration.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import <GGBrainKeeper/BrainKeeperManager.h>

#import "ZFCMSSecKillSkuCell.h"
#import "ZFCMSCouponModel.h"
#import "ZFCMSCouponManager.h"


NS_ASSUME_NONNULL_BEGIN

@interface ZFCMSBaseViewModel : BaseViewModel

@property (nonatomic, strong, nullable) ZFCMSSectionModel   *cmsPullDownModel;
@property (nonatomic, strong, nullable) ZFCMSSectionModel   *historySectionModel;
@property (nonatomic, strong, nullable) ZFCMSSectionModel   *recommendSectionModel;

@property (nonatomic, strong) NSDictionary                                 *recommendParmaters;
@property (nonatomic, strong) NSDictionary                                 *sliderModuleParmaters;
@property (nonatomic, assign) NSInteger                                    currentPage;
@property (nonatomic, strong) NSMutableArray                               *alreadyStartTimerKeyArr;
@property (nonatomic, strong, nullable) NSMutableArray<ZFCMSItemModel *>   *historyModelArr;
/** fb广告链接带进来的商品 */
@property (nonatomic, strong) NSArray<ZFGoodsModel *>                      *afGoodsModelArr;
/** 是否已经清除过添加浏览历史记录 */
@property (nonatomic, assign) BOOL                                         hasClearHistoryData;
@property (nonatomic, strong) NSDictionary                                 *recommendResponseDict;
@property (nonatomic, strong) NSArray                                      *cmsModelArr;

@property (nonatomic, strong, nullable) NSMutableArray<ZFCMSSectionModel *> *couponSectionModelArr;


- (NSMutableDictionary *)baseParmatersDic;


/**
 * 配置cms列表数据
 * type:组件类型  101:弹窗   102:滑动banner <考虑子类型>  103: 轮播banner
 * type:组件类型  105:多分馆即固定   106:商品平铺 <考虑子类型>  107:下拉banner  108:浮窗banner
 */
- (NSArray<ZFCMSSectionModel *> *)configCMSListData:(NSArray<ZFCMSSectionModel *> *)cmsModelArr;

/**
 * 包装每个参ZFCMSItemModel的ZFGoodsModel属性,在统计时用到
 */
- (void)configGoodsModel:(ZFCMSSectionModel *)cmsModel;

/**
 * ZFGoodsModel转换ZFCMSItemModel数据
 */
- (ZFCMSItemModel *)configCMSItemModel:(ZFGoodsModel *)goodsModel;


/**
* 填充配置优惠券完整数据
* array: 为nil时，直接取本地的数据
*/
- (void)configCMSCouponItemsSource:(NSArray<ZFCMSSectionModel *> *)cmsModelArr
                          fillData:(NSArray<ZFCMSCouponModel *> *)array;

/**
* 配置异步请求的滑动SKU商品数据
*/
- (void)configSlideSKUModuleData:(ZFCMSSectionModel *)tmpSectionModel
                     cmsModelArr:(NSArray<ZFCMSSectionModel *> *)cmsModelArr
                        fillData:(NSArray<ZFGoodsModel *> *)array;

/**
 * 获取历史浏览记录
 */
- (void)fetchRecentlyGoods:(nullable void(^)(NSArray<ZFCMSItemModel *> *))block;

/**
 * 清除历史浏览记录数据
 */
- (void)clearCMSHistoryAction;

@end


NS_ASSUME_NONNULL_END

