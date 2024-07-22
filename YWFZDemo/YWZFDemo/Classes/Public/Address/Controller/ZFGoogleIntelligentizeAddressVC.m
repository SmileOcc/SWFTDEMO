//
//  ZFGoogleIntelligentizeVC.m
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoogleIntelligentizeAddressVC.h"
#import "ZFInitViewProtocol.h"
#import "ZFGoogleAddressViewModel.h"
#import "ZFGoogleAddressModel.h"
#import "ZFThemeManager.h"
#import "IQKeyboardManager.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

static NSString *const kGoogleAddressCellIdentify = @"googleAddressCellIdentify";

@interface ZFGoogleIntelligentizeAddressVC ()<ZFInitViewProtocol, UITextFieldDelegate>
{
    dispatch_queue_t queue;
}
@property (nonatomic, strong) UITextField               *addressTextField;
@property (nonatomic, strong) UIView                    *textFieldline;
@property (nonatomic, strong) UILabel                   *textPlaceLabel;
@property (nonatomic, strong) UITableView               *addressTableView;
@property (nonatomic, strong) ZFGoogleAddressViewModel  *addressViewModel;

@property (nonatomic, assign) double                    lastInputTimer;
@property (nonatomic, strong) NSMutableDictionary       *dispatchOperations;

@end

@implementation ZFGoogleIntelligentizeAddressVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self zfInitView];
    [self zfAutoLayoutView];
    [self addNotification];
    
    if (![NSStringUtils isEmptyString:self.key]) {
        self.addressTextField.text = self.key;
        [self getInputGoogleAddressData];
    }
    queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.dispatchOperations = [[NSMutableDictionary alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //IQ会影响到这个页面的UITextField的布局
    [[IQKeyboardManager sharedManager] setEnable:NO];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification {
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;

    [self.addressTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.addressTextField.mas_bottom);
        make.top.mas_equalTo(self.textPlaceLabel.mas_bottom);
        make.leading.trailing.mas_equalTo(self.view);
        //occ测试数据
        make.height.mas_equalTo(KScreenHeight-(48 + NAVBARHEIGHT + STATUSHEIGHT + height)-30);
    }];
}

//当键盘出现或改变时调用
- (void)keyboardWillHide:(NSNotification *)aNotification {
    [self.addressTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.addressTextField.mas_bottom);
        make.top.mas_equalTo(self.textPlaceLabel.mas_bottom);
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
}

- (void)doneButtonAction:(UIButton *)sender {
    if (self.selectedAddressModel) {
        ZFGoogleDetailAddressModel *detailAddressModel = [[ZFGoogleDetailAddressModel alloc] init];
        if (self.addressTextField.text.length > 0) {
            ZFGoogleAddressComponentsModel *address_components = [ZFGoogleAddressComponentsModel new];
            address_components.addressline1 = self.addressTextField.text;
            detailAddressModel.address_components = address_components;
            
        }
//        //occ测试数据
//        detailAddressModel.address_components.addressline1 = @"occ测试数据dsojf@12";
        self.selectedAddressModel(detailAddressModel);
    }
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.addressTextField];
    [self.view addSubview:self.textFieldline];
    [self.view addSubview:self.textPlaceLabel];
    [self.view addSubview:self.addressTableView];
    if ([self.model isTestCountry]) {
        self.textPlaceLabel.hidden = NO;
    }
}

- (void)zfAutoLayoutView {
    [self.addressTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading).offset(16);
        make.top.mas_equalTo(self.view.mas_top).offset(8);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-16);
        make.height.mas_equalTo(48);
    }];
    
    [self.textFieldline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.addressTextField);
        make.bottom.mas_equalTo(self.addressTextField.mas_bottom);
        make.height.mas_equalTo(2);
    }];

    [self.textPlaceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.addressTextField.mas_leading);
        make.trailing.mas_equalTo(self.addressTextField.mas_trailing);
        if (![self.model isTestCountry]) {
            make.height.mas_equalTo(0);
        }
        make.top.mas_equalTo(self.addressTextField.mas_bottom).offset(6);
    }];
    
    
    [self.addressTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textPlaceLabel.mas_bottom);
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
}

#pragma mark -===========请求数据===========

/**
  * 查询输入的国家地址信息
  */
- (void)getInputGoogleAddressData{
    
    NSString *inputText = self.addressTextField.text;
    YWLog(@"*************** %@",inputText);

    if (ZFIsEmptyString(inputText))return;
    if (inputText.length <= 3) {
        return;
    }
    @weakify(self)
    [self.addressViewModel getInputGoogleAddressData:inputText country_code:self.country_code completion:^(NSArray *addressDataArr) {
        @strongify(self)
        NSInteger datacourceCount = [self.addressTableView.dataSource tableView:self.addressTableView numberOfRowsInSection:0];
        self.addressTableView.tableFooterView = [self tableFootViewByEmpty:(datacourceCount == 1)];
        [self.addressTableView reloadData];
    }];
}

#pragma mark -===========UITextFieldDelegate===========

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *allText = [textField.text stringByAppendingString:string];
    
    
//    if([string isEqualToString:@""] && allText.length <= 1 && [self.model isTestCountry]){
//        [self.textPlaceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(self.addressTextField.mas_leading);
//            make.trailing.mas_equalTo(self.addressTextField.mas_trailing);
//            make.height.mas_equalTo(0);
//            make.top.mas_equalTo(self.addressTextField.mas_bottom);
//        }];
//        self.textPlaceLabel.hidden = YES;
//
//    } else if([self.model isTestCountry]) {
//        [self.textPlaceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(self.addressTextField.mas_leading);
//            make.trailing.mas_equalTo(self.addressTextField.mas_trailing);
//            make.top.mas_equalTo(self.addressTextField.mas_bottom);
//        }];
//        self.textPlaceLabel.hidden = NO;
//        self.textPlaceLabel.backgroundColor = ZFRandomColor();
//
//    }
    //查询输入的国家地址信息
    if (textField.text.length == 1 && string.length == 0) {
        [self textFieldShouldClear:textField];
    } else {
        //超过3个字符搜索 这里可以去掉，在getInputGoogleAddressData 有判断
        // 判断为加
        BOOL isAdd = (allText.length > 3 && string.length > 0) ? YES : NO;
        // 判断为减
        BOOL isReduce = (allText.length > 4 && string.length == 0) ? YES : NO;
        if (isAdd || isReduce) {
            self.lastInputTimer = [[NSDate date] timeIntervalSince1970];
            dispatch_source_t oldTimer = [self.dispatchOperations objectForKey:@"timer"];
            if (!oldTimer) {
                dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
                dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
                dispatch_source_set_event_handler(timer, ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
                        if (nowInterval - self.lastInputTimer > 0.8) {
                            dispatch_suspend(timer);
                            dispatch_source_cancel(timer);
                            [self.dispatchOperations removeObjectForKey:@"timer"];
                            [self getInputGoogleAddressData];
                        }
                    });
                });
                dispatch_resume(timer);
                [self.dispatchOperations setObject:timer forKey:@"timer"];
            }
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textFiel {
    [self doneButtonAction:nil];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    [self.addressViewModel clearTableDataSource];
    self.addressTableView.tableFooterView = [self tableFootViewByEmpty:NO];
    [self.addressTableView reloadData];
    
//    if ([self.model isTestCountry]) {
//
//        [self.textPlaceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(self.addressTextField.mas_leading);
//            make.trailing.mas_equalTo(self.addressTextField.mas_trailing);
//            make.height.mas_equalTo(0);
//            make.top.mas_equalTo(self.addressTextField.mas_bottom);
//        }];
//        self.textPlaceLabel.hidden = YES;
//    }

    return YES;
}

- (void)googleIntelligentizeAddressShowController:(UIViewController *)parentController completion:(void (^)(BOOL))completeBlock {
    
    if (parentController) {
        if (self.view.superview) {
            [self.view removeFromSuperview];
        }
        
        self.view.frame = CGRectMake(0, KScreenHeight, KScreenWidth, KScreenHeight);
        [parentController.view addSubview:self.view];
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect tFrame = self.view.frame;
            tFrame.origin.y = 0;
            self.view.frame = tFrame;
    
        } completion:^(BOOL finished) {
            if (completeBlock) {
                completeBlock(YES);
            }
            [self.addressTextField becomeFirstResponder];
        }];
    }
}

- (void)googleIntelligentizeAddressHideCompletion:(void (^)(BOOL))completeBlock {
    if (self.view.superview) {
        
        [UIView animateWithDuration:0.5 animations:^{
            CGRect tFrame = self.view.frame;
            tFrame.origin.y = KScreenHeight;
            self.view.frame = tFrame;
        } completion:^(BOOL finished) {
            
            if (completeBlock) {
                completeBlock(YES);
            }
            [self.addressTextField resignFirstResponder];
            [self.view removeFromSuperview];
        }];
    }
}

#pragma mark - getter

- (ZFGoogleAddressViewModel *)addressViewModel {
    if(!_addressViewModel){
        _addressViewModel = [[ZFGoogleAddressViewModel alloc] init];
        @weakify(self)
        [_addressViewModel setSelectedAddressModel:^(ZFGoogleDetailAddressModel *detailAddressModel) {
            @strongify(self)
            if (self.selectedAddressModel) {
                self.selectedAddressModel(detailAddressModel);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _addressViewModel;
}

- (UITextField *)addressTextField {
    if (!_addressTextField) {
        _addressTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _addressTextField.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _addressTextField.font = [UIFont systemFontOfSize:14];
        _addressTextField.delegate = self;
        _addressTextField.clearButtonMode = UITextFieldViewModeAlways;
        _addressTextField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        [_addressTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [_addressTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//        _addressTextField.placeholder = ZFLocalizedString(@"ModifyAddress_Address1_Placeholder", nil);
        [_addressTextField addDoneOnKeyboardWithTarget:self action:@selector(doneButtonAction:)];
        [_addressTextField becomeFirstResponder];
        _addressTextField.returnKeyType = UIReturnKeyDone;
    }
    return _addressTextField;
}

- (UIView *)textFieldline {
    if(!_textFieldline){
        _textFieldline = [[UIView alloc] init];
        _textFieldline.backgroundColor = ZFCOLOR(45, 45, 45, 1);
    }
    return _textFieldline;
}


- (UILabel *)textPlaceLabel {
    if (!_textPlaceLabel) {
        _textPlaceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textPlaceLabel.text = ZFLocalizedString(@"ModifyAddress_Address1_Placeholder", nil);;
        _textPlaceLabel.hidden = YES;
        _textPlaceLabel.font = [UIFont systemFontOfSize:12];
        _textPlaceLabel.textColor = ZFC0x999999();
    }
    return _textPlaceLabel;
}

- (UITableView *)addressTableView {
    if (!_addressTableView) {
        _addressTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _addressTableView.delegate = self.addressViewModel;
        _addressTableView.dataSource = self.addressViewModel;
        _addressTableView.rowHeight = 56;
        _addressTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _addressTableView.tableFooterView = [self tableFootViewByEmpty:NO];
        [_addressTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kGoogleAddressCellIdentify];
    }
    return _addressTableView;
}

- (UIView *)tableFootViewByEmpty:(BOOL)isEmptyData {
    UIView *footBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 70)];
    footBgView.backgroundColor = ZFCOLOR_WHITE;
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, KScreenWidth-16*2, 30)];
    tipLabel.textColor = ZFCOLOR(153, 153, 153, 1);
    tipLabel.font = ZFFontSystemSize(14);
    tipLabel.numberOfLines = 2;
    [footBgView addSubview:tipLabel];
    if (isEmptyData) {
        tipLabel.text = ZFLocalizedString(@"ModifyAddress_Google_Help_NotFind_Address",nil);
    } else {
        tipLabel.text = ZFLocalizedString(@"ModifyAddress_Google_Help_Find_Address",nil);
    }
    
    UIImageView *googleImgView = [[UIImageView alloc] initWithImage:ZFImageWithName(@"account_globalLogo")];
    [footBgView addSubview:googleImgView];
    
    
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(footBgView.mas_leading).offset(16);
        make.top.mas_equalTo(footBgView.mas_top).offset(10);
        make.trailing.mas_equalTo(footBgView.mas_trailing).offset(-16);
    }];
    
    [googleImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(footBgView.mas_trailing).offset(-16);
        make.top.mas_equalTo(tipLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(20.0);
        make.width.mas_equalTo(googleImgView.mas_height).multipliedBy(264.0 / 32.0);
    }];
    
    return footBgView;
}

@end
