//
//  ZFCollectionViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCollectionViewModel.h"
#import "ZFGoodsModel.h"
#import "YWLocalHostManager.h"
#import "ZFProgressHUD.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFAnalytics.h"
#import "ZFAnalyticsTimeManager.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import <GGBrainKeeper/BrainKeeperManager.h>

@interface ZFCollectionViewModel ()
@property (nonatomic, strong) NSMutableArray<ZFGoodsModel *>                *dataArray;

@property (nonatomic, strong) NSMutableArray<ZFCollectionPostItemModel *>   *normalArray;
@property (nonatomic, strong) ZFCollectionPostListModel                     *normalPostModel;

@property (nonatomic, strong) NSMutableArray<ZFCollectionPostItemModel *>   *outfitArray;
@property (nonatomic, strong) ZFCollectionPostListModel                     *outfitPostModel;


@end

@implementation ZFCollectionViewModel
@synthesize listModel = _listModel;

- (void)setListModel:(ZFCollectionListModel *)listModel
{
    _listModel = listModel;
    if (![self.dataArray count]) {
        //从外部传入数据时，把数据源赋值给viewModel，后续值由接口返回的回调赋值
        [self.dataArray addObjectsFromArray:listModel.data];
    }
}

- (ZFCollectionListModel *)listModel
{
    if (!_listModel) {
        _listModel = [[ZFCollectionListModel alloc] init];
    }
    return _listModel;
}

- (NSMutableArray<ZFGoodsModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (NSMutableArray<ZFCollectionPostItemModel *> *)normalArray {
    if (!_normalArray) {
        _normalArray = [[NSMutableArray alloc] init];
    }
    return _normalArray;
}

- (NSMutableArray<ZFCollectionPostItemModel *> *)outfitArray {
    if (!_outfitArray) {
        _outfitArray = [[NSMutableArray alloc] init];
    }
    return _outfitArray;
}

- (void)requestCollectGoodsPageData:(BOOL)firstPage
                         completion:(void (^)(ZFCollectionListModel *listModel,NSArray *currentPageArray,NSDictionary *pageInfo))completion
{
    NSInteger currentPage = firstPage ? 1 : ++self.listModel.page;
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCacheData = NO;
    requestModel.taget = self.controller;
    requestModel.eventName = @"wishlist";
    requestModel.parmaters = @{
                               @"page"        : @(currentPage),
                               @"sess_id"     : ISLOGIN ? @"" : SESSIONID,
                               };
    requestModel.url = API(Port_collect);
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        self.listModel = [ZFCollectionListModel yy_modelWithJSON:responseObject[ZFResultKey]];
        NSArray *currentPageArray = self.listModel.data.copy;
        if (firstPage) {
            [self.dataArray removeAllObjects];
        }
        if (currentPageArray.count > 0) {
            if (firstPage) {
                self.dataArray = [NSMutableArray arrayWithArray:currentPageArray];
            } else {
                [self.dataArray addObjectsFromArray:currentPageArray];
            }
        }
        self.listModel.data = [NSMutableArray arrayWithArray:self.dataArray];

        // 谷歌统计
        [ZFAnalytics showCollectionProductsWithProducts:self.listModel.data position:0 impressionList:@"Wishlist" screenName:@"Wishlist" event:nil];
        
        if (completion) {
            NSDictionary *pageInfo = @{ kTotalPageKey  : @(self.listModel.total_page),
                                        kCurrentPageKey: @(self.listModel.page) };
            completion(self.listModel,currentPageArray,pageInfo);
        }
        
    } failure:^(NSError *error) {
        // ShowToastToViewWithText(nil, error.domain);//下拉页有提示
        if (!firstPage) (-- self.listModel.page);
        if (completion) {
            completion(self.listModel,nil,nil);
        }
    }];
}

- (void)requestCollectPostPageData:(BOOL)firstPage
                              type:(NSString *)type
                        completion:(void (^)(ZFCollectionPostListModel *listModel,NSArray *currentPageArray,NSDictionary *pageInfo))completion {
    
    BOOL isOutfit = [type isEqualToString:@"1"];
    NSInteger currentPage = firstPage ? 1 : (isOutfit ? ++self.outfitPostModel.currentPage : ++self.normalPostModel.currentPage );

    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.isCommunityRequest = YES;
    requestModel.isCacheData = NO;
    requestModel.url = CommunityAPI;
    requestModel.parmaters = @{@"review_type"    : ZFToString(type),
                               @"curPage"        : @(currentPage),
                               @"pageSize"       : @(20),
                               @"userId"         : USERID,
                               @"is_enc"         :  @"0",
                               @"type"           :  @"9",
                               @"app_type"       :  @"2",
                               @"directory"      :  @"81",
                               @"site"           :  @"ZZZZZcommunity",
                               };
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        NSInteger code     = [responseObject ds_integerForKey:@"code"];
        //NSString  *message = [responseObject ds_stringForKey:@"msg"];
        BOOL isOK = NO;
        NSArray *currentPageArray = nil;
        
        if (firstPage) {
            if (isOutfit) {
                [self.outfitArray removeAllObjects];
            } else {
                [self.normalArray removeAllObjects];
            }

        }
        if (code == 0) {
            isOK = YES;
            
            if (isOutfit) { //穿搭帖
                self.outfitPostModel = [ZFCollectionPostListModel yy_modelWithJSON:responseObject[@"data"]];
                currentPageArray = self.outfitPostModel.list;
                if (self.outfitPostModel && currentPageArray.count > 0) {
                    if (firstPage) {
                        self.outfitArray = [NSMutableArray arrayWithArray:currentPageArray];
                    } else {
                        [self.outfitArray addObjectsFromArray:currentPageArray];
                    }
                }
                self.outfitPostModel.list = self.outfitArray;

            } else { //普通帖
                
                self.normalPostModel = [ZFCollectionPostListModel yy_modelWithJSON:responseObject[@"data"]];
                currentPageArray = self.normalPostModel.list;
                if (self.normalPostModel && currentPageArray.count > 0) {
                    if (firstPage) {
                        self.normalArray = [NSMutableArray arrayWithArray:currentPageArray];
                    } else {
                        [self.normalArray addObjectsFromArray:currentPageArray];
                    }
                }
                self.normalPostModel.list = self.normalArray;
            }
        }
        
        if (completion) {
            if (!isOK) {
                completion(isOutfit ? self.outfitPostModel : self.normalPostModel,nil,nil);

            } else {
                ZFCollectionPostListModel *currnetPostModel = isOutfit ? self.outfitPostModel : self.normalPostModel;
                NSInteger totalCount = [currnetPostModel.total integerValue];
                NSInteger totalPage = totalCount / 20 + (totalCount % 20 > 0 ? 1 : 0);
                currnetPostModel.currentPage = currentPage;
                currnetPostModel.totalPage = totalPage;
                
                NSDictionary *pageInfo = @{ kTotalPageKey  : @(totalPage),
                                            kCurrentPageKey: @(currentPage) };
                completion(currnetPostModel, currentPageArray,pageInfo);
                
                if (currnetPostModel.flag) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPostFirstCollectRedDotNotification object:nil];
                }
            }
           
        }
        
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil, nil,nil);
        }
    }];
}
/**
 * 添加/取消收藏商品
 * type = 0/1 0添加 1取消
 */
+ (void)requestCollectionGoodsNetwork:(NSDictionary *)parmaters
                           completion:(void (^)(BOOL isOK))completion
                               target:(id)target
{
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.eventName = @"collecton";
    requestModel.taget = target;
    requestModel.url = API(Port_operationCollection);
    requestModel.parmaters = @{@"goods_id"       : parmaters[@"goods_id"] ? : @"",
                               @"type"           : ZFToString(parmaters[@"type"]),
                               @"token"          : (ISLOGIN ? TOKEN : @""),
                               @"sess_id"        : (ISLOGIN ? @"" : SESSIONID),
                               @"is_enc"         :  @"0"
                               };
    
    [ZFAnalyticsTimeManager recordRequestStartTime:Port_operationCollection];
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        [ZFAnalyticsTimeManager recordRequestEndTime:Port_operationCollection];
        
        BOOL isOK = NO;
        NSDictionary *dict = responseObject[ZFResultKey];
        if ([dict[@"error"] integerValue] == 0) {
            isOK = YES;
            
            NSDictionary *dataDict = dict[@"data"];
            if (ZFJudgeNSDictionary(dataDict)) {
                NSString *sess_id = [dataDict ds_stringForKey:@"sess_id"];
                if (!ZFIsEmptyString(sess_id)) {
                    [[NSUserDefaults standardUserDefaults] setValue:sess_id forKey:kSessionId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        } else {
            ShowToastToViewWithText(parmaters, responseObject[ZFResultKey][@"msg"]);
        }
        if (completion) {
            completion(isOK);
        }
    } failure:^(NSError *error) {
        // ShowToastToViewWithText(dict, error.domain);
        if (completion) {
            completion(NO);
        }
    }];
}

@end
