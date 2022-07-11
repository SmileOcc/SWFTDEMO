//
//  YXLiveAskViewModel.h
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/8/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXLiveAskViewModel : YXViewModel

@property (nonatomic, strong) void(^successBlock)(NSString * commentId);
@property (nonatomic, strong) dispatch_block_t cancelBlock;

@end

NS_ASSUME_NONNULL_END
