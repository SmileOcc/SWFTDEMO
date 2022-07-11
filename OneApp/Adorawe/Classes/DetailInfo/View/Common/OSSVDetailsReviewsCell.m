//
//  OSSVDetailsReviewsCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailsReviewsCell.h"
#import "ZZStarView.h"
#import "OSSVReviewsImageListModel.h"
#import "STLPhotoBrowserView.h"

@interface OSSVDetailsReviewsCell ()

/**头像*/
@property (nonatomic, strong) YYAnimatedImageView       *iconImg;
/**用户名称*/
@property (nonatomic, strong) UILabel                   *userName;
/**星星*/
@property (nonatomic, strong) ZZStarView         *starRating;
/**评论时间*/
@property (nonatomic, strong) UILabel                   *publishedTime;
/**评论内容*/
@property (nonatomic, strong) UILabel                   *replyLabel;
/**上传的图片容器*/
@property (nonatomic, strong) UIView                    *pictureContentView;

@property (nonatomic, strong) NSMutableArray            *picArray;
@property (nonatomic, strong) NSMutableArray            *layoutArray;

@end

@implementation OSSVDetailsReviewsCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UIView *ws = self.contentView;
        
        [ws addSubview:self.iconImg];
        [ws addSubview:self.userName];
        [ws addSubview:self.starRating];
        [ws addSubview:self.publishedTime];
        [ws addSubview:self.replyLabel];
        [ws addSubview:self.pictureContentView];

        [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(ws.mas_top).offset(14);
            make.leading.mas_equalTo(ws.mas_leading).offset(14);
            make.width.height.mas_equalTo(24);
        }];
        
        [self.userName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.iconImg.mas_centerY);
            make.leading.mas_equalTo(self.iconImg.mas_trailing).offset(2);
        }];

        [self.starRating mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.iconImg.mas_centerY);
            make.leading.mas_equalTo(self.userName.mas_trailing).offset(4);
            make.size.mas_equalTo(CGSizeMake(70, 14));
        }];

        
        [self.replyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconImg.mas_bottom).offset(6);
            make.leading.mas_equalTo(self.iconImg.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-14);
        }];

        [self.publishedTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.replyLabel.mas_bottom).offset(6);
            make.leading.mas_equalTo(self.iconImg.mas_leading);
        }];
        
        [self.pictureContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.publishedTime.mas_bottom).offset(6);
            make.leading.mas_equalTo(self.replyLabel.mas_leading);
            make.bottom.mas_equalTo(ws.mas_bottom).offset(-14);
            make.height.mas_equalTo(0);
        }];
        
       
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self stlAddCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(6, 6)];
}

- (void)setModel:(OSSVReviewsListModel *)model {
    
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
    self.userName.text =userName;
    self.replyLabel.text = model.content;
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
//                               image = [image yy_imageByResizeToSize:CGSizeMake(40, 40) contentMode:UIViewContentModeScaleAspectFill];
                               return image;
                           }
                          completion:nil];
    
    CGFloat imageWidth = (SCREEN_WIDTH - 12 * 2 - 14 * 2 - 4*2) / 3.0;
    self.publishedTime.text = [OSSVCommonsManagers dateFormatString:[OSSVCommonsManagers sharedManager].arReviewDateTimeFormatter time:STLToString(model.time)];
    
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
            make.height.mas_equalTo(imageWidth);
        }];
        
        
        if (model.imgList.count  == 1) {
//            NSString *imgUrl = [[model.imgList firstObject] valueForKey:@"originPic"];
//            imgUrl = [NSString stringWithFormat:@"%@/%@",appReviewLocalHost,imgUrl];
            
            OSSVReviewsImageListModel *reviewsImageModel = model.imgList[0];
            NSString *imgUrl = STLToString(reviewsImageModel.originPic);
            if (![imgUrl hasPrefix:@"http"]) {
                imgUrl = [NSString stringWithFormat:@"%@/%@",appReviewLocalHost,imgUrl];
            }
            
            
            YYAnimatedImageView *imageView = [self createPictureImgView:imgUrl tag:0];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self.pictureContentView);
                make.width.mas_equalTo(imageWidth);
            }];

        } else {
            
            [model.imgList enumerateObjectsUsingBlock:^(OSSVReviewsImageListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([self isCreatePicture:idx]) {
                    *stop = YES;
                    return;
                }
                
                NSString *imgUrl = STLToString(obj.originPic);
                if (![imgUrl hasPrefix:@"http"]) {
                    imgUrl = [NSString stringWithFormat:@"%@/%@",appReviewLocalHost,imgUrl];
                }
                
                YYAnimatedImageView *imageView = [self createPictureImgView:imgUrl tag:idx];
                [pictureMutableArray addObject:imageView];

            }];
            
            [pictureMutableArray mas_distributeViewsAlongAxis:HelperMASAxisTypeHorizon withFixedSpacing:4 leadSpacing:0 tailSpacing:0];
            [pictureMutableArray mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.pictureContentView.mas_top);
                make.bottom.mas_equalTo(self.pictureContentView.mas_bottom);
                make.width.mas_equalTo(imageWidth);
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
- (YYAnimatedImageView *)createPictureImgView:(NSString *)imgUrl tag:(NSInteger)tag {
    
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
    
    STLPhotoGroupItem *item = [STLPhotoGroupItem new];
    item.thumbView = imageView;
    item.largeImageURL = url;
    [self.picArray addObject:item];
    
    return imageView;
}

#pragma mark - Action

- (void)imageTouch:(UITapGestureRecognizer *)tap {
    
    STLPhotoBrowserView *groupView = [[STLPhotoBrowserView alloc]initWithGroupItems:self.picArray];
    groupView.showDismiss = YES;
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

- (YYAnimatedImageView *)iconImg {
    if (!_iconImg) {
        _iconImg = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _iconImg.contentMode = UIViewContentModeScaleAspectFill;
        _iconImg.clipsToBounds = YES;
        _iconImg.layer.cornerRadius = 12;
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
        _starRating = [[ZZStarView alloc] initWithImage:[UIImage imageNamed:@"star_small_review"] selectImage:[UIImage imageNamed:@"star_small_review_h"] starWidth:14 starHeight:14 starMargin:2 starCount:5 callBack:^(CGFloat userGrade, CGFloat finalGrade) {
            
        }];
        _starRating.backgroundColor = [UIColor clearColor];
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
        _publishedTime.font = [UIFont systemFontOfSize:12];
        _publishedTime.textColor = [OSSVThemesColors col_B2B2B2];
    }
    return _publishedTime;
}

- (UILabel *)replyLabel {
    if (!_replyLabel) {
        _replyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _replyLabel.font = [UIFont systemFontOfSize:14];
        _replyLabel.textColor = [OSSVThemesColors col_6C6C6C];
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
