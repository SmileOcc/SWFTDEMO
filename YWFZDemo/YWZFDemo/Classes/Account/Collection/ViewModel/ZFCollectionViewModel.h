//
//  ZFCollectionViewModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFCollectionListModel.h"
#import "ZFCommunityFavesItemModel.h"
#import "ZFCollectionPostListModel.h"

@interface ZFCollectionViewModel : BaseViewModel

@property (nonatomic, strong) ZFCollectionListModel *listModel;

/**
 * 请求收藏夹列表数据
 * listModel : 总数据模型  currentPageArray : 当前页请求的实际商品数据 pageInfo : 用于自动管理分页显示
 */
- (void)requestCollectGoodsPageData:(BOOL)firstPage
                         completion:(void (^)(ZFCollectionListModel *listModel,NSArray *currentPageArray,NSDictionary *pageInfo))completion;

/**
 * 请求收藏夹帖子列表数据
 * type： 0普通帖 1穿搭帖
 */
- (void)requestCollectPostPageData:(BOOL)firstPage
                              type:(NSString *)type
                        completion:(void (^)(ZFCollectionPostListModel *listModel,NSArray *currentPageArray,NSDictionary *pageInfo))completion;

/**
 * 添加/取消收藏商品
 * type = 0/1 0添加 1取消
 * target  调用收藏接口的控制器
 */
+ (void)requestCollectionGoodsNetwork:(NSDictionary *)parmaters
                           completion:(void (^)(BOOL isOK))completion
                               target:(id)target;

@end
