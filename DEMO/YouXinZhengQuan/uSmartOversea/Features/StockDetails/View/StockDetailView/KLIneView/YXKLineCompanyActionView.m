//
//  YXKLineCompanyActionView.m
//  YouXinZhengQuan
//
//  Created by youxin on 2021/3/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXKLineCompanyActionView.h"
#import "UILabel+create.h"
#import <Masonry/Masonry.h>
#import "YXKlineLongPressView.h"
#import "uSmartOversea-Swift.h"

@interface YXKLineCompanyActionView()

@property (nonatomic, assign) YXKlineScreenOrientType oritentType;

@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) QMUIButton *detailButton;

@end

@implementation YXKLineCompanyActionView

- (instancetype)initWithFrame:(CGRect)frame andType:(int)type {
    self = [super initWithFrame:frame];
    if (self) {
        self.oritentType = (YXKlineScreenOrientType)type;
        [self initUI];
    }
    return self;
}


- (void)initUI{

    self.backgroundColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.03];
    [self addSubview: self.contentLabel];
    [self addSubview: self.detailButton];
    [self addSubview: self.lineView];

    [self.contentLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    if (self.oritentType == YXKlineScreenOrientTypeRight) {

        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(10);
            make.centerY.equalTo(self.mas_centerY);
        }];

        [self.detailButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.left.equalTo(self.contentLabel.mas_right).offset(20);
            make.right.lessThanOrEqualTo(self).offset(-10);
        }];
    } else {

        [self.detailButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.mas_centerY);
            make.right.equalTo(self.mas_right).offset(-10);
        }];
        [self.detailButton sizeToFit];

        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(10);
            make.centerY.equalTo(self.mas_centerY);
            make.right.lessThanOrEqualTo(self.detailButton.mas_left).offset(-8);
        }];
    }

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(10);
        make.right.equalTo(self.mas_right).offset(-10);
        make.top.equalTo(self);
        make.height.mas_equalTo(1.0);
    }];


    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tap];
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tap {
    if (self.clickToDetailBlock) {

        self.clickToDetailBlock(self.events, self.dateString);
    }

    UIView *companyActionView = [[UIView alloc] init];
    companyActionView.backgroundColor = QMUITheme.foregroundColor;
    companyActionView.layer.cornerRadius = 10;
    companyActionView.layer.masksToBounds = YES;

    CGFloat height = 48 + 28 * self.events.count + 20 + (self.events.count > 1 ? 14 : 0) + 48;
    CGFloat width = 285;
    UILabel *titleLabel = [UILabel labelWithText:[YXLanguageUtility kLangWithKey:@"company_action"] textColor:QMUITheme.textColorLevel1 textFont:UIFont.normalFont16];
    [companyActionView addSubview:titleLabel];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(companyActionView);
        make.top.equalTo(companyActionView).offset(20);
        make.height.equalTo(@(22));
    }];

    UIView *preView = titleLabel;
    for (int i = 0; i < self.events.count; i ++) {
        YXKLineInsideEvent *event = self.events[i];
        NSString *typeString;
        if (event.type.value == 1) { //财报
            typeString = [YXLanguageUtility kLangWithKey:@"company_finance_report"];
        } else {
            typeString = [YXLanguageUtility kLangWithKey:@"company_equity_dividend"];
        }

        UILabel *typeLabel = [UILabel labelWithText:typeString textColor:QMUITheme.textColorLevel1 textFont:UIFont.mediumFont14];
        typeLabel.adjustsFontSizeToFitWidth = YES;
        typeLabel.minimumScaleFactor = 0.7;
        [typeLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [companyActionView addSubview:typeLabel];
        NSString *quarterTypeStr = @"";
        if (event.type.value == 1) {
            // 公司行动
            if (event.quarterType.length > 0) {
                quarterTypeStr = [NSString stringWithFormat:@"(%@)", event.quarterType];
            }
        }
        
        UILabel *dateLabel = [UILabel labelWithText:[NSString stringWithFormat:@"（%@%@）", quarterTypeStr, self.dateString] textColor:QMUITheme.textColorLevel1 textFont:UIFont.normalFont12];
        [companyActionView addSubview:dateLabel];

        UILabel *contextLabel = [UILabel labelWithText:event.context textColor:[QMUITheme.textColorLevel1 colorWithAlphaComponent:0.65] textFont:UIFont.normalFont14];
        contextLabel.numberOfLines = 0;
        [companyActionView addSubview:contextLabel];

        [typeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(preView.mas_bottom).offset(i == 0 ? 6 : 14);
            make.left.equalTo(companyActionView).offset(16);
            make.height.equalTo(@(22));
        }];

        [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(typeLabel);
            make.left.equalTo(typeLabel.mas_right).offset(4);
            make.right.lessThanOrEqualTo(companyActionView).offset(-12);
        }];

        [contextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(typeLabel.mas_bottom).offset(6);
            make.left.equalTo(companyActionView).offset(16);
            make.right.equalTo(companyActionView).offset(-16);
        }];

        height += [event.context boundingRectWithSize:CGSizeMake(width - 32, 500) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : UIFont.normalFont14} context:nil].size.height;

        preView = contextLabel;
    }

    companyActionView.frame = CGRectMake(0, 0, width, height);

    UIButton *confirmButton = [[UIButton alloc] init];
    [confirmButton setTitle:[YXLanguageUtility kLangWithKey:@"common_confirm2"] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = UIFont.normalFont16;
    [confirmButton setTitleColor:QMUITheme.themeTextColor forState:UIControlStateNormal];
    [companyActionView addSubview:confirmButton];
    [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(companyActionView);
        make.height.mas_equalTo(48);
    }];

    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = QMUITheme.separatorLineColor;
    [companyActionView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(companyActionView);
        make.height.mas_equalTo(1);
        make.top.equalTo(confirmButton);
    }];

    TYAlertController *alertController = [TYAlertController alertControllerWithAlertView:companyActionView preferredStyle:(TYAlertControllerStyleAlert)];

    alertController.backgoundTapDismissEnable = YES;
    [UIViewController.currentViewController presentViewController:alertController animated:YES completion:nil];


    @weakify(alertController)
    [[[confirmButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(alertController);
        [alertController dismissViewControllerAnimated:YES];
    }];
}

- (void)setEvents:(NSArray<YXKLineInsideEvent *> *)events {
    _events = events;
    NSMutableAttributedString *mutStr = [[NSMutableAttributedString alloc] init];

    for (int i = 0; i < events.count; i++) {
        [mutStr appendAttributedString:[self orderContextWithEvent:events[i] eventIndex:i]];
    }

    [_detailButton setTitle:@(events.count).stringValue forState:UIControlStateNormal];

    self.contentLabel.attributedText = mutStr;
}


- (NSMutableAttributedString *)orderContextWithEvent:(YXKLineInsideEvent * _Nullable)event eventIndex:(NSInteger)index {

    UIColor *color;
    NSString *typeString = @"";
    if (event.type.value == 1) {
        typeString = [YXLanguageUtility kLangWithKey:@"company_finance_report"];
        color = [UIColor qmui_colorWithHexString:@"#2F79FF"];
    } else {
        typeString = [YXLanguageUtility kLangWithKey:@"company_equity_dividend"];
        color = [UIColor qmui_colorWithHexString:@"#FFBF32"];
    }

    NSDictionary *textAttributes = @{NSFontAttributeName : UIFont.normalFont10, NSForegroundColorAttributeName : [QMUITheme textColorLevel1]};

    NSMutableAttributedString *mutStr = [[NSMutableAttributedString alloc] init];
    if (index > 0) {
        NSAttributedString *spaceAtt = [[NSAttributedString alloc] initWithString:@"      " attributes:textAttributes];
        [mutStr appendAttributedString:spaceAtt];
    }

    //圆点
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = [UIImage qmui_imageWithColor:color size:CGSizeMake(6, 6) cornerRadius:3];
    NSAttributedString *attachmentStr = [NSAttributedString attributedStringWithAttachment:attachment];
    attachment.bounds = CGRectMake(0, 0, 6, 6);
    [mutStr appendAttributedString:attachmentStr];

    //内容
    NSAttributedString *spaceStr = [[NSAttributedString alloc] initWithString:@"  " attributes:textAttributes];
    [mutStr appendAttributedString:spaceStr];

    NSAttributedString *contextStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", typeString, event.context] attributes:textAttributes];
    [mutStr appendAttributedString:contextStr];

    return mutStr;
}

#pragma mark - Lazy Loading

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [UILabel labelWithText:@"" textColor:[QMUITheme textColorLevel1] textFont:[UIFont normalFont10] textAlignment:(NSTextAlignmentLeft)];
        _contentLabel.adjustsFontSizeToFitWidth = YES;
        _contentLabel.minimumScaleFactor = 0.9;
    }
    return _contentLabel;
}

- (QMUIButton *)detailButton {
    if (!_detailButton) {
        _detailButton = [[QMUIButton alloc] init];
        [_detailButton setTitleColor:[QMUITheme textColorLevel1] forState:UIControlStateNormal];
        [_detailButton setTitle:@"" forState:UIControlStateNormal];
        [_detailButton setImage:[UIImage imageNamed:@"mine_arrow"] forState:UIControlStateNormal];
        _detailButton.imagePosition = QMUIButtonImagePositionRight;
        _detailButton.spacingBetweenImageAndTitle = 4;
        _detailButton.titleLabel.font = UIFont.normalFont10;
        _detailButton.userInteractionEnabled = NO;
    }
    return _detailButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [QMUITheme.textColorLevel1 colorWithAlphaComponent:0.05];
    }
    return _lineView;
}

@end
