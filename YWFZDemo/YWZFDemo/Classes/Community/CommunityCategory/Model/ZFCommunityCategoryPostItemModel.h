//
//  ZFCategoryWaterPostItemModel.h
//  ZZZZZ
//
//  Created by YW on 2018/8/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>
#import <UIKit/UIKit.h>

@class ZFCommunityCategoryPostPicModel;

@interface ZFCommunityCategoryPostItemModel : NSObject<YYModel>

@property (nonatomic, copy) NSString                                *post_id;
@property (nonatomic, copy) NSString                                *avatar;
@property (nonatomic, copy) NSString                                *content;
@property (nonatomic, copy) NSString                                *nickname;
@property (nonatomic, copy) NSString                                *title;
@property (nonatomic, copy) NSString                                *user_id;
@property (nonatomic, copy) NSString                                *likeCount;//点赞数
@property (nonatomic, assign) BOOL                                  isLiked;
@property (nonatomic, strong) ZFCommunityCategoryPostPicModel                *pic;


//自定义 社区首页瀑布流cell
@property (nonatomic, assign) CGSize twoColumnCellSize;
@property (nonatomic, assign) CGFloat twoColumnImageHeight;
//首页社区布瀑流
- (void)calculateWaterFlowCellSize;

@end


//帖子列表图片
@interface ZFCommunityCategoryPostPicModel : NSObject

@property (nonatomic, copy) NSString                                *big_pic;
@property (nonatomic, copy) NSString                                *height;
@property (nonatomic, copy) NSString                                *is_first_pic;
@property (nonatomic, copy) NSString                                *origin_pic;
@property (nonatomic, copy) NSString                                *review_id;
@property (nonatomic, copy) NSString                                *small_pic;
@property (nonatomic, copy) NSString                                *width;

@end
