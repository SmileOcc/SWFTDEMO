//
//  AnalyticsInjectManager.m
//  TestViewModel
//
//  Created by YW on 2018/9/25.
//  Copyright © 2018年 610715. All rights reserved.
//

#import "AnalyticsInjectManager.h"
#import <objc/runtime.h>
#import "Aspects.h"
#import "NSObject+Swizzling.h"
#import "Constants.h"

@implementation AnalyticsInjectManager

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    static AnalyticsInjectManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

-(void)analyticsInject:(NSObject *)fromObject injectObject:(id<ZFAnalyticsInjectProtocol>)injectObject
{
    if (!fromObject) {
        NSAssert(true, @"fromObject is nil");
        return;
    }
    
    if (!injectObject) {
        YWLog(@"injectObject is nil");
        return;
    }
    if (![injectObject conformsToProtocol:@protocol(ZFAnalyticsInjectProtocol)]) {
        YWLog(@"need AnalyticsInjectManagerProtocol");
        return;
    }
    
    if ([injectObject respondsToSelector:@selector(gainCurrentAopClass:)]) {
        [injectObject gainCurrentAopClass:fromObject];
    }
    
    NSDictionary *methodParams = [injectObject injectMenthodParams];
    if (![methodParams isKindOfClass:[NSDictionary class]]) {
        YWLog(@"injectMenthodParams error");
        return;
    }
    //执行后置方法hook
    [self aspect_injectMethodParams:methodParams
                        fromeObject:fromObject
                       injectObject:injectObject
                       aspectOption:AspectPositionAfter];
    
    if ([injectObject respondsToSelector:@selector(beforeInjectMenthodParams)]) {
        NSDictionary *beforeMethodParams = [injectObject beforeInjectMenthodParams];
        //执行前置方法hook
        if ([beforeMethodParams isKindOfClass:[NSDictionary class]]) {
            [self aspect_injectMethodParams:beforeMethodParams
                                fromeObject:fromObject
                               injectObject:injectObject
                               aspectOption:AspectPositionBefore];
        }
    }
}

#pragma mark - private method

- (void)aspect_injectMethodParams:(NSDictionary *)methodParams
                      fromeObject:(NSObject *)fromObject
                     injectObject:(id<ZFAnalyticsInjectProtocol>)injectObject
                     aspectOption:(AspectOptions)options
{
    NSArray *injectMethodAllKeys = [methodParams allKeys];
    
    for (int i = 0; i < [injectMethodAllKeys count]; i++) {
        NSString *key = injectMethodAllKeys[i];
        SEL targetSel = NSSelectorFromString(key);
        SEL injectSel = NSSelectorFromString(methodParams[key]);
        //目标类是否有实现该方法
        if ([fromObject.class instancesRespondToSelector:targetSel]) {
            if (targetSel) {
                if (injectSel) {
                    [self aspect_hookSelect:targetSel
                                    options:options
                                fromeObject:fromObject
                               injectObject:injectObject
                                  injectSel:injectSel];
                }
            }
        }else{
            if ([NSStringFromSelector(targetSel) isEqualToString:@"collectionView:willDisplayCell:forItemAtIndexPath:"] ||
                [NSStringFromSelector(targetSel) isEqualToString:@"tableView:willDisplayCell:forRowAtIndexPath:"]) {
                //如果hoc的方法未找到，且又是我们自己需要hoc的方法，手动添加到目标类，并hoc
                Method targetMethod = class_getInstanceMethod(fromObject.class, targetSel);
                if (!targetMethod) {
                    targetMethod = class_getInstanceMethod(self.class, targetSel);
                }
                BOOL addSuccess = [fromObject class_addMethod:fromObject.class
                                                     selector:targetSel
                                                          imp:method_getImplementation(targetMethod)
                                                        types:method_getTypeEncoding(targetMethod)];
                if (addSuccess) {
                    YWLog(@"add method success");
                    [self aspect_hookSelect:targetSel
                                    options:options
                                fromeObject:fromObject
                               injectObject:injectObject
                                  injectSel:injectSel];
                }
            }
        }
    }
}


- (void)aspect_hookSelect:(SEL)selector
                  options:(AspectOptions)options
              fromeObject:(NSObject *)fromObject
             injectObject:(id<ZFAnalyticsInjectProtocol>)injectObject
                injectSel:(SEL)injectSel
{
    [fromObject aspect_hookSelector:selector withOptions:options usingBlock:^(id<AspectInfo>info){
        NSInvocation *afterinvocation = [NSInvocation invocationWithMethodSignature:info.originalInvocation.methodSignature];
        [afterinvocation setTarget:injectObject];
        [afterinvocation setSelector:injectSel];
        [info.arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger index = idx + 2;
            
            //参数为nil时，这里改成NULL了，需要重新置回nil
            if ([obj isKindOfClass:[NSNull class]]) {
                obj = nil;
            }
            [self setInv:afterinvocation Sig:info.originalInvocation.methodSignature Obj:obj Index:index];
        }];
        [afterinvocation argumentsRetained];
        [afterinvocation invoke];
    } error:nil];
}

- (void)setInv:(NSInvocation *)inv Sig:(NSMethodSignature *)sig Obj:(id)obj Index:(NSInteger)index{
    
    if (sig.numberOfArguments <= index) return;
    
    char *type = (char *)[sig getArgumentTypeAtIndex:index];
    
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type++; // cutoff useless prefix
    }
    
    BOOL unsupportedType = NO;
    
    switch (*type) {
        case 'v': // 1: void
        case 'B': // 1: bool
        case 'c': // 1: char / BOOL
        case 'C': // 1: unsigned char
        case 's': // 2: short
        case 'S': // 2: unsigned short
        case 'i': // 4: int / NSInteger(32bit)
        case 'I': // 4: unsigned int / NSUInteger(32bit)
        case 'l': // 4: long(32bit)
        case 'L': // 4: unsigned long(32bit)
        { // 'char' and 'short' will be promoted to 'int'.
            int value = [obj intValue];
            [inv setArgument:&value atIndex:index];
        } break;
            
        case 'q': // 8: long long / long(64bit) / NSInteger(64bit)
        case 'Q': // 8: unsigned long long / unsigned long(64bit) / NSUInteger(64bit)
        {
            long long value = [obj longLongValue];
            [inv setArgument:&value atIndex:index];
        } break;
            
        case 'f': // 4: float / CGFloat(32bit)
        { // 'float' will be promoted to 'double'.
            double value = [obj doubleValue];
            float valuef = value;
            [inv setArgument:&valuef atIndex:index];
        } break;
            
        case 'd': // 8: double / CGFloat(64bit)
        {
            double value = [obj doubleValue];
            [inv setArgument:&value atIndex:index];
        } break;
            
        case '*': // char *
        case '^': // pointer
        {
            if ([obj isKindOfClass:UIColor.class]) obj = (id)[obj CGColor]; //CGColor转换
            if ([obj isKindOfClass:UIImage.class]) obj = (id)[obj CGImage]; //CGImage转换
            void *value = (__bridge void *)obj;
            [inv setArgument:&value atIndex:index];
        } break;
            
        case '@': // id
        {
            id value = obj;
            [inv setArgument:&value atIndex:index];
        } break;
            
        case '{': // struct
        {
            if (strcmp(type, @encode(CGPoint)) == 0) {
                CGPoint value = [obj CGPointValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CGSize)) == 0) {
                CGSize value = [obj CGSizeValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CGRect)) == 0) {
                CGRect value = [obj CGRectValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CGVector)) == 0) {
                CGVector value = [obj CGVectorValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                CGAffineTransform value = [obj CGAffineTransformValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                CATransform3D value = [obj CATransform3DValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(NSRange)) == 0) {
                NSRange value = [obj rangeValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(UIOffset)) == 0) {
                UIOffset value = [obj UIOffsetValue];
                [inv setArgument:&value atIndex:index];
            } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
                UIEdgeInsets value = [obj UIEdgeInsetsValue];
                [inv setArgument:&value atIndex:index];
            } else {
                unsupportedType = YES;
            }
        } break;
            
        case '(': // union
        {
            unsupportedType = YES;
        } break;
            
        case '[': // array
        {
            unsupportedType = YES;
        } break;
            
        default: // what?!
        {
            unsupportedType = YES;
        } break;
    }
    
    NSAssert(unsupportedType == NO, @"方法的参数类型暂不支持");
}

#pragma mark - hoc method

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    //hoc method, _cmd
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //hoc method, _cmd
}

@end
