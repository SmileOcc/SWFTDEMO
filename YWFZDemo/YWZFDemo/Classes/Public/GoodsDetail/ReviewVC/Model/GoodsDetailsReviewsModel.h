//
//  GoodsDetailsReviewsModel.h
//  Yoshop
//
//  Created by YW on 16/6/10.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReviewsSizeOverModel : NSObject
@property (nonatomic,assign) float small;
@property (nonatomic,assign) float big;
@property (nonatomic,assign) float middle;

// 以下两个字段从父Model中获取
@property (nonatomic,assign) float agvRate;//评论总分
@property (nonatomic,assign) NSInteger reviewCount;//评论条数
@end


@interface GoodsDetailsReviewsModel : NSObject
@property (nonatomic,strong) NSArray *reviewList;//评论列表
@property (nonatomic,assign) float agvRate;//评论总分
@property (nonatomic,assign) NSInteger reviewCount;//评论条数
@property (nonatomic,assign) NSInteger pageCount;//总页数
@property (nonatomic,assign) NSInteger page;//页数
@property (nonatomic,strong) ReviewsSizeOverModel *size_over_all;//评论排名
@end

