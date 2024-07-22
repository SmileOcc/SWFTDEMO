//
//  ZFCategoryRefineNewView.m
//  ZZZZZ
//
//  Created by YW on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCategoryRefineNewView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFProgressHUD.h"
#import "SystemConfigUtils.h"
#import "ZFAppsflyerAnalytics.h"
#import "ExchangeManager.h"

#import "UICollectionViewLeftAlignedLayout.h"
#import "ZFCategoryRefineHeaderCollectionReusableView.h"

static CGFloat const kCategoryRefineNewAnimatonTime = 0.25f;

static NSString *const khideCategoryRefineNewAnimationIdentifier = @"khideCategoryRefineNewAnimationIdentifier";
static NSString *const kshowCategoryRefineNewAnimationIdentifier = @"kshowCategoryRefineNewAnimationIdentifier";

@interface ZFCategoryRefineNewView()
<ZFInitViewProtocol,UICollectionViewDelegate,UICollectionViewDataSource,CAAnimationDelegate>

@property (nonatomic, strong) UIView       *backView;

@property (nonatomic, assign) BOOL         isFirstShow;

@property (nonatomic, assign) CGFloat      mainWidth;


@property (nonatomic, strong) CABasicAnimation          *showRefineInfoViewAnimation;
@property (nonatomic, strong) CABasicAnimation          *hideRefineInfoViewAnimation;

@end


@implementation ZFCategoryRefineNewView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.isFirstShow = YES;
        self.mainWidth = KScreenWidth - 55;
        [self zfInitView];
        [self zfAutoLayoutView];
        
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        [self.backView addGestureRecognizer:tap];
    }
    return self;
}

- (void)zfInitView {
    self.backgroundColor = ZFC0x000000_04();
    
    [self addSubview:self.backView];
    [self addSubview:self.mainView];
    [self.mainView addSubview:self.bottomToolView];
    [self.mainView addSubview:self.collectView];
    
    [self.bottomToolView addSubview:self.cancelButton];
    [self.bottomToolView addSubview:self.confirmButton];
}

- (void)zfAutoLayoutView {
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.leading.mas_equalTo(self);
        make.width.mas_equalTo(55);
    }];
    
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.trailing.mas_equalTo(self);
        make.width.mas_equalTo(self.mainWidth);
    }];
    
    [self.bottomToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mainView.mas_bottom).offset(-kiphoneXHomeBarHeight);
        make.leading.trailing.mas_equalTo(self.mainView);
        make.height.mas_equalTo(52);
    }];
    
    [self.collectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.mainView);
        make.top.mas_equalTo(self.mainView.mas_top).offset(IPHONE_X_5_15 ? 0 : 20);
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
        make.leading.mas_equalTo(self.cancelButton.mas_trailing).offset(8);
        make.width.mas_equalTo(self.cancelButton.mas_width);
    }];
}

#pragma mark - Public Methods
- (void)showRefineInfoViewWithAnimation:(BOOL)animation {
    if (!animation) {
        return ;
    }
    
    self.hidden = NO;
    self.backgroundColor = ColorHex_Alpha(0x000000, 0);
    [UIView animateWithDuration:kCategoryRefineNewAnimatonTime animations:^{
        self.backgroundColor = ZFC0x000000_04();
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
        self.backgroundColor = ColorHex_Alpha(0x000000, 0);
    }];
    
    [self.mainView.layer addAnimation:self.hideRefineInfoViewAnimation forKey:khideCategoryRefineNewAnimationIdentifier];
}


#pragma mark - Action

- (void)actionTap:(UITapGestureRecognizer *)tap {
    [self hideRefineInfoViewViewWithAnimation:YES];
}

- (void)actionCancel:(UIButton *)sender {
    
    /// 原生专题来源
    if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > 0) {
        [self.nativeRefineDataArray enumerateObjectsUsingBlock:^(ZFGeshopSiftItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            obj.editMax = @"";
            obj.editMin = @"";
            obj.localCurrencyMin = @"";
            obj.localCurrencyMax = @"";
            
            if (ZFJudgeNSArray(obj.child_item)) {
                [obj.child_item enumerateObjectsUsingBlock:^(ZFGeshopSiftItemModel * _Nonnull itemObj, NSUInteger idx, BOOL * _Nonnull stop) {
                    itemObj.isCurrentSelected = NO;
                    itemObj.editMax = @"";
                    itemObj.editMin = @"";
                    itemObj.localCurrencyMin = @"";
                    itemObj.localCurrencyMax = @"";
                }];
            }
        }];
        
    } else if(ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
        [self.categoryRefineDataArray enumerateObjectsUsingBlock:^(CategoryRefineDetailModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (ZFJudgeNSArray(obj.childArray)) {
                [obj.childArray enumerateObjectsUsingBlock:^(CategoryRefineCellModel * _Nonnull itemObj, NSUInteger idx, BOOL * _Nonnull stop) {
                    itemObj.isSelect = NO;
                    itemObj.editMax = @"";
                    itemObj.editMin = @"";
                    itemObj.localCurrencyMin = @"";
                    itemObj.localCurrencyMax = @"";
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
    __block NSMutableArray *selectNativeArrays = [[NSMutableArray alloc] init];

    /// 分类来源选择
    __block NSMutableArray *selectCategoryArrays = [[NSMutableArray alloc] init];
    
    /// 原生专题来源
    if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > 0) {
        [self.nativeRefineDataArray enumerateObjectsUsingBlock:^(ZFGeshopSiftItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *af_refineKey = ZFToString(obj.item_title);
            NSMutableArray *subRefineKeys = [[NSMutableArray alloc] init];
            
            if (ZFJudgeNSArray(obj.child_item)) {
                
                if ([obj.item_type isEqualToString:@"3"]) { //价格
                    
                    // 直接返回价格分类的模块
                    obj.typePrice = YES;
                    ZFGeshopSiftItemModel * itemObj = obj.child_item.firstObject;
                    obj.selectItems = [[NSArray alloc] initWithObjects:itemObj, nil];

                    if(!ZFIsEmptyString(af_refineKey)) {
                        if (!ZFIsEmptyString(obj.editMin) || !ZFIsEmptyString(obj.editMax)) {
                            
                            NSString *price_min = !ZFIsEmptyString(obj.editMin) ? obj.editMin : [NSString stringWithFormat:@"%li",(long)obj.price_min];
                             NSString *price_max = !ZFIsEmptyString(itemObj.editMax) ? itemObj.editMax : [NSString stringWithFormat:@"%li",(long)itemObj.price_max];
                            NSString *min_maxString = [NSString stringWithFormat:@"%li-%li",(long)[price_min integerValue],(long)[price_max integerValue]];
                            [subRefineKeys addObject:min_maxString];
                        }
                    }
                    
                    [selectNativeArrays addObject:obj];
                    
                } else {
                    __block ZFGeshopSiftItemModel *refineItemModel = nil;
                    __block NSMutableArray *refineSelectArrays = [[NSMutableArray alloc] init];

                    [obj.child_item enumerateObjectsUsingBlock:^(ZFGeshopSiftItemModel * _Nonnull itemObj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if (itemObj.isCurrentSelected) {
                            if (!refineItemModel) {
                                refineItemModel = obj;
                            }
                            [refineSelectArrays addObject:itemObj];
                            [selectCategoryArrays addObject:itemObj];
                            
                            if(!ZFIsEmptyString(af_refineKey)) {
                                [subRefineKeys addObject:ZFToString(itemObj.item_title)];
                            }
                        }
                    }];
                    refineItemModel.selectItems = refineSelectArrays;

                    if (ZFJudgeNSArray(refineItemModel.selectItems) && refineItemModel.selectItems.count > 0) {
                        [selectNativeArrays addObject:refineItemModel];
                    }
                }
            }

            
            NSString *subRefinekeyString = [subRefineKeys componentsJoinedByString:@","];
            if(!ZFIsEmptyString(subRefinekeyString)) {
                [refineTypeArrays addObject:[NSString stringWithFormat:@"%@:\"%@",subRefineKeys,subRefinekeyString]];
                [refineTypeDic setObject:subRefinekeyString forKey:af_refineKey];
            }
        }];
        
    } else if(ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
        [self.categoryRefineDataArray enumerateObjectsUsingBlock:^(CategoryRefineDetailModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *af_refineKey = ZFToString(obj.name);
            NSMutableArray *subRefineKeys = [[NSMutableArray alloc] init];
            
            if ([obj.type isEqualToString:@"price"]) {
                CategoryRefineCellModel *itemObj = obj.childArray.firstObject;
                [selectCategoryArrays addObject:itemObj];
                
                if(!ZFIsEmptyString(af_refineKey)) {
                    if (!ZFIsEmptyString(itemObj.editMin) || !ZFIsEmptyString(itemObj.editMax)) {
                        
                        NSString *price_min = !ZFIsEmptyString(itemObj.editMin) ? itemObj.editMin : [NSString stringWithFormat:@"%li",(long)itemObj.min];
                         NSString *price_max = !ZFIsEmptyString(itemObj.editMax) ? itemObj.editMax : [NSString stringWithFormat:@"%li",(long)itemObj.max];
                        NSString *min_maxString = [NSString stringWithFormat:@"%li-%li",(long)[price_min integerValue],(long)[price_max integerValue]];
                        [subRefineKeys addObject:min_maxString];
                    }
                }
                
            } else if (ZFJudgeNSArray(obj.childArray)) {
                [obj.childArray enumerateObjectsUsingBlock:^(CategoryRefineCellModel * _Nonnull itemObj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (itemObj.isSelect) {
                        [selectCategoryArrays addObject:itemObj];
                        if(!ZFIsEmptyString(af_refineKey)) {
                            [subRefineKeys addObject:ZFToString(itemObj.name)];
                        }
                    }
                }];
            }
            
            NSString *subRefinekeyString = [subRefineKeys componentsJoinedByString:@","];
            if(!ZFIsEmptyString(subRefinekeyString)) {
                [refineTypeArrays addObject:[NSString stringWithFormat:@"%@:\"%@",subRefineKeys,subRefinekeyString]];
                [refineTypeDic setObject:subRefinekeyString forKey:af_refineKey];
            }
        }];
    }
    
    
    if (self.confirmBlock) {
    
        if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > 0) {
            self.confirmBlock(selectNativeArrays, @[],refineTypeDic);
        } else if(ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
            self.confirmBlock(@[], selectCategoryArrays,refineTypeDic);
        } else {
            self.confirmBlock(@[], @[],@{});
        }
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
    
    if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > 0) {
        if (self.nativeRefineDataArray.count > indexPath.section) {
            
            ZFGeshopSiftItemModel *refineModel = self.nativeRefineDataArray[indexPath.section];
            CategoryRefineCellType cellType = [self refineCellTypeNative:refineModel categoryModel:nil];
                       
            ZFGeshopSiftItemModel *nativeItemModel = [self nativeItemModelForIndexPath:indexPath];
            if (cellType == CategoryRefineCellTypeSpecial) {

               ZFCategoryRefineSpecialCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFCategoryRefineSpecialCCell.class) forIndexPath:indexPath];
                [cell hightLightState:nativeItemModel.isCurrentSelected];
                cell.titleLabel.text = [self titleForIndexPath:indexPath];
                
                return cell;
            }
            
            if (cellType == CategoryRefineCellTypeColor) {
                
                ZFCategoryRefineColorCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFCategoryRefineColorCCell.class) forIndexPath:indexPath];
                cell.colorTitleLabel.text = [self titleForIndexPath:indexPath];
                [cell hightLightState:nativeItemModel.isCurrentSelected];
                cell.colorView.backgroundColor = [self colorForIndexPath:indexPath];

                return cell;
            }
            
            if (cellType == CategoryRefineCellTypePrice) {
                
                ZFCategoryRefinePriceCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFCategoryRefinePriceCCell.class) forIndexPath:indexPath];
  
                //货币转换
                NSString *placePrice_min = @"";
                NSString *placePrice_max = @"";
                NSString *editMinString = @"";
                NSString *editMaxString = @"";
                
                // 最小的，向下取整，最大的向上取整
                if ([nativeItemModel.price_max floatValue] > 0) {
                    placePrice_min = [ExchangeManager transPurePriceforPriceOnlyNumber:nativeItemModel.price_min];
                    placePrice_max = [ExchangeManager transPurePriceforPriceOnlyNumber:nativeItemModel.price_max];
                    placePrice_min = [NSString stringWithFormat:@"%.0f",floor([placePrice_min floatValue])];
                    placePrice_max = [NSString stringWithFormat:@"%.0f",ceil([placePrice_max floatValue])];
                }
                if (!ZFIsEmptyString(nativeItemModel.editMin) && ZFIsEmptyString(nativeItemModel.localCurrencyMin)) {
                    editMinString = [ExchangeManager transPurePriceforPriceOnlyNumber:nativeItemModel.editMin];
                    editMinString = [NSString stringWithFormat:@"%.0f",floor([editMinString floatValue])];
                    nativeItemModel.localCurrencyMin =  editMinString;
                } else if(!ZFIsEmptyString(nativeItemModel.localCurrencyMin)) {
                    editMinString = nativeItemModel.localCurrencyMin;
                }
                
                if (!ZFIsEmptyString(nativeItemModel.editMax)) {
                    editMaxString = [ExchangeManager transPurePriceforPriceOnlyNumber:nativeItemModel.editMax];
                    editMaxString = [NSString stringWithFormat:@"%.0f",ceil([editMaxString floatValue])];
                    nativeItemModel.localCurrencyMax =  editMaxString;
                } else if(!ZFIsEmptyString(nativeItemModel.localCurrencyMax)) {
                    editMaxString = nativeItemModel.localCurrencyMax;
                }
                
                [cell refinePriceMin:editMinString max:editMaxString];
                [cell updatePlaceholder:placePrice_min max:placePrice_max];
                [cell hightLightState:NO];
                
                @weakify(self)
                cell.editBlock = ^(NSString *minString, NSString *maxString) {
                    @strongify(self)
                    [self handleEditPriceMin:minString max:maxString];
                };
                
                return cell;
            }
            
            ZFCategoryRefineNormalCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFCategoryRefineNormalCCell.class) forIndexPath:indexPath];
            [cell hightLightState:nativeItemModel.isCurrentSelected];
            cell.titleLabel.text = [self titleForIndexPath:indexPath];
            
            return cell;
        }
        
    } else if(ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
        if (self.categoryRefineDataArray.count > indexPath.section) {

            CategoryRefineDetailModel *refineModel = self.categoryRefineDataArray[indexPath.section];
            CategoryRefineCellModel *cateItemModel = [self categoryItemModelForIndexPath:indexPath];
            CategoryRefineCellType cellType = [self refineCellTypeNative:nil categoryModel:refineModel];
                        

            
            if (cellType == CategoryRefineCellTypeSpecial) {

               ZFCategoryRefineSpecialCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFCategoryRefineSpecialCCell.class) forIndexPath:indexPath];
                [cell hightLightState:cateItemModel.isSelect];
                cell.titleLabel.text = [self titleForIndexPath:indexPath];
                
                return cell;
            }
            
            if (cellType == CategoryRefineCellTypeColor) {
                
                ZFCategoryRefineColorCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFCategoryRefineColorCCell.class) forIndexPath:indexPath];
                cell.colorTitleLabel.text = [self titleForIndexPath:indexPath];
                [cell hightLightState:cateItemModel.isSelect];
                cell.colorView.backgroundColor = [self colorForIndexPath:indexPath];

                return cell;
            }
            
            if (cellType == CategoryRefineCellTypePrice) {
                
                ZFCategoryRefinePriceCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFCategoryRefinePriceCCell.class) forIndexPath:indexPath];
                
                //货币转换
                NSString *placePrice_min = @"";
                NSString *placePrice_max = @"";
                NSString *editMinString = @"";
                NSString *editMaxString = @"";
                
                if (cateItemModel.max >= 0) {
                    placePrice_min = [ExchangeManager transPurePriceforPriceOnlyNumber:[NSString stringWithFormat:@"%li",(long)cateItemModel.min]];
                    placePrice_max = [ExchangeManager transPurePriceforPriceOnlyNumber:[NSString stringWithFormat:@"%li",(long)cateItemModel.max]];
                    placePrice_min = [NSString stringWithFormat:@"%.0f",floor([placePrice_min floatValue])];
                    placePrice_max = [NSString stringWithFormat:@"%.0f",ceil([placePrice_max floatValue])];

                }
                if (!ZFIsEmptyString(cateItemModel.editMin) && ZFIsEmptyString(cateItemModel.localCurrencyMin)) {
                    editMinString = [ExchangeManager transPurePriceforPriceOnlyNumber:cateItemModel.editMin];
                    editMinString = [NSString stringWithFormat:@"%.0f",floor([editMinString floatValue])];
                    cateItemModel.localCurrencyMin =  editMinString;
                    
                } else if(!ZFIsEmptyString(cateItemModel.localCurrencyMin)) {
                    editMinString = cateItemModel.localCurrencyMin;
                }
                
                if (!ZFIsEmptyString(cateItemModel.editMax) && ZFIsEmptyString(cateItemModel.localCurrencyMax)) {
                    editMaxString = [ExchangeManager transPurePriceforPriceOnlyNumber:cateItemModel.editMax];
                    editMaxString = [NSString stringWithFormat:@"%.0f",ceil([editMaxString floatValue])];
                    cateItemModel.localCurrencyMax =  editMaxString;
                    
                } else if(!ZFIsEmptyString(cateItemModel.localCurrencyMax)) {
                    editMaxString = cateItemModel.localCurrencyMax;
                }
                
                [cell refinePriceMin:editMinString max:editMaxString];
                [cell updatePlaceholder:placePrice_min max:placePrice_max];
                [cell hightLightState:NO];
                
                @weakify(self)
                cell.editBlock = ^(NSString *minString, NSString *maxString) {
                    @strongify(self)
                    [self handleEditPriceMin:minString max:maxString];
                };
                return cell;
            }
            
            ZFCategoryRefineNormalCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFCategoryRefineNormalCCell.class) forIndexPath:indexPath];
            [cell hightLightState:cateItemModel.isSelect];
            cell.titleLabel.text = [self titleForIndexPath:indexPath];
            return cell;
        }
    }
    
    ZFCategoryRefineNormalCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFCategoryRefineNormalCCell.class) forIndexPath:indexPath];
    [cell hightLightState:NO];
    cell.titleLabel.text = @"";
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    ZFCategoryRefineHeaderCollectionReusableView *headView = [ZFCategoryRefineHeaderCollectionReusableView headWithCollectionView:collectionView Kind:kind IndexPath:indexPath];
    headView.titleLabel.text = @"";
    
    @weakify(self)
    headView.tapBlock = ^{
        @strongify(self)
        [self endEditing:YES];
        
        if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > indexPath.section) {
            
            ZFGeshopSiftItemModel *refineListModel = self.nativeRefineDataArray[indexPath.section];
            refineListModel.isFirstShowLine = NO;

            if ([refineListModel.item_type integerValue] != CategoryRefineCellTypePrice) {
                refineListModel.isHeaderSelected = !refineListModel.isHeaderSelected;
                [self.collectView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];

            }
            
        } else if (ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > indexPath.section) {
            
            CategoryRefineDetailModel *refineListModel = self.categoryRefineDataArray[indexPath.section];
            refineListModel.isFirstShowLine = NO;
            
            if (![refineListModel.type isEqualToString:@"price"]) {
                refineListModel.isHeaderSelected = !refineListModel.isHeaderSelected;
                [self.collectView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];

            }
        }
        

    };
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] ) {
        
        if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > indexPath.section) {
            
            ZFGeshopSiftItemModel *refineListModel = self.nativeRefineDataArray[indexPath.section];
            [headView updateArrowDirection:refineListModel.isHeaderSelected];
            [headView updateCountsString:[self sectinSelectAllCounts:indexPath]];
            [headView hideArrow:NO];

            NSString *title = [self firstCharactersCapitalized:ZFToString(refineListModel.item_title)];
            
            if ([refineListModel.item_type integerValue] == CategoryRefineCellTypePrice) {
                [headView hideArrow:YES];

                //本地货币金额符号
                NSString *localTypeCurrency = [ExchangeManager localTypeCurrency];
                headView.titleLabel.text = [NSString stringWithFormat:@"%@(%@)",title,localTypeCurrency];
                
            } else {
                headView.titleLabel.text = title;
            }
        }
        
        if (ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > indexPath.section) {
            
            CategoryRefineDetailModel *refineListModel = self.categoryRefineDataArray[indexPath.section];
            [headView updateArrowDirection:refineListModel.isHeaderSelected];
            [headView updateCountsString:[self sectinSelectAllCounts:indexPath]];
            [headView hideArrow:NO];

            NSString *title = [self firstCharactersCapitalized:ZFToString(refineListModel.name)];

            if ([refineListModel.type isEqualToString:@"price"]) {
                [headView hideArrow:YES];

                //本地货币金额符号
                NSString *localTypeCurrency = [ExchangeManager localTypeCurrency];
                headView.titleLabel.text = [NSString stringWithFormat:@"%@(%@)",title,localTypeCurrency];
            } else {
                headView.titleLabel.text = title;
            }
        }
    }
    
    return headView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > indexPath.section) {
        ZFGeshopSiftItemModel *refineListModel = [self nativeItemModelForIndexPath:indexPath];
        return refineListModel.itemsSize;
    }
    if (ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > indexPath.section) {
        CategoryRefineCellModel *refineListModel = [self categoryItemModelForIndexPath:indexPath];
        return refineListModel.itemsSize;
    }
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(KScreenWidth, 44);
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZFCategoryRefineBaseCCell *cell = (ZFCategoryRefineBaseCCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (![cell isKindOfClass:[ZFCategoryRefinePriceCCell class]]) {
        
        if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > indexPath.section) {
            
            ZFGeshopSiftItemModel *sectionItemModel = self.nativeRefineDataArray[indexPath.section];
            ZFGeshopSiftItemModel *nativeItemModel = [self nativeItemModelForIndexPath:indexPath];
                        

            if (nativeItemModel) {
                nativeItemModel.isCurrentSelected = !nativeItemModel.isCurrentSelected;
            }
            
            
            [cell hightLightState:nativeItemModel.isCurrentSelected];
            sectionItemModel.isFirstShowLine = NO;
            
            // 未显示全部时：点击显示全部
            if (!sectionItemModel.isHeaderSelected) {
                sectionItemModel.isHeaderSelected = YES;
            }
            [UIView performWithoutAnimation:^{
                 [self.collectView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            }];
            
        } else if (ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
            
            CategoryRefineDetailModel *sectionItemModel = self.categoryRefineDataArray[indexPath.section];
            CategoryRefineCellModel *categoryItemModel = [self categoryItemModelForIndexPath:indexPath];
           
            if (categoryItemModel) {
                categoryItemModel.isSelect = !categoryItemModel.isSelect;
            }
            
            [cell hightLightState:categoryItemModel.isSelect];
            sectionItemModel.isFirstShowLine = NO;
            
            // 未显示全部时：点击显示全部
            if (!sectionItemModel.isHeaderSelected) {
                sectionItemModel.isHeaderSelected = YES;
            }
            [UIView performWithoutAnimation:^{
                 [self.collectView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            }];
            
        }        
    }
}

#pragma mark - 数据配置

- (NSInteger)sectionNumberCounts {
    
    /// 原生专题
    if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > 0) {
        //设置第一个选中
        if (self.isFirstShow) {
            ZFGeshopSiftItemModel *refineListModel = self.nativeRefineDataArray[0];
            refineListModel.isHeaderSelected = YES;
            self.isFirstShow = NO;
        }
        return self.nativeRefineDataArray.count;
    }
    if (ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
        //设置第一选中
        if (self.isFirstShow) {
            CategoryRefineDetailModel *refineListModel = self.categoryRefineDataArray[0];
            refineListModel.isHeaderSelected = YES;
            self.isFirstShow = NO;
        }
        return self.categoryRefineDataArray.count;
    }
    return 0;
}

- (NSInteger)nembersForSectionCounts:(NSInteger)section {
    
    /// 原生专题
    if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > section) {
        ZFGeshopSiftItemModel *refineListModel = self.nativeRefineDataArray[section];
        
        if ([refineListModel.item_type integerValue] == CategoryRefineCellTypePrice) {
            return 1;
        }
        
        if (ZFJudgeNSArray(refineListModel.child_item)) {
            if (refineListModel.isFirstShowLine) {
                return refineListModel.firstShowCounts > 0 ? refineListModel.firstShowCounts : refineListModel.child_item.count;
                
            } else if (refineListModel.isHeaderSelected) {
                return refineListModel.child_item.count;
            }
        }
        return 0;
    }
    
    if (ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > section) {
        CategoryRefineDetailModel *refineListModel = self.categoryRefineDataArray[section];
        
        if ([refineListModel.type isEqualToString:@"price"]) {
            return 1;
        }
        
        if (ZFJudgeNSArray(refineListModel.childArray)) {
            
            if (refineListModel.isFirstShowLine) {
                return refineListModel.firstShowCounts > 0 ? refineListModel.firstShowCounts : refineListModel.childArray.count;
                
            } else if (refineListModel.isHeaderSelected) {
                return refineListModel.childArray.count;
            }
        }
    }
    return 0;
}

- (NSString *)titleForIndexPath:(NSIndexPath *)indexPath {

    ZFGeshopSiftItemModel *nativeItemModel = [self nativeItemModelForIndexPath:indexPath];
    /// 原生专题
    if (nativeItemModel) {
        return ZFToString(nativeItemModel.editName);
    }
    
    CategoryRefineCellModel *categoryItemModel = [self categoryItemModelForIndexPath:indexPath];
    if (categoryItemModel) {
        return ZFToString(categoryItemModel.editName);
    }
    
    return @"";
}

- (void)handleEditPriceMin:(NSString *)minString max:(NSString *)maxString {
    
    //本地货币金额符号
    NSString *localTypeCurrency = [ExchangeManager localTypeCurrency];
    NSString *usdMinString = minString;
    NSString *usdMaxSting = maxString;
    
    /// 传给后台，美元
    if (![localTypeCurrency isEqualToString:@"$"]) {
        
        if (!ZFIsEmptyString(minString)) {
            usdMinString = [ExchangeManager transPurePriceForCurrencyPrice:minString sourceCurrency:localTypeCurrency purposeCurrency:@"$" priceType:PriceType_Normal isSpace:NO isAppendCurrency:NO];
        }
        if (!ZFIsEmptyString(maxString)) {
            usdMaxSting = [ExchangeManager transPurePriceForCurrencyPrice:maxString sourceCurrency:localTypeCurrency purposeCurrency:@"$" priceType:PriceType_Normal isSpace:NO isAppendCurrency:NO];
        }
    }
    
    /// 原生专题
    if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > 0) {
        [self.nativeRefineDataArray enumerateObjectsUsingBlock:^(ZFGeshopSiftItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.item_type integerValue] == CategoryRefineCellTypePrice) {
                obj.isCurrentSelected = YES;
                obj.editMin = ZFToString(usdMinString);
                obj.editMax = ZFToString(usdMaxSting);
                
                ZFGeshopSiftItemModel *itemModel = obj.child_item.firstObject;
                if (itemModel) {
                    itemModel.editMin = ZFToString(usdMinString);
                    itemModel.editMax = ZFToString(usdMaxSting);
                    itemModel.isCurrentSelected = (!ZFIsEmptyString(minString) && !ZFIsEmptyString(maxString)) ? YES : NO;
                }
                *stop = YES;
            }
        }];
    } else if(ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
        [self.categoryRefineDataArray enumerateObjectsUsingBlock:^(CategoryRefineDetailModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.type isEqualToString:@"price"]) {
                CategoryRefineCellModel *itemModel = obj.childArray.firstObject;
                if (itemModel) {
                    itemModel.editMin = ZFToString(usdMinString);
                    itemModel.editMax = ZFToString(usdMaxSting);
                    itemModel.isSelect = (!ZFIsEmptyString(minString) && !ZFIsEmptyString(maxString)) ? YES : NO;
                    itemModel.localCurrencyMin = ZFToString(minString);
                    itemModel.localCurrencyMax = ZFToString(maxString);
                }
                *stop = YES;
            }
        }];
    }
}


- (CategoryRefineCellType)refineCellTypeNative:(ZFGeshopSiftItemModel *)nativeModel categoryModel:(CategoryRefineDetailModel *)categoryModel {
    
    CategoryRefineCellType cellType = CategoryRefineCellTypeNormal;
    
    /// 原生专题
    if (nativeModel) {
        if ([nativeModel.item_type isEqualToString:@"0"]) {
            
        } else if([nativeModel.item_type isEqualToString:@"1"]) {
            cellType = CategoryRefineCellTypeSpecial;
        } else if([nativeModel.item_type isEqualToString:@"2"]) {
            cellType = CategoryRefineCellTypeColor;
        } else if([nativeModel.item_type isEqualToString:@"3"]) {
            cellType = CategoryRefineCellTypePrice;
        }
    } else if(categoryModel) {
        
        if ([categoryModel.type isEqualToString:@"size"]) {
            
        } else if([categoryModel.type isEqualToString:@"service"]) {
            cellType = CategoryRefineCellTypeSpecial;
        } else if([categoryModel.type isEqualToString:@"color"]) {
            cellType = CategoryRefineCellTypeColor;
        } else if([categoryModel.type isEqualToString:@"price"]) {
            cellType = CategoryRefineCellTypePrice;
        }
    }
    return cellType;
}

- (UIColor *)colorForIndexPath:(NSIndexPath *)indexPath {
    UIColor *color;
    NSString *colorString;
    
    ZFGeshopSiftItemModel *nativeModel = [self nativeItemModelForIndexPath:indexPath];
    if (nativeModel) {
        colorString = ZFToString(nativeModel.item_color_code);
    }
    
    CategoryRefineCellModel *categoryModel = [self categoryItemModelForIndexPath:indexPath];
    if (categoryModel) {
        colorString = ZFToString(categoryModel.color_code);
    }
    
    if ([colorString hasPrefix:@"#"]) {
        NSArray *colorArrays = [colorString componentsSeparatedByString:@"#"];
        if (colorArrays.count > 1) {
            NSString *colorStr = colorArrays[1];
            color = [self colorWithHexString:colorStr];
        }
    }
    
    if (!color) {
        color = ZFC0xFFFFFF();
    }
    return color;
}

- (UIColor *)colorWithHexString:(NSString *)stringToConvert {
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum])
        return nil;
    return ColorHex_Alpha(hexNum, 1.0);
}

- (NSString *)sectinSelectAllCounts:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSString *countsString = @"";
    
    __block NSInteger count = 0;
    if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > section) {
        if (self.nativeRefineDataArray.count > section) {
            ZFGeshopSiftItemModel *refineListModel = self.nativeRefineDataArray[section];
            [refineListModel.child_item enumerateObjectsUsingBlock:^(ZFGeshopSiftItemModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.isCurrentSelected) {
                    count++;
                }
            }];
        }
    } else if (ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > section) {
        CategoryRefineDetailModel *refineListModel = self.categoryRefineDataArray[section];
        [refineListModel.childArray enumerateObjectsUsingBlock:^(CategoryRefineCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.isSelect) {
                count++;
            }
        }];
    }
    
    if (count > 0) {
        countsString = [NSString stringWithFormat:@"%li",(long)count];
    }
    
    return countsString;
}

- (ZFGeshopSiftItemModel *)nativeItemModelForIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    ZFGeshopSiftItemModel *itemModel;
    
    if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > section) {
        if (self.nativeRefineDataArray.count > section) {
            ZFGeshopSiftItemModel *refineListModel = self.nativeRefineDataArray[section];
            
            if (ZFJudgeNSArray(refineListModel.child_item) && refineListModel.child_item.count > row) {
                itemModel = refineListModel.child_item[row];
            }
        }
    }
    return itemModel;
}


- (CategoryRefineCellModel *)categoryItemModelForIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    CategoryRefineCellModel *itemModel;
    
    if (ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > section) {
        CategoryRefineDetailModel *refineListModel = self.categoryRefineDataArray[section];
        if (ZFJudgeNSArray(refineListModel.childArray) && refineListModel.childArray.count > row) {
            itemModel = refineListModel.childArray[row];
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
    
    NSArray *refineTypeArr = [ZFToString(selectedCategorys) componentsSeparatedByString:@"~"];
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
    
    if (ZFIsEmptyString(key)) {
        return;
    }
    
    if (ZFJudgeNSArray(self.nativeRefineDataArray) && self.nativeRefineDataArray.count > 0) {
        /// 原生专题
        
        for (ZFGeshopSiftItemModel *itemModel in _nativeRefineDataArray) {
            for (ZFGeshopSiftItemModel *subItemModel in itemModel.child_item) {
                
                if ([subItemModel.item_id isEqualToString:key]) {
                    itemModel.isHeaderSelected = YES;
                    subItemModel.isCurrentSelected = YES;
                    return;
                }
            }
        }
    } else if(ZFJudgeNSArray(self.categoryRefineDataArray) && self.categoryRefineDataArray.count > 0) {
        /// 分类
        
        for (CategoryRefineDetailModel *itemModel in _categoryRefineDataArray) {
             for (CategoryRefineCellModel *subItemModel in itemModel.childArray) {
                 if ([subItemModel.attrID isEqualToString:key]) {
                     itemModel.isHeaderSelected = YES;
                     subItemModel.isSelect = YES;
                     return;
                 }
             }
        }
    }
}

- (NSString *)firstCharactersCapitalized:(NSString *)string {
    if (ZFIsEmptyString(string)) {
        return @"";
    }
    
    string = [string lowercaseString];
    NSString *resultStr = [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] capitalizedString]];
    return resultStr;
}


#pragma mark - CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (self.hideCategoryRefineBlock) {
        self.mainView.hidden = YES;
        self.hideCategoryRefineBlock();
    }
}

#pragma mark - Property Method

- (void)setNativeRefineDataArray:(NSArray<ZFGeshopSiftItemModel *> *)nativeRefineDataArray {
    
    
    // 过滤掉子集为空的，除了价格项
    NSMutableArray *tempNativeArrays = [[NSMutableArray alloc] init];
    
    CGFloat kwidth = self.mainWidth - 12 * 2;
    
    for (int j=0; j<nativeRefineDataArray.count; j++) {
        ZFGeshopSiftItemModel *itemModel = nativeRefineDataArray[j];
        itemModel.isFirstShowLine = YES;
        
        // 如果是价格项，没有子集，自己造一个
        if ([itemModel.price_max integerValue] > 0) {
            itemModel.item_type = @"3";
            itemModel.typePrice = YES;
            
            NSArray *price_arrays = [[NSArray alloc] initWithObjects:itemModel, nil];
            itemModel.child_item = price_arrays;
        }

        ZFGeshopSiftItemModel *firstSubItemModel = itemModel.child_item.firstObject;
        if (firstSubItemModel) {
            
            // v5.4.0 特殊处理
            if ([firstSubItemModel.price_max integerValue] > 0 || [itemModel.price_max integerValue] > 0) {
                itemModel.item_type = @"3";
                itemModel.typePrice = YES;
            } else if(!ZFIsEmptyString(firstSubItemModel.item_color_code)) {
                itemModel.item_type = @"2";
            } else {
                itemModel.item_type = @"0";
            }
            
        }
        
        CGFloat tempSumWidth = 0;

        if([itemModel.item_type integerValue] == CategoryRefineCellTypeColor) {
            
            CGFloat tempColorW = 0;
            BOOL isShowTowLine = NO;
            
            for (int i=0; i<itemModel.child_item.count; i++) {
                ZFGeshopSiftItemModel *subItemModel = itemModel.child_item[i];
                subItemModel.editName = [self handeTitleCounts:subItemModel.item_title counts:subItemModel.item_count];
                subItemModel.itemsSize = [ZFCategoryRefineColorCCell contentSize:subItemModel.editName maxWidt:kwidth];
                
                tempSumWidth += subItemModel.itemsSize.width + 12;
                tempColorW += subItemModel.itemsSize.width + 12;
                
                
                if (!itemModel.isMultiLine && tempSumWidth > (kwidth + 12)) {
                    
                    // 能显示多行，设置一行个数
                    itemModel.isMultiLine = YES;
                    itemModel.firstShowCounts = i;
                    itemModel.isHeaderSelected = NO;
                    tempColorW = subItemModel.itemsSize.width + 12;
                    
                } else if(!itemModel.isMultiLine){
                    
                    // 不能显示多行，就设置全展开
                    itemModel.isHeaderSelected = YES;
                    itemModel.isFirstShowLine = NO;
                    
                } else if(itemModel.isMultiLine && j<=2 && tempColorW <= (kwidth + 12)) {
                    // 在前三的时候
                    itemModel.isHeaderSelected = YES;
                    itemModel.isFirstShowLine = NO;
                    
                } else if(j<=2 && itemModel.isMultiLine && tempColorW > (kwidth + 12) && !isShowTowLine) {
                    
                    // 颜色级别时，在前三的时候，设置首次显示两行
                    itemModel.isHeaderSelected = NO;
                    itemModel.isFirstShowLine = YES;
                    itemModel.firstShowCounts = i;
                    isShowTowLine = YES;
                }
            }
            
            if (itemModel.child_item.count > 0) {
                [tempNativeArrays addObject:itemModel];
            }
            
        }  else if([itemModel.item_type integerValue] == CategoryRefineCellTypePrice) {
            
            // 原生专题取默认值（也许是假的，后台自己控制）
            itemModel.isHeaderSelected = YES;
            for (int i=0; i<itemModel.child_item.count; i++) {
                ZFGeshopSiftItemModel *subItemModel = itemModel.child_item[i];
                subItemModel.typePrice = YES;
                subItemModel.itemsSize = [ZFCategoryRefinePriceCCell contentSize:subItemModel.item_title maxWidt:kwidth];
                subItemModel.isCurrentSelected = YES;
            }
            [tempNativeArrays addObject:itemModel];

        } else {
            for (int i=0; i<itemModel.child_item.count; i++) {
                ZFGeshopSiftItemModel *subItemModel = itemModel.child_item[i];
                subItemModel.editName = [self handeTitleCounts:subItemModel.item_title counts:subItemModel.item_count];
                subItemModel.itemsSize = [ZFCategoryRefineNormalCCell contentSize:subItemModel.editName maxWidt:kwidth];
                
                tempSumWidth += subItemModel.itemsSize.width + 12;
                
                if (tempSumWidth > (kwidth + 12) && !itemModel.isMultiLine) {
                    itemModel.isMultiLine = YES;
                    itemModel.firstShowCounts = i;
                    itemModel.isHeaderSelected = NO;
                } else if(!itemModel.isMultiLine){
                    itemModel.isHeaderSelected = YES;
                }
            }
            
            if (itemModel.child_item.count > 0) {
                [tempNativeArrays addObject:itemModel];
            }
        }
    }
    
    // 第一默认全显示
    if (tempNativeArrays.count > 0) {
        ZFGeshopSiftItemModel *firstItemModel = tempNativeArrays.firstObject;
        firstItemModel.isHeaderSelected = YES;
        firstItemModel.isFirstShowLine = NO;

    }
    
    _nativeRefineDataArray = [[NSArray alloc] initWithArray:tempNativeArrays];
    self.isFirstShow = YES;
    [self.collectView reloadData];
}

- (void)setCategoryRefineDataArray:(NSArray<CategoryRefineDetailModel *> *)categoryRefineDataArray {
    
    // 过滤掉子集为空的，除了价格项
    NSMutableArray *tempCategoryArrays = [[NSMutableArray alloc] init];
    
    CGFloat kwidth = self.mainWidth - 12 * 2;
    
    for (int j=0; j< categoryRefineDataArray.count; j++) {
        CategoryRefineDetailModel *itemModel = categoryRefineDataArray[j];
        itemModel.isFirstShowLine = YES;
        
        CGFloat tempSumWidth = 0;
        if([itemModel.type isEqualToString:@"service"]) {
            
            // 特殊处理 数量换行
            for (int i=0; i<itemModel.childArray.count; i++) {
                
                CategoryRefineCellModel *subItemModel = itemModel.childArray[i];
                
                if (ZFIsEmptyString(subItemModel.count)) {
                    subItemModel.editName = [self firstCharactersCapitalized:[NSString stringWithFormat:@"%@",ZFToString(subItemModel.name)]];
                    
                } else {
                    subItemModel.editName = [self firstCharactersCapitalized:[NSString stringWithFormat:@"%@\n(%@)",ZFToString(subItemModel.name),ZFToString(subItemModel.count)]];
                }
                // 特殊处理
                subItemModel.itemsSize = [ZFCategoryRefineSpecialCCell contentSize:subItemModel.name maxWidt:kwidth];
                tempSumWidth += subItemModel.itemsSize.width + 12;
                
                if (tempSumWidth > (kwidth + 12) && !itemModel.isMultiLine) {
                    itemModel.isMultiLine = YES;
                    itemModel.firstShowCounts = i;
                    itemModel.isHeaderSelected = NO;
                } else if(!itemModel.isMultiLine){
                    itemModel.isHeaderSelected = YES;
                }
            }
            
            if (itemModel.childArray.count > 0) {
                [tempCategoryArrays addObject:itemModel];
            }
            
        } else if([itemModel.type isEqualToString:@"color"]) {
            
            CGFloat tempColorW = 0;
            BOOL isShowTowLine = NO;
            for (int i=0; i<itemModel.childArray.count; i++) {
                CategoryRefineCellModel *subItemModel = itemModel.childArray[i];
                subItemModel.editName = [self handeTitleCounts:subItemModel.name counts:subItemModel.count];
                subItemModel.itemsSize = [ZFCategoryRefineColorCCell contentSize:subItemModel.editName maxWidt:kwidth];
                
                tempSumWidth += subItemModel.itemsSize.width + 12;
                tempColorW += subItemModel.itemsSize.width + 12;
                
                if (tempSumWidth > (kwidth + 12) && !itemModel.isMultiLine) {
                    
                    // 能显示多行，设置一行个数
                    itemModel.isMultiLine = YES;
                    itemModel.firstShowCounts = i;
                    itemModel.isHeaderSelected = NO;
                    tempColorW = subItemModel.itemsSize.width + 12;
                    
                } else if(!itemModel.isMultiLine){
                    
                    // 不能显示多行，就设置全展开
                    itemModel.isHeaderSelected = YES;
                    itemModel.isFirstShowLine = NO;
                    
                } else if(itemModel.isMultiLine && j<=2 && tempColorW <= (kwidth + 12)) {
                    // 在前三的时候,不足两行，显示全部
                    itemModel.isHeaderSelected = YES;
                    itemModel.isFirstShowLine = NO;
                               
                } else if(itemModel.isMultiLine && j<=2 && tempColorW > (kwidth + 12) && !isShowTowLine) {
                    
                    // 颜色级别时，在前三的时候，设置首次显示两行
                    itemModel.isHeaderSelected = NO;
                    itemModel.isFirstShowLine = YES;
                    itemModel.firstShowCounts = i;
                    isShowTowLine = YES;
                }
                
            }
            
            if (itemModel.childArray.count > 0) {
                [tempCategoryArrays addObject:itemModel];
            }
            
        }  else if([itemModel.type isEqualToString:@"price"]) {
            itemModel.isHeaderSelected = YES;
            for (CategoryRefineCellModel *subItemModel in itemModel.childArray) {
                subItemModel.typePrice = YES;
                subItemModel.isSelect = YES;
                subItemModel.itemsSize = [ZFCategoryRefinePriceCCell contentSize:subItemModel.editName maxWidt:kwidth];
                tempSumWidth += subItemModel.itemsSize.width + 12;
                
            }
            [tempCategoryArrays addObject:itemModel];
            
        } else if([itemModel.type isEqualToString:@"size"]){
            
            CGFloat tempColorW = 0;
            BOOL isShowTowLine = NO;

            for (int i=0; i<itemModel.childArray.count; i++) {
                CategoryRefineCellModel *subItemModel = itemModel.childArray[i];
                subItemModel.editName = [self handeTitleCounts:subItemModel.name counts:subItemModel.count];
                subItemModel.itemsSize = [ZFCategoryRefineNormalCCell contentSize:subItemModel.editName maxWidt:kwidth];
                tempSumWidth += subItemModel.itemsSize.width + 12;
                tempColorW += subItemModel.itemsSize.width + 12;
                
                if (tempSumWidth > (kwidth + 12) && !itemModel.isMultiLine) {
                    itemModel.isMultiLine = YES;
                    itemModel.firstShowCounts = i;
                    itemModel.isHeaderSelected = NO;
                    tempColorW = subItemModel.itemsSize.width + 12;
                    
                } else if(!itemModel.isMultiLine){
                    itemModel.isHeaderSelected = YES;
                    itemModel.isFirstShowLine = NO;
                    
                } else if(itemModel.isMultiLine && j<=2 && tempColorW <= (kwidth + 12)) {
                    itemModel.isHeaderSelected = YES;
                    itemModel.isFirstShowLine = NO;
                }
                else if(itemModel.isMultiLine && j<=2 && tempColorW > (kwidth + 12) && !isShowTowLine) {
                    
                    itemModel.isHeaderSelected = NO;
                    itemModel.isFirstShowLine = YES;
                    itemModel.firstShowCounts = i;
                    isShowTowLine = YES;
                }
            }
            
            if (itemModel.childArray.count > 0) {
                [tempCategoryArrays addObject:itemModel];
            }
            
        } else {
            
            for (int i=0; i<itemModel.childArray.count; i++) {
                CategoryRefineCellModel *subItemModel = itemModel.childArray[i];
                subItemModel.editName = [self handeTitleCounts:subItemModel.name counts:subItemModel.count];
                subItemModel.itemsSize = [ZFCategoryRefineNormalCCell contentSize:subItemModel.editName maxWidt:kwidth];
                tempSumWidth += subItemModel.itemsSize.width + 12;
                
                if (tempSumWidth > (kwidth + 12) && !itemModel.isMultiLine) {
                    itemModel.isMultiLine = YES;
                    itemModel.firstShowCounts = i;
                    itemModel.isHeaderSelected = NO;
                } else if(!itemModel.isMultiLine){
                    itemModel.isHeaderSelected = YES;
                }
            }
            
            if (itemModel.childArray.count > 0) {
                [tempCategoryArrays addObject:itemModel];
            }
        }
    }
    
    // 第一默认全显示
    if (tempCategoryArrays.count > 0) {
        CategoryRefineDetailModel *firstModel = tempCategoryArrays.firstObject;
        firstModel.isHeaderSelected = YES;
        firstModel.isFirstShowLine = NO;
    }
    
    _categoryRefineDataArray = [[NSArray alloc] initWithArray:tempCategoryArrays];
    self.isFirstShow = YES;
    [self.collectView reloadData];
}

- (NSString *)handeTitleCounts:(NSString *)title counts:(NSString *)counts {
    NSString *titleString = @"";
    if (ZFIsEmptyString(counts)) {
        titleString = [NSString stringWithFormat:@"%@",ZFToString(title)];

    } else {
        if ([counts integerValue] <= 0) {
            titleString = [NSString stringWithFormat:@"%@",ZFToString(title)];
        } else {
            titleString = [NSString stringWithFormat:@"%@(%@)",ZFToString(title),ZFToString(counts)];
        }
    }
    
    titleString = [self firstCharactersCapitalized:titleString];

    return titleString;
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
        _mainView.backgroundColor = ZFC0xFFFFFF();
    }
    return _mainView;
}

- (UIView *)bottomToolView {
    if (!_bottomToolView) {
        _bottomToolView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomToolView.backgroundColor = ZFC0xFFFFFF();
    }
    return _bottomToolView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitleColor:ZFC0x666666() forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _cancelButton.layer.cornerRadius = 2.0;
        _cancelButton.layer.masksToBounds = YES;
        _cancelButton.layer.borderWidth = 0.5;
        _cancelButton.layer.borderColor = ZFC0x666666().CGColor;
        [_cancelButton setTitle:ZFLocalizedString(@"GoodsRefine_VC_Clear", nil) forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.backgroundColor = ZFC0x2D2D2D();
        [_confirmButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        NSString *applySting = [ZFLocalizedString(@"Category_APPLY", nil) lowercaseString];
        applySting = [self firstCharactersCapitalized:applySting];
        
        [_confirmButton setTitle:[self firstCharactersCapitalized:applySting] forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(actionConfirm:) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.layer.cornerRadius = 2.0;
        _confirmButton.layer.masksToBounds = YES;

    }
    return _confirmButton;
}

- (UICollectionView *)collectView {
    if(!_collectView) {
        
        UICollectionViewLeftAlignedLayout *layout = [[UICollectionViewLeftAlignedLayout alloc] init];
        layout.minimumLineSpacing = 12;
        layout.minimumInteritemSpacing = 12;
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
        
        [_collectView registerClass:[ZFCategoryRefineColorCCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFCategoryRefineColorCCell.class)];
        [_collectView registerClass:[ZFCategoryRefinePriceCCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFCategoryRefinePriceCCell.class)];

        [_collectView registerClass:[ZFCategoryRefineNormalCCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFCategoryRefineNormalCCell.class)];
        [_collectView registerClass:[ZFCategoryRefineSpecialCCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFCategoryRefineSpecialCCell.class)];
    }
    
    return _collectView;
}


- (CABasicAnimation *)showRefineInfoViewAnimation {
    if (!_showRefineInfoViewAnimation) {
        _showRefineInfoViewAnimation = [CABasicAnimation animation];
        _showRefineInfoViewAnimation.keyPath = @"position.x";
        _showRefineInfoViewAnimation.fromValue = [SystemConfigUtils isRightToLeftShow] ? @(-KScreenWidth * 0.5) : @(KScreenWidth * 1.5);
        _showRefineInfoViewAnimation.toValue = [SystemConfigUtils isRightToLeftShow] ?  @(self.mainWidth / 2) : @(self.mainWidth / 2 + 55);
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
        _hideRefineInfoViewAnimation.fromValue = [SystemConfigUtils isRightToLeftShow] ? @(self.mainWidth / 2) : @(self.mainWidth / 2 + 55);
        _hideRefineInfoViewAnimation.toValue = [SystemConfigUtils isRightToLeftShow] ? @(-KScreenWidth * 0.5) : @(KScreenWidth * 1.5);
        _hideRefineInfoViewAnimation.duration = kCategoryRefineNewAnimatonTime;
        _hideRefineInfoViewAnimation.removedOnCompletion = NO;
        _hideRefineInfoViewAnimation.fillMode = kCAFillModeForwards;
        _hideRefineInfoViewAnimation.delegate = self;
    }
    return _hideRefineInfoViewAnimation;
}


@end
