//
//  YXMoreOperationViewController.h
//  uSmartOversea
//
//  Created by youxin on 2019/6/18.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXMoreOperationViewController : QMUIMoreOperationController

@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;
- (void)showFromBottom;
- (void)showFromBottomWithBackgroundClear:(BOOL)backgroundClear;

- (void)hideToBottomCallBack:(void (^)(void))callBack;
@end

NS_ASSUME_NONNULL_END
