//
//  YXImportantNewsViewModel.m
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXImportantNewsDetailViewModel.h"
#import "uSmartOversea-Swift.h"
#import "YXListNewsModel.h"
#import "NSDictionary+Category.h"

@interface YXImportantNewsDetailViewModel ()



@end

@implementation YXImportantNewsDetailViewModel

- (void)initialize {
    
    NSMutableArray *tempArr = [NSMutableArray array];
    for (int i = 0; i < YXImportantNewsTypeBottomBanner; ++i) {
        [tempArr addObject:[[NSObject alloc] init]];
    }
    self.topContentArr = [NSMutableArray arrayWithArray:tempArr];
    
    self.commentListArr = [NSMutableArray array];
    
    self.newsId = [self.params yx_stringValueForKey:@"cid"];
    self.loadDetailCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [self loadDeailSignal];
    }];
    
    @weakify(self);
    self.getCommentList = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            [YXUGCCommentManager queryNewsOrLiveCommentListDataWithPost_id:self.newsId limit:5 offset:self.commentListOffset completion:^(YXNewsOrLiveCommentListModel * _Nullable model) {
                if (model) {
                    [model.list enumerateObjectsUsingBlock:^(YXCommentDetailCommentModel *  obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [YXSquareCommentManager transformCommentDetailCommentListLayoutWithModel:obj];
                    }];
                    self.commentListModel = model;
                }
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }];

            return  nil;
        }];
    }];
    
    
    self.loadBannerAndRecommendCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal zip:@[[self loadArticleListSignal], [self sendOtherAdvertiseRequestWithBannerId:21], [self sendOtherAdvertiseRequestWithBannerId:22]]];
    }];
    
}


- (RACSignal *)loadDeailSignal {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionShowInController)}];
        YXNewsDetailRequestModel *requestModel = [[YXNewsDetailRequestModel alloc] init];
        requestModel.newsid = self.newsId;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                self.newsModel = [YXListNewsModel yy_modelWithJSON:responseModel.data];
            } else {
                NSError *error = [NSError errorWithDomain:YXViewModel.defaultErrorDomain code:responseModel.code userInfo:@{NSLocalizedDescriptionKey: responseModel.msg}];
                [self.requestShowErrorSignal sendNext:error];
            }
            self.newsModel.content = [self.newsModel.content stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [self.requestShowLoadingSignal sendNext:@{YXViewModel.loadingViewPositionKey : @(YXRequestViewPositionHideInController)}];
            [self.requestShowErrorSignal sendNext:nil];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}



- (RACSignal *)loadArticleListSignal {
    
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        
        YXNewsDetailListRequestModel *requestModel = [[YXNewsDetailListRequestModel alloc] init];
        requestModel.articleId = self.newsId;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                NSArray *recommendList = [NSArray yy_modelArrayWithClass:[YXListNewsModel class] json:[responseModel.data yx_arrayValueForKey:@"news_list"]];
                for (YXListNewsModel *model in recommendList) {
                    [model calculateRecommendHeight];
                }
                
                if (recommendList.count > 0) {
                    YXNewsRecommendListModel *model = [[YXNewsRecommendListModel alloc] init];
                    model.list = recommendList;
                    self.recommendModel = model;
                }
            }
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}



/// 邀请好友banner请求
- (RACSignal *)sendOtherAdvertiseRequestWithBannerId: (int)pageId {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {

        YXBannerAdvertisementRequestModel *requestModel = [[YXBannerAdvertisementRequestModel alloc] init];
        
        requestModel.show_page = pageId;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                YXBannerActivityModel * model = [YXBannerActivityModel yy_modelWithDictionary:responseModel.data];
                [subscriber sendNext:model];

            }
            [subscriber sendCompleted];
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
}

-(NSMutableArray *)commentTotalDatas
{
    if (!_commentTotalDatas) {
        _commentTotalDatas = [NSMutableArray array];
    }
    return _commentTotalDatas;
}

-(YXCommentSectionTitleModel *)commentTitleModel {
    if (!_commentTitleModel) {
        _commentTitleModel = [[YXCommentSectionTitleModel alloc] init];
    }
    return _commentTitleModel;
}

-(YXCommentSectionFooterTitleModel *)footerTitleModel {
    if (!_footerTitleModel) {
        _footerTitleModel = [[YXCommentSectionFooterTitleModel alloc] init];
        _footerTitleModel.title = [YXLanguageUtility kLangWithKey:@"more_comment_open"];
    }
    return _footerTitleModel;
}

-(YXCommentDetailNoDataModel *)commentNodataModel {
    if (!_commentNodataModel) {
        _commentNodataModel = [[YXCommentDetailNoDataModel alloc] init];
        _commentNodataModel.image = @"empty_noData";
        _commentNodataModel.title =[YXLanguageUtility kLangWithKey:@"no_comment_hk"];
        _commentNodataModel.subTitle =  [YXLanguageUtility kLangWithKey:@"comment_now_hk"];
        _commentNodataModel.post_id = self.newsModel.newsId;
        _commentNodataModel.post_type = [NSString stringWithFormat:@"%ld",YXInformationFlowTypeNews];
    } 
    return _commentNodataModel;
}


@end
