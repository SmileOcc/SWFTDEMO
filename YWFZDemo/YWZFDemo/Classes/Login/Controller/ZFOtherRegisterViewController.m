//
//  ZFOtherRegisterViewController.m
//  ZZZZZ
//
//  Created by YW on 28/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOtherRegisterViewController.h"
#import "ZFRegisterCellTypeModel.h"
#import "ZFRegisterEmailCell.h"
#import "ZFRegisterNameCell.h"
#import "ZFRegisterHeaderView.h"
#import "ZFRegisterFooterView.h"
#import "ZFWebViewViewController.h"
#import "ZFInitViewProtocol.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFOtherRegisterViewController ()<UITableViewDelegate,UITableViewDataSource,ZFInitViewProtocol>
@property (nonatomic, strong) UITableView                   *tableView;
@property (nonatomic, strong) NSMutableArray<NSArray *>     *sectionArray;
@property (nonatomic, strong) ZFRegisterHeaderView          *headerView;
@property (nonatomic, strong) ZFRegisterFooterView          *footerView;
@end

@implementation ZFOtherRegisterViewController
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = ZFLocalizedString(@"register_title", nil);
    [self zfInitView];
    [self zfAutoLayoutView];
    [self configureCellModel];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.model.email) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowPlaceholderAnimationNotification object:nil];
    }
}

- (void)zfInitView {
    self.view.backgroundColor = ZFCOLOR(247, 247, 247, 1);
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsZero);
    }];
}

#pragma mark - Private method
- (void)configureCellModel {
    [self.sectionArray removeAllObjects];
    NSArray *sections = @[@[@0],@[@1]];
    for (NSArray *cells in sections) {
        NSMutableArray<ZFRegisterCellTypeModel *> *cellModelArray = [NSMutableArray arrayWithCapacity:cells.count];
        for (NSNumber *type in cells) {
            RegisterCellType cellType = [type integerValue];
            CGFloat cellHeight = (cellType == RegisterCellTypeEmail) ? 86 : 122;
            ZFRegisterCellTypeModel *typeModel = [[ZFRegisterCellTypeModel alloc] initWithType:cellType cellHeight:cellHeight];
            [cellModelArray addObject:typeModel];
        }
        [self.sectionArray addObject:[cellModelArray copy]];
    }
}

/**
 * 处理协议弹框事件方法
 */
- (void)dealWithTreatyLinkAction:(ZFTreatyLinkAction)actionType {
    NSString *title = nil;
    NSString *url = nil;
    NSString *appH5BaseURL = [YWLocalHostManager appH5BaseURL];
    switch (actionType) {
        case TreatyLinkAction_ProvacyPolicy:
        {
            title = ZFLocalizedString(@"Register_PrivacyPolicy",nil);
            url = [NSString stringWithFormat:@"%@privacy-policy/?app=1&lang=%@",appH5BaseURL, [ZFLocalizationString shareLocalizable].nomarLocalizable];
        }
            break;
        case TreatyLinkAction_TermsUse:
        {
            title = ZFLocalizedString(@"Login_Terms_Web_Title",nil);
            url = [NSString stringWithFormat:@"%@terms-of-use/?app=1&lang=%@",appH5BaseURL, [ZFLocalizationString shareLocalizable].nomarLocalizable];
        }
            break;
        default:
            break;
    }
    
    if (title && url) {
        [self jumpToWebVCWithTitle:title url:url];
    }
}

- (void)jumpToWebVCWithTitle:(NSString *)title url:(NSString *)url{
    ZFWebViewViewController *web = [[ZFWebViewViewController alloc] init];
    web.title = title;
    web.link_url = url;
    [self.navigationController pushViewController:web animated:YES];
    self.navigationController.navigationBar.hidden = NO;
}

- (BOOL)registerCheck {
    if (![NSStringUtils isValidEmailString:self.model.email] || ZFIsEmptyString(self.model.email) || !self.model.isValidEmail) {
        self.model.showEmailError = YES;
        [self.tableView reloadData];
        return NO;
    } else {
        self.model.showEmailError = NO;
    }
    
    if (!self.model.isAgree || !self.model.isSubscribe) {
        [self.footerView showTipAnimation];
        return NO;
    }
    
    return YES;
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sectionArray[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFRegisterCellTypeModel *cellTypeModel = self.sectionArray[indexPath.section][indexPath.row];
    switch (cellTypeModel.type) {
        case RegisterCellTypeEmail:
        {
            ZFRegisterEmailCell *emailCell = [ZFRegisterEmailCell cellWith:tableView index:indexPath];
            emailCell.model = self.model;
            @weakify(self)
            emailCell.emailTextFieldEditingDidEndHandler = ^(ZFRegisterModel *model) {
                @strongify(self)
                self.model = model;
            };
            return emailCell;
        }
            break;
        case RegisterCellTypeName:
        {
            ZFRegisterNameCell *nameCell = [ZFRegisterNameCell cellWith:tableView index:indexPath];
            nameCell.model = self.model;
            @weakify(self)
            nameCell.completeHandler = ^(ZFRegisterModel *model) {
                @strongify(self)
                self.model = model;
            };
            return nameCell;
        }
            break;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFRegisterCellTypeModel *cellTypeModel = self.sectionArray[indexPath.section][indexPath.row];
    return cellTypeModel.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 12;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Getter
- (ZFRegisterHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[ZFRegisterHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 191)];
    }
    return _headerView;
}

- (ZFRegisterFooterView *)footerView {
    if (!_footerView) {
        @weakify(self)
        _footerView = [[ZFRegisterFooterView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 161)];
        _footerView.privacyPolicyActionBlock = ^(ZFTreatyLinkAction actionType) {
            @strongify(self);
            [self dealWithTreatyLinkAction:actionType];
        };
        _footerView.registerButtonCompletionHandler = ^(BOOL isAgree, BOOL isSubscribe) {
            @strongify(self);
            self.model.isAgree = isAgree;
            self.model.isSubscribe = isSubscribe;
            
            if ([self registerCheck]) {
                if (self.registerHandler) {
                    self.registerHandler(self.model);
                    [self goBackAction];
                }
            }
        };
    }
    return _footerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = ZFCOLOR(247, 247, 247, 1);
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = self.headerView;
        _tableView.tableFooterView = self.footerView;
    }
    return _tableView;
}

- (NSMutableArray<NSArray *> *)sectionArray {
    if (!_sectionArray) {
        _sectionArray = [NSMutableArray array];
    }
    return _sectionArray;
}

@end

