//
//  OSSVSortItemsView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVSortItemsView : UIControl

@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UIImageView   *arrowImageView;
@property (nonatomic, assign) BOOL          selectState;
//标识高亮
- (void)showMark:(BOOL)mark;

@end
