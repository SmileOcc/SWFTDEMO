//
//  UITableView+initTools.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/16.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "UITableView+initTools.h"
#import <objc/runtime.h>

@implementation UITableView (initTools)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method oldMethod = class_getInstanceMethod([self class], @selector(initWithFrame:style:));
        Method newMethod = class_getInstanceMethod([self class], @selector(initWithToolsFrame:style:));
        method_exchangeImplementations(oldMethod, newMethod);
    });
}

-(UITableView *)initWithToolsFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [self initWithToolsFrame:frame style:style];
    
    if (self) {
        if (@available(iOS 11.0, *)) {
            self.estimatedRowHeight = 0;
            self.estimatedSectionFooterHeight = 0;
            self.estimatedSectionHeaderHeight = 0;
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

@end
