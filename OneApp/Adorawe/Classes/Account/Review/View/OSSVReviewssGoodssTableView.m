//
//  OSSVReviewssGoodssTableView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVReviewssGoodssTableView.h"

@implementation OSSVReviewssGoodssTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style])
    {
        self.backgroundColor = OSSVThemesColors.col_F5F5F5;
        self.separatorStyle = NO;
        [self setShowsVerticalScrollIndicator:NO];
        self.estimatedRowHeight = UITableViewAutomaticDimension;
        self.estimatedSectionHeaderHeight = UITableViewAutomaticDimension;
        self.estimatedSectionFooterHeight = UITableViewAutomaticDimension;
        [self registerClass:[OSSVReviewssGoodssCell class] forCellReuseIdentifier:NSStringFromClass(OSSVReviewssGoodssCell.class)];
        self.dataSource = self;
        self.delegate = self;
        self.contentInset = UIEdgeInsetsMake(4, 0, kIPHONEX_BOTTOM, 0);
    }
    return self;
}


- (void)emptyOperationTouch {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(STL_ReviewsGoodsTableView:refresh:)]) {
        [self.myDelegate STL_ReviewsGoodsTableView:self refresh:YES];
    }
}

- (NSMutableArray *)goodsDatas {
    if (!_goodsDatas) {
        _goodsDatas = [[NSMutableArray alloc] init];
    }
    return _goodsDatas;
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.goodsDatas.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80 + 28 + 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVReviewssGoodssCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVReviewssGoodssCell.class)];
    cell.myDelegate = self;

    if (self.goodsDatas.count > indexPath.row) {
        cell.model = self.goodsDatas[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(STL_ReviewsGoodsTableView:selectIndexPath:)]) {
        [self.myDelegate STL_ReviewsGoodsTableView:self selectIndexPath:indexPath];
    }
}

#pragma mark - STLReviewsGoodsCellDelegate

- (void)STL_ReviewsGoodsCell:(OSSVReviewssGoodssCell *)reviewsCell flag:(BOOL)flag {
    
    NSIndexPath *index = [self indexPathForCell:reviewsCell];
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(STL_ReviewsGoodsTableView:indexPath:)]) {
        [self.myDelegate STL_ReviewsGoodsTableView:self indexPath:index];
    }
}

@end
