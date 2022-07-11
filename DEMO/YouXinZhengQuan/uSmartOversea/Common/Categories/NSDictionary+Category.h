//
//  NSDictionary+Category.h
//  iBoxCategory
//
//  Created by TBD on 2018/4/23.


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<KeyType, ObjectType> (Category)

- (BOOL)yx_boolValueForKey:(KeyType <NSCopying>)key;
- (BOOL)yx_boolValueForKey:(KeyType <NSCopying>)key defaultValue:(BOOL)defaultValue;
- (int)yx_intValueForKey:(KeyType <NSCopying>)key;
- (int)yx_intValueForKey:(KeyType <NSCopying>)key defaultValue:(int)defaultValue;
- (long long)yx_longLongValueForKey:(KeyType <NSCopying>)key;
- (long long)yx_longLongValueForKey:(KeyType <NSCopying>)key defaultValue:(long long)defaultValue;
- (nullable NSString *)yx_stringValueForKey:(KeyType <NSCopying>)key;
- (nullable NSString *)yx_stringValueForKey:(KeyType <NSCopying>)key defaultValue:(nullable NSString *)defaultValue;
- (nullable NSDictionary *)yx_dictionaryValueForKey:(KeyType <NSCopying>)key;
- (nullable NSArray *)yx_arrayValueForKey:(KeyType <NSCopying>)key;
- (double)yx_doubleValueForKey:(KeyType <NSCopying>)key;
- (double)yx_doubleValueForKey:(KeyType <NSCopying>)key defaultValue:(double)defaultValue;
- (time_t)yx_timeValueForKey:(KeyType <NSCopying>)key;
- (time_t)yx_timeValueForKey:(KeyType <NSCopying>)key defaultValue:(time_t)defaultValue;

@end

NS_ASSUME_NONNULL_END
