//
//  UIViewController+Current.h
//  uSmartOversea
//
//  Created by mac on 2019/4/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Current)

+ (UIViewController*)currentViewController;

- (void)toLastViewController;
@end

NS_ASSUME_NONNULL_END
