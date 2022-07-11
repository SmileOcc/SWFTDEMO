//
//  OSSVMySizeVC.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVMySizeVC.h"
#import "OSSVMysSizesViewModel.h"
#import "OSSVMysSizesViewModel.h"
#import "OSSVMysSizesCell.h"
#import "OSSVMyRulerVC.h"
#import "OSSVSizesModel.h"

#import "Adorawe-Swift.h"
@interface OSSVMySizeVC ()

@property (nonatomic, strong) OSSVMysSizesViewModel *viewModel;
@property (nonatomic, strong) UITableView *mainTable;
@property (nonatomic, strong) OSSVSizesModel *sizeModel;

@property (nonatomic, strong) UIActivityIndicatorView  *actView;

@property (nonatomic, strong) UIView  *maskView;

@property (nonatomic, strong) UILabel *tipLab;

@end

@implementation OSSVMySizeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpRightNavigation];
    [self setupView];
}

- (void)setUpRightNavigation{
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] initWithTitle:STLLocalizedString_(@"Save", nil) style:UIBarButtonItemStylePlain target:self action:@selector(saveSize)];
    self.navigationItem.rightBarButtonItem = saveItem;
}

- (void)setupView{
    self.title = STLLocalizedString_(@"My_Size", nil);
    [self.view addSubview:self.mainTable];
    [self.view addSubview:self.tipLab];
    
    [self.mainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12);
        make.leading.mas_equalTo(12);
        make.trailing.mas_equalTo(-12);
        make.height.mas_equalTo(316);
    }];
    
    [self.view addSubview: _tipLab];
    
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainTable.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.mainTable.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.mainTable.mas_trailing).offset(-12);
    }];
    
    [self.view addSubview:self.actView];
    [self.actView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(20);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(self.view.mas_centerY);
    }];
    
    [self requestData];
}

- (void)requestData{
    [self.actView startAnimating];
    @weakify(self);
    [self.viewModel requestNetwork:nil completion:^(id obj) {
        @strongify(self);
        self.sizeModel = (OSSVSizesModel *)obj;
        [self.actView stopAnimating];
        [self.mainTable reloadData];
    } failure:^(id obj) {
        @strongify(self);
        self.sizeModel = (OSSVSizesModel *)obj;
        [self.actView stopAnimating];
        [self.mainTable reloadData];
    }];
}

/// 保存尺码
- (void)saveSize{
    if (self.sizeModel && [self.sizeModel.height floatValue] != 0 && [self.sizeModel.weight floatValue] != 0) {
        [self.actView startAnimating];
        @weakify(self);
        [self.viewModel saveRequestNetwork:@{} completion:^(id _Nonnull successObj) {
            @strongify(self);
            [self.actView stopAnimating];
            // 埋点
            NSDictionary *parm = @{@"unit":@(self.sizeModel.size_type),
                                   @"gender":@(self.sizeModel.gender),
                                   @"height":self.sizeModel.height,
                                   @"weight":self.sizeModel.weight,
                                   @"shape":self.sizeModel.option
            };
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"FillInSize" parameters:parm];
        } failure:^(id _Nonnull failObj) {
            @strongify(self);
            [self.actView stopAnimating];
        }];
    }else{
        
        [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:STLLocalizedString_(@"SaveNullTip", nil) buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok",nil)] : @[STLLocalizedString_(@"ok",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
            
        }];
    }
}

/// lazy
- (OSSVMysSizesViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[OSSVMysSizesViewModel alloc] init];
        @weakify(self);
        _viewModel.cellDidClick = ^(sizeCellType type, OSSVSizesModel * _Nonnull sizeModel) {
            @strongify(self);
            if (type == sizeCellTypeHeight || type == sizeCellTypeWeight) {
                OSSVMyRulerVC *ruleVC = [OSSVMyRulerVC new];
                [ruleVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
                ruleVC.type = type;
                ruleVC.sizeModel = sizeModel;
                [self.navigationController.view addSubview:self.maskView];
                [self presentViewController:ruleVC animated:YES completion:^{
                    nil;
                }];
                
                // rule中点击save的回调
                ruleVC.saveBtnblock = ^(sizeCellType type, NSString * _Nonnull value) {
                    if (self.maskView) {
                        [self.maskView removeFromSuperview];
                    }
                    if (type == sizeCellTypeHeight) {
                        sizeModel.height = value;
                    }else if (type == sizeCellTypeWeight){
                        sizeModel.weight = value;
                    }
                    [self.mainTable reloadData];
                };
                
                ruleVC.disBtnblock = ^{
                    if (self.maskView) {
                        [self.maskView removeFromSuperview];
                    }
                };
                
            }
        };
        
        _viewModel.changeDescblock = ^(NSString * _Nonnull desc) {
            @strongify(self);
            self.tipLab.text = desc;
        };
    }
    return _viewModel;
}

- (UITableView *)mainTable{
    if (!_mainTable) {
        _mainTable = [[UITableView alloc] initWithFrame:CGRectZero];
        _mainTable.layer.cornerRadius = 3;
        _mainTable.separatorStyle = UITableViewCellSelectionStyleNone;
        _mainTable.showsVerticalScrollIndicator = NO;
        _mainTable.showsHorizontalScrollIndicator = NO;
        _mainTable.delegate = self.viewModel;
        _mainTable.dataSource = self.viewModel;
        [_mainTable registerClass:[OSSVMysSizesCell class] forCellReuseIdentifier:[self.viewModel reuseIdentifier]];
        _mainTable.scrollEnabled = NO;
    }
    return _mainTable;
}

- (UILabel *)tipLab{
    if (!_tipLab) {
        _tipLab = [UILabel new];
        _tipLab.numberOfLines = 0;
        _tipLab.textColor = OSSVThemesColors.col_666666;
        _tipLab.font = FontWithSize(12);
        _tipLab.text = STLLocalizedString_(@"Size_tip", nil);
    }
    return _tipLab;
}

- (UIActivityIndicatorView *)actView {
    if (!_actView) {
        _actView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _actView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _actView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    }
    return _actView;
}

- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _maskView.backgroundColor = [UIColor colorWithRed:0.051 green:0.051 blue:0.051 alpha:0.5];
    }
    return _maskView;
}

@end
