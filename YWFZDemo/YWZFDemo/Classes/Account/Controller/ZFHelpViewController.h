//
//  HelpViewController.h
//  ZZZZZ
//
//  Created by YW on 18/9/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFBaseViewController.h"

@interface ZFHelpViewController : ZFBaseViewController

/// 设置后，只停止当前类侧滑功能，若未找到返回上层
- (void)goBackUpperClassRelativeClass:(NSString *)className;

@end
