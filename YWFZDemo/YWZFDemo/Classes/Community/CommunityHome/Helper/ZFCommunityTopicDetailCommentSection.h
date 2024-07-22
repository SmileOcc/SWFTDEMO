//
//  ZFCommunityTopicDetailCommentSection.h
//  ZZZZZ
//
//  Created by YW on 2019/11/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityTopicDetailBaseSection.h"
#import "ZFCommunityPostDetailReviewsListMode.h"
#import "ZFCommunityPostDetailCommentCCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityTopicDetailCommentSection : ZFCommunityTopicDetailBaseSection

@property (nonatomic, strong) NSArray<ZFCommunityPostDetailReviewsListMode *> *lists;

/** 评论数据高度 */
@property (nonatomic, strong) NSArray *reviewCellSizeArray;

@property (nonatomic, assign) NSInteger           allCount;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *userImageUrl;




- (CGSize)commentItemSizeWithIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
