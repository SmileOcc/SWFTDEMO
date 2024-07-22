//
//  ZFAddressCountryCitySearchView.m
//  ZZZZZ
//
//  Created by YW on 2019/1/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressCountryCitySearchView.h"

#import "ZFInitViewProtocol.h"
//#import "ZFAddressCityModel.h"
//#import "ZFAddressCountryModel.h"
//#import "ZFAddressStateModel.h"
//#import "ZFAddressTownModel.h"
#import "ZFAddressLibraryCountryModel.h"
#import "ZFAddressLibraryStateModel.h"
#import "ZFAddressLibraryCityModel.h"
#import "ZFAddressLibraryTownModel.h"

#import "ZFThemeManager.h"
#import <Masonry/Masonry.h>

@interface ZFAddressCountryCitySearchView () <ZFInitViewProtocol, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView           *tableView;
@end

@implementation ZFAddressCountryCitySearchView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressCityCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *name = @"";
    if (self.dataArray.count > indexPath.row) {
        
        if ([self.dataArray[indexPath.row] isKindOfClass:[ZFAddressLibraryCountryModel class]]){
            name = [(ZFAddressLibraryCountryModel *)self.dataArray[indexPath.row] n];
            
        }  else if ([self.dataArray[indexPath.row] isKindOfClass:[ZFAddressLibraryStateModel class]]){
            name = [(ZFAddressLibraryStateModel *)self.dataArray[indexPath.row] n];
            
        } else if ([self.dataArray[indexPath.row] isKindOfClass:[ZFAddressLibraryCityModel class]]){
            name = [(ZFAddressLibraryCityModel *)self.dataArray[indexPath.row] n];
        } else if ([self.dataArray[indexPath.row] isKindOfClass:[ZFAddressLibraryTownModel class]]) {
            name = [(ZFAddressLibraryTownModel *)self.dataArray[indexPath.row] n];
        }

        NSRange range = [name rangeOfString:self.searchKey options:NSCaseInsensitiveSearch];
        if (range.location != NSNotFound) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:name];
            [attr beginEditing];
            [attr addAttribute:NSForegroundColorAttributeName value:ZFC0xFE5269() range:range];
            [attr endEditing];
            cell.textLabel.attributedText = attr;
        } else {
            cell.textLabel.text = name;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.addressCountryCitySearchBlock) {
        self.addressCountryCitySearchBlock(self.dataArray[indexPath.row]);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.addressCountryCitySearchScrollBlcok) {
        self.addressCountryCitySearchScrollBlcok();
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
- (void)setDataArray:(NSMutableArray<ZFAddressBaseModel *> *)dataArray {
    _dataArray = dataArray;
    [self.tableView reloadData];
    //FIXME: occ Bug 1101
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
//    });
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
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"addressCityCell"];
    }
    return _tableView;
}

@end
