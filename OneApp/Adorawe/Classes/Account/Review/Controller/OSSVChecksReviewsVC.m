//
//  OSSVChecksReviewsVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVChecksReviewsVC.h"
#import "OSSVCheckeRevieweViewModel.h"
#import "OSSVChecksReviewssModel.h"
#import "PhotoBroswerVC.h"
#import "ZZStarView.h"
#import "STLPhotoBrowserView.h"

@interface OSSVChecksReviewsVC ()
@property (nonatomic,weak) UIScrollView         *bottomView;
@property (nonatomic,weak) UIView               *containerView;
//商品
@property (nonatomic,weak) UIView               *topView;
@property (nonatomic,weak) YYAnimatedImageView  *goodsImg;
@property (nonatomic,weak) UILabel              *goodsTitle;
@property (nonatomic,weak) UILabel              *goodsAttr;
@property (nonatomic,weak) UILabel              *goodsPrice;
//评论
@property (nonatomic,weak) UIView               *reviewView;
@property (nonatomic,weak) YYAnimatedImageView  *userIcon;
@property (nonatomic,weak) UILabel              *userName;
@property (nonatomic,weak) ZZStarView    *starRating;//等级评分
@property (nonatomic,weak) UILabel              *addTime;
@property (nonatomic,weak) UILabel              *userFeedback;
@property (nonatomic,weak) UIView               *pictureView;

@property (nonatomic,strong) NSMutableArray     *pictureArray;

@property (nonatomic,strong) MASConstraint      *pictureHight;

@property (nonatomic, strong) OSSVCheckeRevieweViewModel *viewModel;

@property (nonatomic,strong) NSMutableArray<STLPhotoGroupItem *>     *showPictureArray;
@end

@implementation OSSVChecksReviewsVC

- (NSMutableArray*)pictureArray {
    if (!_pictureArray) {
        _pictureArray = [[NSMutableArray alloc] init];
    }
    return _pictureArray;
}

- (NSMutableArray<STLPhotoGroupItem *> *)showPictureArray{
    if (!_showPictureArray) {
        _showPictureArray = [[NSMutableArray alloc] init];
    }
    return _showPictureArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"myReview",nil);
    
    [self initView];
    [self requestLoadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 谷歌统计
    if (!self.firstEnter) {
    }
    self.firstEnter = YES;
}

- (OSSVCheckeRevieweViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVCheckeRevieweViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (void)initView {
    __weak typeof(self.view) ws = self.view;
    
    UIScrollView *bottomView = [[UIScrollView alloc] initWithFrame:CGRectZero];;
    bottomView.showsVerticalScrollIndicator = NO;
    [ws addSubview:bottomView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (kIS_IPHONEX) {
            make.edges.mas_equalTo(ws).insets(UIEdgeInsetsMake(0, 0, STL_TABBAR_IPHONEX_H, 0));
        } else {
            make.edges.mas_equalTo(ws).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }
    }];
    self.bottomView = bottomView;
    
    UIView *containerView = [UIView new];
    containerView.backgroundColor = OSSVThemesColors.col_F5F5F5;
    [bottomView addSubview:containerView];
    
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(UIEdgeInsetsMake(12, 12, 12, 0));
        make.width.mas_equalTo(SCREEN_WIDTH - 24);
    }];
    containerView.layer.cornerRadius = 6;
    containerView.layer.masksToBounds = true;
    self.containerView = containerView;
    
    ///--------------------用户信息--------------------------------
    UIView *reviewView = [UIView new];
    reviewView.backgroundColor = OSSVThemesColors.col_FFFFFF;
    [containerView addSubview:reviewView];
    
    [reviewView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(topView.mas_bottom).offset(1);
        make.top.mas_equalTo(containerView.mas_top);
        make.leading.mas_equalTo(containerView.mas_leading);
        make.trailing.mas_equalTo(containerView.mas_trailing);
//        make.bottom.mas_equalTo(containerView.mas_bottom);
    }];
    self.reviewView = reviewView;
    
    YYAnimatedImageView *userIcon = [YYAnimatedImageView new];
    userIcon.contentMode = UIViewContentModeScaleAspectFill;
    userIcon.layer.cornerRadius = 12;
    userIcon.layer.masksToBounds = YES;
    [reviewView addSubview:userIcon];
    
    [userIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(reviewView.mas_top).offset(14);
        make.leading.mas_equalTo(reviewView.mas_leading).offset(14);
        make.width.height.mas_equalTo(24);
    }];
    self.userIcon = userIcon;

    UILabel *userName = [UILabel new];
    userName.font = [UIFont systemFontOfSize:14];
    userName.textColor = [OSSVThemesColors col_0D0D0D];
    [reviewView addSubview:userName];
    
    [userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(userIcon.mas_centerY);
        make.leading.mas_equalTo(userIcon.mas_trailing).offset(4);
    }];
    self.userName = userName;
    
    ZZStarView *starRating = [[ZZStarView alloc] initWithImage:[UIImage imageNamed:@"star_small_review"] selectImage:[UIImage imageNamed:@"star_small_review_h"] starWidth:14 starHeight:14 starMargin:2 starCount:5 callBack:^(CGFloat userGrade, CGFloat finalGrade) {
        
    }];
    starRating.sublevel = 1;
    starRating.userInteractionEnabled = NO;
    starRating.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        starRating.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
    [reviewView addSubview:starRating];
    
    [starRating mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(userName.mas_centerY);
        make.leading.mas_equalTo(userName.mas_trailing).offset(4);
        make.height.mas_equalTo(@14);
        make.width.mas_equalTo(@78);
    }];
    self.starRating = starRating;
    self.starRating.hidden = YES;

    //评论内容
    UILabel *userFeedback = [UILabel new];
    userFeedback.font = [UIFont systemFontOfSize:14];
    userFeedback.textColor = OSSVThemesColors.col_6C6C6C;
    userFeedback.numberOfLines = 0;
    [reviewView addSubview:userFeedback];
    
    [userFeedback mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(userIcon.mas_bottom).offset(8);
        make.leading.mas_equalTo(userIcon.mas_leading);
        make.trailing.mas_equalTo(reviewView.mas_trailing).offset(-10);
    }];


    self.userFeedback = userFeedback;
    
    UILabel *addTime  = [UILabel new];
    addTime.font = [UIFont systemFontOfSize:12];
    addTime.textColor = OSSVThemesColors.col_B2B2B2;
    [reviewView addSubview:addTime];
    
    [addTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(userFeedback.mas_bottom).offset(8);
        make.leading.mas_equalTo(userIcon.mas_leading);
    }];
    self.addTime = addTime;


    UIView *pictureView = [UIView new];
    [reviewView addSubview:pictureView];
    
    [pictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(addTime.mas_bottom).offset(8);
        make.leading.mas_equalTo(userFeedback.mas_leading);
        make.bottom.mas_equalTo(reviewView.mas_bottom).offset(-8);
        self.pictureHight = make.height.mas_equalTo(@0);
    }];
    self.pictureView = pictureView;
    ///--------------------用户信息--------------------------------
    ///
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = OSSVThemesColors.col_EEEEEE;
    [reviewView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(14);
        make.trailing.equalTo(-14);
        make.height.equalTo(0.5);
        make.bottom.equalTo(0);
    }];
    
    UIView *topView = [UIView new];
    topView.backgroundColor = OSSVThemesColors.col_FFFFFF;
    [containerView addSubview:topView];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(reviewView.mas_bottom);
//        make.top.mas_equalTo(containerView.mas_top);
        make.leading.mas_equalTo(containerView.mas_leading);
        make.trailing.mas_equalTo(containerView.mas_trailing);
        make.bottom.equalTo(containerView.mas_bottom);
    }];
    self.topView = topView;
    
    YYAnimatedImageView *goodsImg = [[YYAnimatedImageView alloc] init];
    goodsImg.layer.borderWidth = 0.5;
    goodsImg.layer.borderColor = OSSVThemesColors.col_EEEEEE.CGColor;
    [topView addSubview:goodsImg];
    goodsImg.layer.masksToBounds = true;
    goodsImg.contentMode = UIViewContentModeScaleAspectFill;
    
    [goodsImg mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.mas_equalTo(topView.mas_top).offset(8);
        make.bottom.mas_equalTo(topView.mas_bottom).offset(-14);
        make.leading.mas_equalTo(topView.mas_leading).offset(14);
        make.size.mas_equalTo(CGSizeMake(60, 80));
    }];
    self.goodsImg = goodsImg;
    
    UILabel *goodsTitle = [[UILabel alloc] init];
    goodsTitle.numberOfLines = 1;
    goodsTitle.textColor = OSSVThemesColors.col_6C6C6C;
    goodsTitle.font = [UIFont systemFontOfSize:12];
    [topView addSubview:goodsTitle];
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        goodsTitle.lineBreakMode = NSLineBreakByTruncatingHead;
    }
    
    [goodsTitle mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(goodsImg.mas_top);
        make.leading.equalTo(goodsImg.mas_trailing).offset(10);
        make.trailing.mas_equalTo(topView.mas_trailing).offset(-16);
    }];
    self.goodsTitle = goodsTitle;
    
    UILabel *goodsAttr = [[UILabel alloc] init];
    goodsAttr.textColor = OSSVThemesColors.col_6C6C6C;
    goodsAttr.font = [UIFont boldSystemFontOfSize:14];
    [topView addSubview:goodsAttr];
    
    [goodsAttr mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(goodsTitle.mas_bottom).offset(5);
        make.leading.equalTo(goodsTitle.mas_leading);
        make.trailing.mas_equalTo(@(-10));
    }];
    self.goodsAttr = goodsAttr;
    
    UILabel *goodsPrice = [[UILabel alloc] init];
    goodsPrice.textColor = [UIColor grayColor];
    goodsPrice.font = [UIFont systemFontOfSize:14];
    [topView addSubview:goodsPrice];
    
    [goodsPrice mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(goodsAttr.mas_bottom).offset(5);
        make.leading.equalTo(goodsAttr.mas_leading);
        make.trailing.mas_equalTo(@(-10));
    }];
    self.goodsPrice = goodsPrice;
    //1.4.6 隐藏
    self.goodsPrice.hidden = true;
    
    
}

#pragma mark - Method
- (void)requestLoadData {
    @weakify(self)
    [self.viewModel requestNetwork:@{@"goods_id" : STLToString(_goodsModel.goodsId) } completion:^(id obj) {
        @strongify(self)
        if ([obj[@"status"] boolValue]) {
            OSSVChecksReviewssModel *model = obj[@"model"];
            [self updateSubviewsWithCheckReviewModel:model];
        }
    } failure:^(id obj) {
        
    }];
}

- (void)updateSubviewsWithCheckReviewModel:(OSSVChecksReviewssModel *)model {
    
    [self.goodsImg yy_setImageWithURL:[NSURL URLWithString:_goodsModel.goodsThumb]
                          placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                              options:kNilOptions
                             progress:nil
                            transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
//                                        image = [image yy_imageByResizeToSize:CGSizeMake(80,80) contentMode:UIViewContentModeScaleAspectFill];
                                        return image;
                                    }
                           completion:nil];
    self.goodsTitle.text = _goodsModel.goodsName;
    self.goodsAttr.text = _goodsModel.goodsAttr;
    
    self.goodsPrice.text = STLToString(_goodsModel.goods_price_converted);
    
    if (!model.content) {
        return;
    }
    [self.userIcon yy_setImageWithURL:[NSURL URLWithString:model.avatar]
                          placeholder:[UIImage imageNamed:@"user_photo_new"]
                              options:YYWebImageOptionShowNetworkActivity
                             progress:nil
                            transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                                return image;
                                        }
                           completion:nil];
    
    NSString *userName = STLToString(model.nickname);
    if (userName.length > 3) {
        userName = [NSString stringWithFormat:@"%@***",[userName substringToIndex:3]];
    } else if(userName.length == 0) {
        userName = @"***";
    }
    self.userName.text = userName;
    self.starRating.hidden = NO;
    self.starRating.grade = model.rateCount;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    if (OSSVSystemsConfigsUtils.isRightToLeftShow) {
        [dateFormatter setDateFormat:@"hh:mm dd-MM-YYYY"];
    }else{
        [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm"];
    }
    
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.addTime]];
    self.addTime.text = currentDateStr;
    self.userFeedback.text = model.content;
    
    if (!STLJudgeEmptyArray(model.reviewPic)) {
        CGFloat imgW = (SCREEN_WIDTH - 26 * 2 - 8) / 3;
        self.pictureHight.mas_equalTo(imgW);
        [self.showPictureArray removeAllObjects];
        if (model.reviewPic.count  == 1) {
            
            NSString *img = [[model.reviewPic firstObject] valueForKey:@"origin_pic"];
            YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [imageView yy_setImageWithURL:[NSURL URLWithString:img]
                              placeholder:nil
                                  options:kNilOptions
                                 progress:nil
                                transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
//                                                image = [image yy_imageByResizeToSize:CGSizeMake(80,80) contentMode:UIViewContentModeScaleAspectFill];
                                                return image;
                                            }
                               completion:nil];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouch:)]];
            
            STLPhotoGroupItem *showPicItem = [[STLPhotoGroupItem alloc] init];
            [self.showPictureArray addObject:showPicItem];
            showPicItem.largeImageURL = [NSURL URLWithString:img];
            showPicItem.thumbView = imageView;
            
            [self.pictureView addSubview:imageView];
            [self.pictureArray addObject:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.pictureView.mas_top);
                make.bottom.mas_equalTo(self.pictureView.mas_bottom);
                make.leading.mas_equalTo(self.pictureView.mas_leading);
                make.width.height.mas_equalTo(imgW);
            }];
            
        }else {
            if ( model.reviewPic.count > 3) {
                model.reviewPic = [model.reviewPic subarrayWithRange:NSMakeRange(0, 3)];
            }
            [model.reviewPic enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
                imageView.layer.borderWidth = 0.5;
                imageView.layer.borderColor = OSSVThemesColors.col_F1F1F1.CGColor;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.clipsToBounds = YES;
                [imageView yy_setImageWithURL:[NSURL URLWithString:[[model.reviewPic objectAtIndex:idx] valueForKey:@"origin_pic"]]
                                  placeholder:nil
                                      options:kNilOptions
                                     progress:nil
                                    transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
//                                                    image = [image yy_imageByResizeToSize:CGSizeMake(80, 80) contentMode:UIViewContentModeScaleToFill];
                                                    return image;
                                                }
                                   completion:nil];
                imageView.userInteractionEnabled = YES;
                imageView.tag = idx;
                [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouch:)]];
                [self.pictureView addSubview:imageView];
                [self.pictureArray addObject:imageView];
                
                STLPhotoGroupItem *showPicItem = [[STLPhotoGroupItem alloc] init];
                [self.showPictureArray addObject:showPicItem];
                showPicItem.largeImageURL = [NSURL URLWithString:[[model.reviewPic objectAtIndex:idx] valueForKey:@"origin_pic"]];
                showPicItem.thumbView = imageView;

            }];
            [self.pictureArray mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:4 leadSpacing:0 tailSpacing:0];
            [self.pictureArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.pictureView.mas_top);
                make.bottom.mas_equalTo(self.pictureView.mas_bottom);
                make.width.height.mas_equalTo(imgW);
            }];
        }
    }else {
        self.pictureHight.mas_equalTo(@0);
    }
}


- (void)imageTouch:(UITapGestureRecognizer *)tap {

    
    STLPhotoBrowserView *groupView = [[STLPhotoBrowserView alloc]initWithGroupItems:self.showPictureArray];
    groupView.isDismissToFirstPosition = YES;
    groupView.showDismiss = YES;
    UIViewController *superCtrl = self;
    [groupView presentFromImageView:tap.view toContainer:superCtrl.navigationController.view animated:YES completion:nil];
}

@end
