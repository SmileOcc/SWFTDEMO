//
//  OSSVCartFreeShippingModel.h
// XStarlinkProject
//
//  Created by Kevin on 2021/6/9.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVCartFreeShippingModel : NSObject
@property (nonatomic, copy) NSString *freeShipLeft; //左侧文案
@property (nonatomic, copy) NSString *freeShipRight; //右侧文案
@property (nonatomic, copy) NSString *specialId; //专题Id
@property (nonatomic, copy) NSString *amount; //包邮金额

@end

NS_ASSUME_NONNULL_END
