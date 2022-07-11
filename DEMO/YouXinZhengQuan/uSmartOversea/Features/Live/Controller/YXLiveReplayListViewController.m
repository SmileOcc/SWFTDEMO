//
//  YXLiveReplayListViewController.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveReplayListViewController.h"
#import "YXLiveReplayListViewModel.h"
#import "YXLiveReplayCell.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXLiveReplayListViewController ()

@property (nonatomic, strong) YXLiveReplayListViewModel *viewModel;


@end

@implementation YXLiveReplayListViewController
@dynamic viewModel;


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    [self setUI];
    [self loadFirstPage];
}

- (void)setUI {
    self.whiteStyle = YES;
    self.tableView.rowHeight = 110;
    self.tableView.backgroundColor = [UIColor whiteColor];
    @weakify(self);
//    yxrefre *header = [YXSecondRefreshHeader headerWithRefreshingBlock:^{
//        @strongify(self);
//        [self loadFirstPage];
//    }];
//    self.tableView.mj_header = header;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (CGFloat)tableViewTop {
    return 0;
}

- (void)bindViewModel {
    [super bindViewModel];
}

#pragma mark - tableView delegata

- (NSDictionary *)cellIdentifiers {
    return @{
             @"YXLiveReplayCell" : @"YXLiveReplayCell"
             };
}
- (NSString *)cellIdentifierAtIndexPath:(NSIndexPath *)aIndexPath {
    return @"YXLiveReplayCell";
}


- (void)configureCell:(YXLiveReplayCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(NSString *)object {
    
    cell.liveModel = self.viewModel.dataSource[indexPath.section][indexPath.row];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    YXLiveDetailModel *model = self.viewModel.dataSource[indexPath.section][indexPath.row];
    [YXWebViewModel pushToWebVC:[YXH5Urls playNewsRecordUrlWith:model.id]];
    
//    NSDictionary *properties = @{YXSensorAnalyticsPropsConstants.propViewPage : @"回放详情页",
////                                 YXSensorAnalyticsPropsConstants.propViewName : @"单个回放视频",
//                                 YXSensorAnalyticsPropsConstants.propVideoId : model.id,
//                                 YXSensorAnalyticsPropsConstants.propVideoName : model.title,
//    };
//    [YXSensorAnalyticsTrack trackWithEvent:YXSensorAnalyticsEventViewClick properties:properties];
}



@end
