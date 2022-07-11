//
//  YXStockPickerResultViewModel.m
//  uSmartOversea
//
//  Created by youxin on 2020/9/8.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXStockPickerResultViewModel.h"
#import "YXSecuMobileBrief1Protocol.h"
#import "uSmartOversea-Swift.h"
#import "YXSecuGroupManager.h"

@interface YXStockPickerResultViewModel()

@property (nonatomic, strong) YXRequest *request;

@property (nonatomic, assign) NSInteger direction;

@property (nonatomic, assign) long long idNumber;

@end

@implementation YXStockPickerResultViewModel

- (void)initialize {
    [super initialize];

    self.direction = 1;
    self.sortState = YXSortStateDescending;

    self.filterType = YXStockFilterItemTypePctchng;

    if(self.params[@"market"] != nil) {
        self.market = self.params[@"market"];
    } else {
        self.market = kYXMarketHK;
    }

    if(self.params[@"updateType"]) {
        self.updateType = [self.params[@"updateType"] integerValue];
    } else {
        self.updateType = YXStockFilterOperationTypeNew;
    }

    if(self.params[@"idNumber"]) {
        self.idNumber = [self.params[@"idNumber"] longLongValue];
    }

    self.sortTypes = @[];
    NSMutableDictionary *namesMutDic = @{
        @(YXStockFilterItemTypePrice).stringValue : [YXLanguageUtility kLangWithKey:@"market_now"],
        @(YXStockFilterItemTypePctchng).stringValue : [YXLanguageUtility kLangWithKey:@"market_roc"],
        @(YXStockFilterItemTypeNetchng).stringValue : [YXLanguageUtility kLangWithKey:@"market_change"]}.mutableCopy;

    if(self.params[@"groups"]) {
        self.groups = self.params[@"groups"];

        NSMutableArray *typeArr = [NSMutableArray array];
        for (YXStokFilterGroup *group in self.groups) {
            for (YXStockFilterItem *item in group.items) {
                YXStockFilterItemType type = [[YXStockFilterEnumUtility shared] enumFromString:item.key];
                NSString *name = item.name;
                if ([item.key isEqualToString:@"rangeChng"]) {
                    YXStokFilterListItem *info = item.queryValueList.firstObject.list.firstObject;
                    type = [[YXStockFilterEnumUtility shared] enumFromString:[item.key stringByAppendingString:info.value]];
                    name = info.name;
                }
                [namesMutDic setValue:name ?: @"" forKey:@(type).stringValue];
                [typeArr addObject:@(type)];
            }
        }

        NSMutableArray *sorttypes = @[@(YXStockFilterItemTypePrice), @(YXStockFilterItemTypePctchng), @(YXStockFilterItemTypeNetchng)].mutableCopy;
        for (NSNumber *type in typeArr) {
            if (type.integerValue != YXStockFilterItemTypePrice &&
                type.integerValue != YXStockFilterItemTypePctchng &&
                type.integerValue != YXStockFilterItemTypeNetchng &&
                type.integerValue != YXStockFilterItemTypeNone) {
                [sorttypes addObject:type];
            }
        }

        self.namesDictionary = namesMutDic;
        self.sortTypes = sorttypes;
    } else {
        self.groups = @[];
    }

    if(self.params[@"groupName"]) {
        self.groupName = self.params[@"groupName"];
    } else {
        self.groupName = @"";
    }

    self.userLevel = [YXUserManager.shared getLevelWith:self.market];

    self.shouldPullToRefresh = YES;
    self.shouldInfiniteScrolling = YES;

    self.requestSubject = [RACSubject subject];
    self.endRefreshSubject = [RACSubject subject];
    self.bmpSubject = [RACSubject subject];

    HLNetWorkStatus netWorkStatus = [YXNetworkUtil.sharedInstance.reachability currentReachabilityStatus];
    if (netWorkStatus != HLNetWorkStatusNotReachable) {
        self.dataSource = @[];
    }

    @weakify(self)
    self.didSelectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSIndexPath * _Nullable indexPath) {
        @strongify(self)
        YXStockPickerList *realModel = self.dataSource[indexPath.section][indexPath.row];
        if (realModel.code && realModel.code.length < 1) {
            return [RACSignal empty];
        }
        NSMutableArray<YXStockInputModel *> *inputs = [NSMutableArray array];
        NSInteger realIndex = 0;
        NSInteger index = 0;
        for (YXStockPickerList *model in self.dataSource[indexPath.section]) {
            if (model.code.length > 0 && model.market.length > 0) {
                YXStockInputModel *input = [[YXStockInputModel alloc] init];
                input.market = model.market;
                input.symbol = model.code;
                input.name = model.name;

                [inputs addObject:input];

                if (realIndex == 0 && [model.code isEqualToString:realModel.code] && [model.market isEqualToString:realModel.market]) {
                    realIndex = index;
                }
                index ++;
            }
        }

        if (inputs.count > 0) {
            [self.services pushPath:YXModulePathsStockDetail context:@{@"dataSource": inputs, @"selectIndex": @(realIndex)} animated:YES];
        }
        return [RACSignal empty];
    }];


    self.didClickSortCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSArray *  _Nullable input) {
        @strongify(self)
        YXSortState state = [input.firstObject integerValue];
        YXStockFilterItemType type = [input.lastObject integerValue];

        NSInteger direction = 1;
        if (state == YXSortStateAscending) {
            direction = 0;
        }
        self.direction = direction;

        self.filterType = type;

        return [RACSignal empty];
    }];


    [[RACObserve(self, filterType) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.requestOffsetDataCommand execute:@(0)];
    }];

    self.saveResultCommand = [[RACCommand alloc] initWithSignalBlock:^(id _Nullable x) {
        @strongify(self)

        return [[self saveResultData] takeUntil:self.rac_willDeallocSignal];
    }];
}

- (NSArray *)checkedSecus {
    if (_checkedSecus == nil) {
        _checkedSecus = [NSArray array];
    }
    return _checkedSecus;
}


- (void)AllCheck {
    NSArray<YXStockPickerList*> *list = self.dataSource[0];
    for (YXStockPickerList* info in list) {
        info.isSelected = YES;
    }
    self.checkedSecus = list;
}

- (void)removeAllChecked {
    NSArray<YXStockPickerList*> *list = self.dataSource[0];
    for (YXStockPickerList* info in list) {
        info.isSelected = NO;
    }
    self.checkedSecus = [NSArray array];
}

- (BOOL)isChecked:(YXStockPickerList *)secu {

    return secu.isSelected;
}

- (void)check:(YXStockPickerList *)secu {
    if ([self isChecked:secu]) {
        return;
    }
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.checkedSecus];
    [array addObject:secu];
    self.checkedSecus = array;
}

- (void)unCheck:(YXStockPickerList *)secu {
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.checkedSecus];
    [array removeObject:secu];
    self.checkedSecus = array;
}

- (RACSignal *)requestWithOffset:(NSInteger)offset{
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)

        if (self.isEditing) {

            if (offset != 0) {
                self.page -= 1;
            }
            [self.endRefreshSubject sendNext:@(1)];
            [subscriber sendCompleted];
            return nil;
        }

        YXStockPickerResultRequestModel *requestModel = [[YXStockPickerResultRequestModel alloc] init];
        requestModel.market = self.market;
        requestModel.groups = self.groups;
        requestModel.from = offset;
        requestModel.asc = !self.direction;
        requestModel.sortKey = [[YXStockFilterEnumUtility shared] stringFromEnum: self.filterType];


        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        //YXProgressHUD *hud = [YXProgressHUD showLoading:@""];  //转圈
        @weakify(self)
        [request startWithBlockWithSuccess:^(YXResponseModel *responseModel) {
            @strongify(self)

            //[hud hideHud];
            YXStockPickerModel *item = [YXStockPickerModel yy_modelWithJSON:responseModel.data];
            if (item) {
                NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[self.dataSource firstObject]];
                if (offset == 0) {
                    array = [NSMutableArray array];
                }
                [array addObjectsFromArray:item.list];

                if (self.userLevel == QuoteLevelBmp && array.count > 20) {

                    NSMutableArray *bmpArray = [NSMutableArray array];
                    for (int i = 0; i < 20; i ++) {
                        [bmpArray addObject:array[i]];
                    }
                    array = bmpArray;

                    self.shouldInfiniteScrolling = NO;

                    [self.bmpSubject sendNext:nil];

                } else {
                    NSInteger total = array.count;
                    if (total >= item.count) {
                        self.loadNoMore = YES;
                    } else {
                        self.loadNoMore = NO;
                    }
                }


                if (self.totalCount != item.count) {
                    self.totalCount = item.count;
                    [self.requestSubject sendNext:@(item.count)];
                }

                self.dataSource = @[array];
                [subscriber sendNext:item];
            }
            [subscriber sendCompleted];

        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendError:request.error];
        }];
        return nil;
    }];
}


- (RACSignal *)saveResultData {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)

        YXStockFilterSaveResultRequestModel *requestModel = [[YXStockFilterSaveResultRequestModel alloc] init];
        requestModel.market = self.market;
        requestModel.optType = self.updateType;
        requestModel.name = self.groupName;
        if (self.updateType == YXStockFilterOperationTypeEdit) {
            requestModel.id = self.idNumber;
        }
        requestModel.groups = self.groups;
        YXProgressHUD *hud = [YXProgressHUD showLoading:@""];  //转圈
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(YXResponseModel *responseModel) {

            [hud hideHud];
            if (responseModel.code == YXResponseCodeSuccess) {

                [subscriber sendNext:@(1)];
            } else {
                [subscriber sendNext:@(-1)];
            }
            [subscriber sendCompleted];

        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [subscriber sendNext:@(-1)];
            [subscriber sendError:request.error];
        }];
        return nil;
    }];
}


@end
