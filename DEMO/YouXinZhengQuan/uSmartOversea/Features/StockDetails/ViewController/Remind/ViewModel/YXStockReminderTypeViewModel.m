//
//  YXStockReminderTypeViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockReminderTypeViewModel.h"
#import "YXReminderModel.h"
#import "uSmartOversea-Swift.h"
#import "YXStockDetailReminderSettingViewModel.h"
#import "YXRemindTool.h"
#import "NSDictionary+Category.h"

@interface YXStockReminderTypeViewModel ()

// 是否需要有财报选项
@property (nonatomic, assign) BOOL isNeedFinancialReport;
// 是否需要有公告选项
@property (nonatomic, assign) BOOL isNeedAnnouncement;

@end

@implementation YXStockReminderTypeViewModel

- (void)initialize {
    [super initialize];
    
    //market
    self.market = self.params[@"market"];
    self.symbol = self.params[@"code"];
    self.formArr = [self.params yx_arrayValueForKey:@"formArr"];
    self.isNeedFinancialReport = [self.params yx_boolValueForKey:@"isNeedFinancialReport"];
    self.isNeedAnnouncement = [self.params yx_boolValueForKey:@"isNeedAnnouncement"];
    self.selecType = YXReminderTypeNone;
    

    NSArray *arr1 = @[@(YXReminderTypePriceUp), @(YXReminderTypePricDown), @(YXReminderTypeDayUp), @(YXReminderTypeDayDown), @(YXReminderTypePriceFiveMinUp), @(YXReminderTypePriceFiveMinDown)];
    NSArray *arr2 = @[@(YXReminderTypeTurnoverMore), @(YXReminderTypeVolumnMore), @(YXReminderTypeTurnoverRateMore), @(YXReminderTypeOvertopBuyOne), @(YXReminderTypeOvertopSellOne), @(YXReminderTypeOvertopBuyOneTurnover), @(YXReminderTypeOvertopSellOneTurnover)];
    
//    NSMutableArray *arrM3 = [NSMutableArray array];
//
//    if (self.isNeedAnnouncement) {
//        [arrM3 addObject:@(YXReminderTypeAnnouncement)];
//    }
//
//    if (self.isNeedFinancialReport) {
//        [arrM3 addObject:@(YXReminderTypeFinancialReport)];
//    }
//
//    NSArray *arr4 = @[@(YXReminderTypePositive), @(YXReminderTypeBad)];
//
//    NSArray *arr5 = @[@(YXReminderTypeClassicTechnical), @(YXReminderTypeKline), @(YXReminderTypeIndex), @(YXReminderTypeShock)];
    
//    if (arrM3.count > 0) {
//        self.dataSource = @[arr1, arr2, arrM3, arr4, arr5];
//    } else {
//        self.dataSource = @[arr1, arr2, arr4, arr5];
//    }
    self.dataSource = @[arr1, arr2];
    @weakify(self);
    self.didSelectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSIndexPath * _Nullable indexPath) {
        @strongify(self);
        
        NSNumber *number = self.dataSource[indexPath.section][indexPath.row];
        
        if (![self isEnableWithType:number.integerValue]) {
            return [RACSignal empty];
        }
        
        
        self.selecType = number.integerValue;
        if (self.dataCallBack) {
            self.dataCallBack(@(self.selecType));
        }
        if (self.comeFromPop) {    
            [[UIViewController cyl_topmostViewController].navigationController popViewControllerAnimated:YES];
            
        } else {
            YXStockDetailReminderSettingViewModel *viewModel = [[YXStockDetailReminderSettingViewModel alloc] initWithServices:self.services params:self.params];
            YXReminderModel *reminderModel = [[YXReminderModel alloc] init];
            reminderModel.status = 1;
            reminderModel.notifyType = 1;
            if ([YXRemindTool isFormWithType:number.integerValue]) {
                reminderModel.formShowType = number.integerValue;
            } else {
                reminderModel.ntfType = number.integerValue;
            }
            viewModel.reminderModel = reminderModel;
            [[UIViewController cyl_topmostViewController] dismissViewControllerAnimated:YES completion:^{
                [self.services pushViewModel:viewModel animated:YES];
            }];
        }
        return [RACSignal empty];
    }];

}


- (BOOL)isEnableWithType: (YXReminderType)type {
    
    // 判断形态(形态不能添加多个)
    if (self.formArr.count > 0) {
        if ([YXRemindTool isFormWithType:type]) {
            // 形态
            for (YXReminderModel *obj in self.formArr) {
                if (obj.formShowType == type) {
                    return NO;
                }
            }
        }
    }
        
    if (self.addType == YXReminderVCTypeEditPrice) {
        if ([YXRemindTool isFormWithType:type]) {
            // 股价
            return NO;
        } else {
            return YES;
        }
    }
    
    if (self.addType == YXReminderVCTypeEditForm) {
        if ([YXRemindTool isFormWithType:type]) {
            // 形态
            return YES;
        } else {
            return NO;
        }
    }
    
    return YES;
}

@end
