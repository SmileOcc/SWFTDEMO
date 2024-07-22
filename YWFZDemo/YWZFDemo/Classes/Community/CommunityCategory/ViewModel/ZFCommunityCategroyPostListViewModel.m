//
//  ZFCategroyPostListViewModel.m
//  ZZZZZ
//
//  Created by YW on 2018/8/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityCategroyPostListViewModel.h"
#import "YWLocalHostManager.h"
#import "ZFProgressHUD.h"
#import "YWCFunctionTool.h"
#import "ZFRequestModel.h"
#import "Constants.h"

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
    info[@"site"] = @"ZZZZZcommunity";
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
    requestModel.taget = self.controller;
    requestModel.eventName = @"get_list";
    
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            responseObject = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        
        if (self.params != info) return;
        
        YWLog(@"%@",responseObject);
        NSDictionary *dict = responseObject;
        if ([dict[@"statusCode"] integerValue] == 200) {
            if ([dict[@"data"] isKindOfClass:[NSDictionary class]]) {
                if ([dict[@"data"][@"list"] isKindOfClass:[NSArray class]]) {
                    
                    //NSString *total = dict[@"data"][@"total"];
                    NSArray *listArray = dict[@"data"][@"list"];
                    NSMutableArray *itemDatas = [[NSMutableArray alloc] init];
                    for (NSDictionary *dic in listArray) {
                        ZFCommunityCategoryPostItemModel *model = [ZFCommunityCategoryPostItemModel yy_modelWithJSON:dic];
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
