//
//  OSSVMyLocationeManager.m
// XStarlinkProject
//
//  Created by Kevin on 2021/9/6.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVMyLocationeManager.h"


@interface OSSVMyLocationeManager ()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void(^locationSuccess)(CLLocation *location);
@property (nonatomic, copy) void(^locationFailure)(CLAuthorizationStatus status, NSError *error);
@property (nonatomic, copy) void(^adddress)(NSString *addressString);
@property (nonatomic, copy) NSString *addressString;
@end

@implementation OSSVMyLocationeManager

+ (OSSVMyLocationeManager *)sharedManager {
    static OSSVMyLocationeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[OSSVMyLocationeManager alloc]init];
    });
    return manager;
}

+ (void)startLocation:(void(^)(CLLocation *location))success address:(void (^)(NSString *))addressString failure:(void (^)(CLAuthorizationStatus, NSError *))failure {
//    [[OSSVMyLocationeManager sharedManager]startLocation:success failure:failure];
    [[OSSVMyLocationeManager sharedManager] startLocation:success address:addressString failure:failure];
}

+ (void)stopLocation {
    [[OSSVMyLocationeManager sharedManager]stopLocation];
}

- (void)startLocation:(void(^)(CLLocation *location))success address:(void(^)(NSString *addressString))addressString failure:(void(^)(CLAuthorizationStatus status, NSError *error))failure {
    self.locationSuccess = success;
    self.locationFailure = failure;
    self.adddress = addressString;
    [self.locationManager startUpdatingLocation];
}

- (void)stopLocation {
    [self.locationManager stopUpdatingLocation];
}

- (NSString *)addressString {
    if (!_addressString) {
        _addressString = [NSString string];
    }
    return _addressString;
}

- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc]init];
        [_locationManager requestWhenInUseAuthorization];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 0.1;
    }
    return _locationManager;
}

#pragma mark - CLLocationManagerDelegate

/// 定位成功
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (self.locationSuccess) {
        self.locationSuccess(locations.lastObject);
        NSLog(@"获取到的纬度：%lf------经度：%lf", locations.lastObject.coordinate.latitude,locations.lastObject.coordinate.longitude);
        //反向地理编码
     
          CLGeocoder *clGeoCoder = [[CLGeocoder alloc] init];
     
          CLLocation *cl = [[CLLocation alloc] initWithLatitude:locations.lastObject.coordinate.latitude longitude:locations.lastObject.coordinate.longitude];
     
          @weakify(self)
          [clGeoCoder reverseGeocodeLocation:cl completionHandler: ^(NSArray *placemarks,NSError *error) {
           @strongify(self)
              if (placemarks.count) {
                  CLPlacemark *placeMark  = placemarks.lastObject;
                  NSString *country = STLToString(placeMark.country);
                  NSString *state   = STLToString(placeMark.administrativeArea);
                  NSString *city    = STLToString(placeMark.locality);
                  NSString *subLocality = STLToString(placeMark.subLocality);
                  NSString *street  = STLToString(placeMark.name);
                  
                  NSLog(@"所在城市====%@ %@ %@ %@ %@", street, subLocality, city, state, country);
                    NSString *str = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",street,subLocality,city,state,country];
                    self.adddress(str);
                    [_locationManager stopUpdatingLocation];
              }

          }];
    }
}

/// 定位失败
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    if (self.locationFailure) {
        if (@available(iOS 14.0, *)) {
            self.locationFailure(manager.authorizationStatus, error);
        } else {
            self.locationFailure([CLLocationManager authorizationStatus], error);
        }
    }
}

/// 定位权限
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusAuthorizedWhenInUse && status != kCLAuthorizationStatusAuthorizedAlways) {
        if (self.locationFailure) {
            self.locationFailure(status, nil);
        }
        NSLog(@"没有开启定位权限");
    } else {
        NSLog(@"已经开启了权限");
    }
}

@end
