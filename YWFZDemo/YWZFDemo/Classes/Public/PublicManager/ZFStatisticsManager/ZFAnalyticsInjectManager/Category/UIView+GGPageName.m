//
//  UIView+GGPageName.m
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "UIView+GGPageName.h"
#import <objc/runtime.h>

#import "GGViewTrackerManager.h"
#import "UIView+GGViewTracker.h"

static const char* kPageName = "pageName";

@implementation UIView (GGPageName)

- (void)resetPageName
{
    objc_setAssociatedObject(self, kPageName, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)pageName
{
    NSString *page = objc_getAssociatedObject(self, kPageName);
    if (!page) {
        page = [GGViewTrackerManager currentPageName];
        objc_setAssociatedObject(self, kPageName, page, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return page;
}

- (UIViewController*)ownerViewController {
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}
@end

#ifdef DEBUG
@implementation UIView (EnumViews)
// Start the tree recursion at level 0 with the root view
- (NSString *) displayViews: (UIView *) aView
{
    NSMutableString *outstring = [[NSMutableString alloc] init];
    [self dumpView: aView.window atIndent:0 into:outstring];
    return outstring;
}

// Recursively travel down the view tree, increasing the indentation level for children
- (void)dumpView:(UIView *)aView atIndent:(int)indent into:(NSMutableString *)outstring
{
    for (int i = 0; i < indent; i++) [outstring appendString:@"--"];
    [outstring appendFormat:@"[%2d] %@ (%@,%@)\n", indent, [[aView class] description], aView.controlName, aView.minorControlName];
    for (UIView *view in [aView subviews])
        [self dumpView:view atIndent:indent + 1 into:outstring];
}
@end
#endif
