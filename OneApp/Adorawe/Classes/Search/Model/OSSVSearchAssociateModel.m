//
//  OSSVSearchAssociateModel.m
// XStarlinkProject
//
//  Created by odd on 2020/10/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVSearchAssociateModel.h"

@implementation OSSVSearchAssociateModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"cat"      : [STLSearchAssociateCatModel class],
             @"goods"    : [STLSearchAssociateGoodsModel class]
             };
}


@end


@implementation STLSearchAssociateCatModel

@end


@implementation STLSearchAssociateGoodsModel

@end
