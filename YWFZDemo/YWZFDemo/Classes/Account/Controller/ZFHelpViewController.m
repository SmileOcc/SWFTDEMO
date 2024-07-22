//
//  HelpViewController.m
//  ZZZZZ
//
//  Created by YW on 18/9/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFHelpViewController.h"
#import "HelpViewModel.h"
#import "HelpModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFWebViewViewController.h"
#import "ZFContactUsViewController.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "UIView+ZFViewCategorySet.h"

#import "Masonry.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

@interface ZFHelpViewController () <ZFInitViewProtocol, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) HelpViewModel         *helpViewModel;
@property (nonatomic, strong) UITableView           *tableView;
@property (nonatomic, strong) NSMutableArray        *dataArray;
@property (nonatomic, copy) NSString                *targetClassName;

@end

@implementation ZFHelpViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self zfInitView];
    [self zfAutoLayoutView];
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)goBackAction {
    [self popUpperClassRelativeClass:self.targetClassName];
}

- (void)goBackUpperClassRelativeClass:(NSString *)className {
    self.fd_interactivePopDisabled = YES;
    self.targetClassName = className;
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"cellId";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentNatural;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    UIImage *image = [UIImage imageNamed:@"account_arrow_right"];
    if ([cell viewWithTag:10086]) {
        UIImageView *imgV = [cell viewWithTag:10086];
        imgV.image = image;
    } else {
        UIImageView *imgV = [[UIImageView alloc] initWithImage:image];
        [imgV convertUIWithARLanguage];
        imgV.tag = 10086;
        [cell addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(cell.mas_trailing).mas_offset(-12);
            make.centerY.mas_equalTo(cell);
        }];
    }
    HelpModel * model = self.dataArray[indexPath.row];
    cell.textLabel.text = model.title;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HelpModel *model = self.dataArray[indexPath.row];
    
    //这里为什么用ZFContactUsViewController, 因为H5用WKWebView传很容易丢失, 改用UIwebview
    if ([model.url containsString:@"contact-us"] || [model.title containsString:@"Contact Us"] ||
        [model.url containsString:@"terms-of-use"] || [model.title containsString:@"Terms of Use"]) {
        
        @weakify(self)
        [self judgePresentLoginVCCompletion:^{
            @strongify(self)
            ZFContactUsViewController *webVC = [[ZFContactUsViewController alloc]init];
            webVC.title = model.title;
            webVC.link_url = model.url;
            [self.navigationController pushViewController:webVC animated:YES];
        }];
        
    } else {
        ZFWebViewViewController *web = [[ZFWebViewViewController alloc]init];
        web.title = model.title;
        web.link_url = model.url;
        [self.navigationController pushViewController:web animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return  CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.title = ZFLocalizedString(@"Help_VC_Title",nil);
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)requestData {
    ShowLoadingToView(self.view);
    @weakify(self)
    [self.helpViewModel requestNetwork:nil completion:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
        self.dataArray = obj;
        [self.tableView reloadData];
        
    } failure:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
        @weakify(self)
        self.tableView.blankPageViewActionBlcok = ^(ZFBlankPageViewStatus status) {
            @strongify(self)
            [self requestData];
        };
        [self.tableView showRequestTip:nil];
    }];
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.bounces = YES;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (HelpViewModel * )helpViewModel {
    if (_helpViewModel == nil) {
        _helpViewModel = [[HelpViewModel alloc]init];
    }
    return _helpViewModel;
}

@end
