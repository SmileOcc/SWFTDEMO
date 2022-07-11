//
//  OSSVTransportineeModel.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OSSVTransporteTrackeMode;
NS_ASSUME_NONNULL_BEGIN

@interface OSSVTransportineeModel : NSObject
@property (nonatomic, copy) NSString *logistics_status; //物流状态
@property (nonatomic, copy) NSString *desc;             //信息描述
@property (nonatomic, copy) NSString *date;           //时间
@property (nonatomic, copy) NSString *loc;            //地址
@property (nonatomic, strong) NSArray <OSSVTransporteTrackeMode *> *trackArray; //物流轨迹
@end

NS_ASSUME_NONNULL_END
