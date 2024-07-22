//
//  ZFCommunityOutfitBorderViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/6/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityOutfitBorderViewModel.h"
#import "YWLocalHostManager.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFRequestModel.h"
#import <YYModel/YYModel.h>

#import "YWCFunctionTool.h"

@interface ZFCommunityOutfitBorderViewModel ()


@end

@implementation ZFCommunityOutfitBorderViewModel

- (void)requestOutfitBorderWithFinished:(void (^)(void))finishedHandel {
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_outfit_border);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        self.borderArray = [NSMutableArray new];
        self.goodsCateArray   = [NSMutableArray new];
        
        NSDictionary *resultDict = [responseObject ds_dictionaryForKey:@"result"];
        NSArray *cateDictArray   = [resultDict ds_arrayForKey:@"category"];
        NSArray *borderDictArray = [resultDict ds_arrayForKey:@"outer_borer"];
        for (NSDictionary *cateDict in cateDictArray) {
            ZFCommunityOutfitGoodsCateModel *cateModel = [ZFCommunityOutfitGoodsCateModel yy_modelWithJSON:cateDict];
            [self.goodsCateArray addObject:cateModel];
        }
        
        for (NSDictionary *borderDict in borderDictArray) {
            ZFCommunityOutfitBorderModel *borderModel = [ZFCommunityOutfitBorderModel yy_modelWithJSON:borderDict];
            [self.borderArray addObject:borderModel];
        }
        
        if (finishedHandel) {
            finishedHandel();
        }
    } failure:^(NSError *error) {
        if (finishedHandel) {
            finishedHandel();
        }
    }];
}

- (void)requestOutfitBorderCateID:(NSString *)cateID finished:(void (^)(void))finishedHandel {
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.parmaters = @{@"cate_id":ZFToString(cateID)};
    requestModel.url = API(Port_outfit_border_data);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        self.borderArray = [NSMutableArray new];
        self.bordersCateArray   = [NSMutableArray new];
        
        NSDictionary *resultDict = [responseObject ds_dictionaryForKey:@"result"];
        NSArray *cateDictArray   = [resultDict ds_arrayForKey:@"cate_list"];
        NSArray *borderDictArray = [resultDict ds_arrayForKey:@"border_list"];
        for (NSDictionary *cateDict in cateDictArray) {
            ZFCommunityOutfitBorderCateModel *cateModel = [ZFCommunityOutfitBorderCateModel yy_modelWithJSON:cateDict];
            [self.bordersCateArray addObject:cateModel];
        }
        
        for (NSDictionary *borderDict in borderDictArray) {
            ZFCommunityOutfitBorderModel *borderModel = [ZFCommunityOutfitBorderModel yy_modelWithJSON:borderDict];
            [self.borderArray addObject:borderModel];
        }
        
        if (finishedHandel) {
            finishedHandel();
        }
    } failure:^(NSError *error) {
        if (finishedHandel) {
            finishedHandel();
        }
    }];
}

- (NSInteger)goodsCateMenuCount {
    return self.goodsCateArray.count;
}

- (NSString *)cateTitleWithIndex:(NSInteger)index {
    ZFCommunityOutfitGoodsCateModel *cateModel = [self.goodsCateArray objectAtIndex:index];
    return cateModel.cateName;
}

- (NSString *)cateIDWithIndex:(NSInteger)index {
    ZFCommunityOutfitGoodsCateModel *cateModel = [self.goodsCateArray objectAtIndex:index];
    return cateModel.cateID;
}

- (NSArray *)outfitBorderImageURLs {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.borderArray.count];
    for (ZFCommunityOutfitBorderModel *model in self.borderArray) {
        [array addObject:model.border_img_url];
    }
    return array;
}

@end
