//
//  ZFAppUpgradeView.h
//  ZZZZZ
//
//  Created by YW on 2018/12/22.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFUpgradeModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFAppUpgradeView : UIView

+ (void)showUpgradeView:(ZFUpgradeModel *)imageData
        upgradeAppBlock:(void(^)(void))upgradeAppBlock
      upgradeCloseBlock:(void(^)(void))upgradeCloseBlock;

@end

NS_ASSUME_NONNULL_END
