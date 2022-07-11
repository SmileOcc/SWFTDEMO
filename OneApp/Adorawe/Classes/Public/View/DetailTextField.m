//
//  DetailTextField.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/14.
//

#import "DetailTextField.h"
#import <JVFloatLabeledTextField.h>
#import "STLFloatLabelTextField.h"

@interface DetailTextField () 
@property (weak,nonatomic) UIButton *showPasswordBtn;
@end

@implementation DetailTextField


-(instancetype)initWithCoder:(NSCoder *)coder{
    if(self = [super initWithCoder:coder]){
        [self setUpViews];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpViews];
    }
    return self;
}

-(void)showOrHidePwd{
    _inputField.secureTextEntry = !_inputField.secureTextEntry;
    _showPasswordBtn.selected = !_showPasswordBtn.selected;
}

-(void)setUpViews{
    self.axis = UILayoutConstraintAxisVertical;
    JVFloatLabeledTextField *inputField = [STLFloatLabelTextField new];
    inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    inputField.placeholder = self.placeholder;
    inputField.autocorrectionType = UITextAutocorrectionTypeNo;
    inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    inputField.floatingLabelYPadding = -11;
    inputField.tintColor = OSSVThemesColors.col_0D0D0D;
    inputField.font = [UIFont boldSystemFontOfSize:15];
    inputField.floatingLabel.font = [UIFont systemFontOfSize:11];
    inputField.keepBaseline = YES;
    _inputField = inputField;
    inputField.delegate = self;
    UIStackView *inputContainer = [[UIStackView alloc] init];
    inputContainer.axis = UILayoutConstraintAxisHorizontal;
    [self addSubview:inputContainer];
    [inputContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.leading.equalTo(self.mas_leading);
        make.trailing.equalTo(self.mas_trailing);
    }];
    
    [inputContainer addSubview:inputField];
    [inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(inputContainer.mas_leading);
        make.top.mas_equalTo(inputContainer.mas_top);
        make.bottom.mas_equalTo(inputContainer.mas_bottom);
        make.height.mas_equalTo(36);
    }];
    UIButton *showPwd = [UIButton buttonWithType:UIButtonTypeCustom];
    _showPasswordBtn = showPwd;
    showPwd.contentEdgeInsets = UIEdgeInsetsMake(2, -2, -2, 2);
    [_showPasswordBtn setImage:[UIImage imageNamed:@"eyes_close"] forState:UIControlStateNormal];
    [_showPasswordBtn setImage:[UIImage imageNamed:@"eyes_open"] forState:UIControlStateSelected];
    [inputContainer addSubview:showPwd];
    [showPwd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(24);
        make.leading.mas_equalTo(inputField.mas_trailing).offset(12);
        make.trailing.mas_equalTo(inputContainer.mas_trailing);
        make.bottom.mas_equalTo(inputContainer.mas_bottom);
    }];
    
    [showPwd addTarget:self action:@selector(showOrHidePwd) forControlEvents:UIControlEventTouchUpInside];
    
//    inputField
    UIView *devider = [UIView new];
    [self addSubview:devider];
    _devider = devider;
    [_devider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(inputContainer.mas_bottom).offset(10);
        make.trailing.equalTo(self.mas_trailing);
        make.leading.equalTo(self.mas_leading);
        make.height.mas_equalTo(0.6);
    }];
    
    UILabel *detailLbl = [UILabel new];
    detailLbl.font = [UIFont systemFontOfSize:11];
    _detailLbl = detailLbl;
    [self addSubview:detailLbl];
    [detailLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(devider.mas_bottom).offset(4);
        make.leading.equalTo(self.mas_leading);
        make.trailing.equalTo(self.mas_trailing);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    self.inputField.textAlignment = ![OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentLeft : NSTextAlignmentRight;
    
    self.isPassword = NO;
}

-(void)setDetails:(NSString *)details{
    _details = details;
    _detailLbl.text = details;
    [self setNeedsUpdateConstraints];
}

-(void)setDetailsColor:(UIColor *)detailsColor{
    _detailsColor = detailsColor;
    _detailLbl.textColor = detailsColor;
}

-(void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    _inputField.placeholder = placeholder;
}

-(void)setPlaceholderColor:(UIColor *)placeholderColor{
    _placeholderColor = placeholderColor;
    if ([_inputField isKindOfClass:JVFloatLabeledTextField.class]) {
        ((JVFloatLabeledTextField*)_inputField).placeholderColor = placeholderColor;
    }
    
}

-(void)setFloatPlaceholderColor:(UIColor *)floatPlaceholderColor{
    _floatPlaceholderColor = floatPlaceholderColor;
    if ([_inputField isKindOfClass:JVFloatLabeledTextField.class]) {
        ((JVFloatLabeledTextField*)_inputField).floatingLabelActiveTextColor = floatPlaceholderColor;
    }
}

-(void)setDeviderColor:(UIColor *)deviderColor{
    _deviderColor = deviderColor;
    _devider.backgroundColor = deviderColor;
}

#pragma mark -TextfiledDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([self.inputField isKindOfClass:JVFloatLabeledTextField.class]) {
        ((JVFloatLabeledTextField *)_inputField).alwaysShowFloatingLabel = NO;
    }else{
        textField.placeholder = _placeholder;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidEndEditing:filed:)]) {
        [self.delegate textFieldDidEndEditing:self filed:textField];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([self.inputField isKindOfClass:JVFloatLabeledTextField.class]) {
        ((JVFloatLabeledTextField *)_inputField).alwaysShowFloatingLabel = YES;
    }else{
        textField.placeholder = @"";
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:filed:)]) {
        [self.delegate textFieldDidBeginEditing:self filed:textField];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldShouldReturn:filed:)]) {
        return [self.delegate textFieldShouldReturn:self filed:textField];
    }
    return true;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textField:detailText:shouldChangeCharactersInRange:replacementString:)]) {
        return [self.delegate textField:textField detailText:self shouldChangeCharactersInRange:range replacementString:string];
    }
    return true;
}


///textfield methods
-(BOOL)isEditing{
    return _inputField.isEditing;
}


-(void)setText:(NSString *)text{
    _inputField.text = text;
}

-(NSString *)text{
    return [_inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void)setReturnKeyType:(UIReturnKeyType)returnKeyType{
    _inputField.returnKeyType = returnKeyType;
}

-(void)setIsPassword:(BOOL)isPassword{
    _isPassword = isPassword;
    _showPasswordBtn.hidden = !isPassword;
    [_showPasswordBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        if (APP_TYPE == 3) {
            make.width.mas_equalTo(isPassword ? 18 : 0);
        } else {
            make.width.mas_equalTo(isPassword ? 24 : 0);
        }
        make.leading.mas_equalTo(self.inputField.mas_trailing).offset(isPassword ? 12 : 0);
    }];
    _inputField.secureTextEntry = isPassword;
}

-(void)setError:(NSString *)msg color:(UIColor *)color{
    self.details = msg;
    self.detailsColor = color;
    self.deviderColor = color;
}
-(void)clearError{
    self.details = @"";
    self.detailsColor = OSSVThemesColors.col_CCCCCC;
    self.deviderColor = OSSVThemesColors.col_CCCCCC;
}

-(void)setKeyboardType:(UIKeyboardType)keyboardType{
    _inputField.keyboardType = keyboardType;
}

-(BOOL)becomeFirstResponder{
    return [_inputField becomeFirstResponder];
}

@end
