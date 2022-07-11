//
//  OSSVHomeItemsModel.h
// OSSVHomeItemsModel
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVHomeGoodsListModel.h"
#import "OSSVAdvsEventsModel.h"

@interface OSSVHomeItemsModel : NSObject<YYModel>

@property (nonatomic, strong) NSArray<OSSVHomeGoodsListModel*> *goodList;//商品列表
@property (nonatomic, strong) NSArray *bannerList;//横条广告
@property (nonatomic, assign) NSInteger pageCount; // 总共页数
@property (nonatomic, assign) NSInteger pageSize; // 一个页面多少Size
@property (nonatomic, assign) NSInteger page; // 当前页面

@end
