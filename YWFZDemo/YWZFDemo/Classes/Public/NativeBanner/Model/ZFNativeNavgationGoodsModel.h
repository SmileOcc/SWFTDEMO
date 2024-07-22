//
//  ZFNativeGoodsModel.h
//  ZZZZZ
//
//  Created by YW on 25/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZFGoodsModel;

@interface ZFNativeNavgationGoodsModel : NSObject

@property (nonatomic, assign) NSInteger   curPage;

@property (nonatomic, assign) NSInteger   totalPage;

@property (nonatomic, assign) NSInteger   resultNum;

@property (nonatomic, strong) NSArray<ZFGoodsModel *>             *goodsList;

@end
