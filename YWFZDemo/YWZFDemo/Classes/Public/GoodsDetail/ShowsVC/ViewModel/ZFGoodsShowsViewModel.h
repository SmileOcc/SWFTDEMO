//
//  ZFGoodsShowsViewModel.h
//  ZZZZZ
//
//  Created by YW on 2019/3/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFGoodsShowsViewModel : BaseViewModel

- (void)requestGoodsShowsData:(NSString *)goods_sku
                 isFirstPage:(BOOL)isFirstPage
                  completion:(void (^)(NSArray *showModelArr, NSDictionary *pageInfo))completion
                     failure:(void (^)(id))failure;

- (void)requestRelatedGoods:(NSString *)goods_sku
                isFirstPage:(BOOL)isFirstPage
                 completion:(void (^)(NSArray *relatedModelArr, NSDictionary *pageInfo))completion
                    failure:(void (^)(id))failure;

- (void)requestAddToCart:(NSString *)goodsId
             goodsNumber:(NSInteger)goodsNumber
              freeGiftId:(NSString *)freeGiftId
             loadingView:(UIView *)loadingView
              completion:(void (^)(id))completion
                 failure:(void (^)(id))failure;

@end

NS_ASSUME_NONNULL_END
