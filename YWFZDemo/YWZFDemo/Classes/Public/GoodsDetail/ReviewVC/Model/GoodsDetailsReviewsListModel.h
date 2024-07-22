//
//  GoodsDetailsReviewsListModel.h
//  Yoshop
//
//  Created by YW on 16/6/10.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoodsDetailsReviewsSizeModel.h"
@class GoodsDetailsReviewsImageListModel;

@interface GoodsDetailsReviewsListModel : NSObject

@property (nonatomic,copy) NSString     *review_id;
@property (nonatomic,copy) NSString     *userName;//用户名称
@property (nonatomic,copy) NSString     *content;//评论内容
@property (nonatomic, copy) NSString    *parent_review_content;

@property (nonatomic,copy) NSString     *time;//评论时间
@property (nonatomic,copy) NSString     *star;//评价分数
@property (nonatomic,copy) NSString     *avatar;//用户头像
@property (nonatomic,strong) NSArray<GoodsDetailsReviewsImageListModel *> *imgList;//上传的图片

//自定义 是否显示翻译
@property (nonatomic, assign) BOOL      isTranslate;

//用户填写的尺寸
@property (nonatomic,strong) GoodsDetailsReviewsSizeModel *review_size;

///
@property (nonatomic, copy) NSString *attr_strs;
@end
