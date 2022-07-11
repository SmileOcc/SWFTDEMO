    //
//  OSSVCategoryRefinesColorsCCell.m
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategoryRefinesColorsCCell.h"
#import "UIColor+STLColorChange.h"

@implementation OSSVCategoryRefinesColorsCCell
@synthesize model = _model;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self stlInitView];
        [self stlAutoLayoutView];
    }
    return self;
}

- (void)stlInitView {
    self.colorView.backgroundColor = STLRandomColor();
    [self.mainView addSubview:self.colorView];
    [self.mainView addSubview:self.colorTitleLabel];
    [self.mainView addSubview:self.closeImageView];
}

- (void)stlAutoLayoutView {
    
    
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mainView.mas_centerY);
        make.leading.mas_equalTo(self.mainView.mas_leading).offset(12);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    
    [self.colorTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.colorView.mas_trailing).offset(2);
        make.centerY.mas_equalTo(self.mainView.mas_centerY);
        make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-10);

    }];
    
    [self.closeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-4);
        make.centerY.mas_equalTo(self.mainView.mas_centerY);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(12);
    }];
    
    // 设置抗压缩优先级
    [self.colorView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.colorView setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.colorTitleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.colorTitleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

}

//- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//
//    // 获得每个cell的属性集
//    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
//    // 计算cell里面textfield的宽度
//    CGRect frame = [self.colorTitleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 28) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.colorTitleLabel.font,NSFontAttributeName, nil] context:nil];
//
//    // 如果内容宽度 大于显示cell的宽度，显示会卡死
//    CGFloat maxW = 150;
//    if (self.superview) {
//        CGFloat suprW = CGRectGetWidth(self.superview.frame);
//        if (suprW > maxW) {
//            maxW = suprW - 24;
//        }
//    }
//
//    // 这里在本身宽度的基础上 又增加了10
//    frame.size.width += 12 * 2 + 14;
//
//    if (frame.size.width >= maxW) {
//        frame.size.width = maxW;
//    }
//
//    frame.size.height = 28;
//
//    // 重新赋值给属性集
//    attributes.frame = frame;
//
//    return attributes;
//}

+ (CGSize)contentSize:(NSString *)title maxWidt:(CGFloat)maxWidth isSelect:(BOOL)isSelect{
    if (STLIsEmptyString(title)) {
        title = @"";
    }
    CGRect frame = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 28) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:11],NSFontAttributeName, nil] context:nil];
    
    // 如果内容宽度 大于显示cell的宽度，显示会卡死
    CGFloat maxW = 150;
    if (maxWidth > maxW) {
        maxW = maxWidth - 24;
    }

    // 这里在本身宽度的基础上 又增加了10
//    if (isSelect) {
//        frame.size.width += 8 + 12 + 8 + 12;
//    } else {
        frame.size.width += 12 + 12 + 12 + 6;
//    }
    
    if (frame.size.width >= maxW) {
        frame.size.width = maxW;
    }
    
    if (frame.size.width <= 44) {
        frame.size.width = 44;
    }
    
    frame.size.height = 28;

    return frame.size;
}

- (void)setModel:(STLCategoryFilterValueModel *)model {
    _model = model;
    
    self.colorView.backgroundColor = [STLThemeColor stlWhiteColor];
    self.colorTitleLabel.text = STLToString(model.editName);
    [self hightLightState:model.tempSelected];
    
    NSString *colorString = STLToString(model.expand_value.hex);
    if (STLIsEmptyString(colorString)) {
        colorString = @"#ffffff";
    }
    
    NSArray *subLayers = self.colorView.layer.sublayers;
    for (CAGradientLayer *borderLayer in subLayers) {
        [borderLayer removeFromSuperlayer];
    }
    
    self.closeImageView.hidden = YES;
    if (model.tempSelected) {
        self.closeImageView.hidden = NO;
        [self.colorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mainView.mas_leading).offset(8);
        }];
        [self.colorTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-16);
        }];
    } else {
        [self.colorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mainView.mas_leading).offset(12);
        }];
        [self.colorTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-12);
        }];
    }
    
    NSArray *colors = [colorString componentsSeparatedByString:@","];
    if (colors.count > 1) {
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.colorView.bounds;
        //  创建渐变色数组，需要转换为CGColor颜色
        gradientLayer.colors = [self gradientColors:colors];
        //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
        gradientLayer.cornerRadius=2;
        //  设置颜色变化点，取值范围 0.0~1.0
        
        CGFloat average = 1.0 / (colors.count + 1);
        NSMutableArray *locations = [[NSMutableArray alloc] init];
        for (int i=0; i<colors.count; i++) {
            [locations addObject:@((i+1) * average)];
        }
        gradientLayer.locations = locations;
        [self.colorView.layer addSublayer:gradientLayer];
        
    } else {
        
        NSArray *colorArrays = [colorString componentsSeparatedByString:@"#"];
        if (colorArrays.count > 1) {
            NSString *colorStr = colorArrays[1];
            UIColor *color = [UIColor colorWithHexString:colorStr];
            self.colorView.backgroundColor = color;
        }
    }

}

- (NSArray *)gradientColors:(NSArray *)colors {
    NSInteger maxCount = colors.count > 3 ? 3 : colors.count;
    NSMutableArray *gradColors = [[NSMutableArray alloc] initWithCapacity:maxCount];
    for (int i=0; i<maxCount; i++) {
        NSString *subColor = colors[i];
        
        NSArray *colorArrays = [subColor componentsSeparatedByString:@"#"];
        if (colorArrays.count > 1) {
            NSString *colorStr = colorArrays[1];
            UIColor *color = [UIColor colorWithHexString:colorStr];
            [gradColors addObject:(__bridge id)color.CGColor];
        }
    }
    return gradColors;
}
#pragma mark - Property Method


- (STLColorView *)colorView {
    if (!_colorView) {
        _colorView = [[STLColorView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        _colorView.layer.cornerRadius = 6.0;
        _colorView.layer.masksToBounds = YES;
        _colorView.layer.borderWidth = 0.5;
        _colorView.layer.borderColor = [STLThemeColor col_EEEEEE].CGColor;
    }
    return _colorView;
}

- (UILabel *)colorTitleLabel {
    if (!_colorTitleLabel) {
        _colorTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _colorTitleLabel.textColor = [STLThemeColor col_666666];
        _colorTitleLabel.font = [UIFont systemFontOfSize:11];
        _colorTitleLabel.textAlignment = NSTextAlignmentCenter;

    }
    return _colorTitleLabel;
}

- (UIImageView *)closeImageView {
    if (!_closeImageView) {
        _closeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _closeImageView.image = [UIImage imageNamed:@"filter_close_gray"];
        _closeImageView.hidden = YES;
    }
    return _closeImageView;
}
@end


@implementation STLColorView

//- (void)drawRect:(CGRect)rect {
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//
//        //创建一个RGB的颜色空间
//        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
//        //定义渐变颜色数组
//        CGFloat colors[] =
//        {
//            204.0 / 255.0, 224.0 / 255.0, 244.0 / 255.0, 1.00,
//            29.0 / 255.0, 156.0 / 255.0, 215.0 / 255.0, 1.00,
//            0.0 / 255.0,  50.0 / 255.0, 126.0 / 255.0, 1.00,
//        };
//
//    NSArray *colorss = [NSArray arrayWithObjects:(id)[UIColor yellowColor].CGColor,(id)[UIColor orangeColor].CGColor, nil];
//
//    CGFloat locations[2];
//    locations[0] = 0.2;
//    locations[1] = 0.7;
//        //创建一个渐变的色值 1:颜色空间 2:渐变的色数组 3:位置数组,如果为NULL,则为平均渐变,否则颜色和位置一一对应 4:位置的个数
////        CGGradientRef _gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
//    CGGradientRef _gradient = CGGradientCreateWithColors(rgb, (CFArrayRef)colorss, locations);
//        CGColorSpaceRelease(rgb);
//
//        //获得一个CGRect
//        CGRect clip = CGRectInset(CGContextGetClipBoundingBox(ctx), 14, 14);
//        //剪切到合适的大小
//        CGContextClipToRect(ctx, clip);
//        //定义起始点和终止点
//        CGPoint start = CGPointMake(0, 0);
//        CGPoint end = CGPointMake(7, 7);
//        //绘制渐变, 颜色的0对应start点,颜色的1对应end点,第四个参数是定义渐变是否超越起始点和终止点
////        CGContextDrawLinearGradient(ctx, _gradient, start, end, kCGGradientDrawsBeforeStartLocation);
//
//        //辐射渐变
//        start = CGPointMake(0, 0);//起始点
//        end = CGPointMake(7, 7); //终结点
//        //辐射渐变 start:起始点 20:起始点的半径 end:终止点 40: 终止点的半径 这个辐射渐变
//        CGContextDrawRadialGradient(ctx, _gradient, start, 7, end, 7, 0);
//}
@end
