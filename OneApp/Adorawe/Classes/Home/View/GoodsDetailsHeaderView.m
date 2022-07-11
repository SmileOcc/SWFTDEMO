//
//  GoodsDetailsHeaderView.m
//  Yoshop
//
//  Created by huangxieyue on 16/5/30.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "GoodsDetailsHeaderView.h"
#import "GoodsDescriptionViewController.h"
#import "GoodsReviewsViewController.h"
#import "GoodsDetailsSelectView.h"
#import "StarRatingControl.h"
#import "PhotoBroswerVC.h"
#import "GoodsDetailsListModel.h"
#import "GoodsDetailsBaseInfoModel.h"

@interface GoodsDetailsHeaderView () <UIScrollViewDelegate>
@property (nonatomic,weak) UIView *pictureBottomView; //商品相册
@property (nonatomic,weak) UIView *detailsBottomView; //商品详情
@property (nonatomic,weak) UIView *attributeBottomView; //商品属性
@property (nonatomic,weak) UIView *describeBottomView; //商品描述
@property (nonatomic,weak) UIView *reviewsBottomView; //商品评论
@property (nonatomic,weak) UIView *recommentionsTitleView; //推荐商品标题

@property (nonatomic,weak) UIImageView *describeButton; //跳转商品描述页
@property (nonatomic,weak) UIImageView *attributeButton; //上拉弹出商品属性页
@property (nonatomic,weak) UILabel *attributeTitleLabel; //显示选中属性
@property (nonatomic,weak) UILabel *detailsPriceLabel; //商品价格
@property (nonatomic,weak) UILabel *detailsPastPriceLabel; //商品以往价格
@property (nonatomic,weak) UILabel *detailsNameLabel; //商品名称
@property (nonatomic,weak) UILabel *detailsDispatchLabel; //派件时间
@property (nonatomic,weak) UILabel *detailsDiscount; //折扣率
@property (nonatomic,weak) UILabel *reviewsTitleLabel; //评论条数
@property (nonatomic,weak) UIButton *collectionButton; //收藏
@property (nonatomic,weak) UIView *alphaView; //遮板
@property (nonatomic, weak) StarRatingControl *starRating; //商品总评分星级

@property (nonatomic,strong) NSMutableArray *pictureArray;
@property (nonatomic,weak) UIPageControl *picturePage;
@property (nonatomic,assign) int index;

@property (nonatomic,strong) GoodsDetailsSelectView *goodsDetailsSelectView;
@end

@implementation GoodsDetailsHeaderView

- (NSMutableArray*)pictureArray {
    if (!_pictureArray) {
        _pictureArray = [[NSMutableArray alloc] init];
    }
    return _pictureArray;
}

+(GoodsDetailsHeaderView*)goodsDetailsHeaderWithCollectionView:(UICollectionView *)collectionView Kind:(NSString *)kind IndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [collectionView registerClass:[GoodsDetailsHeaderView class] forSupplementaryViewOfKind:kind withReuseIdentifier:GOODS_DETAILS_HEADER_INENTIFIER];
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:GOODS_DETAILS_HEADER_INENTIFIER forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        __weak typeof(self) ws = self;
        
        UIView *pictureBottomView = [UIView new];
        pictureBottomView.backgroundColor = YSCOLOR_WHITE;
        [ws addSubview:pictureBottomView];
        
        [pictureBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.mas_top);
            make.leading.mas_equalTo(ws.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing);
            make.height.mas_equalTo(350*DSCREEN_HEIGHT_SCALE);
        }];
        self.pictureBottomView = pictureBottomView;
        
        UIScrollView *pictureScrollView = [UIScrollView new];
        pictureScrollView.backgroundColor = YSCOLOR_WHITE;
        pictureScrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 5, 330);
        pictureScrollView.pagingEnabled = YES;
        pictureScrollView.showsHorizontalScrollIndicator = NO;
        pictureScrollView.delegate = self;
        [pictureBottomView addSubview:pictureScrollView];
        
        [pictureScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(pictureBottomView.mas_top);
            make.leading.mas_equalTo(pictureBottomView.mas_leading);
            make.trailing.mas_equalTo(pictureBottomView.mas_trailing);
            make.height.mas_equalTo(DSCREEN_HEIGHT_SCALE * 330);
        }];
        
        for (int i = 0; i < 5; i++) {
            UIImageView *imageView = [UIImageView new];
            imageView.image = [UIImage imageNamed:@"Snip"];
            imageView.userInteractionEnabled = YES;
            imageView.tag = i;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouch:)]];
            [pictureScrollView addSubview:imageView];
            [self.pictureArray addObject:imageView];
        }
        
        [self.pictureArray mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
        [self.pictureArray mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.height.mas_equalTo(330 * DSCREEN_HEIGHT_SCALE);
            make.centerY.mas_equalTo(pictureScrollView.mas_centerY);
        }];
        
        UIPageControl *picturePage = [UIPageControl new];
        picturePage.pageIndicatorTintColor = YSCOLOR(221, 221, 221, 1.0);
        picturePage.currentPageIndicatorTintColor = YSCOLOR(255, 219, 78, 1.0);
        picturePage.numberOfPages = self.pictureArray.count;
        [pictureBottomView addSubview:picturePage];
        
        [picturePage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(pictureBottomView.mas_leading).offset(15);
            make.top.mas_equalTo(pictureScrollView.mas_bottom).offset(5);
            make.bottom.mas_equalTo(pictureBottomView.mas_bottom).offset(-5);
        }];
        self.picturePage = picturePage;
        
        UIView *detailsBottomView = [UIView new];
        detailsBottomView.backgroundColor = YSCOLOR_WHITE;
        [ws addSubview:detailsBottomView];
        
        [detailsBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(pictureBottomView.mas_bottom);
            make.leading.mas_equalTo(ws.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing);
            make.height.mas_equalTo(@110);
        }];
        self.detailsBottomView = detailsBottomView;
        
        UIButton *goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [goBackButton setImage:[UIImage imageNamed:@"nav_detail_ro_left"] forState:UIControlStateNormal];
        [goBackButton addTarget:self action:@selector(touchGoBackBtn) forControlEvents:UIControlEventTouchDown];
        [ws addSubview:goBackButton];
        [goBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.mas_top).offset(10);
            make.leading.mas_equalTo(ws.mas_leading).offset(10);
            make.width.mas_equalTo(@30);
            make.height.mas_equalTo(goBackButton.mas_width);
        }];
        
        UIButton *collectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [collectionButton setBackgroundImage:[UIImage imageNamed:@"collect-0"] forState:UIControlStateNormal];
        [collectionButton setBackgroundImage:[UIImage imageNamed:@"collect_selected"] forState:UIControlStateSelected];
        collectionButton.backgroundColor = [UIColor clearColor];
        [collectionButton addTarget:self action:@selector(collectionButton:) forControlEvents:UIControlEventTouchDown];
        [ws addSubview:collectionButton];
        [collectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(pictureBottomView.mas_bottom);
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-20);
            make.width.mas_equalTo(@40);
            make.height.mas_equalTo(collectionButton.mas_width);
        }];
        self.collectionButton = collectionButton;
        
        UIView *line = [UIView new];
        line.backgroundColor = YSCOLOR(246, 246, 246, 1.0);
        [ws addSubview:line];
        
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(ws.mas_leading);
            make.trailing.mas_equalTo(collectionButton.mas_leading);
            make.centerY.mas_equalTo(collectionButton.mas_centerY);
            make.height.mas_equalTo(@1);
        }];
        
        UIView *line1 = [UIView new];
        line1.backgroundColor = YSCOLOR(246, 246, 246, 1.0);
        [ws addSubview:line1];
        
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(collectionButton.mas_trailing);
            make.trailing.mas_equalTo(ws.mas_trailing);
            make.centerY.mas_equalTo(collectionButton.mas_centerY);
            make.height.mas_equalTo(@1);
        }];
        
        UILabel *detailsPriceLabel = [UILabel new];
        detailsPriceLabel.text = @"$13.52";
        detailsPriceLabel.textColor = YSCOLOR(51, 51, 51, 1.0);
        [detailsPriceLabel setFont:[UIFont fontWithName:FONT_BOLD size:20]];
        [detailsBottomView addSubview:detailsPriceLabel];
        
        [detailsPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(detailsBottomView.mas_leading).offset(10);
            make.top.mas_equalTo(detailsBottomView.mas_top).offset(20);
        }];
        self.detailsPriceLabel = detailsPriceLabel;
        
        UILabel *detailsPastPriceLabel = [UILabel new];
        detailsPastPriceLabel.text = @"$36.89";
        detailsPastPriceLabel.textColor = YSCOLOR(153, 153, 153, 1.0);
        detailsPastPriceLabel.font = [UIFont systemFontOfSize:12];
        [detailsBottomView addSubview:detailsPastPriceLabel];
        
        [detailsPastPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(detailsPriceLabel.mas_trailing).offset(8);
            make.bottom.mas_equalTo(detailsPriceLabel.mas_bottom);
        }];
        self.detailsPastPriceLabel = detailsPastPriceLabel;
        
        UIView *deleteLine = [UIView new];
        deleteLine.backgroundColor = YSCOLOR(153, 153, 153, 1.0);
        [detailsBottomView addSubview:deleteLine];
        
        [deleteLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(detailsPastPriceLabel.mas_leading);
            make.trailing.mas_equalTo(detailsPastPriceLabel.mas_trailing);
            make.centerY.mas_equalTo(detailsPastPriceLabel.mas_centerY);
            make.height.mas_equalTo(@0.5);
        }];
        
        UILabel *detailsDiscount = [UILabel new];
        detailsDiscount.font = [UIFont systemFontOfSize:14];
        detailsDiscount.textColor = YSCOLOR(51, 51, 51, 1.0);
        detailsDiscount.text = @"40% OFF";
        detailsDiscount.backgroundColor = YSCOLOR(255, 219, 78, 1.0);
        [detailsBottomView addSubview:detailsDiscount];
        
        [detailsDiscount mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(detailsPastPriceLabel.mas_trailing).offset(8);
            make.centerY.mas_equalTo(detailsPastPriceLabel.mas_centerY);
        }];
        self.detailsDiscount = detailsDiscount;
        
        UILabel *detailsNameLabel = [UILabel new];
        detailsNameLabel.numberOfLines = 2;
        detailsNameLabel.font = [UIFont fontWithName:FONT_HIGHT size:14];
        detailsNameLabel.text = @"RITECH Universal Virtual Reality 3D Glasses Ⅱ with Elastic Band Smartphone";
        detailsNameLabel.textColor = YSCOLOR(51, 51, 51, 1.0);
        [detailsBottomView addSubview:detailsNameLabel];
        
        [detailsNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(detailsBottomView.mas_leading).offset(10);
            make.trailing.mas_equalTo(detailsBottomView.mas_trailing).offset(-10);
            make.top.mas_equalTo(detailsPriceLabel.mas_bottom).offset(16);
            make.bottom.mas_equalTo(detailsBottomView.mas_bottom).offset(-10);
        }];
        self.detailsNameLabel = detailsNameLabel;
        
        UIView *otherBottomView = [UIView new];
        otherBottomView.backgroundColor = YSCOLOR(248, 248, 248, 1.0);
        [ws addSubview:otherBottomView];
        
        [otherBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(detailsBottomView.mas_bottom).offset(0.5);
            make.leading.mas_equalTo(ws.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing);
            make.height.mas_equalTo(@65);
        }];
        
        UILabel *detailsDispatchLabel = [UILabel new];
        detailsDispatchLabel.text = @"Dispatch:Within 3-5 Business Days";
        detailsDispatchLabel.textColor = YSCOLOR(153, 153, 153, 1.0);
        detailsDispatchLabel.font = [UIFont fontWithName:FONT_HIGHT size:12];
        [otherBottomView addSubview:detailsDispatchLabel];
        
        [detailsDispatchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(otherBottomView.mas_top).offset(15);
            make.leading.mas_equalTo(detailsBottomView.mas_leading).offset(10);
            make.trailing.mas_equalTo(detailsBottomView.mas_trailing).offset(-10);
        }];
        self.detailsDispatchLabel = detailsDispatchLabel;
        
        UIButton *freeShipping = [UIButton new];
        [freeShipping setImage:[UIImage imageNamed:@"free_icon"] forState:UIControlStateNormal];
        [freeShipping setTitle:@"Free Shipping" forState:UIControlStateNormal];
        [freeShipping setTitleColor:YSCOLOR(255, 111, 0, 1.0) forState:UIControlStateNormal];
        freeShipping.titleLabel.font = [UIFont systemFontOfSize:12];
        [freeShipping setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [freeShipping setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [otherBottomView addSubview:freeShipping];
        
        [freeShipping mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(otherBottomView.mas_leading).offset(10);
            make.top.mas_equalTo(detailsDispatchLabel.mas_bottom).offset(10);
            make.bottom.mas_equalTo(otherBottomView.mas_bottom).offset(-5);
            make.width.mas_equalTo(@100);
        }];
        
        UIButton *refund = [UIButton new];
        [refund setImage:[UIImage imageNamed:@"refund_icon"] forState:UIControlStateNormal];
        [refund setTitle:@"Refund Within 45 Days" forState:UIControlStateNormal];
        [refund setTitleColor:YSCOLOR(33, 153, 243, 1.0) forState:UIControlStateNormal];
        refund.titleLabel.font = [UIFont systemFontOfSize:12];
        [refund setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [refund setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [otherBottomView addSubview:refund];
        
        [refund mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(freeShipping.mas_trailing).offset(10);
            make.centerY.mas_equalTo(freeShipping.mas_centerY);
            make.width.mas_equalTo(@150);
        }];
        
        UIView *attributeBottomView = [UIView new];
        attributeBottomView.userInteractionEnabled = YES;
        attributeBottomView.backgroundColor = YSCOLOR_WHITE;
        [ws addSubview:attributeBottomView];
        
        [attributeBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(otherBottomView.mas_bottom).offset(10);
            make.leading.mas_equalTo(ws.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing);
            make.height.mas_equalTo(@40);
        }];
        self.attributeBottomView = attributeBottomView;
        
        UILabel *attributeTitleLabel = [UILabel new];
        attributeTitleLabel.font = [UIFont systemFontOfSize:12];
        attributeTitleLabel.textColor = YSCOLOR(53, 53, 53, 1.0);
        attributeTitleLabel.numberOfLines = 1;
        attributeTitleLabel.text = @"Select: XIAOMI Note2/ 16GB/ SILVER";
        [attributeBottomView addSubview:attributeTitleLabel];
        
        [attributeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(attributeBottomView.mas_leading).offset(10);
            make.centerY.mas_equalTo(attributeBottomView.mas_centerY);
        }];
        self.attributeTitleLabel = attributeTitleLabel;
        
        UIImageView *attributeButton = [UIImageView new];
        attributeButton.image = [UIImage imageNamed:@"ro_right"];
        [attributeBottomView addSubview:attributeButton];
        
        [attributeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(attributeBottomView.mas_trailing).offset(-10);
            make.centerY.mas_equalTo(attributeBottomView.mas_centerY);
        }];
        self.attributeButton = attributeButton;
        
        UIView *describeBottomView = [UIView new];
        describeBottomView.userInteractionEnabled = YES;
        describeBottomView.backgroundColor = YSCOLOR_WHITE;
        [ws addSubview:describeBottomView];
        
        [describeBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(attributeBottomView.mas_bottom).offset(10);
            make.leading.mas_equalTo(ws.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing);
            make.height.mas_equalTo(@40);
        }];
        self.describeBottomView = describeBottomView;
        
        UILabel *describeTitleLabel = [UILabel new];
        describeTitleLabel.font = [UIFont systemFontOfSize:12];
        describeTitleLabel.textColor = YSCOLOR(53, 53, 53, 1.0);
        describeTitleLabel.numberOfLines = 1;
        describeTitleLabel.text = @"Description";
        [describeBottomView addSubview:describeTitleLabel];
        
        [describeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(describeBottomView.mas_leading).offset(10);
            make.centerY.mas_equalTo(describeBottomView.mas_centerY);
        }];
        
        UIImageView *describeButton = [UIImageView new];
        describeButton.image = [UIImage imageNamed:@"ro_right"];
        [describeBottomView addSubview:describeButton];
        
        [describeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(describeBottomView.mas_trailing).offset(-10);
            make.centerY.mas_equalTo(describeBottomView.mas_centerY);
        }];
        self.describeButton = describeButton;

        UIView *reviewsBottomView = [UIView new];
        reviewsBottomView.backgroundColor = YSCOLOR_WHITE;
        [ws addSubview:reviewsBottomView];
        
        [reviewsBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(describeBottomView.mas_bottom).offset(1);
            make.leading.mas_equalTo(ws.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing);
            make.height.mas_equalTo(@40);
        }];
        self.reviewsBottomView = reviewsBottomView;
        
        UITapGestureRecognizer *tapAttribute = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAttributeButton:)];
        [attributeBottomView addGestureRecognizer:tapAttribute];
        
        UITapGestureRecognizer *tapDescribe = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDescribeButton:)];
        [describeBottomView addGestureRecognizer:tapDescribe];
        
        UITapGestureRecognizer *tapReviews = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapReviewsBottom:)];
        [reviewsBottomView addGestureRecognizer:tapReviews];

        UILabel *reviewsTitleLabel = [UILabel new];
        reviewsTitleLabel.font = [UIFont systemFontOfSize:12];
        reviewsTitleLabel.textColor = YSCOLOR(53, 53, 53, 1.0);
        reviewsTitleLabel.numberOfLines = 1;
        reviewsTitleLabel.text = @"Reviews(200)";
        [reviewsBottomView addSubview:reviewsTitleLabel];
        
        [reviewsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(reviewsBottomView.mas_leading).offset(10);
            make.centerY.mas_equalTo(reviewsBottomView.mas_centerY);
        }];
        self.reviewsTitleLabel = reviewsTitleLabel;
        
        UIImageView *reviewsButton = [UIImageView new];
        reviewsButton.image = [UIImage imageNamed:@"ro_right"];
        [reviewsBottomView addSubview:reviewsButton];
        
        [reviewsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(reviewsBottomView.mas_trailing).offset(-10);
            make.centerY.mas_equalTo(reviewsBottomView.mas_centerY);
        }];
        
        StarRatingControl *starRating = [[StarRatingControl alloc] initWithFrame:CGRectZero andDefaultStarImage:[UIImage imageNamed:@"reviews_star_a"] highlightedStar:[UIImage imageNamed:@"reviews_star"]];
        starRating.enabled = NO;
        starRating.rating = 4.0;
        starRating.backgroundColor = [UIColor whiteColor];
        starRating.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [reviewsBottomView addSubview:starRating];
        
        [starRating mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(reviewsButton.mas_leading).offset(-20);
            make.centerY.mas_equalTo(reviewsBottomView.mas_centerY);
            make.height.mas_equalTo(@20);
            make.width.mas_equalTo(@100);
        }];
        self.starRating = starRating;
        
        UIView *recommentionsTitleView = [UIView new];
        recommentionsTitleView.backgroundColor = YSCOLOR_WHITE;
        [ws addSubview:recommentionsTitleView];
        
        [recommentionsTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(reviewsBottomView.mas_bottom).offset(1);
            make.leading.mas_equalTo(ws.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing);
            make.height.mas_equalTo(@40);
        }];
        self.recommentionsTitleView = recommentionsTitleView;
        
        UILabel *recommentionsTitleLabel = [UILabel new];
        recommentionsTitleLabel.font = [UIFont systemFontOfSize:12];
        recommentionsTitleLabel.textColor = YSCOLOR(53, 53, 53, 1.0);
        recommentionsTitleLabel.numberOfLines = 1;
        recommentionsTitleLabel.text = @"Recommentions";
        [recommentionsTitleView addSubview:recommentionsTitleLabel];
        
        [recommentionsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(recommentionsTitleView.mas_leading).offset(10);
            make.trailing.mas_equalTo(recommentionsTitleView.mas_trailing).offset(-10);
            make.centerY.mas_equalTo(recommentionsTitleView.mas_centerY);
        }];
    }
    return self;
}

#pragma mark - Jump Description ViewController
- (void)tapDescribeButton:(UITapGestureRecognizer*)sender {
    GoodsDescriptionViewController *descriptionViewController = [GoodsDescriptionViewController new];
    [self.controller.navigationController pushViewController:descriptionViewController animated:YES];
}

#pragma mark - Go Back Next Higher Level
- (void)touchGoBackBtn {
    [self.controller.navigationController popViewControllerAnimated:YES];
    self.controller.navigationController.navigationBarHidden = NO;
}

#pragma mark - Jump Reviews ViewController
- (void)tapReviewsBottom:(UITapGestureRecognizer*)sender {
    GoodsReviewsViewController *reviewsViewController = [GoodsReviewsViewController new];
    [self.controller.navigationController pushViewController:reviewsViewController animated:YES];
}

#pragma mark - Pop-Up Attribute View
- (void)tapAttributeButton:(UITapGestureRecognizer*)sender {
    if (self.goodsSelectedBlock) {
        self.goodsSelectedBlock();
    }
}

#pragma mark - Collection Goods
- (void)collectionButton:(UIButton*)sender {
    sender.selected = !sender.selected;
}

#pragma mark - Listening to the ScrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.index = fabs(scrollView.contentOffset.x) / (scrollView.frame.size.width);
    self.picturePage.currentPage = self.index;
}

#pragma mark - Enlarge images
- (void)imageTouch:(UITapGestureRecognizer *)tap {
    __weak typeof(self) weakSelf=self;
    [PhotoBroswerVC show:self.controller type:PhotoBroswerVCTypeZoom index:tap.view.tag photoModelBlock:^NSArray *{
        NSArray *localImages = [weakSelf.pictureArray subarrayWithRange:NSMakeRange(1, weakSelf.pictureArray.count - 1)];
        NSMutableArray *modelsM = [NSMutableArray arrayWithCapacity:localImages.count];
        for (NSUInteger i = 0; i< localImages.count; i++) {
            PhotoModel *pbModel=[[PhotoModel alloc] init];
            pbModel.mid = i + 1;
            pbModel.image = [localImages[i] valueForKey:@"image"];
            //源frame
            UIImageView *imageV =(UIImageView *) localImages[i];
            pbModel.sourceImageView = imageV;
            [modelsM addObject:pbModel];
        }
        return modelsM;
    }];
}

#pragma mark - Assignment Data
- (void)setHeaderViewModel:(GoodsDetailsListModel *)headerViewModel {
    _headerViewModel = headerViewModel;
    self.detailsPriceLabel.text = [ExchangeManager transforPrice:headerViewModel.goodsBaseInfo.goodsShopPrice];
    self.detailsPastPriceLabel.text = [ExchangeManager transforPrice:headerViewModel.goodsBaseInfo.goodsMarketPrice];
    if ([NSStringUtils isEmptyString:headerViewModel.goodsBaseInfo.goodsDiscount] || [headerViewModel.goodsBaseInfo.goodsDiscount isEqualToString:@"0"]) {
        self.detailsDiscount.text = @"";
    }else {
        self.detailsDiscount.text = [NSString stringWithFormat:@"%@%% OFF",headerViewModel.goodsBaseInfo.goodsDiscount];
    }
    self.detailsNameLabel.text = headerViewModel.goodsBaseInfo.goodsTitle;
//    self.detailsDispatchLabel.text = headerViewModel.goodsBaseInfo.goodsDeliveryTime;
    self.reviewsTitleLabel.text = [NSString stringWithFormat:@"Reviews(%@)",headerViewModel.reviewCount];
    YSLog(@"%@",headerViewModel.isCollect?@"YES":@"NO");
    
    headerViewModel.isCollect ? [self.collectionButton setImage:[UIImage imageNamed:@"collect_selected"] forState:UIControlStateNormal] : [self.collectionButton setImage:[UIImage imageNamed:@"collect_selected"] forState:UIControlStateNormal];
    
}

@end
