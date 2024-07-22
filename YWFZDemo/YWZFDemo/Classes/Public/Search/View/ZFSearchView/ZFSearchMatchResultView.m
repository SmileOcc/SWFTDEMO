


//
//  ZFSearchMatchResultView.m
//  ZZZZZ
//
//  Created by YW on 2017/12/13.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchMatchResultView.h"
#import "ZFInitViewProtocol.h"
#import "ZFSearchResultMatchTableViewCell.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "Masonry.h"
#import "Constants.h"
#import "YWCFunctionTool.h"

static NSString *const kZFSearchResultMatchTableViewCellIdentifier = @"kZFSearchResultMatchTableViewCellIdentifier";

@interface ZFSearchMatchResultView() <ZFInitViewProtocol, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView           *tableView;
@property (nonatomic, strong) UIView                *maskView;
/// 关联结果词与历史搜索重复的词
@property (nonatomic, strong) NSMutableArray        *repeatArray;

@end

@implementation ZFSearchMatchResultView
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
    return self.matchResult.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFSearchResultMatchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFSearchResultMatchTableViewCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *keyword = ZFToString(self.matchResult[indexPath.row]);
    cell.matchKey = self.matchResult[indexPath.row];
    cell.searchKey = self.searchKey;
    cell.historySearchImageView.hidden = ![self.repeatArray containsObject:keyword.lowercaseString];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.searchMatchResultSelectCompletionHandler) {
        self.searchMatchResultSelectCompletionHandler(self.matchResult[indexPath.row]);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.searchMatchCloseKeyboardCompletionHandler) {
        self.searchMatchCloseKeyboardCompletionHandler();
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.maskView];
    [self addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - setter
- (void)setSearchKey:(NSString *)searchKey {
    _searchKey = searchKey;
}

- (void)setMatchResult:(NSArray *)matchResult {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:matchResult];
    [self.repeatArray removeAllObjects];
    //  找出历史搜索与关联词相同的词，并放到关联词的前面
    for (int i = (int)self.historyArray.count - 1; i >= 0; i --) {
        NSString *keyword = ZFToString(self.historyArray[i]);
        if ([tempArray containsObject:keyword.lowercaseString]) {
            [tempArray removeObject:keyword.lowercaseString];
            [tempArray insertObject:keyword.lowercaseString atIndex:0];
            [self.repeatArray addObject:keyword.lowercaseString];
        }
    }
    
    _matchResult = tempArray;
    if (_matchResult.count > 0) {
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - getter
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        @weakify(self);
        [_maskView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.searchMatchHideMatchViewCompletionHandler) {
                self.searchMatchHideMatchViewCompletionHandler();
            }
        }];
    }
    return _maskView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = ZFCOLOR_WHITE;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.hidden = YES;
        [_tableView registerClass:[ZFSearchResultMatchTableViewCell class] forCellReuseIdentifier:kZFSearchResultMatchTableViewCellIdentifier];
    }
    return _tableView;
}

- (NSMutableArray *)repeatArray {
    if (!_repeatArray) {
        _repeatArray = [NSMutableArray array];
    }
    return _repeatArray;
}

@end
