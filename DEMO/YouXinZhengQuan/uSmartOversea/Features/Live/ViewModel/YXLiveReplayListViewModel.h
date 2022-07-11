//
//  YXLiveReplayListViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTableViewModel.h"
#import "YXLiveDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXLiveReplayListViewModel : YXTableViewModel

@property (nonatomic, strong) NSMutableArray <YXLiveDetailModel *> *list;

@property (nonatomic, strong) NSString *anchorId;

@end

NS_ASSUME_NONNULL_END
