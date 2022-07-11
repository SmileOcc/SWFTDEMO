//
//  OSSVAccounteOrderseDetailShippingeModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteOrderseDetailShippingeModel.h"

@implementation OSSVAccounteOrderseDetailShippingeModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"ondate"                : @"ondate",
             @"status"                : @"status",
             @"waitingShip"           : @"wait_shipment",
             @"alreadyShip"           : @"shipped_info",
             @"transport"             : @"transit",
             @"alreadySign"           : @"sign_info",
             @"shipAdress"            : @"shipping_address_info",
             @"trackingNumber"        : @"tracking_number"
             };
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"waitingShip"          : [OSSVTrackincWaitingcShipMode class],
             @"alreadyShip"          : [OSSVAlreadycShipcModel class],
             @"transport"            : [OSSVTransportineeModel class],
             @"alreadySign"          : [OSSVAlreadyeSigneModel class],
             @"shipAdress"           : [OSSVTrackineAddresseModel class]

             };
}


// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[@"ondate",
             @"status",
             @"waitingShip",
             @"alreadyShip",
             @"transport",
             @"alreadySign",
             @"shipAdress",
             @"trackingNumber"
    ];
}

@end
