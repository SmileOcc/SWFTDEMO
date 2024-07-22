//
//  ZFCommunityGestureCollectionView.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityGestureCollectionView.h"

@implementation ZFCommunityGestureCollectionView

/**
 * 此方法是支持多手势，当滑动子控制器中的scrollView时，外层 scrollView 也能接收滑动事件
 * 当前类仅供社区个人中心三个列表使用
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}


@end
