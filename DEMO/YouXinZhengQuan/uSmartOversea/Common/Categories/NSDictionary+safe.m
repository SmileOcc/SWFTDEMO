//
//  NSDictionary+safe.m
//  uSmartOversea
//
//  Created by rrd on 2018/7/19.
//Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "NSDictionary+safe.h"
#import "NSObject+swizzle.h"

#if _SEQUENCE_SAFE_ENABLED
@implementation NSDictionary (safe)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [NSObject swizzleObjectClass:NSClassFromString(@"__NSPlaceholderDictionary") originalSelector:@selector(initWithObjects:forKeys:count:) swizzledSelector:@selector(safe_initWithObjects:forKeys:count:)];
        
    });
}

- (instancetype)safe_initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt {
    
    id __unsafe_unretained newObjects[cnt];
    id __unsafe_unretained newKeys[cnt];
    
    NSInteger index = 0;
    
    for (NSInteger i = 0; i < cnt; i++) {
        if (objects[i] && keys[i]) {
            newObjects[index] = objects[i];
            newKeys[index] =keys[i];
            
            index++;
        }
    }
    
    return [self safe_initWithObjects:newObjects forKeys:newKeys count:index];
}



@end


@implementation NSMutableDictionary (safe)


+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [NSObject swizzleObjectClass:NSClassFromString(@"__NSDictionaryM") originalSelector:@selector(setObject:forKey:) swizzledSelector:@selector(safe_setObject:forKey:)];
        [NSObject swizzleObjectClass:NSClassFromString(@"__NSDictionaryM") originalSelector:@selector(setObject:forKeyedSubscript:) swizzledSelector:@selector(safe_setObject:forKeyedSubscript:)];
        
    });
}

- (void)safe_setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    
    if (anObject && aKey) {
        [self safe_setObject:anObject forKey:aKey];
    }
    
}

- (void)safe_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    
    if (obj && key) {
        [self safe_setObject:obj forKeyedSubscript:key];
    }
}
@end

#endif
