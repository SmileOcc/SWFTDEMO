//
//  YXStockFilterMarketGroupViewModel.h
//  uSmartOversea
//
//  Created by youxin on 2020/9/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXStockFilterMarketGroupViewModel : YXTableViewModel

@property (nonatomic, strong) NSString *market;

@property (nonatomic, strong) RACCommand *saveResultCommand;
@end

NS_ASSUME_NONNULL_END
