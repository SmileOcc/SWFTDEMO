//
//  YXOrgAccountViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/6/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXOrgAccountListViewModel : YXTableViewModel


@property (nonatomic, strong) RACCommand *statusChangeCommand;

@end

NS_ASSUME_NONNULL_END
