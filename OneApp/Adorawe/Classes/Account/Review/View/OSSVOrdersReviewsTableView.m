//
//  OSSVOrdersReviewsTableView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVOrdersReviewsTableView.h"

@implementation OSSVOrdersReviewsTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style])
    {
        self.backgroundColor = OSSVThemesColors.col_F8F8F8;
        self.separatorStyle = NO;
        [self setShowsVerticalScrollIndicator:NO];
        self.estimatedRowHeight = UITableViewAutomaticDimension;
        self.estimatedSectionHeaderHeight = UITableViewAutomaticDimension;
        self.estimatedSectionFooterHeight = UITableViewAutomaticDimension;
        [self registerClass:[OSSVReviewssGoodssCell class] forCellReuseIdentifier:NSStringFromClass(OSSVReviewssGoodssCell.class)];
        self.dataSource = self;
        self.delegate = self;
        
        self.tableHeaderView = self.scoreView;
    }
    return self;
}

- (void)reviewSuccess {
    [self.scoreView hideCommitButton];
    self.tableHeaderView = self.scoreView;
}

- (void)setReviewModel:(OSSVOrdereRevieweModel *)reviewModel {
    _reviewModel = reviewModel;
    

    if (_reviewModel.isReview == 1) {
        [self.scoreView handleRating:[_reviewModel.reviewScore.transportRate floatValue]
                               goods:[_reviewModel.reviewScore.goodsRate floatValue]
                                 pay:[_reviewModel.reviewScore.payRate floatValue]
                             service:[_reviewModel.reviewScore.serviceRate floatValue]];
        [self.scoreView hideCommitButton];
    }
    
    [self.goodsDatas removeAllObjects];
    [self.goodsDatas addObjectsFromArray:_reviewModel.goods];
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
    return  107;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSSVReviewssGoodssCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVReviewssGoodssCell.class)];
    cell.myDelegate = self;
    
    if (self.goodsDatas.count > indexPath.row) {
        OSSVAccounteOrdersDetaileGoodsModel *goodsModel = self.goodsDatas[indexPath.row];
        cell.model = goodsModel;
    }

    return cell;
}

#pragma mark - STLReviewsGoodsCellDelegate

- (void)STL_ReviewsGoodsCell:(OSSVReviewssGoodssCell *)reviewsCell flag:(BOOL)flag {
    NSIndexPath *index = [self indexPathForCell:reviewsCell];
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(STL_OrderReviewTableView:indexPath:)]) {
        [self.myDelegate STL_OrderReviewTableView:self indexPath:index];
    }
}


#pragma mark - LazyLoad

- (OSSVOrdersReviewsScoreView *)scoreView {
    if (!_scoreView) {
        _scoreView = [[OSSVOrdersReviewsScoreView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120)];
        _scoreView.orderId = self.orderId;
        @weakify(self)
        _scoreView.reviewBlock = ^{
            @strongify(self)
            
            CGFloat transport = self.scoreView.transportView.rateCount;
            CGFloat goods = self.scoreView.goodsView.rateCount;
            CGFloat pay = self.scoreView.payView.rateCount;
            CGFloat service = self.scoreView.serviceView.rateCount;
            
            if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(STL_OrderReviewTableView:transoprt:goods:pay:service:)]) {
                [self.myDelegate STL_OrderReviewTableView:self transoprt:transport goods:goods pay:pay service:service];
            }
        };
    }
    return _scoreView;
}




@end
