//
//  GoodsDetailFirstReviewModel.h
//  ZZZZZ
//
//  Created by YW on 17/1/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoodsDetailsReviewsSizeModel.h"



@interface GoodsDetailFirstReviewModel : NSObject

/** 用户名称*/
@property (nonatomic,copy)   NSString *userName;
/** 评论内容,默认显示*/
@property (nonatomic,copy)   NSString *content;
/** 有两种语言时，原始语言*/
@property (nonatomic, copy)  NSString *parent_review_content;
@property (nonatomic,copy)   NSString *time;//评论时间
@property (nonatomic,copy)   NSString *star;//评价分数
@property (nonatomic,copy)   NSString *avatar;//用户头像
@property (nonatomic,strong) NSArray *imgList;//上传的图片

//自定义 是否显示翻译
@property (nonatomic, assign) BOOL isTranslate;

//用户填写的尺寸
@property (nonatomic,strong) GoodsDetailsReviewsSizeModel *review_size;

///用户购买的尺寸
@property (nonatomic, copy) NSString *attr_strs;
@end
