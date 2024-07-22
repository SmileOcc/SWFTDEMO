//
//  ZFTrackingPackageViewModel.m
//  ZZZZZ
//
//  Created by YW on 4/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFTrackingPackageViewModel.h"
#import "ZFTrackingPackageModel.h"
#import "ZFTrackingListCell.h"
#import "ZFTrackingGoodsCell.h"
#import "ZFTrackingListHeaderView.h"
#import "ZFTrackingPackageApi.h"
#import "ZFTrackingListModel.h"
#import "ZFTrackingEmptyCell.h"
#import "ZFThemeManager.h"

static const NSInteger kTrackingSectionNumber  = 2;
static const CGFloat kRouteSectionHeaderHeight = 70.0;


typedef NS_ENUM(NSUInteger, TrackingSectionType) {
    TrackingGoodListSectionType = 0,
    TrackingListSectionType     = 1
};

@implementation ZFTrackingPackageViewModel
#pragma mark - Setter
- (void)setModel:(ZFTrackingPackageModel *)model {
    _model = model;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kTrackingSectionNumber;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case TrackingGoodListSectionType:
            return self.model.track_goods.count;
            break;
        case TrackingListSectionType:
            return self.model.track_list.count > 0 ? self.model.track_list.count : 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case TrackingGoodListSectionType:
        {
            UIView *lineView = [[UIView alloc] init];
            lineView.backgroundColor = ZFCOLOR(247, 247, 247, 1);
            return lineView;
        }
            break;
        case TrackingListSectionType:
        {
            ZFTrackingListHeaderView *headerView = [[ZFTrackingListHeaderView alloc] init];
            headerView.model = self.model;
            return headerView;
        }
            break;
        default:
        {
            return nil;
        }
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case TrackingGoodListSectionType:
            return 0.01;
            break;
        case TrackingListSectionType:
            return kRouteSectionHeaderHeight;
            break;
        default:
            return 0.01;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 12;
    }
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case TrackingGoodListSectionType:
        {
            ZFTrackingGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:[ZFTrackingGoodsCell setIdentifier]];
            if (indexPath.row <= self.model.track_goods.count - 1) {
                cell.model = self.model.track_goods[indexPath.row];
            }
            return cell;
        }
            break;
        case TrackingListSectionType:
        {
            if (self.model.track_list.count > 0) {
                ZFTrackingListCell *cell = [tableView dequeueReusableCellWithIdentifier:[ZFTrackingListCell setIdentifier]];
                if (indexPath.row <= self.model.track_list.count - 1) {
                    cell.model = self.model.track_list[indexPath.row];
                    cell.hasUpLine = indexPath.row == 0 ? NO : YES;
                    cell.currented = indexPath.row == 0 ? YES : NO;
                    cell.hasDownLine = indexPath.row == self.model.track_list.count - 1 ? NO : YES;
                }
                return cell;
            }else{
                ZFTrackingEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:[ZFTrackingEmptyCell setIdentifier]];
                return cell;
            }
        }
            break;
        default:
        {
            return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case TrackingGoodListSectionType:
        {
            return UITableViewAutomaticDimension;
        }
            break;
        case TrackingListSectionType:
        {
            if (self.model.track_list.count > 0) {
                return UITableViewAutomaticDimension;
            }else{
                return 250;
            }
        }
            break;
        default:
        {
            return 0;
        }
            break;
    }
}

@end
