//
//  ZFLiveGoodsAttributeView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFLiveGoodsAttributeView.h"
static CGFloat kBottomViewHeight = 40;
static CGFloat kBottomViewSpace = 10;

@interface ZFLiveGoodsAttributeView()
<
ZFInitViewProtocol,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
CAAnimationDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic, assign) CGFloat               groupTitleTopSpace;
@property (nonatomic, strong) NSString              *bottomBtnTitle;
@property (nonatomic, strong) NSMutableArray<ZFSizeSelectSectionModel *> *dataArray;
@property (nonatomic, strong) UIView                *containView;
@property (nonatomic, strong) BigClickAreaButton    *closeButton;
@property (nonatomic, strong) ZFSelectSizeImageListView *topImageListView;
@property (nonatomic, strong) UIView                *bottomView;
@property (nonatomic, strong) UIView                *lineView;
@property (nonatomic, strong) UIButton              *cartButton;
@property (nonatomic, strong) UIButton              *addCartButton;
@property (nonatomic, strong) UIView                *emptyWhiteView;
@property (nonatomic, assign) BOOL                  showCart;
@property (nonatomic, assign) CGFloat               showAlpha;
@property (nonatomic, strong) ZFSizeTipsArrModel    *sizeTipsArrModel;

@property (nonatomic, strong) UIActivityIndicatorView           *activityView;

@end

@implementation ZFLiveGoodsAttributeView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initSelectSizeView:NO
                     bottomBtnTitle:ZFLocalizedString(@"Detail_Product_AddToBag", nil)];
}

- (instancetype)initSelectSizeView:(BOOL)showCart
                    bottomBtnTitle:(NSString *)bottomBtnTitle
{
    CGRect rect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:rect];
    if (self) {
        //点击背景消失
        rect.size.height -= 20;
        UIControl *control = [[UIControl alloc] initWithFrame:rect];
        [control addTarget:self action:@selector(hideSelectTypeView) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:control];
        
        self.showAlpha = 0.4;
        self.showCart = showCart;
        self.bottomBtnTitle = bottomBtnTitle;
        [self initCustomSelectView];
        [self addNotification];
    }
    return self;
}

- (void)initCustomSelectView {
    [self zfInitView];
    [self zfAutoLayoutView];
    [self.addCartButton setTitle:ZFToString(self.bottomBtnTitle) forState:UIControlStateNormal];
}

- (void)showRefreshButton:(BOOL)isShow {
    self.refreshButton.hidden = !isShow;
}

- (void)showLoadActivityView:(BOOL)isShow {
    if (isShow) {
        if (!self.activityView.superview) {
            [self addSubview:self.activityView];
            
            [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self.mas_centerX);
                make.centerY.mas_equalTo(self.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(30, 30));
            }];
        }
        
        self.activityView.hidden = NO;
        [self.activityView startAnimating];
    } else {
        if (_activityView && !_activityView.isHidden) {
            [self.activityView stopAnimating];
        }
    }
}
/// 刷新购物车数量
- (void)addNotification {
    if (self.showCart) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCartNumberInfo) name:kCartNotification object:nil];
    }
}

#pragma mark - animation methods


//- (void)showSelectTypeView:(BOOL)show {
//    if (show) {
//        self.hidden = NO;
//        [self changeCartNumberInfo];
//        [self layoutIfNeeded];
//    }
//    CGFloat containViewTmpH = kImageListViewHeight + self.collectionView.contentSize.height + kBottomViewHeight + self.fetchBottomMargin + kBottomViewSpace;
//    CGFloat showContainHeight = MIN(KScreenHeight * 3/4, containViewTmpH);
//
//    CGFloat hasHeight = self.containView.frame.size.height;
//    if (hasHeight) {
//        //刷新两次会引起页面跳动
//        showContainHeight = hasHeight;
//    }
//
//    [self.containView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.leading.trailing.mas_equalTo(self);
//        make.height.mas_equalTo(showContainHeight);
//        if (show) {
//            make.bottom.mas_equalTo(self.mas_bottom);
//        } else {
//            make.top.mas_equalTo(self.mas_bottom).offset(20);
//        }
//    }];
//
//    [UIView animateWithDuration:0.3 delay:0
//         usingSpringWithDamping:0.8
//          initialSpringVelocity:5
//                        options:UIViewAnimationOptionCurveLinear
//                     animations:^{
//                         CGFloat alpha = show ? self.showAlpha : 0.01;
//                         self.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
//                         [self layoutIfNeeded];
//
//                     } completion:^(BOOL finished) {
//                         self.emptyWhiteView.backgroundColor = show ? [UIColor clearColor] : ZFCOLOR_WHITE;
//                         if (!show) {
//                             self.hidden = YES;
//                         }
//                         if (self.openOrCloseBlock) {
//                             self.openOrCloseBlock(show);  //显示/关闭
//                         }
//                     }];
//}
//
//- (void)openSelectTypeView {
//    [self showSelectTypeView:YES];
//}
//
//- (void)hideSelectTypeView {
//    [self showSelectTypeView:NO];
//}

#pragma mark - action methods

- (void)actionRefresh:(UIButton *)sender {
    if (self.refreshBlock) {
        self.refreshBlock();
    }
}

- (void)bottomCartViewEnable:(BOOL)enable {
    self.bottomView.userInteractionEnabled = enable;
}

- (void)jumpCartButtonAction:(UIButton *)sender {
    if (self.cartBlock) {
        self.cartBlock();
    }
}

- (void)addCartButtonAction:(UIButton *)sender {
    if (self.addCartBlock) {
        self.addCartBlock(ZFToString(self.model.goods_id), 1);
    }
}

- (void)changeCartNumberInfo {
    if (self.showCart) {
        NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
        [self.cartButton showShoppingCarsBageValue:[badgeNum integerValue]];
    }
}

#pragma mark - <AddCart>

- (void)startAddCartAnimation:(void(^)(void))endBlock {
    CGRect rect = [self.bottomView convertRect:self.cartButton.frame toView:WINDOW];
    CGPoint endPoint = CGPointMake(rect.origin.x + rect.size.width / 2, (rect.origin.y + rect.size.height / 2) - 65);
    [self startAddCartAnimation:self
                       endPoint:endPoint
                        endView:self.cartButton
                       endBlock:endBlock];
}

- (void)startAddCartAnimation:(UIView *)superView
                     endPoint:(CGPoint)endPoint
                      endView:(UIView *)endView
                     endBlock:(void(^)(void))endBlock
{
    if (!superView) return;
    ZFPopDownAnimation *popAnimation = [[ZFPopDownAnimation alloc] init];
    popAnimation.animationImage = self.topImageListView.showGoodsImage;
    popAnimation.animationDuration = 0.5f;
    popAnimation.endPoint = endPoint;
    [popAnimation startAnimation:superView endBlock:^{
        if (endBlock) {
            endBlock();
        }
        [ZFPopDownAnimation popDownRotationAnimation:endView];
    }];
}

#pragma mark - Calculate Height

- (CGFloat)calculateAttrInfoWidthWithAttrName:(NSString *)attrName {
    NSDictionary *attribute = @{NSFontAttributeName: ZFFontSystemSize(14)};
    CGSize  size = [attrName boundingRectWithSize:CGSizeMake(MAXFLOAT, 36)  options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)   attributes:attribute context:nil].size;
    CGFloat width = size.width <= 48 ? 48 : size.width + 28;
    if (width > (KScreenWidth - 32)) {
        width = KScreenWidth - 32;
    }
    return width;
}

/// stock_tips的整个View高度
+ (CGFloat)calculateStockTipsHeight:(NSString *)stockTips {
    CGFloat bottomHeight = 0.0;
    if (!ZFIsEmptyString(stockTips)) {
        CGSize stockTipsSize = [stockTips textSizeWithFont:ZFFontSystemSize(14) constrainedToSize:CGSizeMake(kStockTipsWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping paragraphStyle:nil];
        bottomHeight = kStockTipsTopSetY + stockTipsSize.height + kStockTipsTopSetY;
    }
    return bottomHeight;
}

+ (CGFloat)calculateAttrInfoHeightWithSizeTips:(NSString *)sizeTips {
    CGFloat calculateWidth = [ZFSizeSelectSizeTipsView tipsCanCalculateWidth];
    CGFloat space = [ZFSizeSelectSizeTipsView tipsTopBottomSpace];

    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:4];

    //为什么传paragraphStyle高度不对
    CGSize size = [sizeTips textSizeWithFont:ZFFontSystemSize(12) constrainedToSize:CGSizeMake(calculateWidth, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping paragraphStyle:nil];
    return size.height  < 20 ? (kSizeSelectTempSpace + space ): (35 + space);
}

#pragma mark - setter

- (void)setAddToBagTitle:(NSString *)addToBagTitle {
    _addToBagTitle = addToBagTitle;
    if (!ZFIsEmptyString(_addToBagTitle)) {
        [self.addCartButton setTitle:_addToBagTitle forState:UIControlStateNormal];
    }
}

- (void)setRecommendGoodsId:(NSString *)recommendGoodsId {
    _recommendGoodsId = recommendGoodsId;
    if (self.model) {
        [self.collectionView reloadData];
    }
}

- (void)setReviewAllCounts:(NSInteger)reviewAllCounts {
    _reviewAllCounts = reviewAllCounts;
    if (_reviewAllCounts < 0) {
        _reviewAllCounts = 0;
    }
    [self.collectionView reloadData];
}

- (void)setModel:(GoodsDetailModel *)model {
    _model = model;
    self.topImageListView.goodsDetailModel = model;
    [self.dataArray removeAllObjects];
    
    //Title
    ZFSizeSelectSectionModel *titleSectionModel = [[ZFSizeSelectSectionModel alloc] init];
    titleSectionModel.type = ZFSizeSelectSectionTypePrice;
    titleSectionModel.sectionHeight = 60;
    [self.dataArray addObject:titleSectionModel];
    
    //Title
    ZFSizeSelectSectionModel *commentSectionModel = [[ZFSizeSelectSectionModel alloc] init];
    commentSectionModel.type = ZFSizeSelectSectionTypeLiveComment;
    commentSectionModel.sectionHeight = 0;
    [self.dataArray addObject:commentSectionModel];
    
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
            model.color_img = obj.color_img;
            model.attrName = obj.attr_value;
            model.is_click = obj.is_click;
            model.goodsId = obj.goods_id;
            model.width = 36;
            model.isSelect = NO;
            if ([self.model.goods_id isEqualToString:obj.goods_id]) {
                model.isSelect = YES;
                sectionModel.typeName = [NSString stringWithFormat:@"%@:%@", ZFLocalizedString(@"Color", nil), ZFToString(obj.attr_value)];
            }
            [sectionModel.itmesArray addObject:model];
        }];
        [self.dataArray addObject:sectionModel];
    }
    
    //size
    if (self.model.same_goods_spec.size.count > 0) {
        __block NSString *sizeTips = @"";
        __block ZFSizeTipsArrModel *sizeTipsArrModel = nil;
        
        ZFSizeSelectSectionModel *sectionModel = [[ZFSizeSelectSectionModel alloc] init];
        sectionModel.type = ZFSizeSelectSectionTypeSize;
        sectionModel.typeName = ZFLocalizedString(@"Size", nil);
        sectionModel.itmesArray = [NSMutableArray array];
        NSArray *sizeArray = [self.model.same_goods_spec.size copy];
        [sizeArray enumerateObjectsUsingBlock:^(GoodsDetialSizeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZFSizeSelectItemsModel *model = [[ZFSizeSelectItemsModel alloc] init];
            model.type = ZFSizeSelectItemTypeSize;
            model.attrName = obj.attr_value;
            model.is_click = obj.is_click;
            model.goodsId = obj.goods_id;
            model.width = [self calculateAttrInfoWidthWithAttrName:ZFToString(obj.attr_value)];
            model.isSelect = NO;
            if ([self.model.goods_id isEqualToString:obj.goods_id]) {
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
            sizeTipsModel.sectionHeight = [ZFLiveGoodsAttributeView calculateAttrInfoHeightWithSizeTips:sizeTips];
            [self.dataArray addObject:sizeTipsModel];
        }
    }
    
    //V4.8.0增加库存提醒一栏
    if (!ZFIsEmptyString(self.model.stock_tips)) {
        ZFSizeSelectSectionModel *stockTipsModel = [[ZFSizeSelectSectionModel alloc] init];
        stockTipsModel.type = ZFSizeSelectSectionTypeStockTips;
        stockTipsModel.typeName = @"";
        stockTipsModel.sectionHeight = [ZFLiveGoodsAttributeView calculateStockTipsHeight:self.model.stock_tips];
        [self.dataArray addObject:stockTipsModel];
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
        cell.model = sectionModel.itmesArray[indexPath.item];
        return cell;
        
    } else if (sectionModel.type == ZFSizeSelectSectionTypeSize) {
        ZFSelectSizeSizeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFSelectSizeSizeCell.class) forIndexPath:indexPath];
        cell.model = sectionModel.itmesArray[indexPath.item];
        return cell;
        
    } else if (sectionModel.type == ZFSizeSelectSectionTypeMultAttr) {
        ZFSelectSizeSizeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ZFSelectSizeSizeCell.class) forIndexPath:indexPath];
        cell.model = sectionModel.itmesArray[indexPath.item];
        return cell;
    }
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];;
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
    if (self.liveGoodsAttributeTypeBlock) {
        self.liveGoodsAttributeTypeBlock(model.goodsId);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ZFSizeSelectSectionModel *sectionModel = self.dataArray[indexPath.section];

    if (sectionModel.type == ZFSizeSelectSectionTypePrice) {
        ZFSelectSizePriceHeader *priceView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectSizePriceHeader.class) forIndexPath:indexPath];
        priceView.goodsDetailModel = self.model;
        return priceView;
        
    } else if(sectionModel.type == ZFSizeSelectSectionTypeLiveComment) {
        ZFSelectLiveCommentHeader *liveCommentView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectLiveCommentHeader.class) forIndexPath:indexPath];
        
        if (!ZFIsEmptyString(self.recommendGoodsId) && [self.firstGoodsId isEqualToString:self.recommendGoodsId]) {
            [liveCommentView updateCommentNums:self.reviewAllCounts liveMark:YES];
        } else {
            [liveCommentView updateCommentNums:self.reviewAllCounts liveMark:NO];
        }
        
        @weakify(self);
        liveCommentView.commentBlock = ^{
            @strongify(self);
            if (self.commentBlock) {
                self.commentBlock(self.model);
            }
        };
        return liveCommentView;
    }
    else if (sectionModel.type == ZFSizeSelectSectionTypeColor) {
        
        ZFSelectSizeColorHeader *normalView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectSizeColorHeader.class) forIndexPath:indexPath];
        normalView.title = sectionModel.typeName;
        [normalView updateTopSpace:self.groupTitleTopSpace];
        return normalView;
        
    } else if (sectionModel.type == ZFSizeSelectSectionTypeSize) {
        
        ZFSelectSizeSizeHeader *sizeView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectSizeSizeHeader.class) forIndexPath:indexPath];
        sizeView.title = sectionModel.typeName;
        sizeView.size_url = self.model.size_url;
        [sizeView updateTopSpace:self.groupTitleTopSpace];
        
        @weakify(self);
        sizeView.sizeSelectGuideJumpCompletionHandler = ^(NSString *url){
            @strongify(self);
            if (self.liveGoodsAttributeSizeGuideBlock) {
                self.liveGoodsAttributeSizeGuideBlock(url);
            }
        };
        return sizeView;
        
    } else if (sectionModel.type == ZFSizeSelectSectionTypeSizeTips) {
        
        ZFSizeSelectSizeTipsView *sizeTipsView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSizeSelectSizeTipsView.class) forIndexPath:indexPath];
        [sizeTipsView setSizeTipsArrModel:self.sizeTipsArrModel tipsInfo:sectionModel.typeName];
        return sizeTipsView;
        
    }  else if (sectionModel.type == ZFSizeSelectSectionTypeStockTips) { //V4.8.0增加库存提醒一栏
        
        ZFSelectSizeStockTipsHeader *stockTipsView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectSizeStockTipsHeader.class) forIndexPath:indexPath];
        stockTipsView.stockTipsInfo = self.model.stock_tips;
        return stockTipsView;
        
    } else if (sectionModel.type == ZFSizeSelectSectionTypeMultAttr) {
        
        ZFSelectSizeColorHeader *normalView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectSizeColorHeader.class) forIndexPath:indexPath];
        normalView.title = sectionModel.typeName;
        [normalView updateTopSpace:self.groupTitleTopSpace];
        return normalView;
    }
    return nil;
}

#pragma mark - <UICollectionViewDelegateLeftAlignedLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    ZFSizeSelectSectionModel *sectionModel = self.dataArray[section];
    
    if(sectionModel.type == ZFSizeSelectSectionTypePrice
       || sectionModel.type == ZFSizeSelectSectionTypeSizeTips
       || sectionModel.type == ZFSizeSelectSectionTypeStockTips) {
        
        return CGSizeMake(KScreenWidth, sectionModel.sectionHeight);
        
    } else if(sectionModel.type == ZFSizeSelectSectionTypeLiveComment) {
        return CGSizeMake(KScreenWidth, 20);
    }
    return CGSizeMake(KScreenWidth, 28 + self.groupTitleTopSpace);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFSizeSelectSectionModel *sectionModel = self.dataArray[indexPath.section];
    ZFSizeSelectItemsModel *model = sectionModel.itmesArray[indexPath.item];
    return CGSizeMake(model.width, 36);
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:self.showAlpha];
    [self addSubview:self.closeButton];
    [self addSubview:self.emptyWhiteView];
    [self addSubview:self.containView];
    [self addSubview:self.refreshButton];
    
    [self.containView addSubview:self.topImageListView];
    [self.containView addSubview:self.collectionView];
    [self.containView addSubview:self.bottomView];
    
    [self.bottomView addSubview:self.lineView];
    [self.bottomView addSubview:self.cartButton];
    [self.bottomView addSubview:self.addCartButton];

    self.addCartButton.hidden = NO;
    self.cartButton.hidden = !self.showCart;
    self.lineView.hidden = !self.showCart;
    
    if (!self.showCart) {
        self.addCartButton.layer.masksToBounds = YES;
        self.addCartButton.layer.cornerRadius = 3;
    }
    [self bringSubviewToFront:self.refreshButton];
}

- (void)zfAutoLayoutView {
    [self.emptyWhiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.mas_equalTo(self);
        make.height.mas_equalTo(20);
    }];
    
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.mas_top);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.containView.mas_top).offset(-16);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
    }];
    
    [self.topImageListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.containView.mas_top);
        make.leading.trailing.mas_equalTo(self.containView);
        make.height.mas_equalTo(kImageListViewHeight + kListViewSpace);//高度固定
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.containView);
        make.bottom.mas_equalTo(self.containView.mas_bottom);
        make.height.mas_equalTo(kBottomViewHeight + self.fetchBottomMargin);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.bottomView);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView);
        make.leading.mas_equalTo(self.bottomView).offset((self.showCart ? 0 : 16));
        make.width.mas_equalTo((self.showCart ? 120 : 0));
        make.height.mas_equalTo(kBottomViewHeight);
        make.bottom.mas_equalTo(self.containView.mas_bottom).offset(-self.fetchBottomMargin);
    }];
    
    [self.addCartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView);
        make.leading.mas_equalTo(self.cartButton.mas_trailing);
        make.trailing.mas_equalTo(self.bottomView.mas_trailing).offset((self.showCart ? 0 : -16));
        make.height.mas_equalTo(self.cartButton.mas_height);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topImageListView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.containView);
        make.bottom.mas_equalTo(self.bottomView.mas_top).offset(-kBottomViewSpace);
    }];
    
    [self.refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_lessThanOrEqualTo(160);
        make.height.mas_equalTo(32);
    }];
}

#pragma mark - getter
- (CGFloat)fetchBottomMargin {
    return (IPHONE_X_5_15 ? 34 : (self.showCart ? 0 : 8));
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

- (BigClickAreaButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"size_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(hideSelectTypeView)
               forControlEvents:UIControlEventTouchUpInside];
        _closeButton.clickAreaRadious = 64;
    }
    return _closeButton;
}

- (ZFSelectSizeImageListView *)topImageListView {
    if (!_topImageListView) {
        _topImageListView = [[ZFSelectSizeImageListView alloc] init];
    }
    return _topImageListView;
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
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        
        [_collectionView registerClass:[ZFSelectSizeSizeCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFSelectSizeSizeCell.class)];
        [_collectionView registerClass:[ZFSelectSizeColorCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFSelectSizeColorCell.class)];
            
        [_collectionView registerClass:[ZFSelectSizePriceHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectSizePriceHeader.class)];
        
        [_collectionView registerClass:[ZFSelectSizeColorHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectSizeColorHeader.class)];
        [_collectionView registerClass:[ZFSizeSelectSizeTipsView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSizeSelectSizeTipsView.class)];
        [_collectionView registerClass:[ZFSelectSizeSizeHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectSizeSizeHeader.class)];
        // V4.8.0增加库存提醒一栏
        [_collectionView registerClass:[ZFSelectSizeStockTipsHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectSizeStockTipsHeader.class)];
        
        [_collectionView registerClass:[ZFSelectLiveCommentHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(ZFSelectLiveCommentHeader.class)];

        
        if ([SystemConfigUtils isRightToLeftShow]) {
            self.collectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        }
    }
    return _collectionView;
}

///盖住弹性动画时底部露底的白色view
- (UIView *)emptyWhiteView {
    if (!_emptyWhiteView) {
        _emptyWhiteView = [[UIView alloc] initWithFrame:CGRectZero];
        _emptyWhiteView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _emptyWhiteView;
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
        _lineView.backgroundColor = ColorHex_Alpha(0xCCCCCC, 0.5);
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
        NSString *normalTitle = ZFLocalizedString(@"Detail_Product_AddToBag", nil);
        NSString *disabledTitle = ZFLocalizedString(@"Detail_Product_OutOfStock", nil);
        _addCartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addCartButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_addCartButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        [_addCartButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        [_addCartButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateDisabled];
        [_addCartButton setTitle:normalTitle forState:UIControlStateNormal];
        [_addCartButton setTitle:disabledTitle forState:UIControlStateDisabled];
        [_addCartButton addTarget:self action:@selector(addCartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _addCartButton.titleLabel.font = ZFFontBoldSize(16);
        _addCartButton.hidden = YES;
    }
    return _addCartButton;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshButton setTitle:ZFLocalizedString(@"Live_Network_Refresh", nil) forState:UIControlStateNormal];
        _refreshButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        _refreshButton.layer.cornerRadius =2;
        _refreshButton.layer.masksToBounds = YES;
        [_refreshButton addTarget:self action:@selector(actionRefresh:) forControlEvents:UIControlEventTouchUpInside];
        [_refreshButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_refreshButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        _refreshButton.hidden = YES;
    }
    return _refreshButton;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
        activityView.color = ZFC0x000000_A(0.3);
        [activityView hidesWhenStopped];
        [activityView startAnimating];
        _activityView = activityView;
    }
    return _activityView;
}
@end
