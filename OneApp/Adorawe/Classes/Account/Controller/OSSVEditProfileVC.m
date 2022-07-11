//
//  OSSVEditProfileVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVEditProfileVC.h"
#import "OSSVChangePasswordVC.h"
#import "OSSVEditsProfiledViewModel.h"
#import "STLTextField.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import "Adorawe-Swift.h"

static NSString *const EditDefalutDateString = @"0000-00-00"; // 有时默认返回一个这样的数值，防止出错
static NSString *const ArEditDefalutDateString = @"00-00-0000"; // 有时默认返回一个这样的数值，防止出错

typedef NS_ENUM(NSUInteger, MyPhotoChooseType){
    MyPhotoTakePhotoType = 0,  //来源:相机
    MyPhotoAlbumsType = 1     //来源:相册
};

@interface OSSVEditProfileVC ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIButton               *changePasswordButton;
@property (nonatomic, strong) UIView                 *backView;
@property (nonatomic, strong) UIButton               *photoButton;
@property (nonatomic, strong) YYAnimatedImageView    *headImageView;
@property (nonatomic, strong) UIView                 *lineView;
@property (nonatomic, strong) UILabel                *nickNameLabel;
@property (nonatomic, strong) STLTextField            *nickNameTextField;
@property (nonatomic, strong) UILabel                *birthdayLabel;
@property (nonatomic, strong) STLTextField            *birthdayTextField;
@property (nonatomic, strong) UILabel                *genderTitle;
@property (nonatomic, strong) UIButton               *maleButton;
@property (nonatomic, strong) UIButton               *femaleButton;
@property (nonatomic, strong) UILabel                *emailLabel;
@property (nonatomic, strong) UIButton               *confirmEditButton;

@property (nonatomic, strong) OSSVEditsProfiledViewModel   *viewModel;

@property (nonatomic, strong) UIDatePicker           *datePicker;
@property (nonatomic, strong) NSDateFormatter        *dateFormatter;
@property (nonatomic, strong) NSString               *sexString;
@property (nonatomic, strong) NSString               *imageString;

@end

@implementation OSSVEditProfileVC

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 谷歌统计
    if (!self.firstEnter) {
        self.firstEnter = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"editProfile", nil);
    self.view.backgroundColor = OSSVThemesColors.col_F1F1F1;
    [self initSubViews];
    
    // 默认设置 sex
    switch ([OSSVAccountsManager sharedManager].account.sex) {
        case UserEnumSexTypeMale: // @"0"
            self.maleButton.selected = YES;
            self.femaleButton.selected = NO;
            break;
        case UserEnumSexTypeFemale: // @"1"
            self.femaleButton.selected = YES;
            self.maleButton.selected = NO;
            break;
        case UserEnumSexTypeDefault: // @"2",此处也可以省略
            self.femaleButton.selected = NO;
            self.maleButton.selected = NO;
            break;
        default:
            break;
    }
    
    // 默认性别字符串
    self.sexString = [NSString stringWithFormat:@"%lu",(unsigned long)[OSSVAccountsManager sharedManager].account.sex];
    
    //约束
    [self makeConstraints];
    
    // 图片的设置 以及字符串的初始化
    self.imageString = @"";
    if ([[OSSVAccountsManager sharedManager].account.avatar hasPrefix:@"http"]) {
        // 此处是防止用户，已经选过后，再重新修改而没有修改图像这个地方的
        self.imageString = [OSSVAccountsManager sharedManager].account.avatar;
    }
    
    [self.headImageView yy_setImageWithURL:[NSURL URLWithString:[OSSVAccountsManager sharedManager].account.avatar]
                               placeholder:[UIImage imageNamed:@"photo_default"]
                                   options:YYWebImageOptionShowNetworkActivity
                                  progress:nil
                                 transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                     //image = [image yy_imageByResizeToSize:CGSizeMake(42,42) contentMode:UIViewContentModeScaleAspectFit];
                                     //image = [image yy_imageByRoundCornerRadius:21 borderWidth:1.0 borderColor:[UIColor clearColor]];
                                     return image;
                                 }
                                completion:nil];
    
    AccountModel *account = [OSSVAccountsManager sharedManager].account;
    if ([account.birthday isEqualToString:EditDefalutDateString] || [account.birthday isEqualToString:ArEditDefalutDateString]) {
//        NSDateFormatter *tempFormatter = [[NSDateFormatter alloc] init];
//        [tempFormatter setDateFormat:@"yyyy-MM-dd"];
//        NSDate *date = [tempFormatter dateFromString:[OSSVAccountsManager sharedManager].account.birthday];
//        NSString *dateString = [self.dateFormatter stringFromDate:date];
        self.birthdayTextField.text = @"";
    } else {
        self.birthdayTextField.text = STLToString([OSSVAccountsManager sharedManager].account.birthday);
    }
}

#pragma mark - MakeUI
- (void)initSubViews {
    
    [self.view addSubview:self.changePasswordButton];
    [self.view addSubview:self.backView];
    [self.view addSubview:self.confirmEditButton];
    
    [self.backView addSubview:self.photoButton];
    [self.backView addSubview:self.lineView];
    [self.backView addSubview:self.nickNameLabel];
    [self.backView addSubview:self.nickNameTextField];
    [self.backView addSubview:self.birthdayLabel];
    [self.backView addSubview:self.birthdayTextField];
    [self.backView addSubview:self.emailLabel];
    [self.backView addSubview:self.genderTitle];
    [self.backView addSubview:self.maleButton];
    [self.backView addSubview:self.femaleButton];
    
    [self.photoButton addSubview:self.headImageView];
    
    self.birthdayTextField.inputView = self.datePicker;

    
}

- (void)makeConstraints {
    
    [self.changePasswordButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.and.leading.and.trailing.mas_equalTo(@0);
        make.height.mas_equalTo(@40);
    }];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.changePasswordButton.mas_bottom).offset(10);
        make.leading.trailing.equalTo(@0);
    }];
    
    // 假如是faceBook 登录，需要隐藏修改密码
    if ([[NSUserDefaults standardUserDefaults]boolForKey:kUserFacebookLogin]){
        self.changePasswordButton.hidden = YES;
        [self.backView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.leading.and.trailing.mas_equalTo(@0);
        }];
    }
    
    [self.photoButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.and.leading.and.trailing.mas_equalTo(@0);
        make.height.mas_equalTo(@60);
    }];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make){
        make.trailing.mas_equalTo(@(-30));
        make.centerY.mas_equalTo(self.photoButton.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.backView.mas_leading).mas_offset(10);
        make.trailing.mas_equalTo(self.backView.mas_trailing).mas_offset(-10);
        make.height.mas_equalTo(@0.5);
        make.bottom.equalTo(self.photoButton.mas_bottom);
    }];
    
    [self.nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView.mas_bottom).offset(10);
        make.leading.mas_equalTo(@10);
        make.trailing.mas_equalTo(@(-10));
        make.height.mas_equalTo(@20);
    }];
    
    [self.nickNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nickNameLabel.mas_bottom).offset(5);
        make.leading.trailing.equalTo(self.nickNameLabel);
        make.height.mas_equalTo(@40);
    }];
    
    [self.birthdayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nickNameTextField.mas_bottom).offset(10);
        make.leading.trailing.equalTo(self.nickNameLabel);
        make.height.mas_equalTo(@20);
    }];
    
    [self.birthdayTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.birthdayLabel.mas_bottom).offset(5);
        make.leading.trailing.equalTo(self.nickNameLabel);
        make.height.mas_equalTo(@40);
    }];
    
    [self.emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.birthdayTextField.mas_bottom).offset(10);
        make.leading.trailing.equalTo(self.birthdayTextField);
        make.height.mas_equalTo(@(25));
    }];
    
    [self.genderTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailLabel.mas_bottom).offset(10);
        make.leading.trailing.equalTo(self.nickNameLabel);
        make.height.mas_equalTo(@20);
    }];
    
    [self.maleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.genderTitle.mas_bottom).offset(10);
        make.leading.equalTo(self.birthdayTextField.mas_leading);
        make.width.mas_equalTo(@80);
        make.height.mas_equalTo(@(22));
    }];
    
    [self.femaleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.genderTitle.mas_bottom).offset(10);
        make.leading.equalTo(self.maleButton.mas_trailing).offset(10);
        make.width.mas_equalTo(@80);
        make.height.mas_equalTo(@(22));
    }];
    
    [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.femaleButton.mas_bottom).offset(15);
    }];
    
    [self.confirmEditButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.backView.mas_bottom).offset(20);
        make.leading.mas_equalTo(@(30));
        make.width.mas_equalTo(@(SCREEN_WIDTH - 60));
        make.height.mas_equalTo(@40);
    }];
}

#pragma mark - 修改密码
- (void)changePasswordAction {
    OSSVChangePasswordVC * changePasswordVC = [[OSSVChangePasswordVC alloc] init];
    [self.navigationController pushViewController:changePasswordVC animated:YES];
}

#pragma mark 提交
- (void)confirmEditAction {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    // 判断输入的情况是否达到要求
    if (![self checkInputTextIsValid]) return;
    
    // 修改全局默认参数, 以此为准
    [OSSVAccountsManager sharedManager].account.sex = [self.sexString intValue];
    ///<后台修改，去掉性别属性，默认为女性1
    // 接口参数
    NSDictionary *dic = @{
                          EditKeyOfNickName   : self.nickNameTextField.text,
                          EditKeyOfSex        : self.sexString,
                          EditKeyOfBirthday   : self.birthdayTextField.text,
                          EditKeyOfAvatar     : self.imageString
                          };

//    [HUDManager showLoading:[UIColor clearColor] contentColor:[UIColor lightGrayColor]];
    @weakify(self)
    [self.viewModel requestNetwork:dic completion:^(id obj){
        @strongify(self)
        // 同时 对AccountVC头部要刷新 的处理
        if (obj) {
            // 改变用户信息通知
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_ChangeUserInfo object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_ChangeGender object:nil];

            @weakify(self)
            [HUDManager showHUDWithMessage:STLLocalizedString_(@"editSuccess", nil) afterDelay:1 completionBlock:^{
                @strongify(self)
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            [HUDManager hiddenHUD];
            [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkFailed", nil)];
        }

    } failure:^(id obj){
        [HUDManager hiddenHUD];
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkFailed", nil)];
    }];
}

#pragma mark 日期
- (void)datePickerValueChange:(UIDatePicker *)datePicker{
    NSString *dateStr = [self.dateFormatter stringFromDate:datePicker.date];
    self.birthdayTextField.text = dateStr;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField;{
    if (!CGColorEqualToColor(textField.layer.borderColor,OSSVThemesColors.col_DDDDDD.CGColor)) {
        textField.layer.borderColor = OSSVThemesColors.col_DDDDDD.CGColor;
    }
    
    if (textField == self.birthdayTextField) {
        //确保加载时也能获取datePicker的文字
        [self datePickerValueChange:self.datePicker];
    }
}

// 设置textField不能输入文字
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.birthdayTextField) {
        return NO;
    }
    if (textField.text.length + string.length > 32) {
//        [self showHUDText:STLLocalizedString_(@"nickNameMaxLenght", nil) mode:MBProgressHUDModeCustomView];
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.birthdayTextField) {
        [GATools logEditProfileWithAction:@"Birthday_Confirm" screenGroup:@"EditProfile"];
    }
}

#pragma mark 选择性别
- (void)chooseMaleAction:(UIButton *)button {

    NSInteger index;
    if (button == self.maleButton) {

        if (self.maleButton.selected) return;
        self.maleButton.selected = !self.maleButton.selected;
        self.femaleButton.selected =  !self.maleButton.selected;
        index = UserEnumSexTypeMale;
    }
    else {

        if (self.femaleButton.selected) return;
        self.femaleButton.selected = !self.femaleButton.selected;
        self.maleButton.selected = !self.femaleButton.selected;
        index = UserEnumSexTypeFemale;
    }
    [GATools logEditProfileWithAction:@"Select_Gender" screenGroup:@"EditProfile"];
    self.sexString = [NSString stringWithFormat:@"%lu",(long)index];
}

#pragma mark - 选择照片
- (void)choosePhotoAction {
    [GATools logEditProfileWithAction:@"Change_Avatar" screenGroup:@"EditProfile"];
    STLAlertViewController *alertController =  [STLAlertViewController
                                           alertControllerWithTitle: nil
                                           message:nil
                                           preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * takePhotoAction = [UIAlertAction actionWithTitle:STLLocalizedString_(@"takePhoto",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self goToChoosePhotoAction:MyPhotoTakePhotoType];
    }];
    UIAlertAction * albumsAction = [UIAlertAction actionWithTitle:STLLocalizedString_(@"chooseAlbums",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self goToChoosePhotoAction:MyPhotoAlbumsType];
    }];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"cancel",nil) : STLLocalizedString_(@"cancel",nil).uppercaseString style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        
    }];
    [alertController addAction:takePhotoAction];
    [alertController addAction:albumsAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 进入拍照或选择照片
- (void)goToChoosePhotoAction:(MyPhotoChooseType)chooseType {
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (chooseType) {
            case MyPhotoTakePhotoType:
            {
                if (![self isCanUseCamera]) {
                    [self showOpenTheUsePermission:STLLocalizedString_(@"cameraNotPermission", nil)];
                    return;
                }
                sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePickerController.allowsEditing = YES;
            }
                break;
            case MyPhotoAlbumsType:
            {
                // 系统会自动有图提示，此处可以不做判断？？？？
//                if (![self isCanUsePhotos]) {
//                     [self showOpenTheUsePermission:STLLocalizedString_(@"photoNotPermission", nil)];
//                    return;
//                }
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
                break;
            default:
                break;
        }
    }
    else {
        if(chooseType == MyPhotoTakePhotoType) {
            [self showHUDText:STLLocalizedString_(@"cameraUnavailable", nil) mode:MBProgressHUDModeCustomView];
            STLLog(@"sorry, no camera or camera is unavailable.");
            return;
        }
        else {
            if (![self isCanUsePhotos]) {
                 [self showOpenTheUsePermission:STLLocalizedString_(@"photoNotPermission", nil)];
                return;
            }
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
    }
    

    imagePickerController.delegate = self;
    imagePickerController.sourceType = sourceType;
    imagePickerController.allowsEditing = YES;
    imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

//判断用户是否有权限访问相册
- (BOOL)isCanUsePhotos {

    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        //无权限
        return NO;
    }
    return YES;
}

// 判断用户是否有权限访问相机
- (BOOL)isCanUseCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        //无权限
        return NO;
    }
    return YES;
}

- (void)showOpenTheUsePermission:(NSString *)showInformation {
    
    STLAlertViewController *alertController =  [STLAlertViewController
                                           alertControllerWithTitle: showInformation
                                           message:nil
                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:STLLocalizedString_(@"done", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIImagePickerController Delegate
// 照片选完后返回
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = nil;
    if (picker.allowsEditing) {
         image = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    else {
         image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    // 对图片进行尺寸处理 80 / 320 = 0.25
    image = [self scaleImage:image toScale:0.5];
    // 对图片进行压缩
    NSData *imageData = [self compressImageWithOriginImage:image];
    // 将图片以base64的字符串返回
    self.imageString = [imageData base64String];
    // 临时对 headImageView 进行赋值
    self.headImageView.image = image;
}


//点击cancel 调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark - 对图片进行处理
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize {
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (NSData *)compressImageWithOriginImage:(UIImage *)originImage {
    NSData* imageData;
    float i = 1.0;
    do {
        imageData = UIImageJPEGRepresentation(originImage, i);
        i -= 0.1;
    } while (imageData.length > 2*1024*1024);
    return imageData;
}

#pragma mark - Error HUD
- (BOOL)checkInputTextIsValid {

    /**
     *  注意此处的提示语已经是国际化啦
     */
    BOOL isCheckValid = YES;
    NSString *showHudErrorString = nil;
    if ([OSSVNSStringTool isEmptyString:self.nickNameTextField.text]) {
        [self showErrorBorderColorWithTextField:self.nickNameTextField];
        showHudErrorString = !isCheckValid ? showHudErrorString : STLLocalizedString_(@"nickNameEmpty", nil);
        isCheckValid = NO;
    }
    if (!(self.nickNameTextField.text.length > 1)) {
        [self showErrorBorderColorWithTextField:self.nickNameTextField];
        showHudErrorString = !isCheckValid ? showHudErrorString : STLLocalizedString_(@"nickNameMinLenght", nil);
        isCheckValid = NO;
       
    }
    if ((self.nickNameTextField.text.length > 32)) {
//        [self showErrorBorderColorWithTextField:self.nickNameTextField];
//        showHudErrorString = !isCheckValid ? showHudErrorString : STLLocalizedString_(@"nickNameMaxLenght", nil);
        isCheckValid = NO;
        return isCheckValid;
    }
    // 此处可以不是必填项目
//    if ([OSSVNSStringTool isEmptyString:self.birthdayTextField.text])  {
//    
//        [self showErrorBorderColorWithTextField:self.birthdayTextField];
//        showHudErrorString = !isCheckValid ? showHudErrorString : @"birthday";
//        isCheckValid = NO;
//    }
    if (!isCheckValid) {
        [self showHUDText:showHudErrorString mode:MBProgressHUDModeCustomView];
    }
    return isCheckValid;
}

- (void)showHUDText:(NSString *)text mode:(MBProgressHUDMode)mode {
    if (mode == MBProgressHUDModeCustomView) {
        [HUDManager showHUDWithMessage:STLToString(text) customView:[[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"prompt"]]];
    } else {
        [HUDManager showHUDWithMessage:STLToString(text)];
    }
}

- (void)showErrorBorderColorWithTextField:(STLTextField *)textField {
    textField.layer.borderColor = [UIColor redColor].CGColor;
}

#pragma mark - LazyLoad

- (STLTextField *)createTextFieldWithPlaceholder:(NSString *)placeholder {
    
    STLTextField *textField = [[STLTextField alloc] init];
    textField.delegate = self;
    textField.font = [UIFont systemFontOfSize:12];
    textField.placeholder = placeholder;
    textField.layer.borderColor = [OSSVThemesColors.col_DDDDDD CGColor];
    textField.layer.borderWidth = 0.5;
    textField.layer.cornerRadius = 4.0;
    textField.layer.masksToBounds = YES;
    textField.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    return textField;
}

- (OSSVEditsProfiledViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVEditsProfiledViewModel alloc] init];
    }
    return _viewModel;
}

- (UIButton *)changePasswordButton {
    if (!_changePasswordButton) {
        _changePasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changePasswordButton setTitle:STLLocalizedString_(@"changePassword",nil) forState:UIControlStateNormal];
        _changePasswordButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_changePasswordButton setImage:[UIImage imageNamed:[OSSVSystemsConfigsUtils isRightToLeftShow] ? @"arrow_left" : @"arrow_right"] forState:UIControlStateNormal];
        [_changePasswordButton setTitleColor:OSSVThemesColors.col_333333 forState:UIControlStateNormal];
        /*
         * ImageView.x的计算规则有一点变化了：（button的宽度 - 离左右的距离 - 图片的宽度 -Label的宽度）/ 2 + 离左边的距离。
         * Label.x 的计算规则：（button的宽度 - 离左右的距离 - 图片的宽度 -Label的宽度）/ 2 + 离左边的距离 + 图片的宽度
         */
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_changePasswordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            // 为什么 此处不准呢 ---- 应该 IEdgeInsetsMake(0, 10, 0, 0)？
            [_changePasswordButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 0)];
            [_changePasswordButton setImageEdgeInsets:UIEdgeInsetsMake(0, -SCREEN_WIDTH+20, 0, SCREEN_WIDTH-20)];
        } else {
            [_changePasswordButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            // 为什么 此处不准呢 ---- 应该 IEdgeInsetsMake(0, 10, 0, 0)？
            [_changePasswordButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
            [_changePasswordButton setImageEdgeInsets:UIEdgeInsetsMake(0, SCREEN_WIDTH - 20, 0, 0)];
        }
        _changePasswordButton.backgroundColor = [UIColor whiteColor];
        [_changePasswordButton addTarget:self action:@selector(changePasswordAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changePasswordButton;
}

- (UIView *)backView {
    if (!_backView) {
        _backView  = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
    }
    return _backView;
}

- (UIButton *)photoButton {
    if (!_photoButton) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoButton setTitle:STLLocalizedString_(@"myPhotoTitle",nil) forState:UIControlStateNormal];
        _photoButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_photoButton setImage:[UIImage imageNamed:[OSSVSystemsConfigsUtils isRightToLeftShow] ? @"arrow_left" : @"arrow_right"] forState:UIControlStateNormal];
        [_photoButton setTitleColor:OSSVThemesColors.col_333333 forState:UIControlStateNormal];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_photoButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
            // 为什么 此处不准呢 ---- 应该 IEdgeInsetsMake(0, 10, 0, 0)？
            [_photoButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 0)];
            [_photoButton setImageEdgeInsets:UIEdgeInsetsMake(0, -SCREEN_WIDTH + 20, 0, SCREEN_WIDTH - 20)];
            
        } else {
            [_photoButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            // 为什么 此处不准呢 ---- 应该 IEdgeInsetsMake(0, 10, 0, 0)？
            [_photoButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
            [_photoButton setImageEdgeInsets:UIEdgeInsetsMake(0, SCREEN_WIDTH - 20, 0, 0)];
            
        }
        _photoButton.backgroundColor = [UIColor whiteColor];
        [_photoButton addTarget:self action:@selector(choosePhotoAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoButton;
}

- (YYAnimatedImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[YYAnimatedImageView alloc] init];
        _headImageView.contentMode = UIViewContentModeScaleAspectFill;
        _headImageView.clipsToBounds = YES;
        _headImageView.userInteractionEnabled = NO;
        _headImageView.layer.cornerRadius = 21.0f;
        _headImageView.layer.allowsEdgeAntialiasing = true;
        _headImageView.layer.borderColor = [UIColor clearColor].CGColor;
        _headImageView.layer.borderWidth = 1.0f;
        _headImageView.layer.masksToBounds = YES;
    }
    return _headImageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView =[[UIView alloc] init];
        _lineView.backgroundColor = OSSVThemesColors.col_DDDDDD;
    }
    return _lineView;
}

- (UILabel *)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] init];
        _nickNameLabel.text = STLLocalizedString_(@"nickNameTitle", nil);
        _nickNameLabel.textColor = OSSVThemesColors.col_333333;
        _nickNameLabel.font = [UIFont systemFontOfSize:14];
    }
    return _nickNameLabel;
}

- (STLTextField *)nickNameTextField {
    if (!_nickNameTextField) {
        _nickNameTextField = [self createTextFieldWithPlaceholder:STLLocalizedString_(@"nickNameTitle", nil)];
        _nickNameTextField.text = [OSSVAccountsManager sharedManager].account.nickName > 0 ? [OSSVAccountsManager sharedManager].account.nickName : @"";
        _nickNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _nickNameTextField;
}

- (UILabel *)birthdayLabel {
    if (!_birthdayLabel) {
        _birthdayLabel = [[UILabel alloc] init];
        _birthdayLabel.text = STLLocalizedString_(@"birthDayTitle", nil);
        _birthdayLabel.font = [UIFont systemFontOfSize:14];
        _birthdayLabel.textColor = OSSVThemesColors.col_333333;
    }
    return _birthdayLabel;
}

- (STLTextField *)birthdayTextField {
    if (!_birthdayTextField) {
        _birthdayTextField = [self createTextFieldWithPlaceholder:STLLocalizedString_(@"birthDayTitle", nil)];
    }
    return _birthdayTextField;
}

- (UILabel *)emailLabel {
    if (!_emailLabel) {
        _emailLabel = [[UILabel alloc] init];
        _emailLabel.textColor = [UIColor grayColor];
        _emailLabel.text = [OSSVSystemsConfigsUtils isRightToLeftShow] ? [NSString stringWithFormat:@"%@:%@",[OSSVAccountsManager sharedManager].account.email, STLLocalizedString_(@"signPlaceholderEmail", nil)] : [NSString stringWithFormat:@"%@:%@",STLLocalizedString_(@"signPlaceholderEmail", nil),[OSSVAccountsManager sharedManager].account.email];
        _emailLabel.font = [UIFont systemFontOfSize:14];
    }
    return _emailLabel;
}

- (UIButton *)confirmEditButton {
    if (!_confirmEditButton) {
        _confirmEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmEditButton setTitle:STLLocalizedString_(@"editConfirmEditButtonTitle", nil) forState:UIControlStateNormal];
        _confirmEditButton.backgroundColor = [OSSVThemesColors col_262626];
        [_confirmEditButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmEditButton.layer.cornerRadius = 4;
        [_confirmEditButton addTarget:self action:@selector(confirmEditAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmEditButton;
}

- (UILabel *)genderTitle {
    if (!_genderTitle) {
        _genderTitle = [[UILabel alloc] init];
        _genderTitle.text = STLLocalizedString_(@"Gender", nil);
        _genderTitle.font = [UIFont systemFontOfSize:14];
        _genderTitle.textColor = OSSVThemesColors.col_333333;
    }
    return _genderTitle;
}

- (UIButton *)maleButton {
    if (!_maleButton) {
        _maleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_maleButton setImage:[UIImage imageNamed:@"sex_normal"] forState:UIControlStateNormal];
        [_maleButton setImage:[UIImage imageNamed:@"sex_selected"] forState:UIControlStateSelected];
        [_maleButton setTitle:STLLocalizedString_(@"sexTitleOfMale", nil) forState:UIControlStateNormal];
        [_maleButton setTitleColor:OSSVThemesColors.col_333333 forState:UIControlStateNormal];
        _maleButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_maleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_maleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 25, 0, -25)];
            [_maleButton setImageEdgeInsets:UIEdgeInsetsMake(0, 35, 0, -35)];
        } else {
            [_maleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
        }
        [_maleButton addTarget:self action:@selector(chooseMaleAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _maleButton;
}

- (UIButton *)femaleButton {
    if (!_femaleButton) {
        _femaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_femaleButton setImage:[UIImage imageNamed:@"sex_normal"] forState:UIControlStateNormal];
        [_femaleButton setImage:[UIImage imageNamed:@"sex_selected"] forState:UIControlStateSelected];
        [_femaleButton setTitle:STLLocalizedString_(@"sexTitleOfFemale", nil) forState:UIControlStateNormal];
        [_femaleButton setTitleColor:OSSVThemesColors.col_333333 forState:UIControlStateNormal];
        _femaleButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_femaleButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_femaleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
            [_femaleButton setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -20)];
        } else {
            [_femaleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
        }
        [_femaleButton addTarget:self action:@selector(chooseMaleAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _femaleButton;
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
        if ([OSSVAccountsManager sharedManager].account.birthday.length > 0 && ![[OSSVAccountsManager sharedManager].account.birthday isEqualToString:EditDefalutDateString]) {
            NSDate *newDate = [self.dateFormatter dateFromString:[OSSVAccountsManager sharedManager].account.birthday];
            if (newDate) {
                // 怕出现  newDate == nil 的情况
                [_datePicker setDate:newDate];
            }
        }
        else {
            [_datePicker setDate:[NSDate dateWithTimeIntervalSinceNow:-(365 * 24 * 3600 * 20)]];
        }
    
        
        //用先前滚动的样式，然后设置frame
        if (@available(iOS 13.4, *)) {
            [_datePicker setPreferredDatePickerStyle:UIDatePickerStyleWheels];
        } else {
        }
        _datePicker.frame = CGRectMake(0, 300 + 0.5, SCREEN_WIDTH, 300);
        
        // 设置最小时间  没有用
//        [_datePicker setMinimumDate:[NSDate dateWithTimeIntervalSinceNow:-(365 * 24 * 3600 * 100)]];
        //监听datePicker的ValueChanged事件
        [_datePicker addTarget:self action:@selector(datePickerValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

/**
 *  优化的角度出发：
    NSDateFormatter 初始化非常耗时，当有多个的时候尽量复用
 */
- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            [_dateFormatter setDateFormat:@"dd-MM-yyyy"];
//        } else {
            [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
//        }
    }
    return _dateFormatter;
}

@end
