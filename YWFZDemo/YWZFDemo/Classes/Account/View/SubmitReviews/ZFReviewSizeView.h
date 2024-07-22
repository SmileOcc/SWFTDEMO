//
//  ZFReviewSizeView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  评论显示Size的视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFReviewSizeView : UIView

///contentList, 顺序 <Height, Waist, Hips, Bust Size>
@property (nonatomic, strong) NSArray *contentList;

@end

NS_ASSUME_NONNULL_END
