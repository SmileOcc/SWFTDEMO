//
//  ZFCommnuityTopicDetailCollectionView.h
//  ZZZZZ
//
//  Created by YW on 2018/9/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityTopicDetailListModel.h"

typedef NS_ENUM(NSInteger, CommunityTopicDetailCellEvent) {
    CommunityTopicDetailCellEventUserImage,
    CommunityTopicDetailCellEventFllow,
    CommunityTopicDetailCellEventLike,
    CommunityTopicDetailCellEventReview,
    CommunityTopicDetailCellEventShare
};

@interface ZFCommnuityTopicDetailBigCCell : UICollectionViewCell

@property (nonatomic, strong) ZFCommunityTopicDetailListModel *model;

@property (nonatomic, copy) void (^tapEventBlock)(CommunityTopicDetailCellEvent event, ZFCommunityTopicDetailListModel *model, UIButton *sender);
@property (nonatomic, copy) void (^tapLabBlock)(NSString *labName);

@end
