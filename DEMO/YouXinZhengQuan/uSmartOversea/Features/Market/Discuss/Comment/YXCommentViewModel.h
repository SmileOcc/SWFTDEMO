//
//  YXCommentViewModel.h
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/11.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXCommentViewModel : YXViewModel

@property (nonatomic, assign) BOOL isReply;

@property (nonatomic, strong) void(^successBlock)(NSString * commentId);
@property (nonatomic, strong) dispatch_block_t cancelBlock;

@property (nonatomic, strong) dispatch_block_t postDeleteBlock;
@end

NS_ASSUME_NONNULL_END
