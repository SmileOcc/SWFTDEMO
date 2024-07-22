//
//  ZFSearchMapViewModel.h
//  ZZZZZ
//
//  Created by YW on 8/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseViewModel.h"
#import "GoodsDetailModel.h"

@interface ZFSearchMapViewModel : BaseViewModel

/**
 * 分类页面以图搜图入口
 */
- (NSURLSessionDataTask *)requestSearchSDKWithImage:(UIImage *)sourceImage
                                  searchImagePolicy:(NSString *)searchImagePolicy
                                         completion:(void (^)(BOOL isSuccess))completion;


- (NSArray *)queryPageArray:(NSInteger)index;

- (NSInteger)queryCategoryArrayCount:(NSInteger)index;

- (NSArray <NSString *> *)tabMenuTitles;

- (void)requestSearchResultData:(NSString *)goodsID
                     completion:(void (^)(NSArray *currentPageArray))completion;


- (void)reloadCollectionState:(NSDictionary *)info completion:(void (^)(NSIndexPath *index))completion;

@end
