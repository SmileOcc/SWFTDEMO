//
//  ZFCommunitySearchFriendsViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/7/26.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunitySearchFriendsViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunitySearchResultView.h"
#import "ZFCommunitySearchCommonView.h"
#import "ZFCommunitySearchViewModel.h"
#import "ZFCommunityAccountViewController.h"
#import "ZFCommunityContactsViewController.h"
#import "ZFShare.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "NSObject+Swizzling.h"
#import "SystemConfigUtils.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCommunitySearchFriendsViewController () <ZFInitViewProtocol, UISearchBarDelegate,ZFShareViewDelegate>

@property (nonatomic, strong) UISearchBar                       *friendSearchBar;
@property (nonatomic, strong) ZFCommunitySearchResultView       *resultView;
@property (nonatomic, strong) ZFCommunitySearchCommonView       *commonView;
@property (nonatomic, strong) UIView                            *maskView;
@property (nonatomic, strong) ZFCommunitySearchViewModel        *viewModel;
@property (nonatomic, strong) ZFShareView                       *shareView;
@end

@implementation ZFCommunitySearchFriendsViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self zfInitView];
    [self zfAutoLayoutView];
}

#pragma mark - private methods
- (void)jumpToCommunityAccountWithUserId:(NSString *)userId {
    ZFCommunityAccountViewController *accountVC = [[ZFCommunityAccountViewController alloc] init];
    accountVC.userId = userId;
    [self.navigationController pushViewController:accountVC animated:YES];
}

- (void)jumpToContactsViewController {
    ZFCommunityContactsViewController *contactsVC = [[ZFCommunityContactsViewController alloc] init];
    [self.navigationController pushViewController:contactsVC animated:YES];
}

#pragma mark - action methods
- (void)backButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changeCancelBtnColor:(BOOL)isEditing {
    if (![UISearchBar zf_hasVarName:@"cancelButton"]) {
        YWLog(@"UISearchBar类没有 cancelButton属性 ");
        return;
    }
    
    UIButton *cancelButton = [self.friendSearchBar valueForKey:@"cancelButton"];
    if ([cancelButton isKindOfClass:[UIButton class]]) {
        if (isEditing) {
            [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        } else {
            [cancelButton setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - <UISearchBarDelegate>

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self changeCancelBtnColor:YES];
    self.commonView.hidden = NO;
    self.commonView.noResultTips = NO;
    self.resultView.hidden = YES;
    self.maskView.hidden = NO;
    [self.resultView clearOldSearchResultsInfo];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self changeCancelBtnColor:NO];
    self.commonView.hidden = NO;
    self.commonView.noResultTips = NO;
    self.resultView.hidden = YES;
    self.maskView.hidden = YES;
    [self.resultView clearOldSearchResultsInfo];
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if(searchBar.returnKeyType != UIReturnKeySearch || searchBar.text.length <= 0) {
        self.commonView.hidden = NO;
        self.resultView.hidden = YES;
        return ;
    }
    self.maskView.hidden = YES;
    self.commonView.hidden = YES;
    self.resultView.hidden = NO;
    self.resultView.searchKey = searchBar.text;
    [searchBar resignFirstResponder];
}

#pragma mark - ZFShareViewDelegate
- (void)zfShsreView:(ZFShareView *)shareView didSelectItemAtIndex:(NSUInteger)index {
    NativeShareModel *model = [[NativeShareModel alloc] init];
    NSString *appCommunityShareURL = [YWLocalHostManager appCommunityShareURL];
    model.share_url = [NSString stringWithFormat:@"%@?actiontype=6&url=0&name=&source=sharelink",appCommunityShareURL];
    model.share_imageURL = shareView.topView.imageName;
    model.share_description = shareView.topView.title;
    model.fromviewController = self;
    model.sharePageType = ZFSharePage_CommunitySearchFriendsType;
    [ZFShareManager shareManager].model = model;
    [ZFShareManager shareManager].currentShareType = index;
    switch (index) {
        case ZFShareTypeWhatsApp: {
            [[ZFShareManager shareManager] shareToWhatsApp];
        }
            break;
        case ZFShareTypeFacebook:
        {
            [[ZFShareManager shareManager] shareToFacebook];
        }
            break;
        case ZFShareTypeMessenger:
        {
            [[ZFShareManager shareManager] shareToMessenger];
        }
            break;
        case ZFShareTypePinterest: {
            [[ZFShareManager shareManager] shareToPinterest];
        }
            break;
        case ZFShareTypeCopy:
        {
            [[ZFShareManager shareManager] copyLinkURL];
        }
            break;
        case ZFShareTypeMore: {
            [[ZFShareManager shareManager] shareToMore];
        }
            break;
        case ZFShareTypeVKontakte: {
            [[ZFShareManager shareManager] shareVKontakte];
        }
            break;
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.title = ZFLocalizedString(@"FavesViewModel_NoData_AddMoreFriends", nil);
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.friendSearchBar];
    [self.view addSubview:self.commonView];
    [self.view addSubview:self.resultView];
    [self.view addSubview:self.maskView];
}

- (void)zfAutoLayoutView {
    [self.friendSearchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    
    [self.commonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.friendSearchBar.mas_bottom);
        make.leading.trailing.bottom.mas_equalTo(self.view);
    }];
    
    [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.friendSearchBar.mas_bottom);
        make.leading.trailing.bottom.mas_equalTo(self.view);
    }];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.friendSearchBar.mas_bottom);
        make.leading.trailing.bottom.mas_equalTo(self.view);
    }];
}

#pragma mark - getter
- (UISearchBar *)friendSearchBar {
    if (!_friendSearchBar) {
        _friendSearchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
        _friendSearchBar.barTintColor = ZFCOLOR(246, 246, 246, 1.0);
        _friendSearchBar.backgroundImage = [UIImage new];
        _friendSearchBar.searchBarStyle = UISearchBarStyleDefault;
        _friendSearchBar.translucent = NO; //是否半透明
        _friendSearchBar.showsCancelButton = YES;
        _friendSearchBar.tintColor = [UIColor blackColor];
        [_friendSearchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        _friendSearchBar.returnKeyType = UIReturnKeySearch; //设置按键类型
        _friendSearchBar.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
        [_friendSearchBar sizeToFit];
        _friendSearchBar.placeholder = ZFLocalizedString(@"Search_PlaceHolder_Search",nil);
        _friendSearchBar.delegate = self;
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            if ([UISearchBar zf_hasVarName:@"searchField"]) {
                UITextField *searchField = [_friendSearchBar valueForKey:@"searchField"];
                searchField.textAlignment = NSTextAlignmentRight;
            }
        }
    }
    return _friendSearchBar;
}

- (ZFCommunitySearchResultView *)resultView {
    if (!_resultView) {
        _resultView = [[ZFCommunitySearchResultView alloc] initWithFrame:CGRectZero];
        _resultView.hidden = YES;
        @weakify(self);
        _resultView.communitySearchResultUserInfoCompletionHandler = ^(NSString *userId) {
            @strongify(self);
            [self jumpToCommunityAccountWithUserId:userId];
        };
        
        _resultView.communitySearchNoResultsCompletionHandler = ^{
            @strongify(self);
            self.resultView.hidden = YES;
            self.commonView.hidden = NO;
            self.commonView.noResultTips = YES;
        };
    }
    return _resultView;
}

- (ZFCommunitySearchCommonView *)commonView {
    if (!_commonView) {
        _commonView = [[ZFCommunitySearchCommonView alloc] initWithFrame:CGRectZero];
        @weakify(self);
        
        _commonView.communitySuggestedUserInfoCompletionHandler = ^(NSString *userId) {
            @strongify(self);
            [self jumpToCommunityAccountWithUserId:userId];
        };
        
        _commonView.communityInviteContactsCompletionHandler = ^{
            @strongify(self);
            [self jumpToContactsViewController];
        };
        
        _commonView.communityInviteFacebookCompletionHandler = ^{
            @strongify(self);
            [self.shareView open];
        };
    }
    return _commonView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _maskView.hidden = YES;
        @weakify(self)
        [_maskView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self)
            [self searchBarCancelButtonClicked:self.friendSearchBar];
        }];
    }
    return _maskView;
}

- (ZFCommunitySearchViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunitySearchViewModel alloc] init];
    }
    return _viewModel;
}

- (ZFShareView *)shareView {
    if (!_shareView) {
        _shareView = [[ZFShareView alloc] init];
        _shareView.delegate = self;
        
        ZFShareTopView *shareTopView = [[ZFShareTopView alloc] init];
        [shareTopView updateImage:nil
                       title:ZFLocalizedString(@"FriendsCommendViewModel_Share_Content", nil)
                     tipType:ZFShareDefaultTipTypeCommunity];
        _shareView.topView = shareTopView;

        [ZFShareManager authenticatePinterest];
    }
    return _shareView;
}

- (void)dealloc {
    if (_shareView) {
        [self.shareView removeFromSuperview];
        self.shareView.delegate = nil;
        self.shareView = nil;
    }
}

@end
