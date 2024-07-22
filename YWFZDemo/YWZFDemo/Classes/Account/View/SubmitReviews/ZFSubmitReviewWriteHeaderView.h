//
//  ZFSubmitReviewWriteHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFOrderReviewModel.h"

typedef void(^ZFSubmitReviewWriteRatingCompletionHandler)(CGFloat rate);


@interface ZFSubmitReviewWriteHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) ZFOrderReviewModel            *model;

@property (nonatomic, copy) ZFSubmitReviewWriteRatingCompletionHandler      submitReviewWriteRatingCompletionHandler;

@end
