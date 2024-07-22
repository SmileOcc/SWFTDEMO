//
//  CartInfoGoodsViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/4/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CartInfoGoodsViewController.h"
#import "CartInfoGoodsListCell.h"
#import "CheckOutGoodListModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "ZFColorDefiner.h"
#import "ZFThemeManager.h"

static NSString *const kCartInfoGoodsListCellIdentifier = @"kCartInfoGoodsListCellIdentifier";

@interface CartInfoGoodsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation CartInfoGoodsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"CartInfo_Goods_VC_Title", nil);
    self.view.backgroundColor = ZFC0xF2F2F2();
    [self initViews];
}

- (void)initViews {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.leading.trailing.mas_equalTo(self.view);
    }];
}

#pragma mark - Lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = ZFC0xF2F2F2();
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[CartInfoGoodsListCell class] forCellReuseIdentifier:kCartInfoGoodsListCellIdentifier];
    }
    return _tableView;
}

#pragma mark - UITableView DataSource and Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.goodsList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CartInfoGoodsListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCartInfoGoodsListCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CheckOutGoodListModel *goodsModel = self.goodsList[indexPath.row];
    cell.goodsModel = goodsModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CheckOutGoodListModel *goodsModel = self.goodsList[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:kCartInfoGoodsListCellIdentifier configuration:^(CartInfoGoodsListCell *cell) {
        cell.goodsModel = goodsModel;
    }];
}

@end
