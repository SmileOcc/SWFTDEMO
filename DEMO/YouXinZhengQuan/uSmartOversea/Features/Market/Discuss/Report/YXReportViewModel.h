//
//  YXReportViewModel.h
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"
#import "YXSecu.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXReportViewModel : YXViewModel

@property (nonatomic, strong) YXSecu *secu;
@property (nonatomic, strong) NSArray *stockIdList;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) dispatch_block_t successBlock;
@property (nonatomic, strong) dispatch_block_t cancelBlock;


@end

NS_ASSUME_NONNULL_END
