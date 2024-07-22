//
//  ZFRRPTools.h
//  ZZZZZ
//
//  Created by YW on 2019/10/15.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFRRPModel : NSObject

@property (nonatomic, copy) NSAttributedString *rrpString;
@property (nonatomic, assign) BOOL needWarp;

@end

@interface ZFRRPTools : NSObject

+ (ZFRRPModel *)gainZFRRPAttributedString:(NSString *)price marketPrice:(NSString *)marketPrice;

@end

NS_ASSUME_NONNULL_END
