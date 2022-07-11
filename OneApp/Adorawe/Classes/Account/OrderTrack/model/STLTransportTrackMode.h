//
//  OSSVTransporteTrackeMode.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
//----------_运输轨迹------------

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVTransporteTrackeMode : NSObject
@property (nonatomic, copy) NSString *detail;   //物流状态
@property (nonatomic, copy) NSString *desc;             //信息描述
@property (nonatomic, copy) NSString *date;           //时间

@end

NS_ASSUME_NONNULL_END
