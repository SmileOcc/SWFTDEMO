//
//  ZFCommunityOutfitPostEnsureVC.m
//  ZZZZZ
//
//  Created by YW on 2018/8/10.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityOutfitPostEnsureVC.h"
#import "ZFInitViewProtocol.h"

#import "ZFOutfitBuilderSingleton.h"
#import "ZFCommunityPostTagViewModel.h"
#import "ZFCommunityPostViewModel.h"
#import "ZFCommunityPostResultModel.h"
#import "ZFThemeManager.h"
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import "IQKeyboardManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "YSAlertView.h"
#import "Masonry.h"
#import "Constants.h"
#import "YSTextView.h"
#import "YYText.h"
#import "ZFFrameDefiner.h"

#import "ZFCommunityPostHotTopicListVC.h"
#import "ZFCommunityOutfitsResultShowView.h"

#import "ZFOutfitSearchHotWordView.h"
#import "ZFOutfitSearchHotWordManager.h"


// 最大输入字符数
static const NSInteger  KOufitMaxInputCount = 3000;

@interface ZFCommunityOutfitPostEnsureVC ()
<
ZFInitViewProtocol,
UITextViewDelegate,
ZFOutfitSearchHotWordViewDelegate,
ZFOutfitSearchHotWordManagerDelegate
>

@property (nonatomic, strong) UIButton                            *postButton;
@property (nonatomic, strong) UIView                              *editView;
@property (nonatomic, strong) YSTextView                          *postEditView;
@property (nonatomic, strong) UIView                              *lineView;
@property (nonatomic, strong) UIImageView                         *postImageView;
@property (nonatomic, strong) UIButton                            *marketButton;            //标签按钮
@property (nonatomic, strong) UILabel                             *ZZZZZTipsLabel;
@property (nonatomic, strong) UISwitch                            *ZZZZZTipsSwitch;
@property (nonatomic, strong) ZFCommunityOutfitsResultShowView    *resultShowView;


@property (nonatomic, strong) NSMutableArray                      *selectedTagArray;

@property (nonatomic, strong) ZFCommunityPostTagViewModel         *postTagViewModel;
@property (nonatomic, strong) ZFCommunityPostViewModel            *postViewModel;

@property (nonatomic, strong) ZFOutfitSearchHotWordManager        *searchHotWordManager;
@property (nonatomic, strong) ZFOutfitSearchHotWordView           *searchHotWordView;

@property (nonatomic, assign) CGFloat keyboardHeight;               ///键盘高度

@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, assign) BOOL                                isShowToZF;

@end

@implementation ZFCommunityOutfitPostEnsureVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_resultShowView) {
        [_resultShowView showView:NO];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = ZFLocalizedString(@"community_createoutfit_title", nil);

    [self zfInitView];
    [self zfAutoLayoutView];
    
    self.postImageView.image = self.postImage;
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
    self.postImageView.userInteractionEnabled = YES;
    [self.postImageView addGestureRecognizer:tapGesture];
}

- (void)actionTap:(UIGestureRecognizer *)gesture {
    YWLog(@"-----");
    
    [self.view endEditing:YES];
    if (_resultShowView) {
        [_resultShowView removeFromSuperview];
        _resultShowView = nil;
    }
    
    [self.resultShowView setCoverImage:self.postImage];
    [self.resultShowView showView:YES];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    CGFloat height = keyboardRect.size.height;
    self.keyboardHeight = height;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    [self.view addSubview:self.contentView];
    
    [self.contentView addSubview:self.editView];
    [self.contentView addSubview:self.postEditView];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.postImageView];
    [self.contentView addSubview:self.marketButton];
    [self.contentView addSubview:self.ZZZZZTipsLabel];
    [self.contentView addSubview:self.ZZZZZTipsSwitch];
    [self addPostButton];
    self.lineView.hidden = YES;

    self.contentView.contentSize = CGSizeMake(0, 1000);
}

- (void)zfAutoLayoutView {
    
    UIView *view = self.contentView;
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(view.mas_leading);
        make.top.mas_equalTo(view.mas_top);
        make.trailing.mas_equalTo(view.mas_trailing);
    }];
    
    [self.postEditView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.editView.mas_leading).mas_offset(16);
        make.trailing.mas_equalTo(self.editView.mas_trailing).mas_offset(-16);
        make.top.mas_equalTo(self.editView.mas_top).mas_offset(4);
        make.bottom.mas_equalTo(self.editView.mas_bottom).mas_offset(-4);
        make.height.mas_equalTo(80);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.editView.mas_leading).mas_offset(16);
        make.trailing.mas_equalTo(self.editView.mas_trailing).mas_offset(-16);
        make.top.mas_equalTo(self.postEditView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(view.mas_leading).mas_offset(16);
        make.trailing.mas_equalTo(view.mas_trailing).mas_offset(-16);
        make.top.mas_equalTo(self.editView.mas_bottom);
        make.height.mas_equalTo(self.postImageView.mas_width).multipliedBy(1.0);
    }];
    
    CGFloat tipMaxW = ((KScreenWidth - 16 * 2) - 20) * 180.0 / (180.0 + 150.0);
    CGFloat hotMaxW = ((KScreenWidth - 16 * 2) - 20) * 150.0 / (180.0 + 150.0);

    
    [self.marketButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.postImageView.mas_bottom).mas_offset(8);
        make.leading.mas_equalTo(self.postImageView);
        make.height.mas_offset(28);
        make.width.mas_lessThanOrEqualTo(hotMaxW);
    }];
    
    [self.ZZZZZTipsSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
        make.centerY.mas_equalTo(self.marketButton);
    }];
    
    [self.ZZZZZTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.marketButton);
        make.trailing.mas_equalTo(self.ZZZZZTipsSwitch.mas_leading).offset(-3);
        make.width.mas_lessThanOrEqualTo(tipMaxW - 60);
    }];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    self.contentView.contentSize = CGSizeMake(0, CGRectGetMaxY(self.ZZZZZTipsLabel.frame) + 30);
}

- (void)addPostButton {
    UIButton *barItemBtn                   = [UIButton buttonWithType:UIButtonTypeCustom];
    barItemBtn.frame                       = CGRectMake(0.0, 0.0, self.navigationController.navigationBar.height + 20.0, self.navigationController.navigationBar.height);
    barItemBtn.titleLabel.font             = [UIFont boldSystemFontOfSize:16.0];
    [barItemBtn setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
    [barItemBtn setTitleColor:ZFC0x2D2D2D() forState:UIControlStateHighlighted];
    [barItemBtn setTitle:ZFLocalizedString(@"Post_VC_Post", nil) forState:UIControlStateNormal];
    [barItemBtn addTarget:self action:@selector(postAction) forControlEvents:UIControlEventTouchUpInside];
    barItemBtn.contentHorizontalAlignment  = [SystemConfigUtils isRightToLeftShow] ? UIControlContentHorizontalAlignmentLeft : UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *barItem               = [[UIBarButtonItem alloc] initWithCustomView:barItemBtn];
    self.navigationItem.rightBarButtonItem = barItem;
    self.postButton                        = barItemBtn;
    
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}


#pragma mark - 网络请求
/**
 请求标签
 */
//- (void)requestPostTag {
//    @weakify(self)
//    [self.postTagViewModel requestPostTagRequestWithFinished:^{
//        @strongify(self)
//        NSArray *tagArray = [self.postTagViewModel tagArray];
//        [self.tagCollectionView addTags:tagArray];
//        if (self.selectedTagArray.count > 0) {
//            NSString *firstTag = self.selectedTagArray.firstObject;
//            __block NSUInteger currentIndex = -1;
//            [tagArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if ([obj isEqualToString:firstTag]) {
//                    *stop = YES;
//                    currentIndex = idx;
//                }
//            }];
//            if (currentIndex >= 0) {
//                [self.tagCollectionView setTagAtIndex:currentIndex selected:YES];
//            }
//        }
//        [self.tagCollectionView reload];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.tagCollectionView.height = self.tagCollectionView.contentSize.height + 12.0;
//        });
//    }];
//}

#pragma mark - 事件响应

- (void)goBackAction {
    
    if (!ZFIsEmptyString(self.postEditView.text)) {
        
        NSString *title = ZFLocalizedString(@"Community_PostEditTips",nil);
        NSArray *otherBtnArr = @[ZFLocalizedString(@"Post_VC_Post_Cancel_Yes",nil)];
        NSString *cancelTitle = ZFLocalizedString(@"Post_VC_Post_Cancel_No",nil);
        
        ShowAlertView(title, nil, otherBtnArr, ^(NSInteger buttonIndex, id buttonTitle) {
            [self backLastVC];
        }, cancelTitle, nil);
    } else {
        [self backLastVC];
    }
}
- (void)backLastVC {
   NSArray *viewcontrollers=self.navigationController.viewControllers;
    if (viewcontrollers.count > 1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count - 1] == self){
            //push方式
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        //present方式
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)showZFSwitchAction:(UISwitch *)sender{
    if (sender.isOn) {
        @weakify(self)
        [YSAlertView alertWithTitle:nil message:ZFLocalizedString(@"Community_postSafeTips", nil) cancelButtonTitle:nil cancelButtonBlock:nil otherButtonBlock:^(NSInteger buttonIndex, id buttonTitle) {
            @strongify(self)
            if (buttonIndex == 1) {
                self.isShowToZF = YES;
            } else {
                self.isShowToZF = NO;
                sender.on = NO;
            }
        } otherButtonTitles:ZFLocalizedString(@"community_outfit_leave_cancel", nil), ZFLocalizedString(@"community_outfit_leave_confirm", nil), nil];
    } else {
        self.isShowToZF = NO;
    }
}

- (void)postAction {
    
    if ([NSStringUtils isEmptyString:self.postEditView.text]) {//请输入内容
        NSString *title = ZFLocalizedString(@"Community_Outfit_NOContentTips",nil);
        ShowAlertSingleBtnView(nil, title, ZFLocalizedString(@"Post_VC_Post_Alert_OK",nil));
        return;
    }
    
    [self.selectedTagArray removeAllObjects];
    if (!ZFIsEmptyString(self.selectHotTopicModel.label)) {
        [self.selectedTagArray addObject:self.selectHotTopicModel.label];
    }
    
    
    NSString *goodsString = [[ZFOutfitBuilderSingleton shareInstance] selecteGoodsIDsString];
    NSDictionary *dict =@{
                          //@"title" : self.postEditView.text,
                          @"content" : self.postEditView.text,
                          @"goodsId" : ZFToString(goodsString),
                          @"images"  : @[self.postImage],
                          @"topic"   : self.selectedTagArray,
                          @"review_type" : @(1),     // review_type  0普通帖，  1穿搭帖
                          @"nickEncrypt" : self.isShowToZF ? @"1" : @"0"
                          };
    
    ShowLoadingToView(self.navigationController.view);
    self.postViewModel = [[ZFCommunityPostViewModel alloc] init];
    
    @weakify(self)
    [self.postViewModel requestPostNetwork:dict completion:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.navigationController.view);
        ZFCommunityPostResultModel *model = obj;
        if ([model.reviewId length] > 0) {
            if (self.successBlock) {
                
                [ZFOutfitBuilderSingleton shareInstance].postOutfitsModel.reviewTitle = self.postEditView.text;
                [ZFOutfitBuilderSingleton shareInstance].postOutfitsModel.reviewId    = model.reviewId;
                [ZFOutfitBuilderSingleton shareInstance].postOutfitsModel.nikename    = [AccountManager sharedManager].account.nickname;
                [ZFOutfitBuilderSingleton shareInstance].postOutfitsModel.avatar      = [AccountManager sharedManager].account.avatar;
                [ZFOutfitBuilderSingleton shareInstance].postOutfitsModel.img         = self.postImage;
                [[ZFOutfitBuilderSingleton shareInstance] deallocSingleton];
                
                NSDictionary *noteDict = @{@"review_type" : @(1),
                                           @"model": @[model]};
                self.successBlock(noteDict);
                

                // 社区发帖成功统计
                NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
                valuesDic[AFEventParamContentId] = [NSString stringWithFormat:@"%@", model.reviewId];
                valuesDic[@"af_userid"] = ZFgrowingToString([AccountManager sharedManager].account.user_id);
                [ZFAnalytics appsFlyerTrackEvent:@"af_post" withValues:valuesDic];
                [ZFGrowingIOAnalytics ZFGrowingIOPostTopic:model.reviewId postType:@"outfits"];
            }
        } else {
            ShowToastToViewWithText(self.view, ZFLocalizedString(@"Failed", nil));
        }
    } failure:^(id obj) {
        @strongify(self)
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"Failed", nil));
        HideLoadingFromView(self.navigationController.view);
    }];
}

- (void)marketButtonClick
{
    //弹出选择话题框
    ZFCommunityPostHotTopicListVC *topicListVC = [[ZFCommunityPostHotTopicListVC alloc] init];
    topicListVC.hotTopicModel = self.selectHotTopicModel;
    
    @weakify(self)
    topicListVC.selectTopic = ^(ZFCommunityHotTopicModel *model) {
        @strongify(self)
        self.selectHotTopicModel = model;
    };
    topicListVC.cancelTopic = ^(BOOL flag) {
        @strongify(self)
        self.selectHotTopicModel = nil;
    };
    [topicListVC showParentController:self topGapHeight:kiphoneXTopOffsetY];
}

#pragma mark - <UITextViewDelegate>

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self.searchHotWordManager searchTextView:textView shouldChangeTextInRange:range replacementText:text];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString * text = textView.text;
    if (textView.markedTextRange == nil && text.length > KOufitMaxInputCount){
        [self showAlertMessage:ZFLocalizedString(@"Post_VC_Post_TextView_Tip",nil)];
        text = [text substringToIndex:KOufitMaxInputCount];
        textView.text = text;
    //截取的操作会入undo栈，之后的setText：方法并不会清空undo栈，导致做undo操作时，逆操作的是字符串截取的操作，操作的数据对不上，导致崩溃，这是我觉得比较合理的解释
        [textView.undoManager removeAllActions];
    }
    
    [self.searchHotWordManager searchTextViewDidChange:textView];
}

- (void)showAlertMessage:(NSString *)message {
    ShowAlertSingleBtnView(message, nil, ZFLocalizedString(@"Post_VC_Post_Alert_OK",nil));
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.searchHotWordManager searchTextViewDidEndEditing:textView];
    [self.searchHotWordView hiddenHotWordView];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [IQKeyboardManager sharedManager].enable  = NO;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = NO;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [IQKeyboardManager sharedManager].enable  = YES;
    return YES;
}

#pragma mark - ZFOutfitSearchHotWordView delegate

- (void)ZFOutfitSearchHotWordViewDidClickHotWord:(NSString *)word
{
    NSString *text = self.postEditView.text;
    [self.searchHotWordManager replaceInputKeyWithMatchKey:text matchKey:word];
    [self.searchHotWordView hiddenHotWordView];
}

#pragma mark - ZFOutfitSearchHotWordManager delegate

- (void)ZFOutfitSearchHotWordStartSearch:(ZFOutfitSearchHotWordManager *)manager matchList:(NSArray<HotWordModel *> *)list matchKeyword:(NSString *)keyword
{
    if (!self.searchHotWordView.superview) {
//        CGSize size = [self.postEditView.text sizeWithAttributes:@{NSFontAttributeName: self.postEditView.font}];
//        YWLog(@"----- %f",size.height);
//        CGFloat moveY = size.height < 50 ? 50 : size.height;
//        if (size.height > 100) {
//            moveY = 100;
//        }
//        if (moveY > CGRectGetHeight(self.postEditView.frame)) {
//            moveY = CGRectGetHeight(self.postEditView.frame) - 5;
//        }
        // 这里不需要加
        CGFloat moveY = 0;
        [self.searchHotWordView showHotWordView:self.view offsetY:CGRectGetMaxY(self.postEditView.frame) + moveY contentOffsetY:self.keyboardHeight];
    }
    [self.searchHotWordView reloadHotWord:list key:keyword];
}

- (void)ZFOutfitSearchHotWordEndSearch:(ZFOutfitSearchHotWordManager *)manager
{
    [self.searchHotWordView hiddenHotWordView];
}

- (void)ZFOutfitSearchHotWordDidChangeAttribute:(NSAttributedString *)attribute
{
    self.postEditView.attributedText = attribute;
}

#pragma mark - getter/setter

- (void)setSelectHotTopicModel:(ZFCommunityHotTopicModel *)selectHotTopicModel {
    _selectHotTopicModel = selectHotTopicModel;
    if (!ZFIsEmptyString(selectHotTopicModel.label)) {
        [self.marketButton setTitle:selectHotTopicModel.label forState:UIControlStateNormal];
        [self.marketButton setTitleColor:ZFC0x3D76B9() forState:UIControlStateNormal];
        [self.marketButton setTitleColor:ZFC0x3D76B9() forState:UIControlStateHighlighted];
        [self.marketButton setBackgroundColor:ZFC0x3D76B9_01()];
    } else {
        [self.marketButton setTitle:[NSString stringWithFormat:@"#%@",ZFLocalizedString(@"Community_HotEvents", nil)] forState:UIControlStateNormal];
        [self.marketButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        [self.marketButton setTitleColor:ZFC0x999999() forState:UIControlStateHighlighted];
        [self.marketButton setBackgroundColor:ZFC0xF7F7F7()];
    }
}
- (ZFCommunityPostTagViewModel *)postTagViewModel {
    if (!_postTagViewModel) {
        _postTagViewModel = [[ZFCommunityPostTagViewModel alloc] init];
    }
    return _postTagViewModel;
}

- (NSMutableArray *)selectedTagArray {
    if (!_selectedTagArray) {
        _selectedTagArray = [[NSMutableArray alloc] init];
    }
    return _selectedTagArray;
}

- (UIScrollView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    }
    return _contentView;
}

- (UIView *)editView {
    if (!_editView) {
        _editView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _editView;
}

- (UIImageView *)postImageView {
    if (!_postImageView) {
        _postImageView = [[UIImageView alloc] init];
    }
    return _postImageView;
}

- (YSTextView *)postEditView {
    if (!_postEditView) {
        _postEditView = [[YSTextView alloc] initWithFrame:CGRectZero];
        _postEditView.textColor    = [UIColor colorWithRed:51.0 / 255.0 green:51.0 / 255.0 blue:51.0 / 255.0 alpha:1.0];
        _postEditView.font         = [UIFont systemFontOfSize:14.0f];
        _postEditView.placeholderFont = [UIFont systemFontOfSize:14];
//        _postEditView.placeholder  = ZFLocalizedString(@"community_outfitpost_placetitle", nil);
        _postEditView.placeholder  = ZFLocalizedString(@"Community_Shareideas", nil);
        _postEditView.delegate     = self;
        _postEditView.placeholderColor = ZFC0xCCCCCC();
        _postEditView.placeholderPoint = CGPointMake(10, 8.3);
        [_postEditView convertTextAlignmentWithARLanguage];
    }
    return _postEditView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFC0xDDDDDD();
    }
    return _lineView;
}

- (ZFOutfitSearchHotWordManager *)searchHotWordManager
{
    if (!_searchHotWordManager) {
        _searchHotWordManager = [ZFOutfitSearchHotWordManager manager];
        _searchHotWordManager.compareKey = @"label";
        _searchHotWordManager.delegate = self;
    }
    return _searchHotWordManager;
}

- (ZFOutfitSearchHotWordView *)searchHotWordView
{
    if (!_searchHotWordView) {
        _searchHotWordView = [[ZFOutfitSearchHotWordView alloc] init];
        _searchHotWordView.delegate = self;
    }
    return _searchHotWordView;
}

- (UIButton *)marketButton {
    if (!_marketButton) {
        _marketButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = ZFC0xF7F7F7();
            button.titleLabel.font = [UIFont systemFontOfSize:15];
            button.layer.cornerRadius = 14;
            button.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 12);
            [button setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
            [button setTitle:[NSString stringWithFormat:@"#%@",ZFLocalizedString(@"Community_HotEvents", nil)] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(marketButtonClick) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _marketButton;
}

-(UILabel *)ZZZZZTipsLabel
{
    if (!_ZZZZZTipsLabel) {
        _ZZZZZTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 12;
            label.text = ZFLocalizedString(@"Community_OnlyZZZZZ", nil);
            label.textColor = ZFC0xCCCCCC();
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _ZZZZZTipsLabel;
}

- (UISwitch *)ZZZZZTipsSwitch
{
    if (!_ZZZZZTipsSwitch) {
        _ZZZZZTipsSwitch = ({
            UISwitch *switchP = [[UISwitch alloc] init];
            switchP.on = NO;
            switchP.transform = CGAffineTransformMakeScale(0.6, 0.6);
            [switchP addTarget:self action:@selector(showZFSwitchAction:) forControlEvents:UIControlEventValueChanged];
            [switchP setOnTintColor:ZFC0xFE5269()];
            switchP;
        });
    }
    return _ZZZZZTipsSwitch;
}

- (ZFCommunityOutfitsResultShowView *)resultShowView {
    if (!_resultShowView) {
        _resultShowView = [[ZFCommunityOutfitsResultShowView alloc] initWithFrame:CGRectZero];
    }
    return _resultShowView;
}

@end
