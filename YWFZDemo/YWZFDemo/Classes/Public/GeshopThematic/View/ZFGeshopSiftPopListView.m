//
//  ZFGeshopSiftPopListView.m
//  ZZZZZ
//
//  Created by YW on 2019/11/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGeshopSiftPopListView.h"
#import "CategoryNewModel.h"
#import "ZFGeshopSiftListHeaderView.h"
#import "ZFGEshopSiftListItemCell.h"
#import "CategorySectionViewCell.h"
#import "CategorySortSectionView.h"
#import "CategoryPriceListSectionView.h"
#import "CategorySubCell.h"
#import "CategoryPriceListModel.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "ZFGeshopSectionModel.h"

static CGFloat kSelectCellHeight = 44.0f;

@interface ZFGeshopSiftPopListView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView      *tmpWhiteView;//只是为了在切圆角时盖住顶部上面两个圆角
@property (nonatomic, strong) UIView      *maskBgView;
@property (nonatomic, strong) ZFGeshopSectionModel *sectionModel;
@property (nonatomic, assign) ZFCategoryColumnDataType dataType;
@property (nonatomic, strong) NSMutableArray *tempAddArray;
@end

@implementation ZFGeshopSiftPopListView

#pragma mark - Init Method
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.hidden = YES;
    }
    return self;
}

#pragma mark - Initialize
- (void)zfInitView {
    [self addSubview:self.maskBgView];
    [self addSubview:self.tmpWhiteView];
    [self addSubview:self.tableView];
}

- (void)zfAutoLayoutView{
    self.maskBgView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
    self.tmpWhiteView.frame = CGRectMake(0, 0, KScreenWidth, 10);
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, 0);
}

#pragma mark - Setter

- (void)setCategoryData:(ZFGeshopSectionModel *)sectionModel
               dataType:(ZFCategoryColumnDataType)dataType
{
    _sectionModel = sectionModel;
    self.dataType = dataType;
    [self.tableView reloadData];
}

- (ZFGeshopSiftItemModel *)siftModelWithIndexPath:(NSIndexPath *)indexPath {
    if (self.sectionSiftModelArray.count > indexPath.section) {
        ZFGeshopSiftItemModel *siftItemModel = self.sectionSiftModelArray[indexPath.section];
        if (siftItemModel.selectionAllChildItemArr.count > indexPath.item) {
            return siftItemModel.selectionAllChildItemArr[indexPath.row];
        }
    }
    return nil;
}

- (NSArray *)sectionSiftModelArray {
    NSArray *siftDataArray = @[];
    if (self.dataType == ZFCategoryColumn_CategoryType) {
        siftDataArray = self.sectionModel.component_data.category_list;
        
    } else if (self.dataType == ZFCategoryColumn_SortType) {
        siftDataArray = self.sectionModel.component_data.sort_list;
    }
    return siftDataArray;
}

#pragma mark - UITableViewDelegate - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionSiftModelArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ZFGeshopSiftItemModel *siftModel = self.sectionSiftModelArray[section];
    return siftModel.hasOpenChild ? siftModel.selectionAllChildItemArr.count : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    @weakify(self)
    ZFGeshopSiftListHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([ZFGeshopSiftListHeaderView class])];
    headerView.siftItemModel = self.sectionSiftModelArray[section];
    headerView.touchArrowImgBlock = ^(ZFGeshopSiftItemModel *sectionModel) {
        @strongify(self)
        if (self.dataType == ZFCategoryColumn_CategoryType) {
            [self selectHeaderViewModel:sectionModel section:section];
        }
    };
    headerView.selecteCurrentSiftBlock = ^(ZFGeshopSiftItemModel *headerModel) {
        @strongify(self)
        if (self.dataType == ZFCategoryColumn_SortType) {
            [self selectHeaderViewModel:headerModel section:section];
            
        } else if (self.dataType == ZFCategoryColumn_CategoryType) {
            
            [self unCheckoutHasSelected:self.sectionSiftModelArray];
            if (self.selectedCategoryBlock) {
                self.selectedCategoryBlock(headerModel);
            }
            [self showSelectView:NO];
        }
    };
    return headerView;
}

- (void)selectHeaderViewModel:(ZFGeshopSiftItemModel *)sectionModel section:(NSInteger)section {
    if (sectionModel.child_item.count > 0) {
        if (sectionModel.hasOpenChild) {
            sectionModel.hasOpenChild = NO;
            sectionModel.lastSelectionAllOpenChildItemArr = [NSArray arrayWithArray:sectionModel.selectionAllChildItemArr];
            [sectionModel.selectionAllChildItemArr removeObjectsInArray:sectionModel.child_item];
            
        } else {
            sectionModel.hasOpenChild = YES;
            NSArray *addArray = sectionModel.lastSelectionAllOpenChildItemArr;
            if (addArray.count == 0) {
                addArray = sectionModel.child_item;
                for (ZFGeshopSiftItemModel *tempModel in sectionModel.child_item) {
                    tempModel.childLevel = 1;
                }
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, addArray.count)];
                [sectionModel.selectionAllChildItemArr insertObjects:addArray atIndexes:indexSet];
            } else {
                [sectionModel.selectionAllChildItemArr removeAllObjects];
                [sectionModel.selectionAllChildItemArr addObjectsFromArray:addArray];
            }
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:(UITableViewRowAnimationNone)];
        [self showSelectView:YES];
    } else {
        [self setSelectdSiftModel:sectionModel selecteFalg:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFGEshopSiftListItemCell *itemCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFGEshopSiftListItemCell class])];
    itemCell.siftItemModel = [self siftModelWithIndexPath:indexPath];
    @weakify(self)
    itemCell.touchArrowImgBlock = ^(ZFGeshopSiftItemModel *rowSiftModel) {
        @strongify(self)
        [self selectCellRowAtIndexPath:indexPath];
    };
    itemCell.selecteCurrentSiftBlock = ^(ZFGeshopSiftItemModel *rowSiftModel) {
        @strongify(self)
        [self unCheckoutHasSelected:self.sectionSiftModelArray];
        rowSiftModel.isCurrentSelected = (rowSiftModel.child_item.count <= 0);
        [self.tableView reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (self.selectedCategoryBlock) {
                self.selectedCategoryBlock(rowSiftModel);
            }
            [self showSelectView:NO];
        });
    };
    return itemCell;
}

- (void)selectCellRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFGeshopSiftItemModel *rowSiftModel = [self siftModelWithIndexPath:indexPath];
    
    if (rowSiftModel.child_item.count > 0) {
        ZFGeshopSiftItemModel *selectionModel = self.sectionSiftModelArray[indexPath.section];
        selectionModel.isCurrentSelected = NO;
        
        if (rowSiftModel.hasOpenChild) { //关闭
            rowSiftModel.hasOpenChild = NO;
            
            BOOL startFlag = NO;
            NSMutableArray *deleteModelArray = [NSMutableArray array];
            NSMutableArray *deleteIndexArray = [NSMutableArray array];
            
            for (NSInteger i=0; i<selectionModel.selectionAllChildItemArr.count; i++) {
                ZFGeshopSiftItemModel *tempModel = selectionModel.selectionAllChildItemArr[i];
                if ([tempModel isEqual:rowSiftModel]) {
                    startFlag = YES;
                    continue;
                }
                if (!startFlag) continue;
                if (tempModel.childLevel > rowSiftModel.childLevel) {
                    [deleteModelArray addObject:tempModel];
                    [deleteIndexArray addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                } else {
                    break;
                }
            }
            [selectionModel.selectionAllChildItemArr removeObjectsInArray:deleteModelArray];
            
            /// 刷新插入的行
            [self.tableView deleteRowsAtIndexPaths:deleteIndexArray withRowAnimation:UITableViewRowAnimationFade];
            
        } else { //打开
            rowSiftModel.hasOpenChild = YES;
            NSInteger idx = -1;
            self.tempAddArray = [NSMutableArray arrayWithArray:rowSiftModel.child_item];
            NSMutableArray *addArray = [self fetchOpenChildItem:rowSiftModel.child_item];
            
            for (NSInteger i=0; i<selectionModel.selectionAllChildItemArr.count; i++) {
                ZFGeshopSiftItemModel *tempModel = selectionModel.selectionAllChildItemArr[i];
                if ([tempModel isEqual:rowSiftModel]) {
                    idx = i;
                    continue;
                }
                if (idx == -1) continue;
                if (tempModel.childLevel > rowSiftModel.childLevel) {
                    if (tempModel.hasOpenChild) {
                        [addArray addObject:tempModel];
                    }
                } else {
                    break;
                }
            }
            for (ZFGeshopSiftItemModel *tempModel in rowSiftModel.child_item) {
                tempModel.childLevel = rowSiftModel.childLevel + 1;
            }
            
            NSMutableArray *addIndexArray = [NSMutableArray array];
            if (idx == -1) {
                NSInteger startIdx = selectionModel.selectionAllChildItemArr.count - 1;
                for (NSInteger i=0; i<rowSiftModel.child_item.count; i++) {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:(startIdx+i) inSection:indexPath.section];
                    [addIndexArray addObject:path];
                }
                [selectionModel.selectionAllChildItemArr addObjectsFromArray:rowSiftModel.child_item];
            } else {
                NSInteger startIdx = idx+1;
                for (NSInteger i=0; i<addArray.count; i++) {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:(startIdx+i) inSection:indexPath.section];
                    [addIndexArray addObject:path];
                }
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(idx+1, addArray.count)];
                [selectionModel.selectionAllChildItemArr insertObjects:addArray atIndexes:indexSet];
            }
            /// 刷新插入的行
            [self.tableView insertRowsAtIndexPaths:addIndexArray withRowAnimation:UITableViewRowAnimationNone];
        }
        /// 刷新表高度
        [self showSelectView:YES];
        /// 刷新点击的行加减箭头
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    } else {
        [self setSelectdSiftModel:rowSiftModel selecteFalg:YES];
    }
}

- (NSMutableArray *)fetchOpenChildItem:(NSArray *)tempModelArray {
    NSArray *array = nil;
    for (ZFGeshopSiftItemModel *tempModel in tempModelArray) {
        if (tempModel.hasOpenChild && tempModel.child_item.count>0) {
            [self.tempAddArray addObjectsFromArray:tempModel.child_item];
            array = tempModel.child_item;
        }
    }
    if (array.count > 0) {
        return [self fetchOpenChildItem:array];
    } else {
        return self.tempAddArray;
    }
}

- (void)unCheckoutHasSelected:(NSArray *)childModelArray {
    for (ZFGeshopSiftItemModel *tempModel in childModelArray) {
        tempModel.isCurrentSelected = NO;
        if (tempModel.child_item.count>0) {
            [self unCheckoutHasSelected:tempModel.child_item];
        }
    }
}

- (void)setSelectdSiftModel:(ZFGeshopSiftItemModel *)siftModel
                selecteFalg:(NSInteger)selecteFalg
{
    [self resetAllSelecteStatus:self.sectionSiftModelArray];
    siftModel.isCurrentSelected = selecteFalg;
    [self.tableView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.selectedCategoryBlock) {
            self.selectedCategoryBlock(siftModel);
        }
        [self showSelectView:NO];
    });
}

//递归重置选中/打开标识
- (void)resetAllSelecteStatus:(NSArray *)sectionModelArray {
    if (!ZFJudgeNSArray(sectionModelArray)) return;
    
    for (ZFGeshopSiftItemModel *sectionSiftModel in sectionModelArray) {
        if (![sectionSiftModel isKindOfClass:[ZFGeshopSiftItemModel class]]) continue;
        sectionSiftModel.isCurrentSelected = NO;
        
        for (ZFGeshopSiftItemModel *cellSiftModel in sectionSiftModel.selectionAllChildItemArr) {
            if (![cellSiftModel isKindOfClass:[ZFGeshopSiftItemModel class]]) continue;
            cellSiftModel.isCurrentSelected = NO;
        }
        //[self resetAllSelecteStatus:sectionSiftModel.child_item];
    }
}

#pragma mark - Public Methods

- (void)openCategoryListView {
    self.hidden = NO;
    [self showSelectView:YES];
}

- (void)showSelectView:(BOOL)show {
    CGFloat showHeight = show ? [self fetchSeemlyTableHeight] : 0;
    CGFloat maskViewAlpha = show ? 0.3 : 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.frame = CGRectMake(0, 0, KScreenWidth, showHeight);
        self.maskBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:maskViewAlpha];
        
    } completion:^(BOOL finished) {
        self.hidden = !show;
        if (self.categoryCompletionAnimation) {
            self.categoryCompletionAnimation(show);
        }
    }];
}

- (void)dismissCategoryListView {
    [self showSelectView:NO];
}

- (CGFloat)fetchSeemlyTableHeight {
    [self layoutIfNeeded];
    NSInteger sectionsCount = [self numberOfSectionsInTableView:self.tableView];
    NSInteger rowCount = 0;
    for (NSInteger i=0; i<sectionsCount; i++) {
        rowCount += [self tableView:self.tableView numberOfRowsInSection:i];
    }
    return kSelectCellHeight * MIN((sectionsCount + rowCount), 6);
}

#pragma mark - Getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [UIView new];
        _tableView.sectionHeaderHeight = kSelectCellHeight;
        _tableView.sectionFooterHeight = 0.1;
        _tableView.rowHeight = kSelectCellHeight;
        _tableView.layer.cornerRadius = 8;
        _tableView.layer.masksToBounds = YES;
        
        [_tableView registerClass:[ZFGEshopSiftListItemCell class] forCellReuseIdentifier:NSStringFromClass([ZFGEshopSiftListItemCell class])];
        
        [_tableView registerClass:[ZFGeshopSiftListHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([ZFGeshopSiftListHeaderView class])];
    }
    return _tableView;
}

- (UIView *)tmpWhiteView {
    if (!_tmpWhiteView) {
        _tmpWhiteView = [[UIView alloc] initWithFrame:CGRectZero];
        _tmpWhiteView.backgroundColor = [UIColor whiteColor];
    }
    return _tmpWhiteView;
}

- (UIView *)maskBgView {
    if (!_maskBgView) {
        _maskBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        _maskBgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCategoryListView)];
        [_maskBgView addGestureRecognizer:tap];
    }
    return _maskBgView;
}

@end
