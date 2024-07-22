//
//  ZFCommunityShowPostBagCell.m
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityShowPostBagCell.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "ExchangeManager.h"
#import "BigClickAreaButton.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "UIImage+ZFExtended.h"

@interface ZFCommunityShowPostBagCell ()

@property (nonatomic,strong) YYAnimatedImageView *imgView;
@property (nonatomic,strong) UILabel *titleLable;
@property (nonatomic,strong) UILabel *priceLable;
@property (nonatomic,strong) BigClickAreaButton *selectButton;

@end

@implementation ZFCommunityShowPostBagCell

+ (ZFCommunityShowPostBagCell *)postBagCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    
    [tableView registerClass:[ZFCommunityShowPostBagCell class] forCellReuseIdentifier:NSStringFromClass([ZFCommunityShowPostBagCell class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFCommunityShowPostBagCell class]) forIndexPath:indexPath];
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
        [_selectButton setBackgroundImage:[UIImage imageNamed:@"default_no"] forState:UIControlStateNormal];
         [_selectButton setBackgroundImage:[UIImage imageNamed:@"default_ok"] forState:UIControlStateSelected];
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
    if (self.bagSelectBlock) {
        self.bagSelectBlock(sender);
    }
}

-(void)setGoodListModel:(GoodListModel *)goodListModel {
    _goodListModel = goodListModel;
    
    [self.imgView yy_setImageWithURL:[NSURL URLWithString:goodListModel.goods_img]
                         placeholder:ZFImageWithName(@"index_loading")
                             options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                            progress:nil
                           transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
        //CGFloat height = 80;
        //image = [image yy_imageByResizeToSize:CGSizeMake(height,height * ScreenWidth_SCALE) contentMode:UIViewContentModeScaleAspectFill];
        return image;
    } completion:nil];
    
    if (!goodListModel.is_promote && !goodListModel.is_mobile_price) {
        self.priceLable.text = [ExchangeManager transforPrice:goodListModel.shop_price];
        
    }else{
        NSString *shopPrice = [ExchangeManager transforPrice:goodListModel.shop_price];
        self.priceLable.text = shopPrice;
    }
    
    self.titleLable.text = goodListModel.goods_title;
    
    self.selectButton.selected = goodListModel.isSelected;

}

- (void)prepareForReuse {
    [self.imgView yy_cancelCurrentImageRequest];
    self.imgView.image = nil;
    self.priceLable.text = nil;
    self.titleLable.text = nil;
    self.selectButton.selected = NO;
    [super prepareForReuse];
}

@end
