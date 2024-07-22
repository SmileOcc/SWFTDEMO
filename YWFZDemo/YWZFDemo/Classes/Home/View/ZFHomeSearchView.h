//
//  ZFHomeSearchView.h
//  ZZZZZ
//
//  Created by YW on 2018/6/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZFCategoryActionSearchInputCompletionHandler)(void);
typedef void(^ZFCategoryActionSearchImageCompletionHandler)(void);

@interface ZFHomeSearchView : UIView

@property (nonatomic, copy) NSString            *inputPlaceHolder;

@property (nonatomic, copy) ZFCategoryActionSearchInputCompletionHandler    categoryActionSearchInputCompletionHandler;
@property (nonatomic, copy) ZFCategoryActionSearchImageCompletionHandler    categoryActionSearchImageCompletionHandler;

- (void)subViewWithAlpa:(CGFloat)alpha;

@end
