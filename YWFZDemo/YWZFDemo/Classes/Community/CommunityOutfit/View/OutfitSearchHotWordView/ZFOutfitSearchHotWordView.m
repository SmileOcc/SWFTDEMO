//
//  ZFOutfitSearchHotWordView.m
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOutfitSearchHotWordView.h"
#import "ZFOutfitSearchHotWordManager.h"
#import "ZFDetailStyleValueTableViewCell.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"

@interface ZFOutfitSearchHotWordView ()
<
    UITableViewDelegate,
    UITableViewDataSource
>
@property (nonatomic, strong) UITableView *hotwordTableView;
@property (nonatomic, strong) NSMutableArray *hotwordDataList;
@property (nonatomic, assign) BOOL isShow;
@end

@implementation ZFOutfitSearchHotWordView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 5;
    self.hotwordTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.hotwordTableView.delegate = self;
    self.hotwordTableView.dataSource = self;
    self.hotwordTableView.tableFooterView = [UIView new];
    self.hotwordTableView.backgroundColor = ZFC0xF2F2F2();
    self.hotwordTableView.contentInset = UIEdgeInsetsMake(5, 0, 10, 0);
    self.hotwordTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.hotwordTableView];
    
    self.isShow = NO;
}

 
- (void)showHotWordView:(UIView *)superView offsetY:(CGFloat)offsetY contentOffsetY:(CGFloat)contentOffsetY
{
    if (!superView) {
        superView = WINDOW;
    }
    if (!self.superview) {
        [superView addSubview:self];
    }
    
    CGFloat animationOffset = 80;
    CGFloat padding = 0;
    CGFloat height = superView.frame.size.height - offsetY - contentOffsetY;
    self.alpha = 0.5;
    self.frame = CGRectMake(padding, offsetY + animationOffset, KScreenWidth - padding * 2, height);
    self.hotwordTableView.frame = self.bounds;
    
    self.isShow = YES;
    [UIView animateWithDuration:.3 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGFloat oldY = self.frame.origin.y;
        CGFloat newY = oldY - animationOffset;
        self.frame = CGRectMake(self.frame.origin.x, newY, self.frame.size.width, self.frame.size.height);
        self.alpha = 1.0;
    } completion:^(BOOL finished) {}];
}

- (void)hiddenHotWordView
{
    if (!self.isShow) {
        return;
    }
    self.isShow = NO;
    CGFloat animationOffset = 80;
    [UIView animateWithDuration:.3 animations:^{
        CGFloat oldY = self.frame.origin.y;
        CGFloat newY = oldY + animationOffset;
        self.frame = CGRectMake(self.frame.origin.x, newY, self.frame.size.width, self.frame.size.height);
        self.alpha = 0.5;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)reloadHotWord:(NSArray *)wordList key:(NSString *)key
{
    NSMutableArray *stringChar = [[NSMutableArray alloc] init];
    for (int i = 0; i < key.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *sChar = [key substringWithRange:range];
        [stringChar addObject:sChar];
    }
    if ([wordList count] > 20) {
        wordList = [wordList subarrayWithRange:NSMakeRange(0, 20)];
    }
    
    wordList = [ZFOutfitSearchHotWordManager handlerHotWordHighLightKey:wordList wordKey:key];
    
    [self.hotwordDataList removeAllObjects];
    [self.hotwordDataList addObjectsFromArray:wordList];
    [self.hotwordTableView reloadData];
}

#pragma mark - tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = [self.hotwordDataList count];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFDetailStyleValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"iCell"];
    if (!cell) {
        cell = [[ZFDetailStyleValueTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"iCell"];
    }
    cell.backgroundColor = ZFC0xF2F2F2();
    HotWordModel *model = self.hotwordDataList[indexPath.row];
    if (model.keyWordAttributeString) {
        cell.titleAttribute = model.keyWordAttributeString;
    } else {
        cell.title = model.label;
    }
    NSString *posts = ZFLocalizedString(@"Community_Posts", nil);
    NSString *addString = @"";
    NSInteger count = model.count;
    if (model.count > 1000) {
        addString = @"+";
        count = 1000;
    }
    cell.detailTitle = [NSString stringWithFormat:@"%ld %@%@",count,addString,posts];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOutfitSearchHotWordViewDidClickHotWord:)]) {
        HotWordModel *model = self.hotwordDataList[indexPath.row];
        [self.delegate ZFOutfitSearchHotWordViewDidClickHotWord:model.label];
    }
}

#pragma mark - Property Method

- (NSMutableArray *)hotwordDataList
{
    if (!_hotwordDataList) {
        _hotwordDataList = [[NSMutableArray alloc] init];
    }
    return _hotwordDataList;
}

@end
