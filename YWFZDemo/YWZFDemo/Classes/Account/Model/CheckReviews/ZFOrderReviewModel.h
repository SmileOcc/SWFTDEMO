//
//  ZFOrderReviewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/3/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFOrderReviewInfoModel.h"
#import "ZFOrderReviewGoodsModel.h"

@interface ZFOrderReviewModel : NSObject

@property (nonatomic, copy) NSString                                *is_write;
@property (nonatomic, copy) NSString                                *sku;
@property (nonatomic, copy) NSString                                *review_img_domain;
@property (nonatomic, strong) NSArray<ZFOrderReviewInfoModel *>     *reviewList;
@property (nonatomic, strong) NSArray<NSString *>                   *review_hot_word;
@property (nonatomic, strong) ZFOrderReviewGoodsModel               *goods_info;

///客户端本地设置值，是否选择了 overallid 默认值 -1
@property (nonatomic, assign) NSInteger                             overallid;

///用户在填写过程中自己选中的星的数量,默认 5.f
@property (nonatomic, assign) float                             userSelectStartCount;

@end
