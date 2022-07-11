//
//  GoodsDetailsRecommendArrayModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVGoodsListModel.h"

@interface OSSVRecommendArrayModel : NSObject

@property (nonatomic,strong) NSArray <OSSVGoodsListModel*> *goodList; //推荐商品列表
@property (nonatomic,assign) NSInteger totalCount;//总推荐商品个数
@property (nonatomic,assign) NSInteger pageSize;//当前返回总个数
@property (nonatomic,assign) NSInteger page;//当前页

@end
