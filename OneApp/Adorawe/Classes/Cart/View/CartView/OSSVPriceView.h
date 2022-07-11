//
//  OSSVPriceView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVPriceView : UIView

- (instancetype)initWithFrame:(CGRect)frame font:(UIFont *)font textColor:(UIColor *)textColor;

@property (nonatomic, strong) UIFont     *font;
@property (nonatomic, strong) UIColor    *textColor;

@property (nonatomic, strong) UILabel    *descLabel;
@property (nonatomic, strong) UILabel    *priceLabel;

//如：total: ￥12
- (void)updateFirstDesc:(NSString *)desc secondPrice:(NSString *)price;

@end
