//
//  MyPointViewModel.m
//  ZZZZZ
//
//  Created by DBP on 17/2/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "MyPointViewModel.h"
#import "PointsModel.h"
#import "MyPointsCell.h"
#import "YWLocalHostManager.h"
#import "ZFRequestModel.h"
#import <YYModel/YYModel.h>
#import "ZFPubilcKeyDefiner.h"
#import "YWCFunctionTool.h"

@interface MyPointViewModel ()
@property (nonatomic, strong) NSMutableArray        *dataSource;
@end

@implementation MyPointViewModel

/**
 * 分页请求积分数据
 */
- (void)requestPointsListData:(BOOL)firstPage
                   completion:(void (^)(NSDictionary *pageInfo, BOOL isSuccess))completion
{
    if (firstPage) {
        self.currentPage = 1;
    } else {
        self.currentPage += 1;
    }
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_GetPointsRecord);
    requestModel.parmaters = @{@"page" : @(self.currentPage),
                               @"size" : @(10)};
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        BOOL isSuccess = NO;
        NSInteger total_page = 0;
        NSDictionary *result = responseObject[ZFResultKey];
        
        if (ZFJudgeNSDictionary(result)) {
            if (self.currentPage == 1) {
                [self.dataSource removeAllObjects];;
            }
            NSArray *array = [NSArray yy_modelArrayWithClass:[PointsModel class] json:result[@"data"]];
            [self.dataSource addObjectsFromArray:array];
                        
            self.pointCountText = [NSString stringWithFormat:@"%ld",(long)[result[@"avaid_point"] integerValue]];
            self.rewardsText = ZFToString(result[@"rewards_tips"]);
            self.expireTipsText = ZFToString(result[@"expire_tips"]);
            total_page = [result[@"total_page"] integerValue];
            isSuccess = YES;
        }
        if (completion) {
            completion(@{
                kTotalPageKey  : @(total_page),
                kCurrentPageKey: @(self.currentPage)
            }, isSuccess);
        }
        
    } failure:^(NSError *error) {
        //ShowToastToViewWithText(nil, error.domain);
        --self.currentPage;
        if (completion) {
            completion(nil, NO);
        }
    }];
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

#pragma mark - tableviewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MyPointsCell *cell = [MyPointsCell pointCellWithTableView:tableView indexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = _dataSource[indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

@end
