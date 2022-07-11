//
//  OSSVSizeChartModel.h
// XStarlinkProject
//
//  Created by odd on 2020/10/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OSSVSizeChartItemModel;

@interface OSSVSizeChartModel : NSObject

@property (nonatomic, copy) NSString   *size_name;

@property (nonatomic, strong) NSArray <OSSVSizeChartItemModel*> *position_data;
@end


@interface OSSVSizeChartItemModel : NSObject

@property (nonatomic, copy) NSString   *position_name;
@property (nonatomic, copy) NSString   *measurement_value;

@end
