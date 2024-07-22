//
//  ZFWaitCommentCell.h
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFWaitCommentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFWaitCommentCell : UITableViewCell

@property (nonatomic, strong) ZFWaitCommentModel *commentModel;

@property (nonatomic, copy) void (^touchReviewBlock) (ZFWaitCommentModel *model);

@end

NS_ASSUME_NONNULL_END
