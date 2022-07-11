//
//  STLActionSheet.m
//  STLActionSheet
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2016年 huangxieyue. All rights reserved.
//

#import "STLActionSheet.h"
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

#import "UICollectionViewLeftAlignedLayout.h"
#import "UICollectionViewRightAlignedLayout.h"
#import "STLActivityWWebCtrl.h"
#import "OSSVCheckOutVC.h"

//#import "YYPhotoBrowseView.h"
#import "STLPhotoBrowserView.h"
#import "OSSColorSizeCell.h"
#import "Adorawe-Swift.h"

@interface STLActionSheet () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@property (nonatomic, strong) OSSVDetailsViewModel     *viewModel;
@property (nonatomic, strong) UIView                    *shadeView;

@property (nonatomic, strong) UIView                    *mainView;

@property (nonatomic, strong) UIView                    *sheetView;
@property (nonatomic, strong) UIScrollView              *sheetBgView;
@property (nonatomic, strong) UIButton                  *dismissButton;

//@property (nonatomic, strong) UICollectionView          *collectView;
@property (nonatomic, strong) UIView                    *colorView;
@property (nonatomic, strong) ColorSizePickView                    *colorVieVIV;
@property (nonatomic, strong) UIView                    *sizeView;
@property (nonatomic, strong) UICollectionView          *colorColl;
@property (nonatomic, strong) UICollectionView          *sizeColl;

@property (nonatomic, strong) UILabel                   *colorLabel;
@property (nonatomic, strong) UILabel                   *colorOptionLabel;
@property (nonatomic, strong) UILabel                   *sizeLabel;
@property (nonatomic, strong) UILabel                   *sizeOptionLabel;
@property (nonatomic, strong) UIButton                  *sizeEventBtn;
@property (nonatomic, strong) UIView                    *sizeTipView;
@property (nonatomic, strong) UILabel                   *sizeTipLabel;

@property (nonatomic, strong) QuantityCell              *quanityCell;

@property (nonatomic, strong) UIButton                  *addToCartButton;
//@property (nonatomic, strong) YYAnimatedImageView       *goodsImageView;
@property (nonatomic, strong) UICollectionView          *goodsImageView;
@property (nonatomic, strong) UILabel                   *goodsTitleLabel;
@property (nonatomic, strong) UILabel                   *goodsPriceLabel;
@property (nonatomic, strong) STLCLineLabel             *grayPrice;

@property (nonatomic, strong) UIView                    *lineFirst;

@property (nonatomic, strong) UIView                    *lineSecond;
@property (nonatomic, strong) UIStackView               *bottomView;

@property (nonatomic, strong) UIView                    *flashBgView;
@property (nonatomic, strong) UIView                    *flashTipView;
@property (nonatomic, strong) UILabel                   *flashTipLabel;


@property (nonatomic, strong) UILabel                   *detablLabel;
@property (nonatomic, strong) UIImageView               *detailArrowImageView;
@property (nonatomic, strong) UIButton                  *eventBtn;
@property (nonatomic, strong) EmitterButton             *collectButton;

////折扣标 闪购
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;

@property (nonatomic, strong) YYAnimatedImageView       *cartAnimationView;
@property (nonatomic, assign) CGRect                    goodsImageRelateWindow;
@property (nonatomic, assign) CGFloat                   topSpace;
@property (nonatomic, assign) CGRect                    moveLocationRect;
@property (nonatomic, assign) BOOL                      isAddAnimation;

@property (nonatomic, assign) NSInteger                 lastSelectSection;

@property (nonatomic, strong) OSSVDetailsViewModel     *detailViewModel;
@property (nonatomic, strong) NSMutableArray<OSSVSpecsModel*>  *dataArray;

///临时处理
@property (nonatomic, copy) NSString                    *selectColor;
@property (nonatomic, copy) NSString                    *selectSize;

@property (nonatomic, strong) NSArray           *colorGroup_id;
@property (nonatomic, strong) NSArray           *sizeGroup_id;


@property (nonatomic,assign) BOOL showArrivalNotify;
@end

#define SCREEN_BOUNDS    [UIScreen mainScreen].bounds
#define KPicListCollectionTag    570000
#define KColorItemCollTag 999000
#define KSizeItemCollTag 998000

@implementation STLActionSheet

-(ColorSizePickView *)colorVieVIV{
    if (!_colorVieVIV) {
        _colorVieVIV = [[ColorSizePickView alloc] initWithFrame:CGRectZero];
        _colorVieVIV.delegate = self;
        _colorVieVIV.onlyNeedSize = false;
        @weakify(self)
        _colorVieVIV.didSelectedGoodsId = ^(OSSVAttributeItemModel * _Nonnull attrModel) {
            @strongify(self)
            self.goodsId = [NSString stringWithFormat:@"%@",attrModel.goods_id];
            self.wid = attrModel.wid;
            @weakify(self)
            if (self.attributeNewBlock) {
                @strongify(self)
                self.attributeNewBlock([NSString stringWithFormat:@"%@",self.goodsId],attrModel.wid, self.specialId);
            }
        };
    }
    return _colorVieVIV;
}

-(void)setShowCollectButton:(BOOL)showCollectButton{
    _showCollectButton = showCollectButton;
    self.collectButton.hidden = !showCollectButton;
}

- (void)dealloc {
    if (self.cartAnimationView.superview) {
        [self.cartAnimationView removeFromSuperview];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 初始化界面
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.goodsNum = 1; // 默认商品数量
        self.lastSelectSection = 0;
        self.hadManualSelectSize = YES;
        self.moveLocationRect = CGRectZero;
        [self initDetailView];
    }
    return self;
}

- (void)initDetailView {
    UIView *ws = self;
    ws.hidden = YES;
    
    self.lastSelectSection = 0;
    [ws addSubview:self.shadeView];
    [ws addSubview:self.sheetBgView];
    
    [ws addSubview:self.bottomView];
    [self.sheetBgView addSubview:self.sheetView];


    [self.sheetView addSubview:self.goodsImageView];
    [self.sheetView addSubview:self.goodsTitleLabel];
    [self.sheetView addSubview:self.goodsPriceLabel];
    [self.sheetView addSubview:self.grayPrice];
    [self.sheetView addSubview:self.activityStateView];

    [self.sheetView addSubview:self.detablLabel];
    [self.sheetView addSubview:self.detailArrowImageView];
    [self.sheetView addSubview:self.eventBtn];
    
    [self.sheetView addSubview:self.lineFirst];
//    [self.sheetView addSubview:self.bottomView];

    [self.sheetView addSubview:self.lineSecond];
    [self.sheetView addSubview:self.dismissButton];

    if (APP_TYPE == 3) {
        //VIVCOLOR_SIZE
        [self.sheetView addSubview:self.colorVieVIV];
    }else{
        [self.sheetView addSubview:self.colorView];
        [self.colorView addSubview:self.colorLabel];
        [self.colorView addSubview:self.colorOptionLabel];
        [self.colorView addSubview:self.colorColl];
        
        [self.sheetView addSubview:self.sizeView];
        [self.sizeView addSubview:self.sizeLabel];
        [self.sizeView addSubview:self.sizeOptionLabel];
        [self.sizeView addSubview:self.sizeEventBtn];
        [self.sizeView addSubview:self.sizeColl];
    }
   
    
    [self.sheetView addSubview:self.sizeTipView];
    [self.sizeTipView addSubview:self.sizeTipLabel];
    
    [self.sheetView addSubview:self.quanityCell];
    
    [self.sheetView addSubview:self.flashBgView];
    [self.flashBgView addSubview:self.flashTipView];
    [self.flashBgView addSubview:self.flashTipLabel];

    [self.bottomView addArrangedSubview:self.collectButton];
    [self.bottomView addArrangedSubview:self.addToCartButton];
    
    
    [self.dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sheetView.mas_top).mas_offset(6);
        make.trailing.mas_equalTo(self.sheetView.mas_trailing).mas_offset(-12);
        make.width.height.mas_equalTo(@18);
    }];
    
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.sheetView.mas_leading);
        make.trailing.mas_equalTo(self.sheetView.mas_trailing);
        make.top.mas_equalTo(self.dismissButton.mas_bottom).mas_offset(6);
        make.height.mas_equalTo(APP_TYPE == 3 ? 120 : 200);
    }];
    
    
    [self.goodsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.sheetView.mas_leading).offset(12);
        make.top.mas_equalTo(self.goodsImageView.mas_bottom).offset(8);
        make.trailing.mas_equalTo(self.sheetView.mas_trailing).mas_offset(-12);
    }];
    
    [self.goodsPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsTitleLabel.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.sheetView.mas_leading).offset(12);
    }];
    
    [self.grayPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.goodsPriceLabel.mas_centerY);
        make.leading.mas_equalTo(self.goodsPriceLabel.mas_trailing).offset(4);
    }];
    
    [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.grayPrice.mas_trailing).offset(4);
        make.centerY.mas_equalTo(self.grayPrice.mas_centerY);
    }];
    
    
    [self.detailArrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.sheetView.mas_trailing).offset(-12);
        make.size.mas_equalTo(CGSizeMake(12, 12));
        make.centerY.mas_equalTo(self.goodsPriceLabel.mas_centerY);
    }];
    
    [self.detablLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.detailArrowImageView.mas_centerY);
        make.trailing.mas_equalTo(self.detailArrowImageView.mas_leading);
    }];
    
    [self.eventBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.detailArrowImageView.mas_trailing);
        make.top.bottom.mas_equalTo(self.detailArrowImageView);
        make.leading.mas_equalTo(self.detablLabel.mas_leading);
    }];
    
    [self.lineFirst mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.sheetView);
        make.top.mas_equalTo(self.goodsPriceLabel.mas_bottom).mas_offset(8);
        make.height.mas_equalTo(@0.5);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.shadeView.mas_bottom);
        make.leading.mas_equalTo(self.shadeView.mas_leading);
        make.trailing.mas_equalTo(self.shadeView.mas_trailing);
        make.height.mas_equalTo(kIS_IPHONEX ? 60+STL_TABBAR_IPHONEX_H : 60);
    }];
    
    [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView.mas_top).mas_offset(8);
        make.leading.mas_equalTo(self.bottomView);
        make.width.mas_equalTo(@75);
        make.bottom.mas_equalTo(self.bottomView.mas_bottom).mas_offset(kIS_IPHONEX ? -(STL_TABBAR_IPHONEX_H + 8) : -8);
    }];
    
    [self.addToCartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView.mas_top).mas_offset(8);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
        make.leading.mas_greaterThanOrEqualTo(self.mas_leading).offset(12);
        make.bottom.mas_equalTo(self.bottomView.mas_bottom).mas_offset(kIS_IPHONEX ? -(STL_TABBAR_IPHONEX_H + 8) : -8);
    }];
    
    [self.lineSecond mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView.mas_top);
        make.leading.mas_equalTo(self.bottomView.mas_leading);
        make.trailing.mas_equalTo(self.bottomView.mas_trailing);
        make.height.mas_equalTo(@0.5);
    }];
    
    [self.flashBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.sheetView);
        make.height.mas_equalTo(@0);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
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
    
    if (APP_TYPE == 3) {
        //VIVCOLOR_SIZE
        [self.colorVieVIV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.lineFirst.mas_bottom);
            make.leading.mas_equalTo(self.sheetView).offset(14);
            make.trailing.mas_equalTo(self.sheetView).offset(-14);
            make.height.mas_equalTo(@189);
        }];
        
        [self.sizeTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sheetView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.sheetView.mas_trailing).offset(-12);
            make.top.mas_equalTo(self.colorVieVIV.mas_bottom).offset(12);
            make.height.mas_equalTo(@0);
        }];
    }else{
        [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.lineFirst.mas_bottom);
            make.leading.trailing.mas_equalTo(self.sheetView);
            make.height.mas_equalTo(@94);
        }];
        
        [self.colorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.colorView.mas_leading).offset(12);
            make.top.mas_equalTo(self.colorView.mas_top).offset(17);
            make.height.mas_equalTo(@17);
        }];
        [self.colorOptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.colorLabel.mas_trailing);
            make.centerY.mas_equalTo(self.colorLabel.mas_centerY);
            make.height.mas_equalTo(@17);
        }];
        
        [self.colorColl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.colorView.mas_leading).offset(12);
            make.top.mas_equalTo(self.colorLabel.mas_bottom).offset(12);
            make.trailing.mas_equalTo(self.colorView.mas_trailing).offset(-12);
            make.height.mas_equalTo(@48);
        }];
        
        [self.sizeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.colorView.mas_bottom);
            make.leading.trailing.mas_equalTo(self.sheetView);
            make.height.mas_equalTo(@82);
        }];
        
        [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sizeView.mas_leading).offset(12);
            make.top.mas_equalTo(self.sizeView.mas_top).offset(17);
            make.height.mas_equalTo(@17);
        }];
        [self.sizeOptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sizeLabel.mas_trailing);
            make.centerY.mas_equalTo(self.sizeLabel.mas_centerY);
            make.height.mas_equalTo(@17);
        }];
            
        [self.sizeEventBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.sheetView.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.sizeLabel.mas_centerY);
            make.height.mas_equalTo(@17);
        }];
        
        [self.sizeColl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sizeView.mas_leading).offset(12);
            make.top.mas_equalTo(self.sizeLabel.mas_bottom).offset(12);
            make.trailing.mas_equalTo(self.sizeView.mas_trailing).offset(-12);
            make.height.mas_equalTo(@36);
        }];
        
        [self.sizeTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sheetView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.sheetView.mas_trailing).offset(-12);
            make.top.mas_equalTo(self.colorView.mas_bottom).offset(12);
            make.height.mas_equalTo(@0);
        }];
        
    }
    

    [self.sizeTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.sizeTipView.mas_leading).offset(8);
        make.trailing.mas_equalTo(self.sizeTipView.mas_trailing).offset(-8);
        make.top.mas_equalTo(self.sizeTipView.mas_top).offset(4);
        make.bottom.mas_equalTo(self.sizeTipView.mas_bottom).offset(-4);
    }];
    
    [self.quanityCell mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sizeTipView.mas_bottom).offset(6);
        make.leading.trailing.mas_equalTo(self.sheetView);
        make.height.mas_equalTo(@36);
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLoginSuccess) name:kNotif_Login object:nil];
}

- (OSSVDetailsViewModel*)detailViewModel {
    if (!_detailViewModel) {
        _detailViewModel = [OSSVDetailsViewModel new];
        _detailViewModel.controller = self.viewController;
    }
    return _detailViewModel;
}

- (void)setHasFirtFlash:(BOOL)hasFirtFlash {
    _hasFirtFlash = hasFirtFlash;

}

#pragma mark - 设置不同按钮类型显示样式
- (void)setType:(GoodsDetailEnumType)type {
    _type = type;
}

- (void)setIsListSheet:(BOOL)isListSheet {
    _isListSheet = isListSheet;
//    self.detailArrowImageView.hidden = !isListSheet;
//    self.detablLabel.hidden = !isListSheet;
    self.eventBtn.hidden = !isListSheet;
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
    _goodsNum = 1;
    self.specialId = STLToString(baseInfoModel.specialId);
    self.goodsId = baseInfoModel.goodsId;
    self.wid = baseInfoModel.goodsWid;
    if (!self.cart_exits) {
        self.cart_exits = baseInfoModel.cart_exists;
    }
    
    self.flashTipView.hidden = YES;
    
    for (OSSVSpecsModel *specModel in _baseInfoModel.GoodsSpecs) {
        if ([specModel.spec_type integerValue] == 1) {
            for (OSSVAttributeItemModel *itemModel in specModel.brothers) {
                if ([itemModel.goods_id isEqualToString:_baseInfoModel.goodsId]) {
                    self.colorGroup_id = itemModel.group_goods_id;
                }
            }
            if(specModel.brothers.count){
                _baseInfoModel.isHasColorItem = YES;
            }
        }
        if ([specModel.spec_type integerValue] == 2) {
            if(specModel.brothers.count){
                _baseInfoModel.isHasSizeItem = YES;
            }
        }
    }
    
    if ([_baseInfoModel.goodsNumber integerValue] > 0) {
        self.addToCartButton.enabled = YES;
        _showArrivalNotify = NO;
        [_addToCartButton setTitle:STLLocalizedString_(@"addToBag",nil) forState:UIControlStateNormal];
    }else{
        self.addToCartButton.enabled = YES;
        [_addToCartButton setTitle:STLLocalizedString_(@"Arrival_Notify", nil) forState:UIControlStateNormal];
        _showArrivalNotify = YES;
    }
    
    if (!_baseInfoModel.isOnSale) {
        self.addToCartButton.enabled = YES;
        [_addToCartButton setTitle:STLLocalizedString_(@"Arrival_Notify", nil) forState:UIControlStateNormal];
        _showArrivalNotify = YES;
    }

    // 0 > 闪购 > 满减
    self.flashBgView.hidden = YES;
    if (STLIsEmptyString(baseInfoModel.specialId)
        && baseInfoModel.flash_sale
        && !STLIsEmptyString(baseInfoModel.flash_sale.active_discount)
        && [baseInfoModel.flash_sale.active_discount floatValue] > 0
        && ![baseInfoModel.flash_sale.sold_out isEqualToString:@"1"]
        && [baseInfoModel.flash_sale.active_status isEqualToString:@"1"]) {
        
        [self.addToCartButton setTitleColor:[OSSVThemesColors col_0D0D0D] forState:UIControlStateNormal];
        self.addToCartButton.backgroundColor = [OSSVThemesColors col_FDC845];
        
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
        [self.flashBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@36);
        }];
    }else{
        
        [self.addToCartButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        self.addToCartButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
        
        self.flashTipLabel.textColor = OSSVThemesColors.col_6C6C6C;
        if (!baseInfoModel.isOnSale) {
            self.flashBgView.hidden = NO;
            self.flashTipLabel.text = STLLocalizedString_(@"NotOnSale", nil);
            self.flashTipView.backgroundColor = OSSVThemesColors.col_FFF5DF;
            [self.flashBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(@36);
            }];
        }else if ([baseInfoModel.goodsNumber integerValue] == 0){
            self.flashBgView.hidden = NO;
            self.flashTipLabel.text = STLLocalizedString_(@"SaleOut", nil);
            self.flashTipView.backgroundColor = OSSVThemesColors.col_FFF5DF;
            [self.flashBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(@36);
            }];
        }else{
            if(baseInfoModel.flash_sale && [baseInfoModel.flash_sale.active_status isEqualToString:@"0"]){
                self.flashBgView.hidden = NO;
                self.flashTipLabel.text = STLLocalizedString_(@"Item_pre_join_FlashSale", nil);
                self.flashTipView.backgroundColor = OSSVThemesColors.col_F8F8F8;
                self.flashTipView.backgroundColor = OSSVThemesColors.col_F8F8F8;
                [self.flashBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(@36);
                }];
            }else{
                self.flashTipView.hidden = YES;
            }
        }
    }

    [self.goodsImageView reloadData];
    
    self.goodsPriceLabel.textColor = [OSSVThemesColors col_0D0D0D];
    self.goodsPriceLabel.text = STLToString(baseInfoModel.shop_price_converted);
    self.grayPrice.text = STLToString(baseInfoModel.market_price_converted);
    if (APP_TYPE == 3) {
        self.grayPrice.hidden = YES;
        if ([baseInfoModel.showDiscountIcon isEqualToString:@"0"] || [OSSVNSStringTool isEmptyString:baseInfoModel.goodsDiscount] || [baseInfoModel.goodsDiscount isEqualToString:@"0"]) {

        } else {// 价格
            self.grayPrice.hidden = NO;
        }
        if (STLIsEmptyString(baseInfoModel.specialId) && baseInfoModel.flash_sale &&  [baseInfoModel.flash_sale.is_can_buy isEqualToString:@"1"] && [baseInfoModel.flash_sale.active_status isEqualToString:@"1"]) {
            self.grayPrice.hidden = NO;
        }
    }
    self.goodsTitleLabel.text = baseInfoModel.goodsTitle;
    

    // 是否收藏
    self.collectButton.selected = baseInfoModel.isCollect;
    NSString *collectImgName = baseInfoModel.isCollect ? @"actionSheet_like_selected" : @"actionSheet_like_unselected";
    [self.collectButton setImage:[UIImage imageNamed:collectImgName] forState:UIControlStateNormal];
    
    
//    self.addToCartButton.backgroundColor = OSSVThemesColors.col_F1F1F1;
//    self.addToCartButton.userInteractionEnabled = NO;
//    [self.addToCartButton setTitleColor:[OSSVThemesColors col_333333] forState:UIControlStateNormal];

    self.activityStateView.hidden = YES;
    
    if ([baseInfoModel.showDiscountIcon isEqualToString:@"0"] || [OSSVNSStringTool isEmptyString:baseInfoModel.goodsDiscount] || [baseInfoModel.goodsDiscount isEqualToString:@"0"]) {
        self.goodsPriceLabel.textColor = [OSSVThemesColors col_0D0D0D];
    } else {// 价格
        self.goodsPriceLabel.textColor = OSSVThemesColors.col_B62B21;
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(baseInfoModel.goodsDiscount)];
    }
    
    //和鲍勇再次确认完全可以拿着is_can_buy 字段来判断用户能否按照闪购价继续购买，以及闪购背景置灰和 价格不为红色
    // 0 > 闪购 > 满减
    if (STLIsEmptyString(baseInfoModel.specialId) && baseInfoModel.flash_sale &&  [baseInfoModel.flash_sale.is_can_buy isEqualToString:@"1"] && [baseInfoModel.flash_sale.active_status isEqualToString:@"1"]) {
        
        self.activityStateView.hidden = NO;
        self.goodsPriceLabel.text = STLToString(baseInfoModel.flash_sale.active_price_converted);
        self.goodsPriceLabel.textColor = OSSVThemesColors.col_B62B21;
        [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(baseInfoModel.flash_sale.active_discount)];
    }
    
    if (![OSSVNSStringTool isEmptyString:self.specialId] && [baseInfoModel.shop_price integerValue] == 0) {
        self.goodsPriceLabel.textColor = OSSVThemesColors.col_B62B21;
    }
    
    if (APP_TYPE == 3) {
        self.colorVieVIV.goodsInfo = baseInfoModel;
    }else{
        [self.dataArray removeAllObjects];
        if (STLJudgeNSArray(baseInfoModel.GoodsSpecs)) {
            
            if (baseInfoModel.GoodsSpecs.count <= 0) {
                self.hadManualSelectSize = YES;
                if (self.attributeHadManualSelectSizeBlock) {
                    self.attributeHadManualSelectSizeBlock();
                }
                
            } else {
                
                __block OSSVAttributeItemModel *selectMainAttriModel = nil;
                NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:baseInfoModel.GoodsSpecs];
                [tempArray enumerateObjectsUsingBlock:^(OSSVSpecsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    //默认选择的是主属性
                    if (idx == self.lastSelectSection) {
                        [obj.brothers enumerateObjectsUsingBlock:^(OSSVAttributeItemModel * _Nonnull brothersObj, NSUInteger idx, BOOL * _Nonnull brothersStop) {
                            if ([brothersObj.group_goods_id containsObject:self.goodsId]) {
                                selectMainAttriModel = brothersObj;
                                *brothersStop = YES;
                            }
                        }];
                    }
                }];
                
                [tempArray enumerateObjectsUsingBlock:^(OSSVSpecsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if (idx != self.lastSelectSection) {
                        [obj.brothers enumerateObjectsUsingBlock:^(OSSVAttributeItemModel * _Nonnull brothersObj, NSUInteger idx, BOOL * _Nonnull brothersStop) {
                            //不包含主属性的商品组合id的，都不能点
                            if (![self isContainIds:selectMainAttriModel.group_goods_id findGoodIds:brothersObj.group_goods_id]) {
    //                            brothersObj.disabled = YES;
                            }
                        }];
                    }
                }];
                
                self.dataArray = [[NSMutableArray alloc] initWithArray:tempArray];
            }
        } else {
            self.hadManualSelectSize = YES;
            if (self.attributeHadManualSelectSizeBlock) {
                self.attributeHadManualSelectSizeBlock();
            }
        }
    }
   
    
//    [self.collectView reloadData];
    
    self.quanityCell.type = self.type;
    //新人礼包不能编辑
    self.quanityCell.userInteractionEnabled = self.isNewUser ? NO : YES;
    @weakify(self)
    self.quanityCell.goodsNumBlock = ^(NSString *goodsNum) {
        @strongify(self)
        self.goodsNum = [goodsNum integerValue];
    };
    self.quanityCell.operateBlock = ^(QuantityCellEvent event) {
        //@strongify(self)

    };
    //商品加购
    if (self.goodsNum == 0) {
        self.goodsNum = 1;
    }
    
    [self.quanityCell handleGoodsNumber:self.baseInfoModel currnetCount:self.goodsNum];
    [self judgeIsShowColorOrSize];
    
    [self scrollToFirstItem];
    
    if (APP_TYPE == 3 && _showArrivalNotify) {
        _addToCartButton.backgroundColor = OSSVThemesColors.col_9F5123;
    }
}

- (void)updateLoginSuccess{
    //@weakify(self);
    if (!self.isHidden) {
        [self dismiss];
    }
}


// 有些商品没有尺码或者颜色
- (void)judgeIsShowColorOrSize{
    if (APP_TYPE != 3) {
        [self.colorColl reloadData];
        [self.sizeColl reloadData];
    }
    

    if (_baseInfoModel.isHasColorItem && _baseInfoModel.isHasSizeItem) {
        if (APP_TYPE == 3) {
            [self.colorVieVIV mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(189);
            }];
        }else{
            [self.colorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.lineFirst.mas_bottom);
                make.leading.trailing.mas_equalTo(self.sheetView);
                make.height.mas_equalTo(@94);
            }];
            [self.sizeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.colorView.mas_bottom);
                make.leading.trailing.mas_equalTo(self.sheetView);
                make.height.mas_equalTo(@82);
            }];
            self.sizeView.hidden = NO;
            self.colorView.hidden = NO;
        }
        
        if (!kIS_IPHONEX) {
            self.sheetBgView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - (10)*DSCREEN_HEIGHT_SCALE);
        }
       
        
        return;
    }
    if (!_baseInfoModel.isHasColorItem && !_baseInfoModel.isHasSizeItem) {
        if (APP_TYPE == 3) {
            [self.colorVieVIV mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
        }else{
            [self.sizeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.colorView.mas_bottom);
                make.leading.trailing.mas_equalTo(self.sheetView);
                make.height.mas_equalTo(@0);
            }];
            [self.colorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.lineFirst.mas_bottom);
                make.leading.trailing.mas_equalTo(self.sheetView);
                make.height.mas_equalTo(@0);
            }];
            self.sizeView.hidden = YES;
            self.colorView.hidden = YES;
        }
        
    }else if (!_baseInfoModel.isHasColorItem) {
        
        if (APP_TYPE == 3) {
            [self.colorVieVIV mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(82);
            }];
        }else{
            [self.colorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.lineFirst.mas_bottom);
                make.leading.trailing.mas_equalTo(self.sheetView);
                make.height.mas_equalTo(@0);
            }];
            self.colorView.hidden = YES;
            self.sizeView.hidden = NO;
            [self.sizeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.colorView.mas_bottom);
                make.leading.trailing.mas_equalTo(self.sheetView);
                make.height.mas_equalTo(@82);
            }];
            
        }

//        [self.sizeColl reloadData];
    }else if (!_baseInfoModel.isHasSizeItem) {
        
        
        if (APP_TYPE == 3) {
            [self.colorVieVIV mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(104);
            }];
        }else{
            [self.sizeView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.colorView.mas_bottom);
                make.leading.trailing.mas_equalTo(self.sheetView);
                make.height.mas_equalTo(@0);
            }];
            self.sizeView.hidden = YES;
            self.colorView.hidden = NO;
            [self.colorView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.lineFirst.mas_bottom);
                make.leading.trailing.mas_equalTo(self.sheetView);
                make.height.mas_equalTo(@94);
            }];
        }

//        [self.colorColl reloadData];
    }
    
    if (APP_TYPE == 3) {
        return;
    }
    
    NSInteger colorItem = 0;
    NSInteger sizeItem = 0;
    for (OSSVSpecsModel *specModel in _baseInfoModel.GoodsSpecs) {
        if ([specModel.spec_type integerValue] == 1) {
            for (int i = 0;i < specModel.brothers.count;i++) {
                OSSVAttributeItemModel *itemModel  = specModel.brothers[i];
                if ([itemModel.goods_id isEqualToString:_baseInfoModel.goodsId]) {
                    self.colorGroup_id = itemModel.group_goods_id;
                    colorItem = i;
                }
               
            }
        }
        if ([specModel.spec_type integerValue] == 2) {
            for (int i = 0;i < specModel.brothers.count;i++) {
                OSSVAttributeItemModel *itemModel  = specModel.brothers[i];
                if ([itemModel.goods_id isEqualToString:_baseInfoModel.goodsId]) {
                    self.colorGroup_id = itemModel.group_goods_id;
                    sizeItem = i;
                }
               
            }
        }
    }
    
    NSInteger count = [self.colorColl numberOfItemsInSection:0];
    if (_baseInfoModel.isHasColorItem && colorItem != 0 && count > colorItem) {
        NSIndexPath *indexP = [NSIndexPath indexPathForItem:colorItem inSection:0];
        [self.colorColl scrollToItemAtIndexPath:indexP atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
    if (_baseInfoModel.isHasSizeItem && sizeItem != 0) {
        NSIndexPath *indexP = [NSIndexPath indexPathForItem:sizeItem inSection:0];
        [self.sizeColl scrollToItemAtIndexPath:indexP atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (void)scrollToFirstItem{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    [self.goodsImageView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark - 关闭收回窗口

- (void)addCartAnimationTop:(CGFloat)top moveLocation:(CGRect)location showAnimation:(BOOL)isAddAnimation{
    self.isAddAnimation = isAddAnimation;
    self.topSpace = top;
    self.moveLocationRect = location;
    
}
- (CGRect)goodsImageFrameRelativeWindow {
    return [self.goodsImageView convertRect:self.goodsImageView.bounds toView:WINDOW];
}
- (void)dismiss {

    [UIView animateWithDuration:0.5 animations:^{
//        CGRect frame = self.sheetView.frame;
//        frame.origin.y = self.bounds.size.height;
//        self.sheetView.frame = frame;
        
        CGRect frame = self.sheetBgView.frame;
        frame.origin.y = self.bounds.size.height;
        self.sheetBgView.frame = frame;
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
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect frame = self.sheetView.frame;
//        frame.origin.y = self.bounds.size.height - frame.size.height;
//        self.sheetView.frame = frame;
//    }];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.sheetBgView.frame;
        frame.origin.y = self.bounds.size.height - frame.size.height;
        self.sheetBgView.frame = frame;
    }];
    

    self.cartAnimationView.hidden = YES;
    self.goodsImageRelateWindow = [self goodsImageFrameRelativeWindow];
    
    
    
    
    //"- normal：普通商品
    //- free：0元购"
    NSString *item_type = @"normal";
    if (!STLIsEmptyString(self.baseInfoModel.specialId)) {
        item_type = @"free";
    }
    
    NSString *price = STLToString(self.baseInfoModel.shop_price);
    
    // 0 > 闪购 > 满减
    if (STLIsEmptyString(self.baseInfoModel.specialId) && self.baseInfoModel.flash_sale &&  [self.baseInfoModel.flash_sale.is_can_buy isEqualToString:@"1"] && [self.baseInfoModel.flash_sale.active_status isEqualToString:@"1"]) {
        price = STLToString(self.baseInfoModel.flash_sale.active_price);

    }
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

#pragma mark - 点击AddToBag  加购按钮
- (void)addToBagAction:(UIButton*)sender{
   
    if (_showArrivalNotify) {
        [ArrivalSubScribManager.shared showArrivalAlertWithGoodsInfo:_baseInfoModel];
        return;
    }
    
    @weakify(self)
    [self.viewModel requestCartExit:@{@"wid":STLToString(self.wid),@"goods_id":STLToString(self.goodsId)} completion:^(BOOL isExit) {
        @strongify(self)
        self.cart_exits = isExit;
        [self judgeAddTobagWithSender:sender];
    } failure:^(BOOL isExit) {
        @strongify(self)
        self.cart_exits = isExit;
        [self judgeAddTobagWithSender:sender];
    }];
}

-(void)judgeAddTobagWithSender:(UIButton *)sender{
    NSArray *upperTitle = @[STLLocalizedString_(@"no",nil).uppercaseString,STLLocalizedString_(@"yes", nil).uppercaseString];
    NSArray *lowserTitle = @[STLLocalizedString_(@"no",nil),STLLocalizedString_(@"yes", nil)];
    if (self.cart_exits && self.baseInfoModel.shop_price.floatValue == 0) {
        NSString *msg = STLLocalizedString_(@"switchFreeItem", nil);
        [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:@"" message:msg buttonTitles:APP_TYPE == 3 ? lowserTitle : upperTitle buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
            if (index==1) {
                [self touchContinue:sender];
            }
        }];
        return;
    }else{
        [self touchContinue:sender];
    }
}

- (void)touchContinue:(UIButton*)sender {
    
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
            if (self.goodsNum == 0) {
                self.goodsNum = 1;
            }
            cartModel.goodsNumber = self.goodsNum;
            cartModel.goodsPrice = self.baseInfoModel.shop_price;
            cartModel.isFavorite = self.baseInfoModel.isCollect;
            cartModel.wid = self.baseInfoModel.goodsWid;
//            cartModel.warehouseCode = self.baseInfoModel.warehouseCode;
            cartModel.stateType = CartGoodsOperateTypeAdd;
//            cartModel.goodsAttr = self.baseInfoModel.goodsAttr;
//            cartModel.warehouseName = self.baseInfoModel.warehouseName;
            cartModel.goodsStock = self.baseInfoModel.goodsNumber;
            cartModel.isOnSale = self.baseInfoModel.isOnSale;
            cartModel.isChecked = YES;
            cartModel.specialId = STLToString(self.specialId);
            cartModel.mediasource = self.sourceType;
            cartModel.reviewsId = self.reviewsId;
            cartModel.cart_exits = self.cart_exits;
            
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
//                    [HUDManager showHUDWithMessage:[OSSVNSStringTool isEmptyString:msg] ? STLLocalizedString_(@"noInventory", nil) : msg];
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
#pragma mark --加购的埋点
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

        //v1.4.6 现在弹窗加购 都是列表快速加购
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
                                   @"screen_group":STLToString(self.gaAnalyticsDic[kGA_screen_group]),
                                   @"position":STLToString(self.gaAnalyticsDic[kGA_position]),
        };
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventAddToCart parameters:itemsDic];
        
        [OSSVAnalyticsTool analyticsGAEventWithName:@"add_to_cart" parameters:@{@"screen_group": [NSString stringWithFormat:@"%@%@", STLToString(self.screenGroup), STLToString(self.baseInfoModel.goodsTitle)],
                                                                           @"position" : STLToString(self.position),
                                                                           @"currency" : @"USD",
                                                                           @"value"    : @(price),
                                                                           @"items"    : @[items]
        }];

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
                                 kAnalyticsRecommendPartId  :   STLToString(self.analyticsDic[kAnalyticsRequestId]),
            };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"AddToCart" parameters:sensorsDic];
    [OSSVAnalyticsTool analyticsSensorsEventFlush];
    ///branch 埋点
    [OSSVBrancshToolss logAddToCart:sensorsDic];
    
    [DotApi addToCart];
}

- (NSString *)shoppingcartString:(NSInteger)type {
    if (type == 1) {
        return @"addcart_quick";
    } else if (type == 2){
        return @"often_bought_with";
    }
    return @"addcart_goods";
}
- (void)handleAddCart {
    
    if (self.isAddAnimation) {
        
        if (self.cartAnimationView.superview) {
            [self.cartAnimationView removeFromSuperview];
        }
        [WINDOW addSubview:self.cartAnimationView];
        
        CGFloat x = [OSSVSystemsConfigsUtils isRightToLeftShow] ? (SCREEN_WIDTH - CGRectGetWidth(self.goodsImageView.frame) - 16): 16;
        self.cartAnimationView.frame = CGRectMake(x,self.goodsImageRelateWindow.origin.y + self.topSpace, CGRectGetWidth(self.goodsImageView.frame), CGRectGetHeight(self.goodsImageView.frame));
//        UIImageView *currentImgV = (UIImageView *)[self.goodsImageView itemViewAtIndex:self.goodsImageView.currentItemIndex];
        
        NSIndexPath *index = [NSIndexPath indexPathForItem:0 inSection:0];
        STLPicListCell *cell = (STLPicListCell *)[self.goodsImageView cellForItemAtIndexPath:index];
        UIImage *img = [cell getImgOfCell];
        self.cartAnimationView.image = img;
        self.cartAnimationView.hidden = NO;
        
        //动画-

        
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
            self.cartAnimationView.frame= self.moveLocationRect;
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

//#pragma mark  立即购买方法  v1.4.0注释掉occ，一直没有这个功能
- (void)buyItNow {
}



- (void)actionTapGoodsImageCell:(STLPicListCell *)picCell withIndex:(NSIndexPath *)index{

    CGSize tempSize = CGSizeMake(150, 200);
    OSSVDetailPictureArrayModel *picModel = _baseInfoModel.pictureListArray.firstObject;
    if ([picModel.img_height integerValue] != 0 || [picModel.img_width integerValue] != 0) {
        CGFloat bili = [picModel.img_width floatValue]/[picModel.img_height floatValue];
        tempSize = CGSizeMake(200 *bili, 200);
    }
    
    NSMutableArray *tempBrowseImageArr = [NSMutableArray array];
    
    NSMutableArray *imgvArray = [NSMutableArray arrayWithCapacity:1];
    
    
    CGRect currentFrame = [picCell convertRect:picCell.imgV.frame toView:self.window];
    
    if (_baseInfoModel.pictureListArray.count > 0) {
        
        [_baseInfoModel.pictureListArray enumerateObjectsUsingBlock:^(OSSVDetailPictureArrayModel * _Nonnull picModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIImageView *tempImageView = [[UIImageView alloc] init];
            tempImageView.frame = currentFrame;

            if (idx != index.row) {
                NSIndexPath *currnetIndex = [NSIndexPath indexPathForRow:idx inSection:index.section];
                STLPicListCell *cell = (STLPicListCell *)[self.goodsImageView cellForItemAtIndexPath:currnetIndex];
                if (cell) {
                    tempImageView.frame = [cell convertRect:cell.imgV.frame toView:self.window];
                }
                //大图里是拿 图片视图去处理位置的
                //tempImageView.frame = CGRectMake(idx * tempSize.width, currentFrame.origin.y, tempSize.width, tempSize.height);
            }
            
            STLPhotoGroupItem *showItem = [STLPhotoGroupItem new];
            showItem.thumbView = tempImageView;
            
            NSURL *url = [NSURL URLWithString:picModel.goodsBigImg];
            showItem.largeImageURL = url;
            [tempBrowseImageArr addObject:showItem];
            [imgvArray addObject:tempImageView];
        }];
    }
    
    
    STLPhotoBrowserView *groupView = [[STLPhotoBrowserView alloc] initWithGroupItems:tempBrowseImageArr];
    groupView.blurEffectBackground = NO;
    groupView.showDismiss = YES;
    @weakify(self)
    groupView.dismissCompletion = ^(NSInteger currentPage) {
        @strongify(self)
        NSIndexPath *indexPaht = [NSIndexPath indexPathForRow:currentPage inSection:index.section];
//        [self.goodsImageView setContentOffset:CGPointMake(tempSize.width * currentPage, 0) animated:NO];
        if (self.baseInfoModel.pictureListArray.count > currentPage) {
            
            [self.goodsImageView scrollToItemAtIndexPath:indexPaht atScrollPosition:[OSSVSystemsConfigsUtils isRightToLeftShow] ?  UICollectionViewScrollPositionRight : UICollectionViewScrollPositionLeft animated:NO];
        }

    };

    [groupView presentFromImageView:imgvArray[index.row] toContainer:self.window animated:YES completion:nil];
}

#pragma mark ---Details 跳转到商详
- (void)eventBtnTouch:(UIButton*)sender {

    NSString *goodsImageUrl = @"";
    OSSVDetailPictureArrayModel *firstModel = self.baseInfoModel.pictureListArray.firstObject;
    if (firstModel) {
        goodsImageUrl = STLToString(firstModel.goodsBigImg);
    }
    if (self.goNewToDetailBlock) {
        self.goNewToDetailBlock(STLToString(self.baseInfoModel.goodsId),STLToString(self.baseInfoModel.goodsWid), STLToString(self.baseInfoModel.specialId),goodsImageUrl);
    }
    [OSSVAnalyticsTool analyticsGAEventWithName:@"item_entrance" parameters:@{@"screen_group": [NSString stringWithFormat:@"%@%@",STLToString(self.screenGroup), STLToString(self.baseInfoModel.goodsTitle)],
                                                                         @"content" : STLToString(self.baseInfoModel.goodsTitle)
    }];
}
#pragma mark ----收藏按钮
- (void)actionCollection:(EmitterButton *)sender {
    if (USERID) {
        [sender animation];
        NSString *collectImgName = !self.baseInfoModel.isCollect ? @"flash_collectIcon_red" : @"flash_collectIcon_gray";
        [self.collectButton setImage:[UIImage imageNamed:collectImgName] forState:UIControlStateNormal];
        if (self.baseInfoModel.isCollect) {
            @weakify(self)
            [self.viewModel requestCollectDelNetwork:@[STLToString(self.baseInfoModel.goodsId),STLToString(self.baseInfoModel.goodsWid)] completion:^(id obj) {

                @strongify(self)
                [HUDManager showHUDWithMessage:STLLocalizedString_(@"removedWishlist",nil)];

                self.baseInfoModel.isCollect = NO;
                NSInteger wishCount = [self.baseInfoModel.wishCount integerValue] - 1;
                self.baseInfoModel.wishCount = [NSString stringWithFormat:@"%ld",(long)(wishCount >0 ? wishCount : 0)];

                if (self.collectionStateBlock) {
                    self.collectionStateBlock(self.baseInfoModel.isCollect, self.baseInfoModel.wishCount);
                }
                
                NSDictionary *itemsDic = @{@"screen_group" : [NSString stringWithFormat:@"%@%@", STLToString(self.screenGroup), STLToString(self.baseInfoModel.goodsTitle)],
                                           @"action"       : @"Remove",
                                           @"content"      : STLToString(self.baseInfoModel.goodsTitle)
                };
                
                [OSSVAnalyticsTool analyticsGAEventWithName:@"wishList_action" parameters:itemsDic];

            } failure:^(id obj) {
                
            }];
        } else {
            
            @weakify(self)
            [self.viewModel requestCollectAddNetwork:@[STLToString(self.baseInfoModel.goodsId),STLToString(self.baseInfoModel.goodsWid)] completion:^(id obj) {
                @strongify(self)
                [HUDManager showHUDWithMessage:STLLocalizedString_(@"addedWishlist",nil)];
                self.baseInfoModel.isCollect = YES;
                self.baseInfoModel.wishCount = [NSString stringWithFormat:@"%ld",(long)([self.baseInfoModel.wishCount integerValue] + 1)];
                if (self.collectionStateBlock) {
                    self.collectionStateBlock(self.baseInfoModel.isCollect, self.baseInfoModel.wishCount);
                }
                // 谷歌统计 收藏
                [OSSVAnalyticsTool appsFlyeraAddToWishlistWithProduct:self.baseInfoModel fromProduct:YES];
                

                //和鲍勇再次确认完全可以拿着is_can_buy 字段来判断用户能否按照闪购价继续购买，以及闪购背景置灰和 价格不为红色
                //GA
                CGFloat price = [self.baseInfoModel.shop_price floatValue];;
                // 0 > 闪购 > 满减
                if (!STLIsEmptyString(self.baseInfoModel.specialId)) {//0元
                    price = [self.baseInfoModel.shop_price floatValue];
                    
                }  else if (STLIsEmptyString(self.baseInfoModel.specialId) && self.baseInfoModel.flash_sale &&  [self.baseInfoModel.flash_sale.is_can_buy isEqualToString:@"1"] && [self.baseInfoModel.flash_sale.active_status isEqualToString:@"1"]) {//闪购
                    price = [self.baseInfoModel.flash_sale.active_price floatValue];
                }

                NSDictionary *items = @{
                    @"item_id": STLToString(self.baseInfoModel.goods_sn),
                    @"item_name": STLToString(self.baseInfoModel.goodsTitle),
                    @"item_category": STLToString(self.baseInfoModel.cat_name),
                    @"price": @(price),
                    @"quantity": @(1),

                };
                NSDictionary *itemsDic = @{@"items":@[items],
                                           @"currency": @"USD",
                                           @"value":  @(price),
                                           @"position" : STLToString(self.position),
                                           @"screen_group" : [NSString stringWithFormat:@"%@%@",STLToString(self.screenGroup), STLToString(self.baseInfoModel.goodsTitle)]
                };
                [OSSVAnalyticsTool analyticsGAEventWithName:@"add_to_wishlist" parameters:itemsDic];
           
                NSDictionary *sensorsDic = @{@"goods_sn":STLToString(self.baseInfoModel.goods_sn),
                                            @"goods_name":STLToString(self.baseInfoModel.goodsTitle),
                                             @"cat_id":STLToString(self.baseInfoModel.cat_id),
                                             @"cat_name":STLToString(self.baseInfoModel.cat_name),
                                             @"original_price":@([STLToString(self.baseInfoModel.market_price) floatValue]),
                                             @"present_price":@(price),
                                             @"entrance":self.isListSheet ? @"collect_quick" : @"collect_goods",
                        };
                [OSSVAnalyticsTool analyticsSensorsEventWithName:@"GoodsCollect" parameters:sensorsDic];

            } failure:^(id obj) {
                
            }];
        }
    } else {
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        signVC.signBlock = ^{
            @strongify(self)
            [self actionCollection:self.collectButton];
        };
        [self.viewController presentViewController:signVC animated:YES completion:^{
        }];
    }
}

- (BOOL)isShowActivity:(OSSVDetailsBaseInfoModel *)infoModel {
    
    return [infoModel isGoodsDetailDiscountOrFlash];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    self.selectSize = @"";
    self.selectColor = @"";
    return 1;

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView.tag == KPicListCollectionTag) {
        return _baseInfoModel.pictureListArray.count;
    }
    else if(collectionView.tag == KColorItemCollTag){
        OSSVSpecsModel *specsModel = self.dataArray.firstObject;
        return specsModel.brothers.count;
    }
    else if(collectionView.tag == KSizeItemCollTag){
        OSSVSpecsModel *specModel = self.dataArray.lastObject;
        return specModel.brothers.count;
    }
        return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OSSVSpecsModel *specModel = nil;
    OSSColorSizeCell * cell = nil;
    if (collectionView.tag == KPicListCollectionTag) {
        STLPicListCell *cell = [STLPicListCell STLPicListCellWithCollectionView:collectionView indexPath:indexPath];
        OSSVDetailPictureArrayModel *picModel = _baseInfoModel.pictureListArray[indexPath.item];
        NSString *imgStr = picModel.goodsBigImg;
        cell.imgUrlStr = imgStr;
        return cell;
    }else if (collectionView.tag == KColorItemCollTag) {
        specModel = self.dataArray.firstObject;
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"colorSheetCell" forIndexPath:indexPath];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            cell.colorImgV.transform = CGAffineTransformMakeScale(1.0, 1.0);
            cell.flagLab.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }
    }else if(collectionView.tag == KSizeItemCollTag){
        specModel = self.dataArray.lastObject;
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sizeSheetCell" forIndexPath:indexPath];
    }

    cell.goos_numeber = [_baseInfoModel.goodsNumber integerValue];
    cell.goos_id = _baseInfoModel.goodsId;
    OSSVAttributeItemModel *itemModel = specModel.brothers[indexPath.item];

    specModel.isSelectSize = YES;
    cell.goodsSpecModel = specModel;

    if ([specModel.spec_type integerValue] == 1) {
        // 颜色
        if ([itemModel.goods_id isEqualToString:_baseInfoModel.goodsId]) {
            self.colorGroup_id = itemModel.group_goods_id;
            self.colorLabel.text = [NSString stringWithFormat:@"%@:", specModel.spec_name];
            self.colorOptionLabel.text = itemModel.value;
        }
    }else if([specModel.spec_type integerValue] == 2){
        // 尺码
        if ([itemModel.goods_id isEqualToString:_baseInfoModel.goodsId]) {
            self.sizeGroup_id = itemModel.group_goods_id;
            self.sizeOptionLabel.text = itemModel.value;
            self.sizeLabel.text = [NSString stringWithFormat:@"%@:", specModel.spec_name];
        }
        if (![OSSVNSStringTool isEmptyString:STLToString(specModel.size_chart_url)] && ![OSSVNSStringTool isEmptyString:STLToString(specModel.size_chart_title)] && _baseInfoModel.isHasSizeItem) {
            self.sizeEventBtn.hidden = NO;
            [_sizeEventBtn setImage:[UIImage imageNamed:@"detail_size"] forState:UIControlStateNormal];
            [_sizeEventBtn setAttributedTitle:[NSString underLineSizeChatWithTitleStr:specModel.size_chart_title] forState:UIControlStateNormal];
            _sizeEventBtn.tintColor = OSSVThemesColors.col_B62B21;
        }else{
            self.sizeEventBtn.hidden = YES;
            [_sizeEventBtn setImage:nil forState:UIControlStateNormal];
        }
        
        if (_baseInfoModel.isHasColorItem && _baseInfoModel.isHasSizeItem) {
            NSArray *arr = [self interArrayWithArray:self.colorGroup_id other:itemModel.group_goods_id];
            if (arr && arr.count > 0) {
                cell.isJiaoJi = YES;
            }else{
                cell.isJiaoJi = NO;
            }
        }else{
            cell.isJiaoJi = YES;
        }
        
    }

    cell.itemModel = itemModel;

    if (specModel.isSelectSize && [itemModel.goods_id isEqualToString:_baseInfoModel.goodsId] && [specModel.spec_type integerValue] == 2 && _baseInfoModel.isHasSizeItem && _baseInfoModel.isHasColorItem) {
        [self updateSizeTipViewWithArray:_baseInfoModel.size_info itemModel:itemModel];
        self.sizeOptionLabel.text = itemModel.value;
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //点击了color（图片）
    if (collectionView.tag == KPicListCollectionTag) {
        STLPicListCell *picCell = (STLPicListCell *)[collectionView cellForItemAtIndexPath:indexPath];
        //UIImage *img = [picCell getImgOfCell];
        [self actionTapGoodsImageCell:picCell withIndex:indexPath];
        return;
    }
    
    OSSColorSizeCell *cell = (OSSColorSizeCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell.isSelected) {
        return;
    }

    OSSVSpecsModel *specsModel = nil;
    
    if (collectionView.tag == KColorItemCollTag) {
        specsModel = _baseInfoModel.GoodsSpecs.firstObject;
        OSSVAttributeItemModel *itemModel = specsModel.brothers[indexPath.item];
        /*GA埋点-----点击颜色的埋点事件*/
        NSDictionary *analyDic = @{@"screen_group" : [NSString stringWithFormat:@"%@%@",STLToString(self.screenGroup), STLToString(self.baseInfoModel.goodsTitle)],
                                   @"color"        : STLToString(itemModel.value)};
        
        [OSSVAnalyticsTool analyticsGAEventWithName:@"select_ProductColor" parameters:analyDic];
    }else if(collectionView.tag == KSizeItemCollTag){
        specsModel = _baseInfoModel.GoodsSpecs.lastObject;
        OSSVAttributeItemModel *itemModel = specsModel.brothers[indexPath.item];
        /*GA埋点-----点击尺码的埋点事件*/
        NSDictionary *analyDic = @{@"screen_group" : [NSString stringWithFormat:@"%@%@", STLToString(self.screenGroup), STLToString(self.baseInfoModel.goodsTitle)],
                                   @"size"        : STLToString(itemModel.value)};

        [OSSVAnalyticsTool analyticsGAEventWithName:@"select_ProductSize" parameters:analyDic];

    }
    OSSVAttributeItemModel *attriItemModel = specsModel.brothers[indexPath.item];

    if (attriItemModel.disabled) {
        STLLog(@"(goodsId:%@)此商品无库存或下架了",attriItemModel.goods_id);
        return;

    } else if(attriItemModel.checked && !specsModel.hasSelectSpecs) {
        specsModel.hasSelectSpecs = YES;
        [self filterCurrentGoodsID:indexPath.item SpecModel:specsModel];

     } else if (attriItemModel.checked) {
        if ([specsModel.spec_type integerValue] == 2 && !self.hadManualSelectSize) {
            specsModel.hasSelectSpecs = YES;
            [self filterCurrentGoodsID:indexPath.item SpecModel:specsModel];
            
            return;
        }
        STLLog(@"(goodsId:%@)此商品已是选中状态",attriItemModel.goods_id);
        return;
    } else {
        if (collectionView.tag == KColorItemCollTag) {
            self.colorGroup_id = attriItemModel.group_goods_id;
        }else if(collectionView.tag == KSizeItemCollTag){
            self.sizeGroup_id = attriItemModel.group_goods_id;
        }
        [self filterCurrentGoodsID:indexPath.item SpecModel:specsModel];
    }
}


- (BOOL)isContainIds:(NSArray *)sourceGoodIds findGoodIds:(NSArray *)goodIds {
    
    __block BOOL flag = NO;
    [sourceGoodIds enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [goodIds enumerateObjectsUsingBlock:^(id  _Nonnull tempObj, NSUInteger tempIdx, BOOL * _Nonnull tempStop) {
            if ([obj isEqualToString:tempObj]) {
                flag = YES;
                *tempStop = YES;
            }
        }];
        
        if (flag) {
            *stop = YES;
        }
    }];
    
    return flag;
}


- (void)filterCurrentGoodsID:(NSInteger)row SpecModel:(OSSVSpecsModel *)specModel{
    
    OSSVSpecsModel *specsModel = specModel;
    OSSVAttributeItemModel *attriItemModel = specsModel.brothers[row];
    
    
    NSArray *starSet = nil;
    if ([specsModel.spec_type integerValue] == 1) {
        starSet = [self interArrayWithArray:attriItemModel.group_goods_id other:self.sizeGroup_id];
    }else if([specsModel.spec_type integerValue] == 2){
        starSet = [self interArrayWithArray:attriItemModel.group_goods_id other:self.colorGroup_id];
    }
    
    if (starSet.count > 0) {
        
        if (self.dataArray.count == 1 && !self.hadManualSelectSize) {
            self.hadManualSelectSize = YES;
            if (self.attributeHadManualSelectSizeBlock) {
                self.attributeHadManualSelectSizeBlock();
            }
        } else if([specsModel.spec_type integerValue] == 2 && !self.hadManualSelectSize) {
            self.hadManualSelectSize = YES;
            if (self.attributeHadManualSelectSizeBlock) {
                self.attributeHadManualSelectSizeBlock();
            }
        }
        
//        self.goodsId = [NSString stringWithFormat:@"%@",starSet.allObjects.firstObject];
        self.goodsId = [NSString stringWithFormat:@"%@",starSet.firstObject];
        self.wid = attriItemModel.wid;
        @weakify(self)
        if (self.attributeNewBlock) {
            @strongify(self)
            self.attributeNewBlock([NSString stringWithFormat:@"%@",self.goodsId],attriItemModel.wid, self.specialId);
        }
    }else{
        @weakify(self)
        if (self.attributeNewBlock) {
            @strongify(self)
            self.attributeNewBlock([NSString stringWithFormat:@"%@",attriItemModel.goods_id],attriItemModel.wid, self.specialId);
        }
    }
    
    if ([specModel.spec_type integerValue] == 1) {
        self.lastSelectSection = 0;
    }else if([specModel.spec_type integerValue] == 2){
        self.lastSelectSection = 1;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    if (section == 0) {
//        return UIEdgeInsetsMake(0, 0, 0, 0);
//    }

    return UIEdgeInsetsMake(0, 0, 0, 0);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == KPicListCollectionTag) {
        if (APP_TYPE == 3) {
            return CGSizeMake(120, 120);
        }
        OSSVDetailPictureArrayModel *picModel = _baseInfoModel.pictureListArray.firstObject;
        if ([picModel.img_height integerValue] == 0 || [picModel.img_width integerValue] == 0) {
            return CGSizeMake(150, 200);
        }
        CGFloat bili = [picModel.img_width floatValue]/[picModel.img_height floatValue];
        return CGSizeMake(200 *bili, 200);
    }
    

    CGSize itemSize = CGSizeZero;
    OSSVSpecsModel *specModel = nil;
    
    if (collectionView.tag == KColorItemCollTag) {
        specModel = _baseInfoModel.GoodsSpecs.firstObject;
    }else if(collectionView.tag == KSizeItemCollTag){
       specModel = _baseInfoModel.GoodsSpecs.lastObject;
    }
    OSSVAttributeItemModel *itemModel = specModel.brothers[indexPath.item];
    
    if ([specModel.spec_type integerValue] == 1) {
        //颜色
        itemSize = CGSizeMake(36, 48);
    }else if([specModel.spec_type integerValue] == 2){
        // 尺码
        CGFloat width = [self getLabStringWidthWithText:itemModel.value];
        return CGSizeMake(width, 36);
    }
    
    return itemSize;
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
                
                NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
                paragraphStyle.lineSpacing = 2;
                
                NSAttributedString *attName = [[NSAttributedString alloc] initWithString:name attributes:@{NSFontAttributeName:FontWithSize(12), NSForegroundColorAttributeName:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1], NSParagraphStyleAttributeName:paragraphStyle}];
                NSAttributedString *attValue = [[NSAttributedString alloc] initWithString:value attributes:@{NSFontAttributeName:FontWithSize(12), NSForegroundColorAttributeName:OSSVThemesColors.col_0D0D0D, NSParagraphStyleAttributeName:paragraphStyle}];
                [mAttr appendAttributedString:attName];
                [mAttr appendAttributedString:attValue];
            }
            // 文字的高度
            _sizeTipLabel.attributedText = mAttr;
            NSString *str = mAttr.string;
            NSRange range = NSMakeRange(0, mAttr.length);
            NSDictionary *dic = [mAttr attributesAtIndex:0 effectiveRange:&range];
            CGSize sizeToFit = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
            if (self.sizeTipLabel.bounds.size.width > 0) {
                CGFloat num = sizeToFit.width/self.sizeTipLabel.bounds.size.width + 1;
                CGFloat height = sizeToFit.height*num + 10;
                [self.sizeTipView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(height);
                }];
            }
            
            
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                _sizeTipLabel.textAlignment = NSTextAlignmentRight;
            } else {
                _sizeTipLabel.textAlignment = NSTextAlignmentLeft;
            }
        }else{
            [self.sizeTipView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
        }
    }else{
        [self.sizeTipView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
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

// 计算文字宽度
- (CGFloat)getLabStringWidthWithText:(NSString *)text{
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    CGFloat width = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)  options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.width;
    
    width = MAX(width + 14, 36);
    return width;
}

#pragma mark ---what's My Size 尺码表
- (void)sizeChatAction:(UIButton *)sender{
    [GATools logGoodsDetailSimpleEventWithEventName:@"size_guide"
                                        screenGroup:[NSString stringWithFormat:@"%@%@", self.screenGroup, STLToString(self.baseInfoModel.goodsTitle)]
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

#pragma mark - LazyLoad
- (NSMutableDictionary *)analyticsDic {
    if (!_analyticsDic) {
        _analyticsDic = [[NSMutableDictionary alloc] init];
    }
    return _analyticsDic;
}

- (NSMutableDictionary *)gaAnalyticsDic {
    if (!_gaAnalyticsDic) {
        _gaAnalyticsDic = [[NSMutableDictionary alloc] init];
    }
    return _gaAnalyticsDic;
}
- (OSSVDetailsViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVDetailsViewModel alloc] init];
    }
    return _viewModel;
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
//        _sheetView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - (100)*DSCREEN_HEIGHT_SCALE);
        [_sheetView setBackgroundColor:[OSSVThemesColors stlWhiteColor]];
        _sheetView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - (APP_TYPE == 3 ? 160 : 100)*DSCREEN_HEIGHT_SCALE);
    }
    return _sheetView;
}


- (UIScrollView *)sheetBgView{
    if (!_sheetBgView) {
        _sheetBgView = [[UIScrollView alloc] init];
        _sheetBgView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - (APP_TYPE == 3 ? 160 : 100)*DSCREEN_HEIGHT_SCALE);
        [_sheetBgView setBackgroundColor:[OSSVThemesColors stlWhiteColor]];
        _sheetBgView.showsVerticalScrollIndicator = NO;
        _sheetBgView.showsHorizontalScrollIndicator = NO;
        _sheetBgView.layer.cornerRadius = APP_TYPE == 3 ? 0 : 6;
    }
    return _sheetBgView;
}

- (UIView *)colorView{
    if (!_colorView) {
        _colorView = [[UIView alloc] init];
        [_colorView setBackgroundColor:[OSSVThemesColors stlWhiteColor]];
    }
    return _colorView;
}

- (UIView *)sizeView{
    if (!_sizeView) {
        _sizeView = [[UIView alloc] init];
        [_sizeView setBackgroundColor:[OSSVThemesColors stlWhiteColor]];
    }
    return _sizeView;
}



- (QuantityCell *)quanityCell{
    if (!_quanityCell) {
        _quanityCell = [[QuantityCell alloc] init];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _quanityCell.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
    }
    return _quanityCell;
}


- (UICollectionView *)goodsImageView {
    if (!_goodsImageView) {
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.itemSize = APP_TYPE == 3 ?  CGSizeMake(120, 120) : CGSizeMake(150, 200);
        flowLayout.minimumInteritemSpacing = APP_TYPE == 3 ? 4 : 8.0;
        flowLayout.minimumLineSpacing = APP_TYPE == 3 ? 4 : 8.0;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _goodsImageView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _goodsImageView.tag = KPicListCollectionTag;
        _goodsImageView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _goodsImageView.delegate = self;
        _goodsImageView.dataSource = self;
        _goodsImageView.showsVerticalScrollIndicator = NO;
        _goodsImageView.showsHorizontalScrollIndicator = NO;
        _goodsImageView.contentInset = UIEdgeInsetsMake(0, 12, 0, 12);
    }
    return _goodsImageView;
}

- (UIButton *)dismissButton {
    if (!_dismissButton) {
        _dismissButton = [UIButton new];
        [_dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [_dismissButton setImage:[UIImage imageNamed:@"detail_close_black_zhijiao"] forState:UIControlStateNormal];
    }
    return _dismissButton;
}

- (UILabel *)goodsPriceLabel {
    if (!_goodsPriceLabel) {
        _goodsPriceLabel = [UILabel new];
        _goodsPriceLabel.font = [UIFont boldSystemFontOfSize:16];
        if (APP_TYPE == 3) {
            _goodsPriceLabel.font = [UIFont vivaiaRegularFont:20];
            _goodsPriceLabel.textColor = [OSSVThemesColors col_000000:0.8];
        }
    }
    return _goodsPriceLabel;
}

- (STLCLineLabel *)grayPrice {
    if (!_grayPrice) {
        _grayPrice = [[STLCLineLabel alloc] init];
        _grayPrice.textColor = OSSVThemesColors.col_6C6C6C;
        _grayPrice.font = [UIFont systemFontOfSize:10];
    }
    return _grayPrice;
}

- (UILabel *)goodsTitleLabel {
    if (!_goodsTitleLabel) {
        _goodsTitleLabel = [UILabel new];
        _goodsTitleLabel.textColor = OSSVThemesColors.col_6C6C6C;
        _goodsTitleLabel.numberOfLines = 2;
        _goodsTitleLabel.font = [UIFont systemFontOfSize:12];
        if (APP_TYPE == 3) {
            _goodsTitleLabel.font = [UIFont vivaiaRegularFont:20];
            _goodsTitleLabel.textColor = [OSSVThemesColors col_000000:1.0];
        }
    }
    return _goodsTitleLabel;
}

- (UIView *)lineFirst {
    if (!_lineFirst) {
        _lineFirst = [UIView new];
        _lineFirst.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _lineFirst;
}

- (UIStackView *)bottomView {
    if (!_bottomView) {
        UIStackView *stackView = [UIStackView new];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        stackView.alignment = UIStackViewAlignmentTop;
        stackView.distribution = UIStackViewDistributionFill;
        stackView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _bottomView = stackView;
        _bottomView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _bottomView;
}


- (UIButton *)addToCartButton {
    if (!_addToCartButton) {
        _addToCartButton = [UIButton new];
        _addToCartButton.tag = GoodsDetailEnumTypeAdd;
        [_addToCartButton addTarget:self action:@selector(addToBagAction:) forControlEvents:UIControlEventTouchUpInside];
//        _addToCartButton.backgroundColor = [OSSVThemesColors col_262626];
        if (APP_TYPE == 3) {
            [_addToCartButton setTitle:STLLocalizedString_(@"addToBag",nil) forState:UIControlStateNormal];

        } else {
            [_addToCartButton setTitle:[STLLocalizedString_(@"addToBag",nil) uppercaseString] forState:UIControlStateNormal];
        }
        _addToCartButton.titleLabel.font = [UIFont stl_buttonFont: APP_TYPE == 3 ? 18 : 14];
        [_addToCartButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
//        _addToCartButton.userInteractionEnabled = NO;
        _addToCartButton.layer.cornerRadius = 2.0;
        _addToCartButton.layer.masksToBounds = YES;
        _addToCartButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
    }
    return _addToCartButton;
}

- (EmitterButton *)collectButton {
    if (!_collectButton) {
        _collectButton = [EmitterButton buttonWithType:UIButtonTypeCustom];
        [_collectButton setImage:[UIImage imageNamed:@"actionSheet_like_unselected"] forState:UIControlStateNormal];
        _collectButton.backgroundColor = [UIColor clearColor];
        [_collectButton addTarget:self action:@selector(actionCollection:) forControlEvents:UIControlEventTouchDown];
    }
    return _collectButton;
}

- (UIView *)lineSecond {
    if (!_lineSecond) {
        _lineSecond = [UIView new];
        _lineSecond.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineSecond;
}


- (UICollectionView *)colorColl{
    if (!_colorColl) {
        UICollectionViewFlowLayout *colorLayout = [[UICollectionViewFlowLayout alloc] init];
        colorLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _colorColl = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:colorLayout];
        _colorColl.backgroundColor = OSSVThemesColors.col_FFFFFF;
        [_colorColl registerClass:[OSSColorSizeCell class] forCellWithReuseIdentifier:@"colorSheetCell"];
        _colorColl.delegate = self;
        _colorColl.dataSource = self;
        _colorColl.showsVerticalScrollIndicator = NO;
        _colorColl.showsHorizontalScrollIndicator = NO;
        _colorColl.tag = KColorItemCollTag;
    }
    return _colorColl;
}

- (UICollectionView *)sizeColl{
    if (!_sizeColl) {
        UICollectionViewFlowLayout *sizeLayout = [[UICollectionViewFlowLayout alloc] init];
        sizeLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _sizeColl = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:sizeLayout];
        _sizeColl.backgroundColor = OSSVThemesColors.col_FFFFFF;
        [_sizeColl registerClass:[OSSColorSizeCell class] forCellWithReuseIdentifier:@"sizeSheetCell"];
        _sizeColl.delegate = self;
        _sizeColl.dataSource = self;
        _sizeColl.showsVerticalScrollIndicator = NO;
        _sizeColl.showsHorizontalScrollIndicator = NO;
        _sizeColl.tag = KSizeItemCollTag;
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _sizeColl.transform = CGAffineTransformMakeScale(-1.0, 1.0);
            _sizeColl.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
        }
    }
    return _sizeColl;
}

- (UILabel *)colorLabel {
    if (!_colorLabel) {
        _colorLabel = [UILabel new];
        _colorLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _colorLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _colorLabel;
}
- (UILabel *)colorOptionLabel {
    if (!_colorOptionLabel) {
        _colorOptionLabel = [UILabel new];
        _colorOptionLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _colorOptionLabel.font = FontWithSize(14);
    }
    return _colorOptionLabel;
}
- (UILabel *)sizeLabel {
    if (!_sizeLabel) {
        _sizeLabel = [UILabel new];
        _sizeLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _sizeLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    return _sizeLabel;
}
- (UILabel *)sizeOptionLabel {
    if (!_sizeOptionLabel) {
        _sizeOptionLabel = [UILabel new];
        _sizeOptionLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _sizeOptionLabel.font = FontWithSize(14);
    }
    return _sizeOptionLabel;
}

- (UIButton *)sizeEventBtn {
    if (!_sizeEventBtn) {
        _sizeEventBtn = [UIButton new];
        [_sizeEventBtn addTarget:self action:@selector(sizeChatAction:) forControlEvents:UIControlEventTouchUpInside];
        [_sizeEventBtn setImage:[UIImage imageNamed:@"detail_size"] forState:UIControlStateNormal];
        _sizeEventBtn.tintColor = OSSVThemesColors.col_B62B21;
        _sizeEventBtn.titleLabel.font = FontWithSize(12);
        [_sizeEventBtn setTitleColor:OSSVThemesColors.col_0D0D0D forState:UIControlStateNormal];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_sizeEventBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 4, 0, -4)];
        }else{
            [_sizeEventBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -4, 0, 4)];
        }
        
    }
    return _sizeEventBtn;
}

- (UIView *)sizeTipView{
    if (!_sizeTipView) {
        _sizeTipView = [UIView new];
        _sizeTipView.backgroundColor = OSSVThemesColors.col_F8F8F8;
    }
    return _sizeTipView;
}

- (UILabel *)sizeTipLabel {
    if (!_sizeTipLabel) {
        _sizeTipLabel = [UILabel new];
        _sizeTipLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _sizeTipLabel.font = FontWithSize(12);
        _sizeTipLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _sizeTipLabel.numberOfLines = 0;
        
    }
    return _sizeTipLabel;
}

- (YYAnimatedImageView *)cartAnimationView {
    if (!_cartAnimationView) {
        _cartAnimationView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _cartAnimationView.backgroundColor = STLCOLOR_RANDOM;
    }
    return _cartAnimationView;
}

- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleNormal];
//        _activityStateView.samllImageShow = 12;
//        _activityStateView.fontSize = 9;
//        _activityStateView.flashImageSize = 12;
        _activityStateView.hidden = YES;
    }
    return _activityStateView;
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

- (UILabel *)detablLabel {
    if (!_detablLabel) {
        _detablLabel = [[UILabel alloc] init];
        _detablLabel.textColor = OSSVThemesColors.col_6C6C6C;
        _detablLabel.font = [UIFont systemFontOfSize:12];
        
        _detablLabel.text = STLLocalizedString_(@"AttributeSheetDetail", nil);
//        _detablLabel.hidden = YES;
        if (APP_TYPE == 3) {
            _detablLabel.textColor = [OSSVThemesColors col_000000:0.5];
            UIView *underLine = [UIView new];
            underLine.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"spic_dash_line_black"]];
            [_detablLabel addSubview:underLine];
            [underLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(0);
                make.bottom.equalTo(0);
                make.height.equalTo(1);
            }];
        }
    }
    return _detablLabel;
}

- (UIImageView *)detailArrowImageView {
    if (!_detailArrowImageView) {
        _detailArrowImageView = [[UIImageView alloc]init];
        if (APP_TYPE != 3) {
            _detailArrowImageView.image = [UIImage imageNamed:@"goods_arrow"];
        }
//        _detailArrowImageView.hidden = YES;
        [_detailArrowImageView convertUIWithARLanguage];
    }
    return _detailArrowImageView;
}

- (UIButton *)eventBtn {
    if (!_eventBtn) {
        _eventBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eventBtn addTarget:self action:@selector(eventBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        _eventBtn.hidden = YES;
    }
    return _eventBtn;
}

@end

