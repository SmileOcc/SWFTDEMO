//
//  ZFCommunityTopicDetailCommentSection.m
//  ZZZZZ
//
//  Created by YW on 2019/11/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityTopicDetailCommentSection.h"
#import "ZFFrameDefiner.h"

@implementation ZFCommunityTopicDetailCommentSection

- (instancetype)init {
    if (self = [super init]) {
        self.type = ZFTopicSectionTypeReview;
        self.headerSize = CGSizeMake(KScreenWidth, 52.0);
        self.footerSize = CGSizeMake(KScreenWidth, 12.0);
    }
    return self;
}

- (void)setLists:(NSArray<ZFCommunityPostDetailReviewsListMode *> *)lists {
    
    if (lists.count > 2) {
        self.footerSize = CGSizeMake(KScreenWidth, 40 + 12);
    } else {
        self.footerSize = CGSizeMake(KScreenWidth, 12.0);
    }
    
    self.rowCount = lists.count;
    if (lists.count > 2) {
        self.rowCount = 2;
        lists = [[NSArray alloc] initWithObjects:lists[0],lists[1], nil];
    }
    _lists = lists;
    
    NSMutableArray *sizeArray = [NSMutableArray array];
    for (ZFCommunityPostDetailReviewsListMode *model in lists) {
        
        CGFloat celLHeight = [ZFCommunityPostDetailCommentCCell fetchReviewCellHeight:model];// 计算高度
        [sizeArray addObject:NSStringFromCGSize(CGSizeMake(KScreenWidth, celLHeight))];
    }
    self.reviewCellSizeArray = sizeArray;
}

- (void)setAllCount:(NSInteger)allCount {
    _allCount = allCount;
    if (allCount > 2 && self.rowCount == 2) {
        self.footerSize = CGSizeMake(KScreenWidth, 40 + 12);
    } else {
        self.footerSize = CGSizeMake(KScreenWidth, 12.0);
    }
}


- (CGSize)commentItemSizeWithIndex:(NSInteger)index {
    if (self.reviewCellSizeArray.count > index) {
        CGSize size = CGSizeFromString(self.reviewCellSizeArray[index]);
        return size;
    }
    return CGSizeZero;
}

@end
