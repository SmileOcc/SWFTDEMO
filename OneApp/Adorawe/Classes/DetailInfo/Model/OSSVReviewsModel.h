//
//  OSSVReviewsModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVReviewsListModel.h"

@interface OSSVReviewsModel : NSObject

@property (nonatomic,strong) NSArray   *reviewList;
///评论总分
@property (nonatomic,assign) float     agvRate;
@property (nonatomic,assign) NSInteger reviewCount;
//@property (nonatomic,assign) NSInteger pageCount;
@property (nonatomic,assign) NSInteger page;

@end

