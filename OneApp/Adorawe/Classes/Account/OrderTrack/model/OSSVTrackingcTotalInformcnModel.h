//
//  OSSVTrackingcTotalInformcnModel.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
//  --物流总信息----

#import <Foundation/Foundation.h>
//@class OSSVTrackincWaitingcShipMode;
//@class OSSVAlreadycShipcModel;
//@class OSSVTransportineeModel;
//@class OSSVAlreadyeSigneModel;
//@class OSSVTrackineAddresseModel;
#import "OSSVTrackincWaitingcShipMode.h"
#import "OSSVAlreadycShipcModel.h"
#import "OSSVTransportineeModel.h"
#import "OSSVAlreadyeSigneModel.h"
#import "OSSVTrackineAddresseModel.h"
#import "OSSVRefuseeSigneeModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface OSSVTrackingcTotalInformcnModel : NSObject
//运单号
@property (nonatomic, copy)   NSString *trackingNumber;
@property (nonatomic, strong) OSSVTrackincWaitingcShipMode *waitingShip;//待发货
@property (nonatomic, strong) OSSVAlreadycShipcModel        *alreadyShip;//已发货
@property (nonatomic, strong) OSSVTransportineeModel       *transport;//运输中
@property (nonatomic, strong) OSSVAlreadyeSigneModel        *alreadySign;//已签收
@property (nonatomic, strong) OSSVAddresseBookeModel    *shipAdress;//收货地址
@property (nonatomic, strong) OSSVRefuseeSigneeModel         *refuseSign;//拒签收
@end

NS_ASSUME_NONNULL_END
