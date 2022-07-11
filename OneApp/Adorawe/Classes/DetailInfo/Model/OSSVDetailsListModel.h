//
//  OSSVDetailsListModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVSizeChartModel.h"
#import "OSSVReviewsModel.h"
//#import "GoodsDetailHeaderReviewModel.h"

@class OSSVDetailHeaderReviewModel;
@class OSSVDetailsBaseInfoModel;
@class OSSVRecommendArrayModel;
@interface OSSVDetailsListModel : NSObject

@property (nonatomic, strong) OSSVDetailsBaseInfoModel        *goodsBaseInfo;
/** 推荐*/
@property (nonatomic, strong) OSSVRecommendArrayModel  *recommend;
/** 评论*/
//@property (nonatomic, strong) OSSVDetailHeaderReviewModel     *review;

/** 广告*/
@property (nonatomic, strong) NSArray<OSSVAdvsEventsModel*>       *banner;

@property (nonatomic, strong) OSSVReviewsModel *reviewsModel;

@property (nonatomic, assign) CGFloat goodsImageWidth;

@property (nonatomic, assign) NSString *request_id;

- (void)configureTopBannerWeight;
@end


