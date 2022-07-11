//
//  UITableViewCell+STLBottomLine.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger) {
    CellSeparatorStyle_Full,
    CellSeparatorStyle_LeftInset,
    CellSeparatorStyle_LeftRightInset
}CellSeparatorStyle;

@interface UITableViewCell (STLBottomLine)

-(void)addBottomLine:(CellSeparatorStyle)style;

-(void)addBottomLine:(CellSeparatorStyle)style inset:(CGFloat)inset;

-(void)isHiddenBottomLine:(BOOL)hidden;

-(void)addContentViewTap:(SEL)selector;

@end
