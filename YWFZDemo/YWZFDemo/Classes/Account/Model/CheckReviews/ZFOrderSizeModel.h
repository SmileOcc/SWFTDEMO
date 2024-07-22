//
//  ZFOrderSizeModel.h
//  ZZZZZ
//
//  Created by YW on 2019/4/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  订单评论尺寸模型

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFOrderSizeModel : NSObject

@property (nonatomic, copy) NSString *sizeId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL is_select;

@end

NS_ASSUME_NONNULL_END
