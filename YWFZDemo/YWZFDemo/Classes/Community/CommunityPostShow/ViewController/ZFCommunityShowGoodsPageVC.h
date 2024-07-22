//
//  ZFCommunityShowGoodsPageVC.h
//  ZZZZZ
//
//  Created by YW on 16/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "WMPageController.h"
#import "ZFCommunityShowPostTransitionDelegate.h"

typedef void(^DoneBlock)(NSMutableArray *selectArray);

@interface ZFCommunityShowGoodsPageVC : WMPageController

@property (nonatomic,copy) DoneBlock doneBlock;

@property (nonatomic, assign) BOOL hasSelectGoods;
@property (nonatomic, assign) NSInteger goodsCount;



@property (nonatomic, strong) ZFCommunityShowPostTransitionDelegate *transitionDelegate;


- (void)showParentController:(UIViewController *)parentViewController topGapHeight:(CGFloat)topGapHeight;
@end
