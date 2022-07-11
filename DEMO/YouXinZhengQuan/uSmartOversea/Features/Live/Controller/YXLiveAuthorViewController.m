//
//  YXLiveAuthorViewController.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/10/10.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXLiveAuthorViewController.h"
#import "YXLiveAuthorViewModel.h"
#import "YXLiveAuthorCell.h"
#import "YXLiveDesCell.h"
#import <DTCoreText/DTCoreText.h>
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXLiveAuthorViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) YXLiveAuthorViewModel *viewModel;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation YXLiveAuthorViewController

@dynamic viewModel;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self setUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)setUI {
    
    [self.tableView registerClass:[YXLiveAuthorCell class] forCellReuseIdentifier:@"YXLiveAuthorCell"];
    [self.tableView registerClass:[YXLiveDesCell class] forCellReuseIdentifier:@"YXLiveDesCell"];
    
    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)loadData {
    @weakify(self);
    [[self.viewModel.getFollowStatusCommand execute:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
}

#pragma mark - tableView delegata
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        YXLiveAuthorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YXLiveAuthorCell" forIndexPath:indexPath];
        cell.anchorModel = self.viewModel.liveModel.anchor;
        cell.isFollow = self.viewModel.isFollow;
        @weakify(self);
        [cell setClickFollowCallBack:^(BOOL isFollow) {
            @strongify(self);
            if ([YXUserManager isLogin]) {
                [[self.viewModel.updateFollowStatusCommand execute:@(isFollow)] subscribeNext:^(NSNumber *isSuccess) {
                    if (isSuccess.boolValue) {
                        self.viewModel.isFollow = !self.viewModel.isFollow;
                        [self.tableView reloadData];
                    }
                }];
            } else {
                [(NavigatorServices *)self.viewModel.services pushToLoginVCWithCallBack:^(NSDictionary<NSString *,id> * _Nonnull dic) {
                                    
                }];
            }

        }];
        
        return cell;
    } else {
        YXLiveDesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YXLiveDesCell" forIndexPath:indexPath];
        cell.desStr = self.viewModel.liveModel.detail;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        NSString *introduce = self.viewModel.liveModel.anchor.introduce;
        if (introduce.length > 0) {
           CGFloat height = [YXToolUtility getStringSizeWith:introduce andFont:[UIFont systemFontOfSize:14] andlimitWidth:YXConstant.screenWidth - 64 andLineSpace:5].height;
            if (height > 40) {
                return 70 + height;
            }
        }
    } else {
                
        if (self.viewModel.liveModel.detail.length > 0) {
            NSData *data = [self.viewModel.liveModel.detail dataUsingEncoding:NSUTF8StringEncoding];
            NSAttributedString *att = [[NSAttributedString alloc] initWithHTMLData:data options:@{DTDefaultTextColor: QMUITheme.textColorLevel4, DTDefaultFontSize: @(14), DTDefaultLinkColor: QMUITheme.themeTextColor, DTDefaultLinkDecoration: @(NO), DTDefaultLineHeightMultiplier : @(1.4) } documentAttributes:NULL];
            
            DTCoreTextLayouter *layout = [[DTCoreTextLayouter alloc] initWithAttributedString:att];
            CGRect maxRect = CGRectMake(0, 0, YXConstant.screenWidth - 24, CGFLOAT_HEIGHT_UNKNOWN);
            NSRange entireString = NSMakeRange(0, att.length);
            DTCoreTextLayoutFrame *layoutFrame = [layout layoutFrameWithRect:maxRect range:entireString];
            
            return layoutFrame.frame.size.height;
        }
    }
    
    return 110;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 50)];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, (50 - 17) * 0.5, 4, 17)];
    lineView.backgroundColor = QMUITheme.themeTextColor;
    UILabel *label = [UILabel labelWithText:@"" textColor:[UIColor qmui_colorWithHexString:@"#353547"] textFont:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium]];
    label.frame = CGRectMake(12, 0, 150, 50);
    
    if (section == 0) {
        label.text = [YXLanguageUtility kLangWithKey:@"live_teacher_introduction"];
    } else {
        label.text = [YXLanguageUtility kLangWithKey:@"live_description"];
    }
    [header addSubview:lineView];
    [header addSubview:label];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (self.viewModel.liveModel.anchor.anchor_id.length > 0) {
            NSString *jumpUrl = [YXH5Urls liveAnchorDetailUrlWith:self.viewModel.liveModel.anchor.anchor_id];
            [YXWebViewModel pushToWebVC:jumpUrl];
        }
    }
}

#pragma mark - lazy load
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

@end
