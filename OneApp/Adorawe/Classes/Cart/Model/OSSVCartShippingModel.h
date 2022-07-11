//
//  OSSVCartShippingModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVCartShippingModel : NSObject

@property (nonatomic, copy) NSString *sid;
@property (nonatomic, copy) NSString *hasTrackingInfo;
@property (nonatomic, copy) NSString *needTraking;
@property (nonatomic, copy) NSString *trackingFee;
@property (nonatomic, copy) NSString *shipDesc;
@property (nonatomic, copy) NSString *shipName;
@property (nonatomic, copy) NSString *shipSave;
@property (nonatomic, copy) NSString *shippingFee;
@property (nonatomic, copy) NSString *sortOrder;

@property (nonatomic, copy) NSString *shipping_fee_converted;

/*是否COD物流*/
-(BOOL)isCodShipping;

@end
