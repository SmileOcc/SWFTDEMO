//
//  ZFCommunityFavesModel.h
//  ZZZZZ
//
//  Created by YW on 2017/8/3.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFCommunityFavesModel : NSObject
@property (nonatomic, strong) NSArray *list;//评论列表
@property (nonatomic, assign) NSInteger pageCount;//总页数
@property (nonatomic, copy) NSString *curPage;//当前页数
@property (nonatomic, copy) NSString *type;//类型
@end
