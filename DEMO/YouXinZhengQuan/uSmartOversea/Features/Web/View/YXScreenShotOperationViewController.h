//
//  YXScreenShotOperationViewController.h
//  uSmartOversea
//
//  Created by rrd on 2019/6/28.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>

typedef void(^YXHideToBottomBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface YXScreenShotOperationViewController : QMUIMoreOperationController

@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;
@property(nonatomic, strong) UIImage *screenshotImage;

@property (nonatomic, copy) YXHideToBottomBlock hideBlock;

- (void)showFromBottom;



@end

NS_ASSUME_NONNULL_END
