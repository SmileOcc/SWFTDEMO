//
//  ZFMyCommentCell.h
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFWaitCommentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFMyCommentCell : UITableViewCell

@property (nonatomic, copy) void (^TapGoodsBlock)(NSString *goodsId);

@property (nonatomic, strong) ZFMyCommentModel *commentModel;

@end

NS_ASSUME_NONNULL_END
