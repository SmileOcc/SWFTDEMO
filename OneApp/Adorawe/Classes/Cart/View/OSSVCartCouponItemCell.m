//
//  OSSVCartCouponItemCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartCouponItemCell.h"
#import "OSSVMyCouponsListsModel.h"
//#import "RadioButton.h"

@interface OSSVCartCouponItemCell ()

@property (nonatomic, strong) UIView                 *lineView;
/** 渐变图层 */
@property (nonatomic, strong) CAGradientLayer        *gradientLayer;
/** 折线图层 */
@property (nonatomic, strong) CAShapeLayer           *lineChartLayer;


@property (nonatomic, assign) CGFloat               startY;// 圆角起始y的值
@property (nonatomic, assign) CGFloat               viewCaroid;// 圆角起始y的值

@property (nonatomic, strong) CAShapeLayer          *borderlayer;

/** 底部背景图*/
@property (nonatomic, strong) UIView                    *bottomView;
/** Coupon直减价格*/
@property (nonatomic, strong) UILabel                   *couponPrice;
/** Coupon码*/
@property (nonatomic, strong) UILabel                   *couponCode;
/** Coupon优惠信息*/
@property (nonatomic, strong) UILabel                   *couponSave;
/** Coupon有效期*/
@property (nonatomic, strong) UILabel                   *couponCalidity;
/** Coupon状态*/
@property (nonatomic, strong) UILabel                   *couponState;
/** Coupon App专享*/
@property (nonatomic, strong) UILabel                   *couponEx;
/** Coupon允许哪类商品可用*/
@property (nonatomic, strong) UILabel                   *couponAllow;

@property (nonatomic, strong) UILabel                *otherConditionAllow; // Coupon允许其他可用

@property (nonatomic, strong) UIImageView            *selectMarkImageView;

@property (nonatomic, strong) NSDateFormatter        *dateFormatter;


@end

@implementation OSSVCartCouponItemCell

+(OSSVCartCouponItemCell*)CartCouponsCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[OSSVCartCouponItemCell class] forCellReuseIdentifier:NSStringFromClass(OSSVCartCouponItemCell.class)];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVCartCouponItemCell.class) forIndexPath:indexPath];
}

+ (CGFloat)mainViewHeight {
    CGFloat space = SCREEN_WIDTH <= 375.0 ? 10 : 0;
    CGFloat width = SCREEN_WIDTH - 24;
    CGFloat height = width / 351.0 * 138.0;
    return height + space;
}
+ (CGFloat)contentHeigth {
    return [OSSVCartCouponItemCell mainViewHeight] + 10;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        
        CGFloat height = [OSSVCartCouponItemCell mainViewHeight];

        [self.contentView addSubview:self.bottomView];
        [self.contentView addSubview:self.couponPrice];
        [self.contentView addSubview:self.couponCode];
        [self.contentView addSubview:self.couponSave];
        [self.contentView addSubview:self.couponAllow];
        [self.contentView addSubview:self.otherConditionAllow];
        [self.contentView addSubview:self.couponCalidity];
        [self.contentView addSubview:self.couponState];
        [self.contentView addSubview:self.couponEx];
        [self.bottomView addSubview:self.selectMarkImageView];

        
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(12);
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(10);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH - 24, height));
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
        
        [self.couponPrice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bottomView.mas_top).mas_offset(12);
            make.width.mas_lessThanOrEqualTo(150 * DSCREEN_WIDTH_SCALE);
            make.leading.mas_equalTo(self.bottomView.mas_leading).mas_offset(14);
            make.height.mas_greaterThanOrEqualTo(29);
        }];
        
        [self.couponEx mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.couponPrice.mas_centerY);
            make.height.equalTo(14);
            make.leading.mas_equalTo(self.couponPrice.mas_trailing).mas_offset(6);
        }];
       
        [self.couponState mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(14);
            make.centerY.mas_equalTo(self.couponPrice.mas_centerY);
            make.leading.mas_equalTo(self.couponEx.mas_trailing).mas_offset(8);
        }];
        
        [self.couponSave mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.couponPrice.mas_bottom).mas_offset(2);
            make.leading.mas_equalTo(self.couponPrice.mas_leading);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-14);
        }];
        
        [self.couponAllow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.couponSave.mas_bottom).mas_offset(6);
            make.leading.mas_equalTo(self.couponSave.mas_leading);
            make.trailing.mas_equalTo(self.bottomView.mas_trailing).mas_offset(-14);
        }];
        
        [self.otherConditionAllow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.couponAllow.mas_bottom).offset(4);
            make.leading.mas_equalTo(self.couponSave.mas_leading);
            make.trailing.mas_equalTo(self.bottomView.mas_trailing).mas_offset(-14);
        }];
        
        [self.couponCode mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.bottomView.mas_bottom);
            make.leading.mas_equalTo(self.bottomView.mas_leading).mas_offset(14);
            make.trailing.mas_equalTo(self.bottomView.mas_centerX).mas_offset(40);
            make.height.mas_equalTo(33);
        }];
        
        [self.couponCalidity mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.couponCode.mas_centerY);
            make.trailing.mas_equalTo(self.bottomView.mas_trailing).mas_offset(-14);
        }];
        
        [self.selectMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bottomView).offset(1);
            make.trailing.mas_equalTo(self.bottomView).offset(-1);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
        self.startY = height - 27 - 12;
        self.viewCaroid = 6;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.couponPrice.text = nil;
    self.couponSave.text = nil;
    self.couponCode.text = nil;
    self.couponCalidity.text = nil;
    self.couponEx.text = nil;
    self.couponState.text = nil;
    self.couponAllow.text = nil;
    self.otherConditionAllow.text = nil;

}

#pragma mark -

- (void)setModel:(OSSVMyCouponsListsModel *)model index:(NSInteger)index {
#if DEBUG
    //    model.coupon_title = @"over $24- $44,over $24- $44,over $24- $44,over $24- $44,over $24- $44,over $24- $44,";
    //    model.condition = @"什么条件下可以使用，什么条件下可以使用";
    //    model.coupon_desc = @"cod 或 包邮券提示，cod 或 包邮券提示";
    //    model.couponCode = @"优惠券code 码 123456 jdaajfidjaifjdi jfdija 123 3424 12321 4343 32121321 32132131 321321";
    //    model.showFlag = 2;
    //    model.use_type = @"3";
    //    model.isOnlyApp = NO;
    //选中
    //    model.isSelected = YES;
    //过期、失效
    //    model.flag = @"expired";
#endif
    
    
    _model = model;
    
    self.selectMarkImageView.hidden = YES;
    self.couponSave.text = STLToString(model.coupon_title);
    self.couponPrice.text = STLToString(model.coupon_sub);
   
    self.couponEx.text = @"";
    self.otherConditionAllow.text = @"";
    self.couponState.text = @"";

    if (model.isOnlyApp) {
        self.couponEx.text = [NSString stringWithFormat:@"  %@  ",STLLocalizedString_(@"appOnly", nil).uppercaseString];
    }
    
    //1 之前显示new
    CGFloat stateExLeft = 0;
    if (model.showFlag == 1) {
        self.couponState.text = [NSString stringWithFormat:@"  %@  ",STLLocalizedString_(@"new", nil).uppercaseString];
        
    } else if(model.showFlag == 2) {
        self.couponState.text = [NSString stringWithFormat:@"  %@  ",STLLocalizedString_(@"expiredSoon", nil).uppercaseString];
    }
    
    if (model.showFlag == 1 || model.showFlag == 2) {
        if (![OSSVNSStringTool isEmptyString:self.couponEx.text]) {
            stateExLeft = 8;
        }
        [self.couponState mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.couponEx.mas_trailing).mas_offset(stateExLeft);
        }];
    }
    
    
    self.couponAllow.text = model.condition;
    self.couponCode.text = [NSString stringWithFormat:@"%@:%@",STLLocalizedString_(@"CODE", nil),STLToString(model.couponCode)];
    
    if ([STLToString(model.use_type) integerValue] == 2 || [STLToString(model.use_type) integerValue] == 3) {
        self.otherConditionAllow.text = model.coupon_desc;
    }
    

    NSDate *starTime = [NSDate dateWithTimeIntervalSince1970:[model.startTime integerValue]];
    NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:[model.endTime integerValue]];
    NSString *starString = [self.dateFormatter stringFromDate:starTime];
    NSString *endString = [self.dateFormatter stringFromDate:endTime];
    
    self.couponCalidity.text = [NSString stringWithFormat:@"%@ ~ %@",starString,endString];
    
    [self addlayerWithView:self.bottomView withStokeColor:OSSVThemesColors.col_0D0D0D  lineColor:@"#FFFFFF"];

    self.borderlayer.strokeColor = OSSVThemesColors.col_FBE9E9.CGColor;
    self.borderlayer.lineWidth = 1;
    
    if (model.isSelected) {
        self.borderlayer.strokeColor = [OSSVThemesColors col_0D0D0D].CGColor;
        self.borderlayer.lineWidth = 1;
        self.selectMarkImageView.hidden = NO;
    }
    
    self.borderlayer.strokeColor = model.isSelected ? [OSSVThemesColors col_0D0D0D].CGColor : OSSVThemesColors.col_FBE9E9.CGColor;
    self.selectMarkImageView.hidden = !model.isSelected;
    [self.bottomView bringSubviewToFront:self.selectMarkImageView];
    
//    RadioButton *choiceBtn = [[RadioButton alloc] initWithGroupId:@"Coupon" index:index
//                                                      normalImage:nil
//                                                    selectedImage:nil
//                                                            frame:CGRectMake(0, 0, SCREEN_WIDTH -20, 100 * DSCREEN_WIDTH_SCALE)
//                                                             type:BackgroundImage isOptional:YES];
//    [self.bottomView addSubview:choiceBtn];
//    
//    [choiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(self.bottomView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
//    }];
}
#pragma mark - LazyLoad

/**
 *  优化的角度出发：
 NSDateFormatter 初始化非常耗时，当有多个的时候尽量复用
 */
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_dateFormatter setDateFormat:@"dd-MM-YYYY"];
        }else{
            [_dateFormatter setDateFormat:@"YYYY-MM-dd"];
        }
        
    }
    return _dateFormatter;
}


- (UIView *)bottomView {
    if (!_bottomView) {
        CGFloat width = SCREEN_WIDTH - 24;
        CGFloat height = [OSSVCartCouponItemCell mainViewHeight];
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, width, height)];
        _bottomView.backgroundColor = [OSSVThemesColors stlClearColor];
        _bottomView.layer.masksToBounds = YES;
        _bottomView.layer.cornerRadius = 6;
    }
    return _bottomView;
}

- (UILabel *)couponPrice {
    if (!_couponPrice) {
        _couponPrice = [[UILabel alloc] init];
        _couponPrice.numberOfLines = 1;
        _couponPrice.textColor = [OSSVThemesColors col_B62B21];
        _couponPrice.font = [UIFont boldSystemFontOfSize:24];
        _couponPrice.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _couponPrice.textAlignment = NSTextAlignmentRight;
        }
    }
    return _couponPrice;
}

- (UILabel *)couponCode {
    if (!_couponCode) {
        _couponCode = [[UILabel alloc] init];
        _couponCode.font = [UIFont systemFontOfSize:10];
        _couponCode.textColor = [OSSVThemesColors col_6C6C6C];
        _couponCode.numberOfLines = 2;
        _couponCode.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _couponCode.textAlignment = NSTextAlignmentRight;
        }
    }
    return _couponCode;
}

- (UILabel *)couponSave {
    if (!_couponSave) {
        _couponSave = [[UILabel alloc] init];
        _couponSave.font = [UIFont boldSystemFontOfSize:12];
        _couponSave.numberOfLines = 2;
        
        _couponSave.textColor = [OSSVThemesColors col_B62B21];
        _couponSave.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _couponSave.textAlignment = NSTextAlignmentRight;
        }
    }
    return _couponSave;
}

- (UILabel *)couponAllow {
    if (!_couponAllow) {
        _couponAllow = [[UILabel alloc] init];
        _couponAllow.numberOfLines = 1;
        _couponAllow.font = [UIFont systemFontOfSize:10];
        _couponAllow.textColor = [OSSVThemesColors col_6C6C6C];
        
        _couponAllow.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _couponAllow.textAlignment = NSTextAlignmentRight;
        }
    }
    return _couponAllow;
}

- (UILabel *)otherConditionAllow {
    if (!_otherConditionAllow) {
        _otherConditionAllow = [[UILabel alloc] init];
        _otherConditionAllow.numberOfLines = 1;
        _otherConditionAllow.font = [UIFont systemFontOfSize:10];
        _otherConditionAllow.textColor = [OSSVThemesColors col_6C6C6C];
        
        _otherConditionAllow.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _otherConditionAllow.textAlignment = NSTextAlignmentRight;
        }
    }
    return _otherConditionAllow;
}


- (UILabel *)couponCalidity {
    if (!_couponCalidity) {
        _couponCalidity = [[UILabel alloc] init];
        _couponCalidity.textColor = [OSSVThemesColors col_6C6C6C];
        _couponCalidity.font = [UIFont systemFontOfSize:10];
        
        _couponCalidity.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _couponCalidity.textAlignment = NSTextAlignmentRight;
        }
    }
    return _couponCalidity;
}

- (UILabel *)couponState {
    if (!_couponState) {
        _couponState = [[UILabel alloc] init];
        _couponState.font = [UIFont boldSystemFontOfSize:10];
        _couponState.textColor = [OSSVThemesColors col_B62B21];
        _couponState.backgroundColor = [OSSVThemesColors col_FBE9E9];
    }
    return _couponState;
}

- (UILabel *)couponEx {
    if (!_couponEx) {
        _couponEx = [[UILabel alloc] init];
        _couponEx.font = [UIFont boldSystemFontOfSize:10];
        _couponEx.textColor = [OSSVThemesColors col_B62B21];
        _couponEx.backgroundColor = [OSSVThemesColors col_FBE9E9];
    }
    return _couponEx;
}

- (UIImageView *)selectMarkImageView {
    if (!_selectMarkImageView) {
        _selectMarkImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _selectMarkImageView.image = [UIImage imageNamed:[OSSVSystemsConfigsUtils isRightToLeftShow] ? @"coupon_select_left" :  @"coupon_select"];
        _selectMarkImageView.hidden = YES;
    }
    return _selectMarkImageView;
}

/// 绘制控件
/// @param view 对哪个控件进行绘制
/// @param stokeColor 边框的颜色
/// @param fromColor 渐变初始颜色
/// @param toColor 渐变最终颜色
/// @param lineColor 虚线的颜色
 - (void)addlayerWithView:(UIView *)view withStokeColor:(UIColor *)stokeColor lineColor:(NSString *)lineColor{
     //缺角固定半径6
     
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapSquare;
    path.lineJoinStyle = kCGLineJoinRound;
     
    
    [path moveToPoint:CGPointMake(1, self.viewCaroid+1)];
    [path addArcWithCenter:CGPointMake(self.viewCaroid+1, self.viewCaroid+1) radius:self.viewCaroid startAngle:M_PI endAngle:1.5 * M_PI clockwise:YES];
     
    [path addLineToPoint:CGPointMake(view.bounds.size.width-self.viewCaroid-1, 1)];
    [path addArcWithCenter:CGPointMake(view.bounds.size.width-self.viewCaroid-1, self.viewCaroid+1) radius:self.viewCaroid startAngle:1.5 * M_PI endAngle:2.0 * M_PI clockwise:YES];

     //半圆
    [path addLineToPoint:CGPointMake(view.bounds.size.width-1, self.startY-1)];
    [path addArcWithCenter:CGPointMake(view.bounds.size.width-1, self.startY+6) radius:6 startAngle:1.5*M_PI endAngle:0.5*M_PI clockwise:NO];
     
    [path addLineToPoint:CGPointMake(view.bounds.size.width-1, view.bounds.size.height - 6-1)];
    [path addArcWithCenter:CGPointMake(view.bounds.size.width - self.viewCaroid-1, view.bounds.size.height - 6-1) radius:self.viewCaroid startAngle:0 endAngle:0.5 * M_PI clockwise:YES];

    [path addLineToPoint:CGPointMake(6 + 1, view.bounds.size.height-1)];
    [path addArcWithCenter:CGPointMake(6 + 1, view.bounds.size.height - 6-1) radius:self.viewCaroid startAngle:0.5 * M_PI endAngle:M_PI clockwise:YES];
     
     //半圆
    [path addLineToPoint:CGPointMake(1, self.startY + 2*6)];
    [path addArcWithCenter:CGPointMake(1, self.startY+6) radius:6 startAngle:0.5*M_PI endAngle:1.5*M_PI clockwise:NO];
     
    [path addLineToPoint:CGPointMake(1, 6-1)];
     [path stroke];

    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = view.bounds;
    layer.path = path.CGPath;
//    layer.lineWidth = 1;
    layer.strokeColor = [UIColor clearColor].CGColor;
//    layer.fillColor = [UIColor orangeColor].CGColor;



     if (!self.gradientLayer) {
         CAGradientLayer *jianBianLayer = [self setGradualChangingColor:self.bottomView];
         jianBianLayer.mask = layer;
         self.gradientLayer = jianBianLayer;
         [self.bottomView.layer addSublayer: jianBianLayer];
     }
     

     if (!self.borderlayer) {

         CAShapeLayer *borderlayer = [[CAShapeLayer alloc] init];
         borderlayer.frame = view.bounds;
         borderlayer.path = path.CGPath;
         borderlayer.lineWidth = 1;
         borderlayer.strokeColor = stokeColor.CGColor;
         borderlayer.fillColor = [UIColor clearColor].CGColor;
         
         self.borderlayer = borderlayer;
         [self.bottomView.layer addSublayer: borderlayer];
     }

    [self drawLineOfDashByCAShapeLayer:self.bottomView lineLength:5 lineSpacing:2 lineColor:[UIColor colorWithHexString:lineColor]];
     
     
}



- (void)gradBackColor {
    
    CGFloat width = SCREEN_WIDTH - 24;
    CGFloat height = [OSSVCartCouponItemCell mainViewHeight];
    
    CGSize size = CGSizeMake(width, height);
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGPoint startPoint = CGPointZero;
//    if (direction == IHGradientChangeDirectionDownDiagonalLine) {
//        startPoint = CGPointMake(0.0, 1.0);
//    }
    gradientLayer.startPoint = startPoint;
    
    CGPoint endPoint = CGPointZero;
    endPoint = CGPointMake(0.0, 1.0);
    gradientLayer.endPoint = endPoint;
    

    gradientLayer.colors =@[(__bridge id)[UIColor colorWithHexString:@"#FFF1F1"].CGColor,(__bridge id)[UIColor colorWithHexString:@"#FFF5F5"].CGColor,(__bridge id)OSSVThemesColors.col_FBE9E9.CGColor];
    UIGraphicsBeginImageContext(size);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.bottomView.backgroundColor = [UIColor colorWithPatternImage:image];
}

- (NSArray *)gradinetColorsArray {
    return @[(__bridge id)OSSVThemesColors.col_F5F5F5.CGColor,(__bridge id)[UIColor colorWithHexString:@"#FBE4E4"].CGColor];
}

//绘制渐变色颜色的方法
- (CAGradientLayer *)setGradualChangingColor:(UIView *)view{

//    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    
    //  创建渐变色数组，需要转换为CGColor颜色
//    gradientLayer.colors = @[(__bridge id)[UIColor colorWithHexString:@"#FFF1F1"].CGColor,(__bridge id)[UIColor colorWithHexString:@"#FFF5F5"].CGColor,(__bridge id)[UIColor colorWithHexString:@"#FBE9E9"].CGColor];

    gradientLayer.colors = [self gradinetColorsArray];

    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);

    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0,@1];

    return gradientLayer;
}


/**
 *  通过 CAShapeLayer 方式绘制虚线
 *
 *  param lineView:       需要绘制成虚线的view
 *  param lineLength:     虚线的宽度
 *  param lineSpacing:    虚线的间距
 *  param lineColor:      虚线的颜色
 **/
- (void)drawLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor{

    if (!self.lineChartLayer) {
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [shapeLayer setBounds:lineView.bounds];
        [shapeLayer setPosition:CGPointMake(lineView.bounds.size.width / 2.0,       lineView.bounds.size.height/2.0)];
        //    //设置虚线颜色
        [shapeLayer setStrokeColor:lineColor.CGColor];
        //设置虚线宽度
        [shapeLayer setLineWidth:1];
        [shapeLayer setLineJoin:kCALineJoinRound];
        //设置虚线的线宽及间距
        [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
        //创建虚线绘制路径
        CGMutablePathRef path = CGPathCreateMutable();
        //设置虚线绘制路径起点
        CGPathMoveToPoint(path, NULL, 6+2, self.startY + 6);
        //设置虚线绘制路径终点
        CGPathAddLineToPoint(path, NULL, lineView.bounds.size.width - 6-2, self.startY + 6);
        //设置虚线绘制路径
        [shapeLayer setPath:path];
        CGPathRelease(path);
        //添加虚线
        [lineView.layer addSublayer:shapeLayer];
        self.lineChartLayer = shapeLayer;
    } else {
        
    }
}

@end
