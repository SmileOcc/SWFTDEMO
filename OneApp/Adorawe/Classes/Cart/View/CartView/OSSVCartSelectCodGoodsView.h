//
//  OSSVCartSelectCodGoodsView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/16.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVCartSelectCodGoodsView : UIView

@property (nonatomic, strong) UILabel                  *codTitleLabel;
@property (nonatomic, strong) UIButton                 *eventButton;
@property (nonatomic, strong) YYAnimatedImageView      *rightArrow; // 右边箭头
@property (nonatomic, strong) UIView                   *horizontalLine; // 横线

@property (nonatomic, copy) void (^operateBlock)();


- (void)setHtmlTitle:(NSString *)htmlTitles specialUrl:(NSString *)url;
@end
