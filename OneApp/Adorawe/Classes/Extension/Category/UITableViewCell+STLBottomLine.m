//
//  UITableViewCell+STLBottomLine.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "UITableViewCell+STLBottomLine.h"

#define LineTag 10101011

@implementation UITableViewCell (STLBottomLine)

-(void)addBottomLine:(CellSeparatorStyle)style;
{
    [self addBottomLine:style inset:14];
}

-(void)addBottomLine:(CellSeparatorStyle)style inset:(CGFloat)inset
{
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = OSSVThemesColors.col_F1F1F1;
    line.tag = LineTag;
    [self.contentView addSubview:line];
    
    switch (style) {
        case CellSeparatorStyle_Full:{
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView);
                make.leading.mas_equalTo(self.contentView);
                make.trailing.mas_equalTo(self.contentView);
                make.height.mas_offset(.5);
            }];
        }
            break;
        case CellSeparatorStyle_LeftInset:{
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView);
                make.leading.mas_equalTo(self.contentView).mas_offset(inset);
                make.trailing.mas_equalTo(self.contentView);
                make.height.mas_offset(.5);
            }];
        }
            break;
        case CellSeparatorStyle_LeftRightInset:{
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView);
                make.leading.mas_equalTo(self.contentView).mas_offset(inset);
                make.trailing.mas_equalTo(self.contentView).offset(-inset);
                make.height.mas_offset(.5);
            }];
        }
            break;
        default:
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.contentView);
                make.leading.mas_equalTo(self.contentView);
                make.trailing.mas_equalTo(self.contentView);
                make.height.mas_offset(.5);
            }];
            break;
    }
}

-(void)isHiddenBottomLine:(BOOL)hidden
{
    UIView *line = [self viewWithTag:LineTag];
    if (line) {
        line.hidden = hidden;
    }
}

-(void)addContentViewTap:(SEL)selector
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    [self.contentView addGestureRecognizer:tap];
}

@end
