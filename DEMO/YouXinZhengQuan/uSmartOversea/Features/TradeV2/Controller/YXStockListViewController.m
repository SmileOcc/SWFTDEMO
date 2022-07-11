//
//  YXStockListViewController.m
//  YouXinZhengQuan
//
//  Created by ellison on 2018/11/13.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXStockListViewController.h"
#import "YXStockListViewModel.h"
#import "YXStockListHeaderView.h"
#import "YXStockListCell.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>

@interface YXStockListViewController ()

@property (nonatomic, strong, readonly) YXStockListViewModel *viewModel;



@property (nonatomic, strong, readwrite) YXStockListHeaderView *stockListHeaderView;


@end

@implementation YXStockListViewController
@dynamic viewModel;

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.viewModel.isLandscape) {
        self.forceToLandscapeRight = YES;
        [self.view addSubview:self.rotateButton];
        [self.rotateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(-13);
            make.bottom.equalTo(self.view).offset(-20);
            make.width.height.mas_equalTo(30);
        }];
    }
    [self.stockListHeaderView setDefaultSortState:self.viewModel.sortState mobileBrief1Type:self.viewModel.mobileBrief1Type];
    
    if (![[MMKV defaultMMKV] getBoolForKey:NSStringFromClass([YXStockListViewController class]) defaultValue:NO]) {
        [[MMKV defaultMMKV] setBool:YES forKey:NSStringFromClass([YXStockListViewController class])];
        [self.stockListHeaderView scrollToMobileBrief1TypeWithType:[self.sortTypes.lastObject intValue] animate:false];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.viewModel.isLandscape) {
        if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    [self.stockListHeaderView scrollToMobileBrief1TypeWithType:self.viewModel.mobileBrief1Type  animate:true];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}



-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.viewModel.isLandscape) {
        if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        };
    }
}

- (BOOL)preferredNavigationBarHidden {
    if (self.viewModel.isLandscape) {
        return YES;
    }
    return [super preferredNavigationBarHidden];
}

- (BOOL)prefersStatusBarHidden {
    if (self.viewModel.isLandscape) {
        return YES;
    }
    return [super prefersStatusBarHidden];
}

- (void)bindViewModel {
    [super bindViewModel];
    
    if ([self.stockListHeaderView isKindOfClass:[YXStockListHeaderView class]]) {
        @weakify(self)
        [[[RACObserve(self.viewModel, sortState) skip:1] combineLatestWith:RACObserve(self.viewModel, mobileBrief1Type)] subscribeNext:^(RACTuple * _Nullable tuple) {
            @strongify(self)
            [self.stockListHeaderView setSortState:[tuple.first integerValue] mobileBrief1Type:[tuple.second integerValue]];
        }];
        RACChannelTo(self.viewModel, contentOffset) = RACChannelTo(self.stockListHeaderView.scrollView, contentOffset);
    }
}

- (YXStockListHeaderView *)stockListHeaderView {
    if (_stockListHeaderView == nil) {
        _stockListHeaderView = [[YXStockListHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40) sortTypes:self.sortTypes];
        [_stockListHeaderView.lineView setHidden:YES];
        @weakify(self)
        [_stockListHeaderView setOnClickSort:^(YXSortState state, YXMobileBrief1Type type) {
            @strongify(self)
            [self.viewModel.didClickSortCommand execute:@[@(state), @(type)]];
        }];
    }
    return _stockListHeaderView;
}

- (UIButton *)rotateButton {
    if (_rotateButton == nil) {
        if (self.viewModel.isLandscape) {
            _rotateButton = [UIButton buttonWithType:UIButtonTypeCustom image:[UIImage imageNamed:@"rotate_portrait"] target:self action:@selector(rotateButtonAction)];
        } else {
            _rotateButton = [UIButton buttonWithType:UIButtonTypeCustom image:[UIImage imageNamed:@"rotate_portrait"] target:self action:@selector(rotateButtonAction)];
        }
    }
    return _rotateButton;
}

- (void)rotateButtonAction {
    if (self.viewModel.isLandscape) {
        [YXToolUtility forceToPortraitOrientation];
        
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        [self.viewModel.didClickRotateCommand execute:nil];
    }
}

- (void)configureCell:(YXStockListCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {
    if ([cell isKindOfClass:[YXStockListCell class]]) {
        cell.sortTypes = self.sortTypes;
        RACChannelTerminal *channel = RACChannelTo(self.viewModel, contentOffset);
        RACChannelTerminal *cellChannel = RACChannelTo(cell.scrollView, contentOffset);
        
        [[channel takeUntil:cell.rac_prepareForReuseSignal] subscribe:cellChannel];
        [[cellChannel takeUntil:cell.rac_prepareForReuseSignal] subscribe:channel];
    } else if ([cell isKindOfClass:[YXHoldListCell class]]) {
        RACChannelTerminal *channel = RACChannelTo(self.viewModel, contentOffset);
        RACChannelTerminal *cellChannel = RACChannelTo(((YXHoldListCell *)cell).scrollView, contentOffset);
        
        [[channel takeUntil:cell.rac_prepareForReuseSignal] subscribe:cellChannel];
        [[cellChannel takeUntil:cell.rac_prepareForReuseSignal] subscribe:channel];
    }
    [super configureCell:cell atIndexPath:indexPath withObject:object];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.viewModel.isLandscape) {
        return self.stockListHeaderView;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    view.backgroundColor = self.stockListHeaderView.backgroundColor;
    [view addSubview:self.stockListHeaderView];
    [view addSubview:self.rotateButton];
    UIView *line = [UIView lineView];
    [self.rotateButton addSubview:line];
    
    [self.rotateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.height.equalTo(view);
        make.right.equalTo(view);
        make.width.mas_equalTo(30);
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.rotateButton);
        make.height.mas_equalTo(1);
    }];
    
    [self.stockListHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(view);
        make.right.equalTo(self.rotateButton.mas_left);
    }];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)rowHeight {
    return 60;
}

- (NSArray<Class> *)cellClasses {
    return @[[YXStockListCell class]];
}

- (NSArray *)sortTypes {
    return @[@(YXMobileBrief1TypeNow), @(YXMobileBrief1TypeRoc), @(YXMobileBrief1TypeChange), @(YXMobileBrief1TypeTurnoverRate), @(YXMobileBrief1TypeVolume), @(YXMobileBrief1TypeAmount), @(YXMobileBrief1TypeAmp), @(YXMobileBrief1TypeVolumeRatio), @(YXMobileBrief1TypeMarketValue), @(YXMobileBrief1TypePe), @(YXMobileBrief1TypePb)];
}

- (CGFloat)tableViewTop {
    if (self.viewModel.isLandscape) {
        return 0;
    } else {
        return [super tableViewTop];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
