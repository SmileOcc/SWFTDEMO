//
//  OSSVGoodssReviewssModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVAccounteOrdersDetaileGoodsModel.h"

@interface OSSVGoodssReviewssModel : NSObject

@property (nonatomic, strong) NSArray <OSSVAccounteOrdersDetaileGoodsModel*>  *goodsList;
@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger currentPage;

@end
