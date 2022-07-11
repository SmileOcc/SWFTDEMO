//
//  YXTableViewModel.m
//  YouXinZhengQuan
//
//  Created by RuiQuan Dai on 2018/7/3.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXTableViewModel.h"
#import "uSmartOversea-Swift.h"


@interface YXTableViewModel ()


@property (nonatomic, strong, readwrite) RACCommand *requestRemoteDataCommand;

@property (nonatomic, strong, readwrite) RACCommand *requestOffsetDataCommand;

@end

@implementation YXTableViewModel


- (void)initialize {
    
    [super initialize];
    
    self.page = 1;
    self.perPage = 30;
    
    @weakify(self)
    self.requestRemoteDataCommand = [[RACCommand alloc] initWithSignalBlock:^(NSNumber *page) {
        @strongify(self)
        self.page = page.unsignedIntegerValue;
        return [[self requestRemoteDataSignalWithPage:page.unsignedIntegerValue] takeUntil:self.rac_willDeallocSignal];
    }];
    
    self.requestOffsetDataCommand = [[RACCommand alloc] initWithSignalBlock:^(NSNumber *offset) {
        @strongify(self)
        return [self requestWithOffset:[offset intValue]];
    }];
    
    //请求错误订阅给 self.errors
    [[self.requestRemoteDataCommand.errors
      filter:[self requestRemoteDataErrorsFilter]]
     subscribe:self.errors];
    
    [[self.requestOffsetDataCommand.errors
      filter:[self requestRemoteDataErrorsFilter]]
     subscribe:self.errors];
    
    [self.errors subscribeNext:^(id  _Nullable x) {
        if (x != nil) {
            [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"network_timeout"]];
        }
    }];
}

- (BOOL (^)(NSError *error))requestRemoteDataErrorsFilter {
    return ^(NSError *error) {
        return YES;
    };
}

- (id)fetchLocalData {
    return nil;
}

- (NSUInteger)offsetForPage:(NSUInteger)page {
    return (page - 1) * self.perPage;
}

- (RACSignal *)requestRemoteDataSignalWithPage:(NSUInteger)page {
    NSUInteger offset = [self offsetForPage:page];
    return [self requestWithOffset:offset];
}

- (RACSignal *)requestWithOffset:(NSInteger)offset{
    return [RACSignal empty];
}

- (void)updateDataSourceWithArray:(NSArray<NSArray *> *)arr {
    _dataSource = arr;
}

@end
