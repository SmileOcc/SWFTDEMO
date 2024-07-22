//
//  ZFCommunityPostHotTopicListVC.h
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFCommunityShowPostTransitionDelegate.h"
#import "ZFCommunityViewModel.h"


@interface ZFCommunityPostHotTopicListVC : ZFBaseViewController

@property (nonatomic, strong) ZFCommunityShowPostTransitionDelegate *transitionDelegate;

- (void)showParentController:(UIViewController *)parentViewController topGapHeight:(CGFloat)topGapHeight;

/// 选中话题
@property (nonatomic, copy) void (^selectTopic)(ZFCommunityHotTopicModel *model);
/// 取消话题
@property (nonatomic, copy) void (^cancelTopic)(BOOL flag);

@property (nonatomic, strong) ZFCommunityHotTopicModel *hotTopicModel;



@end

