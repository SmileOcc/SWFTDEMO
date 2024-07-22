//
//  ZFUserInfoViewController.m
//  ZZZZZ
//
//  Created by YW on 2020/1/9.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import "ZFUserInfoViewController.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFInitViewProtocol.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "ZFProgressHUD.h"
#import "YWCFunctionTool.h"
#import "UIImage+ZFExtended.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "NSStringUtils.h"
#import "ZFSystemPhototHelper.h"

#import "ZFUserInfoEditWriteVC.h"
#import "ZFUserInfoHeader.h"
#import "ZFUserInfoPointsInfoView.h"
#import "ZFUserInfoPhotoCell.h"
#import "ZFUserInfoTypeCell.h"
#import "ZFActionSheetView.h"

#import "ZFUserInfoTypeModel.h"
#import "ModifyPorfileViewModel.h"
#import "ZFAccountViewModel.h"
#import "AccountManager.h"

static NSString *const ZFUserEditDefalutDateString = @"0000-00-00";

@interface ZFUserInfoViewController ()<ZFInitViewProtocol,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) AccountModel                *userModel;
@property (nonatomic, strong) ModifyPorfileViewModel      *viewModel;
@property (nonatomic, strong) ZFAccountViewModel          *accountViewModel;
@property (nonatomic, strong) NSMutableArray              *sourceDatas;

@property (nonatomic, strong) UITableView                 *tableView;
@property (nonatomic, strong) ZFUserInfoPointsInfoView    *pointsView;
@property (nonatomic, strong) UIView                      *footerView;
@property (nonatomic, strong) UIButton                    *saveButton;
@property (nonatomic, strong) UIDatePicker                *datePicker;
@property (nonatomic, strong) UITextField                 *birthDayTextField;

@property (nonatomic, strong) UIImage                     *updateUserImage;


@property (nonatomic, assign) NSUInteger                  sex;
@property (nonatomic, strong) NSDateFormatter             *dateFormatter;
@property (nonatomic, strong) NSDateFormatter             *uploadDateFormatter;

@end

@implementation ZFUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = ZFC0xF7F7F7();
    self.title = ZFLocalizedString(@"Profile_VC_Title",nil);
    
    [self configurateDatas];
    [self zfInitView];
    [self zfAutoLayoutView];
    [self.tableView reloadData];
    
    [self requestUserData:NO];

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

- (void)zfInitView {
    [self.view addSubview:self.pointsView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.birthDayTextField];
    [self.footerView addSubview:self.saveButton];
    self.tableView.tableFooterView = self.footerView;
    
    self.birthDayTextField.inputView = self.datePicker;
}

- (void)zfAutoLayoutView {
    
    [self.pointsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(0);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.pointsView.mas_bottom);
    }];
    
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.footerView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.footerView.mas_trailing).offset(-16);
        make.top.mas_equalTo(self.footerView.mas_top).offset(12);
        make.height.mas_equalTo(40);
    }];
}

#pragma mark - Action

- (void)showUserPoints {
    if (!ZFIsEmptyString(self.userModel.point_tips)) {
        self.pointsView.hidden = NO;
        self.pointsView.pointsMessageLabel.text = self.userModel.point_tips;
        [self.pointsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.mas_equalTo(self.view);
            make.height.mas_greaterThanOrEqualTo(32);
        }];
    } else {
        self.pointsView.hidden = YES;
        self.pointsView.pointsMessageLabel.text = @"";
        [self.pointsView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.view.mas_top).offset(12);
            make.leading.trailing.mas_equalTo(self.view);
            make.height.mas_equalTo(0);
        }];
    }
}

- (void)updateTypeModel:(ZFUserInfoTypeModel *)typeModel {
    
    ZFUserInfoEditType type = typeModel.editType;
    
    switch (type) {
        case ZFUserInfoEditTypePhoto:{
            
        }
            break;
        case ZFUserInfoEditTypeFirstName:{
            typeModel.content = ZFToString(self.userModel.firstname);
        }
            break;
        case ZFUserInfoEditTypeLastName:{
            typeModel.content = ZFToString(self.userModel.lastname);
        }
            break;
        case ZFUserInfoEditTypeNickName:{
            typeModel.content = ZFToString(self.userModel.nickname);
        }
            break;
        case ZFUserInfoEditTypeGender:{
            self.sex = self.userModel.sex;
            typeModel.content = [self stringSexGender:self.sex];
        }
            break;
        case ZFUserInfoEditTypeBrithday:{
            NSDateFormatter *tempFormatter = [[NSDateFormatter alloc] init];
            NSString *dateFormat = [self gainRequestDateformatter:self.userModel.birthday];
            [tempFormatter setDateFormat:dateFormat];
            NSDate *date = [tempFormatter dateFromString:self.userModel.birthday];
            NSString *dateString = [self.dateFormatter stringFromDate:date];
            typeModel.content = dateString;
            
            if (!ZFIsEmptyString(dateString)) {
                if (self.userModel.is_update_birthday) {
                    typeModel.isShowArrow = YES;
                } else {
                    typeModel.isShowArrow = NO;
                }
            }
        }
            break;
        case ZFUserInfoEditTypePhone:{
            typeModel.content = ZFToString(self.userModel.phone);
        }
            break;
        case ZFUserInfoEditTypeEmail:{
            typeModel.content = ZFToString(self.userModel.email);
        }
            break;
            
        default:
            break;
    }
    [self.tableView reloadData];
}

- (NSString *)stringSexGender:(UserEnumSexType )sexType {
    if (self.userModel.sex == 1) {
        return  ZFLocalizedString(@"Profile_Male", nil);
    } else if(self.userModel.sex == 2) {
        return ZFLocalizedString(@"Profile_Female", nil);
    }
    return ZFLocalizedString(@"Profile_Privacy", nil);
}

- (void)configurateDatas {
    
    NSMutableArray *sectionDatas = [[NSMutableArray alloc] init];
    ZFUserInfoTypeModel *model = [[ZFUserInfoTypeModel alloc] init];
    model.editType = ZFUserInfoEditTypePhoto;
    model.typeName = ZFLocalizedString(@"Account_Change_Photo", nil);
    model.isShowArrow = YES;
    [sectionDatas addObject:model];
    [self.sourceDatas addObject:sectionDatas];
    
    
    NSMutableArray *secondSectionDatas = [[NSMutableArray alloc] init];

    model = [[ZFUserInfoTypeModel alloc] init];
    model.editType = ZFUserInfoEditTypeFirstName;
    model.typeName = ZFLocalizedString(@"Profile_FirstName_Placeholder",nil);
    model.isRequiredField = YES;
    model.isShowArrow = YES;
    [secondSectionDatas addObject:model];
    
    model = [[ZFUserInfoTypeModel alloc] init];
    model.editType = ZFUserInfoEditTypeLastName;
    
    model.typeName = ZFLocalizedString(@"Profile_LastName_Placeholder",nil);
    model.isRequiredField = YES;
    model.isShowArrow = YES;
    [secondSectionDatas addObject:model];

    model = [[ZFUserInfoTypeModel alloc] init];
    model.editType = ZFUserInfoEditTypeNickName;
    model.typeName = ZFLocalizedString(@"Profile_NickName_Placeholder",nil);
    model.isRequiredField = YES;
    model.isShowArrow = YES;
    [secondSectionDatas addObject:model];

    model = [[ZFUserInfoTypeModel alloc] init];
    model.editType = ZFUserInfoEditTypeGender;
    model.typeName = [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"gender", nil)];
    model.isRequiredField = YES;
    model.isShowArrow = YES;
    [secondSectionDatas addObject:model];
    
    model = [[ZFUserInfoTypeModel alloc] init];
    model.editType = ZFUserInfoEditTypeBrithday;
    model.typeName = ZFLocalizedString(@"Profile_Birthday_Placeholder",nil);
    model.isRequiredField = YES;
    model.isShowArrow = YES;
    [secondSectionDatas addObject:model];
    
    model = [[ZFUserInfoTypeModel alloc] init];
    model.editType = ZFUserInfoEditTypePhone;
    model.typeName = ZFLocalizedString(@"Profile_Phone_Placeholder",nil);
    model.isShowArrow = YES;
    model.isRequiredField = NO;
    [secondSectionDatas addObject:model];
    [self.sourceDatas addObject:secondSectionDatas];

    //邮箱注册才显示这个
    if ([AccountManager sharedManager].account.is_emerging_country != 1) {
        NSMutableArray *thirdSection = [[NSMutableArray alloc] init];
        model = [[ZFUserInfoTypeModel alloc] init];
        model.editType = ZFUserInfoEditTypeEmail;
        model.typeName = ZFLocalizedString(@"Profile_EmailAddress_Placeholder",nil);
        model.isShowArrow = NO;
        [thirdSection addObject:model];
        [self.sourceDatas addObject:thirdSection];
    }
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sourceDatas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.sourceDatas.count > section) {
        NSArray *sectionArrays = self.sourceDatas[section];
        return sectionArrays.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFUserInfoTypeModel *typeModel;
    if (self.sourceDatas.count > indexPath.section) {
        NSArray *sectionArrays = self.sourceDatas[indexPath.section];
        typeModel = sectionArrays[indexPath.row];
        
        if (typeModel.editType != ZFUserInfoEditTypePhoto) {
            ZFUserInfoTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ZFUserInfoTypeCell.class)];
            cell.bottomLineView.hidden = indexPath.row == sectionArrays.count-1;
            if (typeModel) {
                cell.typeModel = typeModel;
            }
            return cell;
        }
    }
    
    ZFUserInfoPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ZFUserInfoPhotoCell.class)];
    cell.typeModel = typeModel;
    if (self.updateUserImage) {
        cell.userImageView.image = self.updateUserImage;
    } else {
        cell.userImageUrl = ZFToString(self.userModel.avatar);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sourceDatas.count > indexPath.section) {
        NSArray *sectionDatas = self.sourceDatas[indexPath.section];
        if (sectionDatas.count > indexPath.section) {
            ZFUserInfoTypeModel *model = sectionDatas[indexPath.row];
            
            if (!model.isShowArrow) {
                return;
            }
            if (model.editType == ZFUserInfoEditTypePhoto) {
                [self ZFAccountHeaderCReusableViewDidClickChangeHeadPhoto];
                
            } else if(model.editType == ZFUserInfoEditTypeGender){
                
                // 0: 保密 1：男 2：女
                [ZFActionSheetView actionSheetByBottomCornerRadius:^(NSInteger buttonIndex, id title) {
                    self.userModel.sex = (2 - buttonIndex);
                    self.sex = self.userModel.sex;
                    [self updateTypeCell:ZFUserInfoEditTypeGender content:[self stringSexGender:self.sex]];
                    
                } cancelButtonBlock:nil sheetTitle:ZFLocalizedString(@"Register_ChooseGender", nil) cancelButtonTitle:ZFLocalizedString(@"Cancel", nil) otherButtonTitleArr:@[ZFLocalizedString(@"Profile_Female", nil), ZFLocalizedString(@"Profile_Male", nil),ZFLocalizedString(@"Profile_Privacy", nil)]];
                
            } else if(model.editType == ZFUserInfoEditTypeBrithday) {
                [self.birthDayTextField becomeFirstResponder];
                
            } else {
                ZFUserInfoEditWriteVC *editWriteVC = [[ZFUserInfoEditWriteVC alloc] init];
                editWriteVC.typeModel = model;
                
                ZFUserInfoEditType type = model.editType;
                @weakify(self)
                editWriteVC.inputTextBlock = ^(NSString * _Nonnull text) {
                    @strongify(self)
                    [self updateTypeCell:type content:text];
                };
                [self.navigationController pushViewController:editWriteVC animated:YES];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 60;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    footerView.backgroundColor = ZFC0xF7F7F7();
    return footerView;
}

#pragma mark - Photo
- (void)ZFAccountHeaderCReusableViewDidClickChangeHeadPhoto {
    @weakify(self)
    [ZFSystemPhototHelper showActionSheetChoosePhoto:self callBlcok:^(UIImage *uploadImage) {
        @strongify(self)
        if (uploadImage && [uploadImage isKindOfClass:[UIImage class]]) {
            self.updateUserImage = uploadImage;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.birthDayTextField) {
        //确保加载时也能获取datePicker的文字
        [self datePickerValueChange:self.datePicker];
    }
}


#pragma mark DatePciker Action
- (void)datePickerValueChange:(UIDatePicker *)datePicker{
    //将日期转为指定格式显示
    NSString *dateStr = [self.dateFormatter stringFromDate:datePicker.date];
    [self updateTypeCell:ZFUserInfoEditTypeBrithday content:dateStr];
}

#pragma mark - Property Method

- (void)setUserModel:(AccountModel *)userModel {
    _userModel = userModel;
    
    [self showUserPoints];
    for (NSArray *sectionDatas in self.sourceDatas) {
        for (ZFUserInfoTypeModel *typeModel in sectionDatas) {
            [self updateTypeModel:typeModel];
        }
    }
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

- (NSMutableArray *)sourceDatas {
    if (!_sourceDatas) {
        _sourceDatas = [[NSMutableArray alloc] init];
    }
    return _sourceDatas;
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


- (ZFUserInfoPointsInfoView *)pointsView {
    if (!_pointsView) {
        _pointsView = [[ZFUserInfoPointsInfoView alloc] initWithFrame:CGRectZero];
        _pointsView.frame = CGRectMake(0, 0, KScreenWidth, 32);
    }
    return _pointsView;
}
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = ZFCClearColor();
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedSectionFooterHeight = 12;
        _tableView.bounces = NO;
        
        [_tableView registerClass:[ZFUserInfoPhotoCell class] forCellReuseIdentifier:NSStringFromClass(ZFUserInfoPhotoCell.class)];
        [_tableView registerClass:[ZFUserInfoTypeCell class] forCellReuseIdentifier:NSStringFromClass(ZFUserInfoTypeCell.class)];
    }
    return _tableView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 60)];
    }
    return _footerView;
}

-(UIButton *)saveButton{
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.layer.cornerRadius = 3;
        _saveButton.layer.masksToBounds = YES;
        [_saveButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_saveButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        NSString *title = [ZFLocalizedString(@"Profile_Save_Button",nil) uppercaseString];
        [_saveButton setTitle:title forState:UIControlStateNormal];
        [_saveButton setTitleColor:ZFCOLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
        _saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        [_saveButton addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (UITextField *)birthDayTextField {
    if (!_birthDayTextField) {
        _birthDayTextField = [[UITextField alloc] init];
        _birthDayTextField.delegate = self;
    }
    return _birthDayTextField;
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
        if (birthday.length > 0 && ![birthday isEqualToString:ZFUserEditDefalutDateString]) {
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



#pragma mark - 保存

- (void)saveBtnClick {
    
    for (NSArray *sectionDatas in self.sourceDatas) {
        for (ZFUserInfoTypeModel *typeModel in sectionDatas) {
            if (![self checkInput:typeModel]) {
                return;
            }
        }
    }
    
    //v4.1.0 后台需要 年/月/日 格式
    NSString *birthday = [self typeModelContnet:ZFUserInfoEditTypeBrithday];
    if (ZFToString(birthday).length) {
        NSString *dateFormatter = [self gainRequestDateformatter:birthday];
        [self.uploadDateFormatter setDateFormat:dateFormatter];
        NSDate *date = [self.uploadDateFormatter dateFromString:birthday];
        [self.uploadDateFormatter setDateFormat:@"yyyy/MM/dd"];
        birthday = [self.uploadDateFormatter stringFromDate:date];
    }
    NSDictionary *dict = @{
                           @"firstname" : [self typeModelContnet:ZFUserInfoEditTypeFirstName],
                           @"lastname"  : [self typeModelContnet:ZFUserInfoEditTypeLastName],
                           @"nickname"  : [self typeModelContnet:ZFUserInfoEditTypeNickName],
                           @"sex"       : [NSString stringWithFormat:@"%zd",self.sex],
                           @"phone"     : [self typeModelContnet:ZFUserInfoEditTypePhone],
                           @"email"     : [self typeModelContnet:ZFUserInfoEditTypeEmail],
                           @"birthday"  : [self typeModelContnet:ZFUserInfoEditTypeBrithday],
                           kLoadingView : self.view
                           };
    ShowLoadingToView(self.view);
    @weakify(self)
    [self.viewModel requestSaveInfo:dict completion:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);

        [self requestUserData:YES];

    } failure:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"Failed",nil));
    }];
}

#pragma mark - 数据处理
- (ZFUserInfoTypeModel *)typeModel:(ZFUserInfoEditType)type {
    for (NSArray *sectionDatas in self.sourceDatas) {
        for (ZFUserInfoTypeModel *typeModel in sectionDatas) {
            if (typeModel.editType == type) {
                return typeModel;
            }
        }
    }
    return nil;
}

- (ZFUserInfoTypeCell *)typeCell:(ZFUserInfoEditType)type {
    for (int i=0; i<self.sourceDatas.count; i++) {
        NSArray *sectionDatas = self.sourceDatas[i];
        for (int j=0; j<sectionDatas.count; j++) {
            ZFUserInfoTypeModel *typeModel = sectionDatas[j];
            if (typeModel.editType == type) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                ZFUserInfoTypeCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                return cell;
            }
        }
    }
    return nil;
}

- (NSString *)typeModelContnet:(ZFUserInfoEditType)type {
    for (NSArray *sectionDatas in self.sourceDatas) {
        for (ZFUserInfoTypeModel *typeModel in sectionDatas) {
            if (typeModel.editType == type) {
                return ZFToString(typeModel.content);
            }
        }
    }
    return @"";
}

- (void)updateTypeCell:(ZFUserInfoEditType)type content:(NSString *)content {
    
    ZFUserInfoTypeModel *typeModel = [self typeModel:type];
    if (typeModel) {
        typeModel.content = ZFToString(content);
        ZFUserInfoTypeCell *cell = [self typeCell:type];
        if ([cell isKindOfClass:[ZFUserInfoTypeCell class]]) {
            cell.typeModel = typeModel;
        }
    }
}

- (BOOL)checkInput:(ZFUserInfoTypeModel *)typeModel{
    
    BOOL isCheckValid = YES;
    NSString *showHudErrorString = nil;
    
    if (typeModel.editType == ZFUserInfoEditTypeFirstName) {
        if ([NSStringUtils isEmptyString:typeModel.content]){
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Enter_FirstName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if (!(typeModel.content.length > 1)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Least_FirstName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if ((typeModel.content.length > 35)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Maxium_FirstName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
    }
    
    if (typeModel.editType == ZFUserInfoEditTypeLastName) {
        if ([NSStringUtils isEmptyString:typeModel.content]){
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Enter_LastName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if (!(typeModel.content.length > 1)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Least_LastName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if ((typeModel.content.length > 35)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Maxium_LastName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
    }
    
    if (typeModel.editType == ZFUserInfoEditTypeNickName) {
        if ([NSStringUtils isEmptyString:typeModel.content]){
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Enter_NickName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if (!(typeModel.content.length > 1)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Least_NickName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if ((typeModel.content.length > 35)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Maxium_NickName_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
    }
    
    if (typeModel.editType == ZFUserInfoEditTypePhone) {
        if ([NSStringUtils isEmptyString:typeModel.content]){
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Enter_Phone_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            
            return NO;
        }
        if ((typeModel.content.length < 6)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Least_Phone_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
        if ((typeModel.content.length > 20)) {
            showHudErrorString = !isCheckValid ? showHudErrorString : ZFLocalizedString(@"Profile_Maxium_Phone_Message",nil);
            ShowToastToViewWithText(self.view, showHudErrorString);
            return NO;
        }
    }
    
    if (typeModel.editType == ZFUserInfoEditTypeBrithday) {
        if (ZFIsEmptyString(typeModel.content)) {
            ShowToastToViewWithText(self.view, ZFLocalizedString(@"Account_birthday_enter", nil));
            return NO;
        }
    }
    
    return YES;
}

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

@end
