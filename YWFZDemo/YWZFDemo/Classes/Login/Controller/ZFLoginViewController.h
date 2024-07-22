//
//  YWLoginViewController.h
//  ZZZZZ
//
//  Created by YW on 25/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "UIViewController+ZFViewControllerCategorySet.h"

typedef void (^SuccessSignBlock)(void);
typedef void (^CancelSignBlock)(void);

@interface YWLoginViewController : ZFBaseViewController

@property (nonatomic, copy) SuccessSignBlock successBlock;
@property (nonatomic, copy) CancelSignBlock cancelSignBlock;
@property (nonatomic, assign) YWLoginEnterType type;
@property (nonatomic, assign) YWLoginViewControllerEnterType comefromType;//1：来自新版本启动引导页
@property (nonatomic, copy) NSString *deepLinkSource;

@end
