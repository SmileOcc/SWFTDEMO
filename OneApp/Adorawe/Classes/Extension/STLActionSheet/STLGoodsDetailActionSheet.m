//
//  STLGoodsDetailActionSheet.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/7/13.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLGoodsDetailActionSheet.h"
#import "AttributeView.h"
#import "STLActionCollectionFooterView.h"
#import "AttributeCell.h"
#import "QuantityCell.h"
#import "STLPicListCell.h"
#import "STLCLineLabel.h"
#import "STLAttributeSelectImageListView.h"
#import "STLAttributeSheetGoodsInfoReusableView.h"

#import "CartModel.h"
#import "OSSVDetailsViewModel.h"
#import "OSSVDetailsBaseInfoModel.h"

#import "STLActivityWWebCtrl.h"
#import "OSSVCheckOutVC.h"
#import "OSSColorSizeCell.h"
#import "Adorawe-Swift.h"
#import "OSSVSearchingModel.h"



@interface STLGoodsDetailActionSheet()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@property (nonatomic, strong) OSSVDetailsViewModel     *viewModel;
@property (nonatomic, strong) UIView                    *shadeView;
@property (nonatomic, strong) UIView                    *sheetView;

@property (nonatomic, strong) UIView                    *topContentView;
@property (nonatomic, strong) UILabel                   *titLabel;
@property (nonatomic, strong) UIButton                  *dismissButton;

@property (nonatomic, strong) UIView                    *lineFirst;

@property (nonatomic, strong) UILabel                   *sizeTitleLabel;
@property (nonatomic, strong) UILabel                   *detablLabel;
@property (nonatomic, strong) UIButton                  *eventBtn;
@property (nonatomic, strong) UICollectionView          *sizePickCollectionView;

@property (nonatomic, strong) YYAnimatedImageView       *cartAnimationView;
@property (nonatomic, strong) UIView                    *sizeTipView;
@property (nonatomic, strong) UILabel                   *sizeTipLab;

@property (nonatomic, strong) QuantityCell              *quanityCell;

@property (nonatomic, strong) UIView                    *flashBgView;
@property (nonatomic, strong) UIView                    *flashTipView;
@property (nonatomic, strong) UILabel                   *flashTipLabel;

@property (nonatomic, strong) UIView                    *lineSecond;

@property (nonatomic, strong) UIView                    *bottomView;
@property (nonatomic, strong) UIButton                  *addToCartButton;

@property (nonatomic, assign) CGRect                    goodsImageRelateWindow;
@property (nonatomic, assign) CGFloat                   topSpace;
@property (nonatomic, assign) CGRect                    moveLocationRect;
@property (nonatomic, assign) BOOL                      isAddAnimation;

@property (nonatomic, assign) BOOL                      isSelectedSize;

@property (nonatomic, strong) NSMutableArray<OSSVSpecsModel*>  *dataArray;

///临时处理
@property (nonatomic, copy) NSString                    *selectColor;
@property (nonatomic, copy) NSString                    *selectSize;

@property (nonatomic, strong) NSArray           *colorGroup_id;
@property (nonatomic, strong) NSArray           *sizeGroup_id;

@property (nonatomic, assign) CGFloat           sheetViewHeight;

@property (nonatomic,assign) BOOL showArrivalNotify;

@end

#define contentH     ((APP_TYPE == 3) ? 184 : 154)

@implementation STLGoodsDetailActionSheet

-(ColorSizePickView *)colorSizePickView{
    if (!_colorSizePickView) {
        _colorSizePickView = [[ColorSizePickView alloc] init];
        _colorSizePickView.backgroundColor = OSSVThemesColors.col_FFFFFF;
        _colorSizePickView.onlyNeedSize = YES;
        [_colorSizePickView setFirstIntoSelectSize:YES];
        _colorSizePickView.delegate = self;
        @weakify(self)
        _colorSizePickView.didSelectedGoodsId = ^(OSSVAttributeItemModel * _Nonnull goodsId) {
            @strongify(self)
            self.isSelectedSize = true;
        };
    }
    return _colorSizePickView;
}

- (void)dealloc {
    if (self.cartAnimationView.superview) {
        [self.cartAnimationView removeFromSuperview];
    }
}

#pragma mark - 初始化界面
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initDetailView];
    }
    return self;
}

- (void)initDetailView {
    UIView *ws = self;
    ws.hidden = YES;
    
    self.goodsNum = 1;
    
    [ws addSubview:self.shadeView];
    [ws addSubview:self.sheetView];
    
    [self.sheetView addSubview:self.topContentView];
    [self.topContentView addSubview:self.titLabel];
    [self.topContentView addSubview:self.dismissButton];
    
    [self.sheetView addSubview:self.lineFirst];
    
    
    [self.sheetView addSubview:self.eventBtn];
    if (APP_TYPE == 3) {
        [self.sheetView addSubview:self.colorSizePickView];
    }else{
        [self.sheetView addSubview:self.sizePickCollectionView];
        [self.sheetView addSubview:self.sizeTitleLabel];
        [self.sheetView addSubview:self.detablLabel];
    }
    
    [self.sheetView addSubview:self.sizeTipView];
    [self.sizeTipView addSubview:self.sizeTipLab];
    [self.sheetView addSubview:self.quanityCell];
    
    [self.sheetView addSubview:self.flashBgView];
    [self.flashBgView addSubview:self.flashTipView];
    [self.flashBgView addSubview:self.flashTipLabel];
    
    [self.sheetView addSubview:self.lineSecond];
    [self.sheetView addSubview:self.bottomView];
    
    [self.bottomView addSubview:self.addToCartButton];
    
    CGFloat bottomH =  kIS_IPHONEX ? 60+STL_TABBAR_IPHONEX_H : 60;
    self.sheetViewHeight = contentH + bottomH + 36 + 12;
    [self.sheetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.shadeView);
        make.top.mas_equalTo(self.shadeView.mas_bottom);
        make.height.mas_equalTo(self.sheetViewHeight);
    }];
    
    [self.sheetView.superview layoutIfNeeded];
    
    [self.topContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.sheetView);
        make.height.mas_equalTo(48);
    }];
    
    [self.titLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.topContentView.center);
    }];
    
    [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topContentView.mas_centerY);
        make.trailing.mas_equalTo(self.sheetView.mas_trailing).mas_offset(-12);
        make.width.height.mas_equalTo(18);
    }];
    
    [self.lineFirst mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.sheetView);
        make.top.mas_equalTo(self.topContentView.mas_bottom);
        make.height.mas_equalTo(@0.5);
    }];
    
    
    if (APP_TYPE == 3) {
        //VIVCOLOR
        [self.colorSizePickView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sheetView.mas_leading).offset(14);
            make.trailing.mas_equalTo(self.sheetView.mas_trailing).offset(-14);
            make.top.mas_equalTo(self.lineFirst.mas_bottom).mas_offset(11);
            make.height.mas_equalTo(110);
        }];
       
        [self.sizeTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.sheetView.mas_trailing).offset(-14);
            make.leading.mas_equalTo(self.sheetView.mas_leading).offset(14);
            make.top.mas_equalTo(self.colorSizePickView.mas_bottom).offset(12);
            make.height.mas_equalTo(0);
        }];
    }else{
        [self.sizeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sheetView.mas_leading).offset(12);
            make.top.mas_equalTo(self.lineFirst.mas_bottom).offset(22);
        }];
        
        [self.detablLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.sizeTitleLabel.mas_centerY);
            make.leading.mas_equalTo(self.sizeTitleLabel.mas_trailing);
        }];
        
        
        [self.eventBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.sheetView.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.sizeTitleLabel.mas_centerY);
        }];
        [self.sizePickCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sheetView.mas_leading);
            make.trailing.mas_equalTo(self.sheetView.mas_trailing);
            make.top.mas_equalTo(self.sizeTitleLabel.mas_bottom).mas_offset(11);
            make.height.mas_equalTo(@36);
        }];
        [self.sizeTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.sheetView.mas_trailing);
            make.leading.mas_equalTo(self.sheetView.mas_leading);
            make.top.mas_equalTo(self.sizePickCollectionView.mas_bottom).offset(12);
            make.height.mas_equalTo(0);
        }];
    }
    
    [self.sizeTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sizeTipView.mas_top).offset(4);
        make.bottom.mas_equalTo(self.sizeTipView.mas_bottom).offset(-4);
        make.leading.mas_equalTo(self.sizeTipView.mas_leading).offset(8);
        make.trailing.mas_equalTo(self.sizeTipView.mas_trailing).offset(-8);
    }];
    
    [self.quanityCell mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sizeTipView.mas_bottom).offset(6);
        make.leading.trailing.mas_equalTo(self.sheetView);
        make.height.mas_equalTo(@36);
    }];
    
    
    
   
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.sheetView.mas_bottom);
        make.leading.mas_equalTo(self.sheetView.mas_leading);
        make.trailing.mas_equalTo(self.sheetView.mas_trailing);
        make.height.mas_equalTo(kIS_IPHONEX ? 60+STL_TABBAR_IPHONEX_H : 60);
    }];
    
    [self.addToCartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView.mas_top).mas_offset(12);
        make.trailing.mas_equalTo(self.bottomView.mas_trailing).mas_offset(-12);
        make.leading.mas_equalTo(self.bottomView.mas_leading).offset(12);
        make.bottom.mas_equalTo(self.bottomView.mas_bottomMargin);
    }];
    
    [self.lineSecond mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bottomView.mas_top);
        make.leading.mas_equalTo(self.bottomView.mas_leading);
        make.trailing.mas_equalTo(self.bottomView.mas_trailing);
        make.height.mas_equalTo(@0.5);
    }];
    
    [self.flashBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.sheetView);
        make.height.mas_equalTo(@0);
        make.bottom.mas_equalTo(self.lineSecond.mas_top);
    }];
        
    [self.flashTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.flashBgView.mas_leading);
        make.trailing.mas_equalTo(self.flashBgView.mas_trailing);
        make.top.mas_equalTo(self.flashBgView.mas_top);
        make.bottom.mas_equalTo(self.flashBgView.mas_bottom);
    }];
    
    [self.flashTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.flashTipView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.flashTipView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.flashTipView.mas_centerY);
    }];
    
    if (APP_TYPE != 3) {
        [self.sheetView stlAddCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];
    }
   
}

- (OSSVDetailsViewModel*)viewModel {
    if (!_viewModel) {
        _viewModel = [OSSVDetailsViewModel new];
        _viewModel.controller = self.viewController;
    }
    return _viewModel;
}

- (NSMutableArray<OSSVSpecsModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

#pragma mark - 接收返回数据
- (void)setBaseInfoModel:(OSSVDetailsBaseInfoModel *)baseInfoModel {
    _baseInfoModel = baseInfoModel;
    self.specialId = STLToString(baseInfoModel.specialId);
    self.goodsId = baseInfoModel.goodsId;
    self.wid = baseInfoModel.goodsWid;
    if (APP_TYPE == 3) {
        self.colorSizePickView.goodsInfo = baseInfoModel;
    }
    
    BOOL isselectSize = NO;
    for (OSSVSpecsModel *specModel in _baseInfoModel.GoodsSpecs) {
        if ([specModel.spec_type integerValue] == 1) {
            isselectSize = specModel.isSelectSize;
            for (OSSVAttributeItemModel *itemModel in specModel.brothers) {
                if ([itemModel.goods_id isEqualToString:_baseInfoModel.goodsId]) {
                    self.colorGroup_id = itemModel.group_goods_id;
                    break;
                }
            }
        }
    }
     if(!isselectSize){
        self.addToCartButton.enabled = YES;
     }else{
         if ([_baseInfoModel.goodsNumber integerValue] > 0) {
             self.addToCartButton.enabled = YES;
             [_addToCartButton setTitle:STLLocalizedString_(@"addToBag",nil) forState:UIControlStateNormal];
             _showArrivalNotify = NO;
         }else{
//             self.addToCartButton.enabled = NO;
             ///断码订阅
             [_addToCartButton setTitle:STLLocalizedString_(@"Arrival_Notify", nil) forState:UIControlStateNormal];
             _showArrivalNotify = YES;
         }
         
         if (!_baseInfoModel.isOnSale) {
             [_addToCartButton setTitle:STLLocalizedString_(@"Arrival_Notify", nil) forState:UIControlStateNormal];
             _showArrivalNotify = YES;
         }
     }
    
    self.flashBgView.hidden = YES;
    
    if (STLIsEmptyString(baseInfoModel.specialId)
               && baseInfoModel.flash_sale
               && ![baseInfoModel.flash_sale.sold_out isEqualToString:@"1"]
               && [baseInfoModel.flash_sale.active_status isEqualToString:@"1"]) { // 0 > 闪购 > 满减
        //闪购商品并且活动进行中并且没有售完
        self.addToCartButton.backgroundColor = [OSSVThemesColors col_FDC845];
        [self.addToCartButton setTitleColor:OSSVThemesColors.col_0D0D0D forState:UIControlStateNormal];
        
        CGFloat bottomH =  kIS_IPHONEX ? 60+STL_TABBAR_IPHONEX_H : 60;
        CGFloat height = contentH + bottomH + 36 + 12;
        height += 36;
        self.sheetViewHeight = height;
        if (APP_TYPE != 3) {
            [self.sheetView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.sheetViewHeight);
            }];
        }
        [self.flashBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@36);
        }];
        
        [self.sheetView.layer.mask removeFromSuperlayer];
        self.sheetView.layer.mask = nil;
        [self.sheetView layoutIfNeeded];
        if (APP_TYPE != 3) {
            [self.sheetView stlAddCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];
        }
       
        
        self.flashBgView.hidden = NO;
        if (!baseInfoModel.isOnSale) {
            self.flashTipLabel.text = STLLocalizedString_(@"NotOnSale", nil);
            self.flashTipLabel.textColor = OSSVThemesColors.col_6C6C6C;
            self.flashTipView.backgroundColor = OSSVThemesColors.col_FFF5DF;
        }else if ([baseInfoModel.goodsNumber integerValue] == 0){
            self.flashTipLabel.text = STLLocalizedString_(@"SaleOut", nil);
            self.flashTipLabel.textColor = OSSVThemesColors.col_6C6C6C;
            self.flashTipView.backgroundColor = OSSVThemesColors.col_FFF5DF;
        }else{
            self.flashTipLabel.text = STLLocalizedString_(@"Item_did_join_FlashSale", nil);
            self.flashTipLabel.textColor = OSSVThemesColors.col_B62B21;
            self.flashTipView.backgroundColor = OSSVThemesColors.col_FDF1F0;
        }
    }else{
        
        [self.addToCartButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        self.addToCartButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
        
        self.flashTipLabel.textColor = OSSVThemesColors.col_6C6C6C;
        if (!baseInfoModel.isOnSale) {
            CGFloat bottomH =  kIS_IPHONEX ? 60+STL_TABBAR_IPHONEX_H : 60;
            CGFloat height = contentH + bottomH + 36 + 12;
            height += 36;
            self.sheetViewHeight = height;

            if (APP_TYPE != 3) {
                [self.sheetView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.sheetViewHeight);
                }];
            }
            [self.flashBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(@36);
            }];
            self.flashBgView.hidden = NO;
            
            self.flashTipLabel.text = STLLocalizedString_(@"NotOnSale", nil);
            self.flashTipView.backgroundColor = OSSVThemesColors.col_FFF5DF;
        }else if ([baseInfoModel.goodsNumber integerValue] == 0){
            CGFloat bottomH =  kIS_IPHONEX ? 60+STL_TABBAR_IPHONEX_H : 60;
            CGFloat height = contentH + bottomH + 36 + 12;
            height += 36;
            self.sheetViewHeight = height;

            if (APP_TYPE != 3) {
                [self.sheetView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.sheetViewHeight);
                }];
            }
            [self.flashBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(@36);
            }];
            self.flashBgView.hidden = NO;
            self.flashTipLabel.text = STLLocalizedString_(@"SaleOut", nil);
            self.flashTipView.backgroundColor = OSSVThemesColors.col_FFF5DF;
        }else{
            if(baseInfoModel.flash_sale && [baseInfoModel.flash_sale.active_status isEqualToString:@"0"]){
                CGFloat bottomH =  kIS_IPHONEX ? 60+STL_TABBAR_IPHONEX_H : 60;
                CGFloat height = contentH + bottomH + 36 + 12;
                height += 36;
                self.sheetViewHeight = height;

                if (APP_TYPE != 3) {
                    [self.sheetView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(self.sheetViewHeight);
                    }];
                }
                [self.flashBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(@36);
                }];
                self.flashBgView.hidden = NO;
                
                self.flashTipLabel.text = STLLocalizedString_(@"Item_pre_join_FlashSale", nil);
                self.flashTipView.backgroundColor = OSSVThemesColors.col_F8F8F8;
            }else{
                CGFloat bottomH =  kIS_IPHONEX ? 60+STL_TABBAR_IPHONEX_H : 60;
                CGFloat height = contentH + bottomH + 36 + 12;
                self.sheetViewHeight = height;
                if (APP_TYPE != 3) {
                    [self.sheetView mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.mas_equalTo(self.sheetViewHeight);
                    }];
                }
               
                [self.flashBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(@0);
                }];
                self.flashBgView.hidden = YES;
                
            }
        }
    }
    
    // 如果没有选择尺码 就正常显示
    if (!isselectSize) {
        CGFloat bottomH =  kIS_IPHONEX ? 60+STL_TABBAR_IPHONEX_H : 60;
        CGFloat height = contentH + bottomH + 36 + 12;
        self.sheetViewHeight = height;
        [self.sheetView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.sheetViewHeight);
        }];
        [self.flashBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@0);
        }];
        self.flashBgView.hidden = YES;
        [self.addToCartButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        self.addToCartButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
    }
    
    [self.sheetView.layer.mask removeFromSuperlayer];
    self.sheetView.layer.mask = nil;
    [self.sheetView layoutIfNeeded];
    if (APP_TYPE != 3) {
        [self.sheetView stlAddCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];
    }
    
    
    [self.sizePickCollectionView reloadData];
    
    self.quanityCell.type = self.type;
    //新人礼包不能编辑
    self.quanityCell.userInteractionEnabled = self.isNewUser ? NO : YES;
    @weakify(self)
    self.quanityCell.goodsNumBlock = ^(NSString *goodsNum) {
        @strongify(self)
        if ([OSSVNSStringTool isEmptyString:goodsNum]) {
            [self shakeAnimationForView:self.sizePickCollectionView];
            return;
        }
        self.goodsNum = [goodsNum integerValue];
    };
    self.quanityCell.operateBlock = ^(QuantityCellEvent event) {
        @strongify(self)

    };
    //商品加购
    if (self.goodsNum == 0 && self.baseInfoModel.goodsNumber > 0) {
        self.goodsNum = 1;
    }
    [self.quanityCell handleGoodsNumber:self.baseInfoModel currnetCount:self.goodsNum];
    
    if (_showArrivalNotify && APP_TYPE == 3) {
        _addToCartButton.backgroundColor = OSSVThemesColors.col_9F5123;
    }
}

#pragma mark -- collectionview
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    self.selectSize = @"";
    self.selectColor = @"";
    return _baseInfoModel.GoodsSpecs.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    OSSVSpecsModel *specModel = _baseInfoModel.GoodsSpecs[section];
    if ([specModel.spec_type integerValue] == 2 && ![OSSVNSStringTool isEmptyString:STLToString(specModel.size_chart_url)] && ![OSSVNSStringTool isEmptyString:STLToString(specModel.size_chart_title)]) {
        self.eventBtn.hidden = NO;
        [self.eventBtn setTitle:specModel.size_chart_title forState:UIControlStateNormal];
    }
    if ([specModel.spec_type integerValue] == 2) {
        return specModel.brothers.count;
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OSSColorSizeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([OSSColorSizeCell class]) forIndexPath:indexPath];
    cell.goos_numeber = [_baseInfoModel.goodsNumber integerValue];
    cell.goos_id = _baseInfoModel.goodsId;
    OSSVSpecsModel *specModel = _baseInfoModel.GoodsSpecs[indexPath.section];
    OSSVAttributeItemModel *itemModel = specModel.brothers[indexPath.item];
    cell.goodsSpecModel = _baseInfoModel.GoodsSpecs[indexPath.section];

    if([specModel.spec_type integerValue] == 2){
        // 尺码
        if ([itemModel.goods_id isEqualToString:_baseInfoModel.goodsId]) {
            self.sizeGroup_id = itemModel.group_goods_id;
        }
        
        NSArray *arr = [self interArrayWithArray:self.colorGroup_id other:itemModel.group_goods_id];
        if (arr && arr.count > 0) {
            cell.isJiaoJi = YES;
        }else{
            cell.isJiaoJi = NO;
        }
    }
    
    cell.itemModel = itemModel;
    
    if (specModel.isSelectSize && [itemModel.goods_id isEqualToString:_baseInfoModel.goodsId] && [specModel.spec_type integerValue] == 2) {
        self.detablLabel.text = STLToString(itemModel.value);
        self.detablLabel.textColor = OSSVThemesColors.col_0D0D0D;
        self.isSelectedSize = YES;
        self.selectSize = STLToString(itemModel.value);
        [self updateSizeTipViewWithArray:_baseInfoModel.size_info itemModel:itemModel];
    }
    
    if (![OSSVNSStringTool isEmptyString:STLToString(specModel.size_chart_url)] && ![OSSVNSStringTool isEmptyString:STLToString(specModel.size_chart_title)] && _baseInfoModel.isHasSizeItem) {
        [_eventBtn setAttributedTitle:[NSString underLineSizeChatWithTitleStr:specModel.size_chart_title] forState:UIControlStateNormal];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

//    for (OSSVSpecsModel *specMod in _baseInfoModel.GoodsSpecs) {
//        if ([specMod.spec_type integerValue] == 1) {
//            for (OSSVAttributeItemModel *itemMod in specMod.brothers) {
//                // 颜色
//                if ([itemMod.goods_id isEqualToString:_baseInfoModel.goodsId]) {
//                    self.colorGroup_id = itemMod.group_goods_id;
//                    break;
//                }
//            }
//            break;
//        }
//    }
    OSSColorSizeCell *cell = (OSSColorSizeCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isSelected) {
        return;
    }
    
    OSSVSpecsModel *specModel = nil;
    for (OSSVSpecsModel *specMod in _baseInfoModel.GoodsSpecs) {
        if ([specMod.spec_type integerValue] == 2) {
            specModel = specMod;
            break;
        }
    }
    OSSVAttributeItemModel *itemModel = specModel.brothers[indexPath.item];
    
    if ([specModel.spec_type integerValue]== 2){
        // 尺码
        NSArray *group_id_Slected = itemModel.group_goods_id;
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    OSSVSpecsModel *specModel = _baseInfoModel.GoodsSpecs[indexPath.section];
    if ([specModel.spec_type integerValue] == 2) {
        OSSVAttributeItemModel *itemModel = specModel.brothers[indexPath.item];
        CGFloat w = [self getLabStringWidthWithText:itemModel.value];
        return CGSizeMake(w, 36);
    }
    return CGSizeZero;
}


// 计算文字宽度
- (CGFloat)getLabStringWidthWithText:(NSString *)text{
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    CGFloat width = [text boundingRectWithSize:CGSizeMake(1000, MAXFLOAT)  options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.width;
    
    width = MAX(width + 14, 36);
    return width;
}


#pragma mark - 关闭收回窗口

- (void)addCartAnimationTop:(CGFloat)top moveLocation:(CGRect)location showAnimation:(BOOL)isAddAnimation{
    self.isAddAnimation = isAddAnimation;
    self.topSpace = top;
    self.moveLocationRect = location;
}
- (CGRect)goodsImageFrameRelativeWindow {
    return [self.sizePickCollectionView convertRect:self.sizePickCollectionView.bounds toView:WINDOW];
}
- (void)dismiss {

    [UIView animateWithDuration:0.5 animations:^{
        [self.sheetView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.shadeView);
            make.top.mas_equalTo(self.shadeView.mas_bottom);
            make.height.mas_equalTo(self.sheetViewHeight);
        }];
    } completion:^(BOOL finished) {
        @weakify(self)
        if (self.cancelViewBlock) {
            @strongify(self)
            self.cancelViewBlock();
        }

        self.hidden = YES;
    }];
}

#pragma mark  打开显示窗口
-(void)shouAttribute {
    self.hidden = NO;
    
    //121
    if (![OSSVNSStringTool isEmptyString:self.selectSize]) {
        [UIView animateWithDuration:0.3 animations:^{
            [self setNeedsUpdateConstraints];
            [self.sheetView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.shadeView.mas_bottom).offset(-self.sheetViewHeight);
                make.height.mas_equalTo(self.sheetViewHeight);
            }];

            [self.sheetView.superview layoutIfNeeded];
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            [self setNeedsUpdateConstraints];
            [self.sheetView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.shadeView.mas_bottom).offset(-self.sheetViewHeight);
                make.height.mas_equalTo(self.sheetViewHeight);
            }];
            [self.sheetView.superview layoutIfNeeded];
        }];
    }
    self.cartAnimationView.hidden = YES;
    self.goodsImageRelateWindow = [self goodsImageFrameRelativeWindow];

    NSString *item_type = @"normal";
    if (!STLIsEmptyString(self.baseInfoModel.specialId)) {
        item_type = @"free";
    }
    
    NSString *price = STLToString(self.baseInfoModel.shop_price);

    NSDictionary *sensorsDic = @{@"referrer"            :   [UIViewController currentTopViewControllerPageName],
                                 @"goods_sn"            :   STLToString(self.baseInfoModel.goods_sn),
                                 @"goods_name"          :   STLToString(self.baseInfoModel.goodsTitle),
                                 @"cat_id"              :   STLToString(self.baseInfoModel.cat_id),
                                 @"cat_name"            :   STLToString(self.baseInfoModel.cat_name),
                                 @"item_type"           :   item_type,
                                 @"original_price"      :   @([STLToString(self.baseInfoModel.goodsMarketPrice) floatValue]),
                                 @"present_price"       :   @([price floatValue]),
                                 @"currency"            :   @"USD",
                                 @"shoppingcart_entrance"   :   [self shoppingcartString:self.addCartType],
                                 kAnalyticsKeyWord          :   STLToString(self.analyticsDic[kAnalyticsKeyWord]),
                                 kAnalyticsPositionNumber   :   self.analyticsDic[kAnalyticsPositionNumber] ?: @(0),
                                 kAnalyticsThirdPartId      :   STLToString(self.analyticsDic[kAnalyticsThirdPartId]),
                                 
            };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BeginAddToCart" parameters:sensorsDic];
    [OSSVAnalyticsTool analyticsSensorsEventFlush];
}

#pragma mark - 点击Continue按钮



- (NSString *)shoppingcartString:(NSInteger)type {
    if (type == 1) {
        return @"addcart_quick";
    } else if (type == 2){
        return @"often_bought_with";
    }
    return @"addcart_goods";
}

#pragma mark - 点击Continue按钮
- (void)addToBagAction:(UIButton*)sender{
    NSArray *upperTitle = @[STLLocalizedString_(@"no",nil).uppercaseString,STLLocalizedString_(@"yes", nil).uppercaseString];
    NSArray *lowserTitle = @[STLLocalizedString_(@"no",nil),STLLocalizedString_(@"yes", nil)];

    if (self.cart_exits) {
        NSString *msg = STLLocalizedString_(@"switchFreeItem", nil);
        [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:@"" message:msg buttonTitles:APP_TYPE == 3 ? lowserTitle : upperTitle buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
            if (index==1) {
                [self touchContinueAction:sender];
            }
        }];
        return;
    }else{
        [self touchContinueAction:sender];
    }
}


- (void)touchContinueAction:(UIButton*)sender {

    switch (sender.tag) {
        case GoodsDetailEnumTypeAdd:
        {

            CartModel *cartModel = [CartModel new];
            cartModel.goodsId = self.baseInfoModel.goodsId;
            cartModel.goods_sn = self.baseInfoModel.goods_sn;
            cartModel.cat_name = self.baseInfoModel.cat_name;
            cartModel.marketPrice = self.baseInfoModel.goodsMarketPrice;
            cartModel.goodsName = self.baseInfoModel.goodsTitle;
            cartModel.goodsThumb = self.baseInfoModel.goodsSmallImg;
            cartModel.goodsNumber = self.goodsNum;
            cartModel.goodsPrice = self.baseInfoModel.shop_price;
            cartModel.isFavorite = self.baseInfoModel.isCollect;
            cartModel.wid = self.baseInfoModel.goodsWid;
            cartModel.stateType = CartGoodsOperateTypeAdd;
            cartModel.goodsStock = self.baseInfoModel.goodsNumber;
            cartModel.isOnSale = self.baseInfoModel.isOnSale;
            cartModel.isChecked = YES;
            cartModel.specialId = STLToString(self.specialId);
            cartModel.mediasource = self.sourceType;
            cartModel.reviewsId = self.reviewsId;
            cartModel.cart_exits = self.cart_exits;
            cartModel.spu = self.baseInfoModel.spu;
            
            // 0 > 闪购 > 满减
            if (STLIsEmptyString(self.baseInfoModel.specialId) && self.baseInfoModel.flash_sale) {
                cartModel.activeId  = self.baseInfoModel.flash_sale.active_id;
                cartModel.flash_sale = self.baseInfoModel.flash_sale;
            }

            @weakify(self)
            [[OSSVCartsOperateManager sharedManager] saveCart:cartModel completion:^(id obj) {
                
                if (obj && [obj isKindOfClass:[STLCartModel class]]) {
                    obj = (STLCartModel *)obj;
                    @strongify(self)
                    [obj handleCartGoodsCount];
                    //[[OSSVCartsOperateManager sharedManager] cartSaveValidGoodsCount:allGoods.count];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Cart object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_CartBadge object:nil];
                    
                    //谷歌统计
                    [OSSVAnalyticsTool appsFlyerAddToCartWithProduct:cartModel fromProduct:YES];
                    
                    [self analyticsAddCartModel:cartModel state:YES];

                    [self handleAddCart];
                    
                    if (self.addCartEventBlock) {
                        self.addCartEventBlock(YES);
                    }
                } else {
//                    NSString *msg = STLLocalizedString_(@"noInventory", nil);
                    NSString *msg = @"";

                    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                        if ([obj[kStatusCode] integerValue] == 20002) {//无库存
                            msg = obj[@"message"];
                            if (self.zeroStockBlock) {
                                self.zeroStockBlock(self.goodsId, self.wid);
                            }
                        }
                    }
                    if (msg.length) {
                        [HUDManager showHUDWithMessage:msg];

                    }

                    if (self.addCartEventBlock) {
                        self.addCartEventBlock(NO);
                    }
                    [self analyticsAddCartModel:cartModel state:NO];

                }
            } failure:^(id obj) {
                if (self.addCartEventBlock) {
                    self.addCartEventBlock(NO);
                }
                [self analyticsAddCartModel:cartModel state:NO];
            }];
        }
            break;
        case GoodsDetailEnumTypeBuy:
        {
            [self buyItNow];
        }
            break;
        default:
            break;
    }
}

- (void)analyticsAddCartModel:(CartModel *)cartModel state:(BOOL)state {
    
    NSString *skuType = @"normal";
    if (!STLIsEmptyString(self.specialId) && ![STLToString(self.specialId) isEqualToString:@"0"]) {//0元
        skuType = @"free";
    }
    
    
    CGFloat price = [cartModel.goodsPrice floatValue];

    if (state) {
        
        //和鲍勇再次确认完全可以拿着is_can_buy 字段来判断用户能否按照闪购价继续购买，以及闪购背景置灰和 价格不为红色
        //GA
        // 0 > 闪购 > 满减
        if (!STLIsEmptyString(cartModel.specialId)) {//0元
            price = [cartModel.goodsPrice floatValue];
            
        } else if (STLIsEmptyString(cartModel.specialId) && cartModel.flash_sale &&  [cartModel.flash_sale.is_can_buy isEqualToString:@"1"] && [cartModel.flash_sale.active_status isEqualToString:@"1"]) {//闪购
            price = [cartModel.flash_sale.active_price floatValue];
        }
        CGFloat allPrice = cartModel.goodsNumber * price;

        //数据GA埋点曝光 加购事件
        NSDictionary *items = @{
            kFIRParameterItemID: STLToString(cartModel.goods_sn),
            kFIRParameterItemName: STLToString(cartModel.goodsName),
            kFIRParameterItemCategory: STLToString(cartModel.cat_name),
            kFIRParameterPrice: @(price),
            kFIRParameterQuantity: @(cartModel.goodsNumber),
            //产品规格
            kFIRParameterItemVariant: @"",
            kFIRParameterItemBrand: @"",
            kFIRParameterCurrency: @"USD",

        };
        
        NSDictionary *itemsDic = @{kFIRParameterItems:@[items],
                                   kFIRParameterCurrency: @"USD",
                                   kFIRParameterValue: @(allPrice),
                                   @"screen_group":[NSString stringWithFormat:@"ProductDetail_+%@",STLToString(cartModel.goods_sn)],
                                   @"position":@"Product Detail_Button",
        };
        
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventAddToCart parameters:itemsDic];
        
    }
    
    NSDictionary *sensorsDic = @{@"referrer"            :   [UIViewController currentTopViewControllerPageName],
                                 @"goods_sn"            :   STLToString(cartModel.goods_sn),
                                 @"goods_name"          :   STLToString(cartModel.goodsName),
                                 @"cat_id"              :   STLToString(self.baseInfoModel.cat_id),
                                 @"cat_name"            :   STLToString(self.baseInfoModel.cat_name),
                                 @"item_type"           :   skuType,
                                 @"original_price"      :   @([STLToString(self.baseInfoModel.goodsMarketPrice) floatValue]),
                                 @"present_price"       :   @(price),
                                 @"goods_quantity"      :   @(cartModel.goodsNumber),
                                 @"currency"            :   @"USD",
                                 @"goods_size"          :   STLToString(self.selectSize),
                                 @"goods_color"         :   STLToString(self.selectColor),
                                 @"is_success"          :   @(state),
                                 @"goods_attr"          :   STLToString(cartModel.goodsAttr),
                                 @"shoppingcart_entrance"   :   [self shoppingcartString:self.addCartType],
                                 kAnalyticsPositionNumber   :   @([self.analyticsDic[kAnalyticsPositionNumber] integerValue]),
                                 kAnalyticsThirdPartId      :   STLToString(self.analyticsDic[kAnalyticsThirdPartId]),
                                 kAnalyticsKeyWord          :   STLToString(self.analyticsDic[kAnalyticsKeyWord]),
                                 kAnalyticsRecommendPartId  :    STLToString(self.analyticsDic[kAnalyticsRequestId]),
            };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"AddToCart" parameters:sensorsDic];
    [OSSVAnalyticsTool analyticsSensorsEventFlush];
    ///branch 埋点
    [OSSVBrancshToolss logAddToCart:sensorsDic];
    
    if (self.searchKey && self.searchPositionNum > 0) {
        [ABTestTools.shared addToCartWithKeyWord:STLToString(self.searchKey)
                                     positionNum:self.searchPositionNum
                                         goodsSn:STLToString(cartModel.goods_sn)
                                       goodsName:STLToString(cartModel.goodsName)
                                           catId:STLToString(cartModel.cat_id)
                                         catName:STLToString(cartModel.cat_name)
                                     originPrice:[STLToString(self.baseInfoModel.goodsMarketPrice) floatValue]
                                    presentPrice:price];
        
        [BytemCallBackApi sendCallBackWithApiKey:STLToString(self.searchModel.btm_apikey) index:STLToString(self.searchModel.btm_index) sid:STLToString(self.searchModel.btm_sid) pid:STLToString(cartModel.spu) skuid:STLToString(cartModel.goods_sn) action:1 searchEngine:STLToString(self.searchModel.search_engine)];
    }
    [DotApi addToCart];
}



// 添加购物车完成后执行
- (void)handleAddCart {
    
    if (self.isAddAnimation) {
        
        if (self.cartAnimationView.superview) {
            [self.cartAnimationView removeFromSuperview];
        }
        [WINDOW addSubview:self.cartAnimationView];
        
        CGFloat x = [OSSVSystemsConfigsUtils isRightToLeftShow] ? (SCREEN_WIDTH - CGRectGetWidth(self.sizePickCollectionView.frame) - 16): 16;
        self.cartAnimationView.frame = CGRectMake(x,self.goodsImageRelateWindow.origin.y + self.topSpace, CGRectGetWidth(self.sizePickCollectionView.frame), CGRectGetHeight(self.sizePickCollectionView.frame));
        
        NSIndexPath *index = [NSIndexPath indexPathForItem:0 inSection:0];
        OSSColorSizeCell *cell = (OSSColorSizeCell *)[self.sizePickCollectionView cellForItemAtIndexPath:index];
        UIImage *img = nil;
        for (UIView *subV in cell.contentView.subviews) {
            if ([subV isKindOfClass:[UIImageView class]]) {
                UIImageView *imgv = (UIImageView *)subV;
                img = imgv.image;
            }
        }
        self.cartAnimationView.image = img;
        self.cartAnimationView.hidden = NO;
        
        //动画二
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 11.0 ];
        rotationAnimation.duration = 1.0;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = 0;
        

        //这个是让旋转动画慢于缩放动画执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.cartAnimationView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
        });
        
        [UIView animateWithDuration:1.0 animations:^{
//            self.cartAnimationView.frame= self.moveLocationRect;
            self.cartAnimationView.transform = CGAffineTransformRotate(self.cartAnimationView.transform, M_PI_2);
            
        } completion:^(BOOL finished) {
            //动画完成后做的事
            self.cartAnimationView.hidden = YES;
            self.cartAnimationView.transform = CGAffineTransformIdentity;
            [self dismiss];
            
            [HUDManager showHUD:MBProgressHUDModeText onTarget:nil hide:YES afterDelay:1 enabled:NO message:STLLocalizedString_(@"addToCartSuccess", nil) customView:nil contentBgColor:nil textColor:nil margin:10 completionBlock:nil];
        }];
        
        
    } else {
        //当添加购物车成功后调用此Block收回弹出的View
        [self dismiss];
        
        [HUDManager showHUD:MBProgressHUDModeText onTarget:nil hide:YES afterDelay:1 enabled:NO message:STLLocalizedString_(@"addToCartSuccess", nil) customView:nil contentBgColor:nil textColor:nil margin:10 completionBlock:nil];
    }
}

- (void)eventBtnTouch:(UIButton *)sender{
    
    [GATools logGoodsDetailSimpleEventWithEventName:@"size_guide"
                                            screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.baseInfoModel.goodsTitle)]
                                             buttonName:@"Size Chart"];
    
    for (OSSVSpecsModel *specModel in _baseInfoModel.GoodsSpecs) {
        if ([specModel.spec_type integerValue] == 2 && ![OSSVNSStringTool isEmptyString:STLToString(specModel.size_chart_url)] && ![OSSVNSStringTool isEmptyString:STLToString(specModel.size_chart_title)]) {
            STLActivityWWebCtrl *webViewController = [STLActivityWWebCtrl new];
            webViewController.strUrl = STLToString(specModel.size_chart_url);
            webViewController.isIgnoreWebTitle = YES;
            webViewController.isModalPresent = YES;
            webViewController.title = STLToString(specModel.size_chart_title);
            webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
            WINDOW.backgroundColor = [OSSVThemesColors stlBlackColor];
            
            OSSVNavigationVC *nav = [[OSSVNavigationVC alloc] initWithRootViewController:webViewController];
            nav.modalPresentationStyle = UIModalPresentationPageSheet;
            [[UIViewController currentTopViewController]  presentViewController:nav animated:YES completion:nil];
            break;
        }
    }
}

- (void)touchContinue:(UIButton *)sender{
    if (!_isSelectedSize) {
        if (APP_TYPE == 3) {
            [self shakeAnimationForView:self.colorSizePickView.sizeCollectView];
        }else{
            [self shakeAnimationForView:self.sizePickCollectionView];
        }
        
    }else{
        if (_showArrivalNotify) {
            [ArrivalSubScribManager.shared showArrivalAlertWithGoodsInfo:_baseInfoModel];
        }else{
            [self addToBagAction:sender];
        }
       
    }
}

// 更新sizetipview
- (void)updateSizeTipViewWithArray:(NSArray <OSSVSizeChartModel *> *)size_info itemModel:(OSSVAttributeItemModel *)itemModel{
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
            _sizeTipLab.attributedText = mAttr;
            NSString *str = mAttr.string;
            NSRange range = NSMakeRange(0, mAttr.length);
            NSDictionary *dic = [mAttr attributesAtIndex:0 effectiveRange:&range];
            CGSize sizeToFit = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
            CGFloat num = sizeToFit.width/self.sizeTipLab.bounds.size.width + 1;
            CGFloat height = sizeToFit.height*num + 8;
            
            [_sizeTipView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height);
            }];
            CGFloat bottomH =  kIS_IPHONEX ? 60+STL_TABBAR_IPHONEX_H : 60;
            
            CGFloat sheetH = 0.0f;
            if (self.flashBgView.isHidden) {
                sheetH = contentH + bottomH + 36 + 12;
            }else{
                sheetH = contentH + bottomH + 36 + 12 + 36;
            }
            sheetH += height;
            
            self.sheetViewHeight = sheetH;
            [self.sheetView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.shadeView.mas_bottom).offset(-self.sheetViewHeight);
                make.height.mas_equalTo(self.sheetViewHeight);
            }];

            [self.sizeTipView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height);
            }];
            self.sheetView.layer.mask = nil;
            [self.sheetView layoutIfNeeded];
            if (APP_TYPE != 3) {
                [self.sheetView stlAddCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];
            }
            
        }else{
            CGFloat bottomH =  kIS_IPHONEX ? 60+STL_TABBAR_IPHONEX_H : 60;
            
            CGFloat sheetH = 0.0f;
            if (self.flashBgView.isHidden) {
                sheetH = contentH + bottomH + 36 + 12;
            }else{
                sheetH = contentH + bottomH + 36 + 12 + 36;
            }
            self.sheetViewHeight = sheetH;
            [self.sheetView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.shadeView.mas_bottom).offset(-self.sheetViewHeight);
                make.height.mas_equalTo(self.sheetViewHeight);
            }];

            [self.sizeTipView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(@0);
            }];
            self.sheetView.layer.mask = nil;
            [self.sheetView layoutIfNeeded];
            if (APP_TYPE != 3) {
                [self.sheetView stlAddCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];
            }
            
        }
        
    }else{
        CGFloat bottomH =  kIS_IPHONEX ? 60+STL_TABBAR_IPHONEX_H : 60;
        
        CGFloat sheetH = 0.0f;
        if (self.flashBgView.isHidden) {
            sheetH = contentH + bottomH + 36 + 12;
        }else{
            sheetH = contentH + bottomH + 36 + 12 + 36;
        }
        self.sheetViewHeight = sheetH;
        [self.sheetView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.shadeView.mas_bottom).offset(-self.sheetViewHeight);
            make.height.mas_equalTo(self.sheetViewHeight);
        }];

        [self.sizeTipView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@0);
        }];
        self.sheetView.layer.mask = nil;
        [self.sheetView layoutIfNeeded];
        if (APP_TYPE != 3) {
            [self.sheetView stlAddCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];
        }
        
    }
}

#pragma mark - LazyLoad
- (NSMutableDictionary *)analyticsDic {
    if (!_analyticsDic) {
        _analyticsDic = [[NSMutableDictionary alloc] init];
    }
    return _analyticsDic;
}


- (UIView *)shadeView {
    if (!_shadeView) {
        _shadeView = [[UIView alloc] initWithFrame:self.bounds];
        _shadeView.backgroundColor = [OSSVThemesColors stlBlackColor];
        _shadeView.userInteractionEnabled = YES;
        [_shadeView setAlpha:0.3];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_shadeView addGestureRecognizer:tap];
    }
    return _shadeView;
}

- (UIView *)sheetView {
    if (!_sheetView) {
        _sheetView = [[UIView alloc] init];
        //121
        [_sheetView setBackgroundColor:[OSSVThemesColors stlWhiteColor]];
    }
    return _sheetView;
}


- (UIView *)topContentView {
    if (!_topContentView) {
        _topContentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _topContentView;
}

- (UILabel *)titLabel{
    if (!_titLabel) {
        _titLabel = [UILabel new];
        _titLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _titLabel.font = [UIFont boldSystemFontOfSize:16];
        _titLabel.text = STLLocalizedString_(@"selectSize", nil);
    }
    return _titLabel;
}

- (UICollectionView *)sizePickCollectionView {
    if (!_sizePickCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
//        flowLayout.itemSize = CGSizeMake(36, 36);
        flowLayout.minimumInteritemSpacing = 12.0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _sizePickCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _sizePickCollectionView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _sizePickCollectionView.delegate = self;
        _sizePickCollectionView.dataSource = self;
        _sizePickCollectionView.showsVerticalScrollIndicator = NO;
        _sizePickCollectionView.showsHorizontalScrollIndicator = NO;
        [_sizePickCollectionView registerClass:[OSSColorSizeCell class] forCellWithReuseIdentifier:NSStringFromClass([OSSColorSizeCell class])];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _sizePickCollectionView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            _sizePickCollectionView.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        }
        
        _sizePickCollectionView.contentInset = UIEdgeInsetsMake(0, 12, 0, 12);
    }
    return _sizePickCollectionView;
}


- (UIButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [UIButton new];
        [_dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [_dismissButton setImage:[UIImage imageNamed:@"detail_close_black_zhijiao"] forState:UIControlStateNormal];
    }
    return _dismissButton;
}

- (UILabel *)sizeTitleLabel {
    if (!_sizeTitleLabel) {
        _sizeTitleLabel = [UILabel new];
        _sizeTitleLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _sizeTitleLabel.numberOfLines = 2;
        _sizeTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        _sizeTitleLabel.text = [NSString stringWithFormat:@"%@:", STLLocalizedString_(@"size", nil)];
        
    }
    return _sizeTitleLabel;
}

- (UIView *)lineFirst {
    if (!_lineFirst) {
        _lineFirst = [UIView new];
        _lineFirst.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineFirst;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [UIView new];
        _bottomView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _bottomView;
}

- (UIButton *)addToCartButton {
    if (!_addToCartButton) {
        _addToCartButton = [UIButton new];
        _addToCartButton.tag = GoodsDetailEnumTypeAdd;
        [_addToCartButton addTarget:self action:@selector(touchContinue:) forControlEvents:UIControlEventTouchUpInside];
//        _addToCartButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
        if (APP_TYPE == 3) {
            [_addToCartButton setTitle:STLLocalizedString_(@"addToBag",nil) forState:UIControlStateNormal];
        } else {
            [_addToCartButton setTitle:[STLLocalizedString_(@"addToBag",nil) uppercaseString] forState:UIControlStateNormal];
        }
        _addToCartButton.titleLabel.font = [UIFont stl_buttonFont: APP_TYPE == 3 ? 18 : 14];
        [_addToCartButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        _addToCartButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
    }
    return _addToCartButton;
}

- (UIView *)lineSecond {
    if (!_lineSecond) {
        _lineSecond = [UIView new];
        _lineSecond.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineSecond;
}

- (YYAnimatedImageView *)cartAnimationView {
    if (!_cartAnimationView) {
        _cartAnimationView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _cartAnimationView.backgroundColor = STLCOLOR_RANDOM;
    }
    return _cartAnimationView;
}


- (UILabel *)detablLabel {
    if (!_detablLabel) {
        _detablLabel = [[UILabel alloc] init];
        _detablLabel.textColor = OSSVThemesColors.col_B62B21;
        _detablLabel.font = [UIFont systemFontOfSize:14];
        _detablLabel.text = STLLocalizedString_(@"selectSize", nil);
    }
    return _detablLabel;
}


- (UIButton *)eventBtn {
    if (!_eventBtn) {
        _eventBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eventBtn setImage:[UIImage imageNamed:@"detail_size"] forState:UIControlStateNormal];
        [_eventBtn setAttributedTitle:[NSString underLineSizeChatWithTitleStr:nil] forState:UIControlStateNormal];
        _eventBtn.tintColor = OSSVThemesColors.col_B62B21;
        
        [_eventBtn addTarget:self action:@selector(eventBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_eventBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
        }else{
            [_eventBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -4, 0, 4)];
        }
        _eventBtn.hidden = YES;
    }
    return _eventBtn;
}

- (UIView *)sizeTipView{
    if (!_sizeTipView) {
        _sizeTipView = [UIView new];
        _sizeTipView.backgroundColor = OSSVThemesColors.col_F8F8F8;
    }
    return _sizeTipView;
}

- (UILabel *)sizeTipLab{
    if (!_sizeTipLab) {
        _sizeTipLab = [UILabel new];
        _sizeTipLab.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
        _sizeTipLab.font = FontWithSize(12);
        _sizeTipLab.numberOfLines = 0;
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _sizeTipLab.textAlignment = NSTextAlignmentRight;
        }
    }
    return _sizeTipLab;
}

- (QuantityCell *)quanityCell{
    if (!_quanityCell) {
        _quanityCell = [[QuantityCell alloc] init];
        _quanityCell.storgeLabel.hidden = YES;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _quanityCell.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
    }
    return _quanityCell;
}

- (UIView *)flashBgView {
    if (!_flashBgView) {
        _flashBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _flashBgView.backgroundColor = [OSSVThemesColors stlClearColor];
        _flashBgView.backgroundColor = OSSVThemesColors.col_FFF3E4;

        _flashBgView.hidden = YES;
    }
    return _flashBgView;
}

- (UIView *)flashTipView {
    if (!_flashTipView) {
        _flashTipView = [[UIView alloc] initWithFrame:CGRectZero];
        _flashTipView.backgroundColor = [OSSVThemesColors col_FF4E6A:0.07];
    }
    return _flashTipView;
}

- (UILabel *)flashTipLabel {
    if (!_flashTipLabel) {
        _flashTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _flashTipLabel.text = STLLocalizedString_(@"Item_did_join_FlashSale", nil);
        _flashTipLabel.textColor = [OSSVThemesColors col_FF4E6A];
        _flashTipLabel.font = [UIFont systemFontOfSize:11];
        _flashTipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _flashTipLabel;
}

- (void)shakeAnimationForView:(UIView *) view
{
    // 获取到当前的View
    CALayer *viewLayer = view.layer;
    // 获取当前View的位置
    CGPoint position = viewLayer.position;
    // 移动的两个终点位置
    CGPoint x = CGPointMake(position.x + 10, position.y);
    CGPoint y = CGPointMake(position.x - 10, position.y);
    // 设置动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    // 设置运动形式
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    // 设置开始位置
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    // 设置结束位置
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    // 设置自动反转
    [animation setAutoreverses:YES];
    // 设置时间
    [animation setDuration:.1];
    // 设置次数
    [animation setRepeatCount:2];
    // 添加上动画
    [viewLayer addAnimation:animation forKey:nil];
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

@end
