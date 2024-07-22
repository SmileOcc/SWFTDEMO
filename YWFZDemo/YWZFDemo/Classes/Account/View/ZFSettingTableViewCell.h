//
//  ZFSettingTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2019/6/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//
//  通用Cell (title, detailTitle, arrowImage)

#import <UIKit/UIKit.h>

@interface ZFSettingTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImage *iconImage;

@property (nonatomic, copy )  NSString *title;
@property (nonatomic, strong) NSAttributedString *attributedTitle;

@property (nonatomic, copy )  NSString *detailTitle;
@property (nonatomic, strong) UIColor *detailTextColor;//default ColorHex_Alpha(0x999999, 1.0)
@property (nonatomic, strong) NSAttributedString *attributedDetailTitle;

@property (nonatomic, strong) UIImage *arrowImage;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, assign) BOOL hideBottomLine;

@property (nonatomic, strong) UIColor *detailBackgroundColor;//default white color

- (void)setDetailTitleHidden:(BOOL)hidden;

@end
