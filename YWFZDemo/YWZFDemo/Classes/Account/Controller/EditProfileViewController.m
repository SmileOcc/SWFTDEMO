//
//  AccountProfileViewController.m
//  Dezzal
//
//  Created by 7FD75 on 16/7/28.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "EditProfileViewController.h"
#import "ModifyPorfileViewModel.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "RadioButton.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "AccountManager.h"
#import "UIImage+ZFExtended.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIView+LayoutMethods.h"
#import "ZFAccountViewModel.h"
#import <YYWebImage/YYWebImage.h>
#import "Constants.h"

static NSString *const EditDefalutDateString = @"0000-00-00";

@interface EditProfileViewController () <UITextFieldDelegate,RadioButtonDelegate>
@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *toastImageView;
@property (nonatomic, strong) UILabel *toastLabel;
@property (nonatomic, strong) UITextField *firstNameTextfield;
@property (nonatomic, strong) UITextField *lastNameTextField;
@property (nonatomic, strong) UITextField *nicknameTextField;
@property (nonatomic, strong) RadioButton *maleBtn;
@property (nonatomic, strong) RadioButton *femaleBtn;
@property (nonatomic, strong) RadioButton *privacyBtn;
@property (nonatomic, strong) UITextField *birthDayTextField;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UILabel *emalLabel;
@property (nonatomic, strong) UITextField *emailAddressTextField;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *uploadDateFormatter;
@property (nonatomic, strong) AccountModel *userModel;
@property (nonatomic, strong) ModifyPorfileViewModel *viewModel;
@property (nonatomic, strong) ZFAccountViewModel *accountViewModel;
@property (nonatomic, assign) NSUInteger sex;
/////生日提示视图
//@property (nonatomic, strong) UIView *birthdayTipsView;
@end

@implementation EditProfileViewController

-(void)dealloc {
    YWLog(@"EditProfileViewController");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    [self requestUserData:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [RadioButton removerRb_observersData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UIView *line1 = [self.firstNameTextfield addLineToPosition:(ZFDrawLine_bottom) lineWidth:1];
    line1.width = KScreenWidth - 12 * 2;
    line1.centerX = self.view.centerX;
    
    UIView *line2 = [self.lastNameTextField addLineToPosition:(ZFDrawLine_bottom) lineWidth:1];
    line2.width = line1.width;
    line2.centerX = self.view.centerX;
    
    UIView *line3 = [self.nicknameTextField addLineToPosition:(ZFDrawLine_bottom) lineWidth:1];
    line3.width = line1.width;
    line3.centerX = self.view.centerX;
    
    UIView *line4 = [self.birthDayTextField addLineToPosition:(ZFDrawLine_bottom) lineWidth:1];
    line4.width = line1.width;
    line4.centerX = self.view.centerX;
}

- (void)requestUserData:(BOOL)isPop {
    ShowLoadingToView(self.view);
    [self.accountViewModel requestUserInfoData:^(AccountModel *accountModel) {
        HideLoadingFromView(self.view);
        if ([accountModel isKindOfClass:[AccountModel class]]) {
            self.userModel = accountModel;
            if (isPop) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kChangeUserInfoNotification object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            ShowToastToViewWithText(self.view, ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil));
        }
    } failure:^(NSError *error) {
        ShowToastToViewWithText(self.view, error.domain);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }];
}

- (void)setUserModel:(AccountModel *)userModel {
    _userModel = userModel;
    self.firstNameTextfield.text = userModel.firstname;
    self.lastNameTextField.text = userModel.lastname;
    self.nicknameTextField.text = userModel.nickname;
    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [self gainRequestDateformatter:userModel.birthday];
    [tempFormatter setDateFormat:dateFormat];
    NSDate *date = [tempFormatter dateFromString:userModel.birthday];
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    self.birthDayTextField.text = dateString;
    self.phoneTextField.text = userModel.phone;
    self.emailAddressTextField.text = userModel.email;
    self.sex = userModel.sex;
    if(userModel.sex == 0 ) {
        [self.privacyBtn setChecked:YES];
    }else{
        [self.maleBtn setChecked:self.maleBtn.index == userModel.sex];
        [self.femaleBtn setChecked:self.femaleBtn.index == userModel.sex];
        [self.privacyBtn setChecked:self.privacyBtn.index == userModel.sex];
    }
    
    if ([userModel.point_tips length] > 0) {
        self.toastLabel.text = userModel.point_tips;
        [self isShowToast:YES];
    } else {
        [self isShowToast:NO];
    }
    
    NSString *birthday = userModel.birthday;
    if (!ZFIsEmptyString(birthday)) {
        if (userModel.is_update_birthday) {
            self.birthDayTextField.enabled = NO;
            self.birthDayTextField.clearButtonMode = UITextFieldViewModeNever;
        } else {
            self.birthDayTextField.enabled = YES;
            self.birthDayTextField.clearButtonMode = UITextFieldViewModeAlways;
        }
    } else {
        self.birthDayTextField.enabled = YES;
        self.birthDayTextField.clearButtonMode = UITextFieldViewModeAlways;
    }
}

- (void)setUI {
    self.title = ZFLocalizedString(@"Profile_VC_Title",nil);
    self.view.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, IPHONE_X_5_15 ? 94 : 60, 0));
    }];

    [self.scrollView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(KScreenWidth));
        make.edges.mas_equalTo(self.scrollView).insets(UIEdgeInsetsMake(0, 0, 20, 0));
    }];

    [self.containerView addSubview:self.toastImageView];
    [self.containerView addSubview:self.toastLabel];
    [self.toastImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.containerView).offset(12.0f);
        make.top.mas_equalTo(self.containerView).offset(20.0);
        make.height.with.mas_equalTo(18.0f);
    }];
    [self.toastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.toastImageView.mas_trailing).offset(5.0f);
        make.top.mas_equalTo(self.toastImageView.mas_top);
        make.trailing.mas_equalTo(self.containerView.mas_trailing).offset(- 20.0f);
        make.height.mas_greaterThanOrEqualTo(18.0f);
    }];
    [self isShowToast:NO];
    
    self.firstNameTextfield = [self setTextFieldPlaceholder:ZFLocalizedString(@"Profile_FirstName_Placeholder",nil) keyboardType:UIKeyboardTypeDefault];
    [self.containerView addSubview:self.firstNameTextfield];
    [self.firstNameTextfield mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(0);
        make.top.mas_equalTo(self.toastLabel.mas_bottom).offset(20);
        make.trailing.offset(0);
        make.height.equalTo(@44);
    }];

    self.lastNameTextField = [self setTextFieldPlaceholder:ZFLocalizedString(@"Profile_LastName_Placeholder",nil) keyboardType:UIKeyboardTypeDefault];
    [self.containerView addSubview:self.lastNameTextField];
    [self.lastNameTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.firstNameTextfield);
        make.size.equalTo(self.firstNameTextfield);
        make.top.equalTo(self.firstNameTextfield.mas_bottom).offset(0);
    }];

    self.nicknameTextField = [self setTextFieldPlaceholder:ZFLocalizedString(@"Profile_NickName_Placeholder",nil) keyboardType:UIKeyboardTypeDefault];
    [self.containerView addSubview:self.nicknameTextField];
    [self.nicknameTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.lastNameTextField);
        make.size.equalTo(self.lastNameTextField);
        make.top.equalTo(self.lastNameTextField.mas_bottom).offset(0);
    }];


    [self.containerView addSubview:self.femaleBtn];
    [self.femaleBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.firstNameTextfield.mas_leading).offset(12);
        make.top.equalTo(self.nicknameTextField.mas_bottom).offset(10);
    }];

    [self.containerView addSubview:self.maleBtn];
    [self.maleBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.femaleBtn.mas_centerY);
        make.leading.mas_equalTo(self.femaleBtn.mas_trailing).offset(20);
    }];

    [self.containerView addSubview:self.privacyBtn];
    [self.privacyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.femaleBtn.mas_centerY);
        make.leading.mas_equalTo(self.maleBtn.mas_trailing).offset(20);
    }];

    self.birthDayTextField = [self setTextFieldPlaceholder:ZFLocalizedString(@"Profile_Birthday_Placeholder",nil) keyboardType:UIKeyboardTypeDefault];
    self.birthDayTextField.inputView = self.datePicker;
    [self.containerView addSubview:self.birthDayTextField];
    [self.birthDayTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.femaleBtn.mas_bottom).offset(10);
        make.leading.leading.equalTo(self.firstNameTextfield);
        make.size.equalTo(self.firstNameTextfield);
    }];

    ///如果是用户生日没填一个提示视图
    UIView *topView = self.birthDayTextField;
//    NSString *birthday = [AccountManager sharedManager].account.birthday;
//    if (ZFIsEmptyString(birthday)) {
//        [self.containerView addSubview:self.birthdayTipsView];
//        [self.birthdayTipsView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.birthDayTextField.mas_bottom).mas_offset(0);
//            make.leading.mas_equalTo(self.firstNameTextfield);
//            make.trailing.mas_equalTo(self.containerView.mas_trailing).mas_offset(-15);
//        }];
//        topView = self.birthdayTipsView;
//        self.birthDayTextField.placeholder = ZFLocalizedString(@"Account_birthday_enter", nil);
//    }

    self.phoneTextField = [self setTextFieldPlaceholder:ZFLocalizedString(@"Profile_Phone_Placeholder",nil) keyboardType:UIKeyboardTypeDefault];
    [self.containerView addSubview:self.phoneTextField];
    [self.phoneTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.firstNameTextfield);
        make.size.equalTo(self.firstNameTextfield);
        make.top.equalTo(topView.mas_bottom).offset(0);
        if ([AccountManager sharedManager].account.is_emerging_country == 1) {
            make.bottom.equalTo(self.containerView);
        }
    }];
    
    //邮箱注册才显示这个
    UIView *saveBtnTopView = self.phoneTextField;
    if ([AccountManager sharedManager].account.is_emerging_country != 1) {
        [self.containerView addSubview:self.emalLabel];
        [self.emalLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.firstNameTextfield).offset(12);
            make.top.equalTo(self.phoneTextField.mas_bottom).offset(30);
        }];

        self.emailAddressTextField = [self setTextFieldPlaceholder:ZFLocalizedString(@"Profile_EmailAddress_Placeholder",nil) keyboardType:UIKeyboardTypeEmailAddress];
        self.emailAddressTextField.clearButtonMode = UITextFieldViewModeNever;
        self.emailAddressTextField.borderStyle = UITextBorderStyleNone;
        self.emailAddressTextField.backgroundColor = [UIColor clearColor];
        [self.containerView addSubview:self.emailAddressTextField];
        [self.emailAddressTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.firstNameTextfield);
            make.size.equalTo(self.firstNameTextfield);
            make.top.equalTo(self.emalLabel.mas_bottom).offset(-5);
            make.bottom.equalTo(self.containerView);
        }];
        saveBtnTopView = self.emailAddressTextField;
    }

    [self.view addSubview:self.saveBtn];
    [self.saveBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(saveBtnTopView.mas_bottom).offset(25);
        make.leading.mas_equalTo(self.view).offset(12);
        make.trailing.mas_equalTo(self.view).offset(-12);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark - Delegate
#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!CGColorEqualToColor(textField.layer.borderColor,ZFCOLOR(221, 221, 221, 1.0).CGColor)) {
        textField.layer.borderColor = ZFCOLOR(221, 221, 221, 1.0).CGColor;
    }
    if (textField == self.birthDayTextField) {
        //确保加载时也能获取datePicker的文字
        [self datePickerValueChange:self.datePicker];
    }
}

#pragma mark - radioButton
-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString*)groupId {
    _sex = index; //用户性别 0 保密  1 男  2 女
}
#pragma mark DatePciker Action
- (void)datePickerValueChange:(UIDatePicker *)datePicker{
    //将日期转为指定格式显示
    NSString *dateStr = [self.dateFormatter stringFromDate:datePicker.date];
    self.birthDayTextField.text = dateStr;
}

- (BOOL)checkInputTextFieldIsValid:(UITextField *)textField{
    
    BOOL isCheckValid = YES;
    NSString *showHudErrorString = nil;
    
    if ([textField isEqual:self.firstNameTextfield]) {
        if ([NSStringUtils isEmptyString:textField.text]){
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Enter_FirstName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if (!(textField.text.length > 1)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Least_FirstName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if ((textField.text.length > 35)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Maxium_FirstName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
    }
    
    if ([textField isEqual:self.lastNameTextField]) {
        if ([NSStringUtils isEmptyString:textField.text]){
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Enter_LastName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if (!(textField.text.length > 1)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Least_LastName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if ((textField.text.length > 35)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Maxium_LastName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
    }
    
    if ([textField isEqual:self.nicknameTextField]) {
        if ([NSStringUtils isEmptyString:textField.text]){
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Enter_NickName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if (!(textField.text.length > 1)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Least_NickName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if ((textField.text.length > 35)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Maxium_NickName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
    }
    
    if ([textField isEqual:self.phoneTextField]) {
        if ([NSStringUtils isEmptyString:textField.text]){
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Enter_Phone_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            
            return NO;
        }
        if ((textField.text.length < 6)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Least_Phone_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if ((textField.text.length > 20)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Maxium_Phone_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
    }
    
    if ([textField isEqual:self.birthDayTextField]) {
        if (ZFIsEmptyString(textField.text)) {
            ShowToastToViewWithText(self.view, ZFLocalizedString(@"Account_birthday_enter", nil));
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - private method

- (NSString *)gainRequestDateformatter:(NSString *)birthdayString
{
    NSString *dateFormat = @"MM/dd/yyyy";
    if (!ZFToString(birthdayString).length) {
        return dateFormat;
    }
    NSArray *dateList = [birthdayString componentsSeparatedByString:@"/"];
    if (dateList && [dateList count]) {
        NSString *firstDate = dateList.firstObject;
        if ([dateList count] > 2) {
            //包含年月日
            if (firstDate.length > 2) {
                //年开头 yyyy/MM/dd
                dateFormat = @"yyyy/MM/dd";
            }
        }else if ([dateList count] == 2){
            //月日, 这个是从 谷歌或者facebook获取的
            if (firstDate.length > 2) {
                dateFormat = @"yyyy/MM";
            }else{
                dateFormat = @"MM/dd";
            }
        }
    }
    return dateFormat;
}

#pragma mark Save Button Action

- (void)saveBtnClick
{
    // 判断是否都输入
    if (![self checkInputTextFieldIsValid:self.firstNameTextfield]) {
        return;
    }
    
    if (![self checkInputTextFieldIsValid:self.lastNameTextField]) {
        return;
    }
    
    if (![self checkInputTextFieldIsValid:self.nicknameTextField]) {
        return;
    }
    
    if (![self checkInputTextFieldIsValid:self.emailAddressTextField]) {
        return;
    }
    
    if (![self checkInputTextFieldIsValid:self.birthDayTextField]) {
        return;
    }
    
    //v4.1.0 后台需要 年/月/日 格式
    NSString *birthday = self.birthDayTextField.text;
    if (ZFToString(birthday).length) {
        NSString *dateFormatter = [self gainRequestDateformatter:birthday];
        [self.uploadDateFormatter setDateFormat:dateFormatter];
        NSDate *date = [self.uploadDateFormatter dateFromString:birthday];
        [self.uploadDateFormatter setDateFormat:@"yyyy/MM/dd"];
        birthday = [self.uploadDateFormatter stringFromDate:date];
    }
    NSDictionary *dict = @{
                           @"firstname" : self.firstNameTextfield.text,
                           @"lastname"  : self.lastNameTextField.text,
                           @"nickname"  : self.nicknameTextField.text,
                           @"sex"       : [NSString stringWithFormat:@"%zd",self.sex],
                           @"phone"     : self.phoneTextField.text,
                           @"email"     : self.emailAddressTextField.text,
                           @"birthday"  : ZFToString(birthday),
                           kLoadingView : self.view
                           };
    ShowLoadingToView(self.view);
    @weakify(self)
    [self.viewModel requestSaveInfo:dict completion:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
        
        [self requestUserData:YES];
        
//        AccountModel *userInfoModel = [AccountManager sharedManager].account;
//        if (!userInfoModel) {
//            userInfoModel = [[AccountModel alloc] init];
//        }
//        userInfoModel.firstname = self.firstNameTextfield.text;
//        userInfoModel.lastname = self.lastNameTextField.text;
//        userInfoModel.nickname = self.nicknameTextField.text;
//        userInfoModel.sex = self.sex;
//        userInfoModel.phone = self.phoneTextField.text;
//        userInfoModel.email = self.emailAddressTextField.text;
//        userInfoModel.birthday = self.birthDayTextField.text;
//        //用户修改过生日，就设置为已修改过
//        if (!userInfoModel.is_update_birthday && ZFToString(self.birthDayTextField.text).length) {
//            userInfoModel.is_update_birthday = YES;
//        }
//        [[AccountManager sharedManager] editUserSomeItems:userInfoModel];
//        self.userModel = userInfoModel;
        
    } failure:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"Failed",nil));
    }];
}

// 设置textField不能输入文字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.birthDayTextField) {
        return NO;
    }
    if (textField.text.length + string.length > 35) {
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"Profile_Maxium_NickName_Message",nil));
        return NO;
    }
    return YES;
}

-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    }
    return _scrollView;
}

-(UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}

-(RadioButton *)femaleBtn {
    if (!_femaleBtn) {
        _femaleBtn = [[RadioButton alloc] initWithGroupId:@"sex" index:2 normalImage:[UIImage imageNamed:@"order_unchoose"] selectedImage:[UIImage imageNamed:@"order_choose"] title:ZFLocalizedString(@"Profile_Female", nil) color:[UIColor blackColor]];
        [RadioButton addObserverForGroupId:@"sex" observer:self];
    }
    return _femaleBtn;
}

-(RadioButton *)maleBtn{
    if (!_maleBtn) {
        _maleBtn = [[RadioButton alloc] initWithGroupId:@"sex" index:1 normalImage:[UIImage imageNamed:@"order_unchoose"] selectedImage:[UIImage imageNamed:@"order_choose"] title:ZFLocalizedString(@"Profile_Male", nil) color:[UIColor blackColor]];
        [RadioButton addObserverForGroupId:@"sex" observer:self];
    }
    return _maleBtn;
}

- (RadioButton *)privacyBtn {
    if (!_privacyBtn) {
        _privacyBtn = [[RadioButton alloc] initWithGroupId:@"sex" index:0 normalImage:[UIImage imageNamed:@"order_unchoose"] selectedImage:[UIImage imageNamed:@"order_choose"] title:ZFLocalizedString(@"Profile_Privacy", nil) color:[UIColor blackColor]];
        [RadioButton addObserverForGroupId:@"sex" observer:self];
    }
    return _privacyBtn;
}

/**
 *  设置邮箱不能编辑，不能更改TextField里的内容
 */
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.emailAddressTextField]) {
        return NO;
    }
    return YES;
}

-(UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //_saveBtn.backgroundColor = ZFCThemeColor();
        _saveBtn.layer.cornerRadius = 3;
        _saveBtn.layer.masksToBounds = YES;
        [_saveBtn setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_saveBtn setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        NSString *title = [ZFLocalizedString(@"Profile_Save_Button",nil) uppercaseString];
        [_saveBtn setTitle:title forState:UIControlStateNormal];
        [_saveBtn setTitleColor:ZFCOLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
        _saveBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [_saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveBtn;
}

- (UITextField *)setTextFieldPlaceholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType
{
    UITextField  *textField = [UITextField new];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.keyboardType = keyboardType;
    textField.returnKeyType = UIReturnKeyDone;
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 20)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.placeholder = placeholder;
    textField.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
    textField.textColor = ZFCOLOR(51, 51, 51, 1.0);
    if (kiOSSystemVersion < 13.0) {
        [textField setValue:ZFCOLOR(178, 178, 178, 1.0) forKeyPath:@"_placeholderLabel.textColor"];
        [textField setValue:[UIFont systemFontOfSize:14.0] forKeyPath:@"_placeholderLabel.font"];
    }
    textField.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    textField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    return textField;
}

///显示的dateFormatter v4.1.0
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setDateFormat:@"MM/dd/yyyy"];
    }
    return _dateFormatter;
}

///上传到后台的格式
-(NSDateFormatter *)uploadDateFormatter {
    if (!_uploadDateFormatter) {
        _uploadDateFormatter = [[NSDateFormatter alloc]init];
        [_uploadDateFormatter setDateFormat:@"yyyy/MM/dd"];
        _uploadDateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    }
    return _uploadDateFormatter;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        // 设置时区
        [_datePicker setTimeZone:[NSTimeZone localTimeZone]];
        //设置日期显示的格式
        _datePicker.datePickerMode = UIDatePickerModeDate;
        // 设置显示最大时间
        [_datePicker setMaximumDate:[NSDate dateWithTimeIntervalSinceNow:0]];
        // 设置当前显示时间
        NSString *birthday = [AccountManager sharedManager].account.birthday;
        if (birthday.length > 0 && ![birthday isEqualToString:EditDefalutDateString]) {
            YWLog(@"%@",birthday);
            NSDateFormatter *tempFormatter = [[NSDateFormatter alloc] init];
            
            //判断后台传过来的时间格式
            NSString *dateFormat = @"MM/dd/yyyy";
            dateFormat = [self gainRequestDateformatter:birthday];
            
            [tempFormatter setDateFormat:dateFormat];
            
            NSDate *date = [tempFormatter dateFromString:birthday];
            
            //显示给用户看的时间格式
            NSString *dateString = [self.dateFormatter stringFromDate:date];
            
            NSDate *newDate = [self.dateFormatter dateFromString:dateString];
            if (newDate) {
                // 怕出现  newDate == nil 的情况
                [_datePicker setDate:newDate];
            }
        } else {
            [_datePicker setDate:[NSDate dateWithTimeIntervalSinceNow:-(365 * 24 * 3600 * 20)]];
        }
        
        //监听datePicker的ValueChanged事件
        [_datePicker addTarget:self action:@selector(datePickerValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (ModifyPorfileViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ModifyPorfileViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (ZFAccountViewModel *)accountViewModel {
    if (!_accountViewModel) {
        _accountViewModel = [[ZFAccountViewModel alloc] init];
        _accountViewModel.controller = self;
    }
    return _accountViewModel;
}

- (UIImageView *)toastImageView {
    if (!_toastImageView) {
        _toastImageView = [[UIImageView alloc] init];
        UIImage *originImage = [UIImage imageNamed:@"mine_profile_pointtoast"];
        _toastImageView.image = [originImage imageWithColor:ZFCThemeColor()];;
    }
    return _toastImageView;
}

- (UILabel *)toastLabel {
    if (!_toastLabel) {
        _toastLabel               = [[UILabel alloc] init];
        _toastLabel.font          = [UIFont systemFontOfSize:14.0];
        _toastLabel.textColor     = ZFCOLOR(51, 51, 51, 1.0);
        _toastLabel.numberOfLines = 0;
    }
    return _toastLabel;
}

- (UILabel *)emalLabel {
    if (!_emalLabel) {
        _emalLabel               = [[UILabel alloc] init];
        _emalLabel.font          = [UIFont systemFontOfSize:14.0];
        _emalLabel.textColor     = [UIColor grayColor];
        _emalLabel.text = ZFLocalizedString(@"Profile_EmailAddress_Placeholder",nil);
    }
    return _emalLabel;
}

//- (UIView *)birthdayTipsView
//{
//    if (!_birthdayTipsView) {
//        _birthdayTipsView = ({
//            UIView *view = [[UIView alloc] init];
//            view.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
//            YYAnimatedImageView *icon = [[YYAnimatedImageView alloc] init];
//            icon.image = [YYImage imageNamed:@"jumpGift.gif"];
//            [view addSubview:icon];
//            [icon mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.leading.mas_equalTo(10);
//                make.centerY.mas_equalTo(view.mas_centerY);
//                make.size.mas_offset(CGSizeMake(22, 22));
//            }];
//            UILabel *label = [[UILabel alloc] init];
//            label.text = ZFLocalizedString(@"Account_birthday_tips", nil);
//            label.numberOfLines = 0;
//            label.textColor = ZFC0x999999();
//            label.font = [UIFont systemFontOfSize:12];
//            [view addSubview:label];
//            [label mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(view.mas_top).mas_offset(11);
//                make.leading.mas_equalTo(icon.mas_trailing).mas_offset(2);
//                make.trailing.mas_equalTo(view.mas_trailing).mas_offset(-14);
//                make.bottom.mas_equalTo(view.mas_bottom).mas_offset(-11);
//            }];
//            view;
//        });
//    }
//    return _birthdayTipsView;
//}

- (void)isShowToast:(BOOL)isShow {
    self.toastImageView.hidden = !isShow;
    self.toastLabel.hidden     = !isShow;
    CGFloat height  = isShow ? 18.0f : 0.0f;
    CGFloat offsetY = isShow ? 20.0f : 0.0f;
    [self.toastImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(height);
        make.top.mas_equalTo(self.containerView).offset(offsetY);
    }];
    [self.toastLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_greaterThanOrEqualTo(height);
        make.top.mas_equalTo(self.containerView).offset(offsetY);
    }];
}

@end

