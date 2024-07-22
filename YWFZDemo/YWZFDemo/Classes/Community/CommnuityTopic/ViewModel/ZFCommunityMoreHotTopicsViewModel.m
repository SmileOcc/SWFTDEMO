
//
//  ZFCommunityMoreHotTopicsViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/8/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityMoreHotTopicsViewModel.h"
#import "ZFCommunityTopicListApi.h"
#import "ZFCommunityMoreHotTopicListModel.h"
#import "ZFCommunityMoreHotTopicModel.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFCommunityMoreHotTopicsViewModel ()
@property (nonatomic, strong) ZFCommunityMoreHotTopicListModel      *topicListModel;
@property (nonatomic, strong) NSMutableArray<ZFCommunityMoreHotTopicModel *> *dataArray;
@end

@implementation ZFCommunityMoreHotTopicsViewModel
- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure{
    
    NSArray *array = (NSArray *)parmaters;
    NSInteger page = 1;
    if ([array[0] integerValue] == 0) {
        // 假如最后一页的时候
        if ([self.topicListModel.curPage integerValue] == self.topicListModel.pageCount) {
            if (completion) {
                completion(NoMoreToLoad);
            }
            return;
        }
        page = [self.topicListModel.curPage integerValue]  + 1;
    }
    
    ZFCommunityTopicListApi *api = [[ZFCommunityTopicListApi alloc] initWithcurPage:page pageSize:PageSize];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        @strongify(self)
        self.topicListModel = [self dataAnalysisFromJson: request.responseJSONObject request:api];
        if (page == 1) {
            self.dataArray = [NSMutableArray arrayWithArray:self.topicListModel.topic];
        }else{
            [self.dataArray addObjectsFromArray:self.topicListModel.topic];
        }
        self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewHideType : EmptyShowNoDataType;
        
        if (completion) {
            completion(self.dataArray);
        }
        
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        if (failure) {
            failure(nil);
        }
    }];
    
    
    
}

- (id)dataAnalysisFromJson:(id)json request:(SYBaseRequest *)request{
    YWLog(@"\n-------------------------- Request result --------------------------\n %@ : %@", [request class], request.responseJSONObject);
    if ([request isKindOfClass:[ZFCommunityTopicListApi class]]) {
//        if (ZF_COMMUNITY_RESPONSE_TEST_FLAG()) {//DEBUG 模式开关
//            json = ZF_COMMUNITY_RESPONSE_TEST();
//        }
        if ([json[@"code"] integerValue] == 0) {
            return [ZFCommunityMoreHotTopicListModel yy_modelWithJSON:json[@"data"]];
        }
    }
    return nil;
}
@end
