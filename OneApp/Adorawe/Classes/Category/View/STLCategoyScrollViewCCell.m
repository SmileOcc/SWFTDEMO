//
//  OSSVCategoyScrollrViewCCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/22.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//--------分类顶部滚动banner

#import "OSSVCategoyScrollrViewCCell.h"
#import "STLAdvEventModel.h"
#import "SDCycleScrollView.h"
#import "STLCategoryViewModel.h"

@interface OSSVCategoyScrollrViewCCell ()<SDCycleScrollViewDelegate>

@property (nonatomic, strong) UIView *collectBackGroundView;
@property (nonatomic, strong) UILabel *featuredLabel;
/**hottest轮播图*/
@property (nonatomic, strong) UIView *cycleContentView;
/**Featured一系列文本图片*/
@property (nonatomic, strong) UIView *guidContentView;

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) MASConstraint *cycleContentHeight;

@end

@implementation OSSVCategoyScrollrViewCCell

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [STLThemeColor stlWhiteColor];
    
        [self addSubview:self.collectBackGroundView];
        [self.collectBackGroundView addSubview:self.cycleContentView];
        [self.collectBackGroundView addSubview:self.guidContentView];
        [self.cycleContentView addSubview:self.cycleScrollView];
    
        [self.collectBackGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        [self makeConstarints];
    }
    return self;
}

#pragma make -  SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    if (self.model && self.model.banner.count > index) {
        
        STLAdvEventModel *advEventModel = [self.model.banner objectAtIndex:index];
        if(self.categoriesClickDelegate)
        {
            NSString *pageName = [UIViewController currentTopViewControllerPageName];
            NSString *attrNode3 = [NSString stringWithFormat:@"custom_first_categories_%@",advEventModel.name];
            NSDictionary *sensorsDicClick = @{@"page_name":STLToString(pageName),
                                              @"attr_node_1":@"home_tab",
                                              @"attr_node_2":@"home_category",
                                              @"attr_node_3":attrNode3,
                                              @"position_number":@(index+1),
                                              @"venue_position":@(0),
                                              @"action_type":@([advEventModel advActionType]),
                                              @"url":[advEventModel advActionUrl],
            };
            [STLAnalytics analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDicClick];
            
            //数据GA埋点曝光 广告点击
                                
                                // item
                                NSMutableDictionary *item = [@{
                            //          kFIRParameterItemID: $itemId,
                            //          kFIRParameterItemName: $itemName,
                            //          kFIRParameterItemCategory: $itemCategory,
                            //          kFIRParameterItemVariant: $itemVariant,
                            //          kFIRParameterItemBrand: $itemBrand,
                            //          kFIRParameterPrice: $price,
                            //          kFIRParameterCurrency: $currency
                                } mutableCopy];


                                // Prepare promotion parameters
                                NSMutableDictionary *promoParams = [@{
                            //          kFIRParameterPromotionID: $promotionId,
                            //          kFIRParameterPromotionName:$promotionName,
                            //          kFIRParameterCreativeName: $creativeName,
                            //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                                      @"screen_group":@"Category",
                                      @"position": @"ProductCategory"
                                } mutableCopy];

                                // Add items
                                promoParams[kFIRParameterItems] = @[item];
                                
                                [STLAnalytics analyticsGAEventWithName:kFIREventViewPromotion parameters:promoParams];
            
            if(self.categoriesClickDelegate && [self.categoriesClickDelegate respondsToSelector:@selector(categoriesCell:advModel:isBanner:)]) {
                [self.categoriesClickDelegate categoriesCell:self advModel:advEventModel isBanner:YES];
            }
        }
    }
}

#pragma mark - private methods

- (void)makeConstarints
{
    CGFloat imageH = [STLCategoryViewModel secondRangeCollectionWidth] * 100.0 / 254.0;

    [self.cycleContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.collectBackGroundView.mas_top);
        make.height.mas_equalTo(imageH);
    }];
    
    //循环滚动广告
    [self.cycleScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cycleContentView.mas_top);
        make.leading.trailing.mas_equalTo(self.cycleContentView);
        make.bottom.mas_equalTo(self.cycleContentView.mas_bottom);
    }];
    
    //循环滚动广告下的广告
    [self.guidContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.cycleContentView.mas_bottom).offset(10);
        make.leading.mas_equalTo(self.collectBackGroundView.mas_leading);
        make.trailing.mas_equalTo(self.collectBackGroundView.mas_trailing);
        make.height.mas_equalTo(0);
    }];
}


#pragma make - user action

- (void)guidClick:(UIButton *)btns {
    if (self.model && self.model.guide.count > ((int)btns.tag - 10)) {
        
        STLAdvEventModel *guideModel = [self.model.guide objectAtIndex:(int)btns.tag - 10];
        if(self.categoriesClickDelegate && [self.categoriesClickDelegate respondsToSelector:@selector(categoriesCell:advModel:isBanner:)]) {
            [self.categoriesClickDelegate categoriesCell:self advModel:guideModel isBanner:NO];
        }
    }
}


+ (CGFloat)scrollViewContentH:(OSSVCategorysModel *)model {
    
    if (!model || (model.banner.count == 0 && model.guide.count == 0)) {
        return 0.1;
    }

    CGFloat bannerHeight = 0.0;
    CGFloat guideHeight = 0.0;
    
    CGFloat topBannerH = 0;
    if (model.banner.count != 0) {
        // 10 顶部间隙（广告）
        topBannerH = 12;
        bannerHeight = [STLCategoryViewModel secondRangeCollectionWidth] * 100.0 / 254.0;
    }
    if (model.guide.count != 0) {
        
        CGSize itemSize = [STLCategoryViewModel secondRangeItemSize];
        // 10 与上面广告间隙
        if (APP_TYPE == 3) {
            NSInteger row = (model.guide.count - 1)/ 2 + 1;
            guideHeight = 40 + row * itemSize.height + 12;
        } else {
            NSInteger row = (model.guide.count - 1)/ 3 + 1;
            guideHeight = 40 + row * itemSize.height + 12;
        }
        
    }
    topBannerH += bannerHeight + guideHeight;

    return topBannerH + 0.1;
}

#pragma mark - setters and getters

-(void)setModel:(OSSVCategorysModel *)model {
    
    _model = model;
    CGFloat imageH = [STLCategoryViewModel secondRangeCollectionWidth] * 100.0 / 254.0;

    //移除子视图
    [self.guidContentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
        }];
        [obj removeFromSuperview];
    }];
    
    
    if (model) {        
        self.cycleContentView.hidden = model.banner.count > 0 ? NO : YES;

        if (model.banner.count == 0) {
            [self.cycleContentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.collectBackGroundView.mas_top).offset(0);
                make.height.mas_equalTo(0);
            }];
            
        } else {
            
            NSMutableArray *imageUrlmArray = [NSMutableArray new];
            for (STLAdvEventModel *bannerModel in model.banner) {
                [imageUrlmArray addObject:bannerModel.imageURL];
            }
            self.cycleScrollView.imageURLStringsGroup = imageUrlmArray;
            [self.cycleContentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.collectBackGroundView.mas_top);
                make.height.mas_equalTo(imageH);
            }];
            if (imageUrlmArray.count == 1) {
                self.cycleScrollView.autoScroll = NO;
            }
        }
        
        [self.guidContentView addSubview:self.featuredLabel];
        [self.featuredLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.leading.mas_equalTo(self.guidContentView);
                make.top.mas_equalTo(self.guidContentView.mas_top).offset(15);
            } else {
                make.leading.trailing.mas_equalTo(self.guidContentView).offset(14);
                make.top.mas_equalTo(self.guidContentView.mas_top).offset(17);
            }
            make.height.mas_equalTo(14);
        }];
        
        
        if (model.guide.count != 0) {
            
            CGSize itemSize = [STLCategoryViewModel secondRangeItemSize];
            
            self.guidContentView.hidden = NO;
            
            UIButton *tempButton;
            for (int i = 0; i < model.guide.count; i ++) {
                STLAdvEventModel *guideModel = [model.guide objectAtIndex:i];
                
                STLCateBannerGuidItemView *btn = [STLCateBannerGuidItemView buttonWithType:UIButtonTypeCustom];
                
                btn.tag = i + 10;
                [btn addTarget:self action:@selector(guidClick:) forControlEvents:UIControlEventTouchUpInside];
                [self.guidContentView addSubview:btn];

                if (tempButton) {
                    
                    if (APP_TYPE == 3) {
                        if (i % 2 == 0) {
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.leading.mas_equalTo(self.guidContentView.mas_leading);
                                make.top.mas_equalTo(tempButton.mas_bottom);
                                make.size.mas_equalTo(itemSize);
                            }];
                            
                        } else {
                            
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.leading.mas_equalTo(tempButton.mas_trailing).offset(8);
                                make.top.mas_equalTo(tempButton.mas_top);
                                make.size.mas_equalTo(itemSize);
                            }];
                        }
                        
                    } else {
                        
                        if (i % 3 == 0) {
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.leading.mas_equalTo(self.guidContentView.mas_leading).offset(14);
                                make.top.mas_equalTo(tempButton.mas_bottom);
                                make.size.mas_equalTo(itemSize);
                            }];
                            
                        } else {
                            
                            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.leading.mas_equalTo(tempButton.mas_trailing).offset(8);
                                make.top.mas_equalTo(tempButton.mas_top);
                                make.size.mas_equalTo(itemSize);
                            }];
                        }
                    }
                    
                    
                } else {
                    if (APP_TYPE == 3) {
                        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.leading.mas_equalTo(self.guidContentView.mas_leading);
                            make.top.mas_equalTo(self.guidContentView.mas_top).offset(40);
                            make.size.mas_equalTo(itemSize);
                        }];
                    } else {
                        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.leading.mas_equalTo(self.guidContentView.mas_leading).offset(14);
                            make.top.mas_equalTo(self.guidContentView.mas_top).offset(40);
                            make.size.mas_equalTo(itemSize);
                        }];
                    }
                    
                }
                [btn imageUrl:guideModel.imageURL name:guideModel.name];
                
                tempButton = btn;
            }
            
            if (APP_TYPE == 3) {
                [self.guidContentView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.cycleContentView.mas_bottom).offset(model.banner.count == 0 ? 0 : 12);
                    make.height.mas_equalTo(40 + ((model.guide.count - 1)/2 + 1) * (itemSize.height));
                }];
                
            } else {
                [self.guidContentView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.cycleContentView.mas_bottom).offset(model.banner.count == 0 ? 0 : 12);
                    make.height.mas_equalTo(40 + ((model.guide.count - 1)/3 + 1) * (itemSize.height));
                }];
            }
            
        } else {
            
            self.guidContentView.hidden = YES;
            [self.guidContentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.cycleContentView.mas_bottom).offset(0);
                make.height.mas_equalTo(0);
            }];
        }
    }
}

- (UIView *)collectBackGroundView {
    if (!_collectBackGroundView) {
        _collectBackGroundView = [UIView new];
        _collectBackGroundView.backgroundColor = [STLThemeColor col_F5F5F5];
        _collectBackGroundView.userInteractionEnabled = YES;
        if (APP_TYPE == 3) {
            _collectBackGroundView.backgroundColor = [STLThemeColor stlWhiteColor];
        }
    }
    return _collectBackGroundView;
}

- (UIView *)cycleContentView {
    if (!_cycleContentView) {
        _cycleContentView = [UIView new];
        _cycleContentView.backgroundColor = [STLThemeColor stlWhiteColor];
        if (APP_TYPE == 3) {
            
        } else {
            _cycleContentView.layer.cornerRadius = 6.f;
            _cycleContentView.layer.masksToBounds = YES;
            _cycleContentView.userInteractionEnabled = YES;
        }
        
    }
    return _cycleContentView;
}

- (SDCycleScrollView *)cycleScrollView {
    if (!_cycleScrollView) {
//        _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:[UIImage imageNamed:@"placeholder_banner_pdf"]];
        _cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:nil];
        _cycleScrollView.backgroundColor = [STLThemeColor col_EEEEEE];
        _cycleScrollView.autoScrollTimeInterval = 3.0; // 间隔时间
//        _cycleScrollView.currentPageDotColor = [STLThemeColor col_262626];
        
        if (APP_TYPE == 3) {
            _cycleScrollView.currentPageDotImage = [UIImage imageNamed:@"spic_dot_black"];
            _cycleScrollView.pageDotImage = [UIImage imageNamed:@"spic_dot_gray"];
        } else {
            _cycleScrollView.currentPageDotImage = [UIImage imageNamed:@"progress_black"];
            _cycleScrollView.pageDotImage = [UIImage imageNamed:@"progress_white"];
            
        }
//        _cycleScrollView.pageDotColor = STLThemeColor.col_F1F1F1;
        _cycleScrollView.pageControlBottomOffset = 10;
        _cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
        _cycleScrollView.clipsToBounds = YES;
        _cycleScrollView.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _cycleScrollView;
}

- (UIView *)guidContentView {
    if (!_guidContentView) {
        _guidContentView = [UIView new];
        _guidContentView.backgroundColor = [STLThemeColor stlWhiteColor];
        if (APP_TYPE == 3) {
            
        } else {
            _guidContentView.layer.cornerRadius = 6;
            _guidContentView.layer.masksToBounds = YES;
        }
    }
    return _guidContentView;
}

- (UILabel *)featuredLabel
{
    if (!_featuredLabel)
    {
        self.featuredLabel = [UILabel new];
        self.featuredLabel.backgroundColor = [STLThemeColor stlWhiteColor];
        self.featuredLabel.textColor = [STLThemeColor stlBlackColor];
        if (APP_TYPE == 3) {
            self.featuredLabel.font = [UIFont boldSystemFontOfSize:14];
            self.featuredLabel.text = [NSString stringWithFormat:@"%@",STLLocalizedString_(@"featuredProduct", nil)];

        } else {
            self.featuredLabel.font = [UIFont boldSystemFontOfSize:12];
            self.featuredLabel.text = [NSString stringWithFormat:@"%@",STLLocalizedString_(@"featuredProduct", nil).uppercaseString];

        }
    }
    return _featuredLabel;
}
@end




@implementation STLCateBannerGuidItemView

- (instancetype)initWithFrame:(CGRect)frame;
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [STLThemeColor stlWhiteColor];
        
        STLProductImagePlaceholder *featuredImageView = [[STLProductImagePlaceholder alloc] initWithFrame:CGRectZero isCategory:YES];
        self.featuredImageView = featuredImageView;
        featuredImageView.userInteractionEnabled = NO;
        featuredImageView.backgroundColor = [STLThemeColor stlWhiteColor];

        featuredImageView.frame = CGRectZero;
        featuredImageView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        featuredImageView.imageView.clipsToBounds = YES;
        featuredImageView.grayView.hidden = YES;
        [self addSubview:featuredImageView];
        
        UILabel *featuredtitleLabel = [UILabel new];
        self.featuredtitleLabel = featuredtitleLabel;
        
        featuredtitleLabel.backgroundColor = [UIColor clearColor];
        featuredtitleLabel.textColor = [STLThemeColor col_6C6C6C];
        featuredtitleLabel.numberOfLines = 2;
        featuredtitleLabel.font = [UIFont systemFontOfSize:12];
        featuredtitleLabel.textAlignment = NSTextAlignmentCenter;
        featuredtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:featuredtitleLabel];
        
        [self.featuredImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.top.mas_equalTo(self);
            make.height.mas_equalTo(self.featuredImageView.mas_width);
            
        }];
        
        [featuredtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.top.mas_equalTo(self.featuredImageView.mas_bottom).offset(4);
        }];
    }
    return self;
}

- (void)imageUrl:(NSString *)imageUrl name:(NSString *)name {
    
    [self.featuredImageView.imageView yy_setImageWithURL:[NSURL URLWithString:imageUrl]
                          placeholder:[UIImage imageNamed:@"category_placed"]
                              options:kNilOptions
                             progress:nil
                            transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
    
                                __block UIImage * blockImage = image;
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    blockImage = [image yy_imageByResizeToSize:CGSizeMake(self.featuredImageView.bounds.size.width, self.featuredImageView.bounds.size.height) contentMode:UIViewContentModeScaleAspectFill];
                                });
                                return blockImage;
                            }
                           completion:nil];
    
    self.featuredtitleLabel.text = STLToString(name);

}

@end
