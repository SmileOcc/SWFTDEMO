//
//  OSSVAccounteOrderseDetailShippingeModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVTrackincWaitingcShipMode.h"
#import "OSSVAlreadycShipcModel.h"
#import "OSSVTransportineeModel.h"
#import "OSSVAlreadyeSigneModel.h"
#import "OSSVTrackineAddresseModel.h"
#import "OSSVRefuseeSigneeModel.h"
@interface OSSVAccounteOrderseDetailShippingeModel : NSObject

@property (nonatomic, copy) NSString *ondate;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *trackingNumber; //物流单号
//待发货
@property (nonatomic, strong) OSSVTrackincWaitingcShipMode * waitingShip;
//已发货
@property (nonatomic, strong) OSSVAlreadycShipcModel * alreadyShip;
//运输中
@property (nonatomic, strong) OSSVTransportineeModel * transport;
//已签收
@property (nonatomic, strong) OSSVAlreadyeSigneModel * alreadySign;
//拒签收

@property (nonatomic, strong) OSSVRefuseeSigneeModel    *refuseSign;

//收货地址
@property (nonatomic, strong) OSSVTrackineAddresseModel    *shipAdress;


@end
