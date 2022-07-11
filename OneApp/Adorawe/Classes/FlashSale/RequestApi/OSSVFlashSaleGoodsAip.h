//
//  OSSVFlashSaleGoodsAip.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVBasesRequests.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,STLFLashRequestType){
    STLFLashRequestTypeGetGoods,
    STLFLashRequestTypeFlowSwitch
};

@interface OSSVFlashSaleGoodsAip : OSSVBasesRequests
- (instancetype)initWithFlashSaleGoodsWithActiveId:(NSString *)ActiveId page:(NSInteger)page pageSize:(NSInteger)pageSize;

@property (assign,nonatomic) STLFLashRequestType requestType;

@property (assign,nonatomic) NSInteger followId;
@end

NS_ASSUME_NONNULL_END
