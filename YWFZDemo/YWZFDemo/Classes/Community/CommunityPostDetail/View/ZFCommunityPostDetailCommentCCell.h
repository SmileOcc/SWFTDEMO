//
//  ZFCommunityPostDetailCommentCCell.h
//  ZZZZZ
//
//  Created by YW on 2019/11/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityPostDetailReviewsListMode.h"

@interface ZFCommunityPostDetailCommentCCell : UICollectionViewCell

+ (ZFCommunityPostDetailCommentCCell *)commentCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

- (void)configWithViewModel:(ZFCommunityPostDetailReviewsListMode *)viewModel;

+ (CGFloat)fetchReviewCellHeight:(ZFCommunityPostDetailReviewsListMode *)reviewModel;

@end

