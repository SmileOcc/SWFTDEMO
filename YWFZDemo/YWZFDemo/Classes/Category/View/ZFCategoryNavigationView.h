//
//  ZFCategoryNavigationView.h
//  ZZZZZ
//
//  Created by YW on 2018/6/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZFCategoryBackCompletionHandler)(void);
typedef void(^ZFCategoryJumpCartCompletionHandler)(void);
typedef void(^ZFCategoryActionSearchInputCompletionHandler)(void);
typedef void(^ZFCategoryActionSearchImageCompletionHandler)(void);

@interface ZFCategoryNavigationView : UIView

@property (nonatomic, copy) NSString            *badgeCount;
@property (nonatomic, copy) NSString            *inputPlaceHolder;
 @property (nonatomic, assign) BOOL             showBackButton;

@property (nonatomic, copy) ZFCategoryBackCompletionHandler                 categoryBackCompletionHandler;
@property (nonatomic, copy) ZFCategoryJumpCartCompletionHandler             categoryJumpCartCompletionHandler;
@property (nonatomic, copy) ZFCategoryActionSearchInputCompletionHandler    categoryActionSearchInputCompletionHandler;
@property (nonatomic, copy) ZFCategoryActionSearchImageCompletionHandler    categoryActionSearchImageCompletionHandler;


- (void)subViewWithAlpa:(CGFloat)alpha;
@end
