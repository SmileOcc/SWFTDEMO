//
//  YXStockListViewModel.h
//  YouXinZhengQuan
//
//  Created by ellison on 2018/11/13.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXTableViewModel.h"
#import "YXSecuMobileBrief1Protocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXStockListViewModel : YXTableViewModel

@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, assign) CGPoint contentOffset;

@property (nonatomic, strong) RACCommand *didClickRotateCommand;
@property (nonatomic, strong) RACCommand *didClickSortCommand;

@property (nonatomic, assign) YXSortState sortState;
@property (nonatomic, assign) YXMobileBrief1Type mobileBrief1Type;

@end

NS_ASSUME_NONNULL_END
