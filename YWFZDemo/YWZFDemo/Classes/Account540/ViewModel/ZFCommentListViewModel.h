//
//  ZFCommentListViewModel.h
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFWaitCommentModel.h"

@interface ZFCommentListViewModel : NSObject

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger totalPage;
@property (nonatomic, assign) NSInteger totalCount;//评论总个数

- (void)requestWaitCommentPort:(BOOL)isFirstPage
                    completion:(void (^)(NSArray *model))completion;


- (void)requestMyCommentPort:(BOOL)isFirstPage
                  completion:(void (^)(NSArray *))completion;

@end

