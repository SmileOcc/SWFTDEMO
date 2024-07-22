//
//  ZFOutfitSelectedRefineView.m
//  ZZZZZ
//
//  Created by YW on 2018/10/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFOutfitSelectedRefineView.h"
#import "ZFOutfitRefineToolBar.h"
#import "ZFOutfitRefineCell.h"
#import "ZFOutfitRefineHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

#import "UIView+ZFViewCategorySet.h"

@interface ZFOutfitSelectedRefineView ()<UITableViewDelegate,UITableViewDataSource,ZFInitViewProtocol>

@property (nonatomic, strong) YYLabel                            *navTitleLabel;
@property (nonatomic, strong) UIButton                           *closeButton;
@property (nonatomic, strong) UITableView                        *tableView;
@property (nonatomic, strong) ZFOutfitRefineToolBar              *toolBar;
@property (nonatomic, strong) UIView                             *lineView;

@property (nonatomic, strong) NSMutableDictionary                *parms;
@property (nonatomic, assign) CGFloat                            currentScrollOffsetY;
@property (nonatomic, assign) float                              selectedMinimum;
@property (nonatomic, assign) float                              selectedMaximum;

@end

@implementation ZFOutfitSelectedRefineView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}


#pragma mark - Initialize
- (void)zfInitView {
    [self addSubview:self.navTitleLabel];
    [self addSubview:self.closeButton];
    [self addSubview:self.tableView];
    [self addSubview:self.toolBar];
    [self addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_top).offset(24.5);
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(KScreenWidth - 75);
        make.height.mas_equalTo(30);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading);
        make.centerY.mas_equalTo(self.navTitleLabel.mas_centerY);
    }];
    
    [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(49, 0, 50, 0));
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_top).offset(49);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self addDropShadowWithOffset:CGSizeMake(-2, 0)
                           radius:2
                            color:[UIColor blackColor]
                          opacity:0.1];
}

- (void)actionClose:(UIButton *)sender {
    if (self.closeBlock) {
        self.closeBlock(YES);
    }
    self.closeButton.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.closeButton.userInteractionEnabled = YES;
    });
}

#pragma mark - Setter
- (void)setCategroyRefineModel:(CategoryRefineSectionModel *)categroyRefineModel {
    _categroyRefineModel = categroyRefineModel;
    [self.tableView reloadData];
}


#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.categroyRefineModel.refine_list.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    CategoryRefineDetailModel *detailModel = self.categroyRefineModel.refine_list[section];
    return detailModel.isExpend ? detailModel.childArray.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFOutfitRefineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZFOutfitRefineCell" forIndexPath:indexPath];
    CategoryRefineDetailModel *detailModel = self.categroyRefineModel.refine_list[indexPath.section];
    CategoryRefineCellModel *cellModel = detailModel.childArray[indexPath.row];
    cell.titleLabel.text = cellModel.name;
    cell.isSelect = cellModel.isSelect;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ZFOutfitRefineHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"ZFOutfitRefineHeaderView"];
    CategoryRefineDetailModel *detailModel = self.categroyRefineModel.refine_list[section];
    headerView.categoryRefineModel = detailModel;
    
    headerView.selectBlock = ^(CategoryRefineDetailModel *model) {
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
    
    CategoryRefineDetailModel *detailModel = self.categroyRefineModel.refine_list[indexPath.section];
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
}


#pragma mark - Private Methods
- (void)moveTableViewToMiddlePointWithSection:(NSInteger)section{
    
    // 64+44+80是tableView 上面高度  50是 optinView 高度   44是 单个 cell 高度
    self.currentScrollOffsetY = self.tableView.contentOffset.y;    //_currentScrollOffsetY 为当前ScrollView滚动的偏移量
    CGFloat perfectLocationY = (((KScreenHeight - 188) / 4.0 + _currentScrollOffsetY) / 44) * 44;  //完美状态位置 y
    
    //将tableview在点击header的时候 移动到合适的位置。
    CGRect touchFrame = [self.tableView rectForSection:section];
    NSInteger maxSection = self.categroyRefineModel.refine_list.count - 1;
    CGRect lastFrame = [self.tableView rectForSection:maxSection];
    
    CGFloat canMoveHeight = lastFrame.origin.y - _currentScrollOffsetY + 44;
    //加上点击展开的那部分cell的高度
    if (self.categroyRefineModel.refine_list[section].isExpend && section == maxSection) {
        canMoveHeight += (44 * (self.categroyRefineModel.refine_list[section].childArray.count));
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
    [self.categroyRefineModel.refine_list enumerateObjectsUsingBlock:^(CategoryRefineDetailModel * _Nonnull detailModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (detailModel.attrsArray.count > 0) {
            [allSelectAttrs addObjectsFromArray:detailModel.attrsArray];
        }
    }];
    NSMutableDictionary *parmaters = [NSMutableDictionary dictionary];
    parmaters[@"price_min"] = [@(self.selectedMinimum) stringValue];
    parmaters[@"price_max"] = [@(self.selectedMaximum) stringValue];
    parmaters[@"selected_attr_list"] = [allSelectAttrs componentsJoinedByString:@"~"];
    
    if (self.selectBlock) {
        self.selectBlock(allSelectAttrs.count == 0 ? NO :  YES);
    }
    if (self.applyBlock) {
        self.applyBlock(parmaters);
    }
}

- (void)clearRequestParmaters {
    [self.categroyRefineModel.refine_list enumerateObjectsUsingBlock:^(CategoryRefineDetailModel * _Nonnull detailModel, NSUInteger idx, BOOL * _Nonnull stop) {
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
    
    if (self.selectBlock) {
        self.selectBlock(NO);
    }
    [self.tableView reloadData];
    self.selectedMinimum = 0;
    self.selectedMaximum = 0;
//    self.model.selectPriceMin = @"0";
//    self.model.selectPriceMax = nil;
}

#pragma mark - Getter
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

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"detail_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setContentEdgeInsets:UIEdgeInsetsMake(10, 15, 10, 15)];
    }
    return _closeButton;
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
        [_tableView registerClass:[ZFOutfitRefineHeaderView class] forHeaderFooterViewReuseIdentifier:@"ZFOutfitRefineHeaderView"];
        [_tableView registerClass:[ZFOutfitRefineCell class] forCellReuseIdentifier:@"ZFOutfitRefineCell"];
    }
    return _tableView;
}

- (ZFOutfitRefineToolBar *)toolBar {
    if (!_toolBar) {
        _toolBar = [[ZFOutfitRefineToolBar alloc] init];
        @weakify(self)
        _toolBar.clearBlock = ^{
            @strongify(self)
            [self clearRequestParmaters];
        };
        _toolBar.applyBlock  = ^{
            @strongify(self)
            [self queryRequestParmaters];
        };
    }
    return _toolBar;
}


- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ColorHex_Alpha(0xDDDDDD, 1.0);
    }
    return _lineView;
}

@end
