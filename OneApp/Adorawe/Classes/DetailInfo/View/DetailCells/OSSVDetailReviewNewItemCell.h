//
//  OSSVDetailReviewNewItemCell.h
// XStarlinkProject
//
//  Created by odd on 2021/6/29.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVReviewsListModel.h"

#import "ZZStarView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVDetailReviewNewItemCell : UICollectionViewCell

@property (nonatomic, strong) UILabel               *nickLabel;
@property (nonatomic, strong) ZZStarView     *startRatingView;
@property (nonatomic, strong) UILabel               *contentLabel;
@property (nonatomic, strong) UILabel               *timeLabel;
@property (nonatomic, strong) YYAnimatedImageView   *imageView;
@property (nonatomic, strong) UILabel               *countLabel;

@property (nonatomic, strong) OSSVReviewsListModel *model;

@property (nonatomic, strong) NSMutableArray        *imagsArray;

@end

NS_ASSUME_NONNULL_END
