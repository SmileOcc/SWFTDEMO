//
//  ZFUnlineSimilarViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/7/24.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFUnlineSimilarViewModel.h"
#import "ZFGoodsModel.h"
#import "YWLocalHostManager.h"
#import "AFNetworking.h"
#import "NSDictionary+SafeAccess.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "ZFBTSManager.h"
#import "ZFAnalytics.h"
#import "ZFTimerManager.h"
#import "NSStringUtils.h"

@interface ZFUnlineSimilarViewModel ()
@property (nonatomic, strong) NSMutableArray *goodsSNArray;      // 相似商品 SKU 集合
@property (nonatomic, assign) NSInteger goodsPage;    // 请求商品列表的当前页数
@property (nonatomic, assign) BOOL lastPage;
@end

@implementation ZFUnlineSimilarViewModel

- (instancetype)init {
    if (self = [super init]) {
        self.resultGoodsArray = [NSMutableArray new];
        self.goodsSNArray     = [NSMutableArray new];
        self.goodsPage        = 1;
        self.lastPage         = NO;
    }
    return self;
}

/// 此入口有收藏夹和购物车,都要对接bts
- (void)requestAISimilarMetalDataWithImageURL:(NSString *)url
                                      goodsSn:(NSString *)goods_sn
                                  findsPolicy:(NSString *)findsPolicy
                               completeHandle:(void (^)(void))complateHandle
{
    ZFRequestModel *model = [[ZFRequestModel alloc] init];
    if ([findsPolicy isEqualToString:kZFBts_A]) {
        model.forbidEncrypt = YES; //码隆搜图走原生AF请求
        model.requestSerializer = [AFHTTPRequestSerializer serializer];//此以图搜图需要单独设置序列化对象, 否则请求失败
        model.url = [NSString stringWithFormat:@"%@/url", [YWLocalHostManager searchMapURL]];
        model.parmaters = @{@"page" : @"0",
                            @"count": @"300",
                            @"version" : ZFToString(ZFSYSTEM_VERSION),
                            @"url": ZFToString(url) };
    } else {
        model.url = API(Port_by_sku_query_list);
        model.parmaters = @{@"sku": ZFToString(goods_sn) };
    }
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:model success:^(id responseObject) {

        if ([findsPolicy isEqualToString:kZFBts_A]) { //A:码隆搜图
            NSDictionary *dataDict = [responseObject ds_dictionaryForKey:@"data"];
            NSArray *resultsArray  = [dataDict ds_arrayForKey:@"results"];
            self.goodsSNArray = [NSMutableArray new];
            for (NSDictionary *metaDict in resultsArray) {
                NSDictionary *metaDataDict = [metaDict ds_dictionaryForKey:@"metadata"];
                NSString *goodsSN = [metaDataDict ds_stringForKey:@"goods_sn"];
                if (!ZFIsEmptyString(goodsSN)) {
                    [self.goodsSNArray addObject:goodsSN];
                }
            }
        } else { // B:内部识图
            NSArray *resultsArray  = [responseObject ds_arrayForKey:@"result"];
            self.goodsSNArray = [NSMutableArray new];
            for (NSDictionary *metaDict in resultsArray) {
                NSString *goodsSN = [metaDict ds_stringForKey:@"goods_sn"];
                if (!ZFIsEmptyString(goodsSN)) {
                    [self.goodsSNArray addObject:goodsSN];
                }
            }
        }
        if (complateHandle) {
            complateHandle();
        }
    } failure:^(NSError *error) {
        if (complateHandle) {
            complateHandle();
        }
    }];
}

- (void)requestGoodsListcompleteHandle:(void (^)(void))complateHandle {
    if (self.goodsSNArray.count <= 0) {
        self.lastPage = YES;
        if (complateHandle) {
            complateHandle();
        }
        return;
    }
    
    ZFBTSModel *productPhotoBtsModel = [ZFBTSManager getBtsModel:kZFBtsProductPhoto defaultPolicy:kZFBts_A];
    NSMutableArray *bts_test = [NSMutableArray array];
    [bts_test addObject:[productPhotoBtsModel getBtsParams]];
    
    ZFRequestModel *model = [[ZFRequestModel alloc] init];
    model.url             = API(Port_categorySearch);
    model.parmaters       = @{
                              @"goods_sn" : [self goodsSNSString],
                              @"bts_test" : bts_test
                              };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:model success:^(id responseObject) {
        NSArray<ZFGoodsModel *> *resultArray = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:responseObject[ZFResultKey][@"goods_list"]];
        [self.resultGoodsArray addObjectsFromArray:resultArray];
        self.goodsPage = self.goodsPage + 1;
        if (complateHandle) {
            complateHandle();
        }
        
        // 统计show商品
        if (resultArray.count > 0) {
            NSMutableArray *goodsn = [[NSMutableArray alloc] init];
            [resultArray enumerateObjectsUsingBlock:^(ZFGoodsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [goodsn addObject:ZFToString(obj.goods_sn)];
                
                // 巴西分期付款
                ZFAddressCountryModel *accountModel = [AccountManager sharedManager].accountCountryModel;
                NSString *region_code = ZFToString(accountModel.region_code);
                if ([region_code isEqualToString:@"BR"] && ![NSStringUtils isEmptyString:obj.instalMentModel.instalments]) {
                    obj.isInstallment = YES;
                    obj.tagsArray = @[[ZFGoodsTagModel new]];
                }
                
                // 倒计时开启，根据商品属性判断
                if ([obj.countDownTime integerValue] > 0) {
                    [[ZFTimerManager shareInstance] startTimer:[NSString stringWithFormat:@"GoodsList_%@", obj.goods_id]];
                }
            }];
            NSString *goodIds = [goodsn componentsJoinedByString:@","];
            NSDictionary *params = @{ @"af_content_type": @"findsimilar",
                                      @"af_content_id" : ZFToString(goodIds),
                                      };
            [ZFAnalytics appsFlyerTrackEvent:@"af_view_findsimilar" withValues:params];
        }
        
    } failure:^(NSError *error) {
        if (complateHandle) {
            complateHandle();
        }
    }];
}

- (NSString *)goodsSNSString {
    NSMutableString *goodsSNSString = [NSMutableString new];
    NSInteger pageGoodsCount  = kSimilarPageSize;
    NSInteger goodsBeginIndex = (self.goodsPage - 1) * pageGoodsCount;
    goodsBeginIndex = goodsBeginIndex > 0 ? goodsBeginIndex + 1 : goodsBeginIndex;
    for (NSInteger i = 0; i < pageGoodsCount; i++) {
        NSInteger index = goodsBeginIndex + i;
        if (index < self.goodsSNArray.count) {
            [goodsSNSString appendString:[self.goodsSNArray objectAtIndex:index]];
            if (i < pageGoodsCount - 1) {
                [goodsSNSString appendString:@","];
            }
        } else {
            self.lastPage = YES;
            break;
        }
    }
    return goodsSNSString;
}

#pragma mark - getter/setter
- (NSInteger)totalCount {
    return self.goodsSNArray.count;
}

- (NSInteger)rowCount {
    return self.resultGoodsArray.count;
}

- (ZFGoodsModel *)goodsModelWithIndex:(NSInteger)index {
    ZFGoodsModel *model = [self.resultGoodsArray objectAtIndex:index];
    return model;
}

- (BOOL)isLastPage {
    return self.lastPage;
}

@end
