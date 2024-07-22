
//
//  ZFAddressSearchResultView.m
//  ZZZZZ
//
//  Created by YW on 2017/9/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressCountrySearchResultView.h"
#import "ZFInitViewProtocol.h"
#import "ZFAddressCountryModel.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "UIImage+ZFExtended.h"

@interface ZFAddressCountrySearchResultView () <ZFInitViewProtocol, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView           *tableView;
@property (nonatomic, strong) NSIndexPath           *seletedIndexPath;
@end

@implementation ZFAddressCountrySearchResultView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)cancelSelect {
    self.seletedIndexPath = nil;
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressCountryCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ZFAddressCountryModel *model = self.dataArray[indexPath.row];
    cell.textLabel.text = model.region_name;
    cell.accessoryView = nil;
    if ([self.seletedIndexPath isEqual:indexPath]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[ZFImageWithName(@"refine_select") imageWithColor:ZFC0xFE5269()]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.seletedIndexPath = indexPath;
    [tableView reloadData];
    
    if (self.addressCountryResultSelectCompletionHandler) {
        self.addressCountryResultSelectCompletionHandler(self.dataArray[indexPath.row]);
    }
}


#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
    [self addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - setter
- (void)setDataArray:(NSMutableArray *)dataArray {
    _dataArray = dataArray;
    self.seletedIndexPath = nil;
    [self.tableView reloadData];
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"addressCountryCell"];
    }
    return _tableView;
}
@end
