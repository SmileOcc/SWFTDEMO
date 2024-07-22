//
//  ZFCMSBaseViewModel.m
//  ZZZZZ
//
//  Created by YW on 2019/6/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSBaseViewModel.h"

@interface ZFCMSBaseViewModel ()

@end

@implementation ZFCMSBaseViewModel

/**
 * 配置cms列表数据
 * type:组件类型  101:弹窗   102:滑动banner <考虑子类型>  103: 轮播banner
 * type:组件类型  105:多分馆即固定   106:商品平铺 <考虑子类型>  107:下拉banner  108:浮窗banner
 */
- (NSArray<ZFCMSSectionModel *> *)configCMSListData:(NSArray<ZFCMSSectionModel *> *)cmsModelArr
{
    // 清空所有历史数据
    self.cmsPullDownModel = nil;
    self.recommendSectionModel = nil;
    self.historySectionModel = nil;
    
    //防止重复开启倒计时
    for (NSString *lastTmpTimerKey in self.alreadyStartTimerKeyArr) {
        if (ZFIsEmptyString(lastTmpTimerKey)) continue;
        [[ZFTimerManager shareInstance] stopTimer:lastTmpTimerKey];
    }
    
    
    ///////
    NSMutableArray *configModelArr = [NSMutableArray arrayWithArray:cmsModelArr];
    for (ZFCMSSectionModel *cmsModel in cmsModelArr) {
        
        // 数据封装UIColor对象,Cell中直接使用
        cmsModel.bgColor = [UIColor colorWithHexString:cmsModel.bg_color defaultColor:ZFCOLOR_WHITE];
        cmsModel.attributes.bgColor = [UIColor colorWithHexString:cmsModel.attributes.bg_color defaultColor:ZFCOLOR_WHITE];
        cmsModel.attributes.textColor =  [UIColor colorWithHexString:cmsModel.attributes.text_color defaultColor:[UIColor blackColor]];
        cmsModel.attributes.textSaleColor = [UIColor colorWithHexString:cmsModel.attributes.text_sale_color defaultColor:[UIColor blackColor]];
        
        // 平铺、与滑动能设置背景与边距
        if (cmsModel.type == ZFCMS_SlideBanner_Type
            || cmsModel.type == ZFCMS_GridMode_Type
            || cmsModel.type == ZFCMS_SecKillModule_Type) {
            
        //TODO: occ调试数据
        // cmsModel.attributes.padding_top = 30;
        // cmsModel.attributes.padding_bottom = 60;
        // cmsModel.padding_top = 10;
        // cmsModel.padding_bottom = 10;
        // cmsModel.bg_color = @"dd";
        // cmsModel.bgColor = ZFRandomColor();
        // if (cmsModel.list.count == 3 && cmsModel.type == ZFCMS_GridMode_Type) {
        //    cmsModel.display_count = @"2";
        // }
        } else {
            cmsModel.attributes.padding_top = 0;
            cmsModel.attributes.padding_bottom = 0;
            cmsModel.padding_top = 0;
            cmsModel.padding_bottom = 0;
            cmsModel.bg_color = @"";
            cmsModel.bgColor = [UIColor clearColor];
        }
        // 一行几列
        CGFloat display_count = [cmsModel.display_count floatValue];
        
        // 水平外边距
        CGFloat horizontalOutsideMagin = cmsModel.padding_left + cmsModel.padding_right;
        
        // 水平所有边距总和
        CGFloat horizontalAllMagin = horizontalOutsideMagin + (cmsModel.attributes.padding_left + cmsModel.attributes.padding_right) * ceil(display_count);
        
        // 垂直外边距
        CGFloat verticalOutsideMagin = cmsModel.padding_top + cmsModel.padding_bottom;
        
        // 垂直内边距
        CGFloat verticalInsideMagin = cmsModel.attributes.padding_top + cmsModel.attributes.padding_bottom;
        
        // 同组内两行之间的上下间距
        cmsModel.sectionMinimumLineSpacing = cmsModel.attributes.padding_top;
        
        // 两个cell之间的左右间距
        cmsModel.sectionMinimumInteritemSpacing = cmsModel.attributes.padding_left;
        
        // Section 组边距
        cmsModel.sectionInsetForSection = UIEdgeInsetsMake(cmsModel.padding_top,
                                                           cmsModel.padding_left,
                                                           cmsModel.padding_bottom,
                                                           cmsModel.padding_right);
        
        switch (cmsModel.type) {
            case ZFCMS_BannerPop_Type:          // 首页中间半透明大弹窗
            {
                // occ v460移除
                [configModelArr removeObject:cmsModel];
            }
            case ZFCMS_FloatingGBanner_Type:    // 首页面右下角小浮窗banner
            {
                // 从V4.5.3开始主页CMS接口不对接首页 右下角小浮窗, 中间半透明大弹窗数据
                [configModelArr removeObject:cmsModel];
            }
                break;
                
            case ZFCMS_DropDownBanner_Type:     // 下拉banner
            {
                // 下拉banner数据源不能显示在Collection列表中
                [configModelArr removeObject:cmsModel];
                self.cmsPullDownModel = cmsModel;
            }
                break;
                
            case ZFCMS_CycleBanner_Type:        //轮播banner
            case ZFCMS_VerCycleBanner_Type:     //竖排显示的轮播banner
            {
                cmsModel.sectionItemCount = 1;
                CGFloat cycleWidth = KScreenWidth - 0;//horizontalAllMagin;轮播不设置间距贴满屏幕两侧
                CGFloat cycleHeight = ([cmsModel.prop_h floatValue] * cycleWidth) / [cmsModel.prop_w floatValue];
                cmsModel.sectionItemSize = CGSizeMake(cycleWidth, cycleHeight);
            }
                break;
            case ZFCMS_SlideBanner_Type:        //滑动banner (商品类型, banner类型, 商品历史浏览记录) 一行
            {
                if (cmsModel.subType != ZFCMS_SkuBanner_SubType &&
                    cmsModel.subType != ZFCMS_SkuSelection_SubType &&
                    cmsModel.subType != ZFCMS_NormalBanner_SubType &&
                    cmsModel.subType != ZFCMS_HistorSku_SubType) {
                    [configModelArr removeObject:cmsModel];
                    break;//滑动模式下只能是这三种类型
                }
                
                cmsModel.sectionMinimumLineSpacing = 0;
                cmsModel.sectionMinimumInteritemSpacing = 0;
                cmsModel.sectionInsetForSection = UIEdgeInsetsZero;
                
                // ceil函数，向上取整。eg: ceil(1.4) = 2
                CGFloat topTextHeight = (cmsModel.subType == ZFCMS_HistorSku_SubType) ? kHistorSkuHeaderHeight : 0.0;
                
                CGFloat imageWidth = (KScreenWidth - horizontalAllMagin) / display_count;
                CGFloat imageHeight = ([cmsModel.prop_h floatValue] * imageWidth) / [cmsModel.prop_w floatValue];
                CGFloat priceMargin = (cmsModel.subType == ZFCMS_NormalBanner_SubType) ? 0.0 :  kGoodsPriceHeight ;
                //因为滑动有一个初始边距时，横向滑动就会一直有一个左边距，因此只能将边距放到cell内去设置，
                cmsModel.sectionItemSize = CGSizeMake(KScreenWidth, verticalOutsideMagin + topTextHeight + imageHeight + priceMargin + verticalInsideMagin);
                
                // 阿语时:需要标记滚动到最后
                if ([SystemConfigUtils isRightToLeftShow]) {
                    cmsModel.sliderScrollViewOffsetX = -1;
                }
                
                // 商品历史浏览记录
                if (cmsModel.subType == ZFCMS_HistorSku_SubType) {
                    if (self.historySectionModel) {
                        // 不能重复添加浏览历史记录组件
                        [configModelArr removeObject:cmsModel];
                    } else {
                        cmsModel.list = [NSMutableArray arrayWithArray:self.historyModelArr];
                        self.historySectionModel = cmsModel;
                    }
                }
                
                //商品类型list需要包装goodsModel
                if (cmsModel.subType == ZFCMS_SkuBanner_SubType ||
                    cmsModel.subType == ZFCMS_SkuSelection_SubType) {
                    [self configGoodsModel:cmsModel];
                }
                
                // 滑动的list有数据才显示Cell
                cmsModel.sectionItemCount = (cmsModel.list.count>0) ? 1 : 0;
            }
                break;
                
            case ZFCMS_BranchBanner_Type:   //多分馆：只一行数据
            {
                cmsModel.sectionMinimumLineSpacing = 0;
                cmsModel.sectionInsetForSection = UIEdgeInsetsMake(
                   cmsModel.padding_top + cmsModel.attributes.padding_top,
                   cmsModel.padding_left,
                   cmsModel.padding_bottom + cmsModel.attributes.padding_bottom,
                   cmsModel.padding_right);
                
                cmsModel.sectionItemCount = cmsModel.list.count;
                // 如果多分馆中列数与list集合数不相等时,则取最小个数
                if ([cmsModel.display_count integerValue] != cmsModel.list.count) {
                    NSInteger minCount = MIN([cmsModel.display_count integerValue], cmsModel.list.count);
                    cmsModel.sectionItemCount = minCount;
                    cmsModel.display_count = [NSString stringWithFormat:@"%ld", (long)minCount];
                }
                
                // V5.0.0这里暂不处理每个分馆之间可能会有的细线间距问题,在ZFCMSNormalBannerCell类中布局时已处理为超出边界0.5
                CGFloat branchWidth = ( (KScreenWidth - horizontalAllMagin) / display_count );
                CGFloat branchHeight = ( ([cmsModel.prop_h floatValue] * branchWidth) / [cmsModel.prop_w floatValue] );
                
                // FIXME: occ v460 不需要加内边距高度
                // cmsModel.sectionItemSize = CGSizeMake(branchWidth,  branchHeight + verticalInsideMagin);
                cmsModel.sectionItemSize = CGSizeMake(branchWidth,  branchHeight);
                
                // 解析到一分馆判断是否需要开启定时器
                if ([cmsModel.display_count integerValue] == 1) {
                    NSInteger index = 0;
                    for (ZFCMSItemModel *bannerModel in cmsModel.list) {
                        index++;
                        unsigned long long timcountdownTime = [bannerModel.countdown_time longLongValue];
                        if (timcountdownTime > 0) {
                            NSString *countDownTimerKey = [NSString stringWithFormat:@"ZFCMSBannerModel-%ld-%@",(long)index,  bannerModel.image];
                            [self.alreadyStartTimerKeyArr addObject:countDownTimerKey];
                            bannerModel.countDownCMSTimerKey = countDownTimerKey;
                            [[ZFTimerManager shareInstance] startTimer:countDownTimerKey];//CMS开启倒计时
                        }
                    }
                }
            }
                break;
                
            case ZFCMS_GridMode_Type:       //平铺,格子模式 (商品类型, banner类型) 有多行
            {
                // 平铺模式, 推荐商品
                cmsModel.sectionMinimumLineSpacing = cmsModel.attributes.padding_top + cmsModel.attributes.padding_bottom;
                cmsModel.sectionInsetForSection = UIEdgeInsetsMake(cmsModel.padding_top + cmsModel.attributes.padding_top,
                                                                   cmsModel.padding_left + cmsModel.attributes.padding_left,
                                                                   cmsModel.padding_bottom + cmsModel.attributes.padding_bottom,
                                                                   cmsModel.padding_right + cmsModel.attributes.padding_right);
                
                
                if (cmsModel.subType != ZFCMS_SkuBanner_SubType &&
                    cmsModel.subType != ZFCMS_NormalBanner_SubType) {
                    [configModelArr removeObject:cmsModel];
                    break;//平铺模式下subType只能是(商品类型, banner类型)
                }
                cmsModel.sectionItemCount = cmsModel.list.count;
                
                CGFloat gridWidth = (KScreenWidth - horizontalAllMagin) / display_count;
                CGFloat gridHeight = ([cmsModel.prop_h floatValue] * gridWidth) / [cmsModel.prop_w floatValue];
                CGFloat priceMargin = (cmsModel.subType == ZFCMS_SkuBanner_SubType) ? kGoodsPriceHeight : 0.0;
                
                //FIXME: occ Bug v460 不需要加内边距高度
                // cmsModel.sectionItemSize = CGSizeMake(gridWidth, gridHeight + priceMargin + verticalInsideMagin);
                cmsModel.sectionItemSize = CGSizeMake(gridWidth, gridHeight + priceMargin);
                
                //商品类型list需要包装goodsModel
                if (cmsModel.subType == ZFCMS_SkuBanner_SubType) {
                    [self configGoodsModel:cmsModel];
                }
            }
                break;
                
            case ZFCMS_RecommendGoods_Type:   //推荐商品栏
            {
                
                // 推荐商品
                cmsModel.sectionMinimumLineSpacing = cmsModel.attributes.padding_top + cmsModel.attributes.padding_bottom;
                cmsModel.sectionInsetForSection = UIEdgeInsetsMake(cmsModel.padding_top + cmsModel.attributes.padding_top,
                                                                   cmsModel.padding_left + cmsModel.attributes.padding_left,
                                                                   cmsModel.padding_bottom + cmsModel.attributes.padding_bottom,
                                                                   cmsModel.padding_right + cmsModel.attributes.padding_right);
                
                if (self.recommendSectionModel) { //防止显示多个推荐商品组件
                    [configModelArr removeObject:cmsModel];
                } else {
                    cmsModel.sectionItemCount = cmsModel.list.count;
                    
                    CGFloat goodsWidth = (KScreenWidth - horizontalAllMagin) / display_count;
                    CGFloat goodsHeight = ([cmsModel.prop_h floatValue] * goodsWidth) / [cmsModel.prop_w floatValue];
                    CGFloat priceMargin = kGoodsPriceHeight;
                    //FIXME: occ Bug v460 不需要加内边距高度
                    // cmsModel.sectionItemSize = CGSizeMake(goodsWidth, goodsHeight + priceMargin + verticalInsideMagin);
                    cmsModel.sectionItemSize = CGSizeMake(goodsWidth, goodsHeight + priceMargin);
                    // 标记推荐商品模型放到最后显示
                    self.recommendSectionModel = cmsModel;
                }
            }
                break;
                
            case ZFCMS_TextModule_Type:         // 纯文本栏目
            {
                
                cmsModel.sectionInsetForSection = UIEdgeInsetsMake(cmsModel.padding_top + cmsModel.attributes.padding_top,
                                                                   cmsModel.padding_left,
                                                                   cmsModel.padding_bottom + cmsModel.attributes.padding_bottom,
                                                                   cmsModel.padding_right);
                
                cmsModel.sectionItemCount = 1;
                CGFloat textWidth = KScreenWidth - (horizontalOutsideMagin + cmsModel.attributes.padding_left + cmsModel.attributes.padding_right);
                CGFloat textHeight = ([cmsModel.prop_h floatValue] * textWidth) / [cmsModel.prop_w floatValue];
                //FIXME: occ v460
                //                cmsModel.sectionItemSize = CGSizeMake(KScreenWidth, textHeight + verticalInsideMagin);
                cmsModel.sectionItemSize = CGSizeMake(KScreenWidth, textHeight);
                
                // 文本数据源
                ZFCMSItemModel *itemModel = [[ZFCMSItemModel alloc] init];
                itemModel.name = cmsModel.attributes.text;
                cmsModel.list = [NSMutableArray arrayWithObject:itemModel];
            }
                break;
                
            case ZFCMS_SecKillModule_Type:      // 秒杀组件
            {
                
                // 滑动模式
                cmsModel.sectionMinimumLineSpacing = 0;
                cmsModel.sectionMinimumInteritemSpacing = 0;
                cmsModel.sectionInsetForSection = UIEdgeInsetsZero;
                cmsModel.sectionItemCount = 1;
                
                for (ZFCMSItemModel *subItemModel in cmsModel.list) {
                    subItemModel.textSaleColor = cmsModel.attributes.textSaleColor;
                }
                CGFloat topTextHeight = kSecKillSkuHeaderHeight;
                CGFloat imageWidth = (KScreenWidth - horizontalAllMagin) / display_count;
                CGFloat imageHeight = ([cmsModel.prop_h floatValue] * imageWidth) / [cmsModel.prop_w floatValue];
                CGFloat verticalCellInsideSpace = [ZFCMSSecKillSkuCell cmsVerticalHeightNoContainImage];
                //因为滑动有一个初始边距时，横向滑动就会一直有一个左边距，因此只能将边距放到cell内去设置，
                cmsModel.sectionItemSize = CGSizeMake(KScreenWidth, verticalOutsideMagin + topTextHeight + imageHeight + verticalCellInsideSpace + verticalInsideMagin);
                
                // 判断是否需要开启定时器
                ZFCMSItemModel *countDownModel = cmsModel.list.firstObject;
                unsigned long long timcountdownTime = [countDownModel.countdown_time longLongValue];
                if (timcountdownTime > 0) {
                    NSString *countDownTimerKey = [NSString stringWithFormat:@"ZFCMSSecKillModel-%@", countDownModel.name];
                    [self.alreadyStartTimerKeyArr addObject:countDownTimerKey];
                    countDownModel.countDownCMSTimerKey = countDownTimerKey;
                    [[ZFTimerManager shareInstance] startTimer:countDownTimerKey];//CMS开启倒计时
                }
            }
                break;
            case ZFCMS_VideoPlayer_Type:
            {
                cmsModel.sectionItemCount = cmsModel.list.count;
                CGFloat cycleWidth = KScreenWidth - 0;//horizontalAllMagin;轮播不设置间距贴满屏幕两侧
                CGFloat cycleHeight = ([cmsModel.prop_h floatValue] * cycleWidth) / [cmsModel.prop_w floatValue];
                cmsModel.sectionItemSize = CGSizeMake(cycleWidth, cycleHeight);
            }
                break;
            case ZFCMS_CouponModule_Type:
            {
                
                if ([self matchCouponSectionModel:cmsModel]) {
                    YWLog(@"---- 相同的couponSection: %@",cmsModel.component_id);
                    
                } else {
                    
                    CGFloat width = KScreenWidth - 20;
                    CGFloat height = [ZFCMSItemModel cmsCouponWidth:width calculatHeight:cmsModel.list.count];
                    // 需要请求后台真实数据后，填充设置成 1
                    cmsModel.sectionItemCount = 0;
                    cmsModel.sectionItemSize = CGSizeMake(width, height);
                    cmsModel.sectionInsetForSection = UIEdgeInsetsMake(5, 0, 5, 0);
                }
            }
            default:
                break;
        }
    }
    // 把推荐商品放在最后面显示 (因为需要上拉加载更多)
    if ([configModelArr containsObject:self.recommendSectionModel]) {
        [configModelArr removeObject:self.recommendSectionModel];
        [configModelArr addObject:self.recommendSectionModel];
    }
    return configModelArr;
}

- (BOOL)matchCouponSectionModel:(ZFCMSSectionModel *)cmsModel {
    
    __block BOOL isMatch = NO;
    [self.couponSectionModelArr enumerateObjectsUsingBlock:^(ZFCMSSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.component_id isEqualToString:cmsModel.component_id]) {
            if (obj.list.count == cmsModel.list.count) {
                isMatch = YES;
                for (int i=0; i<obj.list.count; i++) {
                    ZFCMSItemModel *objItem = obj.list[i];
                    ZFCMSItemModel *subCmsModel = cmsModel.list[i];
                    
                    if (![objItem.ad_id isEqualToString:subCmsModel.ad_id]) {
                        isMatch = NO;
                        *stop = YES;
                    } else if(isMatch && i == obj.list.count - 1) {
                        cmsModel.list = obj.list;
                        cmsModel.sectionItemCount = obj.sectionItemCount;
                        cmsModel.sectionItemSize = obj.sectionItemSize;
                        cmsModel.sectionInsetForSection = obj.sectionInsetForSection;
                    }
                }
            }
            *stop = YES;
        }
    }];
    return isMatch;
}

#pragma mark - 数据包装

/**
 * 包装每个参ZFCMSItemModel的ZFGoodsModel属性,在统计时用到
 */
- (void)configGoodsModel:(ZFCMSSectionModel *)cmsModel {
    if (![cmsModel isKindOfClass:[ZFCMSSectionModel class]]) return ;
    for (ZFCMSItemModel *itemModel in cmsModel.list) {
        ZFGoodsModel *goodsModel = [[ZFGoodsModel alloc] init];
        goodsModel.goods_id = itemModel.url;
        goodsModel.goods_sn = itemModel.ad_id;
        goodsModel.goods_title = itemModel.name;
        itemModel.goodsModel = goodsModel;
    }
}

/**
 * ZFGoodsModel转换ZFCMSItemModel数据
 */
- (ZFCMSItemModel *)configCMSItemModel:(ZFGoodsModel *)goodsModel {
    ZFCMSItemModel *itemModel = [[ZFCMSItemModel alloc] init];
    itemModel.image = goodsModel.wp_image;
    itemModel.shop_price = goodsModel.shop_price;
    itemModel.actionType = [NSString stringWithFormat:@"%ld", (long)JumpGoodDetailActionType];
    itemModel.url = [NSString stringWithFormat:@"%@", goodsModel.goods_id];
    itemModel.goodsModel = goodsModel;//浏览历史记录要做统计
    //YWLog(@"这里还需要包装其他参数");
    return itemModel;
}


/**
* 填充配置优惠券完整数据
* array: 为nil时，直接取本地的数据
*/
- (void)configCMSCouponItemsSource:(NSArray<ZFCMSSectionModel *> *)cmsModelArr fillData:(NSArray<ZFCMSCouponModel *> *)array {
    
    [self.couponSectionModelArr removeAllObjects];
    @weakify(self)
    [cmsModelArr enumerateObjectsUsingBlock:^(ZFCMSSectionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        if (obj.type == ZFCMS_CouponModule_Type) {
            [obj.list enumerateObjectsUsingBlock:^(ZFCMSItemModel * _Nonnull subObj, NSUInteger idx, BOOL * _Nonnull subStop) {
                
                //请求回来的数据
                if (ZFJudgeNSArray(array)) {
                    [array enumerateObjectsUsingBlock:^(ZFCMSCouponModel * _Nonnull couponObj, NSUInteger idx, BOOL * _Nonnull couponStop) {
                        if ([couponObj.idx isEqualToString:subObj.coupon_id]) {
                            
                            // 取本地上次点击的优惠券状态
                            ZFCMSCouponModel *localCouponModel = [[ZFCMSCouponManager manager] localCouponModelForID:subObj.coupon_id];
                            if (localCouponModel) {
                                couponObj.couponState = localCouponModel.couponState;
                            }
                            subObj.couponModel = couponObj;
                            *couponStop = YES;
                        }
                    }];
                    
                } else { //界面只是刷界面
                    
                    if (!ZFIsEmptyString(subObj.couponModel.idx)) {
                        // 取本地上次点击的优惠券状态
                        ZFCMSCouponModel *localCouponModel = [[ZFCMSCouponManager manager] localCouponModelForID:subObj.coupon_id];
                        if (localCouponModel) {
                            subObj.couponModel.couponState = localCouponModel.couponState;
                        }
                    }
                }
            }];
            obj.sectionItemCount = (obj.list.count>0) ? 1 : 0;
            [self.couponSectionModelArr addObject:obj];
        }
    }];
}

/**
* 配置异步请求的滑动SKU商品数据
*/
- (void)configSlideSKUModuleData:(ZFCMSSectionModel *)tmpSectionModel
                     cmsModelArr:(NSArray<ZFCMSSectionModel *> *)cmsModelArr
                        fillData:(NSArray<ZFGoodsModel *> *)array {
    if (array.count == 0) return;
    
    [cmsModelArr enumerateObjectsUsingBlock:^(ZFCMSSectionModel * _Nonnull sectionModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([tmpSectionModel.component_id isEqualToString:sectionModel.component_id]
            && sectionModel.type == ZFCMS_SlideBanner_Type
            && sectionModel.subType == ZFCMS_SkuSelection_SubType) {
            
            if ([sectionModel.component_id isEqualToString:sectionModel.component_id]) {
                if (!ZFJudgeNSArray(sectionModel.list)) {
                    sectionModel.list = [NSMutableArray array]; //<ZFCMSItemModel *>
                }
                
                [array enumerateObjectsUsingBlock:^(ZFGoodsModel *goodsModel, NSUInteger idx, BOOL * _Nonnull couponStop) { //包装ItemModel模型
                    ZFCMSItemModel *itemModel = [[ZFCMSItemModel alloc] init];
                    itemModel.image = ZFToString(goodsModel.wp_image);
                    itemModel.shop_price = ZFToString(goodsModel.shop_price);
                    itemModel.actionType = @"3";//点击跳转用到->商品详情页
                    itemModel.url = goodsModel.goods_id;//点击跳转用到
                    [sectionModel.list addObject:itemModel];
                }];
                sectionModel.sectionItemCount = (sectionModel.list.count > 0) ? 1 : 0;
            }
        }
    }];
}

//是否已经开启过d定时器, 场景:缓存数据有倒计时,进入页面刷新数据后倒计时完成后需要标记移除
- (NSMutableArray *)alreadyStartTimerKeyArr {
    if (!_alreadyStartTimerKeyArr) {
        _alreadyStartTimerKeyArr = [NSMutableArray array];
    }
    return _alreadyStartTimerKeyArr;
}

- (NSMutableArray<ZFCMSSectionModel *> *)couponSectionModelArr {
    if (!_couponSectionModelArr) {
        _couponSectionModelArr = [[NSMutableArray alloc] init];
    }
    return _couponSectionModelArr;
}

- (NSMutableDictionary *)baseParmatersDic {
    
    NSString *new_customer = [AccountManager sharedManager].af_user_type;
    ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
    
    NSMutableDictionary *parmaters = [NSMutableDictionary dictionary];
    parmaters[@"website"] = @"ZF";
    parmaters[@"country_code"] = ZFIsEmptyString(accountModel.region_code) ? @"US" : accountModel.region_code;
    parmaters[@"language_code"] = ZFToString([[ZFLocalizationString shareLocalizable] currentLanguageMR]);
    parmaters[@"is_new_customer"] = ZFIsEmptyString(new_customer ) ? @"1" : new_customer;;
    parmaters[@"mid"] = ZFToString([AccountManager sharedManager].device_id);
    parmaters[@"app_version"] = ZFToString(ZFSYSTEM_VERSION);
    parmaters[@"platform"] = @"ios";
    parmaters[@"api_version"] = @"2";//CMS版本号（ZF ios 4.5.4以后版本必须传）
    
    return parmaters;
}


#pragma mark - 
/**
 * 获取历史浏览记录
 */
- (void)fetchRecentlyGoods:(nullable void(^)(NSArray<ZFCMSItemModel *> *))block {
    @weakify(self)
    [ZFGoodsModel selectAllGoods:^(NSArray<ZFGoodsModel *> *recentlyGoodsArray) {
        @strongify(self)
        NSMutableArray *goods_idArr = [NSMutableArray array];
        NSMutableArray *itemGoodsArr = [NSMutableArray array];
        
        // 需要添加fb广告链接带进来的商品
        if (!self.hasClearHistoryData && self.afGoodsModelArr.count > 0) {
            // sku去重
            for (ZFGoodsModel *goodsModel in self.afGoodsModelArr) {
                if (![goodsModel isKindOfClass:[ZFGoodsModel class]]) continue;
                ZFCMSItemModel *itemModel = [self configCMSItemModel:goodsModel];
                [goods_idArr addObject:ZFToString(goodsModel.goods_id)];
                [itemGoodsArr addObject:itemModel];
            }
            self.afGoodsModelArr = @[];
        }
        
        for (ZFGoodsModel *goodsModel in recentlyGoodsArray) {
            if (![goods_idArr containsObject:goodsModel.goods_id]) {
                ZFCMSItemModel *itemModel = [self configCMSItemModel:goodsModel];
                [itemGoodsArr addObject:itemModel];
            }
        }
        self.historyModelArr = itemGoodsArr;
        if (block) {
            block(self.historyModelArr);
        }
    }];
}

/**
 * 清除历史浏览记录数据
 */
- (void)clearCMSHistoryAction {
    [self.historyModelArr removeAllObjects];
    self.hasClearHistoryData = YES;
}

@end
