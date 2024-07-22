//
//  CategoryRefineInfoView.m
//  ListPageViewController
//
//  Created by YW on 30/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryRefineInfoView.h"
#import "CategoryPriceRangeView.h"
#import "CategoryRefineToolBar.h"
#import "CategoryRefineCell.h"
#import "CategoryRefineHeaderView.h"

#import "CategoryRefineSectionModel.h"
#import "CategoryRefineDetailModel.h"
#import "CategoryRefineCellModel.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface CategoryRefineInfoView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) YYLabel                  *navTitleLabel;
@property (nonatomic, strong) CategoryPriceRangeView   *priceRangeView;
@property (nonatomic, strong) UITableView              *tableView;
@property (nonatomic, strong) CategoryRefineToolBar    *toolBar;
@property (nonatomic, strong) NSMutableDictionary      *parms;
@property (nonatomic, assign) CGFloat                  currentScrollOffsetY;
@property (nonatomic, assign) float                    selectedMinimum;
@property (nonatomic, assign) float                    selectedMaximum;


//临时选择项
@property (nonatomic, strong) NSMutableArray           *tempSelectDatas;
@end

@implementation CategoryRefineInfoView
#pragma mark - Init Method
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configureSubViews];
        [self autoLayoutSubViews];
    }
    return self;
}

#pragma mark - Initialize
- (void)configureSubViews {
    [self addSubview:self.navTitleLabel];
    [self addSubview:self.priceRangeView];
    [self addSubview:self.tableView];
    [self addSubview:self.toolBar];
}

- (void)autoLayoutSubViews {
    [self.navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(33);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(KScreenWidth - 75);
    }];
    
    [self.priceRangeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(64);
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(124);
    }];

    [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-kiphoneXHomeBarHeight);
        make.height.mas_equalTo(50);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(188, 0, 50, 0));
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.mas_top).offset(188);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-50);
    }];
}

#pragma mark - Setter
-(void)setModel:(CategoryRefineSectionModel *)model {
    _model = model;
    self.priceRangeView.model = model;
    [self.tableView reloadData];
}

/**
 * 如果是从Deeplink进来需要选中指定的refine
 */
- (void)shouldSelectedCustomRefineByDeeplink:(NSArray<NSString *> *)categoryTypeArr
                                    priceMax:(NSString *)priceMax
                                    priceMin:(NSString *)priceMin
                                    hasCheck:(void(^)(void))hasCheckHandle {
    
    // 刷新筛选价格
    if (!ZFIsEmptyString(priceMax)) {
        self.model.selectPriceMax = priceMax;
    }
    if (!ZFIsEmptyString(priceMin)) {
        self.model.selectPriceMin = priceMin;
    }
    self.priceRangeView.model = self.model;
    
    NSInteger hasSelectedSection = -1;
    
    for (NSString *selectedRefine in categoryTypeArr) {
        if (selectedRefine.length==0) continue;
        for (NSInteger section=0; section<self.model.refine_list.count; section++) {
            CategoryRefineDetailModel *detailModel = self.model.refine_list[section];

            for (int row=0; row<detailModel.childArray.count; row++) {
                CategoryRefineCellModel *cellModel = detailModel.childArray[row];
                if ([selectedRefine isEqualToString:cellModel.attrID]) {
                    YWLog(@"需要选中指定的refine===%@===%@", cellModel.attrID, cellModel.name);
                    hasSelectedSection = section;
                    cellModel.isSelect = YES;
                    detailModel.isExpend = YES;
                    
                    if (!detailModel.selectArray) {
                        detailModel.selectArray = [NSMutableArray array];
                    }
                    if (!detailModel.attrsArray) {
                        detailModel.attrsArray = [NSMutableArray array];
                    }
                    [detailModel.selectArray addObject:cellModel.name];
                    [detailModel.attrsArray addObject:cellModel.attrID];
                }
            }
        }
    }
    
    // 是否已经选中过
    if (hasSelectedSection > -1) {
        if (hasCheckHandle) {
            hasCheckHandle();
        }
        [self.tableView reloadData];
        
        // 移动到合适位置
        [self moveTableViewToMiddlePointWithSection:hasSelectedSection];
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.model.refine_list.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CategoryRefineDetailModel *detailModel = self.model.refine_list[section];
    return detailModel.isExpend ? detailModel.childArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CategoryRefineCell *cell = [tableView dequeueReusableCellWithIdentifier:[CategoryRefineCell setIdentifier] forIndexPath:indexPath];
    CategoryRefineDetailModel *detailModel = self.model.refine_list[indexPath.section];
    CategoryRefineCellModel *cellModel = detailModel.childArray[indexPath.row];
    cell.titleLabel.text = cellModel.name;
    cell.isSelect = cellModel.isSelect;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CategoryRefineHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:[CategoryRefineHeaderView setIdentifier]];
    CategoryRefineDetailModel *detailModel = self.model.refine_list[section];
    headerView.model = detailModel;
    
    headerView.didSelectRefineSelectInfoViewCompletionHandler = ^(CategoryRefineDetailModel *model) {
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (int i = 0; i < model.childArray.count; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:section]];
        }
        if (model.isExpend) {
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
           
        }else{
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        
        if (model.isExpend) {
             // 移动到合适位置
            [self moveTableViewToMiddlePointWithSection:section];
        }
    };
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CategoryRefineDetailModel *detailModel = self.model.refine_list[indexPath.section];
    CategoryRefineCellModel *cellModel = detailModel.childArray[indexPath.row];
    cellModel.isSelect = !cellModel.isSelect;

    if (!detailModel.selectArray) {
        detailModel.selectArray = [NSMutableArray array];
        detailModel.attrsArray = [NSMutableArray array];
    }
    if (cellModel.isSelect) {
        [detailModel.selectArray addObject:cellModel.name];
        [detailModel.attrsArray addObject:cellModel.attrID];
    }else{
        [detailModel.selectArray removeObject:cellModel.name];
        [detailModel.attrsArray  removeObject:cellModel.attrID];
    }

    [self.tableView reloadData];
    
    //occ待优化
}


#pragma mark - Private Methods
- (void)moveTableViewToMiddlePointWithSection:(NSInteger)section{
    
    // 64+44+80是tableView 上面高度  50是 optinView 高度   44是 单个 cell 高度
    self.currentScrollOffsetY = self.tableView.contentOffset.y;    //_currentScrollOffsetY 为当前ScrollView滚动的偏移量
    CGFloat perfectLocationY = (((KScreenHeight - 188) / 4.0 + _currentScrollOffsetY) / 44) * 44;  //完美状态位置 y
    
    //将tableview在点击header的时候 移动到合适的位置。
    CGRect touchFrame = [self.tableView rectForSection:section];
    NSInteger maxSection = self.model.refine_list.count - 1;
    CGRect lastFrame = [self.tableView rectForSection:maxSection];
    
    CGFloat canMoveHeight = lastFrame.origin.y - _currentScrollOffsetY + 44;
    //加上点击展开的那部分cell的高度
    if (self.model.refine_list[section].isExpend && section == maxSection) {
        canMoveHeight += (44 * (self.model.refine_list[section].childArray.count));
    }
    if (canMoveHeight <= 0 || touchFrame.origin.y <= perfectLocationY) {
        //没有可移动空间 或 当前已经是舒适的位置了，不做任何处理
        return ;
    }
    CGFloat finalMoveY = MIN(touchFrame.origin.y - perfectLocationY, canMoveHeight);
    if (finalMoveY <= 0) {
        return ;
    }
    if (finalMoveY + touchFrame.origin.y > lastFrame.origin.y && section != maxSection) {
        finalMoveY = lastFrame.origin.y - touchFrame.origin.y - 44;
    }
    //对 cell 高度取整，确保执行动画准确偏移。避免偏移计算错误导致的闪屏效果。
    [self.tableView setContentOffset:CGPointMake(0, ((finalMoveY + _currentScrollOffsetY)/ 44) * 44) animated:YES];
    
}

- (void)queryRequestParmaters {
    NSMutableArray *allSelectAttrs = [NSMutableArray array];
    NSMutableDictionary *refineTypeDic = [[NSMutableDictionary alloc] init];
    [self.model.refine_list enumerateObjectsUsingBlock:^(CategoryRefineDetailModel * _Nonnull detailModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (detailModel.attrsArray.count > 0) {
            [allSelectAttrs addObjectsFromArray:detailModel.attrsArray];
            
            NSString *af_refineKey = ZFToString(detailModel.name);
            if (!ZFIsEmptyString(af_refineKey)) {
                
                NSMutableArray *subRefineKeys = [[NSMutableArray alloc] init];
                
                [detailModel.childArray enumerateObjectsUsingBlock:^(CategoryRefineCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.isSelect) {
                        [subRefineKeys addObject:ZFToString(obj.name)];
                    }
                }];
                
                NSString *subRefinekeyString = [subRefineKeys componentsJoinedByString:@","];
                if(!ZFIsEmptyString(subRefinekeyString)) {
                    [refineTypeDic setObject:subRefinekeyString forKey:af_refineKey];
                }
            }
        }
    }];
    NSMutableDictionary *parmaters = [NSMutableDictionary dictionary];
    parmaters[@"price_min"] = [@(self.selectedMinimum) stringValue];
    parmaters[@"price_max"] = [@(self.selectedMaximum) stringValue];
    parmaters[@"selected_attr_list"] = [allSelectAttrs componentsJoinedByString:@"~"];
    
    if (self.categoryRefineSelectIconCompletionHandler) {
        self.categoryRefineSelectIconCompletionHandler(allSelectAttrs.count == 0 ? NO :  YES);
    }
    if (self.applyRefineSelectInfoCompletionHandler) {
        self.applyRefineSelectInfoCompletionHandler(parmaters,refineTypeDic);
    }
}

- (void)clearRequestParmaters {
    [self.model.refine_list enumerateObjectsUsingBlock:^(CategoryRefineDetailModel * _Nonnull detailModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (detailModel.selectArray.count > 0) {
            [detailModel.selectArray removeAllObjects];
        }
        if (detailModel.attrsArray.count > 0) {
            [detailModel.attrsArray removeAllObjects];
        }
        [detailModel.childArray enumerateObjectsUsingBlock:^(CategoryRefineCellModel * _Nonnull cellModel, NSUInteger idx, BOOL * _Nonnull stop) {
            cellModel.isSelect = NO;
        }];
    }];
    
    [self.tableView reloadData];
    self.selectedMinimum = 0;
    self.selectedMaximum = 0;
    self.model.selectPriceMin = @"0";
    self.model.selectPriceMax = nil;
    self.priceRangeView.model = self.model;
}

#pragma mark - Getter

- (NSMutableArray *)tempSelectDatas {
    if (!_tempSelectDatas) {
        _tempSelectDatas = [[NSMutableArray alloc] init];
    }
    return _tempSelectDatas;
}

- (YYLabel *)navTitleLabel {
    if (!_navTitleLabel) {
        _navTitleLabel = [YYLabel new];
        _navTitleLabel.textAlignment = NSTextAlignmentCenter;
        _navTitleLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        _navTitleLabel.backgroundColor = ZFCOLOR(255, 255, 255, 1);
        _navTitleLabel.font = [UIFont systemFontOfSize:18.0];
        _navTitleLabel.textColor = ZFCOLOR(51, 51, 51, 1);
        _navTitleLabel.text = ZFLocalizedString(@"GoodsRefine_VC_Title", nil);
    }
    return _navTitleLabel;
}

- (CategoryPriceRangeView *)priceRangeView {
    if (!_priceRangeView) {
        _priceRangeView = [[CategoryPriceRangeView alloc] init];
        @weakify(self)
        _priceRangeView.priceRangeSelectedCompletionHandler = ^(float selectedMinimum, float selectedMaximum) {
             @strongify(self)
            self.selectedMaximum = selectedMaximum;
            self.selectedMinimum = selectedMinimum;
        };
    }
    return _priceRangeView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 44.0;
        _tableView.sectionHeaderHeight = 44.0;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kiphoneXHomeBarHeight, 0);
        [_tableView registerClass:[CategoryRefineHeaderView class] forHeaderFooterViewReuseIdentifier:[CategoryRefineHeaderView setIdentifier]];
        [_tableView registerClass:[CategoryRefineCell class] forCellReuseIdentifier:[CategoryRefineCell setIdentifier]];
    }
    return _tableView;
}

- (CategoryRefineToolBar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[CategoryRefineToolBar alloc] init];
        @weakify(self)
        _toolBar.clearButtonActionCompletionHandle = ^{
            @strongify(self)
            [self clearRequestParmaters];
        };
        _toolBar.applyButtonActionCompletionHandle = ^{
            @strongify(self)
            [self queryRequestParmaters];
        };
    }
    return _toolBar;
}


@end
