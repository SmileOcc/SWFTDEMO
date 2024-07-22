//
//  YWLoginTypeEmailView.m
//  ZZZZZ
//
//  Created by YW on 26/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "YWLoginTypeEmailView.h"
#import "ZFInitViewProtocol.h"
#import "LoginViewModel.h"
#import "YWLoginEmailCell.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "NSString+Extended.h"

static const CGFloat kLineHight = 1;
static  CGFloat kTotalHeight = 0;

@interface YWLoginTypeEmailView ()<ZFInitViewProtocol,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIView             *lineView;
@property (nonatomic, strong) UILabel            *errorLabel;
@property (nonatomic, strong) LoginViewModel     *viewModel;
@property (nonatomic, assign) BOOL               isNeedUpdate;
@property (nonatomic, assign) BOOL               isNotRegister;
@property (nonatomic, strong) UITableView                   *emailTableView;
@property (nonatomic, copy)   NSString                      *inputString;
@property (nonatomic, strong) NSArray<NSString *>           *emailSuffixArray;
@property (nonatomic, strong) NSMutableArray<NSString *>    *matchedSuffixArray;
//『点击外部消失手势』,参考了IQkeyboardManager的点击外部，让键盘消失的思路
@property(nonatomic,strong)UITapGestureRecognizer           *resignFirstResponderGesture;
@end

@implementation YWLoginTypeEmailView
#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.isShowTipsEmail = YES;
        self.backgroundColor = ZFCOLOR_WHITE;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.model.email) {
                [self.emailTextField showPlaceholderAnimation];
            }
        });
        
        _resignFirstResponderGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapRecognized:)];
        _resignFirstResponderGesture.cancelsTouchesInView = NO;
        [_resignFirstResponderGesture setDelegate:self];
    }
    return self;
}

- (void)zfInitView {
    [self addSubview:self.emailTextField];
    [self addSubview:self.lineView];
    [self addSubview:self.errorLabel];
    
    [self addSubview:self.emailTableView];
    [self bringSubviewToFront:self.emailTableView];
}

- (void)zfAutoLayoutView {
    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(33);
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.height.mas_equalTo(32).priorityHigh();
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailTextField.mas_bottom);
        make.height.mas_equalTo(kLineHight);
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
    }];
    
    [self.errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView.mas_bottom).offset(2);
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.height.mas_equalTo(0);
        make.bottom.equalTo(self);
    }];
    
    [self.emailTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.errorLabel.mas_bottom);
        make.leading.equalTo(self.lineView);
        make.width.equalTo(self.emailTextField);
        make.height.mas_equalTo(0);
    }];
}

#pragma mark - Action
- (void)emailTextFieldEditingDidBegin {
    if (!self.model.isFirstFocus) {
        if (self.emailTextFieldEditingDidEndHandler) {
            self.emailTextFieldEditingDidEndHandler(NO,self.model);
        }
    }
    [self showBegainEditAnimation];
}

- (void)emailTextFieldEditingDidEnd {
    self.model.email = self.emailTextField.text;
    if (ZFIsEmptyString(self.emailTextField.text) && self.isNeedUpdate) {
        [self resetAnimation];
        return;
    }
    [self checkValidEmail];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    return YES;
}

- (void)emailTextFieldEditingDidChanged:(NSNotification *)notif {
    if (self.emailTextFieldEditingChangeHandler) {
        self.emailTextFieldEditingChangeHandler(self.emailTextField);
    }
    if ([self.emailTextField.text isEqualToString:@""]) {
        [self dissmissEmailTableView];
        return;
    }

    NSString *inputString = self.emailTextField.text;
    if ([inputString containsString:@"@"]) {
        NSString *latterStr = [self.emailTextField.text substringFromIndex:[self.emailTextField.text rangeOfString:@"@"].location+1];
        if ([latterStr isEqualToString:@""]) {
            self.matchedSuffixArray = [NSMutableArray arrayWithArray:self.emailSuffixArray];
        }else{
            NSMutableArray *array = [NSMutableArray array];
            [self.emailSuffixArray enumerateObjectsUsingBlock:^(NSString  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj containsString:latterStr]) {
                    [array addObject:obj];
                }
            }];
            self.matchedSuffixArray = [array copy];
        }

        if (self.matchedSuffixArray.count == 0) {
            [self dissmissEmailTableView];
            return;
        }
    }else{
         self.matchedSuffixArray = [NSMutableArray arrayWithArray:self.emailSuffixArray];
    }

    CGFloat cellHeight = 40;
    kTotalHeight = self.matchedSuffixArray.count * cellHeight;
    if (self.isShowTipsEmail) {
        [self showEmailTableView];
        [self.emailTableView reloadData];
    }
}

#pragma mark - UIGestureRecognizerDelegate
/** Resigning on tap gesture. */
- (void)tapRecognized:(UITapGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {

    }
}

/** Note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES. */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

/** To not detect touch events in a subclass of UIControl, these may have added their own selector for specific work */
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([self.emailTableView pointInside:[touch locationInView:self.emailTableView] withEvent:nil]) {
        return YES;//点击的是搜索结果tableViiew，则不处理 『点击外部消失手势』
    }
    //  Should not recognize gesture if the clicked view is either UIControl or UINavigationBar(<Back button etc...)    (Bug ID: #145
    if (self.emailTextField.isFirstResponder) {
        [self dissmissEmailTableView];
        return NO;//textField键盘还在，则不处理 『点击外部消失手势』，先影藏键盘
    }

    for (Class aClass in [NSSet setWithObjects:[UIControl class],[UINavigationBar class], nil])
    {
        if ([[touch view] isKindOfClass:aClass])
        {
            return NO;//点击的是一些操作控件，则不处理 『点击外部消失手势』
        }
    }
    return YES;
}

#pragma mark - Rewrite
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // 将point转化成为 tableview 坐标系上的点
    CGPoint buttonPoint = [self convertPoint:point toView:self.emailTableView];
    
    // 如果点在tableview上，那么返回nil，tableview作为响应者1
    if ([self.emailTableView pointInside:buttonPoint withEvent:event]) {
        return self.emailTableView;
    }
    
    // 当然如果点不在tableview上，那么就接着原来的hitTest方法执行，执行super语句。
    return [super hitTest:point withEvent:event];
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)tableView:(UITableView*)table numberOfRowsInSection:(NSInteger)section {
    return self.matchedSuffixArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    YWLoginEmailCell *cell = [YWLoginEmailCell loginEmailCellWith:tableView forIndexPath:indexPath];
    if (indexPath.row < self.matchedSuffixArray.count) {
        self.inputString = self.emailTextField.text;
        if ([self.inputString containsString:@"@"]) {
            NSRange emailCharRange = [self.inputString rangeOfString:@"@"];
            NSRange replaceRange = NSMakeRange(emailCharRange.location, self.inputString.length - emailCharRange.location);
            self.inputString = [self.inputString stringByReplacingCharactersInRange:replaceRange withString:@""];
        }
        cell.email = [self.inputString stringByAppendingString:self.matchedSuffixArray[indexPath.row]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {
    return 40;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    NSString *match = self.matchedSuffixArray[indexPath.row];
    if (ZFIsEmptyString(match)) {
        return;
    }
    self.emailTextField.text = [self.inputString stringByAppendingString:match];
    [self dissmissEmailTableView];
}

#pragma mark - Setter
- (void)setModel:(YWLoginModel *)model {
    _model = model;
    self.emailTextField.text = model.email;
    self.isNeedUpdate = model.isChangeType;
    if (self.isNeedUpdate) {
        if (ZFIsEmptyString(self.emailTextField.text) && !self.errorLabel.hidden) {
            [self resetAnimation];
            self.isNeedUpdate = NO;
            return;
        }
        
        if (!ZFIsEmptyString(model.email)) {
            [self checkValidEmail];
        }
        self.isNeedUpdate = NO;
    }
}

#pragma mark - Public method
- (void)setupErrorTip:(BOOL)isForgotPassword {
    if (isForgotPassword) {
        self.errorLabel.text = ZFLocalizedString(@"email_notRegister", nil);
        self.isNotRegister = YES;
    }else{
        self.errorLabel.text = ZFLocalizedString(@"Login_email_format_error", nil);
        self.isNotRegister = NO;
    }
}

- (void)setupErrorMessage:(NSString *)errorMessage
{
    if (ZFToString(errorMessage).length) {
        self.errorLabel.text = errorMessage;
    }
}

#pragma mark - Private method
- (void)checkValidEmail {
    if (![NSStringUtils isValidEmailString:self.emailTextField.text] || ZFIsEmptyString(self.emailTextField.text)) {
        self.errorLabel.text = ZFLocalizedString(@"Login_email_format_error", nil);
        [self showErrorAnimation];
    }
    
    if (self.model.type == YWLoginEnterTypeRegister) {
        if (!ZFIsEmptyString(self.model.email)) {
            [self requestValidEmail];
        }
    }else{
        [self showNormalStateAnimation];
    }
}

- (void)showLineAnimation:(UIColor *)color height:(CGFloat)height {
    @weakify(self)
    void (^showBlock)(void) = ^{
        @strongify(self)
        [self layoutIfNeeded];
        self.lineView.backgroundColor = color;
    };
    
    CGFloat textheight = [self.errorLabel.text textSizeWithFont:self.errorLabel.font constrainedToSize:CGSizeMake(KScreenWidth - 32, MAXFLOAT) lineBreakMode:self.errorLabel.lineBreakMode].height;
    
    [self.emailTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(32);
    }];
    
    [self.errorLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.errorLabel.hidden ? 0 : textheight);
    }];
    
    [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(65 + height + (self.errorLabel.hidden ? 0 : textheight));
    }];
    
    [UIView animateWithDuration:0.3
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:showBlock
                     completion:nil];
}

- (void)showBegainEditAnimation {
    self.errorLabel.hidden = YES;
    self.model.isFirstFocus = NO;
    [self showLineAnimation:ZFCOLOR(45, 45, 45, 1) height:kLineHight*2];
}

- (void)showErrorAnimation {
    self.errorLabel.hidden = NO;
    [self showLineAnimation:ZFC0xFE5269() height:kLineHight*2];
    if (self.emailTextFieldEditingDidEndHandler) {
        self.model.isValidEmail = NO;
        self.emailTextFieldEditingDidEndHandler(YES,self.model);
    }
}

- (void)showNormalStateAnimation {
    self.errorLabel.hidden = YES;
    [self showLineAnimation:ZFCOLOR(221, 221, 221, 1) height:kLineHight];
    if (self.emailTextFieldEditingDidEndHandler) {
        self.model.isValidEmail = YES;
        self.emailTextFieldEditingDidEndHandler(NO,self.model);
    }
}

- (void)resetAnimation {
    self.errorLabel.hidden = YES;
    [self showLineAnimation:ZFCOLOR(221, 221, 221, 1) height:kLineHight];
    if (self.emailTextFieldEditingDidEndHandler) {
        self.model.isValidEmail = NO;
        self.emailTextFieldEditingDidEndHandler(NO,self.model);
    }
}

- (void)requestValidEmail {
    NSDictionary *dict = @{@"email": ZFToString(self.emailTextField.text)};
    @weakify(self)
    [self.viewModel requestVerifyEamilHasRegister:dict completion:^(NSString *emailTextTipString) {
        @strongify(self)
        if (emailTextTipString) {
            self.errorLabel.text = ZFLocalizedString(@"Email_used", nil);
            [self showErrorAnimation];
        }else{
            [self showNormalStateAnimation];
        }
        if (self.checkValidRequestComplation) {
            self.checkValidRequestComplation(emailTextTipString);
        }
    } failure:^(id obj) {
        @strongify(self)
        [self showErrorAnimation];
        if (self.checkValidRequestComplation) {
            self.checkValidRequestComplation(ZFLocalizedString(@"Email_used", nil));
        }
    }];
}

- (void)showEmailTableView {
    [self.emailTextField.window addGestureRecognizer:_resignFirstResponderGesture];
    self.emailTableView.alpha = 1;
    self.emailTableView.hidden = NO;
    void (^showBlock)(void) = ^{
        [self layoutIfNeeded];
    };

    [self.emailTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kTotalHeight);
    }];
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:showBlock completion:nil];

//    LSAnimator *animator = [LSAnimator animatorWithLayer:self.emailTableView.layer];
//    animator.makeHeight(kTotalHeight).easeOutSine.animate(0.3);
//    animator.concurrent.makeOpacity(1).animate(.3);
}

- (void)dissmissEmailTableView {
    if (!self.emailTableView.superview) {
        return;
    }
    [self.emailTextField.window removeGestureRecognizer:_resignFirstResponderGesture];
    void (^showBlock)(void) = ^{
        self.emailTableView.alpha = 0;
        [self layoutIfNeeded];
    };

    [self.emailTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    [UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:showBlock completion:^(BOOL finished) {
        self.emailTableView.hidden = YES;
    }];
    
//    LSAnimator *animator = [LSAnimator animatorWithLayer:self.emailTableView.layer];
//    animator.makeHeight(0).easeOutSine.animate(0.3);
//    animator.concurrent.makeOpacity(0).animate(.3);
}

#pragma mark - Getter
- (YWLoginTextField *)emailTextField {
    if (!_emailTextField) {
        _emailTextField = [[YWLoginTextField alloc] init];
        _emailTextField.backgroundColor = [UIColor whiteColor];
        _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        _emailTextField.returnKeyType = UIReturnKeyNext;
        _emailTextField.placeholder = ZFLocalizedString(@"SignIn_Email",nil);
        _emailTextField.font = [UIFont systemFontOfSize:16.f];
        _emailTextField.textColor = ZFCOLOR(45, 45, 45, 1);
        _emailTextField.clearImage = [UIImage imageNamed:@"login_clearButton"];
        _emailTextField.placeholderFont = ZFFontSystemSize(16);
        _emailTextField.placeholderAnimationFont = ZFFontSystemSize(14);
        _emailTextField.placeholderNormalColor = ZFCOLOR(153, 153, 153, 1);
        _emailTextField.delegate = self;
        [_emailTextField addTarget:self action:@selector(emailTextFieldEditingDidEnd) forControlEvents:(UIControlEventEditingDidEnd)];
        [_emailTextField addTarget:self action:@selector(emailTextFieldEditingDidBegin) forControlEvents:(UIControlEventEditingDidBegin)];
        [_emailTextField addTarget:self action:@selector(emailTextFieldEditingDidChanged:) forControlEvents:UIControlEventEditingChanged];
        _emailTextField.delegate = self;
    }
    return _emailTextField;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    }
    return _lineView;
}

- (UILabel *)errorLabel {
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.backgroundColor = ZFCOLOR_WHITE;
        _errorLabel.font = ZFFontSystemSize(12);
        _errorLabel.textColor = ZFC0xFE5269();
        _errorLabel.text = ZFLocalizedString(@"Login_email_format_error",nil);
        _errorLabel.numberOfLines = 0;
        _errorLabel.preferredMaxLayoutWidth = KScreenWidth - 32;
        _errorLabel.hidden = NO;
    }
    return _errorLabel;
}

- (LoginViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[LoginViewModel alloc] init];
    }
    return _viewModel;
}

- (UITableView *)emailTableView {
    if (!_emailTableView) {
        _emailTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _emailTableView.delegate = self;
        _emailTableView.dataSource = self;
        _emailTableView.backgroundColor = [UIColor whiteColor];
        _emailTableView.estimatedRowHeight = 0;
        _emailTableView.estimatedSectionFooterHeight = 0;
        _emailTableView.estimatedSectionHeaderHeight = 0;
        _emailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _emailTableView.bounces = NO;
        _emailTableView.hidden = YES;
        [_emailTableView showCurrentViewBorder:1 color:ZFCOLOR(221, 221, 221, 1)];
    }
    return _emailTableView;
}

- (NSArray<NSString *> *)emailSuffixArray {
    if (!_emailSuffixArray) {
        _emailSuffixArray = @[
                              @"@gmail.com",
                              @"@hotmail.com",
                              @"@yahoo.com",
                              @"@icloud.com",
                              @"@outlook.com",
                              @"@aol.com"
                              ];
    }
    //俄罗斯
    if ([self.region_id isEqualToString:@"32"]) {
        _emailSuffixArray = @[
            @"@gmail.ru",
            @"@mail.ru",
            @"@yandex.ru",
            @"@bk.ru",
            @"@gmail.com",
            @"@hotmail.com",
            @"@yahoo.com",
            @"@icloud.com",
            @"@outlook.com",
            @"@aol.com"
        ];
    } else {
        _emailSuffixArray = @[
        @"@gmail.com",
        @"@hotmail.com",
        @"@yahoo.com",
        @"@icloud.com",
        @"@outlook.com",
        @"@aol.com"
        ];
    }
    return _emailSuffixArray;
}

- (NSMutableArray<NSString *> *)matchedSuffixArray {
    if (!_matchedSuffixArray) {
        _matchedSuffixArray = [NSMutableArray array];
    }
    return _matchedSuffixArray;
}

@end
