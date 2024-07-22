//
//  CategorySelectView.m
//  ListPageViewController
//
//  Created by YW on 8/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategorySelectView.h"  
#import "CategoryNewModel.h"
#import "CategorySectionViewCell.h"
#import "CategorySortSectionView.h"
#import "CategoryPriceListSectionView.h"
#import "CategorySubCell.h"
#import "CategoryPriceListModel.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "UIView+ZFViewCategorySet.h"

static CGFloat    const kSelectCellHeight = 44.0f;

@interface CategorySelectView ()<UITableViewDelegate,UITableViewDataSource,CAAnimationDelegate>
@property (nonatomic, strong) UITableView        *selectTableView;
@property (nonatomic, strong) UIView             *tmpWhiteView;//只是为了在切圆角时盖住顶部上面两个圆角
@property (nonatomic, strong) UIView             *maskView;
@end

@implementation CategorySelectView

#pragma mark - Init Method
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureSubViews];
        [self autoLayoutSubViews];
    }
    return self;
}

#pragma mark - Initialize
- (void)configureSubViews {
    self.hidden = YES;
    [self addSubview:self.maskView];
    [self addSubview:self.tmpWhiteView];
    [self addSubview:self.selectTableView];
}

- (void)autoLayoutSubViews{
    self.maskView.frame = CGRectMake(0, 0, KScreenWidth,KScreenHeight - 108);
    self.selectTableView.frame = CGRectMake(0, 0, KScreenWidth, 0);
    self.tmpWhiteView.frame = CGRectMake(0, 0, KScreenWidth, 10);
}

#pragma mark - Setter
- (void)setCategoryArray:(NSArray *)categoryArray {
    _categoryArray = categoryArray;
    [self.selectTableView reloadData];
}

- (void)setSortArray:(NSArray<NSString *> *)sortArray {
    _sortArray = sortArray;
    [self.selectTableView reloadData];
}

- (void)setCurrentSortType:(NSString *)currentSortType {
    _currentSortType = currentSortType;
    [self.selectTableView reloadData];
}

- (void)setCurrentPriceType:(NSString *)currentPriceType {
    _currentPriceType = currentPriceType;
    [self.selectTableView reloadData];
}

#pragma mark - UITableViewDelegate - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataType == SelectViewDataTypeCategory ? self.categoryArray.count : self.sortArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.isPriceList
        || self.dataType != SelectViewDataTypeCategory) {
        return 0;
    } else {
        CategoryNewModel *model = self.categoryArray[section];
        if ([model.is_child boolValue] && model.isOpen) {
            return self.isVirtual ? [self loadSubCategory:model.cat_id].count : model.childrenList.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CategorySubCell *cell = [tableView dequeueReusableCellWithIdentifier:[CategorySubCell setIdentifier] forIndexPath:indexPath];
    
    CategoryNewModel *sectionModel = self.categoryArray[indexPath.section];
    NSArray<CategoryNewModel *> *childs = self.isVirtual ? [[CategoryDataManager shareManager] querySubCategoryDataWithParentID:sectionModel.cat_id] : sectionModel.childrenList;
    
    CategoryNewModel *cellModel = childs[indexPath.row];
    cellModel.isSelect = [self.currentCateId isEqualToString:cellModel.cat_id] ? YES : NO;
    cell.titleLabel.text = cellModel.cat_name;
    cell.isSelect = cellModel.isSelect;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.dataType == SelectViewDataTypeCategory ) {
        if (self.isPriceList) {
            CategoryPriceListSectionView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[CategoryPriceListSectionView setIdentifier]];
            CategoryPriceListModel *model = self.categoryArray[section];
            headerView.priceRange = model.price_range;
            headerView.isSelect = [self.currentPriceType isEqualToString:headerView.priceRange] ? YES : NO;
            headerView.categoryPriceListSectionViewTouchHandler = ^(NSString *selectTitle, BOOL isSelect) {
                if (self.selectCompletionHandler) {
                    self.selectCompletionHandler(section, self.dataType);
                }
                self.currentPriceType = selectTitle;
                [self reloadTableViewData];
            };
            return headerView;
        }else{
            CategorySectionViewCell *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[CategorySectionViewCell setIdentifier]];
            CategoryNewModel *model = self.categoryArray[section];
            model.isSelect = [self.currentCateId isEqualToString:model.cat_id] ? YES : NO;
            headerView.model = model;
            @weakify(headerView)
            headerView.categorySectionViewTouchHandler = ^(CategoryNewModel *model) {
                @strongify(headerView)
                if ([model.is_child boolValue]) {
                    NSArray *childArray = self.isVirtual ? [self loadSubCategory:model.cat_id] : model.childrenList;
                    NSMutableArray *indexPaths = [NSMutableArray array];
                    for (int i = 0; i < childArray.count; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:section]];
                    }

                    headerView.model = model;
                    CGFloat offsetY = self.selectTableView.contentOffset.y;
                    if (model.isOpen) {
                        [self.selectTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                        [self.selectTableView setContentOffset:CGPointMake(0.0, offsetY)];
                    }else{
                        [self.selectTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                        [self.selectTableView setContentOffset:CGPointZero];
                    }
                    
                    NSMutableArray *openArray = [NSMutableArray array];
                    for (CategoryNewModel *model in self.categoryArray) {
                        if (model.isOpen) {
                            NSArray *childs = self.isVirtual ? [self loadSubCategory:model.cat_id] : model.childrenList;
                            [openArray addObjectsFromArray:childs];
                        }
                    }
                    [openArray addObjectsFromArray:self.categoryArray];
                    CGFloat  resultHeight = MIN(openArray.count * kSelectCellHeight, 8 * kSelectCellHeight);
//                    CGFloat  resultHeight = MIN(openArray.count * kSelectCellHeight, self.bounds.size.height - [self queryPhonePadding]);
                    [UIView animateWithDuration:0.3 animations:^{
                        self.selectTableView.frame = CGRectMake(0, 0, KScreenWidth, resultHeight);
                    }];
                }else{
                    for (CategoryNewModel *model in self.categoryArray) {
                        model.isOpen = NO;
                    }
                    if (self.selectCompletionHandler) {
                        self.selectCompletionHandler(section, self.dataType);
                    }
                    self.currentCategory = model.cat_name;
                    self.currentCateId = model.cat_id;
                    [self reloadTableViewData];
                }
            };
            return headerView;
        }

    }else{
        CategorySortSectionView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[CategorySortSectionView setIdentifier]];
        headerView.sortType = self.sortArray[section];
        headerView.isSelect = [self.currentSortType isEqualToString:headerView.sortType] ? YES : NO;
        @weakify(self)
        headerView.categorySortSectionViewTouchHandler = ^(NSString *selectTitle, BOOL isSelect) {
            @strongify(self)
            if (self.selectCompletionHandler) {
                self.selectCompletionHandler(section, self.dataType);
            }
            self.currentSortType = selectTitle;
            [self reloadTableViewData];
        };
        return headerView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    CategoryNewModel *sectionModel = self.categoryArray[indexPath.section];
    NSArray<CategoryNewModel *> *childs = self.isVirtual ? [self loadSubCategory:sectionModel.cat_id] : sectionModel.childrenList;
    CategoryNewModel *cellModel = childs[indexPath.row];
    cellModel.isSelect = !cellModel.isSelect;
    self.currentCategory = cellModel.cat_name;
    self.currentCateId = cellModel.cat_id;
    [self reloadTableViewData];
    if (self.selectSubCellHandler) {
        self.selectSubCellHandler(cellModel, self.dataType);
    }
}

#pragma mark - Private Methods
- (NSArray<CategoryNewModel *> *)loadSubCategory:(NSString *)catID {
    NSArray<CategoryNewModel *> *childs = [[CategoryDataManager shareManager] querySubCategoryDataWithParentID:catID];
    return childs;
}

#pragma mark - Public Methods
- (void)showCompletion:(void (^)(void))completion {
    NSMutableArray *openArray = [NSMutableArray array];
    
    if (self.isPriceList) {
        [openArray addObjectsFromArray:self.categoryArray];
    }else{
        for (CategoryNewModel *model in self.categoryArray) {
            if (model.isOpen) {
                NSArray *childs = self.isVirtual ? [self loadSubCategory:model.cat_id] : model.childrenList;
                [openArray addObjectsFromArray:childs];
            }
        }
        [openArray addObjectsFromArray:self.categoryArray];
    }
    
    CGFloat resultHeight;
    if (self.dataType == SelectViewDataTypeSort) {
        resultHeight = self.sortArray.count * kSelectCellHeight;
    }else{
        resultHeight = MIN(openArray.count * kSelectCellHeight, 8 * kSelectCellHeight);
//        resultHeight = MIN(openArray.count * kSelectCellHeight, self.bounds.size.height - [self queryPhonePadding]);
    }
    self.hidden = NO;
        
    [UIView animateWithDuration:0.3 animations:^{
        self.selectTableView.frame = CGRectMake(0, 0, KScreenWidth, resultHeight);
        self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    } completion:^(BOOL finished) {
        self.hidden = NO;
        if (self.selectAnimationStopCompletionHandler) {
            self.selectAnimationStopCompletionHandler();
        }
    }];
}

- (CGFloat)queryPhonePadding {
    CGFloat padding;
    if (IPHONE_5X_4_0) {
        padding = 158;
    }else if (IPHONE_6X_4_7) {
        padding = 170;
    }else if (IPHONE_7P_5_5) {
        padding = 188;
    }else{
        padding = 0; // 为了取消警告写的
    }
    return padding;
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.selectTableView.frame = CGRectMake(0, 0, KScreenWidth, 0);
        self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];

    } completion:^(BOOL finished) {
        self.hidden = YES;
        if (self.selectAnimationStopCompletionHandler) {
            self.selectAnimationStopCompletionHandler();
        }
    }];
}

- (void)reloadTableViewData {
    [self.selectTableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismiss];
    });
}

- (void)reloadRowData:(NSArray *)dataArray {
    [self.selectTableView beginUpdates];
    NSMutableArray *indexPathArray = [NSMutableArray array];
    for (NSUInteger i = 0; i < dataArray.count; i++) {
        [indexPathArray addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.selectTableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationFade];
    [self.selectTableView endUpdates];
}

#pragma mark - Gesture Handle
- (void)hideSelectView {
    [self dismiss];
    if (self.maskTapCompletionHandler) {
        self.maskTapCompletionHandler(self.dataType);
    }
}

#pragma mark - Getter
- (UITableView *)selectTableView {
    if (!_selectTableView) {
        _selectTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _selectTableView.dataSource = self;
        _selectTableView.delegate = self;
        _selectTableView.showsVerticalScrollIndicator = NO;
        _selectTableView.backgroundColor = [UIColor whiteColor];
        _selectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _selectTableView.tableFooterView = [UIView new];
        _selectTableView.sectionHeaderHeight = 44.0;
        _selectTableView.layer.cornerRadius = 8;
        _selectTableView.layer.masksToBounds = YES;
        
        _selectTableView.rowHeight = kSelectCellHeight;
         [_selectTableView registerClass:[CategorySectionViewCell class] forHeaderFooterViewReuseIdentifier:[CategorySectionViewCell setIdentifier]];
        [_selectTableView registerClass:[CategorySortSectionView class] forHeaderFooterViewReuseIdentifier:[CategorySortSectionView setIdentifier]];
        [_selectTableView registerClass:[CategoryPriceListSectionView class] forHeaderFooterViewReuseIdentifier:[CategoryPriceListSectionView setIdentifier]];
        [_selectTableView registerClass:[CategorySubCell class] forCellReuseIdentifier:[CategorySubCell setIdentifier]];
    }
    return _selectTableView;
}

- (UIView *)tmpWhiteView {
    if (!_tmpWhiteView) {
        _tmpWhiteView = [[UIView alloc] initWithFrame:CGRectZero];
        _tmpWhiteView.backgroundColor = [UIColor whiteColor];
    }
    return _tmpWhiteView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        _maskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelectView)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

@end
