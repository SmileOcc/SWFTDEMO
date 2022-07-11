//
//  OSSVFeedbakReplaysViewModel.m
// XStarlinkProject
//
//  Created by odd on 2021/4/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVFeedbakReplaysViewModel.h"
#import "OSSVFeedbacksReplayListAip.h"

#import "OSSVFeedbacRepladyHeadView.h"

@interface OSSVFeedbakReplaysViewModel()

//列表数据
@property (nonatomic,strong) NSMutableArray<OSSVFeedbacksReplaysModel*> *dataArray;

@end

@implementation OSSVFeedbakReplaysViewModel


- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {

    BOOL isRefresh = [parmaters[@"isRefresh"] boolValue];
    @weakify(self);
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        OSSVFeedbacksReplayListAip *OSSVFeedBacksAip = [[OSSVFeedbacksReplayListAip alloc] init];
//        [OSSVFeedBacksAip.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [OSSVFeedBacksAip  startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self);
            
            if (isRefresh) {
                [self.dataArray removeAllObjects];
            }
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            NSArray *resutls = [self dataAnalysisFromJson: requestJSON request:OSSVFeedBacksAip];
            if (STLJudgeNSArray(resutls)) {
                
                [self.dataArray addObjectsFromArray:resutls];
                if (completion) {
                    completion(@YES);
                }
            }
            else {
                if (completion) {
                    completion(nil);
                }
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

- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    if ([json[kStatusCode] integerValue] == kStatusCode_200) {
        return [NSArray yy_modelArrayWithClass:OSSVFeedbacksReplaysModel.class json:json[kResult]];
    }
    else {
        [self alertMessage:json[@"message"]];
    }
    return nil;
}

/*========================================分割线======================================*/

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray.count > section) {
        OSSVFeedbacksReplaysModel *replayModel = self.dataArray[section];
        return replayModel.replyMessage.count + 1;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    OSSVFeedbacksReplaysModel *replayModel = nil;
    if (self.dataArray.count > indexPath.section) {
        replayModel = self.dataArray[indexPath.section];
    }
    if (indexPath.row == 0) {
        OSSVFeedBakReplaQuestiCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVFeedBakReplaQuestiCell.class) forIndexPath:indexPath];
        cell.model = replayModel;
        return cell;
    } else {
        OSSVFeedbackReplaAnsweCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVFeedbackReplaAnsweCell.class) forIndexPath:indexPath];
        if (replayModel && replayModel.replyMessage.count > indexPath.row - 1) {
            
            STLFeedbackReplayMessageModel *messageModel = replayModel.replyMessage[indexPath.row-1];
            cell.model = messageModel;
            BOOL isFirst = indexPath.row == 1 ? YES : NO;
            BOOL isLast = replayModel.replyMessage.count == indexPath.row;
            [cell updateModel:messageModel first:isFirst last:isLast];
        }
        return cell;
    }
}

/*========================================分割线======================================*/

#pragma mark - TableView Delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(OSSVFeedBakReplaQuestiCell.class) cacheByIndexPath:indexPath configuration:^(OSSVFeedBakReplaQuestiCell *cell) {
            if (self.dataArray.count > indexPath.section) {
                cell.model = self.dataArray[indexPath.section];
            }
        }];
    }
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass(OSSVFeedbackReplaAnsweCell.class) cacheByIndexPath:indexPath configuration:^(OSSVFeedbackReplaAnsweCell *cell) {
        if (self.dataArray.count > indexPath.section) {
            OSSVFeedbacksReplaysModel *replayModel = self.dataArray[indexPath.section];
            
            if (replayModel && replayModel.replyMessage.count > indexPath.row - 1) {
                STLFeedbackReplayMessageModel *messageModel = replayModel.replyMessage[indexPath.row-1];
                BOOL isFirst = indexPath.row == 1 ? YES : NO;
                BOOL isLast = replayModel.replyMessage.count == indexPath.row;
                [cell updateModel:messageModel first:isFirst last:isLast];
            }
        }
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    OSSVFeedbacRepladyHeadView *headView = [[OSSVFeedbacRepladyHeadView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 24)];
    headView.backgroundColor = [OSSVThemesColors col_F5F5F5];
    
    headView.timeLabel.text = @"";
    if (self.dataArray.count > section) {
        OSSVFeedbacksReplaysModel *replayModel = self.dataArray[section];
        headView.timeLabel.text = STLToString(replayModel.listTime);
    }
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}


#pragma mark - setter/getter

- (NSMutableArray<OSSVFeedbacksReplaysModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
@end
