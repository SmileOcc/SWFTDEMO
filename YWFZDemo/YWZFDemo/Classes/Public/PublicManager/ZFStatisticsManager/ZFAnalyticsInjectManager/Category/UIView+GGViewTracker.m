//
//  UIView+GGViewTracker.m
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "UIView+GGViewTracker.h"
#import <objc/runtime.h>

@implementation UIView (GGViewTracker)

static const char *dataCollectionControlName = "controlName";
static const char *dataCollectionMinorControlName = "minorControlName";
static const char *dataCollectionArgs = "dataCollectionArgs";
static const char *dataCollectionCommitType = "commitType";

#pragma mark - Setter And Getters
- (void)setControlName:(NSString *)controlName
{
    if ([controlName isKindOfClass:[NSString class]]) {
        objc_setAssociatedObject(self, dataCollectionControlName, controlName, OBJC_ASSOCIATION_RETAIN);
    }
}
- (NSString *)controlName
{
    return objc_getAssociatedObject(self, dataCollectionControlName);
}

- (void)setMinorControlName:(NSString *)minorControlName
{
    if ([minorControlName isKindOfClass:[NSString class]]) {
        objc_setAssociatedObject(self, dataCollectionMinorControlName, minorControlName, OBJC_ASSOCIATION_RETAIN);
    }
}

- (NSString *)minorControlName
{
    return objc_getAssociatedObject(self, dataCollectionMinorControlName);
}
- (void)setArgs:(NSDictionary *)args
{
    if ([args isKindOfClass:[NSDictionary class]]) {
        objc_setAssociatedObject(self, dataCollectionArgs, args, OBJC_ASSOCIATION_RETAIN);
    }
}

- (NSDictionary *)args
{
    return objc_getAssociatedObject(self, dataCollectionArgs);
}

- (ECommitType)commitType
{
    return [objc_getAssociatedObject(self, dataCollectionCommitType) unsignedIntegerValue];
}

- (void)setCommitType:(ECommitType)type
{
    objc_setAssociatedObject(self, dataCollectionCommitType, @(type), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
