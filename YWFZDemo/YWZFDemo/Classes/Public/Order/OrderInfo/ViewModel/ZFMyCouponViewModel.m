//
//  ZFMyCouponViewModel.m
//  ZZZZZ
//
//  Created by YW on 2017/12/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFMyCouponViewModel.h"
#import "ZFMyCouponTableViewCell.h"
#import "ZFMyCouponModel.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "Masonry.h"
#import "Constants.h"
#import <GGBrainKeeper/BrainKeeperManager.h>

@interface ZFMyCouponViewModel() {
    NSIndexPath *_selectedIndexPath;
}
@property (nonatomic, strong) NSMutableArray *availableArray;
@property (nonatomic, strong) NSMutableArray *disabledArray;
@property (nonatomic, assign) BOOL          hasChangeCoupon;
@property (nonatomic, strong) ZFMyCouponModel *selectedModel;
@end

@implementation ZFMyCouponViewModel

- (void)checkEffectiveCoupon:(NSString *)couponCode
                  completion:(void (^)(id obj))completion
{
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.eventName = @"check_coupon";
    requestModel.taget = self.controller;
    requestModel.url = API(Port_checkCoupon);
    requestModel.parmaters = @{
                               @"coupon"                : ZFToString(couponCode),
                               @"token"                 : (ISLOGIN ? TOKEN : @""),
                               @"sess_id"               : (ISLOGIN ? @"" : SESSIONID),
                               ZFTestForbidUserCoupon   : @"forbid",
                               };
    
    __block BOOL isSuccess = YES;
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        NSString *tip = [responseObject[ZFResultKey] ds_stringForKey:@"msg"];
        if (!ZFIsEmptyString(tip)) {
            ShowToastToViewWithText(nil, tip);
            isSuccess = NO;
        }
        if (completion) {
            completion(@(isSuccess));
        }
    } failure:^(NSError *error) {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"Global_Network_Not_Available",nil));
        isSuccess = NO;
        if (completion) {
            completion(@(isSuccess));
        }
    }];
}

- (instancetype)initWithAvailableCoupon:(NSArray <ZFMyCouponModel *>*)availableCoupon
                          disableCoupon:(NSArray <ZFMyCouponModel *>*)disableCoupon
                             couponCode:(NSString *)couponCode
                           couponAmount:(NSString *)couponAmount {
    if (self = [self init]) {
        self.availableArray = [NSMutableArray new];
        self.disabledArray  = [NSMutableArray new];
        _selectedIndexPath  = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.availableArray addObjectsFromArray:availableCoupon];
        [self.disabledArray addObjectsFromArray:disableCoupon];
        [self reConfigDatasWithCouponCode:couponCode couponAmount:couponAmount];
    }
    return self;
}

- (void)selectedBefore {
    ZFMyCouponModel *model = nil;
    if (self.availableArray.count > _selectedIndexPath.row) {
        model = self.availableArray[_selectedIndexPath.row];
    }
    if (self.itemSelectedHandle) {
        if (model.isSelected) {
            self.itemSelectedHandle(model, self.hasChangeCoupon, NO);
        } else {
            self.itemSelectedHandle(nil, self.hasChangeCoupon, NO);
        }
    }
}

#pragma mark - UITableViewDataSource/UITableViewDelegate
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.availableArray.count > 0 ? self.availableArray.count : self.disabledArray.count;
    }
    return self.disabledArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.availableArray.count > 0
        && self.disabledArray.count > 0) {
        return 2;
    } else if (self.availableArray.count > 0
               || self.disabledArray.count > 0) {
        return 1;
    }
    return 0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ZFMyCouponTableViewCell *cell = [ZFMyCouponTableViewCell couponItemCellWithTableView:tableView indexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ZFMyCouponModel *model = [[ZFMyCouponModel alloc] init];
    if (indexPath.section == 1) {
        model = self.disabledArray[indexPath.row];
        cell.couponType = CouponDisabled;
        
        @weakify(self)
        cell.tagBtnActionHandle = ^{
            @strongify(self)
            model.isShowAll = !model.isShowAll;
            [self.disabledArray replaceObjectAtIndex:indexPath.row withObject:model];
            [UIView performWithoutAnimation:^{
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
        };
    } else {
        model = self.availableArray.count > 0 ? self.availableArray[indexPath.row] : self.disabledArray[indexPath.row];
        if (self.availableArray.count > 0) {
            cell.couponType = CouponAvailable;
        } else {
            cell.couponType = CouponDisabled;
        }
        @weakify(self)
        cell.tagBtnActionHandle = ^{
            @strongify(self)
            model.isShowAll = !model.isShowAll;
            if (self.availableArray.count > 0) {
                [self.availableArray replaceObjectAtIndex:indexPath.row withObject:model];
            } else {
                [self.disabledArray replaceObjectAtIndex:indexPath.row withObject:model];
            }
            [UIView performWithoutAnimation:^{
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
        };
    }
    [cell configWithModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ((section == 0
         && self.availableArray.count == 0)
        || section == 1) {
        return 30.0f;
    }
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1
        ||(section == 0
           && self.availableArray.count == 0
           && self.disabledArray.count > 0)) {
        UIView *headerView         = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.width, 30.0)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UIView *line               = [[UIView alloc] init];
        line.backgroundColor       = ZFCOLOR(178, 178, 178, 1.0);
        [headerView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            CGFloat offsetX = 35.0f * ScreenWidth_SCALE;
            make.leading.mas_equalTo(headerView.mas_leading).offset(offsetX);
            make.trailing.mas_equalTo(headerView.mas_trailing).offset(- offsetX);
            make.centerX.mas_equalTo(headerView.mas_centerX);
            make.centerY.mas_equalTo(headerView.mas_centerY);
            make.height.mas_equalTo(0.5f);
        }];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = tableView.backgroundColor;
        titleLabel.textColor       = ZFCOLOR(178, 178, 178, 1.0);
        titleLabel.textAlignment   = NSTextAlignmentCenter;
        titleLabel.font            = [UIFont systemFontOfSize:14.0f];
        titleLabel.text            = ZFLocalizedString(@"OrderDetail_Coupon_Header", nil);
        [headerView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(headerView.mas_centerX);
            make.centerY.mas_equalTo(headerView.mas_centerY);
            make.width.mas_equalTo(line.mas_width).offset(line.width - 68.0 * ScreenWidth_SCALE * 2);
        }];
        
        return headerView;
    }
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (self.availableArray.count > indexPath.row
        && indexPath.section == 0) {
        ZFMyCouponModel *preModel = self.availableArray[_selectedIndexPath.row];
        if (indexPath.row != _selectedIndexPath.row) {
            preModel.isSelected = NO;
        }
        
        ZFMyCouponModel *model    = self.availableArray[indexPath.row];
        model.isSelected = !model.isSelected;
        [self.availableArray replaceObjectAtIndex:indexPath.row withObject:model];
        
        [UIView performWithoutAnimation:^{
            [tableView reloadRowsAtIndexPaths:@[self->_selectedIndexPath, indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    
        if (self.selectedModel.tempIndex == model.tempIndex) {
            if (self.selectedModel.isSelected == model.isSelected) {
                self.hasChangeCoupon = NO;
            } else {
                self.hasChangeCoupon = YES;
            }
        } else {
            self.hasChangeCoupon = YES;
        }
        if (self.itemSelectedHandle) {
            if (model.isSelected) {
                self.itemSelectedHandle(model, self.hasChangeCoupon, YES);
            } else {
                self.itemSelectedHandle(nil, self.hasChangeCoupon, YES);
            }
        }
        _selectedIndexPath = indexPath;
    }
}

#pragma mark - private Method
- (void)reConfigDatasWithCouponCode:(NSString *)couponCode couponAmount:(NSString *)couponAmount {
    for (NSInteger i=0; i<self.availableArray.count; i++) {
        ZFMyCouponModel *model = self.availableArray[i];
        NSUInteger index = [self.availableArray indexOfObject:model];
        if ([model.code isEqualToString:couponCode]) {
            if (ISLOGIN) {
                model.isSelected   = YES;
                model.pcode_amount = couponAmount;
            } else {
                model.isSelected = ![AccountManager sharedManager].no_login_select_coupon;
            }
            [self.disabledArray removeObject:model];
            [self.availableArray replaceObjectAtIndex:index withObject:model];
            _selectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            
            ZFMyCouponModel *tempModel = [ZFMyCouponModel new];
            tempModel.tempIndex = i;
            tempModel.isSelected = model.isSelected;
            self.selectedModel = tempModel;
            break;
        }
    }
}

- (void)removeOrDeselectDefaultCoupon:(UITableView *)tableView {
    if (self.selectedModel) {
        NSInteger selectedIndex = self.selectedModel.tempIndex;
        if (selectedIndex > 1000) {//防止异常
            selectedIndex = 0;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        [self tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end
