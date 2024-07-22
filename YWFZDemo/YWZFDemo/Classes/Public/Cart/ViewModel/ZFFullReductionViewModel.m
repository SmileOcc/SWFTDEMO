//
//  ZFFullReductionViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/9/20.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFFullReductionViewModel.h"
#import "YWLocalHostManager.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFGoodsModel.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "ZFPubilcKeyDefiner.h"

@interface ZFFullReductionViewModel()
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSMutableArray<ZFGoodsModel *> *goodsArray;
@end

@implementation ZFFullReductionViewModel

/**
 * 获取详情页满减活动列表商品列表
 */
- (void)requestFullReductionData:(BOOL)isFirstPage
                        reduc_id:(NSString *)reduc_id
                   activity_type:(NSString *)activity_type
                  finishedHandle:(void (^)(NSArray *goodsArray, NSDictionary *pageDict))finishedHandle {
    
    if (isFirstPage) {
        self.currentPage = 1;
    } else {
        self.currentPage = ++self.currentPage;
    }
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_GoodsActivity_list);
    requestModel.parmaters = @{
                               @"reduc_id": ZFToString(reduc_id),
                               @"activity_type": ZFToString(activity_type),
                               @"page_size" : @"15",
                               @"page" : @(self.currentPage)
                               };
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        if (isFirstPage) {
            [self.goodsArray removeAllObjects];
        }
        
        if (finishedHandle) {
            NSDictionary *resultDict = [responseObject ds_dictionaryForKey:ZFResultKey];
            NSArray<ZFGoodsModel *> *goodsModelArray = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:resultDict[@"goods_list"]];
            // 分页商品
            [self.goodsArray addObjectsFromArray:goodsModelArray];
            
            NSDictionary *pageInfo = @{ kTotalPageKey  : ZFToString(resultDict[@"total_page"]),
                                        kCurrentPageKey: @(self.currentPage) ,
                                        @"title" : ZFToString(resultDict[@"activity_title"]),
                                        @"result_num" : ZFToString(resultDict[@"result_num"]),
                                        };
            finishedHandle(self.goodsArray, pageInfo);
        }
        
    } failure:^(NSError *error) {
        --self.currentPage;
        if (finishedHandle) {
            finishedHandle(nil, nil);
        }
    }];
}

- (NSMutableArray *)goodsArray {
    if(!_goodsArray){
        _goodsArray = [[NSMutableArray alloc] init];
    }
    return _goodsArray;
}

@end
