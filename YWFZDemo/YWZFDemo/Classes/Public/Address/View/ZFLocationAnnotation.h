//
//  ZFLocationAnnotation.h
//  ZZZZZ
//
//  Created by YW on 2017/12/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface ZFLocationAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@end
