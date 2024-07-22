//
//  ZFCommunityTopicDetailModel.h
//  ZZZZZ
//
//  Created by DBP on 16/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,TopicDetailSortType) {
    /**0：ranking*/
    TopicDetailSortTypeRanking = 0,
    /**1:最新*/
    TopicDetailSortTypeLatest = 1,
    /**2: 精选*/
    TopicDetailSortTypeFeatured = 2
};


@interface ZFCommunityTopicDetailModel : NSObject
@property (nonatomic, strong) NSArray *list;//列表
@property (nonatomic, assign) NSInteger pageCount;//总页数
@property (nonatomic, assign) NSInteger curPage;//当前页数
@property (nonatomic, copy) NSString *type;//类型

//活动排序类型转换
+ (NSString *)sortToStringType:(NSInteger)sortType;
+ (NSInteger)sortToIntType:(NSString *)sortType;

@end
