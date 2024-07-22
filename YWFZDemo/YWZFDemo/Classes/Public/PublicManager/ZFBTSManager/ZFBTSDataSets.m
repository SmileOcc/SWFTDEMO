//
//  ZFBTSDataSets.m
//  ZZZZZ
//
//  Created by YW on 2019/6/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBTSDataSets.h"
#import "YWCFunctionTool.h"
#import "CategoryListPageModel.h"
#import "ZFApiDefiner.h"
#import "YWLocalHostManager.h"
#import "ZFBTSManager.h"

@interface ZFBTSDataSets ()
{
    NSDictionary *_injectURLList;
    NSArray *_injectKeys;
}
@property (nonatomic, strong) NSMutableArray *dataSets;//用于去重的模型数组
@property (nonatomic, strong) NSMutableArray *dataDicSets;//用于上传的字典数组

@end

@implementation ZFBTSDataSets

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZFBTSDataSets *dataSets = nil;
    dispatch_once(&onceToken, ^{
        dataSets = [[ZFBTSDataSets alloc] init];
    });
    return dataSets;
}

- (void)addObject:(ZFBTSModel *)btsModel
{
    @synchronized (self) {
        //去重
        NSInteger count = self.dataSets.count;
        BOOL isHave = NO;
        for (int i = 0; i < count; i++) {
            ZFBTSModel *oldModel = self.dataSets[i];
            isHave = [self isSameBtsParams:oldModel new:btsModel];
            if (isHave) {
                break;
            }
        }
        if (!isHave) {
            if ([self isEmptyParams:btsModel]) {
                //不为空的数据才加入
                [self.dataSets addObject:btsModel];
                [self.dataDicSets addObject:[btsModel yy_modelToJSONObject]];
            }
        }
    }
}

- (void)addObjectFromeArray:(NSArray<ZFBTSModel *> *)btsModelList
{
    if (![btsModelList count]) {
        return;
    }
    @synchronized (self) {
        //去重
        NSMutableArray *afBtsParamsList = [self.dataSets mutableCopy];
        NSMutableArray *filterResult = [[NSMutableArray alloc] init];
        for (int i = 0; i < btsModelList.count; i++) {
            BOOL repeat = NO;
            ZFBTSModel *newModel = btsModelList[i];
            for (int j = 0; j < afBtsParamsList.count; j++) {
                ZFBTSModel *oldModel = afBtsParamsList[j];
                BOOL temSame = [self isSameBtsParams:oldModel new:newModel];
                if (temSame) {
                    repeat = YES;
                    break;
                }
            }
            if (!repeat) {//没有找到相同的就加入
                if ([self isEmptyParams:newModel]) {
                    [filterResult addObject:newModel];
                }
            }
        }
        [self.dataSets addObjectsFromArray:filterResult];
        [self.dataDicSets addObjectsFromArray:[filterResult yy_modelToJSONObject]];
    }
}

- (NSArray <NSDictionary *> *)gainBtsSets
{
    if ([self.dataDicSets count]) {
        return self.dataDicSets;
    }
    NSMutableArray *btsArray = [[NSMutableArray alloc] init];
    [self.dataSets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZFBTSModel *model = (ZFBTSModel *)obj;
        if ([self isEmptyParams:model]) {
            [btsArray addObject:[model yy_modelToJSONObject]];
        }
    }];
    return btsArray.copy;
}

- (void)clearBtsSets
{
    @synchronized (self) {
        [self.dataSets removeAllObjects];
        [self.dataDicSets removeAllObjects];
    }
}

//相同返回YES 不同返回NO
- (BOOL)isSameBtsParams:(ZFBTSModel *)old new:(ZFBTSModel *)new
{
    if ([old.planid isEqualToString:new.planid] &&
        [old.bucketid isEqualToString:new.bucketid] &&
        [old.versionid isEqualToString:new.versionid] &&
        [old.plancode isEqualToString:new.plancode] &&
        [old.policy isEqualToString:new.policy]) {
        return YES;
    }
    return NO;
}

- (BOOL)isEmptyParams:(ZFBTSModel *)btsModel
{
    BOOL value1 = (ZFToString(btsModel.plancode).length && ZFToString(btsModel.policy).length);
    BOOL value2 = (ZFToString(btsModel.planid).length || ZFToString(btsModel.bucketid).length || ZFToString(btsModel.versionid).length);
    if (value1 && value2) {
        return YES;
    } else {
        return NO;
    }
}

-(NSMutableArray *)dataSets
{
    if (!_dataSets) {
        _dataSets = [[NSMutableArray alloc] init];
    }
    return _dataSets;
}

-(NSMutableArray *)dataDicSets
{
    if (!_dataDicSets) {
        _dataDicSets = [[NSMutableArray alloc] init];
    }
    return _dataDicSets;
}

///需要拦截的BTS链接
- (NSDictionary <NSString *, Class> *)interceptProtocol
{
    if (_injectURLList) {
        return _injectURLList;
    }
    _injectURLList = @{
                       API(@"category/get_list") : [NSDictionary class],
                       API(Port_zf_homeRecommendGoods) : [NSDictionary class],
                       API(Port_bigData_homeRecommendGoods) : [NSDictionary class],
                       [YWLocalHostManager appBtsSingleUrl] : [ZFBTSManager class],
                       [YWLocalHostManager appBtsListUrl] : [ZFBTSManager class],
                       API(Prot_cartRecommendGoods) : [NSDictionary class],
                       API(Port_GetAccountProduct) : [NSDictionary class],
                       CMS_API(Port_cms_community) : [NSDictionary class],
                       CMS_API(Port_cms_getMenuList) : [NSDictionary class],
                       API(Port_GoodsSameCate) : [NSDictionary class],
                       API(@"search/get_list") : [NSDictionary class],
                       [YWLocalHostManager cmsHomePageJsonS3URL:nil] : [NSDictionary class],
                       API(@"category/get_promotion_goods") : [NSDictionary class],
                       API(@"goods/detail") : [NSDictionary class],
                       API(@"goods/detail_real_time") : [NSDictionary class],
                       API(Port_checkout) : [NSDictionary class],
                       [YWLocalHostManager geshopAsyncInfoURL] : [NSDictionary class],
                       };
    return _injectURLList;
}

///BTS 解析的key列表
- (NSArray *)BTSinjectAllkeys
{
    if (_injectKeys) {
        return _injectKeys;
    }
    _injectKeys = @[
                    @"af_params_color",
                    @"af_params",
                    @"bts_data",
                    @"af_params_search",
                    @"aiReviewsBtsInfo",
                    @"first_order_bts_result"
                    ];
    
    return _injectKeys;
}

+ (NSURLSessionConfiguration *)ZFURLProtocolSessionConfiguration
{
    NSURLSessionConfiguration *customeConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    Class class = NSClassFromString(@"ZFURLInjectManager");
    if (class) {
        customeConfiguration.protocolClasses = @[class];
    }
    if (@available(iOS 11.0, *)) {
        //多路径TCP服务，提供Wi-Fi和蜂窝之间的无缝切换，以保持连接。
        customeConfiguration.multipathServiceType = NSURLSessionMultipathServiceTypeHandover;
    }
    return customeConfiguration;
}

@end
