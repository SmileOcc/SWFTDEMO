//
//  PostGoodsManger.h
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFCommunityPostShowSelectGoodsModel.h"

@interface PostGoodsManager : NSObject

@property (nonatomic, strong) NSMutableArray             *hotArray;
@property (nonatomic, strong) NSMutableArray             *wishArray;
@property (nonatomic, strong) NSMutableArray             *bagArray;
@property (nonatomic, strong) NSMutableArray             *orderArray;
@property (nonatomic, strong) NSMutableArray             *recentArray;
@property (nonatomic, assign) BOOL                       isFirstTimeEnter;


+ (PostGoodsManager *)sharedManager;

- (void)removeGoodsWithModel:(ZFCommunityPostShowSelectGoodsModel *)model;

- (void)clearData;


@end
