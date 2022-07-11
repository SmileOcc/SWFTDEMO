//
//  OSSVDetailReviewNewCell.h
// XStarlinkProject
//
//  Created by odd on 2021/6/29.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailBaseCell.h"
#import "OSSVReviewsModel.h"

#import "OSSVDetailReviewNewItemCell.h"
#import "ZZStarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVDetailReviewNewCell : OSSVDetailBaseCell

@property (nonatomic, strong) UIView                        *headerView;
@property (nonatomic, strong) UILabel                       *reviewTitleLabel;
@property (nonatomic, strong) UIView                        *reviewStartView;
@property (nonatomic, strong) UILabel                       *ratingLabel;
@property (nonatomic, strong) ZZStarView             *startRatingView;  //评论数量

@property (nonatomic, strong) UICollectionView              *reviewCollectionView;

@property (nonatomic, strong) UIView                        *viewMoreView;
@property (nonatomic, strong) UIButton                      *viewMoreButton;

@property (nonatomic, strong) OSSVReviewsModel      *model;

+ (CGFloat)contentHeight:(NSInteger)count;
@end

NS_ASSUME_NONNULL_END
