//
//  ZFZFNewUserActivetyViewModel.m
//  ZZZZZ
//
//  Created by mac on 2019/1/5.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import "ZFZFNewUserActivetyViewModel.h"
#import "ZFNewUserExclusiveModel.h"
#import "ZFNewUserSecckillModel.h"
#import "ZFNewUserHeckReceivingStatusModel.h"
#import "ZFNewUserGoodsController.h"
#import "ZFNewUserRushViewController.h"
#import "ZFRequestModel.h"
#import "ZFApiDefiner.h"
#import "ZFPubilcKeyDefiner.h"
#import "YYModel.h"
#import "YWLocalHostManager.h"

@interface ZFZFNewUserActivetyViewModel ()

@end

@implementation ZFZFNewUserActivetyViewModel

#pragma mark - Public Methods
- (void)requestGetExclusiveListWihtCompletion:(void (^)(ZFNewUserExclusiveModel *homeExclusiveModel,BOOL isSuccess))completion {
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_getExclusiveList);
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {

        self.homeExclusiveModel = [ZFNewUserExclusiveModel yy_modelWithJSON:responseObject[ZFResultKey]];

        self.exclusiveControllerArr = [self queryChildViewControllers];
        
        self.exclusiveTitleArr = [self queryNavTitles];
        
        if (completion) {
            completion(self.homeExclusiveModel,YES);
        }
    
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil,NO);
        }
    }];
}

- (void)requestGetSecckillListWihtCompletion:(void (^)(ZFNewUserSecckillModel *bannerModel,BOOL isSuccess))completion {
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_GetSecckillList);
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        self.homeSecckillModel = [ZFNewUserSecckillModel yy_modelWithJSON:responseObject[ZFResultKey]];
        
        self.secckillcontrollerArr = [self rushChildViewControllers];
        
        self.secckilltitleArr = [self rushNavTitles];
        
        self.secckillSubtitleArr = [self rushSubNavTitles];
        
        if (completion) {
            completion(self.homeSecckillModel,YES);
        }
        
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil,NO);
        }
    }];
}

- (void)requestCheckReceivingStatusWihtCompletion:(void (^)(ZFNewUserHeckReceivingStatusModel *bannerModel,BOOL isSuccess))completion {
    
    ZFRequestModel *requestModel = [ZFRequestModel new];
    requestModel.url = API(Port_checkReceivingStatus);
    
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        
        self.heckReceivingStatusModel = [ZFNewUserHeckReceivingStatusModel yy_modelWithJSON:responseObject[ZFResultKey]];
        
        if (completion) {
            completion(self.heckReceivingStatusModel,YES);
        }
        
    } failure:^(NSError *error) {
        if (completion) {
            completion(nil,NO);
        }
    }];
}

- (NSArray *)queryChildViewControllers {
    NSMutableArray *vcArray = [NSMutableArray array];
    if (self.homeExclusiveModel.list.count > 0) {
        for (ZFNewUserExclusiveListModel *model in self.homeExclusiveModel.list) {
            ZFNewUserGoodsController *goodsListVC = [[ZFNewUserGoodsController alloc] init];
            goodsListVC.dataArray = model.goodsList;
            [vcArray addObject:goodsListVC];
        }
    } else {
        [vcArray addObject:[[ZFNewUserGoodsController alloc] init]];
    }
    return [vcArray copy];
}

- (NSArray *)queryNavTitles {
    NSMutableArray *titleArray = [NSMutableArray array];
    if (self.homeExclusiveModel.list.count > 0) {
        for (ZFNewUserExclusiveListModel *model in self.homeExclusiveModel.list) {
            [titleArray addObject:model.name];
        }
    }else{
        [titleArray addObject:@""]; // 传空只是占位
    }
    return [titleArray copy];
}

- (NSArray *)rushChildViewControllers {
    NSMutableArray *vcArray = [NSMutableArray array];
    if (self.homeSecckillModel.list.count > 0) {
        for (ZFNewUserSecckillListModel *model in self.homeSecckillModel.list) {
            ZFNewUserRushViewController *goodsListVC = [[ZFNewUserRushViewController alloc] init];
            goodsListVC.dataArray = model.goodsList;
            if (model.startTime > model.serviceTime) {
                goodsListVC.isNotStart = YES;
            }
            [vcArray addObject:goodsListVC];
        }
    } else {
        [vcArray addObject:[[ZFNewUserRushViewController alloc] init]];
    }
    return [vcArray copy];
}

- (NSArray *)rushNavTitles {
    NSMutableArray *titleArray = [NSMutableArray array];
    if (self.homeSecckillModel.list.count > 0) {
        for (int i = 0; i < self.homeSecckillModel.list.count; i++) {
            ZFNewUserSecckillListModel *model = self.homeSecckillModel.list[i];
            [titleArray addObject:model.sekillStartTime];
            if (i == 0) {
                self.remainingTime = model.endTime - model.serviceTime;
            }
        }
    }else{
        [titleArray addObject:@""]; // 传空只是占位
    }
    return [titleArray copy];
}

- (NSArray *)rushSubNavTitles {
    NSMutableArray *titleArray = [NSMutableArray array];
    if (self.homeSecckillModel.list.count > 0) {
        for (ZFNewUserSecckillListModel *model in self.homeSecckillModel.list) {
            [titleArray addObject:model.sekillStartDesc];
        }
    }else{
        [titleArray addObject:@""]; // 传空只是占位
    }
    return [titleArray copy];
}

@end
