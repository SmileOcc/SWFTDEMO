//
//  OSSVDetailReviewCell.m
// XStarlinkProject
//
//  Created by odd on 2021/4/12.
//  Copyright © 2021 starlink. All rights reserved.
//  ----评论内容的cell

#import "OSSVDetailReviewCell.h"

@implementation OSSVDetailReviewCell

+ (CGFloat )heightReplayContent:(NSString *)content {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:4];
    CGSize titleSize = [STLToString(content) textSizeWithFont:[UIFont systemFontOfSize:14]
                                                 constrainedToSize:CGSizeMake(SCREEN_WIDTH - 32, MAXFLOAT)
                                                     lineBreakMode:NSLineBreakByWordWrapping paragraphStyle:paragraphStyle];
    
    if (titleSize.width <= 0) {//没有内容
        titleSize.height = 0;
    } else if (titleSize.height < 21) {//内容没有超过1行
        //titleSize.height = 15;
    }
    
    return titleSize.height;
}

+ (CGFloat )fetchReviewCellHeight:(OSSVReviewsListModel *)model {
    
    // 所有的高
    CGFloat cellAllHeight = 0;
    
    // 用户信息
    CGFloat userHeight = 16 + 40 + 10;
    // 内容
    CGFloat contentHeight = [OSSVDetailReviewCell heightReplayContent:STLToString(model.content)];

//    // 属性
//    CGFloat attributeHeight =  0;
//    if (STLToString(model.attributeStr).length > 0) {
//        attributeHeight = 20;
//    }
    
    // 内容 属性 都没有时，加个间隙
//    if (contentHeight == 0 && attributeHeight == 0) {
//        cellAllHeight += 10;
//    }
    // 商品图片
    CGFloat imgHeight = 0;
    if (model.imgList.count > 0) {
        imgHeight += 90;
    }
    
    // 最后间距
    CGFloat bottomSpace = 16;
    
    cellAllHeight += userHeight + contentHeight  + imgHeight + bottomSpace;
    return cellAllHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        UIView *ws = self.contentView;
        
        [ws addSubview:self.iconImg];
        [ws addSubview:self.userName];
        [ws addSubview:self.starRating];
        [ws addSubview:self.publishedTime];
        [ws addSubview:self.replyLabel];
        [ws addSubview:self.pictureContentView];
        [ws addSubview:self.bottomLineView];
                
        [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.mas_top).offset(16);
            make.leading.mas_equalTo(ws.mas_leading).offset(16);
            make.width.height.mas_equalTo(40);
        }];
        
        [self.userName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconImg.mas_top);
            make.leading.mas_equalTo(self.iconImg.mas_trailing).offset(8);
        }];
        
        [self.starRating mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.userName.mas_centerY);
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-16);
            make.height.mas_equalTo(@12);
            make.width.mas_equalTo(@60);
        }];
        
        [self.publishedTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.iconImg.mas_bottom);
            make.leading.mas_equalTo(self.iconImg.mas_trailing).offset(8);
        }];
        
        [self.replyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconImg.mas_bottom).offset(10);
            make.leading.mas_equalTo(self.iconImg.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-10);
        }];

        [self.pictureContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(ws.mas_bottom).mas_offset(-10);
            make.leading.mas_equalTo(ws.mas_leading).offset(16);
            make.height.mas_equalTo(0);
        }];
        
        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.leading.trailing.mas_equalTo(ws);
            make.height.mas_equalTo(0.5);
        }];
    }
    return self;
}



- (void)setModel:(OSSVReviewsListModel *)model {
    
    if (model == nil) {
        self.iconImg.image = nil;
        self.userName.text = nil;
        self.publishedTime.text = nil;
        self.replyLabel.text = nil;
        return;
    }
    
    _model = model;
    
    [self.layoutArray removeAllObjects];
    [self.picArray removeAllObjects];
    
    NSString *appReviewLocalHost = [STLCommentModule reviewPictureDomainHost];

    
    NSString *userName = STLToString(model.userName);
    if (userName.length > 3) {
        userName = [NSString stringWithFormat:@"%@***",[userName substringToIndex:3]];
    } else if(userName.length == 0) {
        userName = @"***";
    }
    self.userName.text = userName;
    
    self.replyLabel.text = @"";
    if (STLToString(model.content).length > 0) {
        NSMutableParagraphStyle *paragraphStyle  =[[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 4;//连字符
        NSDictionary *attrDict =@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                  NSParagraphStyleAttributeName:paragraphStyle};
        
        NSAttributedString *contentStr =[[NSAttributedString alloc] initWithString:STLToString(model.content) attributes:attrDict];
        
        self.replyLabel.attributedText = contentStr;
        
        self.replyLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            self.replyLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    
    [self.replyLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(model.detailReviewReplayHeight);
        make.top.mas_equalTo(self.iconImg.mas_bottom).mas_offset(model.detailReviewReplayHeight > 0 ? 10 : 0);
    }];
    
    self.starRating.grade = [model.star floatValue];
    
    NSString *userImgUrl = STLToString(model.avatar);
    if (![userImgUrl hasPrefix:@"http"]) {
        userImgUrl = [NSString stringWithFormat:@"%@/%@",appReviewLocalHost,userImgUrl];
    }
    [self.iconImg yy_setImageWithURL:[NSURL URLWithString:userImgUrl]
                         placeholder:[UIImage imageNamed:@"user_photo_new"]
                             options:kNilOptions
                            progress:nil
                           transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                               image = [image yy_imageByResizeToSize:CGSizeMake(80, 80) contentMode:UIViewContentModeScaleAspectFill];
                               return image;
                           }
                          completion:nil];
    
    /*回复时间*/
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
//    [dateFormatter setDateFormat:@"MMM. dd yyyy HH:mm"];
//    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[model.time integerValue]]];
    self.publishedTime.text = [OSSVCommonsManagers dateFormatString:[OSSVCommonsManagers sharedManager].arReviewDateTimeFormatter time:STLToString(model.time)];;
    
    NSMutableArray *pictureMutableArray = [NSMutableArray array];
    [self.pictureContentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
        }];
        [obj removeFromSuperview];
    }];
    
    //[pictureMutableArray removeAllObjects];
    
    /*用户上传的图片*/
    if (!STLJudgeEmptyArray(model.imgList)) {
        
        [self.pictureContentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(90);
        }];
        
        if (model.imgList.count  == 1) {
            OSSVReviewsImageListModel *reviewsImageModel = [[OSSVReviewsImageListModel alloc] init];
            reviewsImageModel = model.imgList[0];
            NSString *imgUrl = STLToString(reviewsImageModel.smallPic);
            if (![imgUrl hasPrefix:@"http"]) {
                imgUrl = [NSString stringWithFormat:@"%@/%@",appReviewLocalHost,imgUrl];
            }
             
            YYAnimatedImageView *imageView = [self createPictureImgView:imgUrl bigUrl:@"" tag:0];
            
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.pictureContentView.mas_leading);
                make.width.mas_equalTo(80);
                make.height.mas_equalTo(80);
                make.centerY.mas_equalTo(self.pictureContentView.mas_centerY);
            }];
            
        } else {
            
            [model.imgList enumerateObjectsUsingBlock:^(OSSVReviewsImageListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([self isCreatePicture:idx]) {
                    *stop = YES;
                    return;
                }
                
                NSString *imgUrl = STLToString(obj.smallPic);
                NSString *bigImgUrl = STLToString(obj.originPic);

                if (![imgUrl hasPrefix:@"http"]) {
                    imgUrl = [NSString stringWithFormat:@"%@/%@",appReviewLocalHost,imgUrl];
                }
                if (![bigImgUrl hasPrefix:@"http"]) {
                    bigImgUrl = [NSString stringWithFormat:@"%@/%@",appReviewLocalHost,bigImgUrl];
                }

                YYAnimatedImageView *imageView = [self createPictureImgView:imgUrl bigUrl:bigImgUrl tag:idx];
                [pictureMutableArray addObject:imageView];
            }];
            
            [pictureMutableArray mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:10 leadSpacing:0 tailSpacing:0];
            [pictureMutableArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(80);
                make.height.mas_equalTo(80);
                make.centerY.mas_equalTo(self.pictureContentView.mas_centerY);
            }];
        }
        
    } else {
        [self.pictureContentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.iconImg yy_cancelCurrentImageRequest];
    self.iconImg.image = nil;
    self.userName.text = nil;
    self.publishedTime.text = nil;
    self.replyLabel.text = nil;
}

#pragma mark - 创建图片个数
- (BOOL)isCreatePicture:(NSInteger)index {
    
    if (IPHONE_4X_3_5 || IPHONE_5X_4_0) {
        if (index == 3) {
            return YES;
        }
    } else if (IPHONE_6X_4_7) {
        if (index == 3) {
            return YES;
        }
    } else if (IPHONE_6P_5_5) {
        if (index == 3) {
            return YES;
        }
    } else {
        if (index == 3) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - 创建图片
- (YYAnimatedImageView *)createPictureImgView:(NSString *)imgUrl bigUrl:(NSString *)bigImgUrl tag:(NSInteger)tag {
    
    NSURL *url = [NSURL URLWithString:imgUrl];
    
    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.tag = tag;
    imageView.userInteractionEnabled = YES;
    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouch:)]];
    
    [imageView yy_setImageWithURL:url
                      placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                          options:kNilOptions
                       completion:nil];
    
    [self.pictureContentView addSubview:imageView];
    [self.layoutArray addObject:imageView];
    
    YYPhotoGroupItem *item = [YYPhotoGroupItem new];
    item.thumbView = imageView;
    item.largeImageURL = !STLIsEmptyString(bigImgUrl) ? [NSURL URLWithString:bigImgUrl] : url;
    [self.picArray addObject:item];
    
    return imageView;
}

#pragma mark - Action

- (void)imageTouch:(UITapGestureRecognizer *)tap {
    YYPhotoBrowseView *groupView = [[YYPhotoBrowseView alloc]initWithGroupItems:self.picArray];
    
    UIViewController *superCtrl = self.viewController;
    [groupView presentFromImageView:self.layoutArray[tap.view.tag] toContainer:superCtrl.navigationController.view animated:YES completion:nil];
}



#pragma mark - LazyLoad

- (NSMutableArray *)picArray {
    if (!_picArray) {
        _picArray = [NSMutableArray array];
    }
    return _picArray;
}

- (NSMutableArray *)layoutArray {
    if (!_layoutArray) {
        _layoutArray = [NSMutableArray array];
    }
    return _layoutArray;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = OSSVThemesColors.col_EFEFEF;
    }
    return _bottomLineView;
}

- (YYAnimatedImageView *)iconImg {
    if (!_iconImg) {
        _iconImg = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _iconImg.contentMode = UIViewContentModeScaleAspectFit;
        _iconImg.clipsToBounds = YES;
        _iconImg.layer.cornerRadius = 20;
        _iconImg.layer.masksToBounds = YES;
    }
    return _iconImg;
}

- (UILabel *)userName {
    if (!_userName) {
        _userName = [[UILabel alloc] initWithFrame:CGRectZero];
        _userName.font = [UIFont systemFontOfSize:14];
        _userName.textColor = OSSVThemesColors.col_333333;
    }
    return _userName;
}

- (ZZStarView *)starRating {
    if (!_starRating) {
        _starRating = [[ZZStarView alloc] initWithImage:[UIImage imageNamed:@"review_new_star"] selectImage:[UIImage imageNamed:@"review_new_star_h"] starWidth:24 starHeight:24 starMargin:8 starCount:5 callBack:^(CGFloat userGrade, CGFloat finalGrade) {
            
        }];
        _starRating.userInteractionEnabled = NO;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _starRating.transform = CGAffineTransformMakeScale(-1.0,1.0);
        }
        _starRating.sublevel = 1;
        _starRating.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _starRating;
}

- (UILabel *)publishedTime {
    if (!_publishedTime) {
        _publishedTime = [[UILabel alloc] initWithFrame:CGRectZero];
        _publishedTime.font = [UIFont systemFontOfSize:14];
        _publishedTime.textColor = OSSVThemesColors.col_999999;
    }
    return _publishedTime;
}

- (UILabel *)replyLabel {
    if (!_replyLabel) {
        _replyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _replyLabel.font = [UIFont systemFontOfSize:14];
        _replyLabel.textColor = OSSVThemesColors.col_2D2D2D;
        _replyLabel.numberOfLines = 0;
    }
    return _replyLabel;
}

- (UIView *)pictureContentView {
    if (!_pictureContentView) {
        _pictureContentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _pictureContentView;
}

@end



@implementation STLGoodsDetailReviewMoreCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        
        [self.contentView addSubview:self.arrImgView];
        [self.contentView addSubview:self.titleLab];
        
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
        }];
        
        [self.arrImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLab.mas_trailing).mas_offset(20);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(24, 24));
        }];
        
    }
    return self;
}


- (UIImageView *)arrImgView {
    if (!_arrImgView) {
        _arrImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrImgView.image = [UIImage imageNamed:@"detail_right_arrow"];
        [_arrImgView convertUIWithARLanguage];
    }
    return _arrImgView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLab.text = STLLocalizedString_(@"viewAll", nil);
        _titleLab.textColor = OSSVThemesColors.col_333333;
        _titleLab.font = [UIFont systemFontOfSize:14];
    }
    return _titleLab;
}

@end
