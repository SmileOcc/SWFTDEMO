//
//  OSSVCategoryRefinesNewView.m
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategoryRefinesNewView.h"
#import "OSSVCategoryRefinessSpeciallCCell.h"
#import "OSSVCategoryRefinesColorsCCell.h"
#import "OSSVCategoryRefinesNormalsCCell.h"
#import "OSSVCategoryRefinesPriceCCell.h"
#import "OSSVCategoryRefineHeadCollectiReusableView.h"
#import "UICollectionViewLeftAlignedLayout.h"

#import "OSSVCategoryFiltersModel.h"
#import "RateModel.h"
static CGFloat const kCategoryRefineNewAnimatonTime = 0.25f;

static NSString *const khideCategoryRefineNewAnimationIdentifier = @"khideCategoryRefineNewAnimationIdentifier";
static NSString *const kshowCategoryRefineNewAnimationIdentifier = @"kshowCategoryRefineNewAnimationIdentifier";


@interface OSSVCategoryRefinesNewView()
<UICollectionViewDelegate,UICollectionViewDataSource,CAAnimationDelegate>

@property (nonatomic, strong) UIView       *backView;

@property (nonatomic, assign) BOOL         isFirstShow;

@property (nonatomic, assign) CGFloat      mainWidth;


@property (nonatomic, strong) CABasicAnimation          *showRefineInfoViewAnimation;
@property (nonatomic, strong) CABasicAnimation          *hideRefineInfoViewAnimation;

@end

@implementation OSSVCategoryRefinesNewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.isFirstShow = YES;
        self.mainWidth = SCREEN_WIDTH - 75;
        [self stlInitView];
        [self stlAutoLayoutView];
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        [self.backView addGestureRecognizer:tap];
    }
    return self;
}

- (void)stlInitView {
    self.backgroundColor = [OSSVThemesColors col_000000:0.4];
    
    [self addSubview:self.backView];
    [self addSubview:self.mainView];
    [self.mainView addSubview:self.bottomToolView];
    [self.mainView addSubview:self.collectView];
    
    [self.bottomToolView addSubview:self.cancelButton];
    [self.bottomToolView addSubview:self.confirmButton];
    [self.bottomToolView addSubview:self.lineView];
}

- (void)stlAutoLayoutView {
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.leading.mas_equalTo(self);
        make.width.mas_equalTo(75);
    }];
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.mas_equalTo(self);
        make.width.mas_equalTo(self.mainWidth);
    }];
    
    [self.bottomToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mainView.mas_bottom).offset(-kIPHONEX_BOTTOM);
        make.leading.trailing.mas_equalTo(self.mainView);
        make.height.mas_equalTo(52);
    }];
    
    [self.collectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.mainView);
        make.top.mas_equalTo(self.mainView.mas_top).offset(kSCREEN_BAR_HEIGHT);
        make.bottom.mas_equalTo(self.bottomToolView.mas_top);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bottomToolView.mas_leading).offset(12);
        make.top.mas_equalTo(self.bottomToolView.mas_top).offset(8);
        make.bottom.mas_equalTo(self.bottomToolView.mas_bottom).offset(-8);
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.bottomToolView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.bottomToolView.mas_top).offset(8);
        make.bottom.mas_equalTo(self.bottomToolView.mas_bottom).offset(-8);
        make.leading.mas_equalTo(self.cancelButton.mas_trailing).offset(12);
        make.width.mas_equalTo(self.cancelButton.mas_width);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.bottomToolView);
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - Public Methods
- (void)showRefineInfoViewWithAnimation:(BOOL)animation {
    if (!animation) {
        return ;
    }
    
    self.hidden = NO;
    self.backgroundColor = [OSSVThemesColors col_000000:0];
    [UIView animateWithDuration:kCategoryRefineNewAnimatonTime animations:^{
        self.backgroundColor = [OSSVThemesColors col_000000:0.4];
    }];

    self.mainView.hidden = NO;
    [self.mainView.layer addAnimation:self.showRefineInfoViewAnimation forKey:kshowCategoryRefineNewAnimationIdentifier];

}

- (void)hideRefineInfoViewViewWithAnimation:(BOOL)animation {
    if (!animation) {
        self.hidden = YES;
        return ;
    }
    
    [UIView animateWithDuration:kCategoryRefineNewAnimatonTime animations:^{
        self.backgroundColor = [OSSVThemesColors col_000000:0];
    }];
    
    [self.mainView.layer addAnimation:self.hideRefineInfoViewAnimation forKey:khideCategoryRefineNewAnimationIdentifier];
}


#pragma mark - Action

- (void)actionTap:(UITapGestureRecognizer *)tap {
    [self hideRefineInfoViewViewWithAnimation:YES];
}

- (void)actionCancel:(UIButton *)sender {
    
    if(STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
        [self.categoryRefineDataArray enumerateObjectsUsingBlock:^(OSSVCategorysFiltersNewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (STLJudgeNSArray(obj.values)) {
                [obj.values enumerateObjectsUsingBlock:^(STLCategoryFilterValueModel * _Nonnull itemObj, NSUInteger idx, BOOL * _Nonnull stop) {
                    itemObj.tempSelected = NO;
                    itemObj.editMaxPrice = @"";
                    itemObj.editMinPrice = @"";
                    itemObj.tempEditMinPrice = @"";
                    itemObj.tempEditMaxPrice = @"";
//                    itemObj.editMax = @"";
//                    itemObj.editMin = @"";
//                    itemObj.localCurrencyMin = @"";
//                    itemObj.localCurrencyMax = @"";
                }];
            }
        }];
    }
    
    [self.collectView reloadData];
    
    if (self.clearConditionBlock) {
        self.clearConditionBlock();
    }
    
    //
    
    if (self.confirmBlock) {
        self.confirmBlock(@[], @[],@{});
    }
}

- (void)actionConfirm:(UIButton *)sender {
    [self endEditing:YES];
    
    /// 统计相关
    __block NSMutableArray *refineTypeArrays = [[NSMutableArray alloc] init];
    __block NSMutableDictionary *refineTypeDic = [[NSMutableDictionary alloc] init];
    
    /// 原生专题选择
    //__block NSMutableArray *selectNativeArrays = [[NSMutableArray alloc] init];

    /// 分类来源选择
    __block NSMutableArray *selectCategoryArrays = [[NSMutableArray alloc] init];
    __block BOOL isNeedRelead = NO;
    __block NSString *minPriceString = @"";
    __block NSString *maxPriceString = @"";
    __block NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    __block NSMutableArray *sizeArray = [[NSMutableArray alloc] init];
    __block NSString *sizeStr = @"";
    __block NSString *colorStr = @"";


    if(STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
        [self.categoryRefineDataArray enumerateObjectsUsingBlock:^(OSSVCategorysFiltersNewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *af_refineKey = STLToString(obj.name);
            NSMutableArray *subRefineKeys = [[NSMutableArray alloc] init];
            
            if ([obj.key isEqualToString:@"price"]) {
                STLCategoryFilterValueModel *itemObj = obj.values.firstObject;
                
                if ([itemObj.tempEditMinPrice integerValue] > [itemObj.tempEditMaxPrice integerValue]) {
                    itemObj.editMinPrice = itemObj.tempEditMaxPrice;
                    itemObj.editMaxPrice = itemObj.tempEditMinPrice;
                    
                    itemObj.tempEditMinPrice = itemObj.editMinPrice;
                    itemObj.tempEditMaxPrice = itemObj.editMaxPrice;
                    
                    isNeedRelead = YES;
                } else {
                    itemObj.editMinPrice = itemObj.tempEditMinPrice;
                    itemObj.editMaxPrice = itemObj.tempEditMaxPrice;
                }
                minPriceString = STLToString(itemObj.editMinPrice);
                maxPriceString = STLToString(itemObj.editMaxPrice);
                [selectCategoryArrays addObject:itemObj];
                
            } else if (STLJudgeNSArray(obj.values)) {
                [obj.values enumerateObjectsUsingBlock:^(STLCategoryFilterValueModel * _Nonnull itemObj, NSUInteger idx, BOOL * _Nonnull stop) {
                    itemObj.isChecked = itemObj.tempSelected;
                    if (itemObj.tempSelected) {
                        [selectCategoryArrays addObject:itemObj];
                        if(!STLIsEmptyString(af_refineKey)) {
                            [subRefineKeys addObject:STLToString(itemObj.value)];
                        }
                     
                        if ([obj.key isEqualToString:@"color"]) {
                            [colorArray addObject:STLToString(itemObj.idx)];
                            colorStr = [NSString stringWithFormat:@"%@,",STLToString(itemObj.idx)];
                            
                        } else if([obj.key isEqualToString:@"size"]) {
                            [sizeArray addObject:STLToString(itemObj.idx)];
                            sizeStr = [NSString stringWithFormat:@"%@,",STLToString(itemObj.idx)];
                        }
                    }
                }];
            }
            
            NSString *subRefinekeyString = [subRefineKeys componentsJoinedByString:@","];
            if(!STLIsEmptyString(subRefinekeyString)) {
                [refineTypeArrays addObject:[NSString stringWithFormat:@"%@:\"%@",subRefineKeys,subRefinekeyString]];
                [refineTypeDic setObject:subRefinekeyString forKey:af_refineKey];
            }
        }];
    }

    NSString *pageName = [UIViewController currentTopViewControllerPageName];
    NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                 @"price_max":maxPriceString,
                                 @"price_min":minPriceString,
                                 @"size " :sizeStr,
                                 @"color ":colorStr,
                                 @"url":STLToString(self.sourceKey),
    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"ClickFilter" parameters:sensorsDic];
    /*GA埋点**/
    NSString *filterSting = [NSString stringWithFormat:@"size:color_%@+:+%@", sizeStr, colorStr];
    [OSSVAnalyticsTool analyticsGAEventWithName:@"product_filter" parameters:@{
        @"screen_group" : [NSString stringWithFormat:@"ProductList_%@", STLToString(pageName)],
        @"filter"       :filterSting
    }];
    
    if (self.confirmBlock) {
    
        if(STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
            self.confirmBlock(@[], selectCategoryArrays,refineTypeDic);
        } else {
            self.confirmBlock(@[], @[],@{});
        }
    }
    
    [self hideRefineInfoViewViewWithAnimation:YES];
    if (isNeedRelead) {
        [self.collectView reloadData];
    }
    
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self sectionNumberCounts];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self nembersForSectionCounts:section];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
        if (self.categoryRefineDataArray.count > indexPath.section) {

            OSSVCategorysFiltersNewModel *refineModel = self.categoryRefineDataArray[indexPath.section];
            STLCategoryFilterValueModel *cateItemModel = [self categoryItemModelForIndexPath:indexPath];
            CategoryRefineCellType cellType = [self refineCellTypeNative:nil categoryModel:refineModel];
                        

            
            if (cellType == CategoryRefineCellTypeSpecial) {

               OSSVCategoryRefinessSpeciallCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVCategoryRefinessSpeciallCCell.class) forIndexPath:indexPath];
                [cell hightLightState:cateItemModel.tempSelected];
                cell.titleLabel.text = [self titleForIndexPath:indexPath];
                
                return cell;
            }
            
            if (cellType == CategoryRefineCellTypeColor) {
                
                OSSVCategoryRefinesColorsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVCategoryRefinesColorsCCell.class) forIndexPath:indexPath];
                cell.model = cateItemModel;
               

                return cell;
            }
            
            if (cellType == CategoryRefineCellTypePrice) {

                OSSVCategoryRefinesPriceCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVCategoryRefinesPriceCCell.class) forIndexPath:indexPath];

//                //货币转换
//                NSString *placePrice_min = @"";
//                NSString *placePrice_max = @"";
//                NSString *editMinString = @"";
//                NSString *editMaxString = @"";
//
//                if (cateItemModel.max >= 0) {
//                    placePrice_min = [ExchangeManager transPurePriceforPriceOnlyNumber:[NSString stringWithFormat:@"%li",(long)cateItemModel.min]];
//                    placePrice_max = [ExchangeManager transPurePriceforPriceOnlyNumber:[NSString stringWithFormat:@"%li",(long)cateItemModel.max]];
//                    placePrice_min = [NSString stringWithFormat:@"%.0f",floor([placePrice_min floatValue])];
//                    placePrice_max = [NSString stringWithFormat:@"%.0f",ceil([placePrice_max floatValue])];
//
//                }
//                if (!STLIsEmptyString(cateItemModel.editMin) && STLIsEmptyString(cateItemModel.localCurrencyMin)) {
//                    editMinString = [ExchangeManager transPurePriceforPriceOnlyNumber:cateItemModel.editMin];
//                    editMinString = [NSString stringWithFormat:@"%.0f",floor([editMinString floatValue])];
//                    cateItemModel.localCurrencyMin =  editMinString;
//
//                } else if(!STLIsEmptyString(cateItemModel.localCurrencyMin)) {
//                    editMinString = cateItemModel.localCurrencyMin;
//                }
//
//                if (!STLIsEmptyString(cateItemModel.editMax) && STLIsEmptyString(cateItemModel.localCurrencyMax)) {
//                    editMaxString = [ExchangeManager transPurePriceforPriceOnlyNumber:cateItemModel.editMax];
//                    editMaxString = [NSString stringWithFormat:@"%.0f",ceil([editMaxString floatValue])];
//                    cateItemModel.localCurrencyMax =  editMaxString;
//
//                } else if(!STLIsEmptyString(cateItemModel.localCurrencyMax)) {
//                    editMaxString = cateItemModel.localCurrencyMax;
//                }
//
//                [cell refinePriceMin:editMinString max:editMaxString];
//                [cell updatePlaceholder:placePrice_min max:placePrice_max];
//                [cell hightLightState:NO];

                [cell refinePriceMin:cateItemModel.tempEditMinPrice max:cateItemModel.tempEditMaxPrice];
                @weakify(self)
                cell.editBlock = ^(NSString *minString, NSString *maxString) {
                    @strongify(self)
                    [self handleEditPriceMin:minString max:maxString];
                };
                return cell;
            }
            
            OSSVCategoryRefinesNormalsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVCategoryRefinesNormalsCCell.class) forIndexPath:indexPath];
            cell.model = cateItemModel;
            return cell;
        }
    }
    
    OSSVCategoryRefinesNormalsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVCategoryRefinesNormalsCCell.class) forIndexPath:indexPath];
    [cell hightLightState:NO];
    cell.titleLabel.text = @"";
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    OSSVCategoryRefineHeadCollectiReusableView *headView = [OSSVCategoryRefineHeadCollectiReusableView headWithCollectionView:collectionView Kind:kind IndexPath:indexPath];
    headView.titleLabel.text = @"";
    
    @weakify(self)
    headView.tapBlock = ^{
        @strongify(self)
        [self endEditing:YES];
        
        if (STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > indexPath.section) {
            
            OSSVCategorysFiltersNewModel *refineListModel = self.categoryRefineDataArray[indexPath.section];
            refineListModel.isFirstShowLine = NO;
            
            if (![refineListModel.key isEqualToString:@"price"]) {
                refineListModel.isHeaderSelected = !refineListModel.isHeaderSelected;
                [self.collectView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];

            }
        }
        

    };
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] ) {

        if (STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > indexPath.section) {
            
            OSSVCategorysFiltersNewModel *refineListModel = self.categoryRefineDataArray[indexPath.section];
            [headView updateArrowDirection:refineListModel.isHeaderSelected];
            [headView updateCountsString:[self sectinSelectAllCounts:indexPath]];
            [headView hideArrow:NO];

//            NSString *title = [self firstCharactersCapitalized:STLToString(refineListModel.name)];//此处不用处理首字母大写
              NSString *title = STLToString(refineListModel.name);
            if ([refineListModel.key isEqualToString:@"price"]) {
                [headView hideArrow:YES];

                //本地货币金额符号
                RateModel *rateModel = [ExchangeManager localCurrency];
                NSString *titleString = [NSString stringWithFormat:STLLocalizedString_(@"category_filter_price_range", nil), [ExchangeManager localTypeCurrency],rateModel.symbol];
                
                if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                    titleString = [NSString stringWithFormat:STLLocalizedString_(@"category_filter_price_range", nil), rateModel.symbol,[ExchangeManager localTypeCurrency]];
                }
                headView.titleLabel.text = titleString;
            } else {
                headView.titleLabel.text = title;
            }
        }
    }
    
    return headView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > indexPath.section) {
        STLCategoryFilterValueModel *refineListModel = [self categoryItemModelForIndexPath:indexPath];
        return refineListModel.itemsSize;
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(SCREEN_WIDTH, 44);
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    OSSVCategoryRefinesBaseCCell *cell = (OSSVCategoryRefinesBaseCCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[OSSVCategoryRefinesBaseCCell class]]) {
        
        if (STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > indexPath.section) {
            
            OSSVCategorysFiltersNewModel *sectionItemModel = self.categoryRefineDataArray[indexPath.section];
            STLCategoryFilterValueModel *categoryItemModel = [self categoryItemModelForIndexPath:indexPath];
           
            if (categoryItemModel) {
                categoryItemModel.tempSelected = !categoryItemModel.tempSelected;
            }
            
            [cell hightLightState:categoryItemModel.tempSelected];
            sectionItemModel.isFirstShowLine = NO;
            
            // 未显示全部时：点击显示全部
            if (!sectionItemModel.isHeaderSelected) {
                sectionItemModel.isHeaderSelected = YES;
            }
            
            [self relaodCurerentSection:sectionItemModel indexPath:indexPath];
            
        }
    }
}

#pragma mark - 数据配置

- (NSInteger)sectionNumberCounts {
    
    if (STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
        //设置第一选中
        if (self.isFirstShow) {
            OSSVCategorysFiltersNewModel *refineListModel = self.categoryRefineDataArray[0];
            refineListModel.isHeaderSelected = YES;
            self.isFirstShow = NO;
        }
        return self.categoryRefineDataArray.count;
    }
    return 0;
}

- (NSInteger)nembersForSectionCounts:(NSInteger)section {
    

    if (STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > section) {
        OSSVCategorysFiltersNewModel *refineListModel = self.categoryRefineDataArray[section];
        
        if ([refineListModel.key isEqualToString:@"price"]) {
            return 1;
        }
        
        if (STLJudgeNSArray(refineListModel.values)) {
            
            if (refineListModel.isFirstShowLine) {
                return refineListModel.firstShowCounts > 0 ? refineListModel.firstShowCounts : refineListModel.values.count;
                
            } else if (refineListModel.isHeaderSelected) {
                return refineListModel.values.count;
            }
        }
    }
    return 0;
}

- (NSString *)titleForIndexPath:(NSIndexPath *)indexPath {


    STLCategoryFilterValueModel *categoryItemModel = [self categoryItemModelForIndexPath:indexPath];
    if (categoryItemModel) {
        return STLToString(categoryItemModel.editName);
    }
    
    return @"";
}

- (void)handleEditPriceMin:(NSString *)minString max:(NSString *)maxString {
    
    //本地货币金额符号
//    NSString *localTypeCurrency = [ExchangeManager localTypeCurrency];
//    NSString *usdMinString = minString;
//    NSString *usdMaxSting = maxString;
    
    /// 传给后台，美元
//    if (![localTypeCurrency isEqualToString:@"$"]) {
//
//        if (!STLIsEmptyString(minString)) {
//            usdMinString = [ExchangeManager transPurePriceForCurrencyPrice:minString sourceCurrency:localTypeCurrency purposeCurrency:@"$" priceType:PriceType_Normal isSpace:NO isAppendCurrency:NO];
//        }
//        if (!STLIsEmptyString(maxString)) {
//            usdMaxSting = [ExchangeManager transPurePriceForCurrencyPrice:maxString sourceCurrency:localTypeCurrency purposeCurrency:@"$" priceType:PriceType_Normal isSpace:NO isAppendCurrency:NO];
//        }
//    }
    
    if(STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
        [self.categoryRefineDataArray enumerateObjectsUsingBlock:^(OSSVCategorysFiltersNewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.key isEqualToString:@"price"]) {
                STLCategoryFilterValueModel *itemModel = obj.values.firstObject;
                itemModel.tempEditMinPrice = minString;
                itemModel.tempEditMaxPrice = maxString;
//                if (itemModel) {
//                    itemModel.editMin = STLToString(usdMinString);
//                    itemModel.editMax = STLToString(usdMaxSting);
//                    itemModel.isSelect = (!STLIsEmptyString(minString) && !STLIsEmptyString(maxString)) ? YES : NO;
//                    itemModel.localCurrencyMin = STLToString(minString);
//                    itemModel.localCurrencyMax = STLToString(maxString);
//                }
                *stop = YES;
            }
        }];
    }
}


- (CategoryRefineCellType)refineCellTypeNative:(OSSVCategorysFiltersNewModel *)nativeModel categoryModel:(OSSVCategorysFiltersNewModel *)categoryModel {
    
    CategoryRefineCellType cellType = CategoryRefineCellTypeNormal;
    
    if(categoryModel) {
        
        if ([categoryModel.key isEqualToString:@"size"]) {
            
        } else if([categoryModel.key isEqualToString:@"service"]) {
            cellType = CategoryRefineCellTypeSpecial;
        } else if([categoryModel.key isEqualToString:@"color"]) {
            cellType = CategoryRefineCellTypeColor;
        } else if([categoryModel.key isEqualToString:@"price"]) {
            cellType = CategoryRefineCellTypePrice;
        }
    }
    return cellType;
}

- (NSString *)colorForIndexPath:(NSIndexPath *)indexPath {
//    UIColor *color;
    NSString *colorString = @"#ffffff";

    STLCategoryFilterValueModel *categoryModel = [self categoryItemModelForIndexPath:indexPath];
    if (categoryModel.expand_value) {
        colorString = STLToString(categoryModel.expand_value.hex);
    }
    
//    if ([colorString hasPrefix:@"#"]) {
//        NSArray *colorArrays = [colorString componentsSeparatedByString:@"#"];
//        if (colorArrays.count > 1) {
//            NSString *colorStr = colorArrays[1];
//            color = [self colorWithHexString:colorStr];
//        }
//    }
//
//    if (!color) {
//        color = [OSSVThemesColors stlWhiteColor];
//    }
    return colorString;
}

- (UIColor *)colorWithHexString:(NSString *)stringToConvert {
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum])
        return nil;
    return STLCOLOR_HEXAlpha(hexNum, 1.0);
}

- (NSString *)sectinSelectAllCounts:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    __block NSString *countsString = @"";
    
    __block NSInteger count = 0;
    if (STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > section) {
        OSSVCategorysFiltersNewModel *refineListModel = self.categoryRefineDataArray[section];
        [refineListModel.values enumerateObjectsUsingBlock:^(STLCategoryFilterValueModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.tempSelected) {
                count++;
                if (STLIsEmptyString(countsString)) {
                    countsString = [NSString stringWithFormat:@"%@",obj.editName];
                } else {
                    countsString = [NSString stringWithFormat:@"%@,%@",countsString,obj.editName];
                }
            }
        }];
    }
    
//    if (count > 0) {
//        countsString = [NSString stringWithFormat:@"%li",(long)count];
//    }
    
    return countsString;
}

- (STLCategoryFilterValueModel *)categoryItemModelForIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    STLCategoryFilterValueModel *itemModel;
    
    if (STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > section) {
        OSSVCategorysFiltersNewModel *refineListModel = self.categoryRefineDataArray[section];
        if (STLJudgeNSArray(refineListModel.values) && refineListModel.values.count > row) {
            itemModel = refineListModel.values[row];
        }
    }
    return itemModel;
}

/**
 * 如果是从Deeplink进来需要选中指定的refine
 */
- (void)selectedCustomRefineByDeeplink:(NSString *)selectedCategorys
                              priceMax:(NSString *)priceMax
                              priceMin:(NSString *)priceMin
                              hasCheck:(void(^)(void))hasCheckBlock {
    
    NSArray *refineTypeArr = [STLToString(selectedCategorys) componentsSeparatedByString:@"~"];
    if (refineTypeArr.count == 0) {
        return;
    }
    @weakify(self)

    [refineTypeArr enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        [self matchingKey:obj];
    }];
    
    [self.collectView reloadData];
}

- (void)matchingKey:(NSString *)key{
    
    if (STLIsEmptyString(key)) {
        return;
    }
    
    if(STLJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
        /// 分类
        
        for (OSSVCategorysFiltersNewModel *itemModel in _categoryRefineDataArray) {
             for (STLCategoryFilterValueModel *subItemModel in itemModel.values) {
                 if ([subItemModel.idx isEqualToString:key]) {
                     itemModel.isHeaderSelected = YES;
                     subItemModel.isChecked = YES;
                     subItemModel.tempSelected = YES;
                     return;
                 }
             }
        }
    }
}

- (NSString *)firstCharactersCapitalized:(NSString *)string {
    if (STLIsEmptyString(string)) {
        return @"";
    }
    
    string = [string lowercaseString];
    NSString *resultStr = [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] capitalizedString]];
    return resultStr;
}



#pragma mark - 选择结果

- (NSString *)filterPriceCondition {
    __block NSString *price = @"";
    
    [self.categoryRefineDataArray enumerateObjectsUsingBlock:^(OSSVCategorysFiltersNewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.key isEqualToString:@"price"]) {
            STLCategoryFilterValueModel *priceValueModel = obj.values.firstObject;
            NSString *minPrice = [priceValueModel.editMinPrice integerValue] > [priceValueModel.editMaxPrice integerValue] ? priceValueModel.editMaxPrice : priceValueModel.editMinPrice;
            NSString *maxPrice = [priceValueModel.editMaxPrice integerValue] > [priceValueModel.editMinPrice integerValue] ? priceValueModel.editMaxPrice : priceValueModel.editMinPrice;
            
            if ([minPrice integerValue] <= 0) {
                minPrice = @"0";
            }
            if ([STLToString(maxPrice) integerValue] > 0) {
                price = [NSString stringWithFormat:@"%@-%@", STLToString(minPrice), STLToString(maxPrice)];
            }
            
            *stop = YES;
        }
    }];
    return  price;
}


- (NSDictionary *)filterItemIDs
{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
    
    for (OSSVCategorysFiltersNewModel *filterModel in self.categoryRefineDataArray) {
        if (![filterModel.key isEqualToString:@"price"]) {
            
            for (STLCategoryFilterValueModel *subFilterModel in filterModel.values) {
                if (subFilterModel.isChecked) {
                    [tempArray addObject:STLToString(subFilterModel.idx)];
                }
            }
            
            if (tempArray.count > 0) {
                [tempDic setObject:tempArray forKey:STLToString(filterModel.key)];
                tempArray = [[NSMutableArray alloc] init];
            }
        }
    }
    
    //NSString *jsonString = [tempDic yy_modelToJSONString];;
    return tempDic;
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.hideCategoryRefineBlock) {
        self.mainView.hidden = YES;
        self.hideCategoryRefineBlock();
    }
}

#pragma mark - Property Method

- (void)setCategoryRefineDataArray:(NSArray<OSSVCategorysFiltersNewModel *> *)categoryRefineDataArray {
    
    CGFloat kwidth = self.mainWidth - 12 * 2;

    // 过滤掉子集为空的，除了价格项
    NSMutableArray *tempCategoryArrays = [[NSMutableArray alloc] init];
    
    // 添加一个 价格
    OSSVCategorysFiltersNewModel *priceItemModel = [[OSSVCategorysFiltersNewModel alloc] init];
    priceItemModel.key = @"price";
    priceItemModel.name = @"Price Range";
    [tempCategoryArrays addObject:priceItemModel];
    
    STLCategoryFilterValueModel *priceSubItem = [[STLCategoryFilterValueModel alloc] init];
    priceSubItem.itemsSize = CGSizeMake(kwidth, 58);
    priceSubItem.isChecked = YES;
    priceSubItem.tempSelected = YES;
    priceSubItem.supKey = priceItemModel.key;
    priceItemModel.values = [[NSArray alloc] initWithObjects:priceSubItem, nil];
    
    for (int j=0; j< categoryRefineDataArray.count; j++) {
        OSSVCategorysFiltersNewModel *itemModel = categoryRefineDataArray[j];
        itemModel.isFirstShowLine = NO;
        //默认可以多行
        itemModel.isMultiLine = YES;
        //默认全显示
        itemModel.isHeaderSelected = YES;
        CGFloat tempSumWidth = 0;
            if([itemModel.key isEqualToString:@"color"]) {
            
            CGFloat tempColorW = 0;
            BOOL isShowTowLine = NO;
            for (int i=0; i<itemModel.values.count; i++) {
                STLCategoryFilterValueModel *subItemModel = itemModel.values[i];
                subItemModel.supKey = itemModel.key;
//                subItemModel.editName = [self handeTitleCounts:subItemModel.searchValue counts:subItemModel.count];
                subItemModel.editName = subItemModel.value;
                subItemModel.tempSelected = subItemModel.isChecked;
                subItemModel.itemsSize = [OSSVCategoryRefinesColorsCCell contentSize:subItemModel.editName maxWidt:kwidth isSelect:subItemModel.tempSelected];
                
                tempSumWidth += subItemModel.itemsSize.width + 8;
                tempColorW += subItemModel.itemsSize.width + 8;
                
//                if (tempSumWidth > (kwidth + 12) && !itemModel.isMultiLine) {
//
//                    // 能显示多行，设置一行个数
//                    itemModel.isMultiLine = YES;
//                    itemModel.firstShowCounts = i;
//                    itemModel.isHeaderSelected = NO;
//                    tempColorW = subItemModel.itemsSize.width + 12;
//
//                } else if(!itemModel.isMultiLine){
//
//                    // 不能显示多行，就设置全展开
//                    itemModel.isHeaderSelected = YES;
//                    itemModel.isFirstShowLine = NO;
//
//                } else if(itemModel.isMultiLine && j<=2 && tempColorW <= (kwidth + 12)) {
//                    // 在前三的时候,不足两行，显示全部
//                    itemModel.isHeaderSelected = YES;
//                    itemModel.isFirstShowLine = NO;
//
//                } else if(itemModel.isMultiLine && j<=2 && tempColorW > (kwidth + 12) && !isShowTowLine) {
//
//                    // 颜色级别时，在前三的时候，设置首次显示两行
//                    itemModel.isHeaderSelected = NO;
//                    itemModel.isFirstShowLine = YES;
//                    itemModel.firstShowCounts = i;
//                    isShowTowLine = YES;
//                }
                
            }
            
            if (itemModel.values.count > 0) {
                [tempCategoryArrays addObject:itemModel];
            }
            
        }
        else if([itemModel.key isEqualToString:@"price"]) {
            [tempCategoryArrays addObject:itemModel];

        }
        else if([itemModel.key isEqualToString:@"size"]){
            
            CGFloat tempColorW = 0;
            BOOL isShowTowLine = NO;

            for (int i=0; i<itemModel.values.count; i++) {
                STLCategoryFilterValueModel *subItemModel = itemModel.values[i];
                subItemModel.supKey = itemModel.key;
                subItemModel.tempSelected = subItemModel.isChecked;
                subItemModel.editName = subItemModel.value;
                subItemModel.itemsSize = [OSSVCategoryRefinesNormalsCCell contentSize:subItemModel.editName maxWidt:kwidth isSelect:subItemModel.tempSelected];
                tempSumWidth += subItemModel.itemsSize.width + 8;
                tempColorW += subItemModel.itemsSize.width + 8;
                
//                if (tempSumWidth > (kwidth + 12) && !itemModel.isMultiLine) {
//                    itemModel.isMultiLine = YES;
//                    itemModel.firstShowCounts = i;
//                    itemModel.isHeaderSelected = NO;
//                    tempColorW = subItemModel.itemsSize.width + 12;
//
//                } else if(!itemModel.isMultiLine){
//                    itemModel.isHeaderSelected = YES;
//                    itemModel.isFirstShowLine = NO;
//
//                } else if(itemModel.isMultiLine && j<=2 && tempColorW <= (kwidth + 12)) {
//                    itemModel.isHeaderSelected = YES;
//                    itemModel.isFirstShowLine = NO;
//                }
//                else if(itemModel.isMultiLine && j<=2 && tempColorW > (kwidth + 12) && !isShowTowLine) {
//
//                    itemModel.isHeaderSelected = NO;
//                    itemModel.isFirstShowLine = YES;
//                    itemModel.firstShowCounts = i;
//                    isShowTowLine = YES;
//                }
            }
            
            if (itemModel.values.count > 0) {
                [tempCategoryArrays addObject:itemModel];
            }
            
        }
    }
    
    // 第一默认全显示
    if (tempCategoryArrays.count > 0) {
        OSSVCategoryFiltersModel *firstModel = tempCategoryArrays.firstObject;
        firstModel.isHeaderSelected = YES;
        firstModel.isFirstShowLine = NO;
    }
    
    _categoryRefineDataArray = [[NSArray alloc] initWithArray:tempCategoryArrays];
    self.isFirstShow = YES;
    [self.collectView reloadData];
}

- (NSString *)handeTitleCounts:(NSString *)title counts:(NSString *)counts {
    NSString *titleString = @"";
    if (STLIsEmptyString(counts)) {
        titleString = [NSString stringWithFormat:@"%@",STLToString(title)];

    } else {
        if ([counts integerValue] <= 0) {
            titleString = [NSString stringWithFormat:@"%@",STLToString(title)];
        } else {
            titleString = [NSString stringWithFormat:@"%@(%@)",STLToString(title),STLToString(counts)];
        }
    }
    
    titleString = [self firstCharactersCapitalized:titleString];

    return titleString;
}

- (void)relaodCurerentSection:(OSSVCategorysFiltersNewModel *)itemModel indexPath:(NSIndexPath *)indexPath {
    
    CGFloat kwidth = self.mainWidth - 12 * 2;

    if (itemModel && [itemModel.key isEqualToString:@"color"]) {
        
        for (int i=0; i<itemModel.values.count; i++) {
            STLCategoryFilterValueModel *subItemModel = itemModel.values[i];
            subItemModel.itemsSize = [OSSVCategoryRefinesColorsCCell contentSize:subItemModel.editName maxWidt:kwidth isSelect:subItemModel.tempSelected];
        }
    } else if(itemModel && [itemModel.key isEqualToString:@"size"]) {
        
        for (int i=0; i<itemModel.values.count; i++) {
            STLCategoryFilterValueModel *subItemModel = itemModel.values[i];
            subItemModel.itemsSize = [OSSVCategoryRefinesNormalsCCell contentSize:subItemModel.editName maxWidt:kwidth isSelect:subItemModel.tempSelected];
        }
        
    }
    
    [UIView performWithoutAnimation:^{
         [self.collectView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
    }];
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _backView;
}

- (UIView *)mainView {
    if (!_mainView) {
        _mainView = [[UIView alloc] initWithFrame:CGRectZero];
        _mainView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _mainView;
}

- (UIView *)bottomToolView {
    if (!_bottomToolView) {
        _bottomToolView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomToolView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _bottomToolView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if (APP_TYPE == 3) {
            [_cancelButton setTitle:STLLocalizedString_(@"category_filter_reset", nil) forState:UIControlStateNormal];
            _cancelButton.titleLabel.font = [UIFont vivaiaSemiBoldFont:14];
            _cancelButton.layer.borderColor = [OSSVThemesColors col_000000:1].CGColor;
            [_cancelButton setTitleColor:[OSSVThemesColors col_000000:1] forState:UIControlStateNormal];
            _cancelButton.layer.borderWidth = 2.0;

        } else {
            [_cancelButton setTitle:[STLLocalizedString_(@"category_filter_reset", nil) uppercaseString] forState:UIControlStateNormal];
            _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            _cancelButton.layer.borderColor = [OSSVThemesColors col_999999].CGColor;
            [_cancelButton setTitleColor:[OSSVThemesColors col_666666] forState:UIControlStateNormal];
            _cancelButton.layer.borderWidth = 1.0;
            _cancelButton.layer.cornerRadius = 2.0;
            _cancelButton.layer.masksToBounds = YES;

        }
        [_cancelButton addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        
        if (APP_TYPE == 3) {
            [_confirmButton setTitle:STLLocalizedString_(@"category_filter_apply", nil) forState:UIControlStateNormal];
            _confirmButton.titleLabel.font = [UIFont vivaiaSemiBoldFont:14];
            _confirmButton.backgroundColor = [OSSVThemesColors col_000000:1];

        } else {
            [_confirmButton setTitle:[STLLocalizedString_(@"category_filter_apply", nil) uppercaseString] forState:UIControlStateNormal];
            _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            _confirmButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
            _confirmButton.layer.cornerRadius = 2.0;
            _confirmButton.layer.masksToBounds = YES;

        }
        //applySting = [self firstCharactersCapitalized:applySting];
        
        [_confirmButton addTarget:self action:@selector(actionConfirm:) forControlEvents:UIControlEventTouchUpInside];
        

    }
    return _confirmButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
}

- (UICollectionView *)collectView {
    if(!_collectView) {
        
        UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
        layout.minimumLineSpacing = 8;
        layout.minimumInteritemSpacing = 8;
        layout.sectionInset = UIEdgeInsetsMake(0, 12, 12, 12);
        
//        if (@available(iOS 10.0, *)) {
//            layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize;
//        } else {
//            layout.estimatedItemSize = CGSizeMake(110, 44);
//        }
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.alignedLayoutType = UICollectionViewLeftAlignedLayoutTypeLeft;
        
        _collectView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectView.delegate = self;
        _collectView.dataSource = self;
        _collectView.backgroundColor = [UIColor whiteColor];
        
        [_collectView registerClass:[OSSVCategoryRefinesColorsCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVCategoryRefinesColorsCCell.class)];

        [_collectView registerClass:[OSSVCategoryRefinesNormalsCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVCategoryRefinesNormalsCCell.class)];
        [_collectView registerClass:[OSSVCategoryRefinessSpeciallCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVCategoryRefinessSpeciallCCell.class)];
        [_collectView registerClass:[OSSVCategoryRefinesPriceCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVCategoryRefinesPriceCCell.class)];
    }
    
    return _collectView;
}


- (CABasicAnimation *)showRefineInfoViewAnimation {
    if (!_showRefineInfoViewAnimation) {
        _showRefineInfoViewAnimation = [CABasicAnimation animation];
        _showRefineInfoViewAnimation.keyPath = @"position.x";
        _showRefineInfoViewAnimation.fromValue = [OSSVSystemsConfigsUtils isRightToLeftShow] ? @(-SCREEN_WIDTH * 0.5) : @(SCREEN_WIDTH * 1.5);
        _showRefineInfoViewAnimation.toValue = [OSSVSystemsConfigsUtils isRightToLeftShow] ?  @(self.mainWidth / 2) : @(self.mainWidth / 2 + 75);
        _showRefineInfoViewAnimation.duration = kCategoryRefineNewAnimatonTime;
        _showRefineInfoViewAnimation.removedOnCompletion = NO;
        _showRefineInfoViewAnimation.fillMode = kCAFillModeForwards;
    }
    return _showRefineInfoViewAnimation;
}

- (CABasicAnimation *)hideRefineInfoViewAnimation {
    if (!_hideRefineInfoViewAnimation) {
        _hideRefineInfoViewAnimation = [CABasicAnimation animation];
        _hideRefineInfoViewAnimation.keyPath = @"position.x";
        _hideRefineInfoViewAnimation.fromValue = [OSSVSystemsConfigsUtils isRightToLeftShow] ? @(self.mainWidth / 2) : @(self.mainWidth / 2 + 75);
        _hideRefineInfoViewAnimation.toValue = [OSSVSystemsConfigsUtils isRightToLeftShow] ? @(-SCREEN_WIDTH * 0.5) : @(SCREEN_WIDTH * 1.5);
        _hideRefineInfoViewAnimation.duration = kCategoryRefineNewAnimatonTime;
        _hideRefineInfoViewAnimation.removedOnCompletion = NO;
        _hideRefineInfoViewAnimation.fillMode = kCAFillModeForwards;
        _hideRefineInfoViewAnimation.delegate = self;
    }
    return _hideRefineInfoViewAnimation;
}


@end
