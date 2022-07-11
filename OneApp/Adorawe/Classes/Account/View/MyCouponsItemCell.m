//
//  OSSVMysCouponItemsCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMysCouponItemsCell.h"
#import "OSSVMyCouponsListsModel.h"

@interface OSSVMysCouponItemsCell ()

@property (nonatomic, strong) UIView                 *lineView;
/** 渐变图层 */
@property (nonatomic, strong) CAGradientLayer        *gradientLayer;
/** 折线图层 */
@property (nonatomic, strong) CAShapeLayer           *lineChartLayer;

/** 圆角起始y的值 */
@property (nonatomic, assign) CGFloat               startY;
/** 圆角起始y的值 */
@property (nonatomic, assign) CGFloat               viewCaroid;

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
/** Coupon允许其他可用*/
@property (nonatomic, strong) UILabel                *otherConditionAllow;

@property (nonatomic, strong) UIImageView            *selectMarkImageView;

@property (nonatomic, strong) NSDateFormatter        *dateFormatter;

@property (nonatomic, assign) CGFloat                moveLineX;

@property (nonatomic, strong) UIView                *leftColorView;
@property (nonatomic, strong) UIView                *leftCircleView;
@property (nonatomic, strong) UIView                *vSelectlayerView;

@property (nonatomic, strong) UILabel               *couponTipLabel;

@end

@implementation OSSVMysCouponItemsCell

+(OSSVMysCouponItemsCell*)myCouponsCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[OSSVMysCouponItemsCell class] forCellReuseIdentifier:NSStringFromClass(OSSVMysCouponItemsCell.class)];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVMysCouponItemsCell.class) forIndexPath:indexPath];
}

+ (CGFloat)mainViewHeight:(OSSVMyCouponsListsModel *)model {
    CGFloat space = SCREEN_WIDTH <= 375.0 ? 10 : 0;
    CGFloat width = SCREEN_WIDTH - 24;
    CGFloat height = width / 351.0 * 138.0;
    
    if (APP_TYPE == 3) {
        if (model && !STLIsEmptyString(model.type_notes)) {
            height = height + 24 + 6;
        }
    }
    
    return height + space - 5;
}
+ (CGFloat)contentHeigth:(OSSVMyCouponsListsModel *)model {
    return [OSSVMysCouponItemsCell mainViewHeight:model] + 10;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.contentView.backgroundColor = [STLThemeColor col_F5F5F5];
        self.moveLineX = 0.5;
        
        [self.contentView addSubview:self.bottomView];
        [self.contentView addSubview:self.leftColorView];
        [self.leftColorView addSubview:self.leftCircleView];
        [self.contentView addSubview:self.couponPrice];
        [self.contentView addSubview:self.couponCode];
        [self.contentView addSubview:self.couponSave];
        [self.contentView addSubview:self.couponAllow];
        [self.contentView addSubview:self.couponTipLabel];
        [self.contentView addSubview:self.otherConditionAllow];
        [self.contentView addSubview:self.couponCalidity];
        [self.contentView addSubview:self.couponState];
        [self.contentView addSubview:self.couponEx];
        [self.contentView addSubview:self.vSelectlayerView];
        if (APP_TYPE == 3) {
            [self.vSelectlayerView addSubview:self.selectMarkImageView];
        } else {
            [self.bottomView addSubview:self.selectMarkImageView];
        }
        
        if (APP_TYPE == 3) {
            self.leftColorView.hidden = NO;
            self.leftCircleView.hidden = NO;
            self.vSelectlayerView.hidden = NO;
            [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(12);
                make.top.mas_equalTo(self.contentView.mas_top).mas_offset(10);
                make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
                make.bottom.mas_equalTo(self.contentView.mas_bottom);
            }];
            
            [self.leftColorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.top.bottom.mas_equalTo(self.bottomView);
                make.width.mas_equalTo(30);
            }];
            
            [self.leftCircleView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.leftColorView.mas_leading);
                make.centerY.mas_equalTo(self.leftColorView.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(12, 12));
            }];
            
            [self.vSelectlayerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self.bottomView);
            }];
            
            [self.couponPrice mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.bottomView.mas_top).mas_offset(12);
                make.width.mas_lessThanOrEqualTo(150 * DSCREEN_WIDTH_SCALE);
                make.leading.mas_equalTo(self.bottomView.mas_leading).mas_offset(14+30);
                make.height.mas_equalTo(24);
            }];
            
            [self.couponEx mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.couponPrice.mas_top);
                make.leading.mas_equalTo(self.couponPrice.mas_trailing).mas_offset(6);
                make.height.mas_equalTo(14);
            }];
            
            [self.couponState mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.couponPrice.mas_top);
                make.leading.mas_equalTo(self.couponEx.mas_trailing).mas_offset(8);
                make.height.mas_equalTo(14);
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
            
            [self.couponTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.couponAllow.mas_bottom).mas_offset(0);
                make.leading.mas_equalTo(self.couponSave.mas_leading);
                make.trailing.mas_equalTo(self.bottomView.mas_trailing).mas_offset(-14);
                make.height.mas_equalTo(0);
            }];
            
            [self.otherConditionAllow mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.couponTipLabel.mas_bottom).offset(4);
                make.leading.mas_equalTo(self.couponSave.mas_leading);
                make.trailing.mas_equalTo(self.bottomView.mas_trailing).mas_offset(-14);
            }];

            [self.couponCode mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.bottomView.mas_bottom);
                make.leading.mas_equalTo(self.bottomView.mas_leading).mas_offset(14+30);
                make.trailing.mas_equalTo(self.bottomView.mas_centerX).mas_offset(40);
                make.height.mas_equalTo(33);
            }];
            
            
            [self.couponCalidity mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.couponCode.mas_centerY);
                make.trailing.mas_equalTo(self.bottomView.mas_trailing).mas_offset(-14);
            }];
            
            [self.selectMarkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.top.mas_equalTo(self.bottomView);
                make.size.mas_equalTo(CGSizeMake(24, 24));
            }];
            
            self.viewCaroid = 0;
            
        } else {
            
            CGFloat height = [OSSVMysCouponItemsCell mainViewHeight:nil];
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
                make.height.mas_equalTo(24);
            }];
            
            [self.couponEx mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.couponPrice.mas_centerY);
                make.leading.mas_equalTo(self.couponPrice.mas_trailing).mas_offset(6);
                make.height.mas_equalTo(14);
            }];
            
            [self.couponState mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.couponPrice.mas_centerY);
                make.leading.mas_equalTo(self.couponEx.mas_trailing).mas_offset(8);
                make.height.mas_equalTo(14);
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
                make.trailing.top.mas_equalTo(self.bottomView);
                make.size.mas_equalTo(CGSizeMake(24, 24));
            }];
            
            self.startY = height - 27 - 12;
            self.viewCaroid = 6;
        }
        
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.couponCalidity.text = nil;
    self.couponPrice.text = nil;
    self.couponSave.text = nil;
    self.couponCode.text = nil;
    self.couponEx.text = nil;
    self.couponState.text = nil;
    self.couponAllow.text = nil;
    self.otherConditionAllow.text = nil;
}

#pragma mark -

- (void)setModel:(OSSVMyCouponsListsModel *)model {
    
#if DEBUG
    //    model.coupon_title = @"over $24- $44,over $24- $44,over $24- $44,over $24- $44,over $24- $44,over $24- $44,";
//        model.condition = @"什么条件下可以使用，什么条件下可以使用";
//        model.coupon_desc = @"cod 或 包邮券提示，cod 或 包邮券提示";
//        model.couponCode = @"优惠券code 码 123456 ";
//        model.showFlag = 1;
//        model.use_type = @"3";
//        model.isOnlyApp = YES;
    //选中
//        model.isSelected = YES;
    //过期、失效
//        model.flag = @"expired";
    
#endif

    _model = model;
    
    self.couponTipLabel.hidden = YES;
    self.selectMarkImageView.hidden = YES;
    self.couponSave.text = STLToString(model.coupon_title);
    self.couponPrice.text = STLToString(model.coupon_sub);
   
    self.couponEx.text = @"";
    self.otherConditionAllow.text = @"";
    self.couponState.text = @"";

    if (model.isOnlyApp) {
        self.couponEx.text = [NSString stringWithFormat:@"  %@  ",STLLocalizedString_(@"appOnly", nil)];
    }
    
    //1 之前显示new
    CGFloat stateExLeft = 0;
    if (model.showFlag == 1) {
        self.couponState.text = [NSString stringWithFormat:@"  %@  ",STLLocalizedString_(@"new", nil).uppercaseString];
        
    } else if(model.showFlag == 2) {
        self.couponState.text = [NSString stringWithFormat:@"  %@  ",STLLocalizedString_(@"expiredSoon", nil)];
    }
    if (model.showFlag == 1 || model.showFlag == 2) {
        if (![NSStringTool isEmptyString:self.couponEx.text]) {
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
    
    if (APP_TYPE == 3) {
        
        CGFloat bottomH = [OSSVMysCouponItemsCell mainViewHeight:model];
        self.startY = bottomH / 2.0 - 6;
        if (model && !STLIsEmptyString(model.type_notes)) {
            self.couponTipLabel.hidden = NO;
            [self.couponTipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.couponAllow.mas_bottom).mas_offset(6);
                make.height.mas_equalTo(24);
            }];
        } else {
            [self.couponTipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.couponAllow.mas_bottom).mas_offset(0);
                make.height.mas_equalTo(0);
            }];
        }
        
        CGRect bottomFrame = self.bottomView.frame;
        bottomFrame.size.height =  bottomH;
        self.bottomView.frame = bottomFrame;
        [self addlayerWithView:self.bottomView withStokeColor:STLThemeColor.col_F5EEE9  lineColor:@"#FFFFFF"];
    } else {
        [self addlayerWithView:self.bottomView withStokeColor:STLThemeColor.col_0D0D0D  lineColor:@"#FFFFFF"];

    }
    
    self.leftColorView.backgroundColor = [STLThemeColor col_F5EEE9];
    if ([model.flag isEqualToString:@"expired"] || [model.flag isEqualToString:@"used"] || model.unAvailabel) {
            
        if (APP_TYPE == 3) {
            self.leftColorView.backgroundColor = [STLThemeColor col_C4C4C4];
            self.gradientLayer.backgroundColor = [STLThemeColor stlWhiteColor].CGColor;
            self.borderlayer.strokeColor = [STLThemeColor col_E1E1E1].CGColor;
            self.borderlayer.lineWidth = 1;

            self.couponSave.textColor = [STLThemeColor col_000000:0.5];
            self.couponPrice.textColor = [STLThemeColor col_000000:0.5];
            self.couponEx.textColor = [STLThemeColor col_000000:0.5];
            self.couponState.textColor = [STLThemeColor col_000000:0.5];
            self.couponCode.textColor = [STLThemeColor col_000000:0.5];
            self.couponCalidity.textColor = [STLThemeColor col_000000:0.5];
            self.otherConditionAllow.textColor = [STLThemeColor col_000000:0.5];
            self.couponAllow.textColor = [STLThemeColor col_000000:0.5];
            
            self.couponEx.backgroundColor = [STLThemeColor col_F8F8F8];
            self.couponState.backgroundColor = [STLThemeColor col_F8F8F8];

            if (!STLIsEmptyString(model.type_notes)) {
                NSString *msg = [NSString stringWithFormat:@" %@",STLToString(model.type_notes)];
                NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:msg];
                [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, msg.length)];
                NSTextAttachment *icon = [[NSTextAttachment alloc] init];
                UIImage *iconImage = [UIImage imageNamed:@"spic_coupon_tip_red"];
                iconImage = [iconImage imageWithColor:[STLThemeColor col_000000:0.5]];
                [icon setBounds:CGRectMake(0, roundf([UIFont systemFontOfSize:10].capHeight - iconImage.size.height)/2.f, iconImage.size.width, iconImage.size.height)];
                [icon setImage:iconImage];
                NSAttributedString *iconString = [NSAttributedString attributedStringWithAttachment:icon];
                [attrStr insertAttributedString:iconString atIndex:0];
                _couponTipLabel.attributedText = attrStr;
                _couponTipLabel.font = [UIFont systemFontOfSize:10];
                _couponTipLabel.numberOfLines = 2;
                _couponTipLabel.adjustsFontSizeToFitWidth = YES;
                _couponTipLabel.minimumScaleFactor = 0.9;
                _couponTipLabel.textColor = [STLThemeColor col_000000:0.5];
            }
            
        } else {
            self.borderlayer.strokeColor = [STLThemeColor col_EEEEEE].CGColor;
            self.borderlayer.lineWidth = 1;
            self.gradientLayer.colors =@[(__bridge id)STLThemeColor.col_FFFFFF.CGColor,(__bridge id)STLThemeColor.col_FFFFFF.CGColor];
            
            self.couponSave.textColor = [STLThemeColor col_B2B2B2];
            self.couponPrice.textColor = [STLThemeColor col_B2B2B2];
            self.couponEx.textColor = [STLThemeColor col_B2B2B2];
            self.couponState.textColor = [STLThemeColor col_B2B2B2];
            self.couponCode.textColor = [STLThemeColor col_B2B2B2];
            self.couponCalidity.textColor = [STLThemeColor col_B2B2B2];
            self.otherConditionAllow.textColor = [STLThemeColor col_B2B2B2];
            self.couponAllow.textColor = [STLThemeColor col_B2B2B2];
            
            self.couponEx.backgroundColor = [STLThemeColor col_F5F5F5];
            self.couponState.backgroundColor = [STLThemeColor col_F5F5F5];
        }
        
        
    } else {
        if (APP_TYPE == 3) {
            self.gradientLayer.backgroundColor = [STLThemeColor stlWhiteColor].CGColor;
            self.borderlayer.strokeColor = [STLThemeColor col_F5EEE9].CGColor;
            self.borderlayer.lineWidth = 1;

            self.couponPrice.textColor = [STLThemeColor col_9F5123];
            self.couponEx.textColor = [STLThemeColor col_9F5123];
            self.couponState.textColor = [STLThemeColor col_9F5123];
            
            self.couponSave.textColor = [STLThemeColor col_000000:0.7];
            self.couponCode.textColor = [STLThemeColor col_000000:0.7];
            self.couponCalidity.textColor = [STLThemeColor col_000000:0.7];
            self.otherConditionAllow.textColor = [STLThemeColor col_000000:0.7];
            self.couponAllow.textColor = [STLThemeColor col_000000:0.7];
            
            self.couponEx.backgroundColor = [STLThemeColor stlWhiteColor];
            self.couponState.backgroundColor = [STLThemeColor stlWhiteColor];
            
            if (!STLIsEmptyString(model.type_notes)) {
                NSString *msg = [NSString stringWithFormat:@" %@",STLToString(model.type_notes)];
                NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:msg];
                [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, msg.length)];
                NSTextAttachment *icon = [[NSTextAttachment alloc] init];
                UIImage *iconImage = [UIImage imageNamed:@"spic_coupon_tip_red"];
                [icon setBounds:CGRectMake(0, roundf([UIFont systemFontOfSize:10].capHeight - iconImage.size.height)/2.f, iconImage.size.width, iconImage.size.height)];
                [icon setImage:iconImage];
                NSAttributedString *iconString = [NSAttributedString attributedStringWithAttachment:icon];
                [attrStr insertAttributedString:iconString atIndex:0];
                _couponTipLabel.attributedText = attrStr;
                _couponTipLabel.font = [UIFont systemFontOfSize:10];
                _couponTipLabel.numberOfLines = 2;
                _couponTipLabel.adjustsFontSizeToFitWidth = YES;
                _couponTipLabel.minimumScaleFactor = 0.9;
                _couponTipLabel.textColor = [STLThemeColor col_E34E4E];
            }

            
        } else {
            
            self.gradientLayer.colors = [self gradinetColorsArray];
            self.borderlayer.strokeColor = [STLThemeColor col_FBE9E9].CGColor;
            self.borderlayer.lineWidth = 1;
            
            self.couponSave.textColor = [STLThemeColor col_B62B21];
            self.couponPrice.textColor = [STLThemeColor col_B62B21];
            self.couponEx.textColor = [STLThemeColor col_B62B21];
            self.couponState.textColor = [STLThemeColor col_B62B21];
            self.couponCode.textColor = [STLThemeColor col_6C6C6C];
            self.couponCalidity.textColor = [STLThemeColor col_6C6C6C];
            self.otherConditionAllow.textColor = [STLThemeColor col_6C6C6C];
            self.couponAllow.textColor = [STLThemeColor col_6C6C6C];
            
            self.couponEx.backgroundColor = [STLThemeColor col_FBE9E9];
            self.couponState.backgroundColor = [STLThemeColor col_FBE9E9];
        }

    }
    
    if (model.isSelected) {
        if (APP_TYPE == 3) {
            self.borderlayer.strokeColor = [STLThemeColor col_9F5123].CGColor;
        } else {
            self.borderlayer.strokeColor = [STLThemeColor col_0D0D0D].CGColor;
        }
        self.borderlayer.lineWidth = 1;
        self.selectMarkImageView.hidden = NO;
    }
    
    [self.bottomView bringSubviewToFront:self.selectMarkImageView];
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
        if ([SystemConfigUtils isRightToLeftShow]) {
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
        CGFloat height = [OSSVMysCouponItemsCell mainViewHeight:nil];
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, width, height)];
        _bottomView.backgroundColor = [STLThemeColor stlClearColor];
        if (APP_TYPE == 3) {
            
        } else {
            _bottomView.layer.masksToBounds = YES;
            _bottomView.layer.cornerRadius = 6;
        }
    }
    return _bottomView;
}

- (UILabel *)couponPrice {
    if (!_couponPrice) {
        _couponPrice = [[UILabel alloc] init];
        _couponPrice.numberOfLines = 1;
        _couponPrice.adjustsFontSizeToFitWidth = YES;
        _couponPrice.minimumScaleFactor = 0.5;
        _couponPrice.textColor = [STLThemeColor col_B62B21];
        _couponPrice.font = [UIFont boldSystemFontOfSize:20];

        _couponPrice.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        
        _couponPrice.textAlignment = NSTextAlignmentLeft;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _couponPrice.textAlignment = NSTextAlignmentRight;
        }
    }
    return _couponPrice;
}

- (UILabel *)couponCode {
    if (!_couponCode) {
        _couponCode = [[UILabel alloc] init];
        _couponCode.font = [UIFont systemFontOfSize:10];
        _couponCode.textColor = [STLThemeColor col_6C6C6C];
        _couponCode.numberOfLines = 2;
        _couponCode.textAlignment = NSTextAlignmentLeft;
        if ([SystemConfigUtils isRightToLeftShow]) {
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
        
        _couponSave.textColor = [STLThemeColor col_B62B21];
        _couponSave.textAlignment = NSTextAlignmentLeft;
        if ([SystemConfigUtils isRightToLeftShow]) {
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
        _couponAllow.textColor = [STLThemeColor col_6C6C6C];
        
        _couponAllow.textAlignment = NSTextAlignmentLeft;
        if ([SystemConfigUtils isRightToLeftShow]) {
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
        _otherConditionAllow.textColor = [STLThemeColor col_6C6C6C];
        
        _otherConditionAllow.textAlignment = NSTextAlignmentLeft;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _otherConditionAllow.textAlignment = NSTextAlignmentRight;
        }
    }
    return _otherConditionAllow;
}

- (UILabel *)couponCalidity {
    if (!_couponCalidity) {
        _couponCalidity = [[UILabel alloc] init];
        _couponCalidity.textColor = [STLThemeColor col_6C6C6C];
        _couponCalidity.font = [UIFont systemFontOfSize:10];
        
        _couponCalidity.textAlignment = NSTextAlignmentLeft;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _couponCalidity.textAlignment = NSTextAlignmentRight;
        }
    }
    return _couponCalidity;
}

- (UILabel *)couponState {
    if (!_couponState) {
        _couponState = [[UILabel alloc] init];
        _couponState.font = [UIFont boldSystemFontOfSize:10];
        _couponState.textColor = [STLThemeColor col_B62B21];
        _couponState.backgroundColor = [STLThemeColor col_FBE9E9];
        if (APP_TYPE == 3) {
            _couponState.layer.borderWidth = 1;
            _couponState.layer.borderColor = [STLThemeColor col_F5EEE9].CGColor;
        }
    }
    return _couponState;
}

- (UILabel *)couponEx {
    if (!_couponEx) {
        _couponEx = [[UILabel alloc] init];
        _couponEx.font = [UIFont boldSystemFontOfSize:10];
        _couponEx.textColor = [STLThemeColor col_B62B21];
        _couponEx.backgroundColor = [STLThemeColor col_FBE9E9];
        if (APP_TYPE == 3) {
            _couponEx.layer.borderWidth = 1;
            _couponEx.layer.borderColor = [STLThemeColor col_F5EEE9].CGColor;
        }

    }
    return _couponEx;
}

- (UIImageView *)selectMarkImageView {
    if (!_selectMarkImageView) {
        _selectMarkImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _selectMarkImageView.image = [UIImage imageNamed:[SystemConfigUtils isRightToLeftShow] ? @"coupon_select_left" :  @"coupon_select"];
        _selectMarkImageView.hidden = YES;
    }
    return _selectMarkImageView;
}

- (UIView *)leftColorView {
    if (!_leftColorView) {
        _leftColorView = [[UIView alloc] initWithFrame:CGRectZero];
        _leftColorView.hidden = YES;
        _leftColorView.backgroundColor = STLThemeColor.col_F5EEE9;
        _leftColorView.layer.masksToBounds = YES;
    }
    return _leftColorView;
}

- (UIView *)leftCircleView {
    if (!_leftCircleView) {
        _leftCircleView = [[UIView alloc] initWithFrame:CGRectZero];
        _leftCircleView.backgroundColor = [STLThemeColor col_F5F5F5];
        _leftCircleView.hidden = YES;
        _leftCircleView.layer.cornerRadius = 6;
        _leftCircleView.layer.masksToBounds = YES;
    }
    return _leftCircleView;
}

- (UIView *)vSelectlayerView {
    if (!_vSelectlayerView) {
        _vSelectlayerView = [[UIView alloc] initWithFrame:CGRectZero];
        _vSelectlayerView.backgroundColor = [STLThemeColor stlClearColor];
        _vSelectlayerView.hidden = YES;
    }
    return _vSelectlayerView;
}

- (UILabel *)couponTipLabel {
    if (!_couponTipLabel) {
        _couponTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _couponTipLabel.font = [UIFont systemFontOfSize:10];
        _couponTipLabel.hidden = YES;
        _couponTipLabel.textColor = [STLThemeColor col_E34E4E];
        
//        if (APP_TYPE == 3) {
//            NSString *msg = [NSString stringWithFormat:@" %@",STLLocalizedString_(@"fullCutAndFlashsaleTipNewV", nil)];
//            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:msg];
//            [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(0, msg.length)];
//            NSTextAttachment *icon = [[NSTextAttachment alloc] init];
//            UIImage *iconImage = [UIImage imageNamed:@"spic_coupon_tip_red"];
//            [icon setBounds:CGRectMake(0, roundf([UIFont systemFontOfSize:10].capHeight - iconImage.size.height)/2.f, iconImage.size.width, iconImage.size.height)];
//            [icon setImage:iconImage];
//            NSAttributedString *iconString = [NSAttributedString attributedStringWithAttachment:icon];
//            [attrStr insertAttributedString:iconString atIndex:0];
//            _couponTipLabel.attributedText = attrStr;
//        }
        _couponTipLabel.font = [UIFont systemFontOfSize:10];
        _couponTipLabel.numberOfLines = 2;
        _couponTipLabel.adjustsFontSizeToFitWidth = YES;
        _couponTipLabel.minimumScaleFactor = 0.9;
    }
    return _couponTipLabel;
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
     
     if (APP_TYPE == 3) {
         [path moveToPoint:CGPointMake(0+self.moveLineX, self.moveLineX)];
          
         [path addLineToPoint:CGPointMake(view.bounds.size.width- self.moveLineX, 0+self.moveLineX)];


         [path addLineToPoint:CGPointMake(view.bounds.size.width - self.moveLineX, self.startY - self.moveLineX)];
         [path addArcWithCenter:CGPointMake(view.bounds.size.width - self.moveLineX, self.startY+6) radius:6 startAngle:1.5*M_PI endAngle:0.5*M_PI clockwise:NO];

         [path addLineToPoint:CGPointMake(view.bounds.size.width - self.moveLineX, view.bounds.size.height - self.moveLineX)];

         [path addLineToPoint:CGPointMake(self.moveLineX, view.bounds.size.height-self.moveLineX)];

         [path addLineToPoint:CGPointMake(0+self.moveLineX, self.startY + 2*6)];
         [path addArcWithCenter:CGPointMake(0+self.moveLineX, self.startY+6) radius:6 startAngle:0.5*M_PI endAngle:1.5*M_PI clockwise:NO];

         [path addLineToPoint:CGPointMake(0+self.moveLineX, self.moveLineX)];
         [path stroke];
         
     } else {
         [path moveToPoint:CGPointMake(0+self.moveLineX, self.viewCaroid + self.moveLineX)];
         [path addArcWithCenter:CGPointMake(self.viewCaroid + self.moveLineX, self.viewCaroid + self.moveLineX) radius:self.viewCaroid startAngle:M_PI endAngle:1.5 * M_PI clockwise:YES];
          
         [path addLineToPoint:CGPointMake(view.bounds.size.width-self.viewCaroid - self.moveLineX, 0+self.moveLineX)];
         [path addArcWithCenter:CGPointMake(view.bounds.size.width-self.viewCaroid - self.moveLineX, self.viewCaroid + self.moveLineX) radius:self.viewCaroid startAngle:1.5 * M_PI endAngle:2.0 * M_PI clockwise:YES];

         [path addLineToPoint:CGPointMake(view.bounds.size.width - self.moveLineX, self.startY - self.moveLineX)];
         [path addArcWithCenter:CGPointMake(view.bounds.size.width - self.moveLineX, self.startY+6) radius:6 startAngle:1.5*M_PI endAngle:0.5*M_PI clockwise:NO];
          
         [path addLineToPoint:CGPointMake(view.bounds.size.width - self.moveLineX, view.bounds.size.height - 6 - self.moveLineX)];
         [path addArcWithCenter:CGPointMake(view.bounds.size.width - self.viewCaroid - self.moveLineX, view.bounds.size.height - 6 - self.moveLineX) radius:self.viewCaroid startAngle:0 endAngle:0.5 * M_PI clockwise:YES];

         [path addLineToPoint:CGPointMake(6+self.moveLineX, view.bounds.size.height-self.moveLineX)];
         [path addArcWithCenter:CGPointMake(6+self.moveLineX, view.bounds.size.height - 6 -self.moveLineX) radius:self.viewCaroid startAngle:0.5 * M_PI endAngle:M_PI clockwise:YES];
          
         [path addLineToPoint:CGPointMake(0+self.moveLineX, self.startY + 2*6)];
         [path addArcWithCenter:CGPointMake(0+self.moveLineX, self.startY+6) radius:6 startAngle:0.5*M_PI endAngle:1.5*M_PI clockwise:NO];
          
         [path addLineToPoint:CGPointMake(0+self.moveLineX, 6 - self.moveLineX)];
         [path stroke];
     }
    


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
         if (APP_TYPE == 3) {
             [self.vSelectlayerView.layer addSublayer: borderlayer];
         } else {
             [self.bottomView.layer addSublayer: borderlayer];
         }
     }

    [self drawLineOfDashByCAShapeLayer:self.bottomView lineLength:5 lineSpacing:4 lineColor:[UIColor colorWithHexString:lineColor]];
     
     
}

- (NSArray *)gradinetColorsArray {
    return @[(__bridge id)[UIColor colorWithHexString:@"#FFF5F5"].CGColor,(__bridge id)[UIColor colorWithHexString:@"#FBE4E4"].CGColor];
}

//绘制渐变色颜色的方法
- (CAGradientLayer *)setGradualChangingColor:(UIView *)view{

//    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = view.bounds;
    
    //  创建渐变色数组，需要转换为CGColor颜色
//    gradientLayer.colors = @[(__bridge id)[UIColor colorWithHexString:@"#FFF1F1"].CGColor,(__bridge id)[UIColor colorWithHexString:@"#FFF5F5"].CGColor,(__bridge id)[UIColor colorWithHexString:@"#FBE9E9"].CGColor];

    if (APP_TYPE == 3) {
        gradientLayer.backgroundColor = (__bridge CGColorRef _Nullable)([STLThemeColor stlWhiteColor]);
    } else {
        
        gradientLayer.colors = [self gradinetColorsArray];
        
        //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        
        //  设置颜色变化点，取值范围 0.0~1.0
        //    gradientLayer.locations = @[@0,@0.52,@1];
        
        gradientLayer.locations = @[@0,@1];
    }

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
        CGPathMoveToPoint(path, NULL, 6+6, self.startY + 6);
        //设置虚线绘制路径终点
        CGPathAddLineToPoint(path, NULL, lineView.bounds.size.width - 6 - 6, self.startY + 6);
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
