//
//  OSSVCategoryFiltersView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/16.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategoryFiltersView.h"
#import "OSSVCategoryFiltersHeadView.h"
#import "OSSVCategoryFiltersCell.h"

#import "OSSVCategoryFiltersModel.h"
#import "OSSVCategroySubsFilterModel.h"
#import "RateModel.h"

static CGFloat const kCategoryRefineAnimatonTime = 0.25f;
static NSString *const khideRefineInfoViewAnimationIdentifier = @"khideRefineInfoViewAnimationIdentifier";
static NSString *const kshowRefineInfoViewAnimationIdentifier = @"kshowRefineInfoViewAnimationIdentifier";

#define kFilterCellIdentifer   @"kFilterCellIdentifer"
#define kSelftTag              10000
@interface OSSVCategoryFiltersView () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate,CAAnimationDelegate> {
    CGFloat _bottomHeight;
    UIView *_priceHeaderView;
    NSString *_filterItemIDs;
    NSString *_minPrice;
    NSString *_maxPrice;
}

@property (nonatomic, strong) UIView      *mainView;
@property (nonatomic, strong) UITableView *filterTableView;
@property (nonatomic, strong) UIButton    *resetButton;
@property (nonatomic, strong) UIButton    *sureButton;

@property (nonatomic, strong) UILabel     *priceHeaderTitleLabel;
@property (nonatomic, strong) UITextField *minPriceTextField;
@property (nonatomic, strong) UITextField *maxPriceTextField;

@property (nonatomic, strong) NSArray *filterItems;
@property (nonatomic, strong) NSMutableArray *filterHeaderViewArray;  // 头部选项

@property (nonatomic, strong) CABasicAnimation          *showRefineInfoViewAnimation;
@property (nonatomic, strong) CABasicAnimation          *hideRefineInfoViewAnimation;

@end

@implementation OSSVCategoryFiltersView


#pragma mark - public method


- (void)show
{
    if (!self.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }
    self.hidden = NO;
//    [UIView animateWithDuration:0.3 animations:^{
//        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
//
//        [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
////            make.width.mas_equalTo(_mainViewWidth);
//            make.trailing.mas_equalTo(self.mas_trailing);
//        }];
//        [self layoutIfNeeded];
//    }];
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:kCategoryRefineAnimatonTime animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    }];
    
    [self.mainView.layer addAnimation:self.showRefineInfoViewAnimation forKey:kshowRefineInfoViewAnimationIdentifier];
}

- (void)dismiss
{
//    [UIView animateWithDuration:0.3 animations:^{
//        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
//        [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
////            make.width.mas_equalTo(0.0);
//            make.trailing.mas_equalTo(self.mas_trailing).offset(_mainViewWidth);
//
//        }];
//        [self layoutIfNeeded];
//    } completion:^(BOOL finished) {
//        [self.mainView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.trailing.mas_equalTo(self.mas_trailing).offset(_mainViewWidth);
//        }];
//        [self removeFromSuperview];
//    }];
    
    [UIView animateWithDuration:kCategoryRefineAnimatonTime animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    }];
    [self.mainView.layer addAnimation:self.hideRefineInfoViewAnimation forKey:khideRefineInfoViewAnimationIdentifier];
    
    
}

- (void)configFilterItems:(NSArray *)filterItems
{
    self.filterItems = filterItems;
    [self.filterTableView reloadData];
}


- (NSString *)filterPriceCondition {
    NSString *price = @"";
    if (self.minPriceTextField.text.length > 0 || [self.maxPriceTextField.text length] > 0) {
        price = [NSString stringWithFormat:@"%@-%@", [self minPrice], [self maxPrice]];
    }
    return  price;
}

- (NSString *)minPrice
{
    NSString *price = self.minPriceTextField.text;
    if ([self.maxPriceTextField.text length] > 0)
    {
        NSInteger minPrice = [self.minPriceTextField.text integerValue];
        NSInteger maxPrice = [self.maxPriceTextField.text integerValue];
        price = maxPrice > minPrice ? self.minPriceTextField.text : self.maxPriceTextField.text;
    }
    _minPrice = price;
    NSString *USDPrice = [ExchangeManager transforUSD_Price:price];
    return self.minPriceTextField.text.length > 0 ? USDPrice : @"0";
}

- (NSString *)maxPrice
{
    NSString *price = self.maxPriceTextField.text;
    if ([self.minPriceTextField.text length] > 0
        && [self.maxPriceTextField.text length] > 0)
    {
        NSInteger minPrice = [self.minPriceTextField.text integerValue];
        NSInteger maxPrice = [self.maxPriceTextField.text integerValue];
        price = maxPrice > minPrice ? self.maxPriceTextField.text : self.minPriceTextField.text;
    }
    _maxPrice = price;
    NSString *USDPrice = [ExchangeManager transforUSD_Price:price];
    return self.maxPriceTextField.text.length > 0 ? USDPrice : @"max";
}

- (NSDictionary *)filterItemIDs
{
    NSMutableDictionary *filterItemDict = [[NSMutableDictionary alloc] init];
    for (OSSVCategoryFiltersModel *filterModel in self.filterItems)
    {
        NSMutableString *contentString = [NSMutableString new];
        BOOL isFirstIn = YES;
        for (OSSVCategroySubsFilterModel *subFilterModel in filterModel.subItemValues)
        {
            if (subFilterModel.isSelected)
            {
                if (!isFirstIn)
                {
                    [contentString appendString:@","];
                }
                isFirstIn = NO;
                [contentString appendString:[NSString stringWithFormat:@"%ld", (long)subFilterModel.searchValueID]];
            }
        }
        if (contentString.length > 0)
        {
            [filterItemDict setValue:contentString forKey:[NSString stringWithFormat:@"%ld", (long)filterModel.searchAttrID]];
        }
    }
    return filterItemDict;
}

- (BOOL)isFiltered
{
    return (self.minPriceTextField.text.length > 0
            || self.maxPriceTextField.text.length > 0
            || [self filterItemIDs].count > 0);
}


#pragma mark -

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        self.tag = kSelftTag;
        _bottomHeight = 48.0f;
        self.filterHeaderViewArray = [NSMutableArray new];
        [self setupView];
        [self subViewLayout];
        [self addTapGesture];
        
        if (@available(iOS 13.0, *)) {
            self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        }
    }
    return self;
}

#pragma mark - UITabelViewDelegate/UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 + self.filterItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section != 0) {
        OSSVCategoryFiltersModel *filterModel = self.filterItems[section - 1];
        if (self.filterHeaderViewArray.count >= section) {
            OSSVCategoryFiltersHeadView *filterHeaderView = self.filterHeaderViewArray[section - 1];
            return filterHeaderView.isShow ? filterModel.subItemValues.count : 0;
        } else {
            return 0;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 78.0f : 42.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVCategoryFiltersCell *cell      = [tableView dequeueReusableCellWithIdentifier:kFilterCellIdentifer];
    OSSVCategoryFiltersModel *filterModel       = self.filterItems[indexPath.section - 1];
    OSSVCategroySubsFilterModel *subFilterModel = filterModel.subItemValues[indexPath.row];
    cell.isSelected                        = subFilterModel.isSelected;
    NSString *itemTitle                    = subFilterModel.searchValue;
    [cell configWithTitle:itemTitle];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            return [self priceHeaderView];
            break;
        }
        default:
        {
            return [self filterHeaderViewWithSection:section];
            break;
        }
    }
    return [UIView new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger realSection = indexPath.section - 1;
    if ([self is5SelectedItemWidthIndexPath:indexPath])
    {
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"category_filter_limit_tip", nil)];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    OSSVCategoryFiltersModel *filteModel = [self.filterItems objectAtIndex:realSection];
    OSSVCategroySubsFilterModel *subFilterModel = [filteModel.subItemValues objectAtIndex:indexPath.row];
    subFilterModel.isSelected = !subFilterModel.isSelected;
    
    [self hiddenKeyBoard];
    [self reloadSection:indexPath.section];
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view.tag != self.tag)
    {
        return NO;
    }
    return YES;
}

#pragma mark - user event

- (void)didTouch:(UITapGestureRecognizer *)tap
{
    [self dismiss];
    [self hiddenKeyBoard];
}

- (void)resetAction:(UIButton *)btn
{
    if (self.resetFilter)
    {
        [self resetValues];
        [self.filterTableView reloadData];
        self.resetFilter();
    }
}

- (void)applyAction:(UIButton *)btn
{
    if (self.applyFilter)
    {
        self.applyFilter();
        [self dismiss];
    }
}


#pragma mark - private method


- (void)addTapGesture {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    tapGesture.delegate = self;
    [tapGesture addTarget:self action:@selector(didTouch:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)setupView {
    [self addSubview:self.mainView];
    [self.mainView addSubview:self.filterTableView];
    [self.mainView addSubview:self.resetButton];
    [self.mainView addSubview:self.sureButton];
}

- (void)subViewLayout {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.bottom.mas_equalTo(self);
        make.leading.mas_equalTo(self.mas_leading).offset(75);
    }];
    
    [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mainView);
        make.bottom.mas_equalTo(self.mainView);
        make.height.mas_equalTo(_bottomHeight);
        make.width.mas_equalTo((SCREEN_WIDTH - 75) / 2);
    }];
    UIView *resetLineView  = [[UIView alloc] init];
    resetLineView.backgroundColor = OSSVThemesColors.col_EBEBEB;
    [_resetButton addSubview:resetLineView];
    [resetLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.resetButton);
        make.height.mas_equalTo(1.0);
    }];
    
    [self.sureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.resetButton.mas_trailing);
        make.bottom.mas_equalTo(self.mainView);
        make.height.mas_equalTo(_bottomHeight);
        make.width.mas_equalTo((SCREEN_WIDTH - 75) / 2);
    }];
    
    [self.filterTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.mainView);
        make.top.mas_equalTo(self.mainView.mas_top).offset(kSCREEN_BAR_HEIGHT);
        make.bottom.mas_equalTo(self.resetButton.mas_top);
    }];
    [self layoutIfNeeded];
}

- (void)hiddenKeyBoard
{
    [self.minPriceTextField resignFirstResponder];
    [self.maxPriceTextField resignFirstResponder];
}

- (void)resetValues
{
    self.minPriceTextField.text = @"";
    self.maxPriceTextField.text = @"";
    _maxPrice = @"";
    _minPrice = @"";
    for (OSSVCategoryFiltersHeadView *filterHeaderView in self.filterHeaderViewArray)
    {
        filterHeaderView.isShow = NO;
    }
    for (OSSVCategoryFiltersModel *filterModel in self.filterItems)
    {
        for (OSSVCategroySubsFilterModel *subFilterModel in filterModel.subItemValues)
        {
            subFilterModel.isSelected = NO;
        }
    }
}

- (UIView *)priceHeaderView {
    if (!_priceHeaderView)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.filterTableView.width, 78.0)];
        headerView.backgroundColor = [UIColor whiteColor];
        
        // 添加视图
        [headerView addSubview:self.priceHeaderTitleLabel];
        [headerView addSubview:self.minPriceTextField];
        [headerView addSubview:self.maxPriceTextField];
        
        UIView *priceLineView = [[UIView alloc] init];
        priceLineView.backgroundColor = OSSVThemesColors.col_333333;
        [headerView addSubview:priceLineView];
        
        UIView *lineView  = [[UIView alloc] init];
        lineView.backgroundColor = OSSVThemesColors.col_EBEBEB;
        [headerView addSubview:lineView];
        
        // 布局
        [priceLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(10.0f);
            make.height.mas_equalTo(1.0f);
            make.centerX.mas_equalTo(headerView.mas_centerX);
            make.bottom.mas_equalTo(headerView).offset(-23.0f);
        }];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(headerView);
            make.height.mas_equalTo(1.0f);
        }];
        
        [self.minPriceTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(headerView).offset(-8.0f);
            make.leading.mas_equalTo(headerView).offset(15.0f);
            make.height.mas_equalTo(30.0f);
            make.trailing.mas_equalTo(priceLineView.mas_leading).offset(-10.0f);
        }];

        [self.maxPriceTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(headerView).offset(-8.0f);
            make.trailing.mas_equalTo(headerView).offset(-15.0f);
            make.height.mas_equalTo(30.0f);
            make.leading.mas_equalTo(priceLineView.mas_trailing).offset(10.0f);
        }];
        
        [self.priceHeaderTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(headerView).offset(15.0);
            make.top.mas_equalTo(headerView).offset(14.0);
            make.bottom.mas_equalTo(self.minPriceTextField.mas_top).offset(-10.0f);
        }];
        
        // 赋值
        RateModel *rateModel = [ExchangeManager localCurrency];
        NSString *titleString = [NSString stringWithFormat:STLLocalizedString_(@"category_filter_price_range", nil), rateModel.symbol,  [ExchangeManager localTypeCurrency]];
        self.priceHeaderTitleLabel.text = titleString;
        
        _priceHeaderView = headerView;
    }
    self.minPriceTextField.text     = _minPrice;
    self.maxPriceTextField.text     = _maxPrice;
    return _priceHeaderView;
}

- (OSSVCategoryFiltersHeadView *)filterHeaderViewWithSection:(NSInteger)section {
    OSSVCategoryFiltersHeadView *filterHeaderView;
    NSInteger realSection = section - 1;
    if (self.filterHeaderViewArray.count >= section)
    {
        filterHeaderView = self.filterHeaderViewArray[realSection];
    }
    else
    {
        filterHeaderView = [[OSSVCategoryFiltersHeadView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.filterTableView.width, 42.0)];
        [self.filterHeaderViewArray addObject:filterHeaderView];
    }
    OSSVCategoryFiltersModel *filterModel = [self.filterItems objectAtIndex:realSection];
    [filterHeaderView setTitle:filterModel.searchAttrName];
    
    NSString *contentString = [self headerContentWithSection:realSection];
    [filterHeaderView setContent:contentString];
    
    @weakify(self)
    filterHeaderView.unfoldAction = ^{
        @strongify(self)
        [self hiddenKeyBoard];
        [self reloadSection:section];
    };
    
    return filterHeaderView;
}

- (void)reloadSection:(NSInteger)section
{
//    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:section];
//    [self.filterTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    [self.filterTableView reloadData];
}

- (NSString *)headerContentWithSection:(NSInteger)section
{
    NSMutableString *contentString = [NSMutableString new];
    
    OSSVCategoryFiltersModel *filterModel = [self.filterItems objectAtIndex:section];
    BOOL isFirstIn = YES;
    for (OSSVCategroySubsFilterModel *subFilterModel in filterModel.subItemValues)
    {
        if (subFilterModel.isSelected)
        {
            if (!isFirstIn)
            {
                [contentString appendString:@","];
            }
            isFirstIn = NO;
            [contentString appendString:subFilterModel.searchValue];
        }
    }
    
    return contentString;
}

- (BOOL)is5SelectedItemWidthIndexPath:(NSIndexPath *)indexPath
{
    NSInteger count = 0;
    OSSVCategoryFiltersModel *filterModel = [self.filterItems objectAtIndex:indexPath.section - 1];
    for (OSSVCategroySubsFilterModel *subFilterModel in filterModel.subItemValues)
    {
        if (subFilterModel.isSelected)
        {
            count++;
        }
    }
    
    // 如果当前选项已被选中，将被取消选择
    OSSVCategroySubsFilterModel *currentSubModel = [filterModel.subItemValues objectAtIndex:indexPath.row];
    if (currentSubModel.isSelected)
    {
        count--;
    }
    return count >= 5;
}


#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.hideRefineViewCompletionHandler) {
        self.hideRefineViewCompletionHandler();
    }
    self.hidden = YES;
    [self removeFromSuperview];
}


#pragma mark - getter/setter


- (UIView *)mainView{
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectZero];
        _mainView.backgroundColor = OSSVThemesColors.stlWhiteColor;
    }
    return _mainView;
}

- (UITableView *)filterTableView {
    if (!_filterTableView) {
        _filterTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _filterTableView.delegate             = self;
        _filterTableView.dataSource           = self;
        _filterTableView.showsVerticalScrollIndicator = NO;
        _filterTableView.tableFooterView      = [UIView new];
        _filterTableView.separatorStyle       = UITableViewCellSeparatorStyleNone;
        
        [_filterTableView registerClass:[OSSVCategoryFiltersCell class] forCellReuseIdentifier:kFilterCellIdentifer];
        _filterTableView.backgroundColor = OSSVThemesColors.stlWhiteColor;
    }
    return _filterTableView;
}

- (UIButton *)resetButton
{
    if (!_resetButton)
    {
        _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _resetButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_resetButton setBackgroundImage:[UIImage yy_imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_resetButton setTitleColor:OSSVThemesColors.col_333333 forState:UIControlStateNormal];
        [_resetButton setTitle:STLLocalizedString_(@"category_filter_reset", nil) forState:UIControlStateNormal];
        [_resetButton addTarget:self action:@selector(resetAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetButton;
}

- (UIButton *)sureButton
{
    if (!_sureButton)
    {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [_sureButton setBackgroundImage:[UIImage yy_imageWithColor:[OSSVThemesColors col_262626]] forState:UIControlStateNormal];
        [_sureButton setTitleColor:OSSVThemesColors.col_FFFFFF forState:UIControlStateNormal];
        [_sureButton setTitle:STLLocalizedString_(@"category_filter_apply", nil) forState:UIControlStateNormal];
        [_sureButton addTarget:self action:@selector(applyAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

- (UILabel *)priceHeaderTitleLabel
{
    if (!_priceHeaderTitleLabel)
    {
        _priceHeaderTitleLabel           = [[UILabel alloc] init];
        _priceHeaderTitleLabel.font      = [UIFont systemFontOfSize:14.0];
        _priceHeaderTitleLabel.textColor = OSSVThemesColors.col_333333;
    }
    return _priceHeaderTitleLabel;
}

- (UITextField *)minPriceTextField
{
    if (!_minPriceTextField)
    {
        _minPriceTextField = [[UITextField alloc] init];
        _minPriceTextField.layer.cornerRadius = 3.0f;
        _minPriceTextField.layer.borderColor  = OSSVThemesColors.col_EBEBEB.CGColor;
        _minPriceTextField.layer.borderWidth  = 1.0;
        _minPriceTextField.placeholder        = STLLocalizedString_(@"category_filter_price_min", nil);
        _minPriceTextField.textColor          = OSSVThemesColors.col_333333;
        _minPriceTextField.font               = [UIFont systemFontOfSize:14.0];
        _minPriceTextField.keyboardType       = UIKeyboardTypeASCIICapableNumberPad;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 30.0)];
        _minPriceTextField.leftView = leftView;
        _minPriceTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _minPriceTextField;
}

- (UITextField *)maxPriceTextField
{
    if (!_maxPriceTextField)
    {
        _maxPriceTextField = [[UITextField alloc] init];
        _maxPriceTextField.layer.cornerRadius = 3.0f;
        _maxPriceTextField.layer.borderColor  = OSSVThemesColors.col_EBEBEB.CGColor;
        _maxPriceTextField.layer.borderWidth  = 1.0;
        _maxPriceTextField.placeholder        = STLLocalizedString_(@"category_filter_price_max", nil);
        _maxPriceTextField.textColor          = OSSVThemesColors.col_333333;
        _maxPriceTextField.font               = [UIFont systemFontOfSize:14.0];
        _maxPriceTextField.keyboardType       = UIKeyboardTypeASCIICapableNumberPad;
        
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 30.0)];
        _maxPriceTextField.leftView = leftView;
        _maxPriceTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _maxPriceTextField;
}


- (CABasicAnimation *)showRefineInfoViewAnimation {
    if (!_showRefineInfoViewAnimation) {
        _showRefineInfoViewAnimation = [CABasicAnimation animation];
        _showRefineInfoViewAnimation.keyPath = @"position.x";
        _showRefineInfoViewAnimation.fromValue = [OSSVSystemsConfigsUtils isRightToLeftShow] ? @(-SCREEN_WIDTH * 0.5) : @(SCREEN_WIDTH * 1.5);
        _showRefineInfoViewAnimation.toValue = [OSSVSystemsConfigsUtils isRightToLeftShow] ?  @((SCREEN_WIDTH-75) / 2) : @((SCREEN_WIDTH-75) / 2 + 75);
        _showRefineInfoViewAnimation.duration = kCategoryRefineAnimatonTime;
        _showRefineInfoViewAnimation.removedOnCompletion = NO;
        _showRefineInfoViewAnimation.fillMode = kCAFillModeForwards;
    }
    return _showRefineInfoViewAnimation;
}

- (CABasicAnimation *)hideRefineInfoViewAnimation {
    if (!_hideRefineInfoViewAnimation) {
        _hideRefineInfoViewAnimation = [CABasicAnimation animation];
        _hideRefineInfoViewAnimation.keyPath = @"position.x";
        _hideRefineInfoViewAnimation.fromValue = [OSSVSystemsConfigsUtils isRightToLeftShow] ? @((SCREEN_WIDTH-75) / 2) : @((SCREEN_WIDTH-75) / 2 + 75);
        _hideRefineInfoViewAnimation.toValue = [OSSVSystemsConfigsUtils isRightToLeftShow] ? @(-SCREEN_WIDTH * 0.5) : @(SCREEN_WIDTH * 1.5);
        _hideRefineInfoViewAnimation.duration = kCategoryRefineAnimatonTime;
        _hideRefineInfoViewAnimation.removedOnCompletion = NO;
        _hideRefineInfoViewAnimation.fillMode = kCAFillModeForwards;
        _hideRefineInfoViewAnimation.delegate = self;
    }
    return _hideRefineInfoViewAnimation;
}

@end
