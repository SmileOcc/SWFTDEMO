//
//  ZFCommunityTopicDetailPageViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/9/17.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFCommunityHotTopicModel.h"

@interface ZFCommunityTopicDetailPageViewController : ZFBaseViewController

@property (nonatomic, copy) NSString *topicId;

/// 假置顶帖子id
@property (nonatomic, copy) NSString *review_id;

/// 话题
@property (nonatomic, strong) ZFCommunityHotTopicModel *hotTopicModel;



// 来源: 供分享使用
@property (nonatomic, copy) NSString *deeplinkSource;

@end
