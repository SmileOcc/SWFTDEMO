//
//  ZFCommunityTopicDetailItemVC.h
//  ZZZZZ
//
//  Created by YW on 2018/9/17.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "YNPageCollectionView.h"

#import "ZFCommunityTopicDetailNewViewModel.h"

typedef NS_ENUM(NSInteger,ZFCommunityTopicDetailItemType) {
    /// 0：ranking
    ZFCommunityTopicDetailItemTypeRanking,
    /// 1:最新
    ZFCommunityTopicDetailItemTypeNewest,
    /// 2: 精选
    ZFCommunityTopicDetailItemTypeFeatured
};

@interface ZFCommunityTopicDetailItemVC : ZFBaseViewController

/** 话题类型*/
@property (nonatomic, copy) NSString                                *topicType;
@property (nonatomic, copy) NSString                                *topicId;
@property (nonatomic, copy) NSString                                *reviewId;

// 1:最新，0：ranking， 2: 精选， v455调整：0放在最前面
@property (nonatomic, copy) NSString                                *sort;
@property (nonatomic, copy) NSString                                *channelName;


@property (nonatomic, strong) ZFCommunityTopicDetailNewViewModel    *viewModel;
@property (nonatomic, copy) void (^operateRefreshBlock)(BOOL isRefresh);



#pragma mark - Public method
- (UICollectionView *)querySubScrollView;
@end
