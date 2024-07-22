//
//  YWLoginNewCountryModel.h
//  ZZZZZ
//
//  Created by YW on 2019/5/27.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  新兴市场国家模型

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YWLoginNewCountryModel : NSObject

@property (nonatomic, copy) NSString *region_id;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *region_name;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@end

NS_ASSUME_NONNULL_END
