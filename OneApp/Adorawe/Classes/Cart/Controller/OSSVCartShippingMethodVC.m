//
//  OSSVCartShippingMethodVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartShippingMethodVC.h"

/*当前ViewModel*/
#import "OSSVCartShippingMethodViewModel.h"

/*当前Cell*/
#import "OSSVCartShippingMethodCell.h"

@interface OSSVCartShippingMethodVC ()

@property (nonatomic,weak) UITableView *tableView;

@property (nonatomic,strong) OSSVCartShippingMethodViewModel *viewModel;

@end

@implementation OSSVCartShippingMethodVC

/*========================================分割线======================================*/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = STLLocalizedString_(@"shipMethod",nil);
    
    /*界面初始化*/
    [self initView];
}

/*========================================分割线======================================*/

#pragma mark - 界面初始化
- (void)initView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    
    [tableView registerClass:[OSSVCartShippingMethodCell class] forCellReuseIdentifier:NSStringFromClass(OSSVCartShippingMethodCell.class)];
    tableView.backgroundColor = OSSVThemesColors.col_F6F6F6;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 50;
    
    tableView.showsVerticalScrollIndicator = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    
    tableView.dataSource = self.viewModel;
    tableView.delegate = self.viewModel;
    
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    self.tableView = tableView;
}

/*========================================分割线======================================*/

#pragma mark - ViewModel
- (OSSVCartShippingMethodViewModel*)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVCartShippingMethodViewModel alloc] init];
        _viewModel.controller = self;
        
        _viewModel.shippingList = self.shippingList;
        _viewModel.shippingModel = self.shippingModel;
        _viewModel.curRate = self.curRate;
        _viewModel.isOptional = self.isOptional;
        
        @weakify(self)
        _viewModel.selectedBlock = ^(NSInteger index){
            @strongify(self)
            if (self.callBackBlock) {
                self.callBackBlock(self.shippingList[index]);
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
    return _viewModel;
}

/*========================================分割线======================================*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.firstEnter) {
    }
    self.firstEnter = YES;
}

/*========================================分割线======================================*/

@end
