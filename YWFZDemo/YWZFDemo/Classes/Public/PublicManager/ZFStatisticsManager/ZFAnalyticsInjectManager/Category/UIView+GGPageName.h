//
//  UIView+GGPageName.h
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (GGPageName)

- (void)resetPageName;
- (NSString*)pageName;

/**
 * The view controller whose view contains this view.
 */
- (UIViewController*)ownerViewController;


@end

#pragma mark - debug funtions
#ifdef DEBUG
@interface UIView (EnumViews)
// Start the tree recursion at level 0 with the root view
- (NSString *) displayViews: (UIView *) aView;

// Recursively travel down the view tree, increasing the indentation level for children
- (void)dumpView:(UIView *)aView atIndent:(int)indent into:(NSMutableString *)outstring;
@end
#endif
