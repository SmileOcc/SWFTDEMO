//
//  ZFCommunityTopicDetailListCell.h
//  ZZZZZ
//
//  Created by YW on 2018/9/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityTopicDetailListModel.h"

@interface ZFCommunityTopicDetailListCell : UICollectionViewCell

@property (nonatomic, strong) ZFCommunityTopicDetailListModel *model;
@property (nonatomic, copy) void (^communtiyMyStyleBlock)(void);//My Style Block
@property (nonatomic, copy) void (^clickEventBlock)(UIButton *btn,ZFCommunityTopicDetailListModel *model);//Click Event Block
@property (nonatomic, copy) void (^topicDetailBlock)(NSString *labName);
/** 社区Follow首页需要全部固定隐藏Follow按钮 */
@property (nonatomic, assign) BOOL isHiddenFollowBtn;


@end
