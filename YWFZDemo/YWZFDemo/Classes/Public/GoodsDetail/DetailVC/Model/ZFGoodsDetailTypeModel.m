
//
//  ZFGoodsDetailTypeModel.m
//  ZZZZZ
//
//  Created by YW on 2017/11/26.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsDetailTypeModel.h"

@implementation ZFGoodsDetailTypeModel

+ (instancetype)createWithTpye:(ZFGoodsDetailType)type {
    ZFGoodsDetailTypeModel *typeModel = [[ZFGoodsDetailTypeModel alloc] init];
    typeModel.type = type;
    return typeModel;
}

@end
