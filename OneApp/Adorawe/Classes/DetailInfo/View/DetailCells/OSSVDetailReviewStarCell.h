//
//  OSSVDetailReviewStarCell.h
// XStarlinkProject
//
//  Created by odd on 2021/4/13.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailBaseCell.h"
#import "ZZStarView.h"

#import "OSSVReviewsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVDetailReviewStarCell : OSSVDetailBaseCell

@property (nonatomic, strong) ZZStarView             *starRating; // 评价分数
@property (nonatomic, strong) UILabel                       *starNumber; // 平均分

@property (nonatomic, strong) UILabel                       *leftTitle; // 左边显示内容
@property (nonatomic, strong) YYAnimatedImageView           *rightArrow; // 右边箭头
@property (nonatomic, strong) UIView                        *horizontalLine; // 横线
@property (nonatomic, assign) NSInteger                     count;

@property (nonatomic, strong) OSSVReviewsModel  *model;

@end

NS_ASSUME_NONNULL_END
