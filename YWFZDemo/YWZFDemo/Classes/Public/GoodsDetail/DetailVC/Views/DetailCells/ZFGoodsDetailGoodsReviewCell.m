//
//  ZFGoodsDetailGoodsReviewCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailGoodsReviewCell.h"
#import "ZFFrameDefiner.h"
#import "ZFInitViewProtocol.h"
#import "ZFGoodsReviewStarsView.h"
#import "ZFReviewImageCollectionViewCell.h"
#import "ZFReviewSizeView.h"
#import "GoodsDetailsReviewsImageListModel.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYWebImage/UIImage+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "Masonry.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"
#import "UIImage+ZFExtended.h"
#import "GoodsDetailModel.h"
#import "Constants.h"

static NSString *const kZFReviewImageCollectionViewCellIdentifier = @"kZFReviewImageCollectionViewCellIdentifier";

@interface ZFGoodsDetailGoodsReviewCell() <ZFInitViewProtocol, UICollectionViewDelegateLeftAlignedLayout>
@property (nonatomic, strong) UIImageView                           *userImageView;
@property (nonatomic, strong) UILabel                               *nameLabel;
@property (nonatomic, strong) UILabel                               *infoLabel;
@property (nonatomic, strong) ZFGoodsReviewStarsView                *starView;
@property (nonatomic, strong) UIView                                *imageContentView;
@property (nonatomic, strong) NSMutableArray                        *masonryViewArray;
@property (nonatomic, strong) UILabel                               *timeLabel;
@property (nonatomic, strong) UIButton                              *translateBtn;
@property (nonatomic, strong) UIView                                *lineView;
@property (nonatomic, strong) GoodsDetailFirstReviewModel           *model;
@end

@implementation ZFGoodsDetailGoodsReviewCell

@synthesize cellTypeModel = _cellTypeModel;

///// 自定义宽高
//- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
//{
//    UICollectionViewLayoutAttributes *reviewAttributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
//    [self layoutIfNeeded];
//
//    CGSize size = [self.contentView systemLayoutSizeFittingSize:reviewAttributes.size]; // 获取自适应size
//    CGRect cellFrame = reviewAttributes.frame;
//    cellFrame.size.width = KScreenWidth;
//    cellFrame.size.height = (size.height < 160) ? 160 : size.height;//防止计算出错
//    self.cellTypeModel.sectionItemSize = CGSizeMake(KScreenWidth, cellFrame.size.height);
//    YWLog(@"自适应评论Cell高度===%.2f", cellFrame.size.height);
//    reviewAttributes.frame = cellFrame;
//    return reviewAttributes;
//}

+ (CGFloat)fetchReviewCellHeight:(GoodsDetailFirstReviewModel *)reviewModel {
    ZFGoodsDetailGoodsReviewCell *reviewCell = [[ZFGoodsDetailGoodsReviewCell alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    reviewCell.model = reviewModel;
    [reviewCell layoutIfNeeded];
    CGFloat calculateHeight = CGRectGetMaxY(reviewCell.lineView.frame);
    return calculateHeight < 120 ? 120 : calculateHeight;
}

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - Action

- (void)setCellTypeModel:(ZFGoodsDetailCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;
    if (cellTypeModel.reviewModelArray.count <= self.indexPath.item) return;
    
    GoodsDetailFirstReviewModel *model = cellTypeModel.reviewModelArray[self.indexPath.item];
    self.model = model;
}

- (void)actionTranslate:(UIControl *)sender {
    if (self.cellTypeModel.reviewCellActionBock) {
        self.cellTypeModel.reviewCellActionBock(self.cellTypeModel.detailModel, self.model, nil);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.userImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.starView];
    [self.contentView addSubview:self.infoLabel];
    [self.contentView addSubview:self.translateBtn];
    [self.contentView addSubview:self.imageContentView];
    [self.contentView addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.top.mas_equalTo(self.contentView.mas_top).offset(16);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.userImageView.mas_centerY);
        make.leading.mas_equalTo(self.userImageView.mas_trailing).offset(12);
    }];
    
    [self.starView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.userImageView.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.width.mas_equalTo(95);
    }];
    
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userImageView.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.userImageView.mas_leading);
        make.width.mas_equalTo(KScreenWidth - 16 * 2);
        //make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.imageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.infoLabel.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.userImageView);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.height.mas_equalTo(0); // 图片自动撑高
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageContentView.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.userImageView);
        make.height.mas_equalTo(16);
    }];
    
    [self.translateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.timeLabel.mas_centerY);
        make.height.mas_equalTo(26);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(16);
        make.leading.mas_equalTo(self.userImageView);
        make.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
        // make.bottom.mas_equalTo(self.contentView);
    }];
    
    YYAnimatedImageView *tempView;
    for (int i=0; i<self.masonryViewArray.count; i++) {
        YYAnimatedImageView *imageView = self.masonryViewArray[i];
        
        if (i == 0) {
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.imageContentView.mas_leading);
                make.top.mas_equalTo(0);  //距离父视图上方距离
                make.bottom.mas_equalTo(self.imageContentView.mas_bottom);
                make.size.mas_equalTo(CGSizeMake(100, 100));
            }];
        } else {
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(tempView.mas_trailing).offset(16);
                make.top.mas_equalTo(0);  //距离父视图上方距离
                make.bottom.mas_equalTo(self.imageContentView.mas_bottom);
                make.size.mas_equalTo(CGSizeMake(100, 100));
            }];
        }
        tempView = imageView;
    }
}

#pragma mark - setter
- (void)setModel:(GoodsDetailFirstReviewModel *)model {
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
    self.starView.rateAVG = _model.star;
    self.infoLabel.text = _model.content;
    
    NSString *showTime = _model.time;
    if (!ZFIsEmptyString(showTime)) {
        showTime = [showTime stringByReplacingOccurrencesOfString:@"AM" withString:@""];
        showTime = [showTime stringByReplacingOccurrencesOfString:@"PM" withString:@""];
    }
    self.timeLabel.text = showTime;
    
    self.translateBtn.hidden = YES;
    if (!ZFIsEmptyString(_model.parent_review_content)) {
        self.translateBtn.hidden = NO;
        
        NSString *translateTitle = nil;
        if (_model.isTranslate) {
            self.infoLabel.text = _model.parent_review_content;//这是原始语
            translateTitle = ZFLocalizedString(@"Community_review_translate_change", nil);
        } else {
            translateTitle = ZFLocalizedString(@"Community_review_translate_default", nil);
        }
        [self.translateBtn setTitle:ZFToString(translateTitle) forState:0];
    }
    
    if (_model.imgList.count > 0) {
        self.imageContentView.hidden = NO;
        
        [self.imageContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.infoLabel.mas_bottom).offset(8);
            make.leading.mas_equalTo(self.userImageView);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.height.mas_equalTo(100);
        }];
        
        if (self.model.imgList > 0 && !_masonryViewArray) {
//            [self.masonryViewArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:16 leadSpacing:0 tailSpacing:16];
//            // 设置array的垂直方向的约束
//            [self.masonryViewArray mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.mas_equalTo(0);  //距离父视图上方距离
//                make.bottom.mas_equalTo(self.imageContentView.mas_bottom);
//                make.size.mas_equalTo(CGSizeMake(100, 100));
//            }];
        }
        // 加载图片
        [self showImageViews];
        
    } else {
        self.imageContentView.hidden = YES;
        [self.imageContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.infoLabel.mas_bottom).offset(8);
            make.leading.mas_equalTo(self.userImageView);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.height.mas_equalTo(0);
        }];
    }
}

/// 水平方向排列、固定控件间隔、控件长度不定
- (void)showImageViews {
    for (int i=0; i<self.masonryViewArray.count; i ++) {
        YYAnimatedImageView *imageView = self.masonryViewArray[i];
        if (i >= self.model.imgList.count) {
            imageView.hidden = YES;
            continue;
        }
        GoodsDetailsReviewsImageListModel *model = self.model.imgList[i];
        
        if (![model isKindOfClass:[GoodsDetailsReviewsImageListModel class]]) continue;
        NSString *imageUrl = model.bigPic;
        if (ZFIsEmptyString(imageUrl)) continue;
        imageView.hidden = NO;
        [imageView yy_setImageWithURL:[NSURL URLWithString:imageUrl]
                               placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                   options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                  progress:nil
                                 transform:nil
                                completion:nil];
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

- (ZFGoodsReviewStarsView *)starView {
    if (!_starView) {
        _starView = [[ZFGoodsReviewStarsView alloc] initWithFrame:CGRectZero];
    }
    return _starView;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _infoLabel.backgroundColor = [UIColor whiteColor];
        _infoLabel.font = [UIFont systemFontOfSize:14];
        _infoLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _infoLabel.numberOfLines = 0;
        _infoLabel.preferredMaxLayoutWidth = KScreenWidth - 16 * 2;
    }
    return _infoLabel;
}

- (UIView *)imageContentView {
    if (!_imageContentView) {
        _imageContentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _imageContentView;
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

- (UIButton *)translateBtn {
    if (!_translateBtn) {
        _translateBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_translateBtn setImage:[UIImage imageNamed:@"community_translate"] forState:0];
        _translateBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_translateBtn setTitle:ZFLocalizedString(@"Community_review_translate_default", nil) forState:0];
        [_translateBtn setTitleColor:ZFC0x999999() forState:0];
        _translateBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [_translateBtn addTarget:self action:@selector(actionTranslate:) forControlEvents:UIControlEventTouchUpInside];
        _translateBtn.layer.borderColor = ZFC0xDDDDDD().CGColor;
        _translateBtn.layer.borderWidth = 1;
        _translateBtn.hidden = YES;
    }
    return _translateBtn;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _lineView;
}

- (NSMutableArray *)masonryViewArray {
    if (!_masonryViewArray) {
        _masonryViewArray = [NSMutableArray array];
        for (int i=0; i <3; i ++) {
            YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
            imageView.backgroundColor = [UIColor whiteColor];
            imageView.image = [UIImage imageNamed:@"loading_cat_list"];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.userInteractionEnabled = YES;
            imageView.clipsToBounds = YES;
            imageView.tag = 2019;
            imageView.hidden = YES;
            [self.imageContentView addSubview:imageView];
            [_masonryViewArray addObject:imageView];
        }
    }
    return _masonryViewArray;
}


@end

