//
//  OSSVReviewssGoodssCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountOrdersDetailGoodsModel.h"

@class OSSVReviewssGoodssCell;

@protocol STLReviewsGoodsCellDelegate <NSObject>

- (void)STL_ReviewsGoodsCell:(OSSVReviewssGoodssCell *)reviewsCell flag:(BOOL)flag;
@end

@interface OSSVReviewssGoodssCell : UITableViewCell

@property (nonatomic, weak) id<STLReviewsGoodsCellDelegate>   myDelegate;
@property (nonatomic, strong) AccountOrdersDetailGoodsModel   *model;

@property (nonatomic, strong) UIImageView           *goodsImgView;
@property (nonatomic, strong) UILabel               *titleLab;
@property (nonatomic, strong) UILabel               *skuLab;
@property (nonatomic, strong) UIButton              *reviewButton;
@property (nonatomic, strong) UIView                *lineView;

- (void)testModel;

@end
