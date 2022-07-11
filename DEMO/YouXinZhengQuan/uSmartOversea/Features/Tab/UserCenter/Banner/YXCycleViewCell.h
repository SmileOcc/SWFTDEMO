//
//  YXCycleViewCell.h
//  uSmartOversea
//
//  Created by JC_Mac on 2018/11/14.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXCycleViewCell : UICollectionViewCell

@property (weak, nonatomic) UIImageView *imageView;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *lable;

@property (copy, nonatomic) NSAttributedString *attributeTitle;

@property (nonatomic, strong) UIColor *titleLabelTextColor;
@property (nonatomic, strong) UIFont *titleLabelTextFont;
@property (nonatomic, strong) UIColor *titleLabelBackgroundColor;
@property (nonatomic, assign) CGFloat titleLabelHeight;
@property (nonatomic, assign) NSTextAlignment titleLabelTextAlignment;
@property (nonatomic, assign) CGFloat lineSpacing;

@property (nonatomic, assign) BOOL hasConfigured;

/** 只展示文字轮播 */
@property (nonatomic, assign) BOOL onlyDisplayText;

/** 在只展示文字轮播的情況下 + 圖片， 配合onlyDisplayText一起使用*/
@property (nonatomic, assign) BOOL onlyDisplayTextWithImage;

/** 是否展示title黑色背景色 */
@property (nonatomic, assign) BOOL showBackView;

@end

NS_ASSUME_NONNULL_END
