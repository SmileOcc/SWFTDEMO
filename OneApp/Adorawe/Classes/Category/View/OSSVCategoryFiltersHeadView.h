//
//  OSSVCategoryFiltersHeadView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVCategoryFiltersHeadView : UIView

@property (nonatomic, assign) BOOL isShow;          // 是否是展开状态
@property (nonatomic, copy) void (^unfoldAction)(); // 展开操作

- (void)setTitle:(NSString *)title;
- (void)setContent:(NSString *)content;

@end
