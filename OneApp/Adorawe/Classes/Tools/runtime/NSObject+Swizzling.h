//
//  NSObject+Swizzling.h
//  TestDemo
//
//  Created by Bruce on 16/12/22.
//  Copyright © 2016年 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzling)

/**
 * 获取类的成员变量名数组(当前类定义，包括属性定义的成员变量)
 */
+ (NSArray *)stl_memberVaribaleNames;


/**
 * 获取类的属性名数组(当前类定义,只是声明property的成员变量。)
 */
+ (NSArray *)stl_propertyNames;


/**
 * 获取类方法名数组(当前类定义，不包括父类中的方法)
 */
+ (NSArray *)stl_methodNames;


/**
 *  校验一个类是否有该属性
 */
+ (BOOL)stl_hasVarName:(NSString *)name;

- (BOOL)stl_hasVarNameCC:(NSString *)name;
/**
 *  交换两个实例方法的实现
 *
 *  @param originSelector 原始方法
 *  @param otherSelector  需要覆盖原始的方法
 */
+ (void)swizzleMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector;


- (BOOL)class_addMethod:(Class)class selector:(SEL)selector imp:(IMP)imp types:(const char *)types;

- (BOOL)isContainSel:(SEL)sel inClass:(Class)class;

@end
