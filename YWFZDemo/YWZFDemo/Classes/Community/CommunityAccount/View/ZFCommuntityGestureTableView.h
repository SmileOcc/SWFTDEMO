//
//  ZFCommuntityGestureTableView.h
//  ZZZZZ
//
//  Created by YW on 2018/4/24.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 此方法是支持多手势，当滑动子控制器中的scrollView时，外层 scrollView 也能接收滑动事件
 * 当前类仅供社区个人中心三个列表使用
 */
@interface ZFCommuntityGestureTableView : UITableView

@end

/**
 * 此方法是支持多手势，当滑动子控制器中的scrollView时，外层 scrollView 也能接收滑动事件
 * 当前类仅供社区个人中心三个列表使用
 */
@interface ZFCommuntityCollectionView : UICollectionView

@end



@interface ZFCountryTableView : UITableView

/**
 * 刷新浮动SelectedFloatView
 */
- (void)refreshFloatIndexView:(NSString *)indexText index:(NSInteger)index;

@property (nonatomic, copy) NSString *currentTitle;

@end

