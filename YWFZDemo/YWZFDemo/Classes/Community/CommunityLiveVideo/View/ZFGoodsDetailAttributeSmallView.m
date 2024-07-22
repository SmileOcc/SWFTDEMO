//
//  ZFGoodsDetailAttributeSmallView.m
//  ZZZZZ
//
//  Created by YW on 2019/7/24.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailAttributeSmallView.h"

#import "ZFInitViewProtocol.h"
#import "ZFSelectSizeColorHeader.h"
#import "ZFSelectSizeSizeHeader.h"
#import "ZFSelectSizeSizeFooter.h"
#import "ZFSelectSizeStockTipsHeader.h"
#import "ZFSelectSizeSizeCell.h"
#import "ZFSelectSizeColorCell.h"
#import "ZFSizeSelectSectionModel.h"

#import "UIView+ZFBadge.h"
#import "ZFPopDownAnimation.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "NSStringUtils.h"
#import "NSString+Extended.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "SystemConfigUtils.h"
#import "ExchangeManager.h"
#import "BigClickAreaButton.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFGoodsDetailAttributeSmallView ()
<
ZFInitViewProtocol,
UICollectionViewDelegate,
UICollectionViewDataSource,
//UICollectionViewDelegateLeftAlignedLayout,
UICollectionViewDelegateFlowLayout
>

@property (nonatomic, strong) UIView            *containView;
@property (nonatomic, strong) UIView            *topView;

@property (nonatomic, strong) UIImageView       *goodsImageView;
@property (nonatomic, strong) UILabel           *shopPriceLabel;
@property (nonatomic, strong) UILabel           *marketPriceLabel;
@property (nonatomic, strong) UIView            *deleteLine;
@property (nonatomic, strong) BigClickAreaButton*closeButton;
@property (nonatomic, strong) UICollectionView  *collectionView;

@property (nonatomic, strong) UIView            *separateLineView;

@property (nonatomic, strong) UIView            *bottomView;
@property (nonatomic, strong) UIButton          *cartButton;
@property (nonatomic, strong) UIButton          *addCartButton;
@property (nonatomic, strong) UIView            *lineView;
@property (nonatomic, assign) BOOL              showCart;
@property (nonatomic, assign) CGFloat           showAlpha;
@property (nonatomic, assign) NSInteger         qityNumber;

@property (nonatomic, strong) NSMutableArray<ZFSizeSelectSectionModel *>        *dataArray;

/** 分组内容间距（只为适配)*/
@property (nonatomic, assign) CGFloat           groupTitleTopSpace;

@end

@implementation ZFGoodsDetailAttributeSmallView
@synthesize  model = _model;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame comeFromSelecteType:(BOOL)comeFromType {
    self = [super initWithFrame:frame];
    if (self) {
        self.showCart = YES;
        [self createSelectTypeView:0.4];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame showCart:(BOOL)show alpha:(CGFloat)alpha {
    self = [super initWithFrame:frame];
    if (self) {
        self.qityNumber = 1;
        self.showCart = show;
        [self createSelectTypeView:alpha];
        //刷新购物车数量
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCartNumberInfo) name:kCartNotification object:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createSelectTypeView:0.4];
    }
    return self;
}

- (void)createSelectTypeView:(CGFloat)alpha {
    self.showAlpha = alpha;
    [self zfInitView];
    [self zfAutoLayoutView];
}

#pragma mark - action methods

- (void)bottomCartViewEnable:(BOOL)enable {
    self.bottomView.userInteractionEnabled = enable;
}

- (void)closeButtonAction:(UIButton *)sender {
    [self hideSelectTypeView];
}

- (void)jumpCartButtonAction:(UIButton *)sender {
    if(self.delegate && [self.delegate respondsToSelector:@selector(goodsDetailAttribute:tapCart:)]) {
        [self.delegate goodsDetailAttribute:self tapCart:YES];
    }
}

- (void)addCartButtonAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(goodsDetailAttribute:addCartGoodsId:count:)]) {
        [self.delegate goodsDetailAttribute:self addCartGoodsId:ZFToString(self.model.goods_id) count:self.qityNumber];
    }
}

- (void)changeCartNumberInfo {
    if (self.showCart) {
        NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
        [self.cartButton showShoppingCarsBageValue:[badgeNum integerValue]];
    }
}

- (void)startAddCartAnimation:(void(^)(void))endBlock
{
    ZFPopDownAnimation *popAnimation = [[ZFPopDownAnimation alloc] init];
    popAnimation.animationImage = self.goodsImageView.image;
    popAnimation.animationDuration = 0.5f;
    CGRect rect = [self.bottomView convertRect:self.cartButton.frame toView:WINDOW];
    
    popAnimation.endPoint = CGPointMake(rect.origin.x + rect.size.width / 2, (rect.origin.y + rect.size.height / 2) - 65);
    [popAnimation startAnimation:self endBlock:^{
        if (endBlock) {
            endBlock();
        }
        [ZFPopDownAnimation popDownRotationAnimation:self.cartButton];
    }];
}

- (void)startAddCartAnimation:(UIView *)superView endPoint:(CGPoint)endPoint endView:(UIView *)endView endBlock:(void(^)(void))endBlock
{
    if (!superView) {
        return;
    }
    if (!endView) {
        return;
    }
    ZFPopDownAnimation *popAnimation = [[ZFPopDownAnimation alloc] init];
    popAnimation.animationImage = self.goodsImageView.image;
    popAnimation.animationDuration = 0.5f;
    popAnimation.endPoint = endPoint;
    [popAnimation startAnimation:superView endBlock:^{
        if (endBlock) {
            endBlock();
        }
        [ZFPopDownAnimation popDownRotationAnimation:endView];
    }];
}

#pragma mark - private methods
- (CGFloat)calculateAttrInfoWidthWithAttrName:(NSString *)attrName {
    NSDictionary *attribute = @{NSFontAttributeName: ZFFontSystemSize(14)};
    CGSize  size = [attrName boundingRectWithSize:CGSizeMake(MAXFLOAT, 26)  options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)   attributes:attribute context:nil].size;
    CGFloat width = size.width + 20 <= 36 ? 36 : size.width + 28;
    if (width > (KScreenWidth - 32)) {
        width = KScreenWidth - 32;
    }
    return width;
}


- (void)updateSizeSelectInfo {
    [self.dataArray removeAllObjects];
    
    //color
    if (self.model.same_goods_spec.color.count > 0) {
        NSArray *colorArray = [self.model.same_goods_spec.color copy];
        
        ZFSizeSelectSectionModel *sectionModel = [[ZFSizeSelectSectionModel alloc] init];
        sectionModel.type = ZFSizeSelectSectionTypeColor;
        sectionModel.typeName = ZFLocalizedString(@"Color", nil);
        sectionModel.itmesArray = [NSMutableArray array];
        
        [colorArray enumerateObjectsUsingBlock:^(GoodsDetialColorModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZFSizeSelectItemsModel *model = [[ZFSizeSelectItemsModel alloc] init];
            model.type = ZFSizeSelectItemTypeColor;
            model.color = obj.color_code;
            model.attrName = obj.attr_value;
            model.is_click = obj.is_click;
            model.goodsId = obj.goods_id;
            model.width = 26;
            model.isSelect = [self.model.goods_id isEqualToString:obj.goods_id];
            [sectionModel.itmesArray addObject:model];
        }];
        [self.dataArray addObject:sectionModel];
    }
    //size
    if (self.model.same_goods_spec.size.count > 0) {
        NSArray *sizeArray = [self.model.same_goods_spec.size copy];
        
        __block NSString *sizeTips = @"";
        ZFSizeSelectSectionModel *sectionModel = [[ZFSizeSelectSectionModel alloc] init];
        sectionModel.type = ZFSizeSelectSectionTypeSize;
        sectionModel.typeName = ZFLocalizedString(@"Size", nil);
        sectionModel.itmesArray = [NSMutableArray array];
        [sizeArray enumerateObjectsUsingBlock:^(GoodsDetialSizeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZFSizeSelectItemsModel *model = [[ZFSizeSelectItemsModel alloc] init];
            model.type = ZFSizeSelectItemTypeSize;
            model.attrName = obj.attr_value;
            model.is_click = obj.is_click;
            model.goodsId = obj.goods_id;
            model.width = [self calculateAttrInfoWidthWithAttrName:ZFToString(obj.attr_value)];
            model.isSelect = [self.model.goods_id isEqualToString:obj.goods_id];
            if ([self.model.goods_id isEqualToString:obj.goods_id]) {
                sizeTips = obj.data_tips;
            }
            [sectionModel.itmesArray addObject:model];
        }];
        [self.dataArray addObject:sectionModel];
    }
    
    //mult attr
    if (self.model.goods_mulit_attr.count > 0) {
        NSArray *attrArray = [self.model.goods_mulit_attr copy];
        
        [attrArray enumerateObjectsUsingBlock:^(GoodsDetailMulitAttrModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
                model.isSelect = [self.model.goods_id isEqualToString:obj.goods_id];
                [sectionModel.itmesArray addObject:model];
            }];
            [self.dataArray addObject:sectionModel];
        }];
    }
    
    
    [self.collectionView reloadData];
}

#pragma mark - animation methods
- (void)openSelectTypeView {
    self.hidden = NO;
    [self changeCartNumberInfo];
    [self showGoodsView:YES];
}

- (void)hideSelectTypeView {
    [self showGoodsView:NO];
}

- (void)showGoodsView:(BOOL)isShow {
    
    CGFloat leadingX = 0;
    if (isShow) {
        leadingX = -300;
        self.hidden = NO;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.containView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_trailing).offset(leadingX);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!isShow) {
            self.hidden = YES;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(goodsDetailAttribute:showState:)]) {
            [self.delegate goodsDetailAttribute:self showState:isShow];
        }
    }];
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
        
        ZFSelectSizeColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFSelectSizeColorCell.class) forIndexPath:indexPath];
        ZFSizeSelectItemsModel *model = sectionModel.itmesArray[indexPath.item];
        [cell updateColorSize:CGSizeMake(model.width, 26) itmesModel:model];
        return cell;
        
    } else if (sectionModel.type == ZFSizeSelectSectionTypeSize) {
        
        ZFSelectSizeSizeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFSelectSizeSizeCell.class) forIndexPath:indexPath];
        ZFSizeSelectItemsModel *model = sectionModel.itmesArray[indexPath.item];
        [cell updateColorSize:CGSizeMake(model.width, 26) itmesModel:model];
        return cell;
        
    } else if (sectionModel.type == ZFSizeSelectSectionTypeMultAttr) {
        
        ZFSelectSizeSizeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFSelectSizeSizeCell.class) forIndexPath:indexPath];
        ZFSizeSelectItemsModel *model = sectionModel.itmesArray[indexPath.item];
        [cell updateColorSize:CGSizeMake(model.width, 26) itmesModel:model];
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    ZFSizeSelectSectionModel *sectionModel = self.dataArray[indexPath.section];
    ZFSizeSelectItemsModel *model = sectionModel.itmesArray[indexPath.item];
    if (!model.is_click || [model.goodsId isEqualToString:self.model.goods_id]) {
        return ;
    }
    NSString *itemName = model.type == ZFSizeSelectItemTypeColor ? @"Color" : @"Size";
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Selected_%@_%@_%@", itemName, model.attrName, model.goodsId] itemName:itemName ContentType:@"Goods - Detail" itemCategory:itemName];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(goodsDetailAttribute:selectGoodsId:)]) {
        [self.delegate goodsDetailAttribute:self selectGoodsId:ZFToString(model.goodsId)];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    ZFSizeSelectSectionModel *sectionModel = self.dataArray[indexPath.section];
    
    if (sectionModel.type == ZFSizeSelectSectionTypeColor) {
        
        ZFSelectSizeColorHeader *normalView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectSizeColorHeader.class) forIndexPath:indexPath];
        normalView.title = sectionModel.typeName;
        [normalView updateTopSpace:self.groupTitleTopSpace];
        return normalView;
        
    } else if (sectionModel.type == ZFSizeSelectSectionTypeSize) {
        
        ZFSelectSizeSizeHeader *sizeView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectSizeSizeHeader.class) forIndexPath:indexPath];
        [sizeView updateTopSpace:self.groupTitleTopSpace];
        [sizeView showSizeGuide:NO];

        return sizeView;
        
    }
    return nil;
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
    return CGSizeMake(model.width, 26);
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:self.showAlpha];
    [self addSubview:self.maskView];
    [self addSubview:self.containView];
    
    [self.containView addSubview:self.topView];
    [self.containView addSubview:self.collectionView];
    [self.containView addSubview:self.separateLineView];
    [self.containView addSubview:self.bottomView];
    
    [self.topView addSubview:self.goodsImageView];
    [self.topView addSubview:self.shopPriceLabel];
    [self.topView addSubview:self.marketPriceLabel];
    [self.topView addSubview:self.closeButton];
    
    [self.bottomView addSubview:self.cartButton];
    [self.bottomView addSubview:self.addCartButton];
    [self.bottomView addSubview:self.lineView];
    
    [self.marketPriceLabel addSubview:self.deleteLine];
    
    if (self.showCart) {
        self.cartButton.hidden = NO;
        self.addCartButton.hidden = NO;
        self.lineView.hidden = NO;
    } else {
        self.cartButton.hidden = YES;
        self.addCartButton.hidden = YES;
        self.lineView.hidden = YES;
    }
}

- (void)zfAutoLayoutView {
    CGFloat topSpace = IPHONE_X_5_15 ? 16 : 8;
    CGFloat topViewHeight = IPHONE_X_5_15 ? 104 : 80;
    CGFloat bottomHeight = self.showCart ? 50 : 0;
    
    //====== 内容视图 =======//
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.containView);
        make.height.mas_equalTo(topViewHeight);
    }];
    
    //====== 底部 购物车 事件 ======//
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.containView);
        make.height.mas_equalTo(bottomHeight);
        make.bottom.mas_equalTo(self.containView.mas_bottom);
    }];
    
    [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(self.bottomView);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(50);
    }];
    
    [self.addCartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.mas_equalTo(self.bottomView);
        make.leading.mas_equalTo(self.cartButton.mas_trailing);
        make.height.mas_equalTo(50);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.bottomView);
        make.height.mas_equalTo(0.5);
    }];
    
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.leading.mas_equalTo(self.containView.mas_leading);
        make.trailing.mas_equalTo(self.containView.mas_trailing);
        make.bottom.mas_equalTo(self.containView.mas_bottom).offset(self.showCart ? -50 : 0);
    }];
    
    [self.separateLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.containView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.containView.mas_trailing).offset(-16);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(self.topView.mas_bottom);
    }];
    
    //===============
    
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_top).offset(topSpace);
        make.bottom.mas_equalTo(self.topView.mas_bottom).offset(-topSpace);
        make.leading.mas_equalTo(self.topView.mas_leading).offset(16);
        make.width.mas_equalTo(self.goodsImageView.mas_height).multipliedBy(54/72.0);
    }];
    
    [self.shopPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.goodsImageView.mas_trailing).offset(12);
        make.bottom.mas_equalTo(self.goodsImageView.mas_centerY).offset(-2);
        make.height.mas_equalTo(20);
    }];
    
    [self.marketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.goodsImageView.mas_trailing).offset(12);
        make.top.mas_equalTo(self.shopPriceLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(20);
    }];
    
    [self.deleteLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.leading.trailing.mas_equalTo(self.marketPriceLabel);
        make.height.mas_equalTo(1);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topView.mas_top);
        make.leading.mas_equalTo(self.topView.mas_leading);
    }];
}

/**
 * 购物车进来底部只显示Ok按钮, 不显示数量控件
 */
- (void)showOkButtonByCartType {
    self.bottomView.backgroundColor = ZFCOLOR_WHITE;
    self.bottomView.hidden = NO;
    self.cartButton.hidden = YES;
    self.addCartButton.hidden = NO;
    [self.addCartButton setTitle:ZFLocalizedString(@"OK", nil) forState:0];
    
    [self.containView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.containView);
        make.height.mas_equalTo(50+12);
        make.bottom.mas_equalTo(self.containView.mas_bottom);
    }];
    
    [self.addCartButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bottomView).offset(-(12));;
        make.leading.mas_equalTo(self.bottomView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset(-12);
        make.height.mas_equalTo(50);
    }];
}

#pragma mark - Property Method

- (void)setModel:(GoodsDetailModel *)model {
    _model = model;
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:_model.wp_image]
                                placeholder:ZFImageWithName(@"index_loading")
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                 completion:nil];//检测到有卡顿
    self.shopPriceLabel.text = [ExchangeManager transforPrice:_model.shop_price];
    self.marketPriceLabel.text = [ExchangeManager transforPrice:_model.market_price];
    [self updateSizeSelectInfo];
}

- (void)setChooseNumebr:(NSInteger)chooseNumebr {
    _chooseNumebr = chooseNumebr;
}

/**
 * 给外部获取选择规格视图的总高度
 */
- (CGFloat)fetchSelectStandardViewTotalHeight:(GoodsDetailModel *)detailModel {
    self.model = detailModel;
    [self layoutIfNeeded];
    NSInteger sectionCount = self.dataArray.count - 1;
    if (sectionCount < 0) {
        return 0.0;
    }
    UICollectionReusableView *selectQityNumberView = [self collectionView:self.collectionView viewForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionCount]];
    
    // -40是因为在底部有很多空白高度
    return CGRectGetMaxY(selectQityNumberView.frame) - 40;
}


- (CGFloat)groupTitleTopSpace {
    return IPHONE_X_5_15 ? 12 : 12;
}

- (NSMutableArray<ZFSizeSelectSectionModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


- (UIView *)containView {
    if (!_containView) {
        _containView = [[UIView alloc] initWithFrame:CGRectZero];
        _containView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _containView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _topView;
}

- (UIView *)separateLineView {
    if (!_separateLineView) {
        _separateLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _separateLineView.backgroundColor = ColorHex_Alpha(0xCCCCCC, 0.5);
    }
    return _separateLineView;
}

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _goodsImageView;
}

- (UILabel *)shopPriceLabel {
    if (!_shopPriceLabel) {
        _shopPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shopPriceLabel.textColor = ZFC0xFE5269();
        _shopPriceLabel.font = ZFFontBoldSize(18);
    }
    return _shopPriceLabel;
}

- (UILabel *)marketPriceLabel {
    if (!_marketPriceLabel) {
        _marketPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _marketPriceLabel.textColor = ZFC0x999999();
        _marketPriceLabel.font = ZFFontSystemSize(14);
    }
    return _marketPriceLabel;
}

- (UIView *)deleteLine {
    if (!_deleteLine) {
        _deleteLine = [[UIView alloc] initWithFrame:CGRectZero];
        _deleteLine.backgroundColor = ZFCOLOR(153, 153, 153, 1.f);
    }
    return _deleteLine;
}

- (BigClickAreaButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"attribute_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.clickAreaRadious = 64;
        [_closeButton convertUIWithARLanguage];
    }
    return _closeButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 12;
        flowLayout.minimumInteritemSpacing = 12;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        
        [_collectionView registerClass:[ZFSelectSizeSizeCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFSelectSizeSizeCell.class)];
        [_collectionView registerClass:[ZFSelectSizeColorCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFSelectSizeColorCell.class)];
        [_collectionView registerClass:[ZFSelectSizeColorHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectSizeColorHeader.class)];
        [_collectionView registerClass:[ZFSelectSizeSizeHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectSizeSizeHeader.class)];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            self.collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        }
    }
    return _collectionView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _bottomView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1);
        _lineView.hidden = YES;
    }
    return _lineView;
}

- (UIButton *)cartButton {
    if (!_cartButton) {
        _cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cartButton setImage:[UIImage imageNamed:@"public_bag"] forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(jumpCartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _cartButton.hidden = YES;
    }
    return _cartButton;
}

- (UIButton *)addCartButton {
    if (!_addCartButton) {
        _addCartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addCartButton.backgroundColor = ZFC0x2D2D2D();
        [_addCartButton setTitle:ZFLocalizedString(@"Detail_Product_AddToBag", nil) forState:UIControlStateNormal];
        [_addCartButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        [_addCartButton setTitle:ZFLocalizedString(@"Detail_Product_OutOfStock", nil) forState:UIControlStateDisabled];
        [_addCartButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateDisabled];
        [_addCartButton addTarget:self action:@selector(addCartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _addCartButton.hidden = YES;
    }
    return _addCartButton;
}

@end
