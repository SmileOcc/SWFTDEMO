//
//  OSSVCurrencyVC.m
// XStarlinkProject
//
//  Created by odd on 2020/8/4.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCurrencyVC.h"
#import "STLCurrencyCell.h"
#import "ExchangeManager.h"
#import "RateModel.h"
#import "CacheFileManager.h"
#import "OSSVLanguageSettingVC.h"

#import "Adorawe-Swift.h"
@interface OSSVCurrencyVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView     *currencyTable;

@property (nonatomic, strong) NSArray         *currencyArray;

@property (nonatomic, assign) NSInteger       sourceIndex;
@property (nonatomic, assign) NSInteger       selectedIndex;
@property (nonatomic, strong) UIButton        *saveButton;

@end

@implementation OSSVCurrencyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = STLLocalizedString_(@"Currency", nil);
    
    self.sourceIndex = -1;
    self.selectedIndex = -1;
    [self currentSelect];
    
    [self stlInitView];
    [self stlAutoLayoutView];
    
}


- (void)currentSelect {
    RateModel *curRateModel = [ExchangeManager localCurrency];
    
    [self.currencyArray enumerateObjectsUsingBlock:^(RateModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.code isEqualToString:curRateModel.code]) {
            self.selectedIndex = idx;
            self.sourceIndex = idx;
            *stop = YES;
        }
    }];
}
- (void)stlInitView {
    [self.view addSubview:self.currencyTable];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.saveButton];
    self.saveButton.enabled = NO;
}

- (void)stlAutoLayoutView {
    
    [self.currencyTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 12, kIPHONEX_BOTTOM, 12));
    }];
}

- (void)saveButtonAction {
    
    if (self.currencyArray.count > self.selectedIndex) {
                
        RateModel *rateModel = self.currencyArray[self.selectedIndex];
        [ExchangeManager updateLocalCurrencyWithRteModel:rateModel];
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setBool:YES forKey:kIsSettingCurrentKey];
        [user synchronize];
//        /**
//         *  发送改变货币类型通知
//         */
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Currency object:nil];
//
//        [self.navigationController popViewControllerAnimated:YES];
        
        [OSSVLanguageSettingVC initAppTabBarVCFromChangeLanguge:STLMainMoudleAccount completion:^(BOOL success) {
            
        }];
        
    }
}


#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currencyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STLCurrencyCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(STLCurrencyCell.class) forIndexPath:indexPath];
    
    if (self.currencyArray.count > indexPath.row) {
        
        RateModel *model = self.currencyArray[indexPath.row];
        NSString *needString = [NSString stringWithFormat:@"%@ %@",model.code,model.symbol];
        if ([SystemConfigUtils isRightToLeftShow]) {
            needString = [NSString stringWithFormat:@"%@ %@",model.symbol,model.code];
        }
        cell.contentLabel.text = needString;
        cell.accesoryImageView.hidden = (indexPath.row == self.selectedIndex) ? NO : YES;
        [cell showLinew:indexPath.row == self.currencyArray.count - 1];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView roundedGroupWithWillDisplay:cell forRowAt:indexPath radius:6 backgroundColor:STLThemeColor.stlWhiteColor horizontolPadding:0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != self.selectedIndex) {
        self.selectedIndex = indexPath.row;
        [tableView reloadData];
    }

    self.saveButton.enabled = self.sourceIndex != self.selectedIndex;
}

#pragma mark - setting

- (NSArray *)currencyArray {
    if (!_currencyArray) {
        _currencyArray = [self getTheExchangeCurrencyList];
    }
    return _currencyArray;
}

#pragma mark 获取不同汇率
- (NSArray *)getTheExchangeCurrencyList {
    NSArray *array = [ExchangeManager currencyList];
    return array.copy;
}

- (UITableView *)currencyTable {
    if (!_currencyTable) {
        _currencyTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _currencyTable.delegate = self;
        _currencyTable.dataSource = self;
        _currencyTable.backgroundColor = STLThemeColor.stlClearColor;
        _currencyTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 12)];
        headerView.backgroundColor = STLThemeColor.stlClearColor;
        _currencyTable.tableHeaderView = headerView;
        [_currencyTable registerClass:[STLCurrencyCell class] forCellReuseIdentifier:NSStringFromClass(STLCurrencyCell.class)];
        
    }
    return _currencyTable;
}

- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _saveButton.backgroundColor = [UIColor clearColor];
        _saveButton.enabled = NO;
        _saveButton.titleLabel.font = FontWithSize(16);
        [_saveButton setTitleColor:STLThemeColor.col_333333 forState:UIControlStateNormal];
        [_saveButton setTitleColor:STLThemeColor.col_DDDDDD forState:UIControlStateDisabled];
        [_saveButton addTarget:self action:@selector(saveButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *title = STLLocalizedString_(@"english_save", nil);
        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:_saveButton.titleLabel.font.fontName size:_saveButton.titleLabel.font.pointSize]}];
        _saveButton.frame = CGRectMake(0.0, 0.0, titleSize.width, self.navigationController.navigationBar.height);
        [_saveButton setTitle:title forState:UIControlStateNormal];
    }
    return _saveButton;
}

@end
