//
//  OSSVSizesModel.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVSizesModel.h"

@implementation STLSizeShapModel

@end

@implementation OSSVSizesModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"shape_options" : [STLSizeShapModel class]};
}

@end
