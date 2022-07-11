//
//  OSSVReviewsViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVReviewsViewModel.h"

//评论API
#import "OSSVReviewsApi.h"



//视图
#import "OSSVReviewsHeaderView.h"
#import "OSSVDetailsReviewsCell.h"

@interface OSSVReviewsViewModel ()



@end

//是否转菊花
#define TURN_HUD 0

@implementation OSSVReviewsViewModel

/*========================================分割线======================================*/

- (void)requestNetwork:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        NSDictionary *parmasDic =(NSDictionary *)parmaters;
        NSInteger page = 1;
        
        if ([STLToString(parmasDic[@"loadState"]) intValue] == 0) {
            page = self.reviewsModel.page + 1;
        }
        OSSVReviewsApi *api = [[OSSVReviewsApi alloc] initWithSKU:STLToString(parmasDic[@"sku"]) spu:STLToString(parmasDic[@"spu"]) goodsID:STLToString(parmasDic[@"goodsID"]) page:[@(page) stringValue] pageSize:@"20"];
        
        {
            // 取缓存数据
            if (api.cacheJSONObject) {
                id requestJSON = api.cacheJSONObject;
                self.reviewsModel = [self dataAnalysisFromJson: requestJSON request:api];
                self.reviewsModel.page = page;
                
                if (page == 1) {
                    self.dataArray = [NSMutableArray arrayWithArray:self.reviewsModel.reviewList];
                }
                self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoData;
                if (completion) {
                    completion(nil);
                }
            }
        }
        
#if TURN_HUD
        [api.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
#endif
        
        @weakify(self)
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            self.reviewsModel = [self dataAnalysisFromJson:requestJSON request:api];
            self.reviewsModel.page = page;
            if (page == 1) {
                self.dataArray = [NSMutableArray arrayWithArray:self.reviewsModel.reviewList];
            } else {
                [self.dataArray addObjectsFromArray:self.reviewsModel.reviewList];
            }
            
            self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoData;
            if (completion) {
                completion(nil);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            @strongify(self)
            self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoNet;
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        @strongify(self)
        self.emptyViewShowType = EmptyViewShowTypeNoNet;
        if (failure) {
            failure(nil);
        }
    }];
}

#pragma mark --最新商详评论数据请求
- (void)requestOnlyDetailReviewsNetwork:(id)parmaters completion:(void (^)(OSSVReviewsModel *reviewsModel))completion failure:(void (^)(id))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        NSDictionary *parmasDic =(NSDictionary *)parmaters;
        NSInteger page = 1;

        OSSVReviewsApi *api = [[OSSVReviewsApi alloc] initWithSKU:STLToString(parmasDic[@"sku"]) spu:STLToString(parmasDic[@"spu"]) goodsID:STLToString(parmasDic[@"goodsID"]) page:[@(page) stringValue] pageSize:@"4"];
      
        @weakify(self)
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            OSSVReviewsModel *result = [self dataAnalysisFromJson:requestJSON request:api];

            if (completion) {
                completion(result);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

/*========================================分割线======================================*/

#pragma mark - 数据解析
- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([request isKindOfClass:[OSSVReviewsApi class]]) {
        
        if (STLJudgeNSDictionary(json) && [json[@"retCode"] intValue] == 0) {
            NSDictionary *retDataDic = json[@"retData"];
            if (STLJudgeNSDictionary(retDataDic)) {
                return [OSSVReviewsModel yy_modelWithJSON:retDataDic];
            }
            
        }
        return nil;
    }
    return nil;
}

/*========================================分割线======================================*/

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.dataArray.count < 5) {
        tableView.mj_footer.hidden = YES;
    } else {
        tableView.mj_footer.hidden = NO;
    }
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVDetailsReviewsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVDetailsReviewsCell.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataArray[indexPath.section];
    cell.controller = self.controller;
    return cell;
}

/*========================================分割线======================================*/

#pragma mark - TableView Delegate
- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (self.reviewsModel.agvRate > 0) {
            OSSVReviewsHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(OSSVReviewsHeaderView.class)];
            headerView.model = self.reviewsModel;
            return headerView;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(OSSVDetailsReviewsCell.class) cacheByIndexPath:indexPath configuration:^(OSSVDetailsReviewsCell *cell) {
        cell.model = self.dataArray[indexPath.section];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (self.reviewsModel.agvRate > 0) {
            return 60;
        }
    }
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 8;
}

/*========================================分割线======================================*/

#pragma mark - DZNEmptyDataSetSource Methods
- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    self.emptyViewManager.customNoDataView = [self makeCustomNoDataView];
    return [self.emptyViewManager accordingToTypeReBackView:self.emptyViewShowType];
}

/*========================================分割线======================================*/

#pragma mark make - privateCustomView(NoDataView)
- (UIView *)makeCustomNoDataView {
    
    UIView * customView = [[UIView alloc] initWithFrame:CGRectZero];
    customView.backgroundColor = [UIColor whiteColor];
    
    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
    imageView.image = [UIImage imageNamed:@"reviews_bank"];
    [customView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(customView.mas_top).offset(56);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = OSSVThemesColors.col_666666;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.text = STLLocalizedString_(@"reviews_blank",nil);
    [customView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(196);
        make.width.mas_equalTo(SCREEN_WIDTH - 30);
        make.centerX.mas_equalTo(customView.mas_centerX);
    }];
    
    return customView;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
    return 0;
}

#pragma mark - DZNEmptyDataSetSource Methods
- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return NO;
}

- (void)emptyDataSetDidTapView:(UIScrollView *)scrollView {
    NSLog(@"%s",__FUNCTION__);
}

/*========================================分割线======================================*/

@end
