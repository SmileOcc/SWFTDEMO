//
//  OSSVTrackingcTotalInformcnModel.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVTrackingcTotalInformcnModel.h"
@implementation OSSVTrackingcTotalInformcnModel


+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"trackingNumber"       : @"tracking_number",
             @"waitingShip"           : @"wait_shipment",
             @"alreadyShip"           : @"shipped_info",
             @"transport"             : @"transit",
             @"alreadySign"           : @"sign_info",
             @"shipAdress"            : @"shipping_address_info",
             @"refuseSign"            : @"refused_info"
             };
}
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"waitingShip"             : [OSSVTrackincWaitingcShipMode class],
             @"alreadyShip"             : [OSSVAlreadycShipcModel class],
             @"transport"               : [OSSVTransportineeModel class],
             @"alreadySign"             : [OSSVAlreadyeSigneModel class],
             @"shipAdress"              : [OSSVAddresseBookeModel class],
             @"refuseSign"              : [OSSVRefuseeSigneeModel class]
             };
}

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    
    return  @[
              @"trackingNumber",
              @"waitingShip",
              @"alreadyShip",
              @"transport",
              @"alreadySign",
              @"shipAdress",
              @"refuseSign"
              ];
}
@end
