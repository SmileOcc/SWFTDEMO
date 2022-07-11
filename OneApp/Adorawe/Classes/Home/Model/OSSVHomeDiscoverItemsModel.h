//
//  OSSVHomeDiscoverItemsModel.h
// OSSVHomeDiscoverItemsModel
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVHomeDiscoverItemsModel : NSObject

@property (nonatomic, strong) NSArray *bannerArray;
@property (nonatomic, strong) NSArray *listArray;
@property (nonatomic, strong) NSArray *threeArray; // 中间那个不固定的Array
@property (nonatomic, strong) NSArray *topicArray;
@property (nonatomic, assign) NSInteger page; // banner 底部list 的当前页数
@property (nonatomic, assign) NSInteger pageSize; // banner底部list的每一页条数)
@property (nonatomic, assign) NSInteger pageCount; // (banner底部list的总条数)

@end
