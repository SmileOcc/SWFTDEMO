//
//  ZFNoNetEmptyView.h
//  ZZZZZ
//
//  Created by YW on 2017/9/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^NoNetEmptyReRequestCompletionHandler)(void);

@interface ZFNoNetEmptyView : UIView
@property (nonatomic, copy) NoNetEmptyReRequestCompletionHandler          noNetEmptyReRequestCompletionHandler;
@end
