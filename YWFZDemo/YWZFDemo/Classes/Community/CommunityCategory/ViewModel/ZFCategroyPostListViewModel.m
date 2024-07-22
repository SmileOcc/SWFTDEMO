//
//  ZFCommunityCategroyPostListViewModel.m
//  Zaful
//
//  Created by occ on 2018/8/15.
//  Copyright © 2018年 Zaful. All rights reserved.
//

#import "ZFCommunityCategroyPostListViewModel.h"

static NSInteger kZFPostListSize = 20;

@interface ZFCommunityCategroyPostListViewModel()

@property (nonatomic, assign) NSInteger                         curPage;
@property (nonatomic, strong) NSDictionary                      *params;

@end

@implementation ZFCommunityCategroyPostListViewModel

-(void)requestCategroyWaterItemListData:(BOOL)firstPage catID:(NSString *)catID completion:(void (^)(NSArray *currentPageDataArr, NSDictionary *pageInfo))completion {
    
    if (firstPage) {
        self.curPage = 1;
    } else {
        self.curPage = ++self.curPage;
    }

    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"type"] = @"9";
    info[@"directory"] = @"63";
    info[@"site"] = @"zafulcommunity";
    info[@"app_type"] = @"2";
    info[@"page"] = @(self.curPage);
    info[@"size"] = @(kZFPostListSize);
    info[@"cat_id"] = ZFToString(catID);
    info[@"loginUserId"] = USERID ?: @"0";
    self.params = info;

    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.isCommunityRequest = YES;
    requestModel.parmaters = info;
    requestModel.url = CommunityAPI;
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
        if (self.params != info) return;
        
        ZFLog(@"%@",responseObject);
        NSDictionary *dict = responseObject;
        if ([dict[@"statusCode"] integerValue] == 200) {
            if ([dict[@"data"] isKindOfClass:[NSDictionary class]]) {
                if ([dict[@"data"][@"list"] isKindOfClass:[NSArray class]]) {
                    
                    //NSString *total = dict[@"data"][@"total"];
                    NSArray *listArray = dict[@"data"][@"list"];
                    NSMutableArray *itemDatas = [[NSMutableArray alloc] init];
                    for (NSDictionary *dic in listArray) {
                        ZFCategoryPostItemModel *model = [ZFCategoryPostItemModel yy_modelWithJSON:dic];
                        [itemDatas addObject:model];
                    }
                    
                    if (completion) {
                        //加载判断 因为只返回总数
                        BOOL canLoadMore = itemDatas.count < kZFPostListSize ? NO : YES;
                        NSInteger totalPage = canLoadMore ? self.curPage + 1 : self.curPage;
                        NSDictionary *pageInfo = @{ kTotalPageKey  : @(totalPage),
                                                    kCurrentPageKey: @(self.curPage) };
                        completion(itemDatas, pageInfo);
                        return ;
                    }
                }
            }
        }
        
        if (completion) {
            if (!firstPage) {
                (-- self.curPage);
            }
            completion(@[], nil);
        }
        ShowToastToViewWithText(nil, dict[@"msg"]);
        
    } failure:^(NSError *error) {
        if (!firstPage) {
            (-- self.curPage);
        }
        if (completion) {
            completion(@[], nil);
        }
    }];
}

@end
