//
//  YXGroupSettingView.m
//  uSmartOversea
//
//  Created by ellison on 2018/11/27.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXGroupSettingView.h"
#import <YYText/YYText.h>

#import <TYAlertController/UIView+TYAlertView.h>
#import <YYText/NSAttributedString+YYText.h>
#import "YXSecuGroupManager.h"
#import <Masonry.h>
#import "YXUICollectionViewFlowLayout.h"
#import "uSmartOversea-Swift.h"
#import <QMUIKit/QMUIKit.h>
#import <YYCategories/YYCGUtilities.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <IQKeyboardManagerSwift-Swift.h>
#import "YXSecuGroup.h"
#import <UIImage+YYAdd.h>

@interface YXChangeGroupCell : UITableViewCell

@property (nonatomic, strong) YXSecuGroup *secuGroup;

@property (nonatomic, strong) QMUIButton *selectButton;

@property (nonatomic, assign) BOOL isAdd;

@property (nonatomic, strong) dispatch_block_t onClickSelect;

@property (nonatomic, strong) UILabel *nameLabel;


@end

@implementation YXChangeGroupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = QMUITheme.popupLayerColor;
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.selectButton];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(16);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-16);
            make.centerY.equalTo(self.contentView);
        }];
        
    }
    return self;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [QMUITheme textColorLevel1];
    }
    return _nameLabel;
}

- (QMUIButton *)selectButton {
    if (_selectButton == nil) {
        _selectButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setImage:[UIImage imageNamed:@"edit_uncheck"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"edit_checked"] forState:UIControlStateSelected];
        _selectButton.userInteractionEnabled = NO;
    }
    return _selectButton;
}

- (void)selectAction {
    self.selected = !self.selected;
    if (self.onClickSelect) {
        self.onClickSelect();
    }
}

- (void)setIsAdd:(BOOL)isAdd {
    _isAdd = isAdd;
    if (isAdd) {
        self.secuGroup = nil;
        [self.selectButton setTitle:[YXLanguageUtility kLangWithKey:@"add_group"] forState:UIControlStateNormal];
        self.selectButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.selectButton setTitleColor:[QMUITheme textColorLevel3] forState:UIControlStateNormal];
        [self.selectButton setImage:[UIImage imageNamed:@"group_add"] forState:UIControlStateNormal];
        self.selectButton.imagePosition = QMUIButtonImagePositionTop;
        self.selectButton.titleEdgeInsets = UIEdgeInsetsMake(6, 0, 0, 0);
    }
}

- (void)setSecuGroup:(YXSecuGroup *)secuGroup {
    _secuGroup = secuGroup;
    
    if (secuGroup == nil) {
        return;
    }
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@(%lu)", secuGroup.name, (unsigned long)secuGroup.list.count];
}

@end

@interface YXGroupSettingView () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

//@property (nonatomic, strong) id<YXSecuProtocol> secu;
@property (nonatomic, strong) NSArray<YXSecuIDProtocol> *secus;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) YYLabel *stockLabel;
@property (nonatomic, strong) UIButton *closeButton;

//@property (nonatomic, strong) UIView *bottomView;
//@property (nonatomic, strong) UILabel *systemGroupLabel;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) QMUIButton *allGroupButton;
@property (nonatomic, strong) UIButton *hkGroupButton;
@property (nonatomic, strong) UIButton *usGroupButton;

@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UILabel *groupLabel;
//@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *customGroupList;
//@property (nonatomic, strong) NSArray *groupListOfStock;
@property (nonatomic, strong) NSMutableArray *addTargetGroups; // 用户选中的将要把股票加入的分组
@property (nonatomic, strong) NSMutableArray *removeTargetGroups; // 用户选中的将要把股票移除的分组

@property (nonatomic, assign) YXGroupSettingType settingType;
@property (nonatomic, strong) YXSecuGroup *currentOperationGroup;

@property (nonatomic, strong) NSString *secuName;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) YXEditGroupBottomView *bottomView;
@property (nonatomic, strong) YXSetGroupNameTextfieldView *addGroupTextFieldView;

@end

@implementation YXGroupSettingView

- (instancetype)initWithSecus:(NSArray<YXSecuIDProtocol> *)secus secuName:(NSString *)secuName currentOperationGroup:(YXSecuGroup *)group settingType:(YXGroupSettingType)type {
    self = [self initWithFrame:CGRectMake(0, 0, YXConstant.screenWidth, 338 + YXConstant.safeAreaInsetsBottomHeight)];
    if (self) {
        self.backgroundColor = QMUITheme.popupLayerColor;
//        self.secu = secu;
        self.secus = secus;
        self.secuName = secuName;
        self.settingType = type;
        self.currentOperationGroup = group;
        self.addTargetGroups = [NSMutableArray array];
        self.removeTargetGroups = [NSMutableArray array];
        [self initializeData];
        [self initializeViews];
    }
    return self;
}

- (void)initializeData {

    NSArray *customGroups = [[YXSecuGroupManager shareInstance] allCustomGroupList];
    NSMutableArray *customGroupsDataSource  = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    [customGroups enumerateObjectsUsingBlock:^(YXSecuGroup * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YXSecuGroup *group = [[YXSecuGroup alloc] init];
        group.name = obj.name;
        group.ID = obj.ID;
        group.list = [obj.list copy];
        if (weakSelf.settingType == YXGroupSettingTypeAdd && weakSelf.currentOperationGroup.ID != obj.ID) { // 批量添加不显示当前正在编辑的分组
            [customGroupsDataSource addObject:group];
        }else if (weakSelf.settingType == YXGroupSettingTypeModify) {
            [customGroupsDataSource addObject:group];
        }
        
    }];
    self.customGroupList = [customGroupsDataSource mutableCopy];
    
    [self.tableView reloadData];
}

- (void)initializeViews {
    
//    [self setupTop];
//    [self setupBottom];
//    [self setupMiddle];
    UIView *lineView = [UIView lineView];
    lineView.backgroundColor = [QMUITheme popSeparatorLineColor];
    
    [self addSubview:self.tableView];
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:lineView];
    
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.bottom.equalTo(self.bottomView.mas_top);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(48 + YXConstant.safeAreaInsetsBottomHeight);
    }];
    
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.bottomView);
        make.height.mas_equalTo(1);
    }];
    
    if ([[UIApplication sharedApplication] keyWindow] != nil) {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        [keyWindow addSubview:self.addGroupTextFieldView];
        [self.addGroupTextFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.equalTo(keyWindow);
        }];
    }
    
    //[self addSubview:self.addGroupTextFieldView];
    
}

//- (void)setupMiddle {
//    [self addSubview:self.middleView];
//
//    [self.middleView addSubview:self.groupLabel];
//    [self.middleView addSubview:self.collectionView];
//
//    [self.middleView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.topView.mas_bottom);
//        make.bottom.equalTo(self.bottomView.mas_top);
//        make.left.right.equalTo(self);
//    }];
//
//    [self.groupLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(12);
//        make.top.mas_equalTo(12);
//    }];
//
//    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.groupLabel.mas_bottom);
//        make.left.right.bottom.equalTo(self.middleView);
//    }];
//}

- (void)setupBottom {
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [QMUITheme popSeparatorLineColor];
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:lineView];
    [self.bottomView addSubview:self.sureButton];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.height.mas_equalTo(48 + YXConstant.safeAreaInsetsBottomHeight);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.bottomView);
        make.height.mas_equalTo(1);
    }];
    
    [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bottomView);
        make.top.equalTo(self.bottomView);
        make.height.mas_equalTo(48);
        make.width.mas_equalTo(80);
    }];
}

- (void)setupTop {
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [QMUITheme popSeparatorLineColor];
    [self addSubview:self.topView];
    [self.topView addSubview:self.stockLabel];
    [self.topView addSubview:self.closeButton];
    [self.topView addSubview:lineView];
    
    [self.stockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.topView);
        make.left.greaterThanOrEqualTo(self.topView).offset(50);
        make.right.lessThanOrEqualTo(self.topView).offset(-50);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topView);
        make.right.equalTo(self.topView).offset(-16);
        make.width.height.mas_equalTo(20);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.topView);
        make.height.mas_equalTo(1);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(52);
    }];
}

- (void)sureButtonAction {
    __block BOOL appendResult = YES;
    __weak typeof(self) weakSelf = self;
    [self.addTargetGroups enumerateObjectsUsingBlock:^(YXSecuGroup *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YXSecuGroup *originGroup = [YXSecuGroupManager shareInstance].customGroupPool[@(obj.ID)];
        NSArray *tempArray = weakSelf.secus;
        if (weakSelf.settingType == YXGroupSettingTypeAdd) { // YXSecuGroupManager里面添加股票到分组的逻辑是添加到第一位，导致批量添加时会倒叙添加，所以此处需要把数组翻转后再添加
            tempArray = (NSArray<YXSecuIDProtocol> *)[[weakSelf.secus reverseObjectEnumerator] allObjects];
        }
        if (![[YXSecuGroupManager shareInstance] _appendArray:tempArray secuGroup:originGroup needPost:NO]) {
            appendResult = NO;
        }
    }];
    
    [self.removeTargetGroups enumerateObjectsUsingBlock:^(YXSecuGroup *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YXSecuGroup *originGroup = [YXSecuGroupManager shareInstance].customGroupPool[@(obj.ID)];
        [[YXSecuGroupManager shareInstance] _removeArray:weakSelf.secus secuGroup:originGroup needPost:NO];
    }];

    if (appendResult) {
        [[YXSecuGroupManager shareInstance] postGroup];
    }

    if (self.addResultCallback) {
        self.addResultCallback(appendResult);
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kCustomSecuGroupAddStockNotification object:nil];
    
}

- (void)closeButtonAction{
    [self hideView];
}

- (BOOL)group:(YXSecuGroup *)group containSecuList:(NSArray<YXSecuID *> *)secus {
    __block BOOL iscontain = YES;
    __weak typeof(self) weakSelf = self;
    [secus enumerateObjectsUsingBlock:^(YXSecuID *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![weakSelf array:group.list containTheStock:obj]) {
            iscontain = NO;
            *stop = YES;
        }
    }];
    
    return iscontain;
}

- (BOOL)array:(NSArray *)arr containTheStock:(YXSecuID *)secuId {
    BOOL iscontain = NO;
    for (YXSecuID *item in arr) {
        if ([item.symbol isEqualToString:secuId.symbol] && [item.market isEqualToString:secuId.market]) {
            iscontain = YES;
            break;
        }
    }
    
    return iscontain;
}

- (void)addSecus:(NSArray *)secus toGroup:(YXSecuGroup *)group {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:group.list];
    YXSecuGroup *origin = [YXSecuGroupManager shareInstance].customGroupPool[@(group.ID)];
    __weak typeof(self) weakSelf = self;
    [secus enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (weakSelf.settingType == YXGroupSettingTypeAdd) { // 添加需要检查原来是否就存在
            if (![weakSelf array:origin.list containTheStock:obj]) {
                [arr addObject:obj];
            }
        }else if (weakSelf.settingType == YXGroupSettingTypeModify) {
            [arr addObject:obj];
        }
    }];
    
    group.list = [arr copy];
}

- (BOOL)removeSecus:(NSArray *)secus fromGroup:(YXSecuGroup *)group {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:group.list];
    YXSecuGroup *origin = [YXSecuGroupManager shareInstance].customGroupPool[@(group.ID)];
    __block BOOL flag = YES;
    __weak typeof(self) weakSelf = self;
    [secus enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 如果是批量编辑，那只能是单向操作，就是只能添加，不能把原来就已经在组里的股票删除掉
        if (weakSelf.settingType == YXGroupSettingTypeAdd) {
            // 如果是此次操作添加到的group，允许移除，如果是原来的分组里就有的，不允许移除
            if (![weakSelf array:origin.list containTheStock:obj]) {
                [weakSelf removeStock:obj fromArray:arr];
            }else {
                flag = NO;
            }
        }else if (weakSelf.settingType == YXGroupSettingTypeModify) {
            [weakSelf removeStock:obj fromArray:arr];
        }
    }];
    
    group.list = [arr copy];
    
    return flag;
}

- (void)removeStock:(YXSecuID *)secuId fromArray:(NSMutableArray *)array {
    [array enumerateObjectsUsingBlock:^(YXSecuID * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([secuId.symbol isEqualToString:obj.symbol] && [secuId.market isEqualToString:obj.market]) {
            [array removeObject:obj];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.customGroupList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YXChangeGroupCell *cell = (YXChangeGroupCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YXChangeGroupCell class]) forIndexPath:indexPath];
    cell.secuGroup = self.customGroupList[indexPath.row];
    cell.selectButton.selected = [self group:cell.secuGroup containSecuList:self.secus];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YXChangeGroupCell *cell = (YXChangeGroupCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectButton.selected) {
        BOOL canMove = [self removeSecus:self.secus fromGroup:cell.secuGroup];
        if ([self.addTargetGroups containsObject:cell.secuGroup]) { // 从分组中移除，先检查用于记录添加操作的数组里是否有添加记录，如果有添加记录，此处的移除操作相当于把曾经的添加记录移除掉，相当于重复操作的互相抵消
            [self.addTargetGroups removeObject:cell.secuGroup];
        }else {
            if(canMove) {
                [self.removeTargetGroups addObject:cell.secuGroup];
            }
        }
        
        [self.tableView reloadData];

    } else {
        [self addSecus:self.secus toGroup:cell.secuGroup];
        
        if ([self.removeTargetGroups containsObject:cell.secuGroup]) { // 从分组中添加，先检查用于记录移除操作的数组里是否有移除记录，如果有移除记录，此处的操作相当于把曾经的移除记录除掉，相当于重复操作的互相抵消
            [self.removeTargetGroups removeObject:cell.secuGroup];
        }else {
            [self.addTargetGroups addObject:cell.secuGroup];
        }
        
        [self.tableView reloadData];
    }
}

- (void)addButtonAction {
    if ([[YXSecuGroupManager shareInstance].customGroupPool count] >= 10) {
        [YXProgressHUD showError:[YXLanguageUtility kLangWithKey:@"tips_group_count_max"] in:[UIApplication sharedApplication].keyWindow];
    } else {
        if ([[UIApplication sharedApplication] keyWindow] != nil) {
            UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
            [keyWindow addSubview:self.addGroupTextFieldView];
            [self.addGroupTextFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.bottom.right.equalTo(keyWindow);
            }];
            [keyWindow bringSubviewToFront:_addGroupTextFieldView];
            [self.addGroupTextFieldView.textField becomeFirstResponder];
        }
    }

}

#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    return [[NSAttributedString alloc] initWithString:[YXLanguageUtility kLangWithKey:@"tip_add_group"]];
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView {
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 80)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 30)];
    titleLabel.text = [YXLanguageUtility kLangWithKey:@"tip_add_group"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [QMUITheme textColorLevel3];
    titleLabel.font = [UIFont systemFontOfSize:12];
    [customView addSubview:titleLabel];
    
    QMUIButton *addButton = [QMUIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(0, 30, 150, 30);
    [addButton setTitle:[YXLanguageUtility kLangWithKey:@"add_group"] forState:UIControlStateNormal];
    addButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [addButton setTitleColor:[QMUITheme themeTextColor] forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"group_add_blue"] forState:UIControlStateNormal];
    [addButton setImage:[UIImage imageNamed:@"group_add_blue"] forState:UIControlStateHighlighted];
    addButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    addButton.imagePosition = QMUIButtonImagePositionLeft;
    //[addButton setButtonImagePostion:YXButtonSubViewPositonLeft interval:8];
    [addButton addTarget:self action:@selector(addButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:addButton];
    
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom);
        make.centerX.equalTo(customView);
        make.bottom.equalTo(customView);
        make.height.mas_equalTo(30);
    }];

    return customView;
}


#pragma mark - DZNEmptyDataSetDelegate

//- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
//    return self.viewModel.dataSource == nil;
//}

//- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
//    return YES;
//}

//- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
//    return -(self.tableView.contentInset.top - self.tableView.contentInset.bottom) / 2;
//}

//- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
//    return 80;
//}


#pragma mark - getter

- (YXSetGroupNameTextfieldView *)addGroupTextFieldView {
    if (!_addGroupTextFieldView) {
        _addGroupTextFieldView = [[YXSetGroupNameTextfieldView alloc] init];
        @weakify(self)
        _addGroupTextFieldView.sureAction = ^{
            @strongify(self)
            [self initializeData];
        };
    }
    return _addGroupTextFieldView;
}

- (UIView *)middleView {
    if (_middleView == nil) {
        _middleView = [[UIView alloc] init];
    }
    return _middleView;
}

- (UILabel *)groupLabel {
    if (_groupLabel == nil) {
        _groupLabel = [[UILabel alloc] init];
        _groupLabel.textColor = [QMUITheme textColorLevel3];
        _groupLabel.font = [UIFont systemFontOfSize:14];
        _groupLabel.text = [YXLanguageUtility kLangWithKey:@"my_stock_group"];
    }
    return _groupLabel;
}


- (YXEditGroupBottomView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[YXEditGroupBottomView alloc] init];
        @weakify(self)
        _bottomView.onClickAdd = ^{
            @strongify(self)
            [self addButtonAction];
        };
    }
    return _bottomView;
}


- (UIButton *)closeButton {
    if (_closeButton == nil) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"group_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (YYLabel *)stockLabel {
    if (_stockLabel == nil) {
        _stockLabel = [[YYLabel alloc] init];
        UIFont *font = [UIFont systemFontOfSize:16];
        
        if (self.settingType == YXGroupSettingTypeModify) {
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
            id<YXSecuIDProtocol> secuID = [self.secus firstObject];
            UIImage *icon = [UIImage imageNamed:secuID.market];
            CGSize iconSize = CGSizeMake(icon.size.width + 5 * 2, 20);
            NSMutableAttributedString *iconAttachment = [NSMutableAttributedString yy_attachmentStringWithContent:icon contentMode:UIViewContentModeCenter attachmentSize:iconSize alignToFont:font alignment:YYTextVerticalAlignmentCenter];
            
            [text appendAttributedString: iconAttachment];
            
            NSMutableAttributedString *name = [[NSMutableAttributedString alloc] initWithString:_secuName];
            name.yy_font = font;
            name.yy_color = [QMUITheme textColorLevel1];
            [text appendAttributedString:name];
            
            UILabel *symbolLabel = [[UILabel alloc] init];
            symbolLabel.textColor = [QMUITheme textColorLevel3];
            symbolLabel.text = [NSString stringWithFormat:@"%@.%@", secuID.symbol, secuID.market.uppercaseString];
            symbolLabel.font = [UIFont systemFontOfSize:12];
            symbolLabel.textAlignment = NSTextAlignmentCenter;
            [symbolLabel sizeToFit];
            symbolLabel.bounds = CGRectMake(0, 0, symbolLabel.bounds.size.width + 4 * 2, 20);
            NSMutableAttributedString *codeAttachment = [NSMutableAttributedString yy_attachmentStringWithContent:symbolLabel contentMode:UIViewContentModeCenter attachmentSize:symbolLabel.bounds.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
            [text appendAttributedString: codeAttachment];
            _stockLabel.attributedText = text;
            
            [_stockLabel sizeToFit];
        }else {
            _stockLabel.text = [YXLanguageUtility kLangWithKey:@"add_to_group"];
            _stockLabel.font = font;
            _stockLabel.textColor = [QMUITheme textColorLevel1];
        }
        
    }
    return _stockLabel;
}

- (UIView *)topView {
    if (_topView == nil) {
        _topView = [[UIView alloc] init];
    }
    return _topView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = 52;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//.none
        _tableView.allowsSelectionDuringEditing = true;
        [_tableView registerClass:[YXChangeGroupCell class] forCellReuseIdentifier:NSStringFromClass([YXChangeGroupCell class])];
    }
    
    return _tableView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
