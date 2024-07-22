//
//  ZFCommunityHomePostCategoryView.h
//  ZZZZZ
//
//  Created by YW on 2018/11/24.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHomeChannelBaseView.h"
#import "ZFCommunityChannelModel.h"
#import "ZFCommunityCategoryPostItemModel.h"

//社区帖子分类
@interface ZFCommunityHomePostCategoryView : ZFCommunityHomeChannelBaseView

/*
 * start: YES 开始请求， NO 未开始请求
 *
 */
- (instancetype)initWithFrame:(CGRect)frame itemModel:(ZFCommunityChannelItemModel *)itemModel startRequest:(BOOL)start;

@property (nonatomic, strong) ZFCommunityChannelItemModel    *itemModel;

///开始请求
- (void)startFirstRequest;
///刷新内容
- (void)updateItemModel:(ZFCommunityChannelItemModel *)itemModel;

/**
 UICollectionView scrollsToTop state
 
 @return defaulte is NO
 */
- (BOOL)collectionViewScrollsTopState;
@end

