//
//  CartInfoGoodsCell.m
//  ZZZZZ
//
//  Created by YW on 2017/4/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CartInfoGoodsListCell.h"
#import "CheckOutGoodListModel.h"
#import "ZFMultiAttributeInfoView.h"
#import "ZFLabel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface CartInfoGoodsListCell ()

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) YYAnimatedImageView *goodImg;
@property (nonatomic, strong) UILabel *goodNameLabel;
@property (nonatomic, strong) UIView  *tagView;
@property (nonatomic, strong) UILabel *colorTitleLabel;
@property (nonatomic, strong) UILabel *colorValueLabel;
@property (nonatomic, strong) UILabel *goodsNumLabel;
@property (nonatomic, strong) UILabel *sizeTitleLabel;
@property (nonatomic, strong) UILabel *sizeValueLabel;
@property (nonatomic, strong) ZFMultiAttributeInfoView      *attrView;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *subTotalLabel;

@end

@implementation CartInfoGoodsListCell

+ (CartInfoGoodsListCell *)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[CartInfoGoodsListCell class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor whiteColor];
        
        [self.contentView addSubview:self.lineView];

        self.goodImg = [[YYAnimatedImageView alloc] init];
        self.goodImg.contentMode = UIViewContentModeScaleAspectFill;
        
        [self.contentView addSubview:self.goodImg];
        [self.goodImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.top.mas_equalTo(self.contentView.mas_top).offset(12);
            make.height.mas_equalTo(@(133 * ScreenWidth_SCALE));
            make.width.mas_equalTo(@(100));
        }];
        
        self.goodNameLabel = [[UILabel alloc] init];
        self.goodNameLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        self.goodNameLabel.numberOfLines = 1;
        self.goodNameLabel.font = [UIFont systemFontOfSize:14];
        
        [self.contentView addSubview:self.goodNameLabel];
        [self.goodNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.goodImg.mas_trailing).offset(10);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.top.mas_equalTo(self.goodImg.mas_top);
        }];
        
        [self.contentView addSubview:self.tagView];
        [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.goodNameLabel);
            make.trailing.equalTo(self.contentView).offset(-12);
            make.top.equalTo(self.goodNameLabel.mas_bottom).offset(4);
        }];
        
        self.colorTitleLabel = [[UILabel alloc] init];
        self.colorTitleLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        self.colorTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        [self.contentView addSubview:self.colorTitleLabel];
        [self.colorTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.goodNameLabel);
            make.top.mas_equalTo(self.goodNameLabel.mas_bottom).offset(4);
        }];
        
        self.colorValueLabel = [[UILabel alloc] init];
        self.colorValueLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        self.colorValueLabel.font = [UIFont systemFontOfSize:14];
        [self.colorValueLabel setContentHuggingPriority:UILayoutPriorityFittingSizeLevel
                                   forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:self.colorValueLabel];
        [self.colorValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.colorTitleLabel.mas_trailing);
            make.trailing.mas_equalTo(self.goodNameLabel);
            make.centerY.mas_equalTo(self.colorTitleLabel.mas_centerY);
        }];
        
        self.sizeTitleLabel = [[UILabel alloc] init];
        self.sizeTitleLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        self.sizeTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        [self.contentView addSubview:self.sizeTitleLabel];
        [self.sizeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.goodNameLabel);
            make.top.mas_equalTo(self.colorTitleLabel.mas_bottom).offset(4);
        }];
        
        self.sizeValueLabel = [[UILabel alloc] init];
        self.sizeValueLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        self.sizeValueLabel.font = [UIFont systemFontOfSize:14];
        [self.sizeValueLabel setContentHuggingPriority:UILayoutPriorityFittingSizeLevel
                                                forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:self.sizeValueLabel];
        [self.sizeValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.sizeTitleLabel.mas_trailing);
            make.trailing.mas_equalTo(self.goodNameLabel);
            make.centerY.mas_equalTo(self.sizeTitleLabel.mas_centerY);
        }];
        
        self.attrView = [[ZFMultiAttributeInfoView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.attrView];
        [self.attrView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.goodNameLabel);
            make.top.mas_equalTo(self.sizeTitleLabel.mas_bottom).offset(4);
            make.height.mas_equalTo(0);
        }];
        
        self.subTitleLabel = [[UILabel alloc] init];
        self.subTitleLabel.textColor = ZFCOLOR(0, 0, 0, 1.0);
        self.subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        [self.contentView addSubview:self.subTitleLabel];
        [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.goodNameLabel.mas_leading);
            make.bottom.mas_equalTo(self.goodImg.mas_bottom);
        }];
        
       
        self.subTotalLabel = [[UILabel alloc] init];
        self.subTotalLabel.textColor = ZFCOLOR(0, 0, 0, 1.0);
        self.subTotalLabel.font = [UIFont boldSystemFontOfSize:16];
        
        [self.contentView addSubview:self.subTotalLabel];
        [self.subTotalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.subTitleLabel.mas_trailing);
            make.bottom.mas_equalTo(self.subTitleLabel.mas_bottom).offset(1);
        }];

        self.goodsNumLabel = [[UILabel alloc] init];
        self.goodsNumLabel.textColor = ZFCOLOR(0, 0, 0, 1.0);
        self.goodsNumLabel.font = [UIFont boldSystemFontOfSize:14];
        
        [self.contentView addSubview:self.goodsNumLabel];
        [self.goodsNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
            make.bottom.mas_equalTo(self.subTitleLabel.mas_bottom);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.height.mas_equalTo(0.5);
            make.top.mas_equalTo(self.goodImg.mas_bottom).offset(11.5);
        }];
        
        self.lineView.hidden = YES;
    }
    return self;
}

- (void)setGoodsModel:(CheckOutGoodListModel *)goodsModel {
    [self.goodImg yy_setImageWithURL:[NSURL URLWithString:goodsModel.wp_image]
                         placeholder:[UIImage imageNamed:@"loading_cat_list"]
                              options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                             }
                            transform:^UIImage *(UIImage *image, NSURL *url) {
                                image = [image yy_imageByResizeToSize:CGSizeMake(100 * ScreenWidth_SCALE, 133 * ScreenWidth_SCALE) contentMode:UIViewContentModeScaleAspectFit];
                                return image;
                            }
                           completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                               if (from == YYWebImageFromDiskCache) {
                                   YWLog(@"load from disk cache");
                               }
                           }];
    
    self.goodNameLabel.text = goodsModel.goods_title;
    
    self.colorTitleLabel.text = [NSString stringWithFormat:@"%@:",ZFLocalizedString(@"OrderDetail_Goods_Cell_Color",nil)];
    self.colorValueLabel.text = [NSString stringWithFormat:@"%@",goodsModel.attr_color == nil ? @"" :goodsModel.attr_color];
    self.sizeTitleLabel.text = [NSString stringWithFormat:@"%@:",ZFLocalizedString(@"OrderDetail_Goods_Cell_Size",nil)];
    self.sizeValueLabel.text = [NSString stringWithFormat:@"%@",goodsModel.attr_size == nil ? @"" :goodsModel.attr_size];
    self.goodsNumLabel.text = [NSString stringWithFormat:@"X%@",goodsModel.goods_number];
    self.subTitleLabel.text = [NSString stringWithFormat:@"%@: ",ZFLocalizedString(@"OrderDetail_Goods_Cell_Total",nil)];
    self.subTotalLabel.text = [ExchangeManager transforPrice:goodsModel.goods_price];
   
    if (goodsModel.multi_attr.count > 0) {
        self.attrView.attrsArray = goodsModel.multi_attr;
        [self.attrView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.goodNameLabel);
            make.top.mas_equalTo(self.sizeTitleLabel.mas_bottom).offset(4);
            make.height.mas_equalTo(goodsModel.multi_attr.count * 16);
        }];
        
        [self.subTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.attrView.mas_bottom);
            make.leading.mas_equalTo(self.goodNameLabel.mas_leading);
            make.bottom.mas_equalTo(self.goodImg.mas_bottom);
        }];
        
        
        [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.height.mas_equalTo(0.5);
            make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(11.5);
        }];
    }
    
    [self.colorTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (goodsModel.tagsArray.count < 1) {
            make.top.mas_equalTo(self.goodNameLabel.mas_bottom).offset(4);
        }else{
            make.top.mas_equalTo(self.tagView.mas_bottom).offset(4);
        }
        make.leading.mas_equalTo(self.goodNameLabel);
    }];
    
    if (goodsModel.tagsArray.count < 1) return;
    
    [self configureTagView:goodsModel.tagsArray];
}

#pragma mark - Private Method
- (void)configureTagView:(NSArray<ZFGoodsTagModel *> *)tagsArray {
    CGFloat tagWidth                = 0.0f;
    CGFloat tagHorizontalMargin     = 4.0f;
    CGFloat labelInsetMargin        = 8.0f;
    CGFloat tagVerticalMargin       = 2.0f;
    CGFloat tagHeight               = 16.0f;
    NSInteger count = tagsArray.count;
    BOOL  isNewLine;
    
    // 判断宽度
    for (ZFGoodsTagModel *tagModel in tagsArray) {
        tagWidth += [self calculateTitleSizeWithString:tagModel.tagTitle].width + labelInsetMargin;
        tagWidth += (tagsArray.count - 1) * tagHorizontalMargin;
    }
    
    isNewLine = tagHeight > (KScreenWidth - 22 - 100 * ScreenWidth_SCALE) ? YES : NO;
    
    ZFLabel *lastTagLabel = nil;
    
    for (int i = 0; i < count; ++i) {
        ZFGoodsTagModel *tagModel = tagsArray[i];
        ZFLabel *tagLabel =  [self configureTagLabelWithText:tagModel.tagTitle color:tagModel.tagColor];
        [self.tagView addSubview:tagLabel];
        [tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(tagHeight);
            if (i == 0) {
                make.leading.top.mas_equalTo(self.tagView);
                if (i == count - 1) {
                    make.bottom.mas_equalTo(self.tagView);
                }
            } else {
                if (i == count - 1 && isNewLine) {
                    make.leading.bottom.mas_equalTo(self.tagView);
                    make.top.equalTo(lastTagLabel.mas_bottom).offset(tagVerticalMargin);
                } else {
                    make.top.mas_equalTo(self.tagView);
                    make.leading.mas_equalTo(lastTagLabel.mas_trailing).offset(tagHorizontalMargin);
                    make.trailing.lessThanOrEqualTo(self.tagView); // 右边不超出
                    make.bottom.mas_equalTo(self.tagView);
                }
            }
        }];
        lastTagLabel = tagLabel;
    }
}

- (ZFLabel *)configureTagLabelWithText:(NSString *)text color:(NSString *)color {
    ZFLabel *tagLabel = [[ZFLabel alloc] init];
    tagLabel.textColor = [UIColor colorWithHexString:color];
    tagLabel.font = [UIFont systemFontOfSize:10];
    tagLabel.textAlignment = NSTextAlignmentCenter;
    tagLabel.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    tagLabel.edgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
    tagLabel.text = text;
    tagLabel.layer.borderColor = [UIColor colorWithHexString:color].CGColor;
    tagLabel.layer.borderWidth = 1.0f;
    return tagLabel;
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string {
    CGFloat fontSize = 10.0;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 20)  options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size;
}

#pragma mark - Getter
- (UIView *)tagView {
    if (!_tagView) {
        _tagView = [[UIView alloc] init];
        _tagView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _tagView;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.tagView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end
