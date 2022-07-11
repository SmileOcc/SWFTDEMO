//
//  YXSecuNameLabel.h
//  uSmartOversea
//
//  Created by ellison on 2019/1/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXSecuNameLabel : UIView

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSAttributedString *attributedText;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) NSTextAlignment textAlignment;

@property (nonatomic, strong) UIFont *defaultFont;
@property (nonatomic, strong) UIFont *smallFont;
@property (nonatomic, strong, readonly) UIFont *font;
@property (nonatomic, assign) CGFloat preferredMaxLayoutWidth;

@end

NS_ASSUME_NONNULL_END
