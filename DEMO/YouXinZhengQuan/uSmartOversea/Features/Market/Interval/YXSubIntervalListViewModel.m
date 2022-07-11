//
//  YXSubIntervalListViewModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/28.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXSubIntervalListViewModel.h"
#import "YXMarketDetailSecu.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"
#import "YXSubIntervalListViewController.h"

@interface YXSubIntervalListViewModel()

@property (nonatomic, strong) YXRequest *request;


@end


@implementation YXSubIntervalListViewModel

- (void)initialize {
    [super initialize];
    
    self.market = [self.params yx_stringValueForKey:@"market"];
    
    self.sortType = YXMarketSortTypeAccer5;
    self.mobileBrief1Type = YXMobileBrief1TypeAccer5;
    self.direction = 1;
    self.sortState = YXSortStateDescending;
    self.shouldPullToRefresh = YES;
    
    
    HLNetWorkStatus netWorkStatus = [YXNetworkUtil.sharedInstance.reachability currentReachabilityStatus];
    if (netWorkStatus != HLNetWorkStatusNotReachable) {
        self.dataSource = @[];
    }
    
    @weakify(self)
    self.didClickSortCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSArray *  _Nullable input) {
        @strongify(self)
        YXSortState state = [input.firstObject integerValue];
        YXMobileBrief1Type type = [input.lastObject integerValue];
        
        NSInteger direction = 1;
        if (state == YXSortStateAscending) {
            direction = 0;
        }
        
//        if (direction == self.direction && self.mobileBrief1Type == type) {
//            return [RACSignal empty];
//        }
        
//        self.mobileBrief1Type = type;
        self.direction = direction;
//        self.sortState = state;
        
        switch (type) {
            case YXMobileBrief1TypeNow:
                self.sortType = YXMarketSortTypeNow;
                break;
            case YXMobileBrief1TypeRoc:
                self.sortType = YXMarketSortTypeRoc;
                break;
            case YXMobileBrief1TypeChange:
                self.sortType = YXMarketSortTypeChange;
                break;
            case YXMobileBrief1TypeMarketValue:
                self.sortType = YXMarketSortTypeMarketValue;
                break;
            case YXMobileBrief1TypePe:
                self.sortType = YXMarketSortTypePe;
                break;
            case YXMobileBrief1TypeAccer5:
                self.sortType = YXMarketSortTypeAccer3;
                break;
            case YXMobileBrief1TypePctChg5day:
                self.sortType = YXMarketSortTypePctChg5day;
                break;
            case YXMobileBrief1TypePctChg10day:
                self.sortType = YXMarketSortTypePctChg10day;
                break;
            case YXMobileBrief1TypePctChg30day:
                self.sortType = YXMarketSortTypePctChg30day;
                break;
            case YXMobileBrief1TypePctChg60day:
                self.sortType = YXMarketSortTypePctChg60day;
                break;
            case YXMobileBrief1TypePctChg120day:
                self.sortType = YXMarketSortTypePctChg120day;
                break;
            case YXMobileBrief1TypePctChg250day:
                self.sortType = YXMarketSortTypePctChg250day;
                break;
            case YXMobileBrief1TypePctChg1year:
                self.sortType = YXMarketSortTypePctChg1year;
                break;
            default:
                break;
        }
        
        return [RACSignal empty];
    }];
    
    [[RACObserve(self, sortType) skip:1] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.requestOffsetDataCommand execute:@(0)];
    }];
    
    self.didClickRotateCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSIndexPath * _Nullable indexPath) {
        @strongify(self)
        //TODO: FIX ME
        YXSubIntervalListViewModel *viewModel = [[YXSubIntervalListViewModel alloc] initWithServices:self.services params:self.params];
        
        viewModel.sortState = self.sortState;
        viewModel.mobileBrief1Type = self.mobileBrief1Type;
        viewModel.isLandscape = YES;
        viewModel.dataSource = self.dataSource;
        viewModel.selectType = self.selectType;
        viewModel.sortType = self.sortType;

        [self.services pushViewModel:viewModel animated:NO];
        
        return [RACSignal empty];
    }];
}

- (RACSignal *)requestWithOffset:(NSInteger)offset{
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        if (self.sortType == 0) {
            return nil;
        }
        YXMarketRequestItem *item = [[YXMarketRequestItem alloc] init];
        item.from = offset;
        item.count = self.perPage;
        if ([self.market isEqualToString:kYXMarketHK]) {
            item.code = @"HK_ALL";
        } else if ([self.market isEqualToString:kYXMarketUS]) {
            item.code = @"US_ALL";
        } else {
            item.code = @"HS_ALL";
        }
        
        item.market = self.params[@"market"];
        item.sorttype = self.sortType;
        item.sortdirection = self.direction;
        
        QuoteLevel authority = [[YXUserManager shared] getLevelWith:item.market];
        item.level = authority;
        
        if ([item.market isEqualToString:kYXMarketHK]) {
            if (authority == QuoteLevelBmp) {
                item.level = QuoteLevelDelay;
            }
        }
        
        YXMarketMergeRequestModel *requestModel = [[YXMarketMergeRequestModel alloc] init];
        
        requestModel.codelist = @[item];
        
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        
        @weakify(self)
        [request startWithBlockWithSuccess:^(YXMarketMergeResponseModel *responseModel) {
            @strongify(self)
            NSDictionary *dic = [responseModel.list firstObject];
            NSString *level = [NSString stringWithFormat:@"%@", dic[@"level"]];
            YXMarketDetailItem2 *item = [YXMarketResponseModel yy_modelWithJSON:dic].item;
            if (item) {
                NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[self.dataSource firstObject]];
                if (offset == 0) {
                    array = [NSMutableArray array];
                }
                if ([array count] < 1) {
                    NSInteger count = item.total;
                    for (int i = 0; i < count; i ++) {
                        YXMarketDetailSecu *secu = [[YXMarketDetailSecu alloc] init];
                        secu.market = self.params[@"market"];
                        secu.symbol = @"";
                        [array addObject:secu];
                    }
                }
                
                __block NSInteger from = item.from;
                NSInteger arrayCount = array.count;
                [item.list enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (from < arrayCount) {
                        YXMarketDetailSecu *secu = [YXMarketDetailSecu yxModelWithJSON:obj];
                        // 讲服务器返回的外层level赋值给数组里的每个model的level字段
                        secu.level = level.intValue;
                        array[from++] = secu;
                    }
                }];
                
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


@end
