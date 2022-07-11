
//
//  DiscoveryViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

///*******************API管理*****************************//
#import "OSSVHomeDiscoverAip.h"
#import "OSSVHomesMenuTabGoodAip.h"
#import "OSSVAdvsEventsManager.h"

//Controllers
#import "OSSVFlashSaleMainVC.h"
#import "OSSVCartVC.h"
#import "OSSVDetailsVC.h"
#import "OSSVAppNewThemeVC.h"
//Views
#import "OSSVDiscovryHeadrReusablView.h"
#import "OSSVHomeCCellBanneModel.h"
#import "OSSVCycleSysCCellModel.h"
#import "OSSVThemeZeorsActivyCCell.h"
#import "OSSVFlasttSaleCellModel.h"
#import "OSSVFastSalesCCell.h"
#import "OSSVSevenAdvBannerCCell.h"
#import "OSSVScrollAdvBannerCCell.h"
#import "OSSVHomeCartCCell.h"
#import "OSSVScrollTitlesCCell.h"
#import "OSSVHomeRecommendToYouCCell.h"
#import "OSSVPrGoodsSPecialCCell.h"
#import "OSSVScrollCCellModel.h"
#import "OSSVAsinglesAdvCCell.h"
#import "OSSVHomeItemssCell.h"
#import "OSSVHomeCycleSysTipCCell.h"
#import "OSSVScrolllGoodsCCell.h"

//Models
#import "OSSVDiscoveyViewModel.h"
#import "OSSVHomeItemsModel.h"
#import "OSSVHomeDiscoveryModel.h"
#import "OSSVAdvsEventsModel.h"
#import "OSSVHomeGoodsListModel.h"
#import "OSSVCustThemePrGoodsListCacheModel.h"
#import "OSSVDetailsBaseInfoModel.h"
//View----Models
#import "OSSVEqlSquareMould.h"
#import "OSSVAsinglViewMould.h"
#import "OSSVThreeCViewMould.h"
#import "OSSVMutilBranchMould.h"
#import "OSSVWaterrFallViewMould.h"
#import "OSSVScrollViewMould.h"
#import "OSSVTimeDownCCellModel.h"
#import "OSSVTopicCCellModel.h"
#import "OSSVCustomThemeMultiMould.h"
#import "OSSVAPPNewThemeMultiCCellModel.h"
#import "OSSVScrollCCTitleViewModel.h"
#import "OSSVHomeCartsCCellModel.h"
#import "OSSVAsinglADCellModel.h"
#import "OSSVScrollAdvCCellModel.h"
#import "OSSVScrollGoodsItesCCellModel.h"

#import "OSSVSevenAdvBannerCCell.h"
#import "OSSVCycleMSGView.h"
#import "OSSVSevenAdvCCellModel.h"
#import "Adorawe-Swift.h"

@import FirebasePerformance;

@interface OSSVDiscoveyViewModel ()
<
    ZJJTimeCountDownDelegate,
    STLScrollerCollectionViewCellDelegate,
    STLCartCollectionViewCellDelegate,
    STLFastSaleCollectionViewCellDelegate,
    STLScrollerGoodsCCellDelegate
>

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, OSSVCustThemePrGoodsListCacheModel *>*customProductListCache;                          ///<商品列表缓存
@property (nonatomic, strong) OSSVHomeDiscoveryModel              *discoveryHeaderModel; // 假设专门 为 header 做处理
@property (nonatomic, strong) OSSVHomeDiscoveryModel              *allDiscoveryModel;  // 总的数据集合
@property (nonatomic, strong) WMMenuView                  *menuView;
@property (nonatomic, strong) ZJJTimeCountDown            *countDown;
@property (nonatomic, strong) UIActivityIndicatorView     *indicatorView;
//底部商品背景色
//@property (nonatomic, strong) UIView                      *bottomBgView;

///是否有频道楼层
@property (nonatomic, assign) BOOL isChannel;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) STLHomeCThemeChannelModel   *currentChannelModel;
@property (nonatomic, strong) OSSVHomesMenuTabGoodAip *tabGoodsApi;



@property (nonatomic, strong) OSSVWaterrFallViewMould    *recommendWaterFallViewTemplate;
@property (nonatomic, strong) OSSVHomeMainAnalyseAP *discoverAnalyticsManager;

/** 组的背景色值数据源*/
@property (nonatomic, strong) NSMutableArray                           *sectionBgColorViewArr;

@property (strong,nonatomic) FIRTrace *trace;

@end

@implementation OSSVDiscoveyViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [[OSSVAnalyticInjectsManager shareInstance] analyticsInject:self injectObject:self.discoverAnalyticsManager];
    }
    return self;
}


#pragma mark - NetRequset
- (void)requestBannerDatas:(id)parmaters completion:(void (^)(id result, BOOL isCache))completion failure:(void (^)(id))failure {
    _trace = [FIRPerformance startTraceWithName:@"home_banner/list"];

//    @weakify(self)
//    [[STLNetworkStateManager sharedManager] networkState:^{
//        @strongify(self)
    @weakify(self)
    __block  BOOL isHidenEmpty = NO;
    OSSVHomeDiscoverAip *api = [[OSSVHomeDiscoverAip alloc] initWithDiscoveryPage:1 pageSize:kSTLPageSize channelId:self.channel_id];
    
    if (!_allDiscoveryModel && api.cacheJSONObject) {
        id requestJSON = api.cacheJSONObject;
        // 总的Discovery Model 数据
        self.allDiscoveryModel = [self dataAnalysisFromJson: requestJSON request:api];
        [self handleDiscoverData];
        isHidenEmpty = YES;
        if (completion) {
            completion(@(isHidenEmpty), YES);
        }
//banner/list 不缓存
//        if (self.isCache) {
//            self.isCache = NO;
//            return;
//        }
    }
    
        SHOW_SYSTEM_ACTIVITY(YES);
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            [self.trace stop];
            @strongify(self)
            SHOW_SYSTEM_ACTIVITY(NO);
            
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            // 总的Discovery Model 数据
            self.allDiscoveryModel = [self dataAnalysisFromJson: requestJSON request:api];
            
            [self analyticsRecommend:self.allDiscoveryModel.goodsList];

            [self.dataSourceList removeAllObjects];
            [self.discoverAnalyticsManager.dataSourceList removeAllObjects];
            [self.discoverAnalyticsManager refreshDataSource];
            [self handleDiscoverData];

            isHidenEmpty = YES;
            if (completion) {
                completion(@(isHidenEmpty), NO);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            [self.trace stop];
            SHOW_SYSTEM_ACTIVITY(NO);
            if (failure) {
                failure(@(isHidenEmpty));
            }
        }];
//    } exception:^{
//        @strongify(self)
//        if (failure) {
//            failure(@([self homeHasDiscoverData]));
//        }
//    }];
}


- (void)requestMenuCategory:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    
    if([parmaters[@"isRefresh"] boolValue]) {
        self.currentPage = 1;
    } else {
        self.currentPage++;
    }
    self.tabGoodsApi = [[OSSVHomesMenuTabGoodAip alloc] initWithCatId:parmaters[@"cat_id"] channelId:parmaters[@"channel_id"] page:self.currentPage];
    
    @weakify(self)
    [self.tabGoodsApi startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        // 总的Discovery Model 数据
         id result = [self dataAnalysisFromJson: requestJSON request:self.tabGoodsApi];
        
        if (completion) {
            completion(result);
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if(![parmaters[@"isRefresh"] boolValue]) {
            self.currentPage--;
        }
        if (failure) {
            failure(nil);
        }
    }];
}

- (void)analyticsRecommend:(NSDictionary *)recomDic {
    
    // AOP曝光了
}

- (void)handleDiscoverData {
    
    [self removeSectionBgColorView];
    ///文字跑马灯占位
    if (self.allDiscoveryModel.marqueeArray.count > 0) {

        [self.allDiscoveryModel.marqueeArray enumerateObjectsUsingBlock:^(OSSVAdvsEventsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGSize itemSize = [OSSVCycleMSGView contentCalculate:[NSString stringWithFormat:@"  %@",obj.marqueeText]];
            obj.paoMaDengWidt = itemSize.width;
        }];
        
        OSSVAsinglViewMould *asingleModule = [[OSSVAsinglViewMould alloc] init];
        OSSVCycleSysCCellModel *cycleSystemTipCellModel = [[OSSVCycleSysCCellModel alloc] init];
        cycleSystemTipCellModel.size = CGSizeMake(SCREEN_WIDTH, 32);
        cycleSystemTipCellModel.dataSource = [self.allDiscoveryModel.marqueeArray copy];
        [asingleModule.sectionDataList addObject:cycleSystemTipCellModel];
        [self.dataSourceList addObject:asingleModule];
        
    }


    //添加滚动banner
    if ([self.allDiscoveryModel.bannerArray count]) {
        OSSVAsinglViewMould *bannerModule = [[OSSVAsinglViewMould alloc] init];
        OSSVHomeCCellBanneModel *cellModel = [[OSSVHomeCCellBanneModel alloc] init];
        cellModel.dataSource = [self.allDiscoveryModel.bannerArray copy];
        [bannerModule.sectionDataList addObject:cellModel];
        [self.dataSourceList addObject:bannerModule];
    }
    
    /////滑动banner
    if (self.allDiscoveryModel.slideImgArray.count > 0) {
        OSSVAsinglViewMould *asingleOneModule = [[OSSVAsinglViewMould alloc] init];
        OSSVScrollAdvCCellModel *scrollBannerCellModel = [[OSSVScrollAdvCCellModel alloc] init];
        scrollBannerCellModel.size = CGSizeMake(SCREEN_WIDTH, floor(kScale_375*116));
        scrollBannerCellModel.dataSource = [self.allDiscoveryModel.slideImgArray copy];
        scrollBannerCellModel.backgroundConfig = self.allDiscoveryModel.slide_img_background;
        
        ///TODO 1.3.8 添加返回背景数据
        [asingleOneModule.sectionDataList addObject:scrollBannerCellModel];
        [self.dataSourceList addObject:asingleOneModule];
    }
    
    //闪购功能
    
    if (self.allDiscoveryModel.flashSale.goodsList.count) {
        OSSVAsinglViewMould *asingFastSaleModule = [[OSSVAsinglViewMould alloc] init];
        OSSVFlasttSaleCellModel *fastSaleModel = [[OSSVFlasttSaleCellModel alloc] init];
        if (APP_TYPE == 3) {
            fastSaleModel.size = CGSizeMake(SCREEN_WIDTH, floor(kScale_375*179));
        } else {
            fastSaleModel.size = CGSizeMake(SCREEN_WIDTH, floor(kScale_375*209));
        }
        fastSaleModel.dataSource = self.allDiscoveryModel.flashSale;
        fastSaleModel.channelId  = self.channel_id;
        fastSaleModel.channelName = self.channelName;
        [asingFastSaleModule.sectionDataList addObject:fastSaleModel];
        [self.dataSourceList addObject:asingFastSaleModule];
    }
    
    if ([self.allDiscoveryModel.exchange count]) {
        OSSVAsinglViewMould *bannerModule = [[OSSVAsinglViewMould alloc] init];
        OSSVAsinglADCellModel *advCellModel = [[OSSVAsinglADCellModel alloc] init];
        advCellModel.dataSource = self.allDiscoveryModel.exchange.firstObject;
        [bannerModule.sectionDataList addObject:advCellModel];
        [self.dataSourceList addObject:bannerModule];
    }
    
    if ([self.allDiscoveryModel.topicArray count]) {
        OSSVEqlSquareMould *module = [[OSSVEqlSquareMould alloc] init];
        [self.allDiscoveryModel.topicArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            OSSVTopicCCellModel *cellModel = [[OSSVTopicCCellModel alloc] init];
            cellModel.dataSource = obj;
            [module.sectionDataList addObject:cellModel];
        }];
        [self.dataSourceList addObject:module];
    }
    
    if ([self.allDiscoveryModel.newuser count]) {//新用户
        
        OSSVAsinglViewMould *bannerModule = [[OSSVAsinglViewMould alloc] init];
        OSSVAsingleCCellModel *cellModel = [[OSSVAsingleCCellModel alloc] init];
        
        // 永远只有一个
        OSSVAdvsEventsModel *OSSVAdvsEventsModel = self.allDiscoveryModel.newuser.firstObject;
        CGFloat h = kDiscoveryOneBannerViewHeight;
        if ([OSSVAdvsEventsModel.width floatValue] > 0 && [OSSVAdvsEventsModel.height floatValue] > 0) {
            CGFloat scale = [OSSVAdvsEventsModel.width floatValue] / [OSSVAdvsEventsModel.height floatValue];
            h = SCREEN_WIDTH / scale;
        }
        cellModel.dataSource = OSSVAdvsEventsModel;
        cellModel.size = CGSizeMake(SCREEN_WIDTH, floor(h));
        [bannerModule.sectionDataList addObject:cellModel];
        [self.dataSourceList addObject:bannerModule];
    }
    
    if ([self.allDiscoveryModel.secondArray count]) {
        [self.allDiscoveryModel.secondArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[OSSVSecondsKillsModel class]]) *stop = YES;
            OSSVSecondsKillsModel *scrollerModel = obj;
            OSSVScrollViewMould *module = [[OSSVScrollViewMould alloc] initWithType:ScrollerType_CountDown];
            OSSVAsingleCCellModel *singleModel = [[OSSVAsingleCCellModel alloc] init];
            singleModel.dataSource = scrollerModel.banner;
            singleModel.size = CGSizeMake(SCREEN_WIDTH, floor(SCREEN_WIDTH*(130.0/750.0)));
            [module.sectionDataList addObject:singleModel];

            OSSVTimeDownCCellModel *countDownModel = [[OSSVTimeDownCCellModel alloc] init];
            countDownModel.dataSource = scrollerModel;
            [module.sectionDataList addObject:countDownModel];
            
            OSSVScrollCCellModel *scrollModel = [[OSSVScrollCCellModel alloc] init];
            scrollModel.dataSource = scrollerModel;
            [module.sectionDataList addObject:scrollModel];
            
            [self.dataSourceList addObject:module];
        }];
    }
    
    if ([self.allDiscoveryModel.scrollArray count]) {
        [self.allDiscoveryModel.scrollArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[OSSVSecondsKillsModel class]]) *stop = YES;
            OSSVSecondsKillsModel *scrollerModel = obj;
            OSSVScrollViewMould *module = [[OSSVScrollViewMould alloc] initWithType:ScrollerType_Scroller];
            OSSVAsingleCCellModel *singleModel = [[OSSVAsingleCCellModel alloc] init];
            //这个尺寸是UI给的尺寸
            singleModel.size = CGSizeMake(SCREEN_WIDTH, floor(SCREEN_WIDTH*(105.0/750.0)));
            singleModel.dataSource = scrollerModel.banner;
            [module.sectionDataList addObject:singleModel];
            
            OSSVScrollCCellModel *scrollModel = [[OSSVScrollCCellModel alloc] init];
            scrollModel.dataSource = scrollerModel;
            [module.sectionDataList addObject:scrollModel];
            
            [self.dataSourceList addObject:module];
        }];
    }
    
//    if ([self.allDiscoveryModel.threeArray count] == 3) {
//        STLThreeViewTemplate *module = [[STLThreeViewTemplate alloc] init];
//        [self.allDiscoveryModel.threeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            STLAsingleCollectionCellModel *cellModel = [[STLAsingleCollectionCellModel alloc] init];
//            cellModel.dataSource = obj;
//            [module.sectionDataList addObject:cellModel];
//        }];
//        [self.dataSourceList addObject:module];
//    }
    
    if ([self.allDiscoveryModel.index_venue count]) {
        [self.allDiscoveryModel.index_venue enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isKindOfClass:[OSSVHomeCThemeModel class]]) return;
            OSSVCustomThemeMultiMould *asingleCellModule = [[OSSVCustomThemeMultiMould alloc] init];
            OSSVHomeCThemeModel *themeModel = obj;
            [themeModel.modeImg enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                OSSVAPPNewThemeMultiCCellModel *asingleCellModel = [[OSSVAPPNewThemeMultiCCellModel alloc] init];
                asingleCellModel.dataSource = obj;
                [asingleCellModule.sectionDataList addObject:asingleCellModel];
            }];
            [self.dataSourceList addObject:asingleCellModule];
        }];
    }
    
    
    if ([self.allDiscoveryModel.blocklist count]) {
        [self.allDiscoveryModel.blocklist enumerateObjectsUsingBlock:^(OSSVDiscoverBlocksModel  * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj.type integerValue] > 0) {
                
                obj.banner.parentId = STLToString(obj.banner.bannerId);
                if (!STLIsEmptyString(obj.banner.bannerId) && STLJudgeNSArray(obj.images)) {
                    [obj.images enumerateObjectsUsingBlock:^(OSSVAdvsEventsModel * _Nonnull advObj, NSUInteger idx, BOOL * _Nonnull stop) {
                        advObj.parentId = obj.banner.bannerId;
                    }];
                }
                if ([obj.type integerValue] == 101) {

                    if (obj.slide_data.count > 0) {
                        
                        obj.imageScale = 3/4.0;
                        NSInteger imageScale = 0;
                        for (int i=0; i<obj.slide_data.count; i++) {
                            STLDiscoveryBlockSlideGoodsModel *tttModel = obj.slide_data[i];
                            if (!STLIsEmptyString(tttModel.width) && [tttModel.width isEqualToString:tttModel.height]) {
                                imageScale++;
                            } else {
                                imageScale--;
                            }
                        }
                        if (imageScale > 0) {
                            obj.imageScale = 1.0;
                        }
                        
                        OSSVAsinglViewMould *scrollGoodsModule = [[OSSVAsinglViewMould alloc] init];
                        OSSVScrollGoodsItesCCellModel *goodsItemCellModel = [[OSSVScrollGoodsItesCCellModel alloc] init];
                        goodsItemCellModel.size = [OSSVScrolllGoodsCCell itemSize:obj.imageScale];
                        goodsItemCellModel.subItemSize = [OSSVScrolllGoodsCCell subItemSize:obj.imageScale];
                        goodsItemCellModel.dataSource = obj;
                        [scrollGoodsModule.sectionDataList addObject:goodsItemCellModel];
                        [self.dataSourceList addObject:scrollGoodsModule];
                    }
                }
                //             //7分馆
                else if ([obj.type integerValue] == 7) {
                    OSSVAsinglViewMould *asingleTwoModule = [[OSSVAsinglViewMould alloc] init];
                    OSSVSevenAdvCCellModel *twoBannerCellModel = [[OSSVSevenAdvCCellModel alloc] init];
                    twoBannerCellModel.size = CGSizeMake(SCREEN_WIDTH, floor(kScale_375*292));
                    twoBannerCellModel.dataSource = obj;
                    [asingleTwoModule.sectionDataList addObject:twoBannerCellModel];
                    [self.dataSourceList addObject:asingleTwoModule];
                    
                } else {
                    
                    OSSVMutilBranchMould *branchModule = [[OSSVMutilBranchMould alloc] init];
                    branchModule.isNewBranch = YES;
                    branchModule.discoverBlockModel = obj;
                    
                    //防止没有
                    if (!STLIsEmptyString(obj.banner.imageURL) && [obj.banner.width floatValue] > 0 && [obj.banner.height floatValue] > 0) {
                        OSSVAsingleCCellModel *cellModel = [[OSSVAsingleCCellModel alloc] init];
                        cellModel.dataSource = obj.banner;
                        [branchModule.sectionDataList addObject:cellModel];
                    }
                    
                    if ([obj.images isKindOfClass:[NSArray class]]) {
                        
                        NSArray *branch = (NSArray *)obj.images;
                        [branch enumerateObjectsUsingBlock:^(id  _Nonnull advObj, NSUInteger idx, BOOL * _Nonnull stop) {
                            OSSVAsingleCCellModel *cellModel = [[OSSVAsingleCCellModel alloc] init];
                            cellModel.dataSource = advObj;
                            [branchModule.sectionDataList addObject:cellModel];
                        }];
                    }
                    [self.dataSourceList addObject:branchModule];
                }
            }
        }];
    }
        
    self.isChannel = NO;
    self.currentPage = 0;
    self.currentChannelModel = nil;
    if (self.allDiscoveryModel.tabsArray.count > 0) {
     
        OSSVHomeCThemeModel *themeModel = [[OSSVHomeCThemeModel alloc] init];
        themeModel.channel = [self.allDiscoveryModel.tabsArray copy];
        
        OSSVAsinglViewMould *singleModule = [[OSSVAsinglViewMould alloc] init];
        OSSVHomeChannelCCellModel *singleCellModel = [[OSSVHomeChannelCCellModel alloc] init];
        singleCellModel.dataSource = themeModel;
        [singleModule.sectionDataList addObject:singleCellModel];
        self.isChannel = YES;
        [self.dataSourceList addObject:singleModule];
        
        self.currentChannelModel = themeModel.channel.firstObject;
        
        if (_menuView) {
            [self.menuView reload];
            [self arMenuViewHandle];
        }
    } else {
        if (_menuView) {
            [_menuView removeFromSuperview];
            _menuView = nil;
        }
    }
        
    self.recommendWaterFallViewTemplate = [[OSSVWaterrFallViewMould alloc] init];
    self.recommendWaterFallViewTemplate.isTopSpace = YES;
    [self.dataSourceList addObject:self.recommendWaterFallViewTemplate];
    self.discoverAnalyticsManager.dataSourceList = [[NSMutableArray alloc] initWithArray:self.dataSourceList];
}

//判断首页是否有数据
//- (BOOL)homeHasDiscoverData {
//    
//    if (STLJudgeEmptyArray(self.discoveryHeaderModel.bannerArray) &&
//        [NSArrayUtils isEmptyArray:self.discoveryHeaderModel.threeArray]  &&
//        [NSArrayUtils isEmptyArray:self.discoveryHeaderModel.topicArray]  &&
//        [NSArrayUtils isEmptyArray:self.allDiscoveryModel.scrollArray] &&
//        [NSArrayUtils isEmptyArray:self.allDiscoveryModel.secondArray] &&
//        [NSArrayUtils isEmptyArray:self.discoveryHeaderModel.blocklist]  &&
//        [NSArrayUtils isEmptyArray:self.discoveryHeaderModel.newuser]  &&
//        [NSArrayUtils isEmptyArray:self.allDiscoveryModel.exchange]  &&
//        [NSArrayUtils isEmptyArray:self.discoveryHeaderModel.goodsList[@"goodList"]]) {
//        return NO;
//    }
//    return YES;
//}

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    
    if ([json[kStatusCode] integerValue] == kStatusCode_200) {
        if ([request isKindOfClass:[OSSVHomeDiscoverAip class]]) {
            return [OSSVHomeDiscoveryModel yy_modelWithJSON:json[kResult]];
        } else if([request isKindOfClass:[OSSVHomesMenuTabGoodAip class]]) {
//            return [NSArray yy_modelArrayWithClass:[HomeGoodListModel class] json:json[kResult][@"goodsList"]];
            return json[kResult];
        }
    } else {
        if ([json[kStatusCode] integerValue] == 202) return nil; // 此处也隐藏某些不必要的提示
        [self alertMessage:json[@"message"]];
    }
    
    return nil;
}

#pragma mark -  LazyLoad
// 为了刷新和加载的时候不需要要重复创建
- (OSSVHomeDiscoveryModel *)discoveryHeaderModel {
    if (!_discoveryHeaderModel) {
        _discoveryHeaderModel = [[OSSVHomeDiscoveryModel alloc] init];
    }
    return _discoveryHeaderModel;
}

- (OSSVHomeDiscoveryModel *)allDiscoveryModel {
    if (!_allDiscoveryModel) {
        _allDiscoveryModel = [[OSSVHomeDiscoveryModel alloc] init];
    }
    return _allDiscoveryModel;
}

- (NSMutableArray<id<CustomerLayoutSectionModuleProtocol>> *)dataSourceList {
    if (!_dataSourceList) {
        _dataSourceList = [NSMutableArray array];
    }
    return _dataSourceList;
}

#pragma mark - UICollectionViewDelegate
//指定单元格的个数 ，这个是一个组里面有多少单元格，e.g : 一个单元格就是一张图片
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    if (self.dataSourceList.count > 0) {
        id<CustomerLayoutSectionModuleProtocol>module = self.dataSourceList[section];
        return [module.sectionDataList count];
    }
    return 0;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSourceList.count;
}

-(id<CustomerLayoutSectionModuleProtocol>)customerLayoutDatasource:(UICollectionView *)collectionView sectionNum:(NSInteger)section {
    
    if (self.dataSourceList.count > section) {
        id<CustomerLayoutSectionModuleProtocol>module = self.dataSourceList[section];
        return module;
    }
    
    OSSVAsinglViewMould *template = [[OSSVAsinglViewMould alloc] init];
    return template;;
}

-(NSInteger)customerLayoutThemeMenusSection:(UICollectionView *)collectionView {
    return [self themeMenuDataIndex];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[OSSVThemesChannelsCCell class]] && _menuView && !_menuView.hidden) {
        [self menuViewShowWindow:_menuView];
    }
}
//构建单元格
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"---- %li ---%li",(long)indexPath.section,(long)indexPath.row);
    
    if (self.dataSourceList.count > indexPath.section) {
        id<CustomerLayoutSectionModuleProtocol>module = self.dataSourceList[indexPath.section];
        if (module.sectionDataList.count > indexPath.row) {
            id<CollectionCellModelProtocol>model = module.sectionDataList[indexPath.row];
            model.channelId = self.channel_id;
            model.channelName = self.channelName_en;
            id<OSSVCollectCCellProtocol>cell = [collectionView dequeueReusableCellWithReuseIdentifier:[model reuseIdentifier] forIndexPath:indexPath];
            cell.delegate = self;
            cell.model = model;
            UICollectionViewCell *resultCell = (UICollectionViewCell *)cell;
            return resultCell;
        }
    }
    
    
    UICollectionViewCell *resultCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(UICollectionViewCell.class) forIndexPath:indexPath];
    return resultCell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([scrollView.superview isKindOfClass:[WMMenuView class]]) {
        [self menuViewShowWindow:(WMMenuView *)scrollView.superview];
        return;
    }
    
    if (self.discoverDelegate && [self.discoverDelegate respondsToSelector:@selector(stl_DiscoveryScrollViewDidScroll:)]) {
        [self.discoverDelegate stl_DiscoveryScrollViewDidScroll:scrollView];
    }
    
    //滑动时候发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_HomeScroll object:scrollView userInfo:nil];

    if (!self.isChannel)return;
        
    CGFloat lastSectionHeight = [self.layout customerLastSectionFirstViewTop];
    CGFloat scrollerOffsetY = scrollView.contentOffset.y;
    if (_menuView) {
        CGFloat y = lastSectionHeight - scrollerOffsetY;
        if (y <= 0) {
            y = 0;
        }
        _menuView.frame = CGRectMake(_menuView.x, y, _menuView.width, _menuView.height);
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.discoverDelegate && [self.discoverDelegate respondsToSelector:@selector(stl_DiscoveryScrollViewDidEndDecelerating:)]) {
        [self.discoverDelegate stl_DiscoveryScrollViewDidEndDecelerating:scrollView];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.discoverDelegate && [self.discoverDelegate respondsToSelector:@selector(stl_DiscoveryScrollViewDidEndDragging:willDecelerate:)]) {
        [self.discoverDelegate stl_DiscoveryScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.discoverDelegate && [self.discoverDelegate respondsToSelector:@selector(stl_DiscoveryScrollViewWillBeginDragging:)]) {
        [self.discoverDelegate stl_DiscoveryScrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.discoverDelegate && [self.discoverDelegate respondsToSelector:@selector(stl_DiscoveryScrollViewDidEndScrollingAnimation:)]) {
        [self.discoverDelegate stl_DiscoveryScrollViewDidEndScrollingAnimation:scrollView];
    }
}


#pragma mark-- 首页模块跳转方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 跳转到我们指定的地方去
    NSLog(@"---- %li ---%li",(long)indexPath.section,(long)indexPath.row);
    
    if (self.dataSourceList.count > indexPath.section) {
        id <CustomerLayoutSectionModuleProtocol> module = self.dataSourceList[indexPath.section];
        
        if (module.sectionDataList.count > indexPath.row) {
            ///分馆类型
            NSString *sectionType = STLToString(module.discoverBlockModel.type);
            id<CollectionCellModelProtocol>model = module.sectionDataList[indexPath.row];

            if ([model.dataSource isKindOfClass:[OSSVHomeGoodsListModel class]]) {
                OSSVHomeGoodsListModel *goodsModel = (OSSVHomeGoodsListModel *)model.dataSource;
                OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
                goodsDetailsVC.goodsId = goodsModel.goodsId;
                goodsDetailsVC.wid = goodsModel.wid;
                goodsDetailsVC.coverImageUrl = goodsModel.goodsImageUrl;
                goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceHomeRecommend;
                goodsDetailsVC.coverImageUrl = STLToString(goodsModel.goodsImageUrl);
                
                STLAppsflyerGoodsSourceType sourceType = STLAppsflyerGoodsSourceHomeLike;
                if (self.allDiscoveryModel.tabsArray.count > 0) {
                    if (self.currentChannelModel) {
                        NSInteger index = [self.allDiscoveryModel.tabsArray indexOfObject:self.currentChannelModel];
                        if (index > 0) {
                            sourceType = STLAppsflyerGoodsSourceHomeOther;
                        }
                    }
                }
                NSDictionary *dic = @{kAnalyticsAction:[OSSVAnalyticsTool sensorsSourceStringWithType:sourceType sourceID:@""],
                                      kAnalyticsUrl:STLToString(self.channel_id),
                                      kAnalyticsPositionNumber:@(indexPath.row),
                                      kAnalyticsRequestId: STLToString(self.analyticsDic[kAnalyticsRequestId]),
                };
                [goodsDetailsVC.transmitMutDic addEntriesFromDictionary:dic];
                [self.controller.navigationController pushViewController:goodsDetailsVC animated:YES];
                
                return;
            }
            
            if ([model.dataSource isKindOfClass:[OSSVAdvsEventsModel class]]) {
                
                OSSVAdvsEventsModel *advEventModel = (OSSVAdvsEventsModel *)model.dataSource;
                
                ///分馆
                NSString *pageName = [UIViewController currentTopViewControllerPageName];
                NSString *attrNode1 = [NSString stringWithFormat:@"home_channel_%@",self.channelName];
                NSString *attrNode3 = [NSString stringWithFormat:@"home_channel_venue_block_%@",advEventModel.name];
                
                NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                             @"attr_node_1":attrNode1,
                                             @"attr_node_2":@"home_channel_venue",
                                             @"attr_node_3":attrNode3,
                                             @"position_number":@(indexPath.row+1),
                                             @"venue_position":sectionType,
                                             @"action_type":@([advEventModel advActionType]),
                                             @"url":[advEventModel advActionUrl],
                        };
                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDic];
                
                //数据GA埋点曝光 广告点击
                                    
                                    // item
                                    NSMutableDictionary *item = [@{
                                //          kFIRParameterItemID: $itemId,
                                //          kFIRParameterItemName: $itemName,
                                //          kFIRParameterItemCategory: $itemCategory,
                                //          kFIRParameterItemVariant: $itemVariant,
                                //          kFIRParameterItemBrand: $itemBrand,
                                //          kFIRParameterPrice: $price,
                                //          kFIRParameterCurrency: $currency
                                    } mutableCopy];


                                    // Prepare promotion parameters
                                    NSMutableDictionary *promoParams = [@{
                                //          kFIRParameterPromotionID: $promotionId,
                                //          kFIRParameterPromotionName:$promotionName,
                                //          kFIRParameterCreativeName: $creativeName,
                                //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                                //          @"screen_group":@"Home"
                                    } mutableCopy];

                                    // Add items
                                    promoParams[kFIRParameterItems] = @[item];
                                    
                                //        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
                
                
                [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:advEventModel];

                return;
            }
            
            if ([model.dataSource isKindOfClass:[STLAdvEventSpecialModel class]]) {
                STLAdvEventSpecialModel *modelSpecial = (STLAdvEventSpecialModel *)model.dataSource;
                OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] initWhtiSpecialModel:modelSpecial];
                [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:advEventModel];
                return;
            }
            
            if ([model.dataSource isKindOfClass:[OSSVCartGoodsModel class]]) {
                
                [self goToCart];
                return;
            }
        }
    }
}

///暂用于埋点吧
- (void)stl_discoverView:(UICollectionView *)collectionView discoverCell:(UICollectionViewCell *)cell itemCell:(UICollectionViewCell *)itemCell isMore:(BOOL)isMore {
    
}

#pragma mark - cell delegate
- (void)stl_scrollerGoodsCCell:(OSSVScrolllGoodsCCell *)scrollerGoodsCCell selectItemCell:(STLScrollerGoodsItemCell *)goodsItemCell isMore:(BOOL)isMore {
    
    [self stl_discoverView:self.themeCollectionView discoverCell:scrollerGoodsCCell itemCell:goodsItemCell isMore:isMore];
    
    ///滑动商品
    if (goodsItemCell && goodsItemCell.model && [goodsItemCell.model isKindOfClass:[STLDiscoveryBlockSlideGoodsModel class]]) {
        STLDiscoveryBlockSlideGoodsModel *slideGoodsModel = goodsItemCell.model;

        //原生专题
        OSSVAppNewThemeVC *newThemeCtrl = [[OSSVAppNewThemeVC alloc] init];
        newThemeCtrl.customId = slideGoodsModel.special_id;
        [self.controller.navigationController pushViewController:newThemeCtrl animated:YES];
    }

}

- (void)STL_ScrollerCollectionViewCell:(OSSVScrollCCell *)scorllerCell didClickMore:(OSSVAdvsEventsModel *)model {
    
    if ([scorllerCell.model.dataSource isKindOfClass:[OSSVSecondsKillsModel class]]) {
        [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:model];
    }
}

- (void)STL_CartCollectionViewCell:(OSSVHomeCartCCell *)scorllerCell didClickProduct:(OSSVCartGoodsModel *)model advEventModel:(OSSVAdvsEventsModel *)OSSVAdvsEventsModel {
    
    [self goToCart];
}

- (void)STL_ScrollerCollectionViewCell:(OSSVScrollCCell *)scorllerCell didClickProduct:(OSSVHomeGoodsListModel *)model advEventModel:(OSSVAdvsEventsModel *)OSSVAdvsEventsModel {
    if ([scorllerCell.model.dataSource isKindOfClass:[OSSVSecondsKillsModel class]]) {
        [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:OSSVAdvsEventsModel];
    } else {
        OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
        goodsDetailsVC.goodsId = model.goodsId;
        goodsDetailsVC.wid = model.wid;
        goodsDetailsVC.coverImageUrl = model.goodsImageUrl;
        goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceHome;
        goodsDetailsVC.coverImageUrl = STLToString(model.goodsImageUrl);
        [self.controller.navigationController pushViewController:goodsDetailsVC animated:YES];
    }
}

#pragma mark --STLFastSaleCollectionViewCellDelegate --跳转到闪购列表代理方法
- (void)jumpFlashSaleViewController {
    NSString *actId = @"";
    if (self.allDiscoveryModel.flashSale.goodsList.count) {
        actId = [self.allDiscoveryModel.flashSale.goodsList firstObject].activeId;
    }

    OSSVFlashSaleMainVC *vc = [[OSSVFlashSaleMainVC alloc] init];
//    NSLog(@"跳转到闪购页面");
    vc.channelId = self.channel_id;
    [self.controller.navigationController pushViewController:vc animated:YES];
}


#pragma mark - menuView datasource

- (NSInteger)numbersOfTitlesInMenuView:(WMMenuView *)menu
{
    return [[self gainMenuList] count];
}

- (NSString *)menuView:(WMMenuView *)menu titleAtIndex:(NSInteger)index
{
    NSArray *list = [self gainMenuList];
    if (list.count > index) {
        STLHomeCThemeChannelModel *model = list[index];
        return model.name;
    }
    return @"";
    
}

-(CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index
{
    NSArray *list = [self gainMenuList];
    if (list.count > index) {
        STLHomeCThemeChannelModel *model = list[index];
        NSString *title = model.name;
        UIFont *titleFont = [UIFont boldSystemFontOfSize:13];
        NSDictionary *attrs = @{NSFontAttributeName: titleFont};
        CGFloat itemWidth = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.width + 1;
        return ceil(itemWidth);
    }
    return 0;
}

- (WMMenuItem *)menuView:(WMMenuView *)menu initialMenuItem:(WMMenuItem *)initialMenuItem atIndex:(NSInteger)index
{

    initialMenuItem.selectedColor = [OSSVThemesColors col_0D0D0D];
    initialMenuItem.selectedSize = 13;
    initialMenuItem.normalColor = [OSSVThemesColors col_666666];
    initialMenuItem.isBlod = YES;
    return initialMenuItem;
}

- (CGFloat)menuView:(WMMenuView *)menu itemMarginAtIndex:(NSInteger)index
{
    if (index == 0 || index == self.allDiscoveryModel.tabsArray.count) {
        return 12;
    }
    return 24;
}
#pragma mark -- tab流 点击事件
- (void)menuView:(WMMenuView *)menu didSelectedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {

    if (index == currentIndex) {
        return;
    }
    
    NSArray *list = [self gainMenuList];
    STLHomeCThemeChannelModel *channelModel = nil;
    if (list.count > index) {
        channelModel = list[index];
    }
    
    if (!self.currentChannelModel) {
        self.currentChannelModel = channelModel;
    } else {
        if ([STLToString(self.currentChannelModel.category_id) isEqualToString: STLToString(channelModel.category_id)]) {
            return;
        }
        if (self.tabGoodsApi) {
            [self.tabGoodsApi.sessionDataTask cancel];
        }
    }
    self.currentChannelModel = channelModel;
    menu.selectIndex = index;
    //约定好，最后一排肯定是商品流
    id<CustomerLayoutSectionModuleProtocol>module = [self.dataSourceList lastObject];
    if (![module isKindOfClass:[OSSVWaterrFallViewMould class]]) {
        return;
    }
//    STLCustomeThemeProductListCacheModel *cacheModel = [self.customProductListCache objectForKey:@(index)];
//    STLCustomeThemeProductListCacheModel *cacheModel = [self.customProductListCache objectForKey:@(0)];

    //保存上一个的位置，数据
//    [self saveProductList:currentIndex list:module.sectionDataList offsetY:self.themeCollectionView.contentOffset pageIndex:0];
//    if (cacheModel) {
//        //如果有缓存，直接替换缓存
//        [module.sectionDataList removeAllObjects];
//        [module.sectionDataList addObjectsFromArray:cacheModel.cacheList];
//        [self.layout reloadSection:[self.dataSourceList count] - 1];
//        [self.themeCollectionView performBatchUpdates:^{
//            [self.themeCollectionView reloadSections:[NSIndexSet indexSetWithIndex:[self.dataSourceList count] - 1]];
//        } completion:NULL];
//        if ([self menuViewIsFloating]) {
//            ///悬浮使使用缓存的位置
////            if (!CGPointEqualToPoint(cacheModel.cacheOffset, CGPointZero)) {
////                [self.themeCollectionView setContentOffset:cacheModel.cacheOffset animated:NO];
////            }else{
//                [self.themeCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:[self.dataSourceList count] - 2] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//            [self resetMenuOffset];
//
//        }else{
//            ///不悬浮时使用当前的位置
//            [self resetMenuOffset];
//        }
//    }
    
    NSInteger section = [self themeMenuDataIndex];
    if (section <= 0) {
        section = 0;
    }
    
    [self.themeCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];

    NSMutableDictionary *aopAnyDic = self.discoverAnalyticsManager.sourecDic;
    [aopAnyDic setObject:@(index) forKey:kHomeDiscoverSubTabIndex];
    
    
    if (!self.indicatorView.superview) {
        [self.controller.view addSubview:self.indicatorView];
        [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.controller.view);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
    }
    self.currentPage = 0;
    [self.indicatorView startAnimating];
    [self.themeCollectionView.mj_footer beginRefreshing];
    
    
    NSString *pageName = [UIViewController currentTopViewControllerPageName];
    NSString *attrNode1 = [NSString stringWithFormat:@"home_channel_%@",self.channelName];
    NSString *attrNode3 = [NSString stringWithFormat:@"home_channel_stream_%@",STLToString(channelModel.name)];

    NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                 @"attr_node_1":attrNode1,
                                 @"attr_node_2":@"home_channel_stream",
                                 @"attr_node_3":attrNode3,
                                 @"position_number":@(0),
                                 @"venue_position":@(0),
                                 @"action_type":@(0),
                                 @"url":@"",
            };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDic];
    
    //数据GA埋点曝光 广告点击
                        
                        // item
                        NSMutableDictionary *item = [@{
                    //          kFIRParameterItemID: $itemId,
                    //          kFIRParameterItemName: $itemName,
                    //          kFIRParameterItemCategory: $itemCategory,
                    //          kFIRParameterItemVariant: $itemVariant,
                    //          kFIRParameterItemBrand: $itemBrand,
                    //          kFIRParameterPrice: $price,
                    //          kFIRParameterCurrency: $currency
                        } mutableCopy];


                        // Prepare promotion parameters
                        NSMutableDictionary *promoParams = [@{
                    //          kFIRParameterPromotionID: $promotionId,
                    //          kFIRParameterPromotionName:$promotionName,
                    //          kFIRParameterCreativeName: $creativeName,
                    //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                    //          @"screen_group":@"Home"
                        } mutableCopy];

                        // Add items
                        promoParams[kFIRParameterItems] = @[item];
                        
                    //        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
    

}

- (UIColor *)menuView:(WMMenuView *)menu titleColorForState:(WMMenuItemState)state atIndex:(NSInteger)index {
    if (state == WMMenuItemStateSelected) {
        return [OSSVThemesColors col_0D0D0D];
    }
    return [OSSVThemesColors col_666666];
}

- (CGFloat)menuView:(WMMenuView *)menu titleSizeForState:(WMMenuItemState)state atIndex:(NSInteger)index {
    return 13;
}


- (void)loadMenuData:(BOOL)isRefresh {

    if (!self.currentChannelModel) {
        if (self.indicatorView.isAnimating) {
            [self.indicatorView stopAnimating];
        }
        [self.themeCollectionView.mj_footer endRefreshing];
        return;
    }
    
    if (self.currentPage < 1) {
        isRefresh = YES;
    }
    
    NSString *catId = STLToString(self.currentChannelModel.category_id);
    @weakify(self)
    [self requestMenuCategory:@{@"cat_id":STLToString(catId),@"channel_id":STLToString(self.currentChannelModel.channel_id),@"isRefresh":@(isRefresh)} completion:^(id obj) {
        
        STLLog(@"------ end ---%@",catId);

        @strongify(self)
        
        NSInteger totalCount = 0;
        NSArray *goodsLists;
        NSDictionary *resultDic = @{};
        if (STLJudgeNSDictionary(obj)) {
            resultDic = (NSDictionary *)obj;
            goodsLists = [NSArray yy_modelArrayWithClass:[OSSVHomeGoodsListModel class] json:resultDic[@"goodsList"]];
            totalCount = [resultDic[@"totalCount"] integerValue];
            NSString *request_id = STLToString(resultDic[@"request_id"]);
        
            self.analyticsDic[kAnalyticsRequestId] = [ABTestTools Recommand_abWithRequestId:request_id];
            ///test recommend
//            self.analyticsDic[kAnalyticsRequestId] = @"request_id";
        }
        
        [self.themeCollectionView.mj_footer endRefreshing];
        if (self.indicatorView.isAnimating) {
            [self.indicatorView stopAnimating];
        }
        
        if (![STLToString(self.currentChannelModel.category_id) isEqualToString:catId]) {
            return;
        }
        STLLog(@"------ 分类ID：%@ isRefresh:%i",self.currentChannelModel.category_id,isRefresh);
        
        if (!self.recommendWaterFallViewTemplate) {
            self.recommendWaterFallViewTemplate = [[OSSVWaterrFallViewMould alloc] init];
            self.recommendWaterFallViewTemplate.isTopSpace = YES;
            [self.dataSourceList addObject:self.recommendWaterFallViewTemplate];
        }
        
        if (isRefresh || self.currentPage <= 1) {
            [self.recommendWaterFallViewTemplate.sectionDataList removeAllObjects];
        }
        
        if (STLJudgeNSArray(goodsLists) && self.dataSourceList.count > 0) {
            NSArray *results = goodsLists;
            
            NSInteger section = [self.dataSourceList count] - 1;
            NSInteger oldCount = [self.recommendWaterFallViewTemplate rowsNumInSection];
            [results enumerateObjectsUsingBlock:^(OSSVHomeGoodsListModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                OSSVProGoodsCCellModel *cellModel = [[OSSVProGoodsCCellModel alloc] init];
                obj.categoryId = catId;
                cellModel.dataSource = obj;
                [self.recommendWaterFallViewTemplate.sectionDataList addObject:cellModel];
            }];
            NSMutableArray *indexPaths = [NSMutableArray array];
            for(NSInteger i = oldCount;i < [self.recommendWaterFallViewTemplate.sectionDataList count]; i++){
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
            }
            
            if (indexPaths.count > 0){
                NSIndexPath *indexPath = indexPaths[0];
                [self.layout inserSection:indexPath.section];
            }
            [self.themeCollectionView reloadData];

            if (self.recommendWaterFallViewTemplate.sectionDataList.count >= totalCount) {
                [self.themeCollectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        
        if (!STLJudgeNSArray(goodsLists)) {
            [self.themeCollectionView reloadData];
            [self.themeCollectionView.mj_footer endRefreshingWithNoMoreData];
        }

    } failure:^(id obj) {
        @strongify(self)
        
        [self.themeCollectionView.mj_footer endRefreshing];
        if (self.indicatorView.isAnimating) {
            [self.indicatorView stopAnimating];
        }
    }];
}

- (NSInteger )themeMenuDataIndex {
    
    __block NSInteger section = -1;
    [self.dataSourceList enumerateObjectsUsingBlock:^(id<CustomerLayoutSectionModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[OSSVAsinglViewMould class]]) {
                
                OSSVAsinglViewMould *template = (OSSVAsinglViewMould *)obj;
                if (template.sectionDataList.firstObject &&[template.sectionDataList.firstObject isKindOfClass:[OSSVHomeChannelCCellModel class]]) {
                    section = idx;
                    *stop = YES;
                }
            }
    }];
    
    return section;
}

-(void)endfootRefresh
{
    NSInteger currentIndex = self.menuView.selectIndex;
    OSSVCustThemePrGoodsListCacheModel *cacheModel = [self.customProductListCache objectForKey:@(currentIndex)];
    if (cacheModel) {
        switch (cacheModel.footStatus) {
            case FooterRefrestStatus_Show:
                [self.themeCollectionView.mj_footer endRefreshing];
                break;
            case FooterRefrestStatus_NoMore:
                [self.themeCollectionView.mj_footer endRefreshingWithNoMoreData];
                break;
            case FooterRefrestStatus_Hidden:
                [self.themeCollectionView.mj_footer resetNoMoreData];
                break;
            default:
                break;
        }
    }
}

- (UICollectionView *)themeCollectionView {
    if (self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(stl_DiscoveryCollectionView)]) {
        return [self.dataDelegate stl_DiscoveryCollectionView];
    }
//    return [UICollectionView new];
    return [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[OSSVThemesMainLayout alloc] init]];
}

- (OSSVThemesMainLayout *)layout {
    if (self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(stl_DiscoveryLayout)]) {
        return [self.dataDelegate stl_DiscoveryLayout];
    }
    return [[OSSVThemesMainLayout alloc] init];
}

- (void)aopMenuView:(WMMenuView *)menuView willShowItemView:(WMMenuItem *)itemView index:(NSInteger)index {
    //aop 埋点曝光
}

- (void)menuViewShowWindow:(WMMenuView *)menuView {
    
    NSArray *subViews = menuView.scrollView.subviews;
    NSInteger index = 0;
    for (UIView *itemView in subViews) {
        if ([itemView isKindOfClass:[WMMenuItem class]]) {
            WMMenuItem *itemMenu = (WMMenuItem *)itemView;
            
            if ([itemView isDisplayedInScreen]) {
                STLLog(@"------Channel %@ : %li",itemMenu.text,(long)index);
                [self aopMenuView:menuView willShowItemView:itemMenu index:index];
            }
            index++;
        }
    }
    
}

#pragma mark -
//需求: 给平铺模式Section添加一个背景视图来 设置背景颜色
- (void)showSectionBgColor:(NSIndexPath *)indexPath
                  sectionY:(CGFloat)sectionY
              sectionModel:(id<CustomerLayoutSectionModuleProtocol>)sectionModel
{
//    if (STLIsEmptyString(sectionModel.bg_color)) return;

    if ([sectionModel isKindOfClass:[OSSVWaterrFallViewMould class]]) {
        return;
    }
    if ([self.sectionBgColorViewArr containsObject:sectionModel]) return;
    [self.sectionBgColorViewArr addObject:sectionModel];

    if (self.layout.columnHeightsArray.count > indexPath.section) {
        
        NSArray *arr = self.layout.columnHeightsArray;
        CGFloat topMagin = 0;
        CGFloat bottomMagin = [arr[indexPath.section] floatValue];
        CGFloat bgColorHeight = [arr[indexPath.section] floatValue];

        if (indexPath.section == 0) {
            topMagin = 0;
        } else if(indexPath.section > 0){
            topMagin = [self.layout.columnHeightsArray[indexPath.section-1] floatValue];
            bgColorHeight = bottomMagin - topMagin;
        }
        
//        CGFloat minimumLineSpacing = sectionModel.sectionMinimumLineSpacing;
//        CGFloat rowCount = sectionModel.sectionItemCount / [sectionModel.display_count floatValue];
//        CGFloat bgColorHeight = topMagin + sectionModel.sectionItemSize.height * ceil(rowCount) + minimumLineSpacing * (ceil(rowCount) - 1) + bottomMagin;
    
        
        UIView *sectionBgColorView = [[UIView alloc] init];
        sectionBgColorView.frame = CGRectMake(0, topMagin, SCREEN_WIDTH, bgColorHeight);
        [self.themeCollectionView insertSubview:sectionBgColorView atIndex:0];
        sectionBgColorView.backgroundColor = STLRandomColor();
        [self.sectionBgColorViewArr addObject:sectionBgColorView];
        
        STLLog(@"平铺模式添加背景色====%@", self.sectionBgColorViewArr);
        for (UIView *bgColorView in self.sectionBgColorViewArr) {
            if ([bgColorView isKindOfClass:[UIView class]]) {
                [self.themeCollectionView insertSubview:bgColorView atIndex:0];
            }
        }
    }
}

/**
 * 重新请求数据,删除浏览历史记录时,可能会改变位置,因此平铺模式下背景view都需要移除来重新创建
 */
- (void)removeSectionBgColorView {
    for (UIView *bgColorView in self.sectionBgColorViewArr) {
        if ([bgColorView isKindOfClass:[UIView class]]) {
            [bgColorView removeFromSuperview];
        }
    }
    [self.sectionBgColorViewArr removeAllObjects];
}


#pragma mark - customer layout delegate

-(void)customerLayoutDidLayoutDone
{
    if (self.dataSourceList.count < 2) {
        return;
    }
    if (![_menuView superview]) {
        if (self.isChannel) {
            [self.controller.view addSubview:self.menuView];
            [self.controller.view bringSubviewToFront:self.menuView];
            _menuView.scrollView.delegate = self;
            _menuView.hidden = NO;
            STLLog(@"---------menu done:%f",self.menuView.origin.y);

            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                self.menuView.transform = CGAffineTransformMakeScale(-1.0,1.0);
                [self arMenuViewHandle];
            }
        }
    } else if(_menuView) {
        _menuView.hidden = YES;
        if (self.isChannel) {
            _menuView.hidden = NO;
            
            CGFloat lastSectionHeight = [self.layout customerLastSectionFirstViewTop];
            CGFloat scrollerOffsetY = self.themeCollectionView.contentOffset.y;
                
            CGFloat y = lastSectionHeight - scrollerOffsetY;
            if (y <= 0) {
                y = 0;
            }
            _menuView.frame = CGRectMake(0, y, _menuView.width, _menuView.height);
        }
    }
//    if (!self.isChannel) {
//        self.themeCollectionView.mj_footer.hidden = YES;
//    }
}

//occ阿语适配
- (void)arMenuViewHandle {
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        NSArray *subMenuViews = self.menuView.scrollView.subviews;
        for (UIView *subView in subMenuViews) {
            if ([subView isKindOfClass:[WMMenuItem class]]) {
                subView.transform = CGAffineTransformMakeScale(-1.0,1.0);
            }
        }
    }
}


#pragma mark -

/////保存数据到缓存
//-(void)saveProductList:(NSInteger)selectIndex list:(NSMutableArray *)productList offsetY:(CGPoint)offset pageIndex:(NSInteger)pageIndex
//{
//    STLCustomeThemeProductListCacheModel *cacheModel = [self.customProductListCache objectForKey:@(selectIndex)];
//    if (cacheModel) {
//        cacheModel.cacheList = [productList mutableCopy];
//        if ([self menuViewIsFloating]) {
//            //悬浮状态保存悬浮状态的位置
//            cacheModel.cacheOffset = offset;
//        }
//    }else{
//        STLCustomeThemeProductListCacheModel *model = [[STLCustomeThemeProductListCacheModel alloc] init];
//        model.pageIndex = 0;
//        model.cacheList = [productList mutableCopy];
//        if ([self menuViewIsFloating]) {
//            model.cacheOffset = offset;
//        }
//        [self.customProductListCache setObject:model forKey:@(selectIndex)];
//    }
//}

//-(void)firstSaveProductList:(NSInteger)index list:(NSMutableArray *)productList sort:(NSString *)sort
//{
//    STLCustomeThemeProductListCacheModel *model = [[STLCustomeThemeProductListCacheModel alloc] init];
//    model.pageIndex = 0;
//    model.cacheList = [productList mutableCopy];
//    model.sort = sort;
//    CGPoint offset = CGPointMake(0, [self.layout customerSectionFirstAttribute:[self.dataSourceList count] - 2].origin.y);
//    model.floatingOffset = offset;
//    model.footStatus = FooterRefrestStatus_Show;
//    model.index = index;
//    [self.customProductListCache setObject:model forKey:@(index)];
//}

//-(void)resetMenuOffset
//{
//    CGFloat scrollerOffsetY = self.themeCollectionView.contentOffset.y;
//    CGFloat lastSectionHeight = [self.layout customerSectionFirstAttribute:[self.dataSourceList count] - 2].origin.y;
//    CGFloat y = lastSectionHeight - scrollerOffsetY;
//
//    if (y <= 0) {
//        y = 0;
//    }
//    if (_menuView) {
//        _menuView.frame = CGRectMake(0, y, _menuView.width, _menuView.height);
//    }
////    if (_bottomBgView) {
////        _bottomBgView.frame = CGRectMake(0, y, SCREEN_WIDTH, SCREEN_HEIGHT);
////    }
//}

/////Menu视图是否悬浮
//-(BOOL)menuViewIsFloating
//{
//    if (_menuView.y == 0) {
//        return YES;
//    }
//    return NO;
//}

-(NSArray *)gainMenuList
{
    
    NSInteger section = [self themeMenuDataIndex];
    if (section < 0) {
        return @[];
    }
    
    OSSVHomeChannelCCellModel *model = [self.dataSourceList objectAtIndex:section].sectionDataList.firstObject;
    OSSVHomeCThemeModel *themeModel = (OSSVHomeCThemeModel *)model.dataSource;
    if (themeModel && [themeModel.channel isKindOfClass:[NSArray class]]) {
        return themeModel.channel;
    }
    return @[];
}

-(OSSVHomeCThemeModel *)gainMenuThemeModel
{
    if (![self.dataSourceList count]) {
        return [[OSSVHomeCThemeModel alloc] init];
    }
    
    NSInteger section = [self themeMenuDataIndex];
    if (self.dataSourceList.count > section && section >= 0) {
        OSSVHomeChannelCCellModel *model = [self.dataSourceList objectAtIndex:section].sectionDataList.firstObject;

        OSSVHomeCThemeModel *themeModel = (OSSVHomeCThemeModel *)model.dataSource;
        return themeModel;
    }
    
    return [[OSSVHomeCThemeModel alloc] init];
}

#pragma mark - method
- (void)goToCart {
    OSSVCartVC *cartView = [OSSVCartVC new];
    [self.controller.navigationController pushViewController:cartView animated:YES];
}

-(void)STLScrollerCollectionViewCellDidClickMore:(OSSVAdvsEventsModel *)model {
    [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:model];
}

- (void)STL_HomeBannerCCell:(OSSVHomeAdvBannerCCell *)cell advEventModel:(OSSVAdvsEventsModel *)model showCellIndex:(NSInteger )index {
    
}

- (void)STL_HomeBannerCCell:(OSSVHomeAdvBannerCCell *)cell advEventModel:(OSSVAdvsEventsModel *)model index:(NSInteger)index{
    
    if ([cell isKindOfClass:[OSSVScrollAdvBannerCCell class]]) {
        
        OSSVScrollAdvBannerCCell *scrollCell = (OSSVScrollAdvBannerCCell *)cell;
        

        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        NSString *attrNode1 = [NSString stringWithFormat:@"home_channel_%@",self.channelName];
        NSString *attrNode3 = [NSString stringWithFormat:@"home_channel_sliding_icon_%@",model.name];

        NSDictionary *sensorsDicClick = @{@"page_name":STLToString(pageName),
                                          @"attr_node_1":attrNode1,
                                          @"attr_node_2":@"home_channel_sliding",
                                          @"attr_node_3":attrNode3,
                                          @"position_number":@(index+1),
                                          @"venue_position":@"",
                                          @"action_type":@([model advActionType]),
                                          @"url":[model advActionUrl],
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDicClick];
        
        //数据GA埋点曝光 广告点击
                            
                            // item
                            NSMutableDictionary *item = [@{
                        //          kFIRParameterItemID: $itemId,
                        //          kFIRParameterItemName: $itemName,
                        //          kFIRParameterItemCategory: $itemCategory,
                        //          kFIRParameterItemVariant: $itemVariant,
                        //          kFIRParameterItemBrand: $itemBrand,
                        //          kFIRParameterPrice: $price,
                        //          kFIRParameterCurrency: $currency
                            } mutableCopy];


                            // Prepare promotion parameters
                            NSMutableDictionary *promoParams = [@{
                        //          kFIRParameterPromotionID: $promotionId,
                        //          kFIRParameterPromotionName:$promotionName,
                        //          kFIRParameterCreativeName: $creativeName,
                        //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                        //          @"screen_group":@"Home"
                            } mutableCopy];

                            // Add items
                            promoParams[kFIRParameterItems] = @[item];
                            
                        //        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
        
        
    } else if([cell isKindOfClass:[OSSVHomeAdvBannerCCell class]]) {
        OSSVHomeAdvBannerCCell *bannerCell = (OSSVHomeAdvBannerCCell *)cell;
        
        
                
        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        NSString *attrNode1 = [NSString stringWithFormat:@"home_channel_%@",self.channelName];
        NSDictionary *sensorsDicClick = @{@"page_name":STLToString(pageName),
                                          @"attr_node_1":attrNode1,
                                          @"attr_node_2":@"home_channel_rolling",
                                          @"attr_node_3":@"",
                                          @"position_number":@(index+1),
                                          @"venue_position":@(0),
                                          @"action_type":@([model advActionType]),
                                          @"url":[model advActionUrl],
        };
        
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDicClick];
        
        //数据GA埋点曝光 广告点击
                            
                            // item
                            NSMutableDictionary *item = [@{
                        //          kFIRParameterItemID: $itemId,
                        //          kFIRParameterItemName: $itemName,
                        //          kFIRParameterItemCategory: $itemCategory,
                        //          kFIRParameterItemVariant: $itemVariant,
                        //          kFIRParameterItemBrand: $itemBrand,
                        //          kFIRParameterPrice: $price,
                        //          kFIRParameterCurrency: $currency
                            } mutableCopy];


                            // Prepare promotion parameters
                            NSMutableDictionary *promoParams = [@{
                        //          kFIRParameterPromotionID: $promotionId,
                        //          kFIRParameterPromotionName:$promotionName,
                        //          kFIRParameterCreativeName: $creativeName,
                        //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                        //          @"screen_group":@"Home"
                            } mutableCopy];

                            // Add items
                            promoParams[kFIRParameterItems] = @[item];
                            
                        //        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
        
        
    } else if([cell isKindOfClass:[OSSVHomeCycleSysTipCCell class]]) {
        OSSVHomeCycleSysTipCCell *bannerCell = (OSSVHomeCycleSysTipCCell *)cell;

        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        NSString *attrNode1 = [NSString stringWithFormat:@"home_channel_%@",self.channelName];
        NSDictionary *sensorsDicClick = @{@"page_name":STLToString(pageName),
                                     @"attr_node_1":attrNode1,
                                     @"attr_node_2":@"home_channel_marquee",
                                     @"attr_node_3":@"",
                                     @"position_number":@(index+1),
                                    @"venue_position":@(0),
                                    @"action_type":@([model advActionType]),
                                    @"url":[model advActionUrl],
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDicClick];
        
        //数据GA埋点曝光 广告点击
                            
                            // item
                            NSMutableDictionary *item = [@{
                        //          kFIRParameterItemID: $itemId,
                        //          kFIRParameterItemName: $itemName,
                        //          kFIRParameterItemCategory: $itemCategory,
                        //          kFIRParameterItemVariant: $itemVariant,
                        //          kFIRParameterItemBrand: $itemBrand,
                        //          kFIRParameterPrice: $price,
                        //          kFIRParameterCurrency: $currency
                            } mutableCopy];


                            // Prepare promotion parameters
                            NSMutableDictionary *promoParams = [@{
                        //          kFIRParameterPromotionID: $promotionId,
                        //          kFIRParameterPromotionName:$promotionName,
                        //          kFIRParameterCreativeName: $creativeName,
                        //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                        //          @"screen_group":@"Home"
                            } mutableCopy];

                            // Add items
                            promoParams[kFIRParameterItems] = @[item];
                            
                        //        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
        
        
        
        
    } else if([cell isKindOfClass:[OSSVSevenAdvBannerCCell class]]) {
        
        OSSVSevenAdvBannerCCell *bannerCell = (OSSVSevenAdvBannerCCell *)cell;

        if (index >=0) {
            
            
        } else {//滑动背景点击 index=-1
            
            
        }
    }
    [OSSVAdvsEventsManager advEventTarget:self.controller withEventModel:model];
}


- (void)setAnalyticsDic:(NSMutableDictionary *)analyticsDic {
    _analyticsDic = analyticsDic;
    self.discoverAnalyticsManager.sourecDic = analyticsDic;
}

- (NSMutableArray *)sectionBgColorViewArr {
    if (!_sectionBgColorViewArr) {
        _sectionBgColorViewArr = [NSMutableArray array];
    }
    return _sectionBgColorViewArr;
}


-(ZJJTimeCountDown *)countDown
{
    if (!_countDown) {
        _countDown = [[ZJJTimeCountDown alloc] init];
        _countDown.timeStyle = ZJJcountDownSecondStyle;
        _countDown.labelInContentView = NO;
        _countDown.delegate = self;
    }
    return _countDown;
}

-(WMMenuView *)menuView
{
    if (!_menuView) {
        _menuView = ({
            CGRect firstSectionRect = [self.layout customerSectionFirstAttribute:[self.dataSourceList count] - 2];
            
            CGFloat lastSectionHeight = [self.layout customerLastSectionFirstViewTop];
            CGFloat scrollerOffsetY = self.themeCollectionView.contentOffset.y;
                
            CGFloat y = lastSectionHeight - scrollerOffsetY;
            if (y <= 0) {
                y = 0;
            }
            STLLog(@"---------menu:%f    %f",CGRectGetMinY(firstSectionRect),y);
            WMMenuView *view = [[WMMenuView alloc] initWithFrame:CGRectMake(0, y, firstSectionRect.size.width, firstSectionRect.size.height)];
            view.backgroundColor = [UIColor whiteColor];
            view.style = WMMenuViewStyleLine;
            view.layoutMode = WMMenuViewLayoutModeScatter;
            view.speedFactor = 5;
            view.progressViewCornerRadius = 10;
            view.delegate = self;
            view.dataSource = self;
            
            OSSVHomeCThemeModel *themeModel = [self gainMenuThemeModel];
            if (themeModel) {
                view.lineColor = [UIColor colorWithHexColorString:STLToString(themeModel.colour)];
            }
            
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//                view.transform = CGAffineTransformMakeScale(-1.0,1.0);
            }
            view;
        });
    }
    return _menuView;
}

//- (UIView *)bottomBgView {
//    if (!_bottomBgView) {
//        _bottomBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//        _bottomBgView.backgroundColor = STLRandomColor();
//    }
//    return _bottomBgView;
//}

-(UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = ({
            UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
            indicatorView.hidesWhenStopped = YES;
            indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            indicatorView;
        });
    }
    return _indicatorView;
}


-(NSMutableDictionary *)customProductListCache
{
    if (!_customProductListCache) {
        _customProductListCache = [[NSMutableDictionary alloc] init];
    }
    return _customProductListCache;
}

- (OSSVHomeMainAnalyseAP *)discoverAnalyticsManager {
    if (!_discoverAnalyticsManager) {
        _discoverAnalyticsManager = [[OSSVHomeMainAnalyseAP alloc] init];
        _discoverAnalyticsManager.source = STLAppsflyerGoodsSourceHome;
    }
    return _discoverAnalyticsManager;
}

@end
