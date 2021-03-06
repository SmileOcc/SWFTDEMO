//
//  ZJJTimeCountDownCellManager.m
//  ZJJCountDown
//
//  Created by xiaozhu on 2017/7/14.
//  Copyright © 2017年 xiaozhu. All rights reserved.
//

#import "ZJJTimeCountDownCellManager.h"
#import "ZJJTimeCountDownLabel.h"

@interface ZJJTimeCountDownCellManager()

@end

@implementation ZJJTimeCountDownCellManager{

    dispatch_source_t _timer;
    UIScrollView         *_countDownScrollView ;
    NSMutableArray                *_dataList;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView dataList:(NSMutableArray *)dataList{
    
    self = [super init];
    if (self) {
         _dataList = dataList;
         [self initWithScrollView:scrollView];
    }
    return self;
}

- (void)initWithScrollView:(UIScrollView *)scrollView {

    [self isTableViewOrCollectionView:scrollView];
    _countDownScrollView  = scrollView;
    [self countDownWithScrollView:_countDownScrollView];
}

- (BOOL)isTableViewOrCollectionView:(UIScrollView *)scrollView{
    
    if ([scrollView isKindOfClass:[UITableView class]] || [scrollView isKindOfClass:[UICollectionView class]]) {
        return YES;
    }
    
    NSAssert(NO, @"你所传入的scrollView，必须是UITableView或者UICollect§	ionView类型");
    return NO;
}

- (void)countDownWithScrollView:(UIScrollView*)scrollView {
    
    if (_timer==nil) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(_timer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self setupScrollViewTimeLabelText];
            });
        });
        dispatch_resume(_timer); // 启动定时器
    }
}

- (void)setupScrollViewTimeLabelText{
    
    if ([self countDownTableView]) {
        
        //设置tableView区头和区尾倒计时
        [self setupTabelViewHeaderOrFooterTimeLabel];
        //设置tableViewCell上倒计时
        [self setupTabelViewCellTimeLabel];
        
       
    }
    if ([self countDownCollectionView]) {
        
         //设置CollectionCell上倒计时
        [self setupCollectionCellTimeLabel];
      
    }
    
}


/**
 设置tableViewCell上倒计时
 */
- (void)setupTabelViewCellTimeLabel{

    if (_dataList.count) {
        
        NSArray  *cells = [self countDownTableView].visibleCells; //取出屏幕可见UITableViewCell
        for (UITableViewCell * cell in cells) {
            [self setupCellTimeLabelWithContentView:cell.contentView];
        }
    }
}

/**
 设置tableView区头和区尾倒计时
 */
- (void)setupTabelViewHeaderOrFooterTimeLabel{

    NSInteger headerCount = self.headerSectionDic.allKeys.count;
    NSInteger footerCount = self.footerSectionDic.allKeys.count;
    if (headerCount || footerCount) {
        //获取可见的组
        NSArray *indexPaths = [self countDownTableView].indexPathsForVisibleRows;
        NSMutableDictionary *iPD = [NSMutableDictionary dictionary];
        
        for (NSIndexPath *indexPath in indexPaths) {
            [iPD setObject:@(indexPath.section) forKey:@(indexPath.section)];
        }
        NSArray *keys = [iPD allKeys];
        for (NSNumber *section in keys) {
            if (headerCount) {
                UIView *headerView = self.headerSectionDic[section];
                if (headerView) {
                    [self setupTabelTimeLabelWithView:headerView];
                }
            }
            if (footerCount) {
                UIView *footerView = self.footerSectionDic[section];
                if (footerView) {
                    [self setupTabelTimeLabelWithView:footerView];
                }
            }

        }
    }
    

}

- (UIView *)cellHeaderSectionViewWithIndexPath:(NSIndexPath *)indexPath{
    
    return self.headerSectionDic[@(indexPath.row)];
}

- (void)setupCollectionCellTimeLabel{

    if (_dataList.count) {
        
        NSArray  *cells = [self countDownCollectionView].visibleCells; //取出屏幕可见UICollectionViewCell
        for (UICollectionViewCell * cell in cells) {
            [self setupCellTimeLabelWithContentView:cell.contentView];
        }
    }
}

- (void)setupTabelTimeLabelWithView:(UIView *)view{

    
    if ([view isKindOfClass:[ZJJTimeCountDownLabel class]]) {
        
        ZJJTimeCountDownLabel *timeLabel = (ZJJTimeCountDownLabel *)view;
        if (timeLabel.model) {
           [self setupAttributedText:timeLabel model:timeLabel.model];
        }
        
        NSLog(@"====++++++=timeLabel.text===%@====",timeLabel.text);
    }
    
    for (UIView * contentSubView in view.subviews) {
        if ([contentSubView isKindOfClass:[ZJJTimeCountDownLabel class]]) {
            ZJJTimeCountDownLabel *timeLabel = (ZJJTimeCountDownLabel *)contentSubView;
            if (timeLabel.model) {
                [self setupAttributedText:timeLabel model:timeLabel.model];
            }
        }
    }
}

- (void)setupCellTimeLabelWithContentView:(UIView *)contentView{
    if (self.labelInContentView) {
        for (UIView *contentSubView in contentView.subviews) {
            if ([contentSubView isKindOfClass:[ZJJTimeCountDownLabel class]]) {
                ZJJTimeCountDownLabel *timeLabel = (ZJJTimeCountDownLabel *)contentSubView;
                id model = nil;
                if (!_dataList.count) {
                    return;
                }
                if ([_dataList[0] isKindOfClass:[NSArray class]]) {
                    
                    if (_dataList.count > timeLabel.indexPath.section) {
                        
                        NSArray *sectionList =_dataList[timeLabel.indexPath.section];
                        if (sectionList.count > timeLabel.indexPath.row) {
                            model = _dataList[timeLabel.indexPath.section][timeLabel.indexPath.row];
                        }else{
                            return;
                        }
                        
                    }else{
                        return;
                    }
                }else {
                    if (_dataList.count > timeLabel.indexPath.row) {
                        model = _dataList[timeLabel.indexPath.row];
                    }else{
                        
                        return;
                    }
                }
                
                if ([self isAutomaticallyDeletedWithModel:model timeLabel:timeLabel]) {
                    
                    if ([self.delegate respondsToSelector:@selector(cellAutomaticallyDeleteWithModel:)]) {
                        [self.delegate cellAutomaticallyDeleteWithModel:model];
                    }
                    [self deleteReloadDataWithModel:model indexPath:timeLabel.indexPath];
                    [self setupScrollViewTimeLabelText];
                    
                }else{
                    [self setupAttributedText:timeLabel model:model];
                }
            }
        }
    }else{
        for (UIView *contentSubView in contentView.subviews) {
            //如果contentView没有找到就从 contentView的subviews里的subviews里面寻找
            for (UIView *subview in contentSubView.subviews) {
                if (![subview isKindOfClass:[ZJJTimeCountDownLabel class]]) continue;
                ZJJTimeCountDownLabel *timeLabel = (ZJJTimeCountDownLabel *)subview;
                id model = nil;
                if (!_dataList.count) {
                    return;
                }
                if ([_dataList[0] isKindOfClass:[NSArray class]]) {
                    
                    if (_dataList.count > timeLabel.indexPath.section) {
                        
                        NSArray *sectionList =_dataList[timeLabel.indexPath.section];
                        if (sectionList.count > timeLabel.indexPath.row) {
                            model = _dataList[timeLabel.indexPath.section][timeLabel.indexPath.row];
                        }else{
                            return;
                        }
                        
                    }else{
                        return;
                    }
                }else {
                    if (_dataList.count > timeLabel.indexPath.row) {
                        model = _dataList[timeLabel.indexPath.row];
                    }else{
                        
                        return;
                    }
                }
                
                if ([self isAutomaticallyDeletedWithModel:model timeLabel:timeLabel]) {
                    
                    if ([self.delegate respondsToSelector:@selector(cellAutomaticallyDeleteWithModel:)]) {
                        [self.delegate cellAutomaticallyDeleteWithModel:model];
                    }
                    [self deleteReloadDataWithModel:model indexPath:timeLabel.indexPath];
                    [self setupScrollViewTimeLabelText];
                    
                }else{
                    [self setupAttributedText:timeLabel model:model];
                }
            }
        }
    }
}

- (void)setupAttributedText:(ZJJTimeCountDownLabel *)timeLabel model:(id)model{

    NSAttributedString *timeStr = [self.delegate cellTimeStringWithModel:model timeLabel:timeLabel];
    timeLabel.attributedText = timeStr ;
}

- (void)deleteReloadDataWithModel:(id)model indexPath:(NSIndexPath *)indexPath{
    
    //说明数据分组
    if ([_dataList[0] isKindOfClass:[NSArray class]]) {
        
        NSArray *deleteSection = _dataList[indexPath.section];
        NSMutableArray *arr = [NSMutableArray arrayWithArray:deleteSection];
        if ([arr containsObject:model]) {
            [arr removeObject:model];
            if (arr.count == 0) {
                [_dataList removeObject:deleteSection];
                [self.headerSectionDic removeAllObjects];
                [self.footerSectionDic removeAllObjects];
            }else{
                
                [_dataList replaceObjectAtIndex:indexPath.section withObject:arr];
            }
        }
        
    }else{
        
        [_dataList removeObject:model];
    }
    [self countDownReloadData];
}

//是否是自动删除已过时的时间数据
- (BOOL)isAutomaticallyDeletedWithModel:(id)model timeLabel:(ZJJTimeCountDownLabel *)timeLabel{
    
    NSAttributedString *descript = [self.delegate cellTimeStringWithModel:model timeLabel:timeLabel];
    
    if (timeLabel.isAutomaticallyDeleted && [descript.string isEqualToString:timeLabel.jj_description] && [self countDownTableView]) {
        return YES;
    }
    return NO;
}

/**
 刷新表格
 */
- (void)countDownReloadData{
    
    if ([self countDownTableView]) {
        [[self countDownTableView] reloadData];
    }
    if ([self countDownCollectionView]) {
        [[self countDownCollectionView] reloadData];
    }
}

- (UITableView *)countDownTableView{
    
    if ([_countDownScrollView isKindOfClass:[UITableView class]]) {
        
        UITableView *tabelView = (UITableView *)_countDownScrollView;
        return tabelView;
    }
    return nil;
}

- (UICollectionView *)countDownCollectionView{
    
    if ([_countDownScrollView isKindOfClass:[UICollectionView class]]){
        
        UICollectionView *collectionView = (UICollectionView *)_countDownScrollView;
        return collectionView;
    }
    return nil;
}

- (NSMutableDictionary *)headerSectionDic{
    if (!_headerSectionDic) {
        _headerSectionDic = [NSMutableDictionary dictionary];
    }
    return _headerSectionDic;
}

- (NSMutableDictionary *)footerSectionDic{
    if (!_footerSectionDic) {
        _footerSectionDic = [NSMutableDictionary dictionary];
    }
    return _footerSectionDic;
}

/**
 销毁定时器
 */
- (void)destoryScrollViewTimer{
    
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

@end
