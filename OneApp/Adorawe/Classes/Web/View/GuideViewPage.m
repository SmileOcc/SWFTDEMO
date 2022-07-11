//
//  GuideViewPage.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import "GuideViewPage.h"

@implementation GuideViewPage

//重写setCurrentPage方法，可设置圆点大小

- (void) setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
    
    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
        UIImageView* subview = [self.subviews objectAtIndex:subviewIndex];
        CGSize size;
        size.height = 8;
        size.width = 8;
        subview.clipsToBounds = YES;
        subview.layer.cornerRadius = 4;
        [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y, size.width,size.height)];
    }
}

@end
