//
//  ZFCommunityMenuView.h
//  ZZZZZ
//
//  Created by YW on 2018/9/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFMenuItem;
@interface ZFCommunityMenuView : UIView

- (instancetype)initWithFrame:(CGRect)frame menus:(NSArray<ZFMenuItem *> *) menus;

@property (nonatomic, copy) void (^menuSelectBlock)(ZFMenuItem *menuItem);

- (void)showView:(UIView *)superView startPoint:(CGPoint )point;
- (void)hideView;
@end




@interface ZFCommunityMenuTableCell : UITableViewCell

@property (nonatomic, strong) UIImageView      *imgView;
@property (nonatomic, strong) UILabel          *titleLab;
@property (nonatomic, strong) UIView           *lineView;

@end


@interface ZFMenuItem: NSObject

@property (nonatomic, strong) UIImage         *img;
@property (nonatomic, copy) NSString          *name;
@property (nonatomic, assign) NSInteger       index;
@end
