//
//  NSArray+safe.m
//  uSmartOversea
//
//  Created by rrd on 2018/7/19.
//Copyright © 2018年 RenRenDai. All rights reserved.
//

#import "NSArray+safe.h"
#import "NSObject+swizzle.h"
#import <YXKit/YXKit.h>

#if _SEQUENCE_SAFE_ENABLED
@implementation NSArray (safe)

//#ifdef DEBUG

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        
        //不可变数组 > 1  个元素
        [NSObject swizzleObjectClass:NSClassFromString(@"__NSArrayI") originalSelector:@selector(objectAtIndex:) swizzledSelector:@selector(safe_arrayIobjectAtIndex:)];
        
        //数组中0个元素
        [NSObject swizzleObjectClass:NSClassFromString(@"__NSArray0") originalSelector:@selector(objectAtIndex:) swizzledSelector:@selector(safe_array0objectAtIndex:)];
        
        //数组中一个元素
        [NSObject swizzleObjectClass:NSClassFromString(@"__NSSingleObjectArrayI") originalSelector:@selector(objectAtIndex:) swizzledSelector:@selector(safe_arraySingleObjectAtIndex:)];
        
        
        [NSObject swizzleObjectClass:NSClassFromString(@"__NSArrayI") originalSelector:@selector(objectAtIndexedSubscript:) swizzledSelector:@selector(safe_arrayIobjectAtIndexedSubscript:)];
        
        
        [NSObject swizzleObjectClass:NSClassFromString(@"__NSPlaceholderArray") originalSelector:@selector(initWithObjects:count:) swizzledSelector:@selector(safe_initWithObjects:count:)];
        
        
    });
}

//#else




//#endif

#pragma mark - objectAtIndex
- (id)safe_arrayIobjectAtIndex:(NSUInteger)index {
    
    @synchronized(self) {
        if (index >= self.count) {
            LOG_ERROR(kOther, @"❌safe_arrayIobjectAtIndex error index = %d, count = %d", index, self.count);
            return nil;
        }
        return [self safe_arrayIobjectAtIndex:index];
    }
    
}




- (id)safe_array0objectAtIndex:(NSUInteger)index {
    @synchronized(self) {
        if (index >= self.count) {
            LOG_ERROR(kOther, @"❌safe_array0objectAtIndex error index = %d, count = %d", index, self.count);
            return nil;
        }
        return [self safe_array0objectAtIndex:index];
    }
}


- (id)safe_arraySingleObjectAtIndex:(NSUInteger)index {
    @synchronized(self) {
        if (index >= self.count) {
            LOG_ERROR(kOther, @"❌safe_arraySingleObjectAtIndex error index = %d, count = %d", index, self.count);
            return nil;
        }
        return [self safe_arraySingleObjectAtIndex:index];
    }
}


#pragma mark - objectAtIndexedSubscript
- (id)safe_arrayIobjectAtIndexedSubscript:(NSUInteger)idx {
    
    @synchronized(self) {
        if (idx >= self.count) {
            LOG_ERROR(kOther, @"❌safe_arrayIobjectAtIndexedSubscript error idx = %d, count = %d", idx, self.count);
            return nil;
        }
        return [self safe_arrayIobjectAtIndexedSubscript:idx];
    }
    
}


#pragma mark - 数组插入nil处理
- (instancetype)safe_initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt {
    
    id __unsafe_unretained newObjects[cnt];
    NSUInteger index = 0;
    
    for (NSUInteger i = 0; i < cnt; i++) {
        if (objects[i]) {
            newObjects[index++] = objects[i];
        }
    }
    
    return  [self safe_initWithObjects:newObjects count:index];
}




@end

@implementation NSMutableArray (safe)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //可变数组
        [NSObject swizzleObjectClass:NSClassFromString(@"__NSArrayM") originalSelector:@selector(objectAtIndex:) swizzledSelector:@selector(safe_arrayMobjectAtIndex:)];
        
        [NSObject swizzleObjectClass:NSClassFromString(@"__NSArrayM") originalSelector:@selector(objectAtIndexedSubscript:) swizzledSelector:@selector(safe_arrayMobjectAtIndexedSubscript:)];
        
        [NSObject swizzleObjectClass:NSClassFromString(@"__NSArrayM") originalSelector:@selector(insertObject:atIndex:) swizzledSelector:@selector(safe_insertObject:atIndex:)];
        
        [NSObject swizzleObjectClass:NSClassFromString(@"__NSArrayM") originalSelector:@selector(removeObject:inRange:) swizzledSelector:@selector(safe_removeObject:inRange:)];
        
        [NSObject swizzleObjectClass:NSClassFromString(@"__NSArrayM") originalSelector:@selector(removeObjectsInRange:) swizzledSelector:@selector(safe_removeObjectsInRange:)];
        
        
        
        
    });
}


- (id)safe_arrayMobjectAtIndex:(NSUInteger)index {
    
    @synchronized(self) {
        if (index >= self.count) {
            LOG_ERROR(kOther, @"❌safe_arrayIobjectAtIndexedSubscript error index = %d, count = %d", index, self.count);
            return nil;
        }
        return [self safe_arrayMobjectAtIndex:index];
    }
}



- (id)safe_arrayMobjectAtIndexedSubscript:(NSUInteger)idx {
    
    @synchronized(self) {
        if (idx >= self.count) {
            LOG_ERROR(kOther, @"❌safe_arrayMobjectAtIndexedSubscript error idx = %d, count = %d", idx, self.count);
            return nil;
        }
        return [self safe_arrayMobjectAtIndexedSubscript:idx];
    }
    
}

- (void)safe_insertObject:(id)anObject atIndex:(NSUInteger)index {
    
    if (!anObject) {
        LOG_ERROR(kOther, @"❌safe_insertObject:atIndex: error anObject is nil");
        return;
    }
    
    if (index > self.count) {
        LOG_ERROR(kOther, @"❌safe_insertObject:atIndex: error index = %d, count = %d", index, self.count);
        return;
    }
    
    [self safe_insertObject:anObject atIndex:index];
    
}


- (void)safe_removeObject:(id)anObject inRange:(NSRange)range {
    
    if (range.location > self.count) {
        LOG_ERROR(kOther, @"❌safe_removeObject:inRange: error range.location = %d, count = %d", range.location, self.count);
        return;
    }
    
    if (range.length > self.count) {
        LOG_ERROR(kOther, @"❌safe_removeObject:inRange: error range.length = %d, count = %d", range.length, self.count);
        return;
    }
    
    if ((range.location + range.length) > self.count) {
        LOG_ERROR(kOther, @"❌safe_removeObject:inRange: error range.location = %d, range.length = %d, count = %d", range.location, range.length, self.count);
        return;
    }
    
    if (!anObject){
        LOG_ERROR(kOther, @"❌safe_removeObject:inRange: error anObject is nil");
        return;
    }
    
    return [self safe_removeObject:anObject inRange:range];
}


- (void)safe_removeObjectsInRange:(NSRange)range {
    if (range.location > self.count) {
        LOG_ERROR(kOther, @"❌safe_removeObject:inRange: error range.location = %d, count = %d", range.location, self.count);
        return;
    }
    
    if (range.length > self.count) {
        LOG_ERROR(kOther, @"❌safe_removeObject:inRange: error range.length = %d, count = %d", range.length, self.count);
        return;
    }
    
    if ((range.location + range.length) > self.count) {
        LOG_ERROR(kOther, @"❌safe_removeObject:inRange: error range.location = %d, range.length = %d, count = %d", range.location, range.length, self.count);
        return;
    }
    
    return [self safe_removeObjectsInRange:range];
}

@end
#endif
