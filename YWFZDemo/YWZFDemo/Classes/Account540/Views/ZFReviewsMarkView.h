//
//  ZFReviewsMarkView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFOrderReviewModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFReviewsMarkView : UIView

- (void)refreshReviewsMark:(ZFOrderReviewModel *)reviewModel handlerHeight:(void(^)(CGFloat))handlerHeight;

@property (nonatomic, copy) void(^selectedMarkHandler)(NSString *mark, BOOL selecte);

@end

NS_ASSUME_NONNULL_END
