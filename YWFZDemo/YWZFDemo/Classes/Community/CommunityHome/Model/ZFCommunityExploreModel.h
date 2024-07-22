//
//  ZFCommunityExploreModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFBannerModel.h"

@class ZFCommunityFavesItemModel;

@interface ZFCommunityBranchBannerModel : NSObject
//@property (nonatomic, assign) NSInteger branch;
@property (nonatomic, strong) NSArray<ZFBannerModel *> *banners;
@end

@interface ZFCommunityExploreModel : NSObject

@property (nonatomic, strong) NSArray<ZFCommunityFavesItemModel *> *list;//评论列表
@property (nonatomic, strong) NSArray *bannerlist;//banner数组
@property (nonatomic, strong) NSArray *video;//视频
@property (nonatomic, strong) NSArray *topicList;//话题
@property (nonatomic, assign) NSInteger pageCount;//总页数
@property (nonatomic, assign) NSInteger curPage;//当前页数
@property (nonatomic, copy) NSString *type;//类型
@property (nonatomic, strong) NSArray<ZFCommunityBranchBannerModel *> *branchBannerList;//多分馆列表
@end
