//
//  VerificationView.m
//  ZZZZZ
//
//  Created by DBP on 17/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "VerificationView.h"
#import "NSString+Extended.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface VerificationView () <UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UIButton      *closeBtn;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UILabel       *detailLabel;
@property (nonatomic, strong) UILabel       *phoneLabel;
@property (nonatomic, strong) UIButton      *senderBtn;
@property (nonatomic, strong) UIView        *middleLine;
@property (nonatomic, strong) UITextField   *codeField;
@property (nonatomic, strong) UILabel       *vreifyTipLabel;
@property (nonatomic, strong) UIButton      *vreifyBtn;
@property (nonatomic, strong) UILabel       *bottomLabel;
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation VerificationView

- (void)dealloc
{
    YWLog(@"VerificationView dealloc");
}

-(void)stopTimer
{
    if (self.timer) {
        dispatch_source_cancel(self.timer);
    }
    [self removeFromSuperview];
}

- (void)showTitle:(NSString *)title andCode:(NSString *)code andphoneNum:(NSString *)phoneNum
{
    if (!self.superview) {
        [[UIApplication sharedApplication].delegate.window addSubview:self];
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo([UIApplication sharedApplication].delegate.window).with.insets(UIEdgeInsetsZero);
        }];
    } else {
        self.hidden = !self.hidden;
    }
    // 设置号码
    self.titleLabel.text = ZFLocalizedString(@"VerificationView_titleLabel", nil);
    if([NSStringUtils isEmptyString:code]) {
        self.phoneLabel.text = [NSString stringWithFormat:@"%@",phoneNum];
    } else {
        self.phoneLabel.text = [NSString stringWithFormat:@"+%@ %@",code,phoneNum];
    }
    
    // 设置订单信息和价格
    [self setupDetailLabelText:title];
}

- (void)dismiss {
    self.hidden = YES;
//    [self removeFromSuperview];
}

#pragma mark - data
- (instancetype)init{
    if (self = [super initWithFrame:CGRectZero]) {
        self.backgroundColor = ZFCOLOR(0,0,0,0.6);
        
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

/**
 * 设置订单信息和价格
 */
- (void)setupDetailLabelText:(NSString *)orderPrice {
    NSString *daysText = ZFLocalizedString(@"COD_SMS_5-10WorkingDays", nil);
    NSString *tip1 = ZFLocalizedString(@"COD_SMS_Description1", nil);
    NSString *tip2 = [NSString stringWithFormat:@"%@ \n", ZFToString(daysText)];
    NSString *tip3 = ZFLocalizedString(@"COD_SMS_Description2", nil);
    NSString *tip4 = [NSString stringWithFormat:@"%@ \n", ZFToString(orderPrice)];
    NSString *tip5 = ZFLocalizedString(@"COD_SMS_Description3", nil);
    
    NSArray *colorArr = @[ZFCOLOR(153, 153, 153, 1),ZFC0xFE5269(),
                          ZFCOLOR(153, 153, 153, 1),ZFC0xFE5269(),
                          ZFCOLOR(153, 153, 153, 1)];
    NSArray *fontArr = @[ZFFontSystemSize(12),ZFFontBoldSize(12),
                         ZFFontSystemSize(12), ZFFontBoldSize(12),
                         ZFFontSystemSize(12)];
    
    NSTextAlignment textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.detailLabel.attributedText = [NSString getAttriStrByTextArray:@[tip1, tip2, tip3, tip4, tip5]
                                                               fontArr:fontArr
                                                              colorArr:colorArr
                                                           lineSpacing:1
                                                             alignment:textAlignment];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.closeBtn];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.senderBtn];
    [self.contentView addSubview:self.middleLine];
    [self.contentView addSubview:self.phoneLabel];
    [self.contentView addSubview:self.codeField];
    [self.contentView addSubview:self.vreifyTipLabel];
    [self.contentView addSubview:self.vreifyBtn];
    [self.contentView addSubview:self.bottomLabel];
}

- (void)zfAutoLayoutView {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(33);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-33);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-10);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.size.mas_equalTo(30);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(16);
        make.trailing.mas_equalTo(self.closeBtn.mas_leading);
        make.top.mas_equalTo(self.contentView.mas_top).offset(17);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(16);
    }];
    
    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView.mas_centerX);
        make.top.mas_equalTo(self.detailLabel.mas_bottom).offset(24);
    }];
    
    [self.senderBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.top.mas_equalTo(self.phoneLabel.mas_bottom).offset(16);
        make.height.mas_equalTo(44);
    }];
    
    [self.middleLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.senderBtn.mas_bottom).offset(16);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(1);
    }];
    
    [self.codeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.middleLine.mas_bottom).offset(16);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.height.mas_equalTo(44);
    }];
    
    [self.vreifyTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.codeField.mas_leading);
        make.trailing.mas_equalTo(self.codeField.mas_trailing);
        make.top.mas_equalTo(self.codeField.mas_bottom).offset(6);
        make.height.mas_equalTo(0);
    }];
    
    [self.vreifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.codeField);
        make.top.mas_equalTo(self.vreifyTipLabel.mas_bottom).offset(12);
        make.height.mas_equalTo(44);
    }];
    
    [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.leading.trailing.mas_equalTo(self.codeField);
        make.top.mas_equalTo(self.vreifyBtn.mas_bottom).offset(12);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-20);
    }];
}

- (void)setIsCodeSuccess:(BOOL)isCodeSuccess {
    if (!isCodeSuccess) {
        self.vreifyTipLabel.text = ZFLocalizedString(@"VerificationView_alretLabel_error", nil);
    }
    // 更新提示信息约束
    [self updateVreifyTipConstraint:!isCodeSuccess];
}

/**
 * 更新提示信息约束
 */
- (void)updateVreifyTipConstraint:(BOOL)showTip {
    CGFloat textHeight = showTip ? 15 : 0.0;
    [self.vreifyTipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textHeight);
    }];
}

#pragma mark - btnclik
/**
 * 倒计时功能
 */
- (void)startTime:(UIButton *)showButton{
    if (self.sendCodeBlock) {
        self.sendCodeBlock();
    }
    __block int timeout = 119; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    @weakify(self)
    dispatch_source_set_event_handler(_timer, ^{
        @strongify(self)
        if(timeout <= 0){ //倒计时结束，关闭
            dispatch_source_cancel(self.timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [showButton setTitle:ZFLocalizedString(@"VerificationView_showButton_titile", nil) forState:UIControlStateNormal];
                showButton.backgroundColor = ZFC0x2D2D2D();
                showButton.userInteractionEnabled = YES;
            });
        }else{
            NSString *strTime = [NSString stringWithFormat:@"%.2d", timeout];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                //NSLog(@"____%@",strTime);
//                [UIView beginAnimations:nil context:nil];
//                [UIView setAnimationDuration:1];
                [showButton setTitle:[NSString stringWithFormat:ZFLocalizedString(@"VerificationView_showButton_resent", nil),strTime] forState:UIControlStateNormal];
//                [UIView commitAnimations];
                showButton.backgroundColor = ZFCOLOR(153, 153, 153, 1);
                showButton.userInteractionEnabled = NO;
            });
            timeout--;
        }
    });
    dispatch_resume(self.timer);
}

- (void)closeBtnClick {
    [self removeFromSuperview];
}

- (void)vreifyBtnClick {
    if ([NSStringUtils isEmptyString:self.codeField.text]) {
        self.vreifyTipLabel.text = ZFLocalizedString(@"VerificationView_alretLabel_empty", nil);
        // 更新提示信息约束
        [self updateVreifyTipConstraint:YES];
        return;
    }
    if (self.codeBlock) {
        self.codeBlock(self.codeField.text);
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self convertContetnViewY:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self convertContetnViewY:NO];
}

/**
 * 键盘刷新contentView位置
 */
- (void)convertContetnViewY:(BOOL)showUP {
    CGFloat offsetY = showUP ? (-100 *ScreenHeight_SCALE) : 0;
    
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY).offset(offsetY);
    }];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self layoutIfNeeded];
    }];
}

#pragma mark - lazy
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 4;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"login_dismiss"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        [_titleLabel convertTextAlignmentWithARLanguage];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:12];
        _detailLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _detailLabel.numberOfLines = 0;
        [_detailLabel convertTextAlignmentWithARLanguage];
    }
    return _detailLabel;
}

- (UILabel *)phoneLabel {
    if (!_phoneLabel) {
        _phoneLabel = [[UILabel alloc] init];
//        _phoneLabel.textAlignment = NSTextAlignmentCenter;
        _phoneLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _phoneLabel.font = [UIFont systemFontOfSize:18];
    }
    return _phoneLabel;
}

- (UIButton *)senderBtn {
    if (!_senderBtn) {
        _senderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _senderBtn.backgroundColor = ZFC0x2D2D2D();
        _senderBtn.titleLabel.textColor = ZFCOLOR(255, 255, 255, 1.0);
        _senderBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_senderBtn setTitle:ZFLocalizedString(@"VerificationView_showButton_titile", nil) forState:UIControlStateNormal];
        [_senderBtn addTarget:self action:@selector(startTime:) forControlEvents:UIControlEventTouchUpInside];
        [_senderBtn.titleLabel convertTextAlignmentWithARLanguage];
    }
    return _senderBtn;
}

- (UIView *)middleLine {
    if (!_middleLine) {
        _middleLine = [[UIView alloc] init];
        _middleLine.backgroundColor = ZFCOLOR(216, 216, 216, 1);
    }
    return _middleLine;
}

-(UITextField *)codeField {
    if (!_codeField) {
        _codeField = [[UITextField alloc] init];
        _codeField.delegate = self;
        _codeField.backgroundColor = [UIColor whiteColor];
        _codeField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 20)];
        _codeField.leftViewMode = UITextFieldViewModeAlways;
        [_codeField showCurrentViewBorder:0.5 color:ZFCOLOR(178, 178, 178, 1.0)];
        _codeField.font = [UIFont systemFontOfSize:14];
        _codeField.keyboardType = UIKeyboardTypePhonePad;
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _codeField.textAlignment = NSTextAlignmentRight;
        }
        // 站位文案
        NSString *text = ZFLocalizedString(@"VerificationView_codeField", nil);
        NSMutableAttributedString *placeholderText = [[NSMutableAttributedString alloc] initWithString:text];
        [placeholderText addAttribute:NSForegroundColorAttributeName value:ZFCOLOR(153, 153, 153, 1) range:NSMakeRange(0, text.length)];
        [placeholderText addAttribute:NSFontAttributeName value:ZFFontSystemSize(12) range:NSMakeRange(0, text.length)];
        _codeField.attributedPlaceholder = placeholderText;
    }
    return _codeField;
}

- (UILabel *)vreifyTipLabel {
    if (!_vreifyTipLabel) {
        _vreifyTipLabel = [[UILabel alloc] init];
        _vreifyTipLabel.font = [UIFont systemFontOfSize:12];
        _vreifyTipLabel.textColor = ZFC0xFE5269();
        [_bottomLabel convertTextAlignmentWithARLanguage];
    }
    return _vreifyTipLabel;
}

- (UIButton *)vreifyBtn {
    if (!_vreifyBtn) {
        _vreifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _vreifyBtn.backgroundColor = ZFC0x2D2D2D();
        _vreifyBtn.titleLabel.textColor = ZFCOLOR(255, 255, 255, 1.0);
        _vreifyBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_vreifyBtn setTitle:ZFLocalizedString(@"VerificationView_VERIFY", nil) forState:UIControlStateNormal];
        [_vreifyBtn addTarget:self action:@selector(vreifyBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _vreifyBtn;
}

- (UILabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [[UILabel alloc] init];
        _bottomLabel.numberOfLines = 0;
        _bottomLabel.font = [UIFont systemFontOfSize:12];
        _bottomLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _bottomLabel.text = ZFLocalizedString(@"CODVerify_NoteTip", nil);
        [_bottomLabel convertTextAlignmentWithARLanguage];
    }
    return _bottomLabel;
}

@end
