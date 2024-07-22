//
//  ZFCollectionPostListModel.h
//  ZZZZZ
//
//  Created by YW on 2019/6/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZFCollectionPostItemModel;
@class ZFCollectionPostReviewPicModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFCollectionPostListModel : NSObject

@property (nonatomic, copy) NSString     *total;
@property (nonatomic, assign) NSInteger   currentPage;// 当前页
@property (nonatomic, assign) NSInteger   totalPage;// 总页数

@property (nonatomic, assign) BOOL     flag;//是否第一次收藏进入显示红点
@property (nonatomic, strong) NSMutableArray<ZFCollectionPostItemModel *>  *list;          //列表数据

@end

@interface ZFCollectionPostItemModel : NSObject

@property (nonatomic, copy) NSString *idx;
@property (nonatomic, copy) NSString *review_type;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *like_count;
@property (nonatomic, copy) NSString *reply_count;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *site_version;
@property (nonatomic, strong) NSArray *topicList;
@property (nonatomic, strong) NSArray<ZFCollectionPostReviewPicModel *> *reviewPic;//图片数组
@property (nonatomic, copy) NSString *user_id;//点赞数
@property (nonatomic, copy) NSString *add_time;//评论数

@end


@interface ZFCollectionPostReviewPicModel : NSObject

@property (nonatomic, copy) NSString *idx;
@property (nonatomic, copy) NSString *big_pic_width;
@property (nonatomic, copy) NSString *review_id;
@property (nonatomic, copy) NSString *small_pic;
@property (nonatomic, copy) NSString *small_pic_height;
@property (nonatomic, copy) NSString *small_pic_width;
@property (nonatomic, copy) NSString *big_pic;
@property (nonatomic, strong) NSArray *pic_title;
@property (nonatomic, copy) NSString *big_pic_height;
@property (nonatomic, copy) NSString *origin_pic;
@property (nonatomic, copy) NSString *is_first_pic;

@end
NS_ASSUME_NONNULL_END
