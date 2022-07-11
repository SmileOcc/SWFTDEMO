//
//  YXAlertViewController.h
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/4.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>



NS_ASSUME_NONNULL_BEGIN

@interface YXAlertViewController : QMUIAlertController

@property (nonatomic, strong) UIColor *containerViewColor;

//actionSheet style 默认配置
- (void)defaultSheetConfig;
@end

NS_ASSUME_NONNULL_END
