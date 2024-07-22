//
//  ZFCommunityShowPostGoodsCell.m
//  ZZZZZ
//
//  Created by YW on 16/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityShowPostGoodsCell.h"
#import "GoodListModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ExchangeManager.h"
#import "BigClickAreaButton.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "UIImage+ZFExtended.h"

@interface ZFCommunityShowPostGoodsCell ()
@property (nonatomic,strong) YYAnimatedImageView *imgView;
@property (nonatomic,strong) UILabel *titleLable;
@property (nonatomic,strong) UILabel *priceLable;
@property (nonatomic,strong) BigClickAreaButton *selectButton;
@end

@implementation ZFCommunityShowPostGoodsCell

+ (ZFCommunityShowPostGoodsCell *)postGoodsCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    
    [tableView registerClass:[ZFCommunityShowPostGoodsCell class] forCellReuseIdentifier:NSStringFromClass([ZFCommunityShowPostGoodsCell class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFCommunityShowPostGoodsCell class]) forIndexPath:indexPath];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _imgView = [[YYAnimatedImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_imgView];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.contentView).offset(10);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(80, 80));
        }];
        
        _selectButton = [[BigClickAreaButton alloc] init];
        _selectButton.clickAreaRadious = 60;
        [_selectButton setImage:[UIImage imageNamed:@"default_no"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"default_ok"] forState:UIControlStateSelected];
        [_selectButton addTarget:self action:@selector(selectGoods:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_selectButton];
        [_selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.contentView).offset(-16);
            make.centerY.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(16, 16));
        }];
        
        _titleLable = [UILabel new];
        _titleLable.textColor = ZFCOLOR(102, 102, 102, 1);
        _titleLable.font = [UIFont systemFontOfSize:14];
        _titleLable.numberOfLines = 2;
        _titleLable.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLable.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_titleLable];
        [_titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imgView.mas_top).offset(2);
            make.leading.equalTo(self.imgView.mas_trailing).offset(8);
            make.trailing.equalTo(self.selectButton.mas_leading).offset(-40);
        }];
        
        _priceLable = [UILabel new];
        _priceLable.textColor = ZFCOLOR(51, 51, 51, 1);
        _priceLable.font = [UIFont boldSystemFontOfSize:18];
        _priceLable.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_priceLable];
        [_priceLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.imgView.mas_bottom).offset(-2);
            make.leading.equalTo(self.imgView.mas_trailing).offset(8);
            make.trailing.equalTo(self.selectButton.mas_leading).offset(-40);
        }];

    }
    return self;
}

- (void)selectGoods:(UIButton *)sender {
    if (self.wishlistSelectBlock) {
        self.wishlistSelectBlock(sender);
    }
}

- (void)setGoodsListModel:(ZFGoodsModel *)goodsListModel {
    _goodsListModel = goodsListModel;
    
    [self.imgView yy_setImageWithURL:[NSURL URLWithString:goodsListModel.wp_image]
                         placeholder:ZFImageWithName(@"community_loading_product")
                             options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                          completion:nil];
    
    self.priceLable.text = [ExchangeManager transforPrice:goodsListModel.shop_price];
    self.titleLable.text = goodsListModel.goods_title;
    self.selectButton.selected = goodsListModel.isSelected;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imgView yy_cancelCurrentImageRequest];
    self.imgView.image = nil;
    self.priceLable.text = nil;
    self.titleLable.text = nil;
    self.selectButton.selected = NO;
}



@end
