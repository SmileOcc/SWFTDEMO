//
//  OSSVDetailHeaderReviewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/10.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OSSVDetailReviewSubModel;

@interface OSSVDetailHeaderReviewModel : NSObject

@property (nonatomic, copy) NSString      *count;
@property (nonatomic, copy) NSString      *score;
@property (nonatomic, strong) NSArray     *data;

@end

//商品详情 评论
@interface OSSVDetailReviewSubModel : NSObject

@property (nonatomic, copy) NSString     *content;
@property (nonatomic, copy) NSString     *rateOverall;
@property (nonatomic, copy) NSString     *addTime;
@property (nonatomic, copy) NSString     *nickname;
@property (nonatomic, copy) NSString     *avatar;
@property (nonatomic, copy) NSString     *goodsAttr;
@property (nonatomic, strong) NSArray    *reviewPic;

@property (nonatomic,assign) CGFloat    detailReviewReplayHeight;
@property (nonatomic,assign) CGFloat    detailReviewHeight;
@end
