//
//  OSSVSupporteLangeModel.h
// XStarlinkProject
//
//  Created by odd on 2020/7/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVSupporteLangeModel : NSObject

//语言code
@property (nonatomic, copy) NSString *code;
//语言名称
@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) NSInteger is_default;

@end

NS_ASSUME_NONNULL_END
