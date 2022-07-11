//
//  YXResponseModel.m
//  uSmartOversea
//
//  Created by rrd on 2018/7/23.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "YXResponseModel.h"

@interface YXResponseModel ()

@property (nonatomic, strong, readwrite) NSDictionary *data;
@property (nonatomic, assign, readwrite) YXResponseStatusCode code;
@property (nonatomic, copy, readwrite) NSString *msg;

@end

@implementation YXResponseModel

@end
