//
//  ZFSubmitReviewViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFOrderReviewListModel.h"

@interface ZFSubmitReviewViewModel : BaseViewModel

@property (nonatomic, strong) ZFOrderReviewListModel            *model;

/*
 * 查看评论列表
 */
- (void)requestOrderReviewListNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

/*
 * 提交评论数据
 */
- (void)requestWriteReview:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;

@end

