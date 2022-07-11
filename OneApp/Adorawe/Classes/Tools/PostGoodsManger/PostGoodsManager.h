//
//  PostGoodsManger.h
//  Zaful
//
//  Created by 10010 on 20/7/29.
//  Copyright © 2020年 StarLink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SelectGoodsModel;
@interface PostGoodsManager : NSObject
@property (nonatomic,strong) NSMutableArray *wishArray;    // 已选商品
@property (nonatomic,strong) NSMutableArray *bagArray;     // 已选商品
@property (nonatomic,strong) NSMutableArray *orderArray;   // 已选商品
@property (nonatomic,strong) NSMutableArray *recentArray;  // 已选商品
@property (nonatomic,assign) BOOL isFirstTimeEnter;

// 新数据
@property (nonatomic,strong) NSArray *wishArr;
@property (nonatomic,strong) NSArray *bagArr;
@property (nonatomic,strong) NSArray *orderArr;


+ (PostGoodsManager *)sharedManager;

- (void)removeGoodsWithModel:(SelectGoodsModel *)model;

- (void)clearData;


@end
