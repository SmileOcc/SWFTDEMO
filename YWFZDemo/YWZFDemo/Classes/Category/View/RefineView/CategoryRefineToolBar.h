//
//  CategoryRefineToolBar.h
//  ListPageViewController
//
//  Created by YW on 1/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClearButtonActionCompletionHandle)(void);
typedef void(^ApplyButtonActionCompletionHandle)(void);

@interface CategoryRefineToolBar : UIView

@property (nonatomic, copy) ClearButtonActionCompletionHandle       clearButtonActionCompletionHandle;
@property (nonatomic, copy) ApplyButtonActionCompletionHandle       applyButtonActionCompletionHandle;

@end
