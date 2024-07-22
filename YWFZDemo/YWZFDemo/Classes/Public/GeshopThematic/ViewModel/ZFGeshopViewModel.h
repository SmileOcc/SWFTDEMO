//
//  ZFGeshopViewModel.h
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "BaseViewModel.h"
@class ZFGeshopSectionModel, ZFGeshopSectionListModel;

typedef void(^ZFGeshopDataBlock)(NSArray<ZFGeshopSectionModel *> *, NSDictionary *);
typedef void(^ZFGeshopMoreDataBlock)(NSArray<ZFGeshopSectionListModel *> *, NSDictionary *);

typedef enum : NSUInteger {
    ZFGeshopRequest_detailType=2019,
    ZFGeshopRequest_moreDataType,
    ZFGeshopRequest_asyncInfoType,
} ZFGeshopRequestDataType;


@interface ZFGeshopViewModel : BaseViewModel

///筛选组件模型
@property (nonatomic, strong, readonly) ZFGeshopSectionModel *siftSectionModel;
/// 最后一个商品组件, 用于判断是否还能分页
@property (nonatomic, strong, readonly) ZFGeshopSectionModel *lastGoodsSectionModel;

@property (nonatomic, copy)NSString *nativeThemeId;
@property (nonatomic, copy)NSString *nativeThemeTitle;
@property (nonatomic, strong) NSArray *listViewCellBlockArray;
@property (nonatomic, assign) NSInteger curPage;
@property (nonatomic, assign) NSInteger page_size;

- (NSString *)fetchMorePageComponent_ids;

- (NSString *)fetchSiftComponent_ids;


/// 请求专题筛选数据列表 <接口里有一个失败就不显示页面>
/// @param geshopInfo 请求参数
/// @param needRequestS3 是否需要请求S3备份数据
/// @param completion 回调
- (void)requestGeshopPageData:(NSDictionary *)geshopInfo
                   completion:(ZFGeshopDataBlock)completion;


/// 分页请求专题组件数据
/// @param geshopInfo 请求参数
/// @param completion 回调

- (void)requestGeshopMoreData:(NSDictionary *)geshopInfo
                   completion:(ZFGeshopMoreDataBlock)completion;


/// 异步请求指定组件id数据
/// @param geshopInfo 请求参数
/// @param completion 回调

- (void)requestGeshopAsyncData:(NSDictionary *)geshopInfo
               pageModelArrray:(NSArray<ZFGeshopSectionModel *> *)pageModelArrray
                    completion:(ZFGeshopDataBlock)completion;

@end
