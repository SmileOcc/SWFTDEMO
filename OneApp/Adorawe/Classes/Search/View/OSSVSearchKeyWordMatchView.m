//
//  OSSVSearchKeyWordMatchView.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVSearchKeyWordMatchView.h"
#import "OSSVSearchKeyWordMatchTCell.h"

@interface OSSVSearchKeyWordMatchView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTable;

@end

@implementation OSSVSearchKeyWordMatchView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = STLRandomColor();
        [self stlInitView];
    }
    return self;
}

- (void)stlInitView{
    [self addSubview:self.mainTable];
    [self.mainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)setKeywords:(NSArray *)keywords{
    _keywords = keywords;
    [self.mainTable reloadData];
}

// datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.keywords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    @weakify(self);
    OSSVSearchKeyWordMatchTCell *cell = [tableView  dequeueReusableCellWithIdentifier:NSStringFromClass([OSSVSearchKeyWordMatchTCell class])];
    cell.key = self.searchKey;
    cell.keyWord = [NSString stringWithFormat:@"%@",self.keywords[indexPath.row]];
    cell.SearchMatchRightblock = ^(NSString * _Nonnull keyWord) {
        @strongify(self);
        if (self.copyHandler) {
            self.copyHandler(keyWord);
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    @weakify(self);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *keyWord = self.keywords[indexPath.row];
    if (self.keyWordHandler) {
        @strongify(self);
        // 开始搜索
        self.keyWordHandler(keyWord);
    }
}

// lazy

- (UITableView *)mainTable{
    if (!_mainTable) {
        _mainTable = [[UITableView alloc] init];
        _mainTable.delegate = self;
        _mainTable.dataSource = self;
        _mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTable.rowHeight = 48;
        [_mainTable registerClass:[OSSVSearchKeyWordMatchTCell class] forCellReuseIdentifier:NSStringFromClass([OSSVSearchKeyWordMatchTCell class])];
    }
    return _mainTable;
}



@end
