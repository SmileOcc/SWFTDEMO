//
//  OSSVOrdereCodeConfirmView.m
// XStarlinkProject
//
//  Created by odd on 2020/10/20.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVOrdereCodeConfirmView.h"
#import "STLTextField.h"

@interface OSSVOrdereCodeConfirmView ()

@property (nonatomic, strong) UIView         *container;
@property (nonatomic, strong) UIView         *headerView;
@property (nonatomic, strong) UIButton       *closeBtn;
@property (nonatomic, strong) UILabel        *title;
@property (nonatomic, strong) UILabel        *cotentTip;
@property (nonatomic, strong) STLTextField   *phoneTextField;
@property (nonatomic, strong) UIButton       *confirmBtn;

@property (nonatomic, copy) NSString         *titleMsg;
@property (nonatomic, copy) NSString         *phoneMsg;
@end

@implementation OSSVOrdereCodeConfirmView

- (instancetype)initWithFrame:(CGRect)frame titleMsg:(NSString *)titleMsg phoneMsg:(NSString *)phoneMsg{
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.titleMsg = STLToString(titleMsg);
        self.phoneMsg = STLToString(phoneMsg);
        [self initViewWithFrame:frame];
    }
    return self;
}

- (void)initViewWithFrame:(CGRect)frame {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
    _container = [[UIView alloc] init];
    _container.backgroundColor = [OSSVThemesColors stlWhiteColor];
    _container.layer.cornerRadius = 4.0;
    _container.clipsToBounds = YES;
    [self addSubview:_container];
    
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).mas_offset(38);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-38);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    

    self.headerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.headerView.backgroundColor = [OSSVThemesColors col_F5F5F5];
    [_container addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.container);
        make.height.mas_equalTo(81);
    }];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_closeBtn setImage:[UIImage imageNamed:@"detail_close"] forState:UIControlStateNormal];
    [_container addSubview:_closeBtn];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_container.mas_top).mas_offset(12);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-12);
        make.width.height.mas_equalTo(24);
    }];
    
    
    NSString *paymentAmount = STLLocalizedString_(@"PaymentAmount", nil);
    NSString *tips = STLToString(self.titleMsg);
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:13];
    
    NSString *titleDesc = [NSString stringWithFormat:@"%@:%@",paymentAmount,tips];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc] initWithString:titleDesc];
    NSRange tipsRange = [titleDesc rangeOfString:tips];
    [attriString addAttributes:@{NSForegroundColorAttributeName : [OSSVThemesColors col_FF624F]} range:tipsRange];
    
    _title = [[UILabel alloc] init];
    _title.textColor = [OSSVThemesColors col_0D0D0D];
    _title.font = [UIFont boldSystemFontOfSize:18];
    _title.textAlignment = NSTextAlignmentCenter;
    _title.attributedText = attriString;
    
    [_container addSubview:_title];
    
    [_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.headerView);
        make.bottom.mas_equalTo(self.headerView.mas_bottom).offset(-13);
    }];
        

    _cotentTip = [[UILabel alloc] init];
    _cotentTip.numberOfLines = 0;
    _cotentTip.textColor = [OSSVThemesColors col_0D0D0D];
    _cotentTip.font = [UIFont systemFontOfSize:15];
    _cotentTip.text = STLLocalizedString_(@"Order_code_seconds_confirm_tip", nil);
    
    [_container addSubview:_cotentTip];
    
    [_cotentTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).mas_offset(24);
        make.centerX.mas_equalTo(_container.mas_centerX);
        make.leading.mas_equalTo(_container.mas_leading).mas_offset(24);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-24);
    }];
    
    self.phoneTextField = [[STLTextField alloc] initLeftPadding:12 rightPadding:12];
    self.phoneTextField.backgroundColor = [OSSVThemesColors col_F5F5F5];
    self.phoneTextField.layer.cornerRadius = 2.0;
    self.phoneTextField.layer.masksToBounds = YES;
    self.phoneTextField.textColor = [OSSVThemesColors col_999999];
    self.phoneTextField.font = [UIFont systemFontOfSize:17];
    self.phoneTextField.text = STLToString(self.phoneMsg);
    self.phoneTextField.enabled = NO;
    self.phoneTextField.textAlignment = NSTextAlignmentLeft;

    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.phoneTextField.textAlignment = NSTextAlignmentRight;
    }
    
    [self.container addSubview:self.phoneTextField];
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cotentTip.mas_bottom).offset(24);
        make.leading.mas_equalTo(self.container.mas_leading).offset(24);
        make.trailing.mas_equalTo(self.container.mas_trailing).offset(-24);
        make.height.mas_equalTo(44);
    }];
    
    _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _confirmBtn.layer.cornerRadius = 2.0;
    _confirmBtn.layer.masksToBounds = YES;
    if (APP_TYPE == 3) {
        [_confirmBtn setTitle:STLLocalizedString_(@"confirm", @"confirm") forState:UIControlStateNormal];

    } else {
        [_confirmBtn setTitle:[STLLocalizedString_(@"confirm", @"confirm") uppercaseString] forState:UIControlStateNormal];
    }
    [_confirmBtn addTarget:self action:@selector(actionConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [_confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [_confirmBtn setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
    _confirmBtn.backgroundColor = [OSSVThemesColors col_0D0D0D];
    [_container addSubview:_confirmBtn];
    
    [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.phoneTextField.mas_bottom).mas_offset(24);
        make.leading.mas_equalTo(_container.mas_leading).mas_offset(24);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-24);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(_container.mas_bottom).offset(-24);
    }];
    
}

- (void)actionConfirm:(UIButton *)button {
    
    if (self.confirmRequestBlock) {
        self.confirmRequestBlock();
    }
}
- (void)show{
    if (!self.superview) {
        [WINDOW addSubview:self];
    }
    self.hidden = NO;
    self.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
        [self.container mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
        }];
    }];
    
    
    [[OSSVAnalyticPagesManager sharedManager] pageStartTime:NSStringFromClass(OSSVOrdereCodeConfirmView.class)];
}


- (void)dismiss {


    NSString *startTime = [[OSSVAnalyticPagesManager sharedManager] startPageTime:NSStringFromClass(OSSVOrdereCodeConfirmView.class)];
    NSString *endTime = [[OSSVAnalyticPagesManager sharedManager] endPageTime:NSStringFromClass(OSSVOrdereCodeConfirmView.class)];

    NSString *timeLeng = [[OSSVAnalyticPagesManager sharedManager] pageEndTimeLength:NSStringFromClass(OSSVOrdereCodeConfirmView.class)];
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"key_page_load" parameters:@{@"$screen_name":[UIViewController currentTopViewControllerPageName],
                                                                              @"$referrer":[UIViewController lastViewControllerPageName],
                                                                              @"$title":STLToString(self.viewController.title),
                                                                                @"$url":STLToString(@""),
                                                                                @"load_begin":startTime,
                                                                                @"load_end":endTime,
                                                                              @"load_time":timeLeng}];
    
    CGRect contentFrame = self.container.frame;
    contentFrame.origin.y = SCREEN_HEIGHT;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.5;
         [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = YES;
        if (self.superview) {
            [self removeFromSuperview];
        }
    }];

}


-(void)dealloc {

}

@end
