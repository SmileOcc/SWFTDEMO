//
//  ZFGEshopSiftListItemCell.m
//  ZZZZZ
//
//  Created by YW on 2019/11/7.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGEshopSiftListItemCell.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "YYText.h"
#import "ZFGeshopSectionModel.h"
#import "BigClickAreaButton.h"
#import "UIImage+ZFExtended.h"
#import "SystemConfigUtils.h"

@interface ZFGEshopSiftListItemCell ()
@property (nonatomic, strong) YYLabel              *titleLabel;
@property (nonatomic, strong) BigClickAreaButton   *arrowImgButton;
@end

@implementation ZFGEshopSiftListItemCell
#pragma mark - Init Method
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configureSubViews];
        [self autoLayoutSubViews];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selecteCurrentSiftItem)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = nil;
    [self.arrowImgButton setImage:nil forState:UIControlStateNormal];
}

#pragma mark - Initialize
- (void)configureSubViews {
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.arrowImgButton];
}

- (void)autoLayoutSubViews {    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView).offset(16);
        make.centerY.equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-60);
    }];
    
    [self.arrowImgButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-20);
    }];
}

#pragma mark - Setter

- (void)setSiftItemModel:(ZFGeshopSiftItemModel *)siftItemModel {
    _siftItemModel = siftItemModel;
    self.titleLabel.text = ZFToString(siftItemModel.item_title);
    
    UIImage *image = nil;
    if (siftItemModel.child_item.count>0) {
        self.titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        image = siftItemModel.hasOpenChild ? [UIImage imageNamed:@"search_list_minus"] : [UIImage imageNamed:@"search_list_plus"];
        
    } else {
        self.titleLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        image = siftItemModel.isCurrentSelected ? [[UIImage imageNamed:@"refine_select"] imageWithColor:ZFC0xFE5269()] : nil;
    }
    [self.arrowImgButton setImage:image forState:UIControlStateNormal];
    
    NSInteger offsetX = MAX(1, siftItemModel.childLevel);
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(16 + offsetX * 10);
    }];
    [self layoutIfNeeded];
}

#pragma mark - Gesture Handle

- (void)selecteCurrentSiftItem {
    if (self.selecteCurrentSiftBlock) {
        self.selecteCurrentSiftBlock(self.siftItemModel);
    }
}

- (void)touchArrowImgAction {
    if (self.touchArrowImgBlock) {
        self.touchArrowImgBlock(self.siftItemModel);
    }
}

#pragma mark - Getter
- (YYLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [YYLabel new];
        BOOL isAr = ([SystemConfigUtils isRightToLeftShow]) ? YES : NO;
        _titleLabel.textAlignment = isAr ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _titleLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
        _titleLabel.numberOfLines = 1;
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _titleLabel.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    }
    return _titleLabel;
}

- (BigClickAreaButton *)arrowImgButton {
    if (!_arrowImgButton) {
        _arrowImgButton = [[BigClickAreaButton alloc] init];
        _arrowImgButton.clickAreaRadious = 60;
        [_arrowImgButton addTarget:self action:@selector(touchArrowImgAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _arrowImgButton;
}

@end