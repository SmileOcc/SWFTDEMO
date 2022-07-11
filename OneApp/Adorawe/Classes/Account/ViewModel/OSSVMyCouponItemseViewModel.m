//
//  OSSVMyCouponItemseViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMyCouponItemseViewModel.h"
#import "OSSVMysCouponssListAip.h"
#import "OSSVMyCouponsListsModel.h"
#import "OSSVMysCouponItemsCell.h"

@interface OSSVMyCouponItemseViewModel ()


@end

@implementation OSSVMyCouponItemseViewModel

#pragma mark
#pragma mark - Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        OSSVMysCouponssListAip *api = [[OSSVMysCouponssListAip alloc] initWithFlag:parmaters];
        @weakify(self)
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
              @strongify(self)
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            self.dataArray = [self dataAnalysisFromJson: requestJSON request:api];
            self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoData;
            if (completion) {
                completion(self.dataArray);
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            @strongify(self)
            self.emptyViewShowType = self.dataArray.count > 0 ? EmptyViewShowTypeHide : EmptyViewShowTypeNoNet;
            if (failure) {
                failure(error);
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

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request{
    if ([request isKindOfClass:[OSSVMysCouponssListAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            return [NSArray yy_modelArrayWithClass:[OSSVMyCouponsListsModel class] json:json[kResult]];
        }
    }
    return nil;
}

#pragma mark
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (self.dataArray.count < 7) {
//        tableView.mj_footer.hidden = YES;
//    } else {
//        tableView.mj_footer.hidden = NO;
//    }
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVMysCouponItemsCell *cell = [OSSVMysCouponItemsCell myCouponsCellWithTableView:tableView andIndexPath:indexPath];
    if (self.dataArray.count > indexPath.row) {
        OSSVMyCouponsListsModel *model= self.dataArray[indexPath.row];
        cell.model = model;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataArray.count > indexPath.row) {
        OSSVMyCouponsListsModel *model= self.dataArray[indexPath.row];
        return [OSSVMysCouponItemsCell contentHeigth:model];
    }
    return [OSSVMysCouponItemsCell contentHeigth:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return self.dataArray.count > 0 ? (SCREEN_HEIGHT > 736.0)?34:12 : 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] init];
}

@end
