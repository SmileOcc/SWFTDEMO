//
//  ZFGoodsDetailGoodsSelectSizeCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailGoodsSelectSizeCell.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"
#import "NSString+Extended.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "SystemConfigUtils.h"
#import "ZFSizeSelectSectionModel.h"
#import "ZFSelectSizeSizeCell.h"
#import "ZFSelectSizeColorCell.h"
#import "ZFSelectSizeColorHeader.h"
#import "ZFSizeSelectSizeTipsView.h"
#import "ZFSelectSizeSizeHeader.h"
#import "ZFSelectSizeStockTipsHeader.h"

#import "GoodsDetailModel.h"
#import "ZFGoodsDetailEnumDefiner.h"
#import "ZFBTSManager.h"
#import "UICollectionViewLeftAlignedLayout.h"

static NSString *const kZFSizeSelectNormalHeaderViewIdentifier = @"kZFSizeSelectNormalHeaderViewIdentifier";
static NSString *const kZFSizeSelectSizeHeaderViewIdentifier = @"kZFSizeSelectSizeHeaderViewIdentifier";
static NSString *const kZFSizeSelectCollectionViewCellIdentifier = @"kZFSizeSelectCollectionViewCellIdentifier";
static NSString *const kZFSizeSelectSizeTipsViewIdentifier = @"kZFSizeSelectSizeTipsViewIdentifier";
static NSString *const kZFColorSelectCollectionViewCellIdentifier = @"kZFColorSelectCollectionViewCellIdentifier";
static NSString *const kZFSizeSelectStockTipsHeaderViewIdentifier = @"kZFSizeSelectStockTipsHeaderViewIdentifier";

static CGFloat kStandardCellBottomSpace = 8;

@interface ZFGoodsDetailGoodsSelectSizeCell() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray<ZFSizeSelectSectionModel *>    *dataArray;
@property (nonatomic, strong) UICollectionView                              *collectionView;
@property (nonatomic, assign) CGFloat                                       groupTitleTopSpace;
@property (nonatomic, strong) ZFSizeTipsArrModel                            *sizeTipsArrModel;
@end

@implementation ZFGoodsDetailGoodsSelectSizeCell

@synthesize cellTypeModel = _cellTypeModel;

+ (CGFloat)fetchSizeCellHeight:(ZFGoodsDetailCellTypeModel *)cellTypeModel
{
    ZFGoodsDetailGoodsSelectSizeCell *sizeCell = [[ZFGoodsDetailGoodsSelectSizeCell alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];    
    sizeCell.cellTypeModel = cellTypeModel;
    if (!cellTypeModel.detailModel.same_goods_spec) {
        return 8; //防止尺码模型不返回数据出错
    }
    [sizeCell layoutIfNeeded];
    CGFloat calculateHeight = sizeCell.collectionView.contentSize.height;
    
    if (ZFIsEmptyString(cellTypeModel.detailModel.stock_tips)) {
        calculateHeight += 8;
    }
    return (calculateHeight < 70) ? 323 : (calculateHeight + kStandardCellBottomSpace);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - setter

- (void)setCellTypeModel:(ZFGoodsDetailCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;
    [self.dataArray removeAllObjects];

    //color
    if (cellTypeModel.detailModel.same_goods_spec.color.count > 0) {
        ZFSizeSelectSectionModel *sectionModel = [[ZFSizeSelectSectionModel alloc] init];
        sectionModel.type = ZFSizeSelectSectionTypeColor;
        sectionModel.typeName = ZFLocalizedString(@"Color", nil);
        sectionModel.itmesArray = [NSMutableArray array];

        [cellTypeModel.detailModel.same_goods_spec.color enumerateObjectsUsingBlock:^(GoodsDetialColorModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZFSizeSelectItemsModel *model = [[ZFSizeSelectItemsModel alloc] init];
            model.type = ZFSizeSelectItemTypeColor;
            model.color = obj.color_code;
            model.color_img = obj.color_img;
            model.attrName = obj.attr_value;
            model.is_click = obj.is_click;
            model.goodsId = obj.goods_id;
            model.width = 36;
            model.isSelect = NO;
            if ([cellTypeModel.detailModel.goods_id isEqualToString:obj.goods_id]) {
                model.isSelect = YES;
                sectionModel.typeName = [NSString stringWithFormat:@"%@:%@", ZFLocalizedString(@"Color", nil), ZFToString(obj.attr_value)];
            }
            [sectionModel.itmesArray addObject:model];
        }];
        [self.dataArray addObject:sectionModel];
    }
    //size
    if (cellTypeModel.detailModel.same_goods_spec.size.count > 0) {
        __block NSString *sizeTips = @"";
        __block ZFSizeTipsArrModel *sizeTipsArrModel = nil;
        
        ZFSizeSelectSectionModel *sectionModel = [[ZFSizeSelectSectionModel alloc] init];
        sectionModel.type = ZFSizeSelectSectionTypeSize;
        sectionModel.typeName = ZFLocalizedString(@"Size", nil);
        sectionModel.itmesArray = [NSMutableArray array];
        [cellTypeModel.detailModel.same_goods_spec.size enumerateObjectsUsingBlock:^(GoodsDetialSizeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZFSizeSelectItemsModel *model = [[ZFSizeSelectItemsModel alloc] init];
            model.type = ZFSizeSelectItemTypeSize;
            model.attrName = obj.attr_value;
            model.is_click = obj.is_click;
            model.goodsId = obj.goods_id;
            model.width = [self calculateAttrInfoWidthWithAttrName:ZFToString(obj.attr_value)];
            model.isSelect = NO;
            if ([cellTypeModel.detailModel.goods_id isEqualToString:obj.goods_id]) {
                model.isSelect = YES;
                sizeTips = obj.data_tips;
                sizeTipsArrModel = obj.sizeTipsArrModel;
                sectionModel.typeName = [NSString stringWithFormat:@"%@:%@", ZFLocalizedString(@"Size", nil), ZFToString(obj.attr_value)];
            }
            [sectionModel.itmesArray addObject:model];
        }];
        [self.dataArray addObject:sectionModel];
        
        /// 尺码提示文案采用bts显示: 表格显示为1个时只显示一行
        ZFSizeSelectSectionModel *sizeTipsModel = [[ZFSizeSelectSectionModel alloc] init];
        sizeTipsModel.type = ZFSizeSelectSectionTypeSizeTips;
        sizeTipsModel.typeName = sizeTips;
        
        if (sizeTipsArrModel.tipsTextModelArray.count > 1) {
            sizeTipsArrModel.tipsTextModelArray = [sizeTipsArrModel configuTipsTitleWidth];
            self.sizeTipsArrModel = sizeTipsArrModel;
            sizeTipsModel.sectionHeight = 82;
            [self.dataArray addObject:sizeTipsModel];
            
        } else if (!ZFIsEmptyString(sizeTips)) {
            sizeTipsModel.sectionHeight = [self calculateAttrInfoHeightWithSizeTips:sizeTips];
            [self.dataArray addObject:sizeTipsModel];
        }
    }

    //V4.8.0增加库存提醒一栏
    if (!ZFIsEmptyString(cellTypeModel.detailModel.stock_tips)) {
        ZFSizeSelectSectionModel *stockTipsModel = [[ZFSizeSelectSectionModel alloc] init];
        stockTipsModel.type = ZFSizeSelectSectionTypeStockTips;
        stockTipsModel.typeName = @"";
        stockTipsModel.sectionHeight = [self calculateStockTipsHeight:cellTypeModel.detailModel.stock_tips];;
        [self.dataArray addObject:stockTipsModel];
    }

    //mult attr
    if (cellTypeModel.detailModel.goods_mulit_attr.count > 0) {
        [cellTypeModel.detailModel.goods_mulit_attr enumerateObjectsUsingBlock:^(GoodsDetailMulitAttrModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZFSizeSelectSectionModel *sectionModel = [[ZFSizeSelectSectionModel alloc] init];
            sectionModel.type = ZFSizeSelectSectionTypeMultAttr;
            sectionModel.typeName = obj.name;
            sectionModel.itmesArray = [NSMutableArray array];
            [obj.value enumerateObjectsUsingBlock:^(GoodsDetailMulitAttrInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ZFSizeSelectItemsModel *model = [[ZFSizeSelectItemsModel alloc] init];
                model.type = ZFSizeSelectItemTypeMultAttr;
                model.attrName = obj.attr_value;
                model.is_click = obj.is_click;
                model.goodsId = obj.goods_id;
                model.width = [self calculateAttrInfoWidthWithAttrName:ZFToString(obj.attr_value)];
                model.isSelect = [cellTypeModel.detailModel.goods_id isEqualToString:obj.goods_id];
                [sectionModel.itmesArray addObject:model];
            }];
            [self.dataArray addObject:sectionModel];
        }];
    }
    [self.collectionView reloadData];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    ZFSizeSelectSectionModel *sectionModel = self.dataArray[section];
    return sectionModel.itmesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFSizeSelectSectionModel *sectionModel = self.dataArray[indexPath.section];

    if (sectionModel.type == ZFSizeSelectSectionTypeColor) {
        ZFSelectSizeColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFColorSelectCollectionViewCellIdentifier forIndexPath:indexPath];
        cell.model = sectionModel.itmesArray[indexPath.item];
        return cell;
        
    } else if (sectionModel.type == ZFSizeSelectSectionTypeSize) {
        ZFSelectSizeSizeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFSizeSelectCollectionViewCellIdentifier forIndexPath:indexPath];
        cell.model = sectionModel.itmesArray[indexPath.item];
        return cell;
        
    } else if (sectionModel.type == ZFSizeSelectSectionTypeMultAttr) {
        ZFSelectSizeSizeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFSizeSelectCollectionViewCellIdentifier forIndexPath:indexPath];
        cell.model = sectionModel.itmesArray[indexPath.item];
        return cell;
    }
    // 防止异常
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    ZFSizeSelectSectionModel *sectionModel = self.dataArray[indexPath.section];
    ZFSizeSelectItemsModel *model = sectionModel.itmesArray[indexPath.item];
    if (!model.is_click || [model.goodsId isEqualToString:self.cellTypeModel.detailModel.goods_id]) {
        return ;
    }
    NSString *itemName = model.type == ZFSizeSelectItemTypeColor ? @"Color" : @"Size";
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Selected_%@_%@_%@", itemName, model.attrName, model.goodsId] itemName:itemName ContentType:@"Goods - Detail" itemCategory:itemName];
    
    NSInteger actionType = 0;
    if (model.type == ZFSizeSelectSectionTypeSize) {
        actionType = ZFSelectStandard_ChangeGoodsIdBySizeType;
    } else {
        actionType = ZFSelectStandard_ChangeGoodsIdType;
    }
    if (self.cellTypeModel.detailCellActionBlock) {
        self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, @(actionType), model.goodsId);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ZFSizeSelectSectionModel *sectionModel = self.dataArray[indexPath.section];

    if (sectionModel.type == ZFSizeSelectSectionTypeColor) {

        ZFSelectSizeColorHeader *normalView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFSizeSelectNormalHeaderViewIdentifier forIndexPath:indexPath];
        normalView.title = sectionModel.typeName;
        [normalView updateTopSpace:self.groupTitleTopSpace];
        return normalView;

    } else if (sectionModel.type == ZFSizeSelectSectionTypeSize) {

        ZFSelectSizeSizeHeader *sizeView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFSizeSelectSizeHeaderViewIdentifier forIndexPath:indexPath];
        sizeView.title = sectionModel.typeName;
        sizeView.size_url = self.cellTypeModel.detailModel.size_url;
        [sizeView updateTopSpace:self.groupTitleTopSpace];
        @weakify(self);
        sizeView.sizeSelectGuideJumpCompletionHandler = ^(NSString *url){
            @strongify(self);
            if (self.cellTypeModel.detailCellActionBlock) {
                self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, @(ZFSelectStandard_SizeGuideType), nil);
            }
        };
        return sizeView;

    } else if (sectionModel.type == ZFSizeSelectSectionTypeSizeTips) {

        ZFSizeSelectSizeTipsView *sizeTipsView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFSizeSelectSizeTipsViewIdentifier forIndexPath:indexPath];
        [sizeTipsView setSizeTipsArrModel:self.sizeTipsArrModel tipsInfo:sectionModel.typeName];
        return sizeTipsView;

    }  else if (sectionModel.type == ZFSizeSelectSectionTypeStockTips) { //V4.8.0增加库存提醒一栏

        ZFSelectSizeStockTipsHeader *stockTipsView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFSizeSelectStockTipsHeaderViewIdentifier forIndexPath:indexPath];
        stockTipsView.stockTipsInfo = self.cellTypeModel.detailModel.stock_tips;
        return stockTipsView;

    } else if (sectionModel.type == ZFSizeSelectSectionTypeMultAttr) {

        ZFSelectSizeColorHeader *normalView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFSizeSelectNormalHeaderViewIdentifier forIndexPath:indexPath];
        normalView.title = sectionModel.typeName;
        [normalView updateTopSpace:self.groupTitleTopSpace];
        return normalView;
    }
    // 防止异常
    return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];;
}

#pragma mark - <UICollectionViewDelegateLeftAlignedLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    ZFSizeSelectSectionModel *sectionModel = self.dataArray[section];
    if(sectionModel.type == ZFSizeSelectSectionTypeStockTips) { //V4.8.0增加库存提醒一栏
        return CGSizeMake(KScreenWidth, sectionModel.sectionHeight);

    } else if(sectionModel.type == ZFSizeSelectSectionTypeSizeTips) {
        return CGSizeMake(KScreenWidth, sectionModel.sectionHeight);
    }
    return CGSizeMake(KScreenWidth, 28 + self.groupTitleTopSpace); //默认44;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFSizeSelectSectionModel *sectionModel = self.dataArray[indexPath.section];
    ZFSizeSelectItemsModel *model = sectionModel.itmesArray[indexPath.item];
    if(sectionModel.type == ZFSizeSelectSectionTypeSize ||
       sectionModel.type == ZFSizeSelectSectionTypeMultAttr) {
        return CGSizeMake(model.width, kSelectSizeItemHeight);
    } else {
        return CGSizeMake(model.width, 36);
    }
}

#pragma mark - private methods
- (CGFloat)calculateAttrInfoWidthWithAttrName:(NSString *)attrName {
    NSDictionary *attribute = @{NSFontAttributeName: ZFFontSystemSize(14)};
    CGSize size = [attrName boundingRectWithSize:CGSizeMake(MAXFLOAT, kSelectSizeItemHeight)  options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)   attributes:attribute context:nil].size;
    CGFloat width = size.width <= 48 ? 48 : size.width + 28;
    if (width > (KScreenWidth - 32)) {
        width = KScreenWidth - 32;
    }
    return width;
}

/// stock_tips的整个View高度
- (CGFloat)calculateStockTipsHeight:(NSString *)stockTips {
    CGFloat bottomHeight = 0.0;
    if (!ZFIsEmptyString(stockTips)) {
        CGSize stockTipsSize = [stockTips textSizeWithFont:ZFFontSystemSize(14) constrainedToSize:CGSizeMake(kStockTipsWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping paragraphStyle:nil];
        bottomHeight = kStockTipsTopSetY + stockTipsSize.height + kStockTipsTopSetY + 5;
    }
    return bottomHeight;
}

- (CGFloat)calculateAttrInfoHeightWithSizeTips:(NSString *)sizeTips {
    CGFloat calculateWidth = [ZFSizeSelectSizeTipsView tipsCanCalculateWidth];
    CGFloat space = [ZFSizeSelectSizeTipsView tipsTopBottomSpace];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:4];

    //为什么传paragraphStyle高度不对
    CGSize size = [sizeTips textSizeWithFont:ZFFontSystemSize(12) constrainedToSize:CGSizeMake(calculateWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping paragraphStyle:nil];
    return size.height  < 20 ? (kSizeSelectTempSpace + space ): (35 + space);
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
    [self.contentView addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-kStandardCellBottomSpace);
    }];
}

#pragma mark - getter

- (CGFloat)groupTitleTopSpace {
    return IPHONE_X_5_15 ? 12 : 12;
}

- (NSMutableArray<ZFSizeSelectSectionModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewLeftAlignedLayout *flowLayout = [[UICollectionViewLeftAlignedLayout alloc] init];
        flowLayout.minimumLineSpacing = 12;
        flowLayout.minimumInteritemSpacing = 12;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        if ([SystemConfigUtils isRightToLeftShow]) {
            flowLayout.alignedLayoutType = UICollectionViewLeftAlignedLayoutTypeRight;
        } else {
            flowLayout.alignedLayoutType = UICollectionViewLeftAlignedLayoutTypeLeft;
        }
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) collectionViewLayout:flowLayout];

        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = NO;
        _collectionView.backgroundColor = [UIColor whiteColor];

        [_collectionView registerClass:[ZFSelectSizeSizeCell class] forCellWithReuseIdentifier:kZFSizeSelectCollectionViewCellIdentifier];
        [_collectionView registerClass:[ZFSelectSizeColorCell class] forCellWithReuseIdentifier:kZFColorSelectCollectionViewCellIdentifier];
        [_collectionView registerClass:[ZFSelectSizeColorHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFSizeSelectNormalHeaderViewIdentifier];
        
        [_collectionView registerClass:[ZFSizeSelectSizeTipsView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFSizeSelectSizeTipsViewIdentifier];
        
        [_collectionView registerClass:[ZFSelectSizeSizeHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFSizeSelectSizeHeaderViewIdentifier];
        // V4.8.0增加库存提醒一栏
        [_collectionView registerClass:[ZFSelectSizeStockTipsHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFSizeSelectStockTipsHeaderViewIdentifier];
        
        // 防止异常注册一个空cell
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            self.collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        }
    }
    return _collectionView;
}

@end
