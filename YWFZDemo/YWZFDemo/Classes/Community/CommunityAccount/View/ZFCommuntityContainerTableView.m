//
//  ZFCommuntityContainerTableView.m
//  ZZZZZ
//
//  Created by YW on 2018/4/24.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommuntityContainerTableView.h"
#import "ZFFrameDefiner.h"

@interface ZFCommuntityContainerTableView()
@property (nonatomic, weak) id containerDelagate;
@property (nonatomic, strong) UIView                        *sectionHeaderView;
@property (nonatomic, strong) UICollectionViewFlowLayout    *flowLayout;
@end

@implementation ZFCommuntityContainerTableView

- (instancetype)initWithFrame:(CGRect)frame
                        style:(UITableViewStyle)style
            containerDelagate:(id)containerDelagate
            sectionHeaderView:(UIView *)sectionHeaderView
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.containerDelagate = containerDelagate;
        self.sectionHeaderView = sectionHeaderView;
    }
    return self;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.sectionInset = UIEdgeInsetsZero;
        _flowLayout.minimumLineSpacing = 0;
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat height = self.frame.size.height;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, height) collectionViewLayout:self.flowLayout];
        _collectionView.bounces = NO;
        _collectionView.delegate = self.containerDelagate;
        _collectionView.dataSource = self.containerDelagate;
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        
        [_collectionView registerClass:NSClassFromString(@"ZFCommunityAccountShowView") forCellWithReuseIdentifier:kZFCommunityAccountShowViewIdentifier];
        [_collectionView registerClass:NSClassFromString(@"ZFCommunityAccountFavesView") forCellWithReuseIdentifier:kZFCommunityAccountFavesViewIdentifier];
        
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ContainerTableViewCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.collectionView];
    }
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY >= 180) {
        //YWLog(@"ContainerTableView表格滚动===%.2f",offsetY);
    }
    
    if (offsetY <= 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
    }
}

@end
