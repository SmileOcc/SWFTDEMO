//
//  OSSVReviewsListModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVReviewsImageListModel.h"

@interface OSSVReviewsListModel : NSObject

@property (nonatomic,copy) NSString *userName;//用户名称
@property (nonatomic,copy) NSString *content;//评论内容
@property (nonatomic,copy) NSString *time;//评论时间
@property (nonatomic,copy) NSString *star;//评价分数
@property (nonatomic,copy) NSString *avatar;//???
@property (nonatomic,strong) NSArray *imgList;//上传的图片


@property (nonatomic,assign) CGFloat    detailReviewReplayHeight;
@property (nonatomic,assign) CGFloat    detailReviewHeight;

@end
