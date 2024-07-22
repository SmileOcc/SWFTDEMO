//
//  ZFSearchTypeModel.h
//  ZZZZZ
//
//  Created by YW on 2018/2/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZFSearchType) {
    ZFSearchTypePorpular = 0,
    ZFSearchTypeHistory
};

@interface ZFSearchTypeModel : NSObject
@property (nonatomic, assign) ZFSearchType          type;
@end
