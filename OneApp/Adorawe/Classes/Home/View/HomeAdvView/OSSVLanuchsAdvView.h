//
//  LanuchAdvView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^LanuchAdvViewBlock)(OSSVAdvsEventsModel *OSSVAdvsEventsModel);

@interface OSSVLanuchsAdvView : UIView

- (instancetype)initWithFrame:(CGRect)frame advModel:(OSSVAdvsEventsModel *)OSSVAdvsEventsModel image:(UIImage *)advImg;

@property (nonatomic, copy) LanuchAdvViewBlock  advDoActionBlock;

@property (nonatomic, copy) void (^skipBlock)(void);

@property (nonatomic, strong) YYAnimatedImageView      *advertImgView;

@property (nonatomic, strong) UIButton         *btn;

@property (nonatomic, strong) UILabel          *skipLab;

@property (nonatomic, strong) UILabel          *timeLab;



@end
