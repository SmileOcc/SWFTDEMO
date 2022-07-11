//
//  YXStockPickerResultCell.h
//  uSmartOversea
//
//  Created by youxin on 2020/9/4.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXTableViewCell.h"
NS_ASSUME_NONNULL_BEGIN
@class YXStockPickerList;
@interface YXStockPickerResultCell : YXTableViewCell

@property (nonatomic, strong) YXStockPickerList *model;

@property (nonatomic, strong) UIImageView *marketIconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *symbolLabel;
@property (nonatomic, strong) UILabel *delayLabel;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *sortTypes;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL checked;

@property (nonatomic, copy) void (^selectItemBlock)(BOOL isSelected);
@end

NS_ASSUME_NONNULL_END
