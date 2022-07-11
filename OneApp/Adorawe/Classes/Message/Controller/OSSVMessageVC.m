//
//  OSSVMessageVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//


#import "OSSVMessageVC.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "OSSVMessageActivityVC.h"
#import "OSSVMessageNotifyVC.h"
#import "OSSVMessageSystemVC.h"
#import "OSSVMessageSystemDetailVC.h"

#import "OSSVMessageTableView.h"
#import "OSSVMessageHeaderView.h"
#import "OSSVMessageViewModel.h"
#import "OSSVMessageNotifyViewModel.h"
#import "OSSVMessageActivityViewModel.h"

#import "UIButton+STLCategory.h"


@interface OSSVMessageVC ()<STLMessageTableviewDelegate>

@property (nonatomic, strong) OSSVMessageListModel          *msgListModel;

@property (nonatomic, strong) OSSVMessageHeaderView         *messageHeaderView;
@property (nonatomic, strong) UIView                       *contentView;

@property (nonatomic, strong) OSSVMessageViewModel          *viewModel;

@property (nonatomic, strong) UIScrollView                 *emptyBackView;

@property (nonatomic, assign) BOOL                      testFirst;

@property (nonatomic, assign) NSInteger                    currentIndex;

@end

@implementation OSSVMessageVC


#pragma mark - life cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadMessageData];
    
    if ([OSSVAccountsManager sharedManager].isSignIn) {
        if ([OSSVAccountsManager sharedManager].appUnreadMessageNum > 0) {
            [OSSVAccountsManager sharedManager].appUnreadMessageNum = 0;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_ChangeMessageCountDot object:nil];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.fd_prefersNavigationBarHidden = YES;
    self.title = STLLocalizedString_(@"Message", nil);
    self.currentIndex = 0;
    
    self.view.backgroundColor = [OSSVThemesColors col_F5F5F5];
    [self.view addSubview:self.messageHeaderView];
    
    [self.view addSubview:self.contentView];
    
    
    [self.messageHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top);
        make.height.mas_equalTo([OSSVMessageHeaderView mssageHeadercontentH]);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view);
        make.leading.mas_equalTo(self.view.mas_leading);
        make.trailing.mas_equalTo(self.view.mas_trailing);
        make.top.mas_equalTo(self.messageHeaderView.mas_bottom);
    }];
    
    [self createEmptyViews];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)actionMessage:(OSSVMessageModel *)model index:(NSInteger)index{
    [self addChileView:model index:index];
}

#pragma mark - private methods

- (void)loadMessageData {
    
//    if (!self.testFirst) {
//        self.testFirst = YES;
//
//        if (self.msgListModel) {
//            self.emptyBackView.hidden = YES;
//            [self.emptyBackView removeFromSuperview];
//        } else if(self.emptyBackView.superview){
//            self.emptyBackView.hidden = NO;
//        }
//
//        return;
//    }
    @weakify(self)
    [self.viewModel requestNetwork:nil
                        completion:^(OSSVMessageListModel *obj) {
        @strongify(self)

        self.messageHeaderView.hidden = NO;
        if (self.msgListModel && obj) {
            self.msgListModel = obj;
            [self.messageHeaderView updateModel:self.msgListModel index:self.currentIndex isFirst:NO];

        } else if(obj){
            self.msgListModel = obj;
            [self.messageHeaderView updateModel:self.msgListModel index:self.currentIndex isFirst:YES];
            if (self.msgListModel.bubbles.count > 0) {
                [self addChileView:self.msgListModel.bubbles.firstObject index:0];
            }
        }

        if (self.messageRefresh){
            self.messageRefresh(self.msgListModel);
        }

        if (self.msgListModel) {
            self.emptyBackView.hidden = YES;
            [self.emptyBackView removeFromSuperview];
        } else if(self.emptyBackView.superview){
            self.emptyBackView.hidden = NO;
            [self.emptyBackView showRequestTip:@{}];
        }
    } failure:^(id obj){
        @strongify(self)
        self.messageHeaderView.hidden = YES;
        self.emptyBackView.hidden = NO;
        [self.emptyBackView showRequestTip:@{}];
    }];
}

- (void)addChileView:(OSSVMessageModel *)model index:(NSInteger)index{
    
    if (!model) {
        return;
    }
    self.currentIndex = index;
    NSArray *subCtrls = self.childViewControllers;
    
    STLBaseCtrl  *tempVC;
    __block BOOL hadCtrl = NO;
    if (model.type.integerValue == 1 || model.type.integerValue == 2) {
        [subCtrls enumerateObjectsUsingBlock:^(UIViewController *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:OSSVMessageNotifyVC.class]) {
                OSSVMessageNotifyVC *notifyVC = (OSSVMessageNotifyVC*)obj;
                if (model.type.integerValue == notifyVC.type) {
                    [self.contentView bringSubviewToFront:obj.view];
                    [notifyVC refreshRequest:[model.count integerValue] > 0];
                    
                    hadCtrl = YES;
                    *stop = YES;
                }
            }
        }];
        
        if (hadCtrl) {
            return;
        }
        OSSVMessageNotifyVC *notifyVC = [[OSSVMessageNotifyVC alloc] init];
        notifyVC.typeModel = model;
        notifyVC.type = model.type.integerValue;
        @weakify(self)
        [notifyVC setBlock:^{
            @strongify(self)
            [self loadMessageData];
        }];
        tempVC = notifyVC;
        
    } else if (model.type.integerValue == 3) {//活动信息
        
        [subCtrls enumerateObjectsUsingBlock:^(UIViewController *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:OSSVMessageActivityVC.class]) {
                [self.contentView bringSubviewToFront:obj.view];
                
                OSSVMessageActivityVC *msgActivityVC = (OSSVMessageActivityVC*)obj;
                [msgActivityVC refreshRequest:[model.count integerValue] > 0];

                hadCtrl = YES;
                *stop = YES;
            }
        }];
        
        if (hadCtrl) {
            return;
        }
        OSSVMessageActivityVC *msgActivityVC = [[OSSVMessageActivityVC alloc] init];
        msgActivityVC.typeModel = model;
        @weakify(self)
        [msgActivityVC setBlock:^{
            @strongify(self)
            [self loadMessageData];
        }];
        tempVC = msgActivityVC;

    } else if (model.type.integerValue == 4) {//系统公告
        [subCtrls enumerateObjectsUsingBlock:^(UIViewController *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:OSSVMessageSystemVC.class]) {
                [self.contentView bringSubviewToFront:obj.view];
                
                OSSVMessageSystemVC *systemVC = (OSSVMessageSystemVC*)obj;
                [systemVC refreshRequest:[model.count integerValue] > 0];
                
                hadCtrl = YES;
                *stop = YES;
            }
        }];
        
        if (hadCtrl) {
            return;
        }
        OSSVMessageSystemVC *systemVC = [[OSSVMessageSystemVC alloc] init];
        systemVC.typeModel = model;
        @weakify(self)
        [systemVC setBlock:^{
            @strongify(self)
            [self loadMessageData];
        }];
        tempVC = systemVC;
    }
    
    if (tempVC) {
        tempVC.view.bounds = self.contentView.bounds;
        [self.contentView addSubview:tempVC.view];
        [self addChildViewController:tempVC];
        [tempVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
    }
}

#pragma mark - setters and getters

- (OSSVMessageViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [OSSVMessageViewModel new];
    }
    return _viewModel;
}


- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = [OSSVThemesColors col_F5F5F5];
    }
    return _contentView;;
}

//-(OSSVMessageTableView *)tableView {
//    if (!_tableView) {
//        _tableView = [[OSSVMessageTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
//        _tableView.rowHeight = UITableViewAutomaticDimension;
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.myDelegate = self;
//        _tableView.rowHeight = 60;
//        _tableView.backgroundColor = [OSSVThemesColors col_F5F5F5];
//    }
//    return _tableView;
//}


- (OSSVMessageHeaderView *)messageHeaderView {
    if (!_messageHeaderView) {
        _messageHeaderView = [[OSSVMessageHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, [OSSVMessageHeaderView mssageHeadercontentH])];
        _messageHeaderView.hidden = YES;
        
        @weakify(self)
        _messageHeaderView.tapItemBlock = ^(OSSVMessageModel *model, NSInteger index) {
            @strongify(self)
            
            //数据GA ok
            
            [OSSVAnalyticsTool analyticsGAEventWithName:@"message_action" parameters:@{
                @"screen_group":@"Message",
                @"action":STLToString(model.type)}];
            
            [self actionMessage:model index:index];
        };
    }
    return _messageHeaderView;
}



#pragma mark - 空白View
- (void)createEmptyViews {
    self.emptyBackView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.emptyBackView.backgroundColor = [OSSVThemesColors col_F5F5F5];
    self.emptyBackView.hidden = YES;
    [self.view addSubview:self.emptyBackView];
    [self.emptyBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
    }];
    
    // 这样做是为了增加  菊花的刷新效果
    @weakify(self)
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        [self.viewModel requestNetwork:STLRefresh completion:^(id obj) {
            @strongify(self)
            [self loadMessageData];
            [self.emptyBackView.mj_header endRefreshing];
        } failure:^(id obj) {
            @strongify(self)
            [self.emptyBackView.mj_header endRefreshing];
            [self.emptyBackView showRequestTip:nil];
        }];
    }];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.emptyBackView.mj_header = header;
    
    self.emptyBackView.mj_header = header;
    self.emptyBackView.blankPageImageViewTopDistance = 40;
    self.emptyBackView.emptyDataImage = [UIImage imageNamed:@"my_message_bank"];
    if (APP_TYPE == 3) {
        self.emptyBackView.emptyDataBtnTitle = STLLocalizedString_(@"retry", nil);
    } else {
        self.emptyBackView.emptyDataBtnTitle = STLLocalizedString_(@"retry", nil).uppercaseString;
    }
    self.emptyBackView.blankPageViewActionBlcok = ^(STLBlankPageViewStatus status) {
        @strongify(self)
        [self.emptyBackView.mj_header beginRefreshing];
    };
}

- (void)emptyHomeTapAction {
    [self.emptyBackView.mj_header beginRefreshing];
}


@end
