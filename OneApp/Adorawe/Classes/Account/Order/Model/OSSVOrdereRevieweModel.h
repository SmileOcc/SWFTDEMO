//
//  OSSVOrdereRevieweModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVAccounteOrdersDetaileGoodsModel.h"

@class STLOrderReviewScore;

@interface OSSVOrdereRevieweModel : NSObject

@property (nonatomic, strong) NSArray           *goods;
@property (nonatomic, assign) NSInteger         isReview;
@property (nonatomic, strong) STLOrderReviewScore  *reviewScore;

@end



@interface STLOrderReviewScore : NSObject

@property (nonatomic, copy) NSString       *transportRate;
@property (nonatomic, copy) NSString       *goodsRate;
@property (nonatomic, copy) NSString       *payRate;
@property (nonatomic, copy) NSString       *serviceRate;


@end
