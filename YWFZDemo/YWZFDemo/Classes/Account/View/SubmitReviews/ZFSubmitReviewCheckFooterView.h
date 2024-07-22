//
//  ZFSubmitReviewCheckFooterView.h
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFOrderReviewModel.h"

typedef void(^ZFSubmitReviewCheckImageCompletionHandler)(NSInteger index);

@interface ZFSubmitReviewCheckFooterView : UITableViewHeaderFooterView
@property (nonatomic, strong) ZFOrderReviewModel            *model;
@property (nonatomic, copy) ZFSubmitReviewCheckImageCompletionHandler       submitReviewCheckImageCompletionHandler;
@end
