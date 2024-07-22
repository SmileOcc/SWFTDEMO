//
//  ZFAddressCountryCitySelectVC.m
//  ZZZZZ
//
//  Created by YW on 2019/1/7.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAddressCountryCitySelectVC.h"

#import "ZFInitViewProtocol.h"
#import "ZFAddressCountryCitySearchView.h"
#import "ZFAddressCountryCityStateView.h"
#import "ZFAddressCountryCityCell.h"
#import "ZFAddressSectionKeyHeaderView.h"

#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIView+LayoutMethods.h"
#import <Masonry/Masonry.h>
#import "ZFLocalizationString.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "ZFProgressHUD.h"
#import <YYWebImage/YYWebImage.h>
#import "UIButton+ZFButtonCategorySet.h"

#import "ZFCommuntityGestureTableView.h"
#import "ZFAddressLibraryManager.h"
#import "NSStringUtils.h"
#import "ZFButton.h"

static NSInteger kZFAddressCountryCitySelectTableViewTag = 1000;


@interface ZFAddressCountryCitySelectVC ()
<ZFInitViewProtocol,
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate>

@property (nonatomic, strong) UIView                                            *backgroundView;

@property (nonatomic, strong) UIView                                            *topView;
@property (nonatomic, strong) UILabel                                           *titleLabel;
@property (nonatomic, strong) UIButton                                          *closeButton;
@property (nonatomic, strong) UITextField                                       *searchBar;
@property (nonatomic, strong) ZFAddressCountryCitySearchView                    *searchResultView;
@property (nonatomic, strong) UIScrollView                                      *scrollView;
@property (nonatomic, strong) ZFAddressCountryCityStateView                     *selectStateView;
@property (nonatomic, strong) UIView                                            *lineView;

/** 空视图*/
@property (nonatomic, strong) UIView                                            *emptyView;
@property (nonatomic, strong) YYAnimatedImageView                               *emptyImageView;
@property (nonatomic, strong) UILabel                                           *emptyLabel;
@property (nonatomic, strong) UIButton                                          *emptyButton;

@property(nonatomic, strong) NSIndexPath                                        *countryPath;
@property(nonatomic, strong) NSIndexPath                                        *statePath;
@property(nonatomic, strong) NSIndexPath                                        *cityPath;
@property(nonatomic, strong) NSIndexPath                                        *townPath;

/** 顶部间隙 */
@property (nonatomic, assign) CGFloat                                           topGapHeight;
/** 数据是否重置*/
@property (nonatomic, assign) BOOL                                              isResetCountryGroupData;

/** 是为了显示动画过程中，加载loading显示及隐藏太快，视觉效果不太好*/
@property (nonatomic, assign) BOOL                                              isStartRequest;

@end

@implementation ZFAddressCountryCitySelectVC

#pragma mark - Life Cycle

- (void)showParentController:(UIViewController *)parentViewController topGapHeight:(CGFloat)topGapHeight {
    
    dispatch_async(dispatch_get_main_queue(), ^{

        ZFAddressCountryCitySelectTransitionDelegate *transitionDelegate = [[ZFAddressCountryCitySelectTransitionDelegate alloc] init];
        self.modalTransitionStyle = UIModalPresentationCustom;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.transitionDelegate = transitionDelegate;
        self.transitioningDelegate = transitionDelegate;
        self.topGapHeight = topGapHeight;
        transitionDelegate.height = KScreenHeight - self.topGapHeight;
        
        if (parentViewController) {
            [parentViewController presentViewController:self animated:YES completion:nil];
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zfInitView];
    [self zfAutoLayoutView];
    
    /** 是为了显示动画过程中，加载loading显示及隐藏太快，视觉效果不太好*/
}

- (void)setIsStartRequest:(BOOL)isStartRequest {
    _isStartRequest = isStartRequest;
    [self requestCountryIsFirst:YES];
}

- (void)requestCountryIsFirst:(BOOL)isFirst{
    
    NSInteger ignore = [self ignoreAddressRank];
    //1111^1111=0000
    if ((ignore^ZFAddressLibraryIgnoreLeveCondifion) == 0) {//第四级只会第一次是四级地址进入时，
        [self reloadLocalAddressTable:isFirst];
        
    } else {
        
        if (self.countryModel.provinceList.count > 0 && self.stateModel.cityList.count > 0 && self.cityModel.town_list.count > 0) {//选择第三级城市
            [self reloadLocalAddressTable:isFirst];
        } else if(self.countryModel.provinceList.count > 0 && self.stateModel.cityList.count > 0 && !self.cityModel) {//选择第二级州省
            [self reloadLocalAddressTable:isFirst];
        } else if(self.countryModel.provinceList.count > 0 && !self.stateModel) {//选择一级国家
            [self reloadLocalAddressTable:isFirst];
        } else {

            NSDictionary *params = @{
                                     @"country_name"   :   ZFToString(self.countryModel.n),
                                     @"state"          :   ZFToString(self.stateModel.n),
                                     @"city"           :   ZFToString(self.cityModel.n),
                                     @"town"           :   ZFToString(self.townModel.n),
                                     @"is_child"        :   isFirst ? @"0" : @"1",
                                     @"ignore"         :   [NSString stringWithFormat:@"%li",ignore],
                                     @"is_order"       : self.isOrderUpdate ? @"1" : @"0",
                                     };
            
            ShowLoadingToView(self.view);
            
            @weakify(self)
            [ZFAddressLibraryManager requestAreaLinkAge:params completion:^(ZFAddressCountryResultModel *resultModel) {
                @strongify(self)

                [self removeAgainRequestView];
                [self handelResult:resultModel isFirst:isFirst];

            } failure:^(id obj) {
                if (isFirst) {
                    [self showAgainRequestView];
                }
            }];
        }
        
    }
}

- (void)handelResult:(ZFAddressCountryResultModel *)resultModel isFirst:(BOOL)isFirst{
    
    // 判断请求返回数据是否结束
    if (!isFirst && [self isEndSelectAddress:resultModel]) {
        HideLoadingFromView(self.view);
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @weakify(self)
        double startTime = [NSStringUtils getCurrentMSimestamp].doubleValue;

        [[ZFAddressLibraryManager manager] handleCountryGroupDatas:resultModel.country];
        [[ZFAddressLibraryManager manager] handleStateGroupDatas:resultModel.state country:self.countryModel resultBlock:^(ZFAddressLibraryCountryModel *countryModel) {
            @strongify(self)
            self.countryModel = countryModel;
        }];
        [[ZFAddressLibraryManager manager] handleCityGroupDatas:resultModel.city country:self.countryModel state:self.stateModel resultBlock:^(ZFAddressLibraryStateModel *stateModel) {
            @strongify(self)
            self.stateModel = stateModel;
        }];
        [[ZFAddressLibraryManager manager] handleTownGroupDatas:resultModel.town country:self.countryModel state:self.stateModel city:self.cityModel resultBlock:^(ZFAddressLibraryCityModel *cityModel) {
            @strongify(self)
            self.cityModel = cityModel;
        }];
        
        double endTime = [NSStringUtils getCurrentMSimestamp].doubleValue;
        double time = endTime - startTime;
        YWLog(@"-------------cccccc handelResult: %f",time);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            HideLoadingFromView(self.view);
            [self reloadLocalAddressTable:isFirst];
        });
    });
}

- (void)reloadLocalAddressTable:(BOOL)isFirst {
    
    if (isFirst) {//第一次进入
        
        [self firstCountryListHandle];
        
        UITableView *country = [self.scrollView viewWithTag:kZFAddressCountryCitySelectTableViewTag];
        [country reloadData];
        
        if (self.countryPath) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self addressTable:country scrollToIndex:self.countryPath];
            });
        }
        
        // 异常数据，防止滚动的级别没数据
        NSInteger tempSelectIndex = 0;
        if (!ZFIsEmptyString(self.stateModel.idx) || self.countryModel.provinceList.count > 0) {
            tempSelectIndex = 1;
            [self selectCountryInit:YES changeSelect:NO];
        }
        
        if (!ZFIsEmptyString(self.cityModel.idx) || self.stateModel.cityList.count > 0) {
            tempSelectIndex = 2;
            [self selectProvinceInit:YES changeSelect:NO];
        }
        
        if (!ZFIsEmptyString(self.townModel.idx) || self.cityModel.town_list.count > 0) {
            tempSelectIndex = 3;
            [self selectTownInit:YES changeSelect:NO];
        }
        
        if (self.selectIndex > tempSelectIndex) {
            self.selectIndex = tempSelectIndex;
        }
        [self changeTableViewWith:self.selectIndex];
        [self.selectStateView selectIndex:self.selectIndex];
        
    } else {
        
        // 选处理当前选择的，在处理对应下级数据
        if(self.countryModel.provinceList.count > 0) {
            [self resetRefreshCountryIndexPath];
            [self selectCountryInit:NO changeSelect:YES];
        }
        
        if (self.stateModel.cityList.count > 0) {
            [self resetRefreshStateIndexPath];
            [self selectProvinceInit:NO changeSelect:YES];
        }
        
        if (self.cityModel.town_list.count > 0) {
            [self resetRefreshCityIndexPath];
            [self selectTownInit:NO changeSelect:YES];
        }
    }
}


/**
 判断请求返回数据没子集，是否结束
 */
- (BOOL)isEndSelectAddress:(ZFAddressCountryResultModel *)resutleModel {
    
    BOOL hasEnd = NO;
    if (!ZFIsEmptyString(self.townModel.n) && !ZFIsEmptyString(self.townModel.idx)) {//选择城镇结束
        self.addressCountrySelectCompletionHandler(self.countryModel, self.stateModel, self.cityModel, self.townModel);
        hasEnd = YES;
        
    } else if (!ZFIsEmptyString(self.cityModel.n) && !ZFIsEmptyString(self.cityModel.idx)) {
        if (resutleModel.town.count <= 0) {//选择城市，返回数据没子集结束
            self.addressCountrySelectCompletionHandler(self.countryModel, self.stateModel, self.cityModel, nil);
            hasEnd = YES;
        }
    } else if (!ZFIsEmptyString(self.stateModel.n) && !ZFIsEmptyString(self.stateModel.idx)) {
        if (resutleModel.city.count <= 0) {//选择州省，返回数据没子集结束
            self.addressCountrySelectCompletionHandler(self.countryModel, self.stateModel, nil, nil);
            hasEnd = YES;
        }
    } else if (!ZFIsEmptyString(self.countryModel.n) && !ZFIsEmptyString(self.countryModel.idx)) {
        if (resutleModel.state.count <= 0) {//选择国家，返回数据没子集结束
            self.addressCountrySelectCompletionHandler(self.countryModel, self.stateModel, nil, nil);
            hasEnd = YES;
        }
    }
    
    if (hasEnd) {
        [self actionClose:nil];
    }
    return hasEnd;
}


/**
 查询默认选中国家
 */
- (void)firstCountryListHandle {
    
    if (!self.countryPath && !ZFIsEmptyString(self.countryModel.n) && !ZFIsEmptyString(self.countryModel.idx)) {//查找默认选中国家
        
        NSString *key = [ZFAddressLibraryManager sectionKey:self.countryModel.k];
        NSInteger sectionIndex = [[ZFAddressLibraryManager manager].countryGroupKeys indexOfObject:key];
        NSArray <ZFAddressLibraryCountryModel*> *countryArray = [[ZFAddressLibraryManager manager].countryGroupDic objectForKey:key];
        
        [countryArray enumerateObjectsUsingBlock:^(ZFAddressLibraryCountryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self.countryModel.n isEqualToString:obj.n]) {
                self.countryModel = obj;
                self.countryPath = [NSIndexPath indexPathForRow:idx inSection:sectionIndex];
                *stop = YES;
            }
        }];
    }
}

#pragma mark - Action

- (void)actionClose:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)doneButtonAction:(UIButton *)sender {
    [self.view endEditing:YES];
}

- (void)actionRefresh:(UIButton *)sender {
    [self requestCountryIsFirst:YES];
}

- (void)actionSelectAddress:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    
    if (self.addressCountrySelectCompletionHandler) {
        if (tableView.tag == kZFAddressCountryCitySelectTableViewTag) {
            ZFAddressLibraryCountryModel *model;
            if ([ZFAddressLibraryManager manager].countryGroupKeys.count > indexPath.section) {
                NSString *key = [ZFAddressLibraryManager manager].countryGroupKeys[indexPath.section];
                NSArray *countryArray = [[ZFAddressLibraryManager manager].countryGroupDic objectForKey:key];
                if (ZFJudgeNSArray(countryArray)) {
                    if (countryArray.count > indexPath.row) {
                        model = countryArray[indexPath.row];
                    }
                }
            }
            //若选择不同的
            if (![model.n isEqualToString:self.countryModel.n]) {
                self.isResetCountryGroupData = NO;
                
                self.countryPath = indexPath;
                self.countryModel = model;
                [tableView reloadData];
                
                self.statePath = nil;
                self.stateModel = nil;
                
                self.cityPath = nil;
                self.cityModel = nil;
                
                self.townPath = nil;
                self.townModel = nil;
                
                [self requestCountryIsFirst:NO];
                
            } else {
                //若选择的有下级数据
                if (self.countryModel.provinceList.count>0) {
                    [self selectCountryInit:NO changeSelect:NO];
                } else {
                    //若选择的没有下级数据，结束
                    self.addressCountrySelectCompletionHandler(self.countryModel, nil, nil, nil);
                    [self actionClose:nil];
                }
            }
            
        } else if(tableView.tag == kZFAddressCountryCitySelectTableViewTag + 1) {
            
            if (self.countryModel.sectionKeys.count > indexPath.section) {
                NSString *key = self.countryModel.sectionKeys[indexPath.section];
                NSArray *sectionStatesArray = [self.countryModel sectionDatasForKey:key];
                
                if (sectionStatesArray.count > indexPath.row) {
                    
                    ZFAddressLibraryStateModel *model = sectionStatesArray[indexPath.row];
                    
                    if (![self.stateModel.n isEqualToString:model.n]) {
                        
                        self.statePath = indexPath;
                        self.stateModel = model;
                        [tableView reloadData];
                        
                        self.cityPath = nil;
                        self.cityModel = nil;
                        
                        self.townPath = nil;
                        self.townModel = nil;
                        
                        //请求数据
                        [self requestCountryIsFirst:NO];
                    } else {
                        
                        if (self.stateModel.cityList.count>0) {
                            [self selectProvinceInit:NO changeSelect:NO];
                        } else {
                            self.addressCountrySelectCompletionHandler(self.countryModel, self.stateModel, nil, nil);
                            [self actionClose:nil];
                        }
                    }
                }
            }
            
        } else if(tableView.tag == kZFAddressCountryCitySelectTableViewTag + 2) {
            
            if (self.stateModel.sectionKeys.count > indexPath.section) {
                NSString *key = self.stateModel.sectionKeys[indexPath.section];
                NSArray *sectionCityArray = [self.stateModel sectionDatasForKey:key];
                
                if (sectionCityArray.count > indexPath.row) {
                    
                    ZFAddressLibraryCityModel *model = sectionCityArray[indexPath.row];
                    
                    if (![self.cityModel.n isEqualToString:model.n]) {
                        
                        self.cityPath = indexPath;
                        self.cityModel = model;
                        [tableView reloadData];
                        
                        self.townPath = nil;
                        self.townModel = nil;
                        
                        //请求数据
                        [self requestCountryIsFirst:NO];
                    } else {
                        
                        if (self.cityModel.town_list.count > 0) {
                            [self selectTownInit:NO changeSelect:NO];
                        } else {
                            self.addressCountrySelectCompletionHandler(self.countryModel, self.stateModel, self.cityModel, nil);
                            [self actionClose:nil];
                        }
                    }
                }
            }
            
        } else if(tableView.tag == kZFAddressCountryCitySelectTableViewTag + 3) {
            
            if (self.cityModel.sectionKeys.count > indexPath.section) {
                NSString *key = self.cityModel.sectionKeys[indexPath.section];
                NSArray *sectionVillageArray = [self.cityModel sectionDatasForKey:key];
                
                if (sectionVillageArray.count > indexPath.row) {
                    
                    ZFAddressLibraryTownModel *villageModel = sectionVillageArray[indexPath.row];
                    self.townPath = indexPath;
                    self.townModel = villageModel;
                    
                    self.addressCountrySelectCompletionHandler(self.countryModel, self.stateModel, self.cityModel, self.townModel);
                    [self actionClose:nil];
                }
            }
        }
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *list = [self currentTableKeys:tableView];
    return list.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionDatas;
    if (tableView.tag == kZFAddressCountryCitySelectTableViewTag) {
        if ([ZFAddressLibraryManager manager].countryGroupKeys.count > section) {
            NSString *key = [ZFAddressLibraryManager manager].countryGroupKeys[section];
            sectionDatas = [[ZFAddressLibraryManager manager].countryGroupDic objectForKey:key];
        }
    } else if(tableView.tag == kZFAddressCountryCitySelectTableViewTag + 1) {
        if (self.countryModel.sectionKeys.count > section) {
            NSString *key = self.countryModel.sectionKeys[section];
            sectionDatas = [self.countryModel sectionDatasForKey:key];
        }
    } else if(tableView.tag == kZFAddressCountryCitySelectTableViewTag + 2) {
        if (self.stateModel.sectionKeys.count > section) {
            NSString *key = self.stateModel.sectionKeys[section];
            sectionDatas = [self.stateModel sectionDatasForKey:key];
        }
    } else if(tableView.tag == kZFAddressCountryCitySelectTableViewTag + 3) {
        if (self.cityModel.sectionKeys.count > section) {
            NSString *key = self.cityModel.sectionKeys[section];
            sectionDatas = [self.cityModel sectionDatasForKey:key];
        }
    }
    return ZFJudgeNSArray(sectionDatas) ? sectionDatas.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFAddressCountryCityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZFAddressCountryCityCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (tableView.tag == kZFAddressCountryCitySelectTableViewTag) {
        if ([ZFAddressLibraryManager manager].countryGroupKeys.count > indexPath.section) {
            NSString *key = [ZFAddressLibraryManager manager].countryGroupKeys[indexPath.section];
            NSArray *countryArray = [[ZFAddressLibraryManager manager].countryGroupDic objectForKey:key];
            if (ZFJudgeNSArray(countryArray)) {
                if (countryArray.count > indexPath.row) {
                    ZFAddressLibraryCountryModel *countryModel = countryArray[indexPath.row];
                    cell.nameLabel.text = ZFToString(countryModel.n);
                    cell.selectImageView.hidden = [countryModel.n isEqualToString:self.countryModel.n] ? NO : YES;
                }
            }
        }
    } else if(tableView.tag == kZFAddressCountryCitySelectTableViewTag + 1) {
        if (self.countryModel.sectionKeys.count > indexPath.section) {
            NSString *key = self.countryModel.sectionKeys[indexPath.section];
            NSArray *sectionStatesArray = [self.countryModel sectionDatasForKey:key];
            
            if (sectionStatesArray.count > indexPath.row) {
                ZFAddressLibraryStateModel *stateModel = sectionStatesArray[indexPath.row];
                cell.nameLabel.text = ZFToString(stateModel.n);
                cell.selectImageView.hidden = [stateModel.n isEqualToString:self.stateModel.n] ? NO : YES;
            }
        }
    } else if(tableView.tag == kZFAddressCountryCitySelectTableViewTag + 2) {
        if (self.stateModel.sectionKeys.count > indexPath.section) {
            NSString *key = self.stateModel.sectionKeys[indexPath.section];
            NSArray *sectionCityArray = [self.stateModel sectionDatasForKey:key];
            
            if (sectionCityArray.count > indexPath.row) {
                ZFAddressLibraryCityModel *cityModel = sectionCityArray[indexPath.row];
                cell.nameLabel.text = cityModel.n;
                cell.selectImageView.hidden = [cityModel.n isEqualToString:self.cityModel.n] ? NO : YES;
            }
        }
    } else if(tableView.tag == kZFAddressCountryCitySelectTableViewTag + 3) {
        if (self.cityModel.sectionKeys.count > indexPath.section) {
            NSString *key = self.cityModel.sectionKeys[indexPath.section];
            NSArray *sectionVillageArray = [self.cityModel sectionDatasForKey:key];
            
            if (sectionVillageArray.count > indexPath.row) {
                ZFAddressLibraryTownModel *villageModel = sectionVillageArray[indexPath.row];
                cell.nameLabel.text = villageModel.n;
                cell.selectImageView.hidden = [villageModel.n isEqualToString:self.townModel.n] ? NO : YES;
            }
        }
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ZFAddressSectionKeyHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([ZFAddressSectionKeyHeaderView class])];
    [header sectionHeader:[self currentTableKeys:tableView] section:section];
    return header;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self currentTableKeys:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    [(ZFCountryTableView *)tableView refreshFloatIndexView:title index:index];
    return index;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self actionSelectAddress:tableView indexPath:indexPath];
}

- (NSArray *)currentTableKeys:(UITableView *)tableView {
    
    NSArray *currentKeys;
    if (tableView.tag == kZFAddressCountryCitySelectTableViewTag) {
        currentKeys = [ZFAddressLibraryManager manager].countryGroupKeys;
        
    } else if(tableView.tag == kZFAddressCountryCitySelectTableViewTag + 1) {
        currentKeys = self.countryModel.sectionKeys;
        
    } else if(tableView.tag == kZFAddressCountryCitySelectTableViewTag + 2) {
        currentKeys = self.stateModel.sectionKeys;

    } else if(tableView.tag == kZFAddressCountryCitySelectTableViewTag + 3) {
        currentKeys = self.cityModel.sectionKeys;
    }
    return ZFJudgeNSArray(currentKeys) ? currentKeys : @[];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger tag = scrollView.tag;
    
    if (tag == kZFAddressCountryCitySelectTableViewTag
        || tag == kZFAddressCountryCitySelectTableViewTag + 1
        || tag == kZFAddressCountryCitySelectTableViewTag + 2
        || tag == kZFAddressCountryCitySelectTableViewTag + 3) {
        [self.view endEditing:YES];
        self.searchResultView.hidden = YES;
    }
    
    /// 刷新右侧滑动index
    if ([scrollView isMemberOfClass:[ZFCountryTableView class]]) {
        ZFCountryTableView *tableView = (ZFCountryTableView *)scrollView;

        NSArray *visallCell = tableView.visibleCells;
        UITableViewCell *firstCell = visallCell.firstObject;
        if (firstCell) {
            NSArray *keysArray = [self currentTableKeys:tableView];
            
            NSIndexPath *indexPath = [tableView indexPathForCell:firstCell];
            if (indexPath && keysArray.count > indexPath.section) {
                NSString *title = keysArray[indexPath.section];
                
                if (title && ![tableView.currentTitle isEqualToString:title]) {
                    [tableView refreshFloatIndexView:title index:indexPath.section];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        [self changeTableViewWith:scrollView.contentOffset.x / KScreenWidth];
        [self.selectStateView selectIndex:self.selectIndex];
    }
}

- (void)changeTableViewWith:(NSInteger)index {
    [self.view endEditing:YES];
    self.searchResultView.hidden = YES;
    self.selectIndex = index;
    [self.selectStateView selectIndex:index];
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.width * index, 0) animated:YES];
}


#pragma mark - Textfield Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    NSString *searchKey = [NSStringUtils trimmingStartEndWhitespace:textField.text];
    if (searchKey.length == 0 || [ZFAddressLibraryManager manager].countryList.count == 0) {
        self.searchResultView.hidden = YES;
    } else {
        //筛选处理数据源
        self.searchResultView.searchKey = searchKey;
        self.searchResultView.dataArray = [self smartMatchSearchResultWithKey:searchKey];
        self.searchResultView.hidden = NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *searchKey = [textField.text mutableCopy];
    [searchKey replaceCharactersInRange:range withString:string];
    
    NSString *searchResultKey = [NSStringUtils trimmingStartEndWhitespace:searchKey];
    if (searchResultKey.length == 0 || [ZFAddressLibraryManager manager].countryList.count == 0) {
        self.searchResultView.hidden = YES;
    } else {
        //筛选处理数据源
        self.searchResultView.searchKey = searchResultKey;
        self.searchResultView.dataArray = [self smartMatchSearchResultWithKey:searchResultKey];
        self.searchResultView.hidden = NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.searchResultView.hidden = YES;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (NSMutableArray *)smartMatchSearchResultWithKey:(NSString *)key {
    
    NSArray *tempArr = nil;
    if (self.selectIndex == 0) {
        tempArr = [ZFAddressLibraryManager manager].countryList;
    } else if(self.selectIndex == 1) {
        tempArr = self.countryModel.provinceList;
    } else if(self.selectIndex == 2) {
        tempArr = self.stateModel.cityList;
    } else if(self.selectIndex == 3) {
        tempArr = self.cityModel.town_list;
    }
    
    NSMutableArray *searchResult = [ZFAddressLibraryManager smartMatchSearchList:tempArr searchKey:key];
    return searchResult;
}

#pragma mark - Private Method

- (void)zfInitView {
    self.view.backgroundColor = ZFC0xFFFFFF();

    [self.view addSubview:self.topView];
    [self.topView addSubview:self.titleLabel];
    [self.topView addSubview:self.closeButton];
    [self.topView addSubview:self.searchBar];
    [self.topView addSubview:self.lineView];
    [self.view addSubview:self.selectStateView];
    
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.searchResultView];
}

- (void)zfAutoLayoutView {
    
    CGFloat selectStateViewHeight = !ZFIsEmptyString(self.stateModel.idx) ? 56 : 0;

    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.view);
        make.height.mas_equalTo(93);
    }];
    
    [self.selectStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.topView);
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.height.mas_equalTo(selectStateViewHeight);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.selectStateView.mas_bottom);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.topView.mas_trailing).offset(-10);
        make.top.mas_equalTo(self.topView.mas_top);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.topView.mas_centerX);
        make.height.mas_equalTo(20);
        make.top.mas_equalTo(self.topView.mas_top).offset(14);
    }];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(14);
        make.leading.mas_equalTo(self.topView.mas_leading).offset(8);
        make.trailing.mas_equalTo(self.topView.mas_trailing).offset(-8);
        make.height.mas_equalTo(36);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.topView);
        make.height.mas_equalTo(1);
    }];
    
    [self creatTableView];

    [self.searchResultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.selectStateView.mas_bottom);
    }];
    
}

- (CGFloat)defaultSrollViewHeight {
    CGFloat selectStateViewHeight = self.stateModel ? 56 : 0;
    return KScreenHeight - self.topGapHeight - 93 - selectStateViewHeight;
}

- (void)creatTableView {
    for (int i = 0; i < 4; i++) {
        ZFCountryTableView *tableView = [[ZFCountryTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [tableView registerClass:[ZFAddressCountryCityCell class] forCellReuseIdentifier:@"ZFAddressCountryCityCell"];
        [tableView registerClass:[ZFAddressSectionKeyHeaderView class] forHeaderFooterViewReuseIdentifier:NSStringFromClass([ZFAddressSectionKeyHeaderView class])];

        tableView.estimatedSectionFooterHeight = 0;
        tableView.sectionIndexColor = ZFC0x999999();
        tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
        tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        tableView.sectionHeaderHeight = 36;
        
        tableView.rowHeight = 48;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tag = kZFAddressCountryCitySelectTableViewTag + i;
        tableView.frame = CGRectMake(self.scrollView.width * i, 0, self.scrollView.width, self.scrollView.height);
        [self.scrollView addSubview:tableView];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            tableView.transform = CGAffineTransformMakeRotation(M_PI);
        }
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width, 0);
}


#pragma mark - 重置
// 筛选国家重置
- (void)resetRefreshCountryIndexPath {
    
    self.countryPath = nil;
    if (!ZFIsEmptyString(self.countryModel.n) && !ZFIsEmptyString(self.countryModel.idx)) {
        
        NSString *key = [ZFAddressLibraryManager sectionKey:self.countryModel.k];
        NSInteger indexSection = [[ZFAddressLibraryManager manager].countryGroupKeys indexOfObject:key];
        NSArray <ZFAddressLibraryCountryModel*> *countryArray = [[ZFAddressLibraryManager manager].countryGroupDic objectForKey:key];
        [countryArray enumerateObjectsUsingBlock:^(ZFAddressLibraryCountryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([self.countryModel.n isEqualToString:obj.n]) {
                self.countryPath = [NSIndexPath indexPathForRow:idx inSection:indexSection];
                *stop = YES;
            }
        }];
    }
    
    UITableView *currentTable = [self.scrollView viewWithTag:kZFAddressCountryCitySelectTableViewTag];
    [currentTable reloadData];
    
    if (self.countryPath) {
        //[currentTable scrollToRowAtIndexPath:self.countryPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [self addressTable:currentTable scrollToIndex:self.countryPath];
    }
}

// 筛选州、省重置
- (void)resetRefreshStateIndexPath {

    __block NSInteger row = 0;
    
    NSString *firstCharactor = [ZFAddressLibraryManager sectionKey:self.stateModel.k];
    NSInteger section = [self.countryModel.sectionKeys indexOfObject:firstCharactor];
    NSArray *currentCountryStateLists = [self.countryModel.sectionProvinceDic objectForKey:firstCharactor];
    [currentCountryStateLists enumerateObjectsUsingBlock:^(ZFAddressLibraryStateModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.n isEqualToString:self.stateModel.n]) {
            row = idx;
            *stop = YES;
            self.stateModel = obj;
        }
    }];
    
    self.statePath = [NSIndexPath indexPathForRow:row inSection:section];
    
    UITableView *currentTable = [self.scrollView viewWithTag:kZFAddressCountryCitySelectTableViewTag + 1];
    [currentTable reloadData];
    [self addressTable:currentTable scrollToIndex:self.statePath];
}

// 筛选城、镇重置
- (void)resetRefreshCityIndexPath {

    __block NSInteger row = 0;
    NSString *firstCharactor = [ZFAddressLibraryManager sectionKey:self.cityModel.k];
    NSInteger section = [self.stateModel.sectionKeys indexOfObject:firstCharactor];
    
    NSArray *currentCountryStateLists = [self.stateModel.sectionCityDic objectForKey:firstCharactor];
    [currentCountryStateLists enumerateObjectsUsingBlock:^(ZFAddressLibraryCityModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.n isEqualToString:self.cityModel.n]) {
            row = idx;
            *stop = YES;
            self.cityModel = obj;
        }
    }];
    
    self.cityPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    UITableView *currentTable = [self.scrollView viewWithTag:kZFAddressCountryCitySelectTableViewTag + 2];
    [currentTable reloadData];
    [self addressTable:currentTable scrollToIndex:self.cityPath];
}

// 筛选四级、行政农村重置
- (void)resetRefreshTownIndexPath {
    
    __block NSInteger row = 0;
    NSString *firstCharactor = [ZFAddressLibraryManager sectionKey:self.townModel.k];
    NSInteger section = [self.cityModel.sectionKeys indexOfObject:firstCharactor];
    
    NSArray *currentCountryStateLists = [self.cityModel.sectionVillageDic objectForKey:firstCharactor];
    [currentCountryStateLists enumerateObjectsUsingBlock:^(ZFAddressLibraryTownModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.n isEqualToString:self.townModel.n]) {
            row = idx;
            *stop = YES;
            self.townModel = obj;
        }
    }];
    
    self.townPath = [NSIndexPath indexPathForRow:row inSection:section];
    
    UITableView *currentTable = [self.scrollView viewWithTag:kZFAddressCountryCitySelectTableViewTag + 3];
    [currentTable reloadData];
    [self addressTable:currentTable scrollToIndex:self.townPath];
}


#pragma mark - 选择
/**
选择国家

 @param isInit 初始为YES时，isChange不生效
 @param isChange 是否改变
 */
- (void)selectCountryInit:(BOOL)isInit changeSelect:(BOOL)isChange {
    
    //重置高度
    if (CGRectGetHeight(self.selectStateView.frame) < 56) {
        [self.selectStateView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(56);
        }];
    }
    
    for (UIView *view in self.scrollView.subviews) {
        CGFloat topViewHeight = 93 + 56;
        view.height = KScreenHeight - self.topGapHeight - topViewHeight;
    }
    
    UITableView *nextTable = [self.scrollView viewWithTag:kZFAddressCountryCitySelectTableViewTag + 1];

    if (isInit) {//首次默认初始
        
        NSString *state = self.stateModel.n.length>0 ? self.stateModel.n : ZFLocalizedString(@"modifyAddress_countryCity_state", nil);
        [self.selectStateView setTitlesArray:@[ZFToString(self.countryModel.n),state]];
        self.scrollView.contentSize = CGSizeMake(self.scrollView.width*2,0);
        
        if (!ZFIsEmptyString(self.stateModel.n) && !ZFIsEmptyString(self.stateModel.idx)) {
            
            __block NSInteger row = 0;
            NSString *firstCharactor = [ZFAddressLibraryManager sectionKey:self.stateModel.k];
            NSInteger section = [self.countryModel.sectionKeys indexOfObject:firstCharactor];
            NSArray *currentCountryStateLists = [self.countryModel.sectionProvinceDic objectForKey:firstCharactor];
            
            [currentCountryStateLists enumerateObjectsUsingBlock:^(ZFAddressLibraryStateModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.n isEqualToString:self.stateModel.n]) {
                    row = idx;
                    *stop = YES;
                    self.stateModel = obj;
                }
            }];
            self.statePath = [NSIndexPath indexPathForRow:row inSection:section];
        }
        
        
    } else {
        
        if (isChange) {
            NSString *state = self.stateModel.n.length>0 ? self.stateModel.n : ZFLocalizedString(@"modifyAddress_countryCity_state", nil);
            [self.selectStateView setTitlesArray:@[ZFToString(self.countryModel.n),state]];
            self.scrollView.contentSize = CGSizeMake(self.scrollView.width*2,0);
        }
        [self changeTableViewWith:1];
    }

    [nextTable reloadData];
    [self addressTable:nextTable scrollToIndex:self.statePath];
}


/**
 选择州、省

 @param isInit 初始为YES时，isChange不生效
 @param isChange 是否改变
 */
- (void)selectProvinceInit:(BOOL)isInit changeSelect:(BOOL)isChange {
    
    UITableView *nextTable = [self.scrollView viewWithTag:kZFAddressCountryCitySelectTableViewTag + 2];
    if (isInit) {
        self.scrollView.contentSize = CGSizeMake(self.scrollView.width * 3, 0);
        NSString *city = self.cityModel.n.length>0 ? self.cityModel.n : ZFLocalizedString(@"modifyAddress_countryCity_city", nil);

        [self.selectStateView setTitlesArray:@[ZFToString(self.countryModel.n),ZFToString(self.stateModel.n),city]];
        
        // 重新处理数据源
        if (!ZFIsEmptyString(self.cityModel.n) && !ZFIsEmptyString(self.cityModel.idx)) {
            
            __block NSInteger row = 0;
            NSString *firstCharactor = [ZFAddressLibraryManager sectionKey:self.cityModel.k];
            NSInteger section = [self.stateModel.sectionKeys indexOfObject:firstCharactor];
            NSArray *currentCountryStateLists = [self.stateModel.sectionCityDic objectForKey:firstCharactor];
            
            [currentCountryStateLists enumerateObjectsUsingBlock:^(ZFAddressLibraryCityModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.n isEqualToString:self.cityModel.n]) {
                    row = idx;
                    *stop = YES;
                    self.cityModel = obj;
                }
            }];
            
            self.cityPath = [NSIndexPath indexPathForRow:row inSection:section];
        }
        
    } else {
        if (isChange) {
            self.scrollView.contentSize = CGSizeMake(self.scrollView.width * 3, 0);
            NSString *city = self.cityModel.n.length>0 ? self.cityModel.n : ZFLocalizedString(@"modifyAddress_countryCity_city", nil);
            [self.selectStateView setTitlesArray:@[ZFToString(self.countryModel.n),ZFToString(self.stateModel.n),city]];
            
        }
        [self changeTableViewWith:2];
    }
    
    [nextTable reloadData];
    [self addressTable:nextTable scrollToIndex:self.cityPath];
}

/**
 选择农村

 @param isInit 初始为YES时，isChange不生效
 @param isChange 是否改变
 */
- (void)selectTownInit:(BOOL)isInit changeSelect:(BOOL)isChange {
    
    UITableView *currentTable = [self.scrollView viewWithTag:kZFAddressCountryCitySelectTableViewTag + 3];
    
    if (isInit) {
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.width * 4, 0);
        NSString *barangay = self.townModel.n.length>0 ? self.townModel.n : ZFLocalizedString(@"modifyAddress_countryCity_village", nil);
        [self.selectStateView setTitlesArray:@[ZFToString(self.countryModel.n),ZFToString(self.stateModel.n),ZFToString(self.cityModel.n),barangay]];
        
        if (!ZFIsEmptyString(self.townModel.n) && !ZFIsEmptyString(self.townModel.idx)) {
            
            __block NSInteger row = 0;
            NSString *firstCharactor = [ZFAddressLibraryManager sectionKey:self.townModel.k];
            NSInteger section = [self.cityModel.sectionKeys indexOfObject:firstCharactor];
            NSArray *currentCountryStateLists = [self.cityModel.sectionVillageDic objectForKey:firstCharactor];
            
            [currentCountryStateLists enumerateObjectsUsingBlock:^(ZFAddressLibraryTownModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.n isEqualToString:self.townModel.n]) {
                    row = idx;
                    *stop = YES;
                    self.townModel = obj;
                }
            }];
            
            self.townPath = [NSIndexPath indexPathForRow:row inSection:section];
        }
        
    } else {
        
        if (isChange) {
            
            self.scrollView.contentSize = CGSizeMake(self.scrollView.width * 4, 0);
            NSString *barangay = self.townModel.n.length>0 ? self.townModel.n : ZFLocalizedString(@"modifyAddress_countryCity_village", nil);
            [self.selectStateView setTitlesArray:@[ZFToString(self.countryModel.n),ZFToString(self.stateModel.n),ZFToString(self.cityModel.n),barangay]];
            
        }
        [self changeTableViewWith:3];
    }
    [currentTable reloadData];
    [self addressTable:currentTable scrollToIndex:self.townPath];
}

// 滚动到选择位置
- (void)addressTable:(UITableView *)tableView scrollToIndex:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

//        if (indexPath) {
//            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
//
//        } else {
//            [tableView setContentOffset:CGPointMake(0, 0) animated:YES];
//        }

        CGFloat offsetY = 0;
        if (indexPath) {
            CGRect currentRect = [tableView rectForRowAtIndexPath:indexPath];
            // 24的组头
            offsetY = CGRectGetMinY(currentRect) - 24;
        }
        [tableView setContentOffset:CGPointMake(0, offsetY) animated:NO];

    });
}

#pragma mark - 筛选
/**
 处理搜索结果
 @param addressModel 结果模型
 */
- (void)handleSearchSelectResult:(ZFAddressBaseModel *)addressModel {
    
    self.searchBar.text = @"";
    BOOL isChange = NO;
    
    if (self.selectIndex == 0) {
        
        ZFAddressLibraryCountryModel *countryModel = (ZFAddressLibraryCountryModel *)addressModel;
        if (![self.countryModel.n isEqualToString:countryModel.n]) {
            
            self.countryModel = nil;
            NSString *key = [ZFAddressLibraryManager sectionKey:countryModel.k];
            NSArray <ZFAddressLibraryCountryModel*> *countryArray = [[ZFAddressLibraryManager manager].countryGroupDic objectForKey:key];
            if (ZFJudgeNSArray(countryArray)) {
                [countryArray enumerateObjectsUsingBlock:^(ZFAddressLibraryCountryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj.n isEqualToString:countryModel.n]) {
                        self.countryModel = obj;
                        *stop = YES;
                    }
                }];
            }
            
            //若查到数据，
            if (self.countryModel) {
                
                self.statePath = nil;
                self.stateModel = nil;
                self.cityPath = nil;
                self.cityModel = nil;
                self.townPath = nil;
                self.townModel = nil;
                
                //若查到数据有下级数据
                if (self.countryModel.provinceList.count > 0) {
                    isChange = YES;
                    [self resetRefreshCountryIndexPath];
                    [self selectCountryInit:NO changeSelect:isChange];
                } else {
                    //若没有下级数据，请求
                    [self requestCountryIsFirst:NO];
                }
            }
        } else {
            //若当前数据有下级
            if (self.countryModel.provinceList.count > 0) {
                [self selectCountryInit:NO changeSelect:isChange];
            } else {
                //若没有下级数据，请求
                [self requestCountryIsFirst:NO];
            }
        }
        
    } else if(self.selectIndex == 1) {
        
        ZFAddressLibraryStateModel *stateModel = (ZFAddressLibraryStateModel *)addressModel;
        if (![self.stateModel.n isEqualToString:stateModel.n]) {
            [self.countryModel.provinceList enumerateObjectsUsingBlock:^(ZFAddressLibraryStateModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.n isEqualToString:stateModel.n]) {
                    self.stateModel = obj;
                    *stop = YES;
                }
            }];
            
            if (self.stateModel) {
                
                self.cityPath = nil;
                self.cityModel = nil;
                self.townPath = nil;
                self.townModel = nil;
                
                if (self.stateModel.cityList.count > 0) {
                    isChange = YES;
                    [self resetRefreshStateIndexPath];
                    [self selectProvinceInit:NO changeSelect:isChange];
                } else {
                    [self requestCountryIsFirst:NO];
                }
            }
        } else {
            if (self.stateModel.cityList.count > 0) {
                [self selectProvinceInit:NO changeSelect:isChange];
            } else {
                [self requestCountryIsFirst:NO];
            }
        }
        
    } else if(self.selectIndex == 2) {
        
        ZFAddressLibraryCityModel *cityModel = (ZFAddressLibraryCityModel *)addressModel;
        if (![self.cityModel.n isEqualToString:cityModel.n]) {
            [self.stateModel.cityList enumerateObjectsUsingBlock:^(ZFAddressLibraryCityModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.n isEqualToString:cityModel.n]) {
                    self.cityModel = obj;
                    *stop = YES;
                }
            }];
            
            if (self.cityModel) {
                self.townPath = nil;
                self.townModel = nil;
                
                if (self.cityModel.town_list.count > 0) {
                    isChange = YES;
                    [self resetRefreshCityIndexPath];
                    [self selectTownInit:NO changeSelect:isChange];
                } else {
                    [self requestCountryIsFirst:NO];
                }
            }
            
        } else {
            
            if (self.cityModel.town_list.count > 0) {
                [self selectTownInit:NO changeSelect:YES];
            } else {
                [self requestCountryIsFirst:NO];
            }
        }
        
    } else if(self.selectIndex == 3) {
        self.townModel = (ZFAddressLibraryTownModel *)addressModel;
        self.addressCountrySelectCompletionHandler(self.countryModel, self.stateModel, self.cityModel, self.townModel);
        [self actionClose:nil];
    }
    self.searchResultView.hidden = YES;
}

#pragma mark - Private Method

- (NSArray *)currentSectionCountrys:(ZFAddressLibraryCountryModel *)countryModel {
    
    NSArray *countryArray;
    if ([ZFAddressLibraryManager manager].countryGroupDic && countryModel) {
        NSString *countrySectionKey = [ZFAddressLibraryManager sectionKey:countryModel.k];
        if (ZFIsEmptyString(countryModel.k)) {
            countrySectionKey = [ZFAddressLibraryManager sectionKey:countryModel.n];
        }
        countryArray = [ZFAddressLibraryManager manager].countryGroupDic[countrySectionKey];
    }
    return countryArray ? countryArray : @[];
}


/**
 忽略层级
 */
- (NSInteger)ignoreAddressRank {
    
    __block ZFAddressLibraryIgnoreLeve addressIgnoreLeve = 0;
    
    [[self currentSectionCountrys:self.countryModel] enumerateObjectsUsingBlock:^(ZFAddressLibraryCountryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.n isEqualToString:self.countryModel.n]) {
            self.countryModel = obj;
            addressIgnoreLeve = ZFAddressLibraryIgnoreLeveCountry;
            *stop = YES;
            
            if (!ZFIsEmptyString(self.stateModel.n)) {
                [obj.provinceList enumerateObjectsUsingBlock:^(ZFAddressLibraryStateModel * _Nonnull stateObj, NSUInteger idx, BOOL * _Nonnull stateStop) {
                    
                    if ([stateObj.n isEqualToString:self.stateModel.n]) {
                        self.stateModel = stateObj;
                        addressIgnoreLeve = addressIgnoreLeve|ZFAddressLibraryIgnoreLeveState;
                        *stateStop = YES;
                        
                        if (!ZFIsEmptyString(self.cityModel.n)) {
                            [stateObj.cityList enumerateObjectsUsingBlock:^(ZFAddressLibraryCityModel * _Nonnull cityObj, NSUInteger idx, BOOL * _Nonnull cityStop) {
                                
                                if ([cityObj.n isEqualToString:self.cityModel.n]) {
                                    self.cityModel = cityObj;
                                    addressIgnoreLeve = addressIgnoreLeve|ZFAddressLibraryIgnoreLeveCity;

                                    *cityStop = YES;
                                    
                                    if (!ZFIsEmptyString(self.townModel.n)) {
                                        [cityObj.town_list enumerateObjectsUsingBlock:^(ZFAddressLibraryTownModel * _Nonnull townObj, NSUInteger idx, BOOL * _Nonnull townStop) {
                                            
                                            if ([townObj.n isEqualToString:self.townModel.n]) {
                                                self.townModel = townObj;
                                                //// 这是最后一级了
                                                addressIgnoreLeve = addressIgnoreLeve|ZFAddressLibraryIgnoreLeveTown;
                                                *townStop = YES;
                                            }
                                        }];
                                    }
                                }
                            }];
                        }
                    }
                }];
            }
            
        }
    }];
    
    return addressIgnoreLeve&ZFAddressLibraryIgnoreLeveCondifion;
}

// 暂时不支持黑暗模式 因为用旧的打包
//- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
//    [super traitCollectionDidChange:previousTraitCollection];
//    
//    if (@available(iOS 13.0, *)) {
//        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
//            if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
//                
//            } else {
//                
//            }
//        }
//        
//    }
//}

#pragma mark - Property Method

//- (UIView *)backgroundView {
//    if (!_backgroundView) {
//        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
//        _backgroundView.backgroundColor = ZFC0x000000_04();
//    }
//    return _backgroundView;
//}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _topView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"detail_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setContentEdgeInsets:UIEdgeInsetsMake(10, 15, 6, 6)];
    }
    return _closeButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = ZFLocalizedString(@"modifyAddress_countryCity_country", nil);
    }
    return _titleLabel;
}

- (UITextField *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UITextField alloc] init];
        _searchBar.delegate = self;
        _searchBar.placeholder = [NSString stringWithFormat:@" %@", ZFLocalizedString(@"Search_PlaceHolder_Search", nil)];
        _searchBar.backgroundColor = ZFC0xF2F2F2();
        _searchBar.layer.cornerRadius = 2;
        _searchBar.layer.masksToBounds = YES;
        _searchBar.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        ZFButton *searchIcon = [ZFButton buttonWithType:UIButtonTypeCustom];
        searchIcon.frame = CGRectMake(0, 0, 36, 36);
        searchIcon.imageRect = CGRectMake(6, 4, 28, 28);

        if (@available(iOS 13.0, *)) {
            // 暂时不支持黑暗模式 因为用旧的打包
            searchIcon.frame = CGRectMake(0, 0, 46, 36);
            searchIcon.imageRect = CGRectMake(0, -3, 28, 28);
            if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            } else {
                
            }
        }
        [searchIcon setImage:[UIImage imageNamed:@"category_search"] forState:UIControlStateNormal];
        searchIcon.enabled = NO;
        _searchBar.leftViewMode = UITextFieldViewModeAlways;
        _searchBar.leftView = searchIcon;
        
        [_searchBar addDoneOnKeyboardWithTarget:self action:@selector(doneButtonAction:)];
    }
    return _searchBar;
}


- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFC0xDDDDDD();
    }
    return _lineView;
}

- (ZFAddressCountryCityStateView *)selectStateView {
    if (!_selectStateView) {
        _selectStateView = [[ZFAddressCountryCityStateView alloc] initWithFrame:CGRectZero];
        @weakify(self)
        _selectStateView.selectIndexBlock = ^(NSInteger index) {
            @strongify(self)
            [self changeTableViewWith:index];
        };
    }
    return _selectStateView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, [self defaultSrollViewHeight])];
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.contentSize = CGSizeMake(4 * KScreenWidth, 0);

        if ([SystemConfigUtils isRightToLeftShow]) {
            _scrollView.transform = CGAffineTransformMakeRotation(M_PI);
        }
    }
    return _scrollView;
}

- (ZFAddressCountryCitySearchView *)searchResultView {
    if (!_searchResultView) {
        _searchResultView = [[ZFAddressCountryCitySearchView alloc] initWithFrame:CGRectZero];
        _searchResultView.hidden = YES;
        @weakify(self);
        _searchResultView.addressCountryCitySearchBlock = ^(ZFAddressBaseModel *model) {
            @strongify(self);
            [self handleSearchSelectResult:model];
        };
        _searchResultView.addressCountryCitySearchScrollBlcok = ^{
            @strongify(self);
            [self.view endEditing:YES];
        };
    }
    return _searchResultView;
}


- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _emptyView;
}

- (YYAnimatedImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _emptyImageView.image = ZFImageWithName(@"blankPage_networkError");
    }
    return _emptyImageView;
}

- (UILabel *)emptyLabel {
    if (!_emptyLabel) {
        _emptyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _emptyLabel.textColor = ZFC0x999999();
        _emptyLabel.textAlignment = NSTextAlignmentCenter;
        _emptyLabel.numberOfLines = 0;
        _emptyLabel.font = ZFFontSystemSize(14.0);
        _emptyLabel.adjustsFontSizeToFitWidth = YES;
        _emptyLabel.preferredMaxLayoutWidth = KScreenWidth - 56;
        _emptyLabel.text =  ZFLocalizedString(@"BlankPage_NetworkError_tipTitle",nil);
    }
    return _emptyLabel;
}


- (UIButton *)emptyButton {
    if (!_emptyButton) {
        _emptyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _emptyButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _emptyButton.titleLabel.textColor = ZFCOLOR_WHITE;
        _emptyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_emptyButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_emptyButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        [_emptyButton setTitle:ZFLocalizedString(@"EmptyCustomViewManager_refreshButton",nil) forState:UIControlStateNormal];
        [_emptyButton addTarget:self action:@selector(actionRefresh:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emptyButton;
}


- (void)removeAgainRequestView {
    if (_emptyView) {
        [_emptyView removeFromSuperview];
        _emptyView = nil;
    }
}
- (void)showAgainRequestView {
    
    HideLoadingFromView(self.view);
    if ([ZFAddressLibraryManager manager].countryGroupKeys.count > 0) {
        [self removeAgainRequestView];
        return;
    }
    
    if (!_emptyView) {
        [self.view addSubview:self.emptyView];
        [self.emptyView addSubview:self.emptyImageView];
        [self.emptyView addSubview:self.emptyLabel];
        [self.emptyView addSubview:self.emptyButton];
        
        
        [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.topView.mas_bottom);
            make.leading.trailing.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view.mas_bottom);
        }];
        
        [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.emptyView);
            make.bottom.mas_equalTo(self.emptyView.mas_centerY).offset(-45);
            make.size.mas_equalTo(CGSizeMake(80, 80));
        }];
        
        CGFloat maxWidth = KScreenWidth - 56;
        [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.emptyImageView.mas_bottom).offset(20);
            make.centerX.equalTo(self.emptyImageView);
            make.width.greaterThanOrEqualTo(@(maxWidth));
        }];
        
        [self.emptyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.emptyImageView);
            make.top.equalTo(self.emptyLabel.mas_bottom).offset(36);
            make.size.mas_equalTo(CGSizeMake(maxWidth, 44));
        }];
        
    }
}
@end






#pragma mark - 自定义动画拦截器

@implementation ZFAddressCountryCitySelectTransitionDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    ZFAddressCountryCitySelectTransitionBegan *begain = [[ZFAddressCountryCitySelectTransitionBegan alloc] init];
    begain.height = self.height;
    return begain;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    ZFAddressCountryCitySelectTransitionEnd *end = [[ZFAddressCountryCitySelectTransitionEnd alloc] init];
    return end;
}


@end

#pragma mark - 自定义动画实现

@implementation ZFAddressCountryCitySelectTransitionBegan

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromVC.view.layer.zPosition = -1;
    fromVC.view.layer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toVC.view.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, self.height?:[UIScreen mainScreen].bounds.size.height);
    [[transitionContext containerView] addSubview:toVC.view];
    toVC.view.layer.zPosition = MAXFLOAT;
    
    if ([toVC isKindOfClass:[ZFAddressCountryCitySelectVC class]]) {
        ZFAddressCountryCitySelectVC *addressToVC = (ZFAddressCountryCitySelectVC *)toVC;
        if (addressToVC.backgroundView) {
            if (addressToVC.backgroundView.superview) {
                [addressToVC.backgroundView removeFromSuperview];
            }
            [fromVC.view addSubview:addressToVC.backgroundView];
        }
    }
    
    CGFloat duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = toVC.view.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - self.height?:[UIScreen mainScreen].bounds.size.height;
        toVC.view.frame = frame;
    } completion:^(BOOL finished){
        [transitionContext completeTransition:YES];
        
        if ([toVC isKindOfClass:[ZFAddressCountryCitySelectVC class]]) {
            ZFAddressCountryCitySelectVC *addressToVC = (ZFAddressCountryCitySelectVC *)toVC;
            addressToVC.isStartRequest = YES;
        }
    }];
}


@end

@implementation ZFAddressCountryCitySelectTransitionEnd

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController * toVC =
    [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController * fromVC =
    [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if ([fromVC isKindOfClass:[ZFAddressCountryCitySelectVC class]]) {
        ZFAddressCountryCitySelectVC *addressFromVC = (ZFAddressCountryCitySelectVC *)fromVC;
        if (addressFromVC.backgroundView && addressFromVC.backgroundView.superview) {
            [addressFromVC.backgroundView removeFromSuperview];
        }
    }
    
    CGFloat duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = fromVC.view.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height;
        fromVC.view.frame = frame;
        toVC.view.layer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    } completion:^(BOOL finished){
        [transitionContext completeTransition:YES];
    }];
}

@end
