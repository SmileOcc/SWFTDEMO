//
//  OSSVDetailReviewNewItemCell.m
// XStarlinkProject
//
//  Created by odd on 2021/6/29.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailReviewNewItemCell.h"
#import "YYPhotoBrowseView.h"
#import "STLPhotoBrowserView.h"

@implementation OSSVDetailReviewNewItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        if (APP_TYPE != 3) {
            self.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
            self.layer.borderWidth = 1.0;
            self.contentView.backgroundColor = [UIColor clearColor];
        } else {
            self.contentView.backgroundColor = OSSVThemesColors.col_F8F8F8;
        }
        
        [self.contentView addSubview:self.nickLabel];
        [self.contentView addSubview:self.startRatingView];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.countLabel];
        
        [self.nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.top.mas_equalTo(self.contentView.mas_top).offset(12);
            make.height.mas_equalTo(18);
        }];
        
        [self.startRatingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.nickLabel.mas_centerY);
            make.leading.mas_equalTo(self.nickLabel.mas_trailing).offset(4);
            make.size.mas_equalTo(CGSizeMake(78, 14));
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
           
            if (APP_TYPE == 3) {
                make.size.mas_equalTo(CGSizeMake(72, 72));
                make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
            } else {
                make.size.mas_equalTo(CGSizeMake(72, 96));
                make.centerY.mas_equalTo(self.contentView.mas_centerY);
            }
            
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.nickLabel.mas_leading);
            make.top.mas_equalTo(self.nickLabel.mas_bottom).offset(8);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-92);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.nickLabel.mas_leading);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.imageView);
            make.bottom.mas_equalTo(self.imageView.mas_bottom);
            make.height.mas_equalTo(14);
        }];
    }
 
    return self;
}

- (void)setModel:(OSSVReviewsListModel *)model {
    _model = model;
    
    self.startRatingView.hidden = NO;
    self.imageView.hidden = YES;
    self.countLabel.hidden = YES;
    
    NSString *userName = STLToString(model.userName);
    if (userName.length > 3) {
        userName = [NSString stringWithFormat:@"%@***",[userName substringToIndex:3]];
    } else if(userName.length == 0) {
        userName = @"***";
    }
    
    self.nickLabel.text = userName;
    self.startRatingView.grade = [STLToString(model.star) floatValue];
    self.contentLabel.text = STLToString(model.content);
    
    NSString *appReviewLocalHost = [STLCommentModule reviewPictureDomainHost];
    self.timeLabel.text = [OSSVCommonsManagers dateFormatString:[OSSVCommonsManagers sharedManager].arDateTimeFormatter time:STLToString(model.time)];;
    
    if (STLJudgeNSArray(model.imgList) && model.imgList.count > 0) {
        self.imageView.hidden = NO;
        self.countLabel.hidden = NO;
        self.countLabel.text = [NSString stringWithFormat:@"x%lu",(unsigned long)model.imgList.count];
        
        OSSVReviewsImageListModel *firstModel = model.imgList.firstObject;
        NSString *imgUrl = STLToString(firstModel.smallPic);
        if (![imgUrl hasPrefix:@"http"]) {
            imgUrl = [NSString stringWithFormat:@"%@/%@",appReviewLocalHost,imgUrl];
        }
        
        NSURL *url = [NSURL URLWithString:imgUrl];
        [self.imageView yy_setImageWithURL:url
                          placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                              options:kNilOptions
                           completion:nil];
        
        
        [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-92);
        }];
    } else {
        [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        }];
    }
}

- (void)imageTouch:(UITapGestureRecognizer *)tap {
    
    self.imagsArray = [[NSMutableArray alloc] init];
    NSMutableArray *imgsUrls = [[NSMutableArray alloc] init];
    NSString *appReviewLocalHost = [STLCommentModule reviewPictureDomainHost];

    for (OSSVReviewsImageListModel *lisModel in self.model.imgList) {
        NSString *bigImgUrl = STLToString(lisModel.originPic);
        NSString *smallImgUrl = STLToString(lisModel.smallPic);

        if (![bigImgUrl hasPrefix:@"http"]) {
            bigImgUrl = [NSString stringWithFormat:@"%@/%@",appReviewLocalHost,bigImgUrl];
        }
        if (![smallImgUrl hasPrefix:@"http"]) {
            smallImgUrl = [NSString stringWithFormat:@"%@/%@",appReviewLocalHost,smallImgUrl];
        }
        
        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [imageView yy_setImageWithURL:[NSURL URLWithString:smallImgUrl]
                          placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                              options:kNilOptions
                           completion:nil];
        
        STLPhotoGroupItem *item = [STLPhotoGroupItem new];
        item.thumbView = imageView;
        item.largeImageURL = !STLIsEmptyString(bigImgUrl) ? [NSURL URLWithString:bigImgUrl] : [NSURL URLWithString:smallImgUrl];
        [self.imagsArray addObject:item];
        
        [imgsUrls addObject:bigImgUrl];
    }
        
    STLPhotoBrowserView *groupView = [[STLPhotoBrowserView alloc]initWithGroupItems:self.imagsArray];
    groupView.isDismissToFirstPosition = YES;
    groupView.showDismiss = YES;
    UIViewController *superCtrl = self.viewController;
    [groupView presentFromImageView:self.imageView toContainer:superCtrl.navigationController.view animated:YES completion:nil];
}

- (UILabel *)nickLabel {
    if (!_nickLabel) {
        _nickLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nickLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _nickLabel.font = [UIFont systemFontOfSize:14];
    }
    return _nickLabel;
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
        _startRatingView.backgroundColor = [UIColor clearColor];
        _startRatingView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _startRatingView.hidden = YES;
    }
    return _startRatingView;
}

- (YYAnimatedImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
        [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTouch:)]];
        
    }
    return _imageView;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.backgroundColor = [OSSVThemesColors col_0D0D0D:0.3];
        _countLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _countLabel.font = [UIFont systemFontOfSize:10];
        _countLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _countLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.numberOfLines = 3;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _contentLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _contentLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [OSSVThemesColors col_B2B2B2];
    }
    return _timeLabel;
}

@end
