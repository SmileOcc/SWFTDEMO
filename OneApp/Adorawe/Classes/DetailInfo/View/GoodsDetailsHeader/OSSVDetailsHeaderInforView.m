//
//  OSSVDetailsHeaderInforView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailsHeaderInforView.h"


#define SPACING_10 10 // 间距高度

#define SPACING_Left 16 // 间距高度

#define SPACING_Title_Right 48 // 间距高度


@interface GoodsDetailsTitleView : UIView

@property (nonatomic, strong) UIScrollView *bgScroView;
@property (nonatomic, strong) YYLabel *titleLabel;
@end


@implementation GoodsDetailsTitleView

+ (CGFloat)fetchSizeCellHeight:(NSMutableAttributedString *)attstring
{
    GoodsDetailsTitleView *sizeCell = [[GoodsDetailsTitleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    sizeCell.titleLabel.attributedText = attstring;
    [sizeCell layoutIfNeeded];
    CGFloat calculateHeight = sizeCell.bgScroView.contentSize.height;
    
    if (calculateHeight <=0) {
        return 0;
    }
    return calculateHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.bgScroView];
        [self.bgScroView addSubview:self.titleLabel];
        
        [self.bgScroView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(26);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-26);
            make.top.bottom.mas_equalTo(self);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH - 52);
            make.edges.mas_equalTo(self.bgScroView);
        }];
    }
    return self;
}

- (UIScrollView *)bgScroView {
    if (!_bgScroView) {
        _bgScroView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    }
    return _bgScroView;
}

- (YYLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[YYLabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 12*2 - 14*2;

        [_titleLabel sizeToFit];
        _titleLabel.textColor = [OSSVThemesColors col_6C6C6C];
    }
    return _titleLabel;
}


@end


@interface OSSVDetailsHeaderInforView ()
@end

@implementation OSSVDetailsHeaderInforView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.shopPrice];
        [self addSubview:self.marketPrice];
        [self addSubview:self.flastScitviytStateView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.moreButton];
        [self addSubview:self.ratingtView];
        [self addSubview:self.lineView];
        
        [self.ratingtView addSubview:self.startRatingView];
        [self.ratingtView addSubview:self.ratingLabel];
        [self.ratingtView addSubview:self.arrowImageView];
        [self.ratingtView addSubview:self.ratingButton];
        [self.ratingtView addSubview:self.reviewCountLabel];
        [self.ratingtView addSubview:self.reviewBottomLineView];

        [self addSubview:self.coinView];
        
        
        if (APP_TYPE == 3) {
            self.lineView.hidden = NO;
            self.reviewCountLabel.hidden = NO;
            self.reviewBottomLineView.hidden = NO;
            self.arrowImageView.hidden = YES;
            
            [self.shopPrice mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self).mas_offset(12);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
                make.height.mas_equalTo(27);
            }];
            
            [self.marketPrice mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.shopPrice.mas_trailing);
                make.top.mas_equalTo(self.shopPrice.mas_bottom).offset(2);
            }];

            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading).mas_offset(14);
                make.trailing.mas_equalTo(self.shopPrice.mas_leading).mas_offset(-4);
                make.top.mas_equalTo(self).mas_offset(12);
                make.height.mas_equalTo(27);
            }];
            
            
            [self.ratingtView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading).offset(14);
                make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-14);
                make.top.mas_equalTo(self.titleLabel.mas_bottom);
                make.height.mas_equalTo(30);
            }];
            
            [self.startRatingView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.ratingtView.mas_leading);
                make.centerY.mas_equalTo(self.ratingtView.mas_centerY);
                make.height.mas_equalTo(@14);
                make.width.mas_equalTo(@78);
            }];
            
            [self.ratingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.startRatingView.mas_trailing).offset(2);
                make.centerY.mas_equalTo(self.startRatingView.mas_centerY);
            }];
            [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.startRatingView.mas_centerY);
                make.leading.mas_equalTo(self.ratingLabel.mas_trailing).offset(1);
                make.size.mas_equalTo(CGSizeMake(12, 12));
            }];
            
            [self.reviewCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.ratingLabel.mas_trailing).offset(2);
                make.centerY.mas_equalTo(self.arrowImageView.mas_centerY);
            }];
            
            [self.reviewBottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.mas_equalTo(self.reviewCountLabel);
                make.top.mas_equalTo(self.reviewCountLabel.mas_bottom);
                make.height.mas_equalTo(1);
            }];
            
            [self.ratingButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.startRatingView.mas_leading);
                make.trailing.mas_equalTo(self.reviewCountLabel.mas_trailing);
                make.centerY.mas_equalTo(self.startRatingView.mas_centerY);
                make.height.mas_equalTo(@30);
            }];
            
            [self.coinView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading).mas_offset(14);
                make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-14);
                make.top.mas_equalTo(self.ratingtView.mas_bottom);
                make.height.mas_equalTo(23);
            }];
            
            [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading).offset(14);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
                make.bottom.mas_equalTo(self.mas_bottom);
                make.height.mas_equalTo(0.6);
            }];
            
            // 设置抗压缩优先级
            [self.shopPrice setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
            [self.shopPrice setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
            
            [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            [self.titleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
            
            
        } else {
            
            [self.shopPrice mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self).mas_offset(12);
                make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
                make.height.mas_equalTo(21);
            }];
            
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                [self.marketPrice mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.mas_equalTo(self.shopPrice.mas_trailing).mas_offset(2);
                    make.bottom.mas_equalTo(self.shopPrice.mas_bottom).offset(-2);
                }];
            } else {
                [self.marketPrice mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.mas_equalTo(self.shopPrice.mas_trailing).mas_offset(2);
                    make.bottom.mas_equalTo(self.shopPrice.mas_bottom).offset(-4);
                }];
            }
           
            [self.flastScitviytStateView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.marketPrice.mas_trailing).offset(6);
                make.centerY.mas_equalTo(self.marketPrice.mas_centerY);
                make.height.mas_equalTo(14);
            }];

            [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading).mas_offset(14);
                make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-14);
                make.top.mas_equalTo(self.mas_top).mas_offset(42);
                make.height.mas_greaterThanOrEqualTo(19);
            }];
            
            [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
                make.width.mas_equalTo(42);
                make.bottom.mas_equalTo(self.titleLabel.mas_bottom);
            }];
            
            [self.ratingtView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading).offset(14);
                make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-14);
                make.top.mas_equalTo(self.titleLabel.mas_bottom);
                make.height.mas_equalTo(30);
            }];
            
            [self.startRatingView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.ratingtView.mas_leading);
                make.centerY.mas_equalTo(self.ratingtView.mas_centerY);
                make.height.mas_equalTo(@14);
                make.width.mas_equalTo(@78);
            }];
            
            [self.ratingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.startRatingView.mas_trailing).offset(2);
                make.centerY.mas_equalTo(self.startRatingView.mas_centerY);
            }];
            [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.startRatingView.mas_centerY);
                make.leading.mas_equalTo(self.ratingLabel.mas_trailing).offset(1);
                make.size.mas_equalTo(CGSizeMake(12, 12));
            }];
            
            [self.ratingButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.startRatingView.mas_leading);
                make.trailing.mas_equalTo(self.arrowImageView.mas_trailing);
                make.centerY.mas_equalTo(self.arrowImageView.mas_centerY);
                make.height.mas_equalTo(@30);
            }];
            
            [self.coinView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.mas_leading).mas_offset(14);
                make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-14);
                make.top.mas_equalTo(self.ratingtView.mas_bottom);
                make.height.mas_equalTo(23);
            }];
        }
    }
    return self;
}

+ (CGFloat)heightGoodsInforView:(OSSVDetailsBaseInfoModel *)goodsInforModel reviewInfo:(OSSVReviewsModel *)reviewModel{
    
    if (goodsInforModel) {
        BOOL isNewGoods = [goodsInforModel isShowGoodDetailNew];
        NSString *newString = [[NSString stringWithFormat:@"  %@    ",STLLocalizedString_(@"new_goods_mark", nil)] uppercaseString];
        if (APP_TYPE != 3) {
            if (isNewGoods) {
                if (![goodsInforModel.goodsTitle hasPrefix:newString]) {
                    goodsInforModel.goodsTitle = [NSString stringWithFormat:@"%@%@",newString,goodsInforModel.goodsTitle];
                }
            }
        }
        
        
        CGFloat pricsContentHeight = 42;
        ///闪购进行中，可以买
        if (STLIsEmptyString(goodsInforModel.specialId)
            && goodsInforModel.flash_sale
            && [goodsInforModel.flash_sale.active_status intValue] == 1
            && [goodsInforModel.flash_sale.is_can_buy isEqualToString:@"1"]) {
            pricsContentHeight = 12;
        }
        
        CGFloat topSpaceHeight = 0;
         
        CGSize titleSize = CGSizeZero;
        
        //标题内容高
        
        UIFont *textFont = [UIFont systemFontOfSize:12];
        
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        paragraph.lineSpacing = 4;//连字符
        
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        
        if (goodsInforModel.titleSizeHeight <= 0) {
            titleSize = [STLToString(goodsInforModel.goodsTitle) boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 12*2 - 14*2, CGFLOAT_MAX)
                                                                              options:(NSStringDrawingUsesLineFragmentOrigin |
                                                                                       NSStringDrawingTruncatesLastVisibleLine)
                                                                           attributes:attributes
                                                                              context:nil].size;
            
            
            goodsInforModel.titleSizeHeight = titleSize.height;
        }
        
        if (goodsInforModel.titleSizeHeight > 0) {
            titleSize = CGSizeMake(SCREEN_WIDTH - 12*2 - 14*2, goodsInforModel.titleSizeHeight);

        }
        
        
        CGFloat spaceHeight = 0;
        CGFloat twoLineHeigth = 35;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            twoLineHeigth = 40;
        }

            
        if (titleSize.width <= 0) {//没有内容
            
            titleSize.height = 0;
            goodsInforModel.isShowTitleMore = NO;
            goodsInforModel.isShowLess = NO;
            
        } else if (titleSize.height < 21) {//内容没有超过1行
            
            goodsInforModel.isShowTitleMore = NO;
            goodsInforModel.isShowLess = NO;
            titleSize.height = 20;
            
        } else if(titleSize.height < twoLineHeigth) {//两行之内
            goodsInforModel.isShowTitleMore = NO;
            goodsInforModel.isShowLess = NO;
            titleSize.height = twoLineHeigth;
            
        } else {//两行之外
            if (!goodsInforModel.isShowTitleMore) {
                goodsInforModel.isShowTitleMore = YES;
                goodsInforModel.isShowLess = NO;
                titleSize.height = twoLineHeigth;
            } else if(!goodsInforModel.isShowLess){
                titleSize.height = twoLineHeigth;
            }
            
            //内容超过两行，计算添加Less的
            if (goodsInforModel.titleLessSizeHeight <= 0) {
                
                NSMutableParagraphStyle *paragraphStyle  =[[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineSpacing = 4;//连字符
                NSDictionary *attrDict =@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                          NSForegroundColorAttributeName:[OSSVThemesColors col_6C6C6C],
                                          NSParagraphStyleAttributeName:paragraphStyle};
                
                NSMutableAttributedString *attrStr =[[NSMutableAttributedString alloc] initWithString:STLToString(goodsInforModel.goodsTitle) attributes:attrDict];
                
                BOOL isNewGoods = [goodsInforModel isShowGoodDetailNew];
                if (isNewGoods) {
                    NSString *newString = [[NSString stringWithFormat:@"  %@  ",STLLocalizedString_(@"new_goods_mark", nil)] uppercaseString];
                    NSRange LessRange = [attrStr.string rangeOfString:newString];
                    
                    if (LessRange.location != NSNotFound) {
                        YYTextBorder * border = [YYTextBorder borderWithFillColor:[OSSVThemesColors col_60CD8E] cornerRadius:0];//创建背景色（颜色与圆角）
                        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                            border.insets=UIEdgeInsetsMake(0,0,-2,0);//背景色的偏移量
                        } else {
                            border.insets=UIEdgeInsetsMake(0,0,-1,0);//背景色的偏移量
                        }
                        [attrStr yy_setTextBackgroundBorder:border range:LessRange];
                        
                        
                    }
                }
                
                if (APP_TYPE == 3) {
                    goodsInforModel.titleLessSizeHeight = 27;
                } else {
                    
                    if (goodsInforModel.isShowTitleMore) {
                        NSString *lessString = STLLocalizedString_(@"Less", nil);
                        NSString *attributeLessString = [NSString stringWithFormat:@"  %@",lessString];
                        NSAttributedString *conditionAtt = [[NSMutableAttributedString alloc] initWithString:attributeLessString attributes:attrDict];
                        [attrStr appendAttributedString:conditionAtt];
                    }
                    
                    CGFloat titleSizeLess = [GoodsDetailsTitleView fetchSizeCellHeight:attrStr];
                    goodsInforModel.titleLessSizeHeight = titleSizeLess;
                }
                
                //这个算得不太准啊，如果行数多了的话 4-5行，差不就大了
                //                    NSString *titleLess = [NSString stringWithFormat:@"%@  %@",STLToString(goodsInforModel.goodsTitle),STLLocalizedString_(@"Less", nil)];
                //
                //                    CGSize titleSizeLess = [titleLess boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 12*2 - 14*2, CGFLOAT_MAX)
                //                                                                   options:(NSStringDrawingUsesLineFragmentOrigin |
                //                                                                            NSStringDrawingTruncatesLastVisibleLine)
                //                                                                attributes:attributes
                //                                                                   context:nil].size;
                //                    goodsInforModel.titleLessSizeHeight = titleSizeLess.height;
 
            }
            
            if (goodsInforModel.isShowLess) {
                titleSize.height = goodsInforModel.titleLessSizeHeight;
            }
        }
        
       
        
        
        //评论
        CGFloat commentheight = 4;
        
        if (APP_TYPE == 3) {
            titleSize.height = 27;
            commentheight = 0;
            pricsContentHeight = 42;
        }
        if (reviewModel && reviewModel.reviewList.count > 0) {
            commentheight = 30;
        }
        
        //v 2.0.0 隐藏
        goodsInforModel.return_coin = 0;
        // 有金币
        CGFloat coinHeight = 0.0;
        if (goodsInforModel.return_coin > 0) {
            coinHeight = 23;
        }
        
        if (APP_TYPE == 3) {
            return pricsContentHeight + topSpaceHeight + titleSize.height + spaceHeight + coinHeight + commentheight - 10;

        }
       
        return pricsContentHeight + topSpaceHeight + titleSize.height + spaceHeight + coinHeight + commentheight;
    }
    
    return 12 + 21 + 31 + 12;
}

-(void)updateReviewInfo:(OSSVReviewsModel *)reviewInfo{
    
    self.ratingButton.userInteractionEnabled = NO;
    self.ratingtView.hidden = YES;

    NSInteger count = reviewInfo.reviewCount;
    if (count > 0 ) {
        self.ratingButton.userInteractionEnabled = YES;
        self.ratingtView.hidden = NO;

        self.startRatingView.grade = reviewInfo.agvRate;
        self.ratingLabel.text = [NSString stringWithFormat:@"%.1f",reviewInfo.agvRate];
        
        self.reviewCountLabel.text = [NSString stringWithFormat:@"%ld %@",(long)reviewInfo.reviewCount,STLLocalizedString_(@"reviews", nil)];
        
    } else {
        self.ratingLabel.text = @"";
    }
    
    [self.ratingtView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(count > 0 ? 30 : 4);
    }];
}

- (void)updateHeaderGoodsInfor:(OSSVDetailsBaseInfoModel *)goodsInforModel reviewInfo:(OSSVReviewsModel *)reviewModel {
    
    //v 2.0.0 隐藏
    goodsInforModel.return_coin = 0;
    
    // 价格
    self.shopPrice.textColor = [OSSVThemesColors col_0D0D0D];
    if (APP_TYPE == 3) {
        self.shopPrice.textColor = [OSSVThemesColors col_000000:0.8];
    }
    self.shopPrice.text = STLToString(goodsInforModel.shop_price_converted);
    self.marketPrice.text = STLToString(goodsInforModel.market_price_converted);
    
    self.titleLabel.numberOfLines = 2;
    self.moreButton.hidden = YES;
    BOOL isMutAttributTitle = NO;
    BOOL isShowMoreTitle = goodsInforModel.isShowTitleMore;
    // 商品名
    self.titleLabel.text = @"";
    
    if (goodsInforModel.isShowTitleMore) {
        self.moreButton.hidden = NO;
        if (goodsInforModel.isShowLess) {
            self.titleLabel.numberOfLines = 0;
            self.moreButton.hidden = YES;
            isMutAttributTitle = YES;
        }
    }
    [self handleTitleAttribute:goodsInforModel];
    
    
    /////闪购 折扣标
    self.flastScitviytStateView.hidden = YES;
    if ([goodsInforModel.showDiscountIcon isEqualToString:@"0"]) {
    } else {
        if ([OSSVNSStringTool isEmptyString:goodsInforModel.goodsDiscount] || [goodsInforModel.goodsDiscount isEqualToString:@"0"]) {
        }else {
            self.flastScitviytStateView.hidden = NO;
            [self.flastScitviytStateView updateState:STLActivityStyleNormal discount:STLToString(goodsInforModel.goodsDiscount)];
            self.shopPrice.textColor = OSSVThemesColors.col_B62B21;
            if (APP_TYPE == 3) {
                self.shopPrice.textColor = OSSVThemesColors.col_9F5123;
            }
        }
    }
    
    if (goodsInforModel.specialId && [goodsInforModel.shop_price integerValue] == 0) {
        self.shopPrice.textColor = OSSVThemesColors.col_B62B21;
        if (APP_TYPE == 3) {
            self.shopPrice.textColor = OSSVThemesColors.col_9F5123;
        }
    }
    
    self.shopPrice.hidden = NO;
    self.marketPrice.hidden = APP_TYPE == 3 ? YES : NO;
    
    // 0 > 闪购 > 满减
    //和鲍勇再次确认完全可以拿着is_can_buy 字段来判断用户能否按照闪购价继续购买，以及闪购背景置灰和 价格不为红色
    BOOL isTopSpace = YES;
    if (STLIsEmptyString(goodsInforModel.specialId) && goodsInforModel.flash_sale &&  [goodsInforModel.flash_sale.is_can_buy isEqualToString:@"1"] && [goodsInforModel.flash_sale.active_status isEqualToString:@"1"]) {
        self.shopPrice.hidden = YES;
        self.marketPrice.hidden = YES;
        self.flastScitviytStateView.hidden = YES;
        isTopSpace = NO;
    }

    if (APP_TYPE == 3) {
        if ([goodsInforModel.showDiscountIcon isEqualToString:@"0"] || [OSSVNSStringTool isEmptyString:goodsInforModel.goodsDiscount] || [goodsInforModel.goodsDiscount isEqualToString:@"0"]) {
            
        } else {// 价格
            self.marketPrice.hidden = NO;
        }
        self.marketPrice.textColor = [OSSVThemesColors col_000000:0.5];
        
    } else {
        if (isMutAttributTitle) {
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.mas_top).offset(isTopSpace ? 42 : 12);
                make.trailing.mas_equalTo(self.mas_trailing).offset(isMutAttributTitle ? (-12) : (-60));
            }];
        } else if(isShowMoreTitle) {
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.mas_top).offset(isTopSpace ? 42 : 12);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-60);
            }];
        } else  {
            [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.mas_top).offset(isTopSpace ? 42 : 12);
                make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            }];
        }
    }
    

    [self updateReviewInfo:reviewModel];
    
    if(goodsInforModel.return_coin > 0){
        [self.coinView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(23);
        }];
        self.coinView.hidden = NO;
    }else{
        [self.coinView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        self.coinView.hidden = YES;
    }
    
    // 获得金币
    [self.coinView configBaseInfoModel:goodsInforModel];
}

- (void)handleTitleAttribute:(OSSVDetailsBaseInfoModel *)goodsInforModel {
    
    BOOL isMutAttributTitle = NO;
    if (goodsInforModel.isShowTitleMore) {
        if (goodsInforModel.isShowLess) {
            isMutAttributTitle = YES;
        }
    }
    
    if (!isMutAttributTitle) {
        if (STLToString(goodsInforModel.goodsTitle).length > 0) {
            if (!goodsInforModel.titleAttributeString) {
                
                NSMutableParagraphStyle *paragraphStyle  =[[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineSpacing = 4;//连字符
                NSDictionary *attrDict =@{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                          NSForegroundColorAttributeName:[OSSVThemesColors col_6C6C6C],
                                          NSParagraphStyleAttributeName:paragraphStyle};
                if (APP_TYPE == 3) {
                    attrDict =@{NSFontAttributeName:[UIFont vivaiaRegularFont:20],
                                              NSForegroundColorAttributeName:[OSSVThemesColors col_000000:1],
                                              NSParagraphStyleAttributeName:paragraphStyle};
                }
                
                NSMutableAttributedString *attrStr =[[NSMutableAttributedString alloc] initWithString:STLToString(goodsInforModel.goodsTitle) attributes:attrDict];
                
                BOOL isNewGoods = [goodsInforModel isShowGoodDetailNew];
                
                if (isNewGoods) {
                    NSString *newString = [[NSString stringWithFormat:@"  %@  ",STLLocalizedString_(@"new_goods_mark", nil)] uppercaseString];
                    NSRange newRange = [attrStr.string rangeOfString:newString];
                    
                    if (newRange.location != NSNotFound) {
                        YYTextBorder * border = [YYTextBorder borderWithFillColor:[OSSVThemesColors col_60CD8E] cornerRadius:0];//创建背景色（颜色与圆角）
                        
                        if (APP_TYPE == 3) {
                            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                                border.insets=UIEdgeInsetsMake(-3,0,0,0);//背景色的偏移量
                            } else {
                                border.insets=UIEdgeInsetsMake(-3,0,0,0);//背景色的偏移量
                            }
                        } else {
                            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                                border.insets=UIEdgeInsetsMake(0,0,-2,0);//背景色的偏移量
                            } else {
                                border.insets=UIEdgeInsetsMake(0,0,-1,0);//背景色的偏移量
                            }
                        }
                        
                        [attrStr yy_setTextBackgroundBorder:border range:newRange];
                        [attrStr yy_setColor:[OSSVThemesColors stlWhiteColor] range:newRange];
                        if (APP_TYPE == 3) {
                            [attrStr yy_setFont:[UIFont systemFontOfSize:12] range:newRange];
                            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                                [attrStr yy_setBaselineOffset:@(3) range:newRange];
                            } else {
                                [attrStr yy_setBaselineOffset:@(2) range:newRange];
                            }
                        }
                        
                    }
                }
                
                if (APP_TYPE == 3) {
                    
                } else {
                    
                    if (goodsInforModel.isShowTitleMore) {
                        NSString *lessString = STLLocalizedString_(@"Less", nil);
                        NSString *attributeLessString = [NSString stringWithFormat:@"  %@",lessString];
                        NSAttributedString *conditionAtt = [[NSMutableAttributedString alloc] initWithString:attributeLessString attributes:attrDict];
                        [attrStr appendAttributedString:conditionAtt];
                        
                        NSRange LessRange = [attrStr.string rangeOfString:lessString];
                        YYTextDecoration *decoration = [YYTextDecoration decorationWithStyle:YYTextLineStyleSingle
                                                                                       width:@(0.5)
                                                                                       color:[OSSVThemesColors col_6C6C6C]];
                        
                        if (LessRange.location != NSNotFound) {
                            [attrStr yy_setTextUnderline:decoration range:LessRange];
                            [attrStr yy_setTextHighlightRange:LessRange
                                                        color:[OSSVThemesColors col_6C6C6C]
                                              backgroundColor:[UIColor clearColor]
                                                    tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                                
                                [self showMoreTitle:NO];
                                
                            }];
                            
                        }
                    }
                }
                goodsInforModel.titleAttributeString = attrStr;
            }
        }
    }
    
    if (goodsInforModel.titleAttributeString) {
        self.titleLabel.attributedText = goodsInforModel.titleAttributeString;
    }
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.titleLabel.textAlignment = NSTextAlignmentRight;
    } else {
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    if (APP_TYPE == 3) {
        self.titleLabel.numberOfLines = 1;
    } else {
        self.titleLabel.numberOfLines = isMutAttributTitle ? 0 : 2;
    }
}

#pragma mark - Action
#pragma mark 收藏
- (void)showCointsTip {
    if (self.delegate && [self.delegate respondsToSelector:@selector(detailsHeaderInforView:cointTip:)]) {
        [self.delegate detailsHeaderInforView:self cointTip:YES];
    }
}
- (void)ratingAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(detailsHeaderInforView:review:)]) {
        [self.delegate detailsHeaderInforView:self review:YES];
    }
}

- (void)actionShowMore:(UIButton *)sender {
    [self showMoreTitle:YES];
}

- (void)showMoreTitle:(BOOL)isShow {
    if (self.delegate && [self.delegate respondsToSelector:@selector(detailsHeaderInforView:showMoreTitle:)]) {
        [self.delegate detailsHeaderInforView:self showMoreTitle:isShow];
    }
}

#pragma mark - LazyLoad

- (UILabel *)shopPrice {
    if (!_shopPrice) {
        _shopPrice = [[UILabel alloc] init];
        _shopPrice.textColor = [OSSVThemesColors col_0D0D0D];
        if (APP_TYPE == 3) {
            [_shopPrice setFont:[UIFont vivaiaRegularFont:20]];

        } else {
            [_shopPrice setFont:[UIFont boldSystemFontOfSize:18]];

        }
    }
    return _shopPrice;
}

- (STLCLineLabel *)marketPrice {
    if (!_marketPrice) {
        _marketPrice = [[STLCLineLabel alloc] init];
        _marketPrice.textColor = [OSSVThemesColors col_6C6C6C];
        _marketPrice.font = [UIFont systemFontOfSize:10];
    }
    return _marketPrice;
}

- (OSSVDetailsHeaderActivityStateView *)flastScitviytStateView {
    if (!_flastScitviytStateView) {
        _flastScitviytStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleNormal];
        _flastScitviytStateView.samllImageShow = NO;
        _flastScitviytStateView.fontSize = 10;
        _flastScitviytStateView.flashImageSize = 12;
        _flastScitviytStateView.activityNormalView.discountLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _flastScitviytStateView.activityNormalView.backgroundColor = [OSSVThemesColors col_0D0D0D];
        _flastScitviytStateView.hidden = YES;
    }
    return _flastScitviytStateView;
}


- (YYLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[YYLabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        if (APP_TYPE == 3) {
            _titleLabel.numberOfLines = 1;
            _titleLabel.font = [UIFont vivaiaRegularFont:20];
        } else {
            _titleLabel.numberOfLines = 2;
            _titleLabel.font = [UIFont systemFontOfSize:12];
            _titleLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 12*2 - 14*2;
            [_titleLabel sizeToFit];

        }
        

        _titleLabel.textColor = [OSSVThemesColors col_6C6C6C];
    }
    return _titleLabel;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setTitle:STLLocalizedString_(@"More", nil) forState:UIControlStateNormal];
        [_moreButton setTitleColor:[OSSVThemesColors col_6C6C6C] forState:UIControlStateNormal];
        _moreButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _moreButton.contentEdgeInsets = UIEdgeInsetsMake(7, 4, 0, 0);
        
        [_moreButton addTarget:self action:@selector(actionShowMore:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (UIView *)ratingtView {
    if (!_ratingtView) {
        _ratingtView = [[UIView alloc] initWithFrame:CGRectZero];
        _ratingtView.hidden = YES;
    }
    return _ratingtView;
}

- (ZZStarView *)startRatingView {
    if (!_startRatingView) {
        _startRatingView = [[ZZStarView alloc] initWithImage:[UIImage imageNamed:@"star_small_review"] selectImage:[UIImage imageNamed:@"star_small_review_h"] starWidth:14 starHeight:14 starMargin:2 starCount:5 callBack:^(CGFloat userGrade, CGFloat finalGrade) {
            
        }];
        
        _startRatingView.userInteractionEnabled = NO;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _startRatingView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
        _startRatingView.sublevel = 1;
        _startRatingView.backgroundColor = [UIColor whiteColor];
        _startRatingView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _startRatingView;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.image = [UIImage imageNamed:@"goods_arrow"];
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}

- (UILabel *)ratingLabel {
    if (!_ratingLabel) {
        _ratingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _ratingLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _ratingLabel.font = [UIFont boldSystemFontOfSize:12];
    }
    return _ratingLabel;
}

- (UIButton *)ratingButton {
    if (!_ratingButton) {
        _ratingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_ratingButton addTarget:self action:@selector(ratingAction:) forControlEvents:UIControlEventTouchUpInside];
        _ratingButton.userInteractionEnabled = NO;

    }
    return _ratingButton;
}

- (OSSVDetailHeaderCoinView *)coinView{
    if (!_coinView) {
        _coinView = [[OSSVDetailHeaderCoinView alloc] initWithFrame:CGRectZero];
        _coinView.hidden = YES;

        @weakify(self)
        _coinView.coinBlock = ^{
            @strongify(self)
            [self showCointsTip];
        };
    }
    return _coinView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = OSSVThemesColors.col_E1E1E1;
        _lineView.hidden = YES;
    }
    return _lineView;
}

- (UILabel *)reviewCountLabel {
    if (!_reviewCountLabel) {
        _reviewCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _reviewCountLabel.textColor = [OSSVThemesColors col_000000:0.5];
        _reviewCountLabel.font = [UIFont systemFontOfSize:12];
        _reviewCountLabel.hidden = YES;
    }
    return _reviewCountLabel;
}

- (UIView *)reviewBottomLineView {
    if (!_reviewBottomLineView) {
        _reviewBottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        UIImage *backImg = STLImageWithName(@"spic_dash_line_black");
        UIColor*bcColor =[UIColor colorWithPatternImage:backImg];
        _reviewBottomLineView.backgroundColor = bcColor;
        _reviewBottomLineView.hidden = YES;
    }
    return _reviewBottomLineView;
}

@end
