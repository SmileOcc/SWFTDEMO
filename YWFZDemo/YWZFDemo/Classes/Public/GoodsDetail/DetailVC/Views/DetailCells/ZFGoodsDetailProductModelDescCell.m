//
//  ZFGoodsDetailProductModelDescCell.m
//  ZZZZZ
//
//  Created by YW on 2019/11/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailProductModelDescCell.h"
#import "ZFLocalizationString.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFInitViewProtocol.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "Masonry.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "Constants.h"
#import "YWCFunctionTool.h"
#import "GoodsDetailModel.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYWebImage/UIImage+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "SystemConfigUtils.h"
#import "NSString+Extended.h"

@interface ZFGoodsDetailProductModelDescCell ()
@property (nonatomic, strong) UIButton      *leftMenuButton;
@property (nonatomic, strong) UIView        *leftBgView;
@property (nonatomic, strong) UILabel       *productDescLabel;
@property (nonatomic, strong) UIButton      *showMoreDescButton;

@property (nonatomic, strong) UIButton      *rightMenuButton;
@property (nonatomic, strong) UIView        *rightBgView;
@property (nonatomic, strong) UIImageView   *modelImageView;
@property (nonatomic, strong) UILabel       *modelNameLabel;
@property (nonatomic, strong) UILabel       *modelWearLabel;
@property (nonatomic, strong) UILabel       *modelInfoLeftLabel;
@property (nonatomic, strong) UILabel       *modelInfoRightLabel;

@property (nonatomic, strong) UIView        *menuUnderLine;
@property (nonatomic, strong) UIView        *bottomLineView;
@end

@implementation ZFGoodsDetailProductModelDescCell

@synthesize cellTypeModel = _cellTypeModel;


#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - setter

- (void)setCellTypeModel:(ZFGoodsDetailCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;
    
    self.showMoreDescButton.selected = cellTypeModel.detailModel.goods_model_data.selectedShowMoreFlag;
    self.productDescLabel.numberOfLines = self.showMoreDescButton.selected ? 0 : 3;
    
    BOOL isEmptyModelData = cellTypeModel.detailModel.goods_model_data.isEmptyModelData;
    self.rightMenuButton.hidden = isEmptyModelData;
    self.menuUnderLine.hidden = isEmptyModelData;
    
    // 选择Menu线
    [self convertSelectUnderLine:cellTypeModel.detailModel.goods_model_data.selectedMenuType];
    
    /// 1.更新产品描述信息
    self.productDescLabel.attributedText = nil;
    self.productDescLabel.text = nil;
    
    NSAttributedString *descAttriText = cellTypeModel.detailModel.goods_model_data.goodsDescAttriText;
    if ([descAttriText isKindOfClass:[NSAttributedString class]]) {
        self.productDescLabel.attributedText = descAttriText;
    } else {
        self.productDescLabel.text = ZFToString(cellTypeModel.detailModel.goods_desc_data);
    }
    
    /// 2.更新模特信息
    NSString *url = cellTypeModel.detailModel.goods_model_data.model_pic;
    [self.modelImageView yy_setImageWithURL:[NSURL URLWithString:url]
                                placeholder:[UIImage imageNamed:@"public_user_small"]
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:nil
                                  transform:nil
                                 completion:nil];

    self.modelNameLabel.text = ZFToString(cellTypeModel.detailModel.goods_model_data.model_name);
    [self showAttriStringToLabel:self.modelWearLabel kitType:0];
    [self showAttriStringToLabel:self.modelInfoLeftLabel kitType:1];
    [self showAttriStringToLabel:self.modelInfoRightLabel kitType:2];
}

- (void)showAttriStringToLabel:(UILabel *)label kitType:(NSInteger)kitType {
    NSMutableArray *textArray = [NSMutableArray array];
    NSMutableArray *fontArray = [NSMutableArray array];
    NSMutableArray *colorArray = [NSMutableArray array];
    
    NSArray *modelArray = self.cellTypeModel.detailModel.goods_model_data.list;
    for (NSInteger i=0; i<modelArray.count; i++) {
        
        GoodsDetailsModelInfo *infoModel = nil;
        if (kitType == 0) { //0: (数组中第一个表示Model Wear,单独显示一行)
            infoModel = modelArray[i];
            
        } else if (kitType == 1) { //左边的控件(i==奇数)
            if (i % 2 > 0) {
                infoModel = modelArray[i];
            } else {
                continue;
            }
        } else if (kitType == 2) { //右边的控件(i!= 0 && i==偶数)            
            if (i == 0 || i % 2 > 0) {
                continue;
            } else {
                infoModel = modelArray[i];
            }
        }
        if (!infoModel) continue;
        NSString *key = [NSString stringWithFormat:@"%@: ", ZFToString(infoModel.name)];
        NSString *value = [NSString stringWithFormat:@"%@\n", ZFToString(infoModel.value)];
        if (kitType == 0) { //Model Wear不换行
            value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        }
        
        [textArray addObjectsFromArray:@[key, value]];
        [colorArray addObjectsFromArray:@[ZFCOLOR(45, 45, 45, 1), ZFCOLOR(153, 153, 153, 1)]];
        [fontArray addObjectsFromArray:@[ZFFontSystemSize(12), ZFFontSystemSize(12)]];
        
        if (kitType == 0)break;
    }
    
    if (textArray.count==0) return;
    label.attributedText = [NSString getAttriStrByTextArray:textArray
                                                    fontArr:fontArray
                                                   colorArr:colorArray
                                                lineSpacing:5
                                                  alignment:0];
}

- (void)convertSelectUnderLine:(ZFGoodsDetailProductDescCellActionType)selectedType {
    if (selectedType < 2019) return;
    self.leftBgView.hidden = (selectedType == ZFDetailVCCellAction_ModelStatsType);
    self.rightBgView.hidden = (selectedType == ZFDetailVCCellAction_ProductDescType);
    
    UIView *tmpView = self.rightBgView.hidden ? self.leftMenuButton : self.rightMenuButton;
    [self.menuUnderLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.leftMenuButton.mas_bottom);
        make.leading.mas_equalTo(tmpView.mas_leading);
        make.trailing.mas_equalTo(tmpView.mas_trailing);
        make.height.mas_equalTo(2);
    }];
}

#pragma mark - <MenuButtonAction>

- (void)menuButtonAction:(UIButton *)menuButton {
    if (menuButton.tag < 2019) return;
    
    BOOL isShowMoreLessType = (menuButton.tag == ZFDetailVCCellAction_ShowMoreLessType);
    if (!isShowMoreLessType) {
        self.cellTypeModel.detailModel.goods_model_data.selectedMenuType = menuButton.tag;
    }
    if (menuButton.tag == ZFDetailVCCellAction_ProductDescType || isShowMoreLessType) {
        if (isShowMoreLessType) {
            self.showMoreDescButton.selected = !self.showMoreDescButton.selected; //选中=展开
        }
        //mcalculate cell height
        CGFloat textH = self.cellTypeModel.detailModel.goods_model_data.contentViewHeight;
        CGFloat addpdingH = (self.showMoreDescButton.selected ? textH : MIN(63, textH));
        
        //default tool height=105;
        self.cellTypeModel.detailModel.goods_model_data.cellHeight = 105 + addpdingH;
        self.cellTypeModel.detailModel.goods_model_data.selectedShowMoreFlag = self.showMoreDescButton.selected;
    } else {
        //model stats fixed height
        self.cellTypeModel.detailModel.goods_model_data.cellHeight = 188;
    }
    if (self.cellTypeModel.detailCellActionBlock) {
        self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, nil, nil);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    
    [self.contentView addSubview:self.leftMenuButton];
    [self.contentView addSubview:self.leftBgView];
    [self.leftBgView addSubview:self.productDescLabel];
    [self.leftBgView addSubview:self.showMoreDescButton];
    
    [self.contentView addSubview:self.rightMenuButton];
    [self.contentView addSubview:self.rightBgView];
    [self.rightBgView addSubview:self.modelImageView];
    [self.rightBgView addSubview:self.modelNameLabel];
    [self.rightBgView addSubview:self.modelWearLabel];
    [self.rightBgView addSubview:self.modelInfoLeftLabel];
    [self.rightBgView addSubview:self.modelInfoRightLabel];
    
    [self.contentView addSubview:self.menuUnderLine];
    [self.contentView addSubview:self.bottomLineView];
}

- (void)zfAutoLayoutView {
    [self.leftMenuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.height.mas_equalTo(40);
    }];
    
    [self.menuUnderLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.leftMenuButton.mas_bottom);
        make.leading.mas_equalTo(self.leftMenuButton.mas_leading);
        make.trailing.mas_equalTo(self.leftMenuButton.mas_trailing);
        make.height.mas_equalTo(2);
    }];
    
//================================================================================
    
    [self.leftBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.menuUnderLine.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.productDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self.leftBgView);
        make.height.mas_greaterThanOrEqualTo(63);//mas_lessThanOrEqualTo
    }];
    
    [self.showMoreDescButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.productDescLabel.mas_bottom);
        make.leading.mas_equalTo(self.leftBgView.mas_leading);
        make.width.mas_equalTo(self.leftBgView.mas_width);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.leftBgView.mas_bottom);
    }];
    
//================================================================================
    
    [self.rightMenuButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.leftMenuButton.mas_top);
        make.leading.mas_equalTo(self.leftMenuButton.mas_trailing).offset(16);
        make.height.mas_equalTo(40);
    }];
    
    [self.rightBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.menuUnderLine.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.modelImageView.mas_bottom).offset(16);
    }];
    
    [self.modelImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.rightBgView.mas_top);
        make.leading.mas_equalTo(self.rightBgView.mas_leading);
        make.size.mas_equalTo(CGSizeMake(90, 90));
    }];
    
    [self.modelNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.modelImageView.mas_bottom).offset(6);
        make.centerX.mas_equalTo(self.modelImageView.mas_centerX);
        make.width.mas_equalTo(self.modelImageView.mas_width);
    }];
    
    [self.modelWearLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.modelImageView.mas_trailing).offset(8);
        make.top.mas_equalTo(self.modelImageView.mas_top);
        make.trailing.mas_equalTo(self.rightBgView.mas_trailing).offset(-16);
    }];
    
    [self.modelInfoLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.modelWearLabel.mas_leading);
        make.top.mas_equalTo(self.modelWearLabel.mas_bottom).offset(14);
        make.width.mas_equalTo((KScreenWidth - (90+19+8))/2);
    }];
    
    [self.modelInfoRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.modelInfoLeftLabel.mas_trailing);
        make.top.mas_equalTo(self.modelWearLabel.mas_bottom).offset(14);
        make.trailing.mas_equalTo(self.rightBgView.mas_trailing).offset(-16);
    }];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(9);
    }];
}

#pragma mark - getter

- (UIButton *)leftMenuButton {
    if (!_leftMenuButton) {
        _leftMenuButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _leftMenuButton.titleLabel.backgroundColor = [UIColor whiteColor];
        _leftMenuButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_leftMenuButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:0];
        [_leftMenuButton setTitle:ZFLocalizedString(@"Detail_Product_Description", nil) forState:0];
        [_leftMenuButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        _leftMenuButton.tag = ZFDetailVCCellAction_ProductDescType;
    }
    return _leftMenuButton;
}

- (UIView *)menuUnderLine {
    if (!_menuUnderLine) {
        _menuUnderLine = [[UIView alloc] initWithFrame:CGRectZero];
        _menuUnderLine.backgroundColor = ZFCOLOR(45, 45, 45, 1);
    }
    return _menuUnderLine;
}

- (UIView *)leftBgView {
    if (!_leftBgView) {
        _leftBgView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _leftBgView;
}

- (UILabel *)productDescLabel {
    if (!_productDescLabel) {
        _productDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productDescLabel.backgroundColor = [UIColor whiteColor];
        _productDescLabel.numberOfLines = 3;
        _productDescLabel.textColor = ZFC0x2D2D2D();
        _productDescLabel.font = [UIFont systemFontOfSize:14];
        _productDescLabel.preferredMaxLayoutWidth = KScreenWidth - 16 *2;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _productDescLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _productDescLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _productDescLabel;
}

- (UIButton *)showMoreDescButton {
    if (!_showMoreDescButton) {
        _showMoreDescButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _showMoreDescButton.titleLabel.backgroundColor = [UIColor whiteColor];
        [_showMoreDescButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:0];
        
        UIImage *normalImage = [UIImage imageNamed:@"category_filter_arrow_down"];;
        UIImage *selectedImage = [UIImage imageNamed:@"category_filter_arrow_up"];
        [_showMoreDescButton setImage:normalImage forState:UIControlStateNormal];
        [_showMoreDescButton setImage:selectedImage forState:UIControlStateSelected];
        [_showMoreDescButton setTitle:ZFLocalizedString(@"Search_Tool_Morel", nil) forState:0];
        
        _showMoreDescButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_showMoreDescButton zfLayoutStyle:(ZFButtonEdgeInsetsStyleRight)
                           imageTitleSpace:2];
        [_showMoreDescButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        _showMoreDescButton.tag = ZFDetailVCCellAction_ShowMoreLessType;
        _showMoreDescButton.selected = NO; //默认不选中=不展开
    }
    return _showMoreDescButton;
}

- (UIButton *)rightMenuButton {
    if (!_rightMenuButton) {
        _rightMenuButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _rightMenuButton.titleLabel.backgroundColor = [UIColor whiteColor];
        _rightMenuButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_rightMenuButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:0];
        [_rightMenuButton setTitle:ZFLocalizedString(@"Detail_Product_ModelStats", nil) forState:0];
        [_rightMenuButton addTarget:self action:@selector(menuButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
        _rightMenuButton.tag = ZFDetailVCCellAction_ModelStatsType;
        _rightMenuButton.hidden = YES;
    }
    return _rightMenuButton;
}

- (UIView *)rightBgView {
    if (!_rightBgView) {
        _rightBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _rightBgView.hidden = YES;
    }
    return _rightBgView;
}

- (UIImageView *)modelImageView {
    if (!_modelImageView) {
        _modelImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _modelImageView.contentMode = UIViewContentModeScaleAspectFill;
        _modelImageView.clipsToBounds = YES;
    }
    return _modelImageView;
}

 - (UILabel *)modelNameLabel {
     if (!_modelNameLabel) {
         _modelNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
         _modelNameLabel.backgroundColor = [UIColor whiteColor];
         _modelNameLabel.numberOfLines = 0;
         _modelNameLabel.textAlignment = NSTextAlignmentCenter;
         _modelNameLabel.font = [UIFont systemFontOfSize:14];
         _modelNameLabel.textColor = ZFCOLOR(45, 45, 45, 1) ;
     }
     return _modelNameLabel;
 }

 - (UILabel *)modelWearLabel {
    if (!_modelWearLabel) {
        _modelWearLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _modelWearLabel.backgroundColor = [UIColor whiteColor];
        _modelWearLabel.numberOfLines = 0;
        _modelWearLabel.font = [UIFont systemFontOfSize:14];
        _modelWearLabel.textColor = ZFCOLOR(45, 45, 45, 1);
    }
    return _modelWearLabel;
}

- (UILabel *)modelInfoLeftLabel {
    if (!_modelInfoLeftLabel) {
        _modelInfoLeftLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _modelInfoLeftLabel.backgroundColor = [UIColor whiteColor];
        _modelInfoLeftLabel.numberOfLines = 0;
        _modelInfoLeftLabel.font = [UIFont systemFontOfSize:14];
        _modelInfoLeftLabel.textColor = ZFCOLOR(102, 102, 102, 1);
    }
    return _modelInfoLeftLabel;
}


- (UILabel *)modelInfoRightLabel {
    if (!_modelInfoRightLabel) {
        _modelInfoRightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _modelInfoRightLabel.backgroundColor = [UIColor whiteColor];
        _modelInfoRightLabel.numberOfLines = 0;
        _modelInfoRightLabel.font = [UIFont systemFontOfSize:14];
        _modelInfoRightLabel.textColor = ZFCOLOR(102, 102, 102, 1);
    }
    return _modelInfoRightLabel;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = ZFCOLOR_WHITE;//ZFCOLOR(247, 247, 247, 1.f);其他cell底部有灰色分割线
    }
    return _bottomLineView;
}

@end
