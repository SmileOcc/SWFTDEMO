//
//  YXLiveAskViewController.m
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/8/17.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXLiveAskViewController.h"
#import "YXLiveAskViewModel.h"
#import "YXReportTextParser.h"
#import "YXTextLinePositionModifier.h"
#import "uSmartOversea-Swift.h"
#import "YYTextContainerView.h"
#import <Masonry/Masonry.h>
#import "NSDictionary+Category.h"

@interface YXLiveAskViewController () <YYTextViewDelegate, YYTextKeyboardObserver>

@property (nonatomic, strong) YXLiveAskViewModel *viewModel;
@property (nonatomic, strong) YYTextView *textView;

@property (nonatomic, strong) UIButton *reportButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) BOOL isPostSuccess;

@property (nonatomic, strong) NSString * commentId;

@end

@implementation YXLiveAskViewController
@dynamic viewModel;

- (instancetype)initWithViewModel:(YXViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    if (self.isPostSuccess && self.viewModel.successBlock) {
        self.viewModel.successBlock(self.commentId);
    } else if (self.viewModel.cancelBlock) {
        self.viewModel.cancelBlock();
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.commentId = @"";
        
    self.view.backgroundColor = QMUITheme.foregroundColor;
    
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = QMUITheme.backgroundColor;
    [self.view addSubview:topView];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(36);
    }];
    
    [topView addSubview:self.cancelButton];
    [topView addSubview:self.reportButton];
    [topView addSubview:self.titleLabel];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.top.equalTo(topView);
        make.bottom.equalTo(topView);
        make.width.mas_equalTo(50);
    }];
    
    [self.reportButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(topView).offset(-12);
        make.top.equalTo(topView);
        make.bottom.equalTo(topView);
        make.width.mas_equalTo(50);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(topView);
    }];
    
    [self.view addSubview:self.textView];

    UIView *textContainerView;
    for (UIView *subView in [self.textView subviews]) {
        if ([subView isKindOfClass:[YYTextContainerView class]]) {
            textContainerView = subView;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textView becomeFirstResponder];
    self.navigationController.navigationBar.hidden = YES;
}

- (UIButton *)reportButton {
    if (_reportButton == nil) {
        _reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reportButton setTitle:[YXLanguageUtility kLangWithKey:@"publish"] forState:UIControlStateNormal];
        _reportButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _reportButton.enabled = NO;
        [_reportButton setTitleColor:[UIColor qmui_colorWithHexString:@"#2F79FF"] forState:UIControlStateNormal];
        [_reportButton setTitleColor:[[UIColor qmui_colorWithHexString:@"#2F79FF"] colorWithAlphaComponent:0.45] forState:UIControlStateDisabled];

        @weakify(self)
        [_reportButton setQmui_tapBlock:^(__kindof UIControl *sender) {
            @strongify(self)
            if (self.textView.text.length > 300) {
                [self showText:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"publish_tips"], self.textView.text.length - 300]];
                return;
            }
            
            
            [self submitReport];
        }];
    }
    return _reportButton;
}

- (UIButton *)cancelButton {
    if (_cancelButton == nil) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:[YXLanguageUtility kLangWithKey:@"common_cancel"] forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [_cancelButton setTitleColor:QMUITheme.textColorLevel3 forState:UIControlStateNormal];

//        @weakify(self)
        [_cancelButton setQmui_tapBlock:^(__kindof UIControl *sender) {
//            @strongify(self)
            [[UIViewController currentViewController] dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return _cancelButton;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = QMUITheme.textColorLevel1;
        _titleLabel.text = [self.viewModel.params yx_stringValueForKey:@"title"];
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _titleLabel;
}

- (void)submitReport{
    
    [self showLoading:@""];
    YXGetUniqueIdRequestModel *uniqueIdRequestModel = [[YXGetUniqueIdRequestModel alloc] init];
    YXRequest *uniqueRequest = [[YXRequest alloc] initWithRequestModel:uniqueIdRequestModel];
    [uniqueRequest startWithBlockWithSuccess:^(__kindof YXResponseModel * _Nonnull responseModel) {
        NSArray *arr = [responseModel.data yx_arrayValueForKey:@"data"];
        NSString *uniqueId = arr.firstObject;
        
        YXCommentRequestModel *commentRequestModel = [[YXCommentRequestModel alloc] init];
        commentRequestModel.content = self.textView.text;
        commentRequestModel.post_id = [self.viewModel.params yx_stringValueForKey:@"post_id"];
        commentRequestModel.unique_id = uniqueId;
        commentRequestModel.ext_type = 3;
        YXRequest *commentRequest = [[YXRequest alloc] initWithRequestModel:commentRequestModel];
        [commentRequest startWithBlockWithSuccess:^(__kindof YXResponseModel * _Nonnull responseModel) {
            [self hideHud];
            if (responseModel.code == YXResponseCodeSuccess) {
                [self showSuccess:[YXLanguageUtility kLangWithKey:@"ask_success"]];
                self.isPostSuccess = YES;
                [[UIViewController currentViewController] dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self showError:responseModel.msg];
            }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [self hideHud];
            [self showError:[YXLanguageUtility kLangWithKey:@"network_timeout"]];
        }];
        
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        [self hideHud];
        [self showError:[YXLanguageUtility kLangWithKey:@"network_timeout"]];
    }];
    
    
        
//    YXHZBaseRequestModel *requestModel;
//
//    YXCommentPostRequestModel *commentRequestModel = [[YXCommentPostRequestModel alloc] init];
//    commentRequestModel.content = self.textView.attributedText.string;
//
//    commentRequestModel.post_id = self.viewModel.params[@"post_id"];
//    if (self.viewModel.params[@"post_type"]) {
//        commentRequestModel.post_type = [self.viewModel.params[@"post_type"] intValue];
//    }else{
//        commentRequestModel.post_type = 5;  //个股讨论
//    }
//
//    requestModel = commentRequestModel;
//    YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
//    @weakify(self)
//    [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
//        @strongify(self)
//        [self hideHud];
//        if (responseModel.code == 0) {
//            [self showSuccess:@"发表成功"];
//            if( responseModel.data[@"comment_id"]) {
//                self.commentId = responseModel.data[@"comment_id"];
//            }
//            self.isPostSuccess = YES;
//            [self.viewModel.services dismissViewModelAnimated:YES completion:^{
//
//            }];
//        }else if(responseModel.code == YXResponseStatusCodePostIsDeleted) {
//            [self showError:responseModel.msg];
////            self.isPostDelete = YES;
//            [self.viewModel.services dismissViewModelAnimated:YES completion:^{
//
//            }];
//        } else {
//            [self showError:responseModel.msg];
//        }
//
//    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
//        @strongify(self)
//        [self hideHud];
//        [self showError:@"网络开小差了，请稍后重试"];
//    }];
}


- (YYTextView *)textView {
    if (_textView == nil) {
        _textView = [[YYTextView alloc] initWithFrame:CGRectMake(0, 36, self.view.width, self.view.height - 36)];
        _textView.textContainerInset = UIEdgeInsetsMake(12, 16, 12, 16);
        _textView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textView.extraAccessoryViewHeight = 60;
        _textView.showsVerticalScrollIndicator = NO;
        _textView.alwaysBounceVertical = YES;
        _textView.allowsCopyAttributedString = NO;
        _textView.font = [UIFont systemFontOfSize:16];
        YXReportTextParser *parser = [YXReportTextParser new];
        parser.editing = YES;
        _textView.textParser = parser;
        _textView.delegate = self;
        _textView.inputAccessoryView = [UIView new];
        _textView.textColor = QMUITheme.textColorLevel1;
        
        YXTextLinePositionModifier *modifier = [YXTextLinePositionModifier new];
        modifier.font = [UIFont systemFontOfSize:16];
        modifier.paddingTop = 12;
        modifier.paddingBottom = 12;
        modifier.lineHeightMultiple = 1.5;
        _textView.linePositionModifier = modifier;
        
        NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:[YXLanguageUtility kLangWithKey:@"ask_placeholder"]];
        atr.yy_color = QMUITheme.textColorLevel3;
        atr.yy_font = [UIFont systemFontOfSize:16];
        _textView.placeholderAttributedText = atr;
    }
    return _textView;
}


- (void)textViewDidChange:(YYTextView *)textView {
    if (textView.attributedText.length > 0) {
        self.reportButton.enabled = YES;
    } else {
        self.reportButton.enabled = NO;
    }
}


//- (void)keyboardWillShow:(NSNotification *)notification {
//    NSDictionary *userInfo = notification.userInfo;
//
//    double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    
//    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
//    if (duration == 0) {
//        self.toolbar.qmui_bottom = self.view.height - keyboardF.size.height;
//    } else {
//        [UIView animateWithDuration:duration delay:0 options: UIViewAnimationOptionBeginFromCurrentState animations:^{
//            self.toolbar.qmui_bottom = self.view.height - keyboardF.size.height;
//        } completion:NULL];
//    }

//    [UIView animateWithDuration:duration animations:^{
//
//        if (keyboardF.origin.y > CGRectGetHeight(self.view.frame)) {
//
//
//            self.toolbar.qmui_bottom = self.view.height - keyboardF;
//        }
//        else {
//
//            CGRect frame = self.webView.frame;
//            frame.origin.y = keyboardF.origin.y - CGRectGetHeight(self.webView.frame);
//            self.webView.frame = frame;
//        }
//    }];
//}


@end
