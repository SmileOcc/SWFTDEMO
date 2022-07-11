//
//  OSSVTrackingccItemcViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVTrackingccItemcViewModel.h"
#import "OSSVTrackingcRoutecHeadView.h"
#import "OSSVTrackingcRouteccCell.h"
#import "OSSVTrackingcGoodscCell.h"
#import "OSSVTrackingcInformationcModel.h"
#import "OSSVTrackingcGoodListcModel.h"
#import "OSSVTrackingcMessagecModel.h"
#import "OSSVLogistieeTrackeCell.h"
#import "UITableView+FDTemplateLayoutCell.h"

///把数目2 修改成1， 目的是不显示商品列表了
const NSInteger kTrackingSectionNumber = 1;
const CGFloat kGoodListsSectionFooterHeight = 10.0; //底部高度
const CGFloat kRouteSectionHeaderHeight = 55.0; //头部高度
const CGFloat kRouteCellHeight = 60; // Route Cell  高度


typedef NS_ENUM(NSUInteger, TrackingSectionType) {
    TrackingGoodListSectionType = 0,
    TrackingRouteSectionType  = 1
};


@interface OSSVTrackingccItemcViewModel ()

//@property (nonatomic, strong) NSMutableArray *goodsArray;
@property (nonatomic, strong) NSMutableArray *routesArray;
@property (nonatomic, copy) NSString *shippingName;
@property (nonatomic, copy) NSString *shippingNumber;

@end

@implementation OSSVTrackingccItemcViewModel

#pragma mark - GetModelData 

//- (void)setTrackingInformationModel:(OSSVTrackingcInformationcModel *)OSSVTrackingcInformationcModel {
//
//    self.goodsArray = [NSMutableArray arrayWithArray:OSSVTrackingcInformationcModel.goodList];
//    self.routesArray = [NSMutableArray arrayWithArray:OSSVTrackingcInformationcModel.trackingMessageList];
//    self.shippingName = OSSVTrackingcInformationcModel.shippingName;
//    self.shippingNumber = OSSVTrackingcInformationcModel.shippingNumber;
//}

- (void)setTrackingRoutesArray:(NSArray *)array {
    
    self.routesArray = [NSMutableArray arrayWithArray:STLJudgeNSArray(array) ? array : @[]];
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kTrackingSectionNumber;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    switch (section) {
//        case TrackingGoodListSectionType:
//            return self.goodsArray.count;
//            break;
//        case TrackingRouteSectionType:
//            return self.routesArray.count;
//            break;
//        default:
//            return 0;
//            break;
//    }
    return self.routesArray.count;
}


//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

//    switch (section) {
//        case TrackingGoodListSectionType:
//        {
//            UIView *lineView = [[UIView alloc] init];
//            lineView.backgroundColor = STLThemeColor.col_F1F1F1;
//            return lineView;
//        }
//            break;
//        case TrackingRouteSectionType:
//        {
//            TrackingRouteHeaderView *headerView = [[TrackingRouteHeaderView alloc] init];
//            [headerView setTitleString:self.shippingName trackingNumber:self.shippingNumber];
//            return headerView;
//        }
//            break;
//        default:
//        {
//            return 0;
//        }
//            break;
//    }
    
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//
//    switch (section) {
//        case TrackingGoodListSectionType:
//            return 1; // 一条线
//            break;
//        case TrackingRouteSectionType:
//            return kRouteSectionHeaderHeight;
//            break;
//        default:
//            return 0;
//            break;
//    }
//
//}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//
//    if (section == TrackingGoodListSectionType) {
//        UIView *footerView = [[UIView alloc] init];
//        footerView.backgroundColor = STLThemeColor.col_F1F1F1;
//        return footerView;
//    }
//    else {
//        return nil;
//    }
//
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//
//    if (section == TrackingGoodListSectionType) {
//        return kGoodListsSectionFooterHeight;
//    }
//    else {
//        return 0;
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    switch (indexPath.section) {
//        case TrackingGoodListSectionType:
//            return kGoodListsCellHeight;
//            break;
//        case TrackingRouteSectionType:
//            return kRouteCellHeight;
//            break;
//        default:
//            return 0;
//            break;
//    }
    OSSVTrackingcMessagecModel *model = self.routesArray[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:@"OSSVLogistieeTrackeCell" configuration:^(OSSVLogistieeTrackeCell *cell) {
        cell.model = model;
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVLogistieeTrackeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OSSVLogistieeTrackeCell"];
    
    OSSVTrackingcMessagecModel *model = self.routesArray[indexPath.row];
    cell.model = model;
    if (indexPath.row == 0) {
        if ([self.routesArray count] > 1) {
            [cell setDotLineStatus:DotLineStatus_Top];
        }else{
            [cell setDotLineStatus:DotLineStatus_OnlyOne];
        }
    }else if (indexPath.row == self.routesArray.count - 1){
        [cell setDotLineStatus:DotLineStatus_Bottom];
    }else{
        [cell setDotLineStatus:DotLineStatus_Normal];
    }
    return cell;
    
//    OSSVTrackingcRouteccCell *cell = [OSSVTrackingcRouteccCell trackingRouteCellWithTableView:tableView andIndexPath:indexPath];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.trackingRouteMessageModel = self.routesArray[indexPath.row];
//    if (indexPath.row == 0) {
//        [cell isNearestRouteCell];
//    }
//    if (indexPath.row == self.routesArray.count - 1) {
//        [cell isFarthestRouteCell];
//    }
//    return cell;
//    switch (indexPath.section) {
//        case TrackingGoodListSectionType:
//        {
//            OSSVTrackingcGoodscCell *cell = [OSSVTrackingcGoodscCell trackingGoodsCellWithTableView:tableView andIndexPath:indexPath];
//            cell.goodListModel = self.goodsArray[indexPath.row];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
//        }
//            break;
//        case TrackingRouteSectionType:
//        {
//            OSSVTrackingcRouteccCell *cell = [OSSVTrackingcRouteccCell trackingRouteCellWithTableView:tableView andIndexPath:indexPath];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            cell.trackingRouteMessageModel = self.routesArray[indexPath.row];
//            if (indexPath.row == 0) {
//                [cell isNearestRouteCell];
//            }
//            if (indexPath.row == self.routesArray.count - 1) {
//                [cell isFarthestRouteCell];
//            }
//            return cell;
//        }
//            break;
//        default:
//        {
//            return [UITableViewCell new];
//        }
//            break;
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 唯有此处section == 0 才可以选择
    if (indexPath.section == TrackingGoodListSectionType) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
  
}

@end
