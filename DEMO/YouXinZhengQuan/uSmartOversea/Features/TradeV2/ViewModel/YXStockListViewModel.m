//
//  YXStockListViewModel.m
//  YouXinZhengQuan
//
//  Created by ellison on 2018/11/13.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXStockListViewModel.h"
#import "YXSecuProtocol.h"
#import "YXSecuMobileBrief1Protocol.h"
#import "uSmartOversea-Swift.h"

@implementation YXStockListViewModel

- (void)initialize {
    [super initialize];
    
    @weakify(self)
    self.didSelectCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSIndexPath * _Nullable indexPath) {
        @strongify(self)
        id<YXSecuProtocol> secu = self.dataSource[indexPath.section][indexPath.row];
        if (secu.symbol && secu.symbol.length < 1) {
            return [RACSignal empty];
        }
        YXStockInputModel *input = [[YXStockInputModel alloc] init];
        input.market = secu.market;
        input.symbol = secu.symbol;
        input.name = secu.name;
        
        if (self.isLandscape) {
            [self.services pushPath:YXModulePathsLandStockDetail context:@{@"dataSource": @[input], @"selectIndex": @(0)} animated:YES];
        } else {
            [self.services pushPath:YXModulePathsStockDetail context:@{@"dataSource": @[input], @"selectIndex": @(0)} animated:YES];
         
        }
        return [RACSignal empty];
    }];
    
    self.didClickRotateCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSIndexPath * _Nullable indexPath) {
        @strongify(self)
        //TODO: FIX ME
//        YXStockListViewModel *viewModel = [[[self class] alloc] initWithServices:self.services params:self.params];
//        viewModel.sortState = self.sortState;
//        viewModel.mobileBrief1Type = self.mobileBrief1Type;
//        viewModel.isLandscape = YES;
//        viewModel.dataSource = self.dataSource;
//        [self.services pushViewModel:viewModel animated:NO];
        return [RACSignal empty];
    }];
    
    self.didClickSortCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSArray *  _Nullable input) {
        return [RACSignal empty];
    }];
}


@end
