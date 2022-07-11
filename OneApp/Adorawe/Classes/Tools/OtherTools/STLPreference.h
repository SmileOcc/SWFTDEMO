//
//  STLPreference.h
// XStarlinkProject
//
//  Created by fan wang on 2021/5/22.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STLPreference : NSObject
+(void)setObject:(id)object key:(NSString *)key;
+(id)objectForKey:(NSString *)key;

+(void)setIsFirstIntoDetails:(BOOL)value;
+(BOOL)isFirstIntoDetails;

@end

NS_ASSUME_NONNULL_END
