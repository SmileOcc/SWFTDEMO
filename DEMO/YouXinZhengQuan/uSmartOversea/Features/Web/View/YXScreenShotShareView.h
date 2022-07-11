//
//  YXScreenShotShareView.h
//  uSmartOversea
//
//  Created by mac on 2019/5/20.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef  void (^ShareResultBlock)(BOOL result);

@interface YXScreenShotShareView : UIView

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, copy) ShareResultBlock shareResultBlock;

@end

NS_ASSUME_NONNULL_END
