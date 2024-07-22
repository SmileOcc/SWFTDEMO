//
//  ZFMyCouponViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/12/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFMyCouponViewController.h"
#import "ZFMyCouponViewModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFMyCouponModel.h"
#import "ZFCouponWarningView.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "CustomTextField.h"
#import "UIView+ZFViewCategorySet.h"
#import "SystemConfigUtils.h"
#import "UIImage+ZFExtended.h"

typedef enum : NSUInteger {
    ZFMyCouponApplyButton_ApplyType,
    ZFMyCouponApplyButton_RemoveType,
} ZFMyCouponApplyButtonActionType;

@interface ZFMyCouponViewController () <ZFInitViewProtocol> {
    ZFMyCouponModel *_applyModel;
}

@property (nonatomic, strong) UITableView           *couponTableView;
@property (nonatomic, strong) ZFMyCouponViewModel   *viewModel;
@property (nonatomic, strong) UIView                *bottomView;
@property (nonatomic, strong) CustomTextField       *couponTextField;
@property (nonatomic, strong) UIButton              *applyButton;
@property (nonatomic, strong) ZFCouponWarningView   *warningView;
@property (nonatomic, assign) BOOL                  hasChangeCoupon;
@end

@implementation ZFMyCouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"Account_Cell_Coupon", nil);
    self.view.backgroundColor = ZFC0xF2F2F2();
    [self zfInitView];
    [self zfAutoLayoutView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.viewModel selectedBefore];
    [self judgeAvailableCouponCode:YES];
    
    [AccountManager sharedManager].account.has_new_coupon = @"0";
    [APPDELEGATE.tabBarVC isShowNewCouponDot];
    
    //空白页
    [self.couponTableView reloadData];
    [self.couponTableView showRequestTip:@{}];
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    [self.view addSubview:self.couponTableView];
    [self.view addSubview:self.warningView];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.couponTextField];
    [self.bottomView addSubview:self.applyButton];
    [self.view bringSubviewToFront:self.warningView];
    [self.view bringSubviewToFront:self.bottomView];
}

- (void)zfAutoLayoutView {
    UIView *topView = self.view;
    UIView *bottomView = self.bottomView;
    
    CGFloat padding = 16;
    CGFloat topPadding = 8;
    CGFloat rightPadding = 12;

    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(48.0f);
        make.leading.mas_equalTo(self.view.mas_leading);
        make.trailing.mas_equalTo(self.view.mas_trailing);
        make.top.mas_equalTo(self.warningView.mas_bottom);
    }];
    topView = self.bottomView;
    bottomView = self.view;
    [self.couponTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_bottom);
        make.leading.mas_equalTo(self.view.mas_leading);
        make.trailing.mas_equalTo(self.view.mas_trailing);
        make.bottom.mas_equalTo(bottomView.mas_bottom);
    }];
    [self.warningView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top);
        make.leading.mas_equalTo(self.view.mas_leading);
        make.trailing.mas_equalTo(self.view.mas_trailing);
        make.height.mas_equalTo(0.0f);
    }];
    
    [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.couponTextField.mas_height);
        make.width.mas_greaterThanOrEqualTo(70.0f);
        make.trailing.mas_equalTo(self.bottomView.mas_trailing).mas_offset(-padding);
        make.bottom.mas_equalTo(self.couponTextField.mas_bottom);
    }];
 
    [self.couponTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bottomView.mas_leading).offset(padding);
        make.trailing.mas_equalTo(self.applyButton.mas_leading).offset(-rightPadding);
        make.top.mas_equalTo(self.bottomView.mas_top).offset(topPadding);
        make.bottom.mas_equalTo(self.bottomView.mas_bottom).offset(-topPadding);
    }];
    
    [self.couponTextField setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.applyButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.applyButton setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - event
- (void)applyButtonAction:(UIButton *)applyButton  {
    if (applyButton.tag == ZFMyCouponApplyButton_RemoveType) {
        [self clearDefaultSelectCoupon];
        return;
    }
    
    @weakify(self)
    ShowLoadingToView(self.view);
    [self.view endEditing:YES];
    [self.viewModel checkEffectiveCoupon:self.couponTextField.text completion:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
        if ([obj boolValue]) {            
            NSString *couponCode = self.couponTextField.text;
            [AccountManager sharedManager].hasSelectedAppCoupon = YES;
            if (ZFJudgeNSString(couponCode)) {
                [AccountManager sharedManager].selectedAppCouponCode = couponCode;
            }
            if (self.applyCouponHandle) {
                if (!ISLOGIN && self.hasChangeCoupon) {
                    [AccountManager sharedManager].no_login_select_coupon = ![AccountManager sharedManager].no_login_select_coupon;
                }
                self.applyCouponHandle(self.couponTextField.text, YES);
            }
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //V5.7.0不要清除
                //self.couponTextField.text = nil;
                [self fieldEditingChanged];
            });
        }
    }];
}

#pragma mark - action methods
- (void)fieldEditingChanged {
    
    NSString *text = self.couponTextField.text;
    if (ZFIsEmptyString(text)) {
        self.applyButton.enabled = NO;
        [self judgeAvailableCouponCode:NO];
    } else {
        self.applyButton.enabled = YES;
    }
}

- (void)judgeAvailableCouponCode:(BOOL)isDefaultType {
    NSString *applyTitle = nil;
    if (isDefaultType && !ZFIsEmptyString(self.couponAmount)) {
        applyTitle = ZFLocalizedString(@"Cart_Coupon_Remove", nil);
        self.applyButton.tag = ZFMyCouponApplyButton_RemoveType;
    } else {
        applyTitle = ZFLocalizedString(@"CartOrderInfo_MyCouponPickerView_APPLY", nil);
        self.applyButton.tag = ZFMyCouponApplyButton_ApplyType;
    }
    [self.applyButton setTitle:applyTitle forState:UIControlStateNormal];
}

- (void)clearDefaultSelectCoupon {
    if (self.applyCouponHandle) {
        self.couponTextField.text = nil;
        self.couponCode = nil;
        [self fieldEditingChanged];
        [self judgeAvailableCouponCode:NO];
        [self.viewModel removeOrDeselectDefaultCoupon:self.couponTableView];
        self.applyCouponHandle(nil, NO);
    }
}

#pragma mark - getter/setter
- (UITableView *)couponTableView {
    if (!_couponTableView) {
        _couponTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _couponTableView.backgroundColor                = ZFC0xF2F2F2();
        _couponTableView.rowHeight                      = UITableViewAutomaticDimension;
        _couponTableView.estimatedRowHeight             = 200;
        _couponTableView.separatorStyle                 = UITableViewCellSeparatorStyleNone;
        _couponTableView.showsVerticalScrollIndicator   = YES;
        _couponTableView.showsHorizontalScrollIndicator = NO;
        _couponTableView.contentInset                   = UIEdgeInsetsMake(0, 0, 30, 0);
        _couponTableView.dataSource                     = self.viewModel;
        _couponTableView.delegate                       = self.viewModel;
        _couponTableView.emptyDataTitle  = ZFLocalizedString(@"OrderCheckCoupon_NoCouponTips", nil);
        _couponTableView.emptyDataImage  = ZFImageWithName(@"blankPage_noCoupon");
    }
    return _couponTableView;
}

- (ZFMyCouponViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFMyCouponViewModel alloc] initWithAvailableCoupon:self.availableArray
                                                            disableCoupon:self.disabledArray
                                                               couponCode:self.couponCode
                                                             couponAmount:self.couponAmount];
        _viewModel.controller = self;
        
        @weakify(self)
        _viewModel.itemSelectedHandle = ^(ZFMyCouponModel *model, BOOL hasChangeCoupon, BOOL isSelectCallback) {
            @strongify(self)
            self.hasChangeCoupon = hasChangeCoupon;
            if (model == nil) {
                ///当优惠券已存在，并且不是用户自己取消的，就填写默认的优惠券
                CGFloat height = 0.0;
                if (ZFToString(self.couponCode) && !isSelectCallback) {
                    self.couponTextField.text = self.couponCode;
                    if (self.couponAmount.floatValue > 0) {
                        self.warningView.couponAmount = self.couponAmount;
                        height = 30.0;
                    }
                } else {
                    self.couponTextField.text = @"";
                }
                
                if (!model && !ZFIsEmptyString(self.couponCode) && !self.alreadyEnter) { //只做一次清理
                    self.alreadyEnter = YES;
                    [self clearDefaultSelectCoupon];
                }
                
                [UIView animateWithDuration:0.25 animations:^{
                    [self.warningView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(height);
                    }];
                    [self.view layoutIfNeeded];
                }];
            } else {
                self.couponTextField.text = model.code;
                self.warningView.couponAmount = model.pcode_amount;
                
                [UIView animateWithDuration:0.25 animations:^{
                    [self.warningView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(30.0f);
                    }];
                    [self.view layoutIfNeeded];
                }];
            }
//            if (isSelectCallback) {
                self.alreadyEnter = YES;
//            }
            
            [self fieldEditingChanged];
            [self judgeAvailableCouponCode:NO];
        };
    }
    return _viewModel;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (CustomTextField *)couponTextField {
    if (!_couponTextField) {
        _couponTextField           = [[CustomTextField alloc] init];
        _couponTextField.placeholderPadding = 8;
        _couponTextField.textColor = ZFC0x2D2D2D();
        _couponTextField.font      = [UIFont systemFontOfSize:14.0f];
        _couponTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _couponTextField.backgroundColor = ZFC0xF7F7F7();
        if ([SystemConfigUtils isRightToLeftShow]) {
            _couponTextField.textAlignment = NSTextAlignmentRight;
        }
        _couponTextField.placeholder = ZFLocalizedString(@"OrderDetail_CouponCode_InputplaceholderText", nil);
        
        _couponTextField.layer.cornerRadius = 2;
        _couponTextField.layer.masksToBounds = YES;
        [_couponTextField addTarget:self action:@selector(fieldEditingChanged) forControlEvents:UIControlEventAllEditingEvents];
    }
    return _couponTextField;
}

- (UIButton *)applyButton {
    if (!_applyButton) {
        _applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *normalImage = [UIImage zf_createImageWithColor:ZFC0x2D2D2D()];
        UIImage *disabledImage = [UIImage zf_createImageWithColor:ZFC0xCCCCCC()];
        [_applyButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        [_applyButton setBackgroundImage:disabledImage forState:UIControlStateDisabled];
        
        [_applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _applyButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _applyButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_applyButton setTitle:ZFLocalizedString(@"CartOrderInfo_MyCouponPickerView_APPLY", nil) forState:UIControlStateNormal];
        _applyButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        _applyButton.layer.cornerRadius = 2;
        _applyButton.layer.masksToBounds = YES;
        _applyButton.enabled = NO;
        _applyButton.tag = ZFMyCouponApplyButton_ApplyType;
        
        [_applyButton addTarget:self
                         action:@selector(applyButtonAction:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _applyButton;
}

- (ZFCouponWarningView *)warningView {
    if (!_warningView) {
        _warningView = [[ZFCouponWarningView alloc] init];
        _warningView.currentPaymentType = self.currentPaymentType;
    }
    return _warningView;
}

@end
