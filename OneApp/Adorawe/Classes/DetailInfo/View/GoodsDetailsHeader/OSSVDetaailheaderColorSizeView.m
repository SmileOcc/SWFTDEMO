//
//  OSSVDetaailheaderColorSizeView.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/7.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetaailheaderColorSizeView.h"
#import "OSSColorSizeCell.h"
#import "OSSVColorSizeReusableView.h"
#import "YBPopupMenu.h"
#import "STLActivityWWebCtrl.h"
#import "Adorawe-Swift.h"

#define GoodsDetailViewFirstAppear @"GoodsDetailViewFirstAppear"
#define kCollectionColorTag  9527
#define kCollectionSizeTag  9528
#define kCollectionMainTag  9529

@interface OSSVDetaailheaderColorSizeView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, YBPopupMenuDelegate>

@property (nonatomic, strong) UICollectionView  *mainColl;
@property (nonatomic, strong) UICollectionView  *colorColl;
@property (nonatomic, strong) UICollectionView  *sizeColl;
@property (nonatomic, strong) UIView            *tipView;
@property (nonatomic, strong) UILabel           *tipLab;
@property (nonatomic, strong) YBPopupMenu       *popUpMeun;
@property (nonatomic, assign) CGFloat           tipViewHeight;

@property (nonatomic, strong) NSArray           *colorGroup_id;
@property (nonatomic, strong) NSArray           *sizeGroup_id;

@end

@implementation OSSVDetaailheaderColorSizeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    [self addSubview:self.tipView];
    [self.tipView addSubview:self.tipLab];
    
    if (APP_TYPE == 3) {
        [self addSubview:self.colorSizeViewVIV];
        [self.colorSizeViewVIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self);
            make.leading.equalTo(self.mas_leading).offset(14);
            make.trailing.equalTo(self.mas_trailing).offset(-14);
            make.height.equalTo(189);
        }];
        
        [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.colorSizeViewVIV.mas_bottom).offset(0);
            make.leading.mas_equalTo(self.mas_leading).offset(14);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
            make.height.mas_equalTo(0);
//            make.bottom.equalTo(self);
        }];
    }else{
        [self addSubview:self.mainColl];
        
        [self addSubview:self.colorColl];
        [self addSubview:self.sizeColl];
        [self.mainColl mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.edges.mas_offset(UIEdgeInsetsMake(0, 0, 0, 0));
            make.top.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(156);
        }];
        
        [self.colorColl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.mainColl);
            make.top.mas_equalTo(self.mainColl.mas_top).offset(34);
            make.height.mas_equalTo(50);
        }];
        
        [self.sizeColl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.colorColl);
            make.top.mas_equalTo(self.colorColl.mas_bottom).offset(36);
            make.height.mas_equalTo(36);
        }];
        
        [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mainColl.mas_bottom).offset(12);
            make.leading.mas_equalTo(self.mas_leading).offset(14);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
            make.height.mas_equalTo(0);
        }];
    }
    
    
   
    
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.tipView.mas_leading).offset(8);
        make.trailing.mas_equalTo(self.tipView.mas_trailing).offset(-8);
        make.top.mas_equalTo(self.tipView.mas_top).offset(4);
        make.bottom.mas_equalTo(self.tipView.mas_bottom).offset(-4);
    }];
}

// 设置数据源
- (void)setBaseModel:(OSSVDetailsBaseInfoModel *)baseModel{
    _baseModel = baseModel;
    if (_baseModel) {
        if (APP_TYPE == 3) {
            self.colorSizeViewVIV.goodsInfo = baseModel;
        }else{
            if (!_baseModel.isHasSizeItem) {
                [self.mainColl mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(84);
                }];
                self.sizeColl.hidden = YES;
            }
            if (!_baseModel.isHasColorItem) {
                [self.mainColl mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(72);
                }];
                
                self.colorColl.hidden = YES;
                
                [self.sizeColl mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.mas_equalTo(self.mainColl);
                    make.top.mas_equalTo(self.mainColl.mas_top).offset(34);
                    make.height.mas_equalTo(36);
                }];

            }
            NSInteger item = 0;
            for (OSSVSpecsModel *specModel in _baseModel.GoodsSpecs) {
                if ([specModel.spec_type integerValue] == 1) {
                    for (int i = 0;i < specModel.brothers.count;i++) {
                        OSSVAttributeItemModel *itemModel  = specModel.brothers[i];
                        if ([itemModel.goods_id isEqualToString:_baseModel.goodsId]) {
                            self.colorGroup_id = itemModel.group_goods_id;
                            item = i;
                        }
                       
                    }
                }
                if ([specModel.spec_type integerValue] == 2) {
                    for (int i = 0;i < specModel.brothers.count;i++) {
                        OSSVAttributeItemModel *itemModel  = specModel.brothers[i];
                        if ([itemModel.goods_id isEqualToString:_baseModel.goodsId]) {
                            self.sizeGroup_id = itemModel.group_goods_id;
                            item = i;
                        }
                       
                    }
                }
            }
            
            [self.sizeColl reloadData];
            [self.mainColl reloadData];
            [self.colorColl reloadData];
            NSInteger colorCount = [self collectionView:self.colorColl numberOfItemsInSection:0];
            if (_baseModel.isHasColorItem && item < colorCount) {
                NSIndexPath *indexP = [NSIndexPath indexPathForItem:item inSection:0];
                [self.colorColl scrollToItemAtIndexPath:indexP atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            }
            
        }
        
    }
}

- (UICollectionView *)mainColl{
    if (!_mainColl) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _mainColl = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _mainColl.showsVerticalScrollIndicator = NO;
        _mainColl.showsHorizontalScrollIndicator = NO;
        _mainColl.delegate = self;
        _mainColl.dataSource = self;
        _mainColl.backgroundColor = [UIColor whiteColor];
        _mainColl.scrollEnabled = YES;
        
        [_mainColl registerClass:[OSSColorSizeCell class] forCellWithReuseIdentifier:NSStringFromClass([OSSColorSizeCell class])];
        
        [_mainColl registerClass:[OSSVColorSizeReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([OSSVColorSizeReusableView class])];
        _mainColl.scrollEnabled = NO;
        
        _mainColl.tag = kCollectionMainTag;
    }
    return _mainColl;
}

- (UICollectionView *)colorColl{
    if (!_colorColl) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _colorColl = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _colorColl.showsVerticalScrollIndicator = NO;
        _colorColl.showsHorizontalScrollIndicator = NO;
        _colorColl.delegate = self;
        _colorColl.dataSource = self;
        _colorColl.backgroundColor = [UIColor whiteColor];
        _colorColl.scrollEnabled = YES;
        
        [_colorColl registerClass:[OSSColorSizeCell class] forCellWithReuseIdentifier:@"colorSheetIdentifer"];
        
        [_colorColl registerClass:[OSSVColorSizeReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([OSSVColorSizeReusableView class])];
        _colorColl.tag = kCollectionColorTag;
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _colorColl.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            _colorColl.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        }
    }
    return _colorColl;
}

- (UICollectionView *)sizeColl{
    if (!_sizeColl) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _sizeColl = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _sizeColl.showsVerticalScrollIndicator = NO;
        _sizeColl.showsHorizontalScrollIndicator = NO;
        _sizeColl.delegate = self;
        _sizeColl.dataSource = self;
        _sizeColl.backgroundColor = [UIColor whiteColor];
        _sizeColl.scrollEnabled = YES;
        
        [_sizeColl registerClass:[OSSColorSizeCell class] forCellWithReuseIdentifier:@"sizeSheetIdentifer"];
        
        
        [_sizeColl registerClass:[OSSVColorSizeReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([OSSVColorSizeReusableView class])];
        _sizeColl.tag = kCollectionSizeTag;
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _sizeColl.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            _sizeColl.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        }
    }
    return _sizeColl;
}

- (UIView *)tipView{
    if (!_tipView) {
        _tipView = [UIView new];
        _tipView.backgroundColor = OSSVThemesColors.col_FAFAFA;
    }
    return _tipView;
}

- (UILabel *)tipLab{
    if (!_tipLab) {
        _tipLab = [UILabel new];
        _tipLab.font = FontWithSize(12);
        _tipLab.numberOfLines = 0;
    }
    return _tipLab;
}


// 延时操作
// ybpop 消失的代理
- (void)ybPopupMenuBeganDismiss{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dissMissPopUpView) object:nil];
}

- (UITableViewCell *)ybPopupMenu:(YBPopupMenu *)ybPopupMenu cellForRowAtIndex:(NSInteger)index{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:ybPopupMenu.bounds];
    UILabel *titLab = [[UILabel alloc] initWithFrame:CGRectMake(14, -2, ybPopupMenu.bounds.size.width - 28, ybPopupMenu.bounds.size.height)];
    [cell.contentView addSubview:titLab];
    titLab.font = FontWithSize(14);
    titLab.numberOfLines = 0;
    titLab.text = STLLocalizedString_(@"checkTheSize", nil);
    titLab.textColor = [UIColor whiteColor];
    titLab.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)dissMissPopUpView{
    if (_popUpMeun) {
        [_popUpMeun dismiss];
    }
}

// datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    if (collectionView.tag == kCollectionColorTag || collectionView.tag == kCollectionSizeTag) {
        return 1;
    }
    return _baseModel.GoodsSpecs.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView.tag == kCollectionColorTag) {
        OSSVSpecsModel *specModel = _baseModel.GoodsSpecs.firstObject;
        return specModel.brothers.count;
    }else if(collectionView.tag == kCollectionSizeTag){
        if (_baseModel.isHasColorItem) {
            if (_baseModel.GoodsSpecs && _baseModel.GoodsSpecs.count >= 2) {
                OSSVSpecsModel *specModel = _baseModel.GoodsSpecs[1];
                return specModel.brothers.count;
            }
        }else{
            OSSVSpecsModel *specModel = _baseModel.GoodsSpecs.firstObject;
            return specModel.brothers.count;
        }
        return 0;
    }else{
        OSSVSpecsModel *specModel = _baseModel.GoodsSpecs[section];
        if (STLJudgeNSArray(specModel.brothers) && specModel.brothers.count > 0) {
            return 1;
        }
        return 0;
    }
    
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OSSVSpecsModel *specModel = nil;
    OSSColorSizeCell * cell = nil;
    
    if (collectionView.tag == kCollectionColorTag) {
        specModel = _baseModel.GoodsSpecs.firstObject;
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"colorSheetIdentifer" forIndexPath:indexPath];
    }else if(collectionView.tag == kCollectionSizeTag){
        if (_baseModel.isHasColorItem) {
            if (_baseModel.GoodsSpecs && _baseModel.GoodsSpecs.count >= 2) {
                specModel = _baseModel.GoodsSpecs[1];
            }
        }else{
            specModel = _baseModel.GoodsSpecs.firstObject;
        }
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sizeSheetIdentifer" forIndexPath:indexPath];
    }else if (collectionView.tag == kCollectionMainTag){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([OSSColorSizeCell class]) forIndexPath:indexPath];
        specModel = _baseModel.GoodsSpecs[indexPath.section];
        cell.hidden = YES;
    }
    
    OSSVAttributeItemModel *itemModel = specModel.brothers[indexPath.item];
    
    cell.goos_numeber = [_baseModel.goodsNumber integerValue];
    cell.goos_id = _baseModel.goodsId;
    cell.goodsSpecModel = specModel;
    
    NSArray *arr = [self interArrayWithArray:self.colorGroup_id other:itemModel.group_goods_id];
    if ((arr && arr.count > 0) || !_baseModel.isHasColorItem || !_baseModel.isHasSizeItem) {
        cell.isJiaoJi = YES;
    }else{
        cell.isJiaoJi = NO;
    }
    
    cell.itemModel = itemModel;
    
//    if ([specModel.spec_type integerValue] == 1) {
//        // 颜色
//        if ([itemModel.goods_id isEqualToString:_baseModel.goodsId]) {
//            self.colorGroup_id = itemModel.group_goods_id;
//        }
//    }else if([specModel.spec_type integerValue] == 2){
//        // 尺码
//        if ([itemModel.goods_id isEqualToString:_baseModel.goodsId]) {
//            self.sizeGroup_id = itemModel.group_goods_id;
//        }
//    }
    
    
    if (specModel.isSelectSize && [itemModel.goods_id isEqualToString:_baseModel.goodsId] && [specModel.spec_type integerValue] == 2 && _baseModel.isHasSizeItem) {
        [self updateSizeTipViewWithArray:_baseModel.size_info itemModel:itemModel];
    }
    
    return cell;
}

// didselected
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    OSSColorSizeCell *cell = (OSSColorSizeCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isSelected) {
        return;
    }
    
    OSSVSpecsModel *specModel = nil;
    
    if (collectionView.tag == kCollectionColorTag) {
        specModel = _baseModel.GoodsSpecs.firstObject;
    }else if(collectionView.tag == kCollectionSizeTag){
        if (_baseModel.isHasColorItem) {
            if (_baseModel.GoodsSpecs && _baseModel.GoodsSpecs.count >= 2) {
                specModel = _baseModel.GoodsSpecs[1];
            }
        }else{
            specModel = _baseModel.GoodsSpecs.firstObject;
        }
    }else if (collectionView.tag == kCollectionMainTag){
        specModel = _baseModel.GoodsSpecs[indexPath.section];
    }
    OSSVAttributeItemModel *itemModel = specModel.brothers[indexPath.item];
    if ([specModel.spec_type integerValue]== 1) {
        // 颜色
        [GATools logGoodsChangeColorWithColor:STLToString(itemModel.value) screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.baseModel.goodsTitle)]];
        NSArray *group_id_Slected = itemModel.group_goods_id;
        NSString *good_id = nil;
        
        if (specModel.isSelectSize) {
            NSArray *inerArray = [self interArrayWithArray:self.sizeGroup_id other:group_id_Slected];

            if (inerArray && inerArray.count >0) {
                good_id = inerArray.firstObject;
            }else{
                good_id = itemModel.goods_id;
            }
        }else{
            good_id = itemModel.goods_id;
        }
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_GoodsDetailColorTap object:good_id];
    }else if ([specModel.spec_type integerValue]== 2){
        // 尺码
        [GATools logGoodsChangeSizeWithSize:STLToString(itemModel.value) screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.baseModel.goodsTitle)]];
        NSArray *group_id_Slected = itemModel.group_goods_id;
        self.sizeGroup_id = group_id_Slected;
        NSArray *inerArray = [self interArrayWithArray:self.colorGroup_id other:group_id_Slected];
        
        NSString *good_id = nil;
        if (inerArray && inerArray.count >0) {
            good_id = inerArray.firstObject;
        }else{
            good_id = itemModel.goods_id;
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_GoodsDetailSizeTap object:good_id];
    }
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

// header
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == kCollectionColorTag ||collectionView.tag == kCollectionSizeTag) {
        return [OSSVColorSizeReusableView new];
    }
    OSSVColorSizeReusableView *placeHeader = (OSSVColorSizeReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([OSSVColorSizeReusableView class]) forIndexPath:indexPath];
    if (!placeHeader) {
        placeHeader = [OSSVColorSizeReusableView new];
    }
    placeHeader.goods_id = _baseModel.goodsId;
    OSSVSpecsModel *specsModel = _baseModel.GoodsSpecs[indexPath.section];
    placeHeader.specsModel = specsModel;
    placeHeader.isSelectSize = specsModel.isSelectSize;
    
    BOOL isAppeared = [[NSUserDefaults standardUserDefaults] objectForKey:GoodsDetailViewFirstAppear];
    
    if (!_popUpMeun && !isAppeared) {
        _popUpMeun = [YBPopupMenu showRelyOnView:placeHeader titles:@[STLLocalizedString_(@"checkTheSize", nil)] icons:nil menuWidth:self.bounds.size.width - 16 otherSettings:^(YBPopupMenu *popupMenu) {
            popupMenu.arrowDirection = YBPopupMenuPriorityDirectionNone;
            popupMenu.priorityDirection = YBPopupMenuPriorityDirectionBottom;
            popupMenu.isShowShadow = NO;
            popupMenu.showMaskView = NO;
            popupMenu.cornerRadius = 0;
            popupMenu.backColor = [UIColor colorWithWhite:0 alpha:0.8];
            popupMenu.textColor = [UIColor whiteColor];
            popupMenu.arrowWidth = 8;
            popupMenu.arrowHeight = 4;
            popupMenu.dismissOnSelected = YES;
            popupMenu.dismissOnTouchOutside = YES;
            popupMenu.delegate = self;
            popupMenu.itemHeight = 50;
        }];
        [self performSelector:@selector(dissMissPopUpView) withObject:nil afterDelay:5];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GoodsDetailViewFirstAppear];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    placeHeader.sizeChatblock = ^{
        
        [GATools logGoodsDetailSimpleEventWithEventName:@"size_guide"
                                                screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.baseModel.goodsTitle)]
                                                 buttonName:@"Size Chart"];
        
        STLActivityWWebCtrl *webViewController = [STLActivityWWebCtrl new];
        webViewController.strUrl = STLToString(specsModel.size_chart_url);
        webViewController.isIgnoreWebTitle = YES;
        webViewController.isModalPresent = YES;
        webViewController.title = STLToString(specsModel.size_chart_title);
        webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
        WINDOW.backgroundColor = [OSSVThemesColors stlBlackColor];
        
        OSSVNavigationVC *nav = [[OSSVNavigationVC alloc] initWithRootViewController:webViewController];
        nav.modalPresentationStyle = UIModalPresentationPageSheet;
        [[UIViewController currentTopViewController]  presentViewController:nav animated:YES completion:nil];
    };
    
    return placeHeader;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (collectionView.tag == kCollectionColorTag ||collectionView.tag == kCollectionSizeTag) {
        return CGSizeZero;
    }
    return CGSizeMake(self.frame.size.width, 36);
}

// flow layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    OSSVSpecsModel *specModel = nil;
    
    if (collectionView.tag == kCollectionColorTag) {
        specModel = _baseModel.GoodsSpecs.firstObject;
    }else if(collectionView.tag == kCollectionSizeTag){
        if (_baseModel.isHasColorItem) {
            if (_baseModel.GoodsSpecs && _baseModel.GoodsSpecs.count >= 2) {
                specModel = _baseModel.GoodsSpecs[1];
            }
        }else{
            specModel = _baseModel.GoodsSpecs.firstObject;
        }
        
    }else{
        specModel = _baseModel.GoodsSpecs[indexPath.section];
    }
    if ([specModel.spec_type integerValue]== 1) {
        // color
        return CGSizeMake(36, 48);
    }else if ([specModel.spec_type integerValue]== 2){
        OSSVAttributeItemModel *itemModel = specModel.brothers[indexPath.item];
        CGFloat width = [self getLabStringWidthWithText:itemModel.value];
        return CGSizeMake(width, 36);
    }else{
        return  CGSizeZero;
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 14, 0, 14);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 12.0f;
}

// 计算文字宽度
- (CGFloat)getLabStringWidthWithText:(NSString *)text{
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    CGFloat width = [text boundingRectWithSize:CGSizeMake(1000, MAXFLOAT)  options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.width;
    
    width = MAX(width + 14, 36);
    return width;
}

// 更新sizetipview
- (void)updateSizeTipViewWithArray:(NSArray <OSSVSizeChartModel *> *)size_info itemModel:(OSSVAttributeItemModel *)itemModel{
    if (STLJudgeNSArray(size_info) && size_info.count > 0) {
        if (!self.baseModel.isHasSizeItem) {
            return;
        }
        NSArray <OSSVSizeChartItemModel*> *positionData = nil;
        for (OSSVSizeChartModel *chatModel in size_info) {
            if ([chatModel.size_name.lowercaseString isEqualToString:itemModel.size_name.lowercaseString]) {
                positionData = chatModel.position_data;
                break;
            }
        }
        NSMutableAttributedString *mAttr = [[NSMutableAttributedString alloc] init];
        if (STLJudgeNSArray(positionData) && positionData.count > 0) {
            for (int i = 0; i<positionData.count; i++) {
                OSSVSizeChartItemModel *chartModel = positionData[i];
                NSString *name = [NSString stringWithFormat:@"%@:", chartModel.position_name];
                NSString *value = [NSString stringWithFormat:@"%@ %@ ", chartModel.measurement_value, STLLocalizedString_(@"Goods_cm", nil)];

                NSAttributedString *attName = [[NSAttributedString alloc] initWithString:name attributes:@{NSFontAttributeName:FontWithSize(12), NSForegroundColorAttributeName:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1]}];
                NSAttributedString *attValue = [[NSAttributedString alloc] initWithString:value attributes:@{NSFontAttributeName:FontWithSize(12), NSForegroundColorAttributeName:OSSVThemesColors.col_0D0D0D}];
                [mAttr appendAttributedString:attName];
                [mAttr appendAttributedString:attValue];
            }
            // 文字的高度
            _tipLab.attributedText = mAttr;
            NSString *str = mAttr.string;
            // 文字的高度

            NSRange range = NSMakeRange(0, mAttr.length);
            NSDictionary *dic = [mAttr attributesAtIndex:0 effectiveRange:&range];
            // 计算文本的大小
            CGSize sizeToFit = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
            CGFloat num = sizeToFit.width/_tipLab.bounds.size.width + 1;
            CGFloat height = sizeToFit.height*num;
            
//            CGFloat height = textHeight(str, FontWithSize(12), CGSizeMake(self.tipView.bounds.size.width, MAXFLOAT)) + 8;
            self.tipViewHeight = height + 8;
            [self.tipView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.tipViewHeight);
            }];
            [self.tipView layoutIfNeeded];
        }else{
            self.tipViewHeight = 0;
            [self.tipView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.tipViewHeight);
            }];
            [self.tipView layoutIfNeeded];
        }
        
    }
}
+ (CGFloat)updateSizeTipViewWithArray:(NSArray <OSSVSizeChartModel *> *)size_info itemModel:(OSSVAttributeItemModel *)itemModel{
    if (STLJudgeNSArray(size_info) && size_info.count > 0) {
        NSArray <OSSVSizeChartItemModel*> *positionData = nil;
        for (OSSVSizeChartModel *chatModel in size_info) {
            if ([chatModel.size_name.lowercaseString isEqualToString:itemModel.size_name.lowercaseString]) {
                positionData = chatModel.position_data;
                break;
            }
        }
        NSMutableAttributedString *mAttr = [[NSMutableAttributedString alloc] init];
        if (STLJudgeNSArray(positionData) && positionData.count > 0) {
            for (int i = 0; i<positionData.count; i++) {
                OSSVSizeChartItemModel *chartModel = positionData[i];
                NSString *name = [NSString stringWithFormat:@"%@:", chartModel.position_name];
                NSString *value = [NSString stringWithFormat:@"%@ %@ ", chartModel.measurement_value, STLLocalizedString_(@"Goods_cm", nil)];

                NSAttributedString *attName = [[NSAttributedString alloc] initWithString:name attributes:@{NSFontAttributeName:FontWithSize(12), NSForegroundColorAttributeName:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1]}];
                NSAttributedString *attValue = [[NSAttributedString alloc] initWithString:value attributes:@{NSFontAttributeName:FontWithSize(12), NSForegroundColorAttributeName:OSSVThemesColors.col_0D0D0D}];
                [mAttr appendAttributedString:attName];
                [mAttr appendAttributedString:attValue];
            }
            // 文字的高度
            NSString *str = mAttr.string;
            NSRange range = NSMakeRange(0, mAttr.length);
            NSDictionary *dic = [mAttr attributesAtIndex:0 effectiveRange:&range];
            // 计算文本的大小
            CGSize sizeToFit = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
            CGFloat num = sizeToFit.width/(SCREEN_WIDTH - 44) + 1;
            CGFloat height = sizeToFit.height*num;
//            CGFloat height = textHeight(str, FontWithSize(12), CGSizeMake(SCREEN_WIDTH - 68, MAXFLOAT)) + 8;
            return height + 8;
        }else{
            return 0;
        }
    }
    return 0;
}

- (CGFloat)getTipViewHeight{
    return  self.tipViewHeight;
}

+ (CGFloat)getTipViewHeightWith:(OSSVDetailsBaseInfoModel *)baseModel{
    for (OSSVSpecsModel *specModel in baseModel.GoodsSpecs) {
        if ([specModel.spec_type integerValue] == 2 && specModel.brothers.count > 0) {
            baseModel.isHasSizeItem = YES;
            break;
        }
    }
    if (!baseModel.isHasSizeItem) {
        return 0;
    }
    

    for (OSSVSpecsModel *specModel in baseModel.GoodsSpecs) {
        if ([specModel.spec_type integerValue] == 2) {
            for (OSSVAttributeItemModel *itemModel in specModel.brothers) {
//                CGFloat height = [OSSVDetaailheaderColorSizeView updateSizeTipViewWithArray:baseModel.size_info itemModel:itemModel] + 12;
                if ([baseModel.goodsId isEqualToString:itemModel.goods_id]) {
                    for (OSSVSizeChartModel *chatModel in baseModel.size_info) {
                        if ([chatModel.size_name.lowercaseString isEqualToString:itemModel.size_name.lowercaseString]) {
                            CGFloat height = [OSSVDetaailheaderColorSizeView updateSizeTipViewWithArray:baseModel.size_info itemModel:itemModel];
                            return height;
                        }
                    }
                }
                
            }
            break;
        }
    }
    return  0;
}

// 两个数组求交集带顺序
- (NSArray *)interArrayWithArray:(NSArray *)array1 other:(NSArray *)array2{
    if (array1 && array1.count > 0 && array2 && array2.count >0) {
        NSMutableArray *marray = [NSMutableArray arrayWithCapacity:1];
        for (int i = 0; i<array1.count; i++) {
            NSString *str1 = array1[i];
            for (int j = 0; j<array2.count; j++) {
                NSString *str2 = array2[j];
                if ([str1 isEqualToString:str2]) {
                    [marray addObject:str1];
                }
            }
        }
        return [marray copy];
    }else{
        return nil;
    }
}

-(ColorSizePickView *)colorSizeViewVIV{
    if (!_colorSizeViewVIV) {
        _colorSizeViewVIV = [[ColorSizePickView alloc] initWithFrame:CGRectZero];
        [_colorSizeViewVIV setFirstIntoSelectSize:YES];
        _colorSizeViewVIV.delegate = self;
        _colorSizeViewVIV.onlyNeedSize = false;
    }
    return _colorSizeViewVIV;
}

@end
