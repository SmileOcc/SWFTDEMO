//
//  ZFMyCommentSubVC.h
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFMyCommentSubVC : ZFBaseViewController

@property (nonatomic, copy) void(^myCommentCountBlock)(NSString *title);

@end

NS_ASSUME_NONNULL_END
