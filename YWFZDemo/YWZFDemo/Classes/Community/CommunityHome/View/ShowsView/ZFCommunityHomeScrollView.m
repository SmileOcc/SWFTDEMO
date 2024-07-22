//
//  ZFCommunityHomeScrollView.m
//  ZZZZZ
//
//  Created by YW on 2018/11/20.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeScrollView.h"
#import "SDCycleScrollView.h"

@interface ZFCommunityHomeScrollView()


@end

@implementation ZFCommunityHomeScrollView

/**
 * 此方法是支持多手势，当滑动子控制器中的scrollView时，外层 scrollView 也能接收滑动事件
 * 当前类仅供社区个人中心三个列表使用
 */
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return NO;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //YWLog(@"inView: %@",otherGestureRecognizer.view);
    if ([otherGestureRecognizer.view isKindOfClass:[ZFCommunityHomeScrollView class]] ||
        [otherGestureRecognizer.view isKindOfClass:[SDCycleScrollView class]] ||
        [otherGestureRecognizer.view isKindOfClass:[UICollectionView class]] ||
        [otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
        return NO;
    }
    
    return YES;
}
@end
