//
//  ZFOutfitPostEnsureViewController.m
//  Zaful
//
//  Created by occ on 2018/8/10.
//  Copyright © 2018年 Zaful. All rights reserved.
//

#import "ZFCommunityOutfitPostEnsureVC.h"
#import "TTGTextTagCollectionView.h"
#import "ZFInitViewProtocol.h"

#import "ZFOutfitBuilderSingleton.h"
#import "ZFCommunityPostTagViewModel.h"
#import "PostViewModel.h"
#import "ZFCommunityPostModel.h"

@interface ZFCommunityOutfitPostEnsureVC ()
<
ZFInitViewProtocol,
UITextFieldDelegate,
TTGTextTagCollectionViewDelegate
>

@property (nonatomic, strong) UIButton                            *postButton;
@property (nonatomic, strong) UIView                              *editView;
@property (nonatomic, strong) UITextField                         *postEditView;
@property (nonatomic, strong) UIView                              *lineView;
@property (nonatomic, strong) UIImageView                         *postImageView;
@property (nonatomic, strong) TTGTextTagCollectionView            *tagCollectionView;
@property (nonatomic, strong) NSMutableArray                      *selectedTagArray;

@property (nonatomic, strong) ZFCommunityPostTagViewModel         *postTagViewModel;
@property (nonatomic, strong) PostViewModel                       *postViewModel;

@end

@implementation ZFCommunityOutfitPostEnsureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"community_createoutfit_title", nil);

    [self zfInitView];
    [self zfAutoLayoutView];
    
    if (!ZFIsEmptyString(self.topicLabel)) {
        [self.selectedTagArray addObject:self.topicLabel];
    }
    [self requestPostTag];
    
    self.postImageView.image = self.postImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    
    [self.view addSubview:self.editView];
    [self.view addSubview:self.postEditView];
    [self.view addSubview:self.lineView];
    [self.view addSubview:self.postImageView];
    [self.view addSubview:self.tagCollectionView];
    
    [self addPostButton];
}

- (void)zfAutoLayoutView {
    
    [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading);
        make.top.mas_equalTo(self.view.mas_top);
        make.trailing.mas_equalTo(self.view.mas_trailing);
    }];
    
    [self.postEditView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.editView.mas_leading).mas_offset(16);
        make.trailing.mas_equalTo(self.editView.mas_trailing).mas_offset(-16);
        make.top.mas_equalTo(self.editView.mas_top).mas_offset(25);
        make.bottom.mas_equalTo(self.editView.mas_bottom).mas_offset(-25);
        make.height.mas_equalTo(22);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.editView.mas_leading).mas_offset(16);
        make.trailing.mas_equalTo(self.editView.mas_trailing).mas_offset(-16);
        make.top.mas_equalTo(self.postEditView.mas_bottom);
        make.height.mas_equalTo(1);
    }];
    
    [self.postImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view.mas_leading).mas_offset(16);
        make.trailing.mas_equalTo(self.view.mas_trailing).mas_offset(-16);
        make.top.mas_equalTo(self.editView.mas_bottom);
        make.height.mas_equalTo(self.postImageView.mas_width).multipliedBy(1.0);
    }];
    
    [self.tagCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.postImageView.mas_bottom).mas_offset(16);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-16);
    }];
}

- (void)addPostButton {
    UIButton *barItemBtn                   = [UIButton buttonWithType:UIButtonTypeCustom];
    barItemBtn.frame                       = CGRectMake(0.0, 0.0, self.navigationController.navigationBar.height + 20.0, self.navigationController.navigationBar.height);
    barItemBtn.titleLabel.font             = [UIFont systemFontOfSize:16.0];
    [barItemBtn setTitleColor:ColorHex_Alpha(0xffa800, 1.0) forState:UIControlStateNormal];
    [barItemBtn setTitleColor:ColorHex_Alpha(0xffa800, 1.0) forState:UIControlStateHighlighted];
    [barItemBtn setTitle:ZFLocalizedString(@"Post_VC_Post", nil) forState:UIControlStateNormal];
    [barItemBtn addTarget:self action:@selector(postAction) forControlEvents:UIControlEventTouchUpInside];
    barItemBtn.contentHorizontalAlignment  = [SystemConfigUtils isRightToLeftShow] ? UIControlContentHorizontalAlignmentLeft : UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *barItem               = [[UIBarButtonItem alloc] initWithCustomView:barItemBtn];
    self.navigationItem.rightBarButtonItem = barItem;
    self.postButton                        = barItemBtn;
}


#pragma mark - 网络请求
/**
 请求标签
 */
- (void)requestPostTag {
    @weakify(self)
    [self.postTagViewModel requestPostTagRequestWithFinished:^{
        @strongify(self)
        NSArray *tagArray = [self.postTagViewModel tagArray];
        [self.tagCollectionView addTags:tagArray];
        if (self.selectedTagArray.count > 0) {
            NSString *firstTag = self.selectedTagArray.firstObject;
            __block NSUInteger currentIndex = -1;
            [tagArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isEqualToString:firstTag]) {
                    *stop = YES;
                    currentIndex = idx;
                }
            }];
            if (currentIndex >= 0) {
                [self.tagCollectionView setTagAtIndex:currentIndex selected:YES];
            }
        }
        [self.tagCollectionView reload];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tagCollectionView.height = self.tagCollectionView.contentSize.height + 12.0;
        });
    }];
}

#pragma mark - 事件响应

- (void)postAction {
    
    if ([NSStringUtils isEmptyString:self.postEditView.text]) {//请输入一个标题
        NSString *title = ZFLocalizedString(@"community_outfit_post_forgettitle",nil);
        ShowAlertSingleBtnView(nil, title, ZFLocalizedString(@"Post_VC_Post_Alert_OK",nil));
        return;
    }
    
    NSString *goodsString = [[ZFOutfitBuilderSingleton shareInstance] selecteGoodsIDsString];
    NSDictionary *dict =@{
                          @"title" : self.postEditView.text,
                          @"goodsId" : ZFToString(goodsString),
                          @"images"  : @[self.postImage],
                          @"topic"   : self.selectedTagArray,
                          @"review_type" : @(1)     // review_type  0普通帖，  1穿搭帖
                          };
    
    ShowLoadingToView(self.navigationController.view);
    self.postViewModel = [[PostViewModel alloc] init];
    
    @weakify(self)
    [self.postViewModel requestPostNetwork:dict completion:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.navigationController.view);
        ZFCommunityPostModel *model = obj;
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


#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [IQKeyboardManager sharedManager].enable  = NO;
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [IQKeyboardManager sharedManager].enable  = YES;
    return YES;
}

#pragma mark - <TTGTextTagCollectionViewDelegate>
- (void)textTagCollectionView:(TTGTextTagCollectionView *)textTagCollectionView didTapTag:(NSString *)tagText atIndex:(NSUInteger)index selected:(BOOL)selected {
    if (selected) {
        [self.selectedTagArray addObject:tagText];
    } else {

        [self.selectedTagArray removeObject:tagText];
    }
}

- (void)showMaxSelectTagsMessage {
    [self showAlertMessage:ZFLocalizedString(@"Post_VC_Post_MaxTag_Tip",nil)];
}

- (void)showAlertMessage:(NSString *)message {
    UIAlertController *alertController =  [UIAlertController
                                           alertControllerWithTitle: nil
                                           message:message
                                           preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:ZFLocalizedString(@"Post_VC_Post_Alert_OK",nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - getter/setter

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

- (UITextField *)postEditView {
    if (!_postEditView) {
        _postEditView = [[UITextField alloc] initWithFrame:CGRectZero];
        _postEditView.textColor    = [UIColor colorWithRed:51.0 / 255.0 green:51.0 / 255.0 blue:51.0 / 255.0 alpha:1.0];
        _postEditView.font         = [UIFont systemFontOfSize:14.0f];
        _postEditView.placeholder  = ZFLocalizedString(@"community_outfitpost_placetitle", nil);
        _postEditView.delegate     = self;
        [_postEditView convertTextAlignmentWithARLanguage];
        
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, _postEditView.height - 1.0, _postEditView.width, 1.0)];
//        lineView.backgroundColor = [UIColor colorWithHex:0xDDDDDD];
//        [_postEditView addSubview:lineView];
    }
    return _postEditView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor colorWithHex:0xDDDDDD];
    }
    return _lineView;
}
-(TTGTextTagCollectionView *)tagCollectionView {
    if (!_tagCollectionView) {
        _tagCollectionView = [[TTGTextTagCollectionView alloc] init];
        _tagCollectionView.frame = CGRectZero;
        _tagCollectionView.tagTextFont = [UIFont systemFontOfSize:14.0f];
        
        _tagCollectionView.tagTextColor = [UIColor colorWithHex:0x999999];
        _tagCollectionView.tagSelectedTextColor = ZFCOLOR(255, 168, 0, 1);
        
        _tagCollectionView.tagBackgroundColor = [UIColor whiteColor];
        _tagCollectionView.tagSelectedBackgroundColor = [UIColor whiteColor];
        
        _tagCollectionView.horizontalSpacing = 10.0;
        _tagCollectionView.verticalSpacing = 10.0;
        
        _tagCollectionView.tagBorderColor = ZFCOLOR(221, 221, 221, 1);
        _tagCollectionView.tagSelectedBorderColor = ZFCOLOR(255, 168, 0, 1);
        _tagCollectionView.tagBorderWidth = 1.0;
        _tagCollectionView.tagSelectedBorderWidth = 1.0;
        
        _tagCollectionView.tagCornerRadius = 2;
        _tagCollectionView.contentInset = UIEdgeInsetsMake(0, 12, 0, 12);
        _tagCollectionView.delegate = self;
    }
    return _tagCollectionView;
}
@end
