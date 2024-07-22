//
//  ZFOutfitBorderViewModel.m
//  Zaful
//
//  Created by QianHan on 2018/6/5.
//  Copyright © 2018年 Y001. All rights reserved.
//

#import "ZFCommunityOutfitBorderViewModel.h"

@interface ZFCommunityOutfitBorderViewModel ()

@property (nonatomic, strong) NSMutableArray<ZFOutfitBorderModel *> *borderArray;
@property (nonatomic, strong) NSMutableArray<ZFOutfitCateModel *> *cateArray;

@end

@implementation ZFCommunityOutfitBorderViewModel

- (void)requestOutfitBorderWithFinished:(void (^)(void))finishedHandel {
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_outfit_border);
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        self.borderArray = [NSMutableArray new];
        self.cateArray   = [NSMutableArray new];
        
        NSDictionary *resultDict = [responseObject ds_dictionaryForKey:@"result"];
        NSArray *cateDictArray   = [resultDict ds_arrayForKey:@"category"];
        NSArray *borderDictArray = [resultDict ds_arrayForKey:@"outer_borer"];
        for (NSDictionary *cateDict in cateDictArray) {
            ZFOutfitCateModel *cateModel = [ZFOutfitCateModel yy_modelWithJSON:cateDict];
            [self.cateArray addObject:cateModel];
        }
        
        for (NSDictionary *borderDict in borderDictArray) {
            ZFOutfitBorderModel *borderModel = [ZFOutfitBorderModel yy_modelWithJSON:borderDict];
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

- (NSInteger)cateCount {
    return self.cateArray.count;
}

- (NSString *)cateTitleWithIndex:(NSInteger)index {
    ZFOutfitCateModel *cateModel = [self.cateArray objectAtIndex:index];
    return cateModel.cateName;
}

- (NSString *)cateIDWithIndex:(NSInteger)index {
    ZFOutfitCateModel *cateModel = [self.cateArray objectAtIndex:index];
    return cateModel.cateID;
}

- (NSArray *)outfitBorderImageURLs {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.borderArray.count];
    for (ZFOutfitBorderModel *model in self.borderArray) {
        [array addObject:model.imageURL];
    }
    return array;
}

@end
