//
//  OSSVCartLikeTableCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartLikeTableCell.h"

#import "OSSVDetailsVC.h"

@implementation OSSVCartLikeTableCell

+ (OSSVCartLikeTableCell *)cellCartLikeTableWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [tableView registerClass:[OSSVCartLikeTableCell class] forCellReuseIdentifier:@"OSSVCartLikeTableCell"];
    return [tableView dequeueReusableCellWithIdentifier:@"OSSVCartLikeTableCell" forIndexPath:indexPath];
}

+ (CGFloat)heightCellCartLike {
    return SCREEN_WIDTH / 2.0 * 264 / 188.0;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = OSSVThemesColors.col_FFFFFF;

        [self.contentView addSubview:self.oneItemView];
        [self.contentView addSubview:self.twoItemView];
        
        CGFloat h = [OSSVCartLikeTableCell heightCellCartLike];
        [self.oneItemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(16);
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(16);
            make.trailing.mas_equalTo(self.contentView.mas_centerX).mas_offset(-10);
            make.height.mas_equalTo(h - 16);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
        
        [self.twoItemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_centerX).mas_offset(10);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-16);
            make.top.mas_equalTo(self.oneItemView.mas_top);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
        }];
        
    }
    return self;
}

#pragma mark -

- (void)actionEvent:(LikeItemView *)itemView {
    NSInteger flag = itemView.tag - 400001;
    
    if (_datasArray.count > flag) {
        CartLikeGoodsItemsModel *model = _datasArray[flag];
        
        OSSVDetailsVC *goodsDetailsVC = [OSSVDetailsVC new];
        goodsDetailsVC.goodsId = model.goodsId;
        goodsDetailsVC.wid = model.wid;
        goodsDetailsVC.sourceType = STLAppsflyerGoodsSourceCartRecommend;
        goodsDetailsVC.coverImageUrl = STLToString(model.goodsThumb);
        [self.viewController.navigationController pushViewController:goodsDetailsVC animated:YES];
    }
}


- (void)setDatasArray:(NSArray *)datasArray {
    _datasArray = datasArray;
    
    self.oneItemView.hidden = YES;
    self.twoItemView.hidden = YES;
    
    for (int i=0; i<_datasArray.count; i++) {
        
        CartLikeGoodsItemsModel *model = _datasArray[i];

        LikeItemView *itemView = [self viewWithTag:400001 + i];
        itemView.hidden = NO;
        [itemView.imgView yy_setImageWithURL:[NSURL URLWithString:model.goodsThumb]
                              placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                  options:kNilOptions
                                 progress:nil
                                transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                    return image;
                                }
                               completion:nil];
        
        itemView.priceLabel.text = STLToString(model.shop_price_converted);
    }
}

#pragma mark - LazyLoad

- (LikeItemView *)oneItemView {
    if (!_oneItemView) {
        _oneItemView = [[LikeItemView alloc] initWithFrame:CGRectZero];
        _oneItemView.tag = 400001;
        [_oneItemView addTarget:self action:@selector(actionEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _oneItemView;
}

- (LikeItemView *)twoItemView {
    if (!_twoItemView) {
        _twoItemView = [[LikeItemView alloc] initWithFrame:CGRectZero];
        _twoItemView.tag = 400002;
        [_twoItemView addTarget:self action:@selector(actionEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _twoItemView;
}


@end







//////////////////////////////////////////////

@implementation LikeItemView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = OSSVThemesColors.col_FFFFFF;
        [self addSubview:self.imgView];
        [self addSubview:self.priceLabel];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(self.imgView.mas_width).multipliedBy(216 / 162.0);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self.imgView.mas_bottom).mas_offset(10);
        }];
    }
    return self;
}

- (YYAnimatedImageView *)imgView {
    if (!_imgView) {
        _imgView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        _imgView.layer.masksToBounds = YES;
        //_imgView.backgroundColor = OSSVThemesColors.col_F7F7F7;
    }
    return _imgView;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.textColor = OSSVThemesColors.col_333333;
        _priceLabel.font = [UIFont systemFontOfSize:14];
    }
    return _priceLabel;
}
@end
