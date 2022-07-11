//
//  UIView+STLSensors.m
// XStarlinkProject
//
//  Created by odd on 2021/6/16.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "UIView+STLSensors.h"

@implementation UIView (STLSensors)
@dynamic sensor_element_id;

- (void)setSensor_element_id:(NSString *)sensor_element_id {
    self.sensorsAnalyticsViewProperties = @{@"$element_id": STLToString(sensor_element_id)};
}
@end
