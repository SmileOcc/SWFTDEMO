
//
//  ZFGoodsDetailReviewInfoTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2017/11/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsDetailReviewInfoTableViewCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFGoodsReviewStarsView.h"
#import "ZFReviewImageCollectionViewCell.h"
#import "ZFReviewSizeView.h"
#import "GoodsDetailFirstReviewImgListModel.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYWebImage/UIImage+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"
#import "UIImage+ZFExtended.h"

static NSString *const kZFReviewImageCollectionViewCellIdentifier = @"kZFReviewImageCollectionViewCellIdentifier";

@interface ZFGoodsDetailReviewInfoTableViewCell() <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateLeftAlignedLayout>
@property (nonatomic, strong) UIImageView                           *userImageView;
@property (nonatomic, strong) UILabel                               *nameLabel;
@property (nonatomic, strong) UILabel                               *sizeLabel;///显示用户购买的商品的尺寸
@property (nonatomic, strong) UILabel                               *infoLabel;
@property (nonatomic, strong) UILabel                               *timeLabel;
@property (nonatomic, strong) UIControl                             *translateControl;
@property (nonatomic, strong) UIImageView                           *translateImageView;
@property (nonatomic, strong) UILabel                               *translateLabel;
@property (nonatomic, strong) UILabel                               *overallFitLabel;
@property (nonatomic, strong) ZFReviewSizeView                      *sizeView;
@property (nonatomic, strong) ZFGoodsReviewStarsView                *starView;
@property (nonatomic, strong) UICollectionViewLeftAlignedLayout     *flowLayout;
@property (nonatomic, strong) UICollectionView                      *collectionView;
@property (nonatomic, strong) UIView                                *lineView;
@end

@implementation ZFGoodsDetailReviewInfoTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - Action

- (void)actionTranslate:(UIControl *)sender {
    if (self.reviewTranslateBlcok) {
        self.reviewTranslateBlcok(self.model);
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.imgList.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFReviewImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFReviewImageCollectionViewCellIdentifier forIndexPath:indexPath];
    GoodsDetailFirstReviewImgListModel *model = self.model.imgList[indexPath.item];
    cell.url = ZFIsEmptyString(model.bigPic) ? model.originPic : model.bigPic;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (self.goodsDetailReviewImageCheckCompletionHandler) {
        
        NSMutableArray *imageViewArr = [NSMutableArray array];
        for (NSInteger i=0; i<self.model.imgList.count; i++) {
            NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForItem:i inSection:0];
            ZFReviewImageCollectionViewCell *cell = (ZFReviewImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:tmpIndexPath];
            if (cell.imageView) {
                [imageViewArr addObject:cell.imageView];
            }
        }
        if (imageViewArr.count > 0) {
            self.goodsDetailReviewImageCheckCompletionHandler(indexPath.item, imageViewArr);
        }
    }
}

#pragma mark - <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 100);
}


#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.userImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.sizeLabel];
    [self.contentView addSubview:self.infoLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.overallFitLabel];
    [self.contentView addSubview:self.sizeView];
    [self.contentView addSubview:self.translateControl];
    [self.translateControl addSubview:self.translateImageView];
    [self.translateControl addSubview:self.translateLabel];
    [self.contentView addSubview:self.starView];
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(self.contentView.mas_top).offset(16);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.userImageView.mas_centerY).mas_offset(-2);
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(12);
    }];
    
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userImageView.mas_centerY).mas_offset(2);
        make.leading.mas_equalTo(self.nameLabel);
    }];
    
    [self.starView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.userImageView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.width.mas_equalTo(95);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userImageView);
        make.top.mas_equalTo(self.userImageView.mas_bottom).offset(8);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.infoLabel.mas_bottom).offset(8);
        make.height.mas_equalTo(100);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userImageView);
        make.top.mas_equalTo(self.collectionView.mas_bottom).offset(8);
        make.height.mas_equalTo(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.overallFitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.timeLabel);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).mas_offset(16);
        make.height.mas_offset(14);
    }];
    
    [self.sizeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.overallFitLabel.mas_bottom).mas_offset(4);
        make.leading.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView);
        make.height.mas_offset(32);
    }];
    
    [self.translateControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.timeLabel.mas_centerY);
        make.height.mas_equalTo(26);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.translateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.translateControl.mas_centerY);
        make.trailing.mas_equalTo(self.translateControl.mas_trailing).offset(-6);
    }];
    
    [self.translateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.translateControl.mas_leading).offset(6);
        make.centerY.mas_equalTo(self.translateControl.mas_centerY);
        make.trailing.mas_equalTo(self.translateLabel.mas_leading).offset(-2);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userImageView);
        make.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
        make.top.mas_equalTo(self.sizeView.mas_bottom).offset(16);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

- (void)setCanShowBigImage:(BOOL)canShowBigImage {
    _canShowBigImage = canShowBigImage;
    self.collectionView.userInteractionEnabled = canShowBigImage;
}

#pragma mark - setter
- (void)setModel:(GoodsDetailFirstReviewModel *)model {
    
    //GoodsDetailFirstReviewModel 与 GoodsDetailsReviewsListModel 里返回数据字段不统一啊，啊，啊
    
    _model = model;
    [self.userImageView yy_setImageWithURL:[NSURL URLWithString:model.avatar]
                        placeholder:[UIImage imageNamed:@"index_cat_loading"]
                             options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                            progress:nil
                           transform:^UIImage *(UIImage *image, NSURL *url) {
                               if ([image isKindOfClass:[YYImage class]]) {
                                   YYImage *showImage = (YYImage *)image;
                                   if (showImage.animatedImageType == YYImageTypeGIF || showImage.animatedImageData) {
                                       return image;
                                   }
                               }
                               return [image zf_imageByResizeToSize:CGSizeMake(40, 40) contentMode:UIViewContentModeScaleAspectFill];
                           }
                          completion:nil];
    self.nameLabel.text = _model.userName;
    
    if (self.isTimeStamp) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en"];
        [dateFormatter setDateFormat:@"MMM.dd,yyyy  HH:mm:ss aa"];
        NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[_model.time integerValue]]];
        NSMutableString* date= [[NSMutableString alloc]initWithString:currentDateStr];
        [date insertString:@"at" atIndex:12];
        self.timeLabel.text = date;
    } else {
        NSString *showTime = _model.time;
        if (!ZFIsEmptyString(showTime)) {
            showTime = [showTime stringByReplacingOccurrencesOfString:@"AM" withString:@""];
            showTime = [showTime stringByReplacingOccurrencesOfString:@"PM" withString:@""];
        }
        self.timeLabel.text = showTime;
    }
    
    self.infoLabel.text = _model.content;
    self.translateControl.hidden = YES;
    if (!ZFIsEmptyString(_model.parent_review_content)) {
        self.translateControl.hidden = NO;
        if (_model.isTranslate) {
            //这是原始语
            self.infoLabel.text = _model.parent_review_content;
            self.translateLabel.text = ZFLocalizedString(@"Community_review_translate_change", nil);
        } else {
            self.translateLabel.text = ZFLocalizedString(@"Community_review_translate_default", nil);
        }
    }
    
    CGFloat overHeight = 0;
    CGFloat overTop = 0;
    CGFloat sizeHeight = 0;
    CGFloat sizeTop = 0;
    ///如果需要显示尺寸
    if ([_model.review_size isShowReviewsSize] && self.isShowSizeView) {
        sizeHeight = 32;
        sizeTop = 4;
        ///contentList, 顺序 <Height, Waist, Hips, Bust Size>
        NSArray *list = @[
                          ZFToString(_model.review_size.height),
                          ZFToString(_model.review_size.waist),
                          ZFToString(_model.review_size.hips),
                          ZFToString(_model.review_size.bust)
                          ];
        self.sizeView.contentList = list;
        self.sizeView.hidden = NO;
    } else {
        //用户没有填写尺寸，不显示出来
        sizeHeight = 0;
        sizeTop = 0;
        self.sizeView.hidden = YES;
    }
    
    if (self.isShowSizeView) {
        self.sizeLabel.hidden = NO;
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.userImageView.mas_centerY).mas_offset(-2);
            make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(12);
        }];
        
        [self.sizeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.userImageView.mas_centerY).mas_offset(2);
            make.leading.mas_equalTo(self.nameLabel);
            make.trailing.mas_equalTo(self.starView.mas_leading).mas_offset(-5);
        }];
        
        self.sizeLabel.text = _model.attr_strs;
    } else {
        self.sizeLabel.hidden = YES;
        self.sizeLabel.text = @"";
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.userImageView.mas_centerY);
            make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(12);
        }];
    }
    
    if ([_model.review_size isShowOverall] && self.isShowSizeView) {
        overHeight = 14;
        overTop = 16;
        self.overallFitLabel.hidden = NO;
        self.overallFitLabel.text = [NSString stringWithFormat:@"%@ : %@", ZFLocalizedString(@"Reviews_OverallFit", nil), [_model.review_size reviewsOverallContent]];
    } else {
        overHeight = 0;
        overTop = 0;
        self.overallFitLabel.hidden = YES;
    }
    
    [self.overallFitLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.timeLabel);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).mas_offset(overTop);
        make.height.mas_offset(overHeight);
    }];
    
    [self.sizeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.overallFitLabel.mas_bottom).mas_offset(sizeTop);
        make.leading.mas_equalTo(self.contentView);
        make.trailing.mas_equalTo(self.contentView);
        make.height.mas_offset(sizeHeight);
    }];

    self.starView.rateAVG = _model.star;
    if (_model.imgList.count <= 0) {
        self.collectionView.hidden = YES;
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.userImageView);
            make.top.mas_equalTo(self.infoLabel.mas_bottom).offset(8);
            make.height.mas_equalTo(16);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        }];
        
        [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.userImageView);
            make.trailing.mas_equalTo(self.contentView);
            make.height.mas_equalTo(0.5);
            make.top.mas_equalTo(self.sizeView.mas_bottom).offset(16);
            make.bottom.mas_equalTo(self.contentView);
        }];
    } else {
        self.collectionView.hidden = NO;
        [self.collectionView reloadData];
        [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.userImageView);
            make.top.mas_equalTo(self.collectionView.mas_bottom).offset(8);
            make.height.mas_equalTo(16);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        }];
        
        [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.userImageView);
            make.trailing.mas_equalTo(self.contentView);
            make.height.mas_equalTo(0.5);
            make.top.mas_equalTo(self.sizeView.mas_bottom).offset(16);
            make.bottom.mas_equalTo(self.contentView);
        }];
    }
}

#pragma mark - getter
- (UIImageView *)userImageView {
    if (!_userImageView) {
        _userImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _userImageView.layer.cornerRadius = 20;
        _userImageView.layer.masksToBounds = YES;
    }
    return _userImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.backgroundColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
    }
    return _nameLabel;
}

-(UILabel *)sizeLabel
{
    if (!_sizeLabel) {
        _sizeLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.backgroundColor = [UIColor whiteColor];
            label.textColor = ZFCOLOR(153, 153, 153, 1);
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _sizeLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _infoLabel.backgroundColor = [UIColor whiteColor];
        _infoLabel.font = [UIFont systemFontOfSize:14];
        _infoLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _infoLabel.numberOfLines = 0;
    }
    return _infoLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor whiteColor];
        _timeLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _timeLabel.font = [UIFont systemFontOfSize:12];
    }
    return _timeLabel;
}

- (UIControl *)translateControl {
    if (!_translateControl) {
        _translateControl = [[UIControl alloc] initWithFrame:CGRectZero];
        _translateControl.layer.borderColor = ZFC0xDDDDDD().CGColor;
        _translateControl.layer.borderWidth = 1;
        [_translateControl addTarget:self action:@selector(actionTranslate:) forControlEvents:UIControlEventTouchUpInside];
        _translateControl.hidden = YES;
    }
    return _translateControl;
}

- (UIImageView *)translateImageView {
    if (!_translateImageView) {
        _translateImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _translateImageView.image = [UIImage imageNamed:@"community_translate"];
    }
    return _translateImageView;
}

- (UILabel *)translateLabel {
    if (!_translateLabel) {
        _translateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _translateLabel.backgroundColor = [UIColor whiteColor];
        _translateLabel.textColor = ZFC0x999999();
        _translateLabel.font = [UIFont systemFontOfSize:14];
        _translateLabel.text = ZFLocalizedString(@"Community_review_translate_default", nil);
    }
    return _translateLabel;
}


- (ZFGoodsReviewStarsView *)starView {
    if (!_starView) {
        _starView = [[ZFGoodsReviewStarsView alloc] initWithFrame:CGRectZero];
    }
    return _starView;
}

- (UICollectionViewLeftAlignedLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewLeftAlignedLayout alloc] init];
        _flowLayout.minimumLineSpacing = 16;
        _flowLayout.minimumInteritemSpacing = 16;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        _flowLayout.itemSize = CGSizeMake(100, 100);
        _flowLayout.alignedLayoutType = UICollectionViewLeftAlignedLayoutTypeLeft;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        [_collectionView registerClass:[ZFReviewImageCollectionViewCell class] forCellWithReuseIdentifier:kZFReviewImageCollectionViewCellIdentifier];
    }
    return _collectionView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _lineView;
}

-(ZFReviewSizeView *)sizeView
{
    if (!_sizeView) {
        _sizeView = [[ZFReviewSizeView alloc] init];
    }
    return _sizeView;
}

-(UILabel *)overallFitLabel
{
    if (!_overallFitLabel) {
        _overallFitLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.backgroundColor = [UIColor whiteColor];
            label.numberOfLines = 1;
            NSString *text = [NSString stringWithFormat:@"%@ : ", ZFLocalizedString(@"Reviews_OverallFit", nil)];
            label.text = text;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:12];
            label;
        });
    }
    return _overallFitLabel;
}

@end
