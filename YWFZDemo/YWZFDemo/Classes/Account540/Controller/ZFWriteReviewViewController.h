//
//  ZFWriteReviewViewController.h
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFWaitCommentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFWriteReviewViewController : ZFBaseViewController

@property (nonatomic, strong) ZFWaitCommentModel *commentModel;

@property (nonatomic, copy) void (^commentSuccessBlock)(ZFWaitCommentModel *commentModel);

@property (nonatomic, copy) NSString *goodsId;


@end

NS_ASSUME_NONNULL_END
