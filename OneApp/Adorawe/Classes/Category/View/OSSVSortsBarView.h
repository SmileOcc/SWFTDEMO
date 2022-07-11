//
//  OSSVSortsBarView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVSortItemsView.h"

typedef void (^SortItemViewBlock)(NSInteger index,BOOL flag);

@interface OSSVSortsBarView : UIView

@property (nonatomic, strong) OSSVSortItemsView    *sortItem;
@property (nonatomic, strong) UIButton           *filterItem;
@property (nonatomic, strong) UIView             *verLineView;
@property (nonatomic, strong) UIView             *bottomLineView;
@property (nonatomic, copy) SortItemViewBlock   sortItemBlock;
@property (nonatomic, copy) void(^filterItemBlock)();

//取消选择状态
- (void)cancelSelectState;

@end


