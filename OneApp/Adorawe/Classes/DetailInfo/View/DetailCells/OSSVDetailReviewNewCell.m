//
//  OSSVDetailReviewNewCell.m
// XStarlinkProject
//
//  Created by odd on 2021/6/29.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVDetailReviewNewCell.h"
#import "Adorawe-Swift.h"

@interface OSSVDetailReviewNewCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *reviewsData;
@property (nonatomic, strong) UIImageView    *lineImageView;
@property (nonatomic, strong) UIView         *lineView;
@end

@implementation OSSVDetailReviewNewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];

        self.reviewsData = @[];
        [self.bgView addSubview:self.headerView];
        [self.bgView addSubview:self.reviewStartView];
        [self.bgView addSubview:self.reviewCollectionView];
        [self.bgView addSubview:self.viewMoreView];
        
        
        [self.headerView addSubview:self.reviewTitleLabel];
        [self.reviewStartView addSubview:self.ratingLabel];
        [self.reviewStartView addSubview:self.startRatingView];
        [self.viewMoreView addSubview:self.viewMoreButton];
        if (APP_TYPE == 3) {
            [self.viewMoreView addSubview:self.lineView];
            [self.viewMoreView addSubview:self.lineImageView];
        }
        

        [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgView.mas_top).mas_offset(0);
            make.leading.mas_equalTo(self.bgView.mas_leading).mas_offset(14);
            make.trailing.mas_equalTo(self.bgView.mas_trailing).mas_offset(-14);
            make.height.mas_offset(50);
        }];
        
        [self.reviewTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.headerView);
            make.top.mas_equalTo(self.headerView.mas_top).offset(15);
        }];
        
        [self.reviewStartView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.headerView);
            if (APP_TYPE == 3) {
                make.height.mas_equalTo(43);
            } else {
                make.height.mas_equalTo(60);
            }
            make.top.mas_equalTo(self.headerView.mas_bottom);
        }];
        
        [self.ratingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.leading.mas_equalTo(self.reviewStartView.mas_leading).offset(0);
            } else {
                make.leading.mas_equalTo(self.reviewStartView.mas_leading).offset(12);
            }
            make.centerY.mas_equalTo(self.reviewStartView.mas_centerY);
        }];
        
        [self.startRatingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.ratingLabel.mas_trailing).offset(8);
            make.centerY.mas_equalTo(self.ratingLabel.mas_centerY);
            make.height.mas_equalTo(@14);
            make.width.mas_equalTo(@78);
        }];
        
        [self.reviewCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.bgView.mas_leading);
            make.trailing.mas_equalTo(self.bgView.mas_trailing);
            make.top.mas_equalTo(self.reviewStartView.mas_bottom).offset(8);
            make.height.mas_equalTo(120);
        }];
        
        [self.viewMoreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.headerView);
            make.top.mas_equalTo(self.reviewCollectionView.mas_bottom);
            make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-14);
            make.height.mas_equalTo(44);
        }];
        
        [self.viewMoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.centerY.mas_equalTo(self.viewMoreView.mas_centerY);
                make.centerX.mas_equalTo(self.viewMoreView.mas_centerX);
            } else {
                make.leading.trailing.mas_equalTo(self.viewMoreView);
            }
            make.top.mas_equalTo(self.viewMoreView.mas_top).offset(8);
            make.height.mas_equalTo(36);
        }];
        
        if (APP_TYPE == 3) {
            [self.lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.mas_equalTo(self.viewMoreButton);
                make.top.mas_equalTo(self.viewMoreButton.mas_bottom).offset(-5);
                make.height.mas_equalTo(1);
            }];
            
            [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
                make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
                make.height.equalTo(0.5);
                make.bottom.mas_equalTo(self.viewMoreView.mas_bottom).offset(-1);
            }];
        }
    }
    return self;
}

+ (CGFloat)contentHeight:(NSInteger)count {
    CGFloat collectHeight = 120;
    if (APP_TYPE == 3) {
        if (count > 0) {
            if (count > 3) {
                return 50 + 43 + 8 + collectHeight + 44 + 14;
            }
            return 50 + 43 + 8 + collectHeight + 14;
        }

    } else {
        if (count > 0) {
            if (count > 3) {
                return 50 + 60 + 8 + collectHeight + 44 + 14;
            }
            return 50 + 60 + 8 + collectHeight + 14;
        }
    }
    return 0;
}

- (void)setModel:(OSSVReviewsModel *)model {
    _model = model;
    if (STLJudgeNSArray(model.reviewList)) {
        self.reviewsData = [[NSArray alloc] initWithArray:model.reviewList];
    } else {
        self.reviewsData = @[];
    }
    self.reviewTitleLabel.text = [NSString stringWithFormat:@"%@(%lu)",STLLocalizedString_(@"reviews", nil),(unsigned long)model.reviewCount];
    self.viewMoreButton.hidden = self.reviewsData.count > 3 ? NO : YES;
    self.lineView.hidden = self.viewMoreButton.hidden;
    self.ratingLabel.text = [NSString stringWithFormat:@"%.1f",model.agvRate];
    self.startRatingView.grade = model.agvRate;
    self.startRatingView.hidden = NO;
    
    if (self.reviewsData.count > 3) {
        [self.viewMoreView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
        }];
    } else {
        [self.viewMoreView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    
    [self.reviewCollectionView reloadData];
}

- (void)actionMore:(UIButton *)sender {
    if (self.stlDelegate && [self.stlDelegate respondsToSelector:@selector(OSSVDetialCell:reiveMore:)]) {
        [self.stlDelegate OSSVDetialCell:self reiveMore:YES];
    }
}
#pragma mark --UICollectionDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.reviewsData.count > 3) {
        return 3;
    }
    return self.reviewsData.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    OSSVDetailReviewNewItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OSSVDetailReviewNewItemCell" forIndexPath:indexPath];
    if (self.reviewsData.count > indexPath.row) {    
        OSSVReviewsListModel *model = self.reviewsData[indexPath.item];
        cell.model = model;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    OSSVAdvsEventsModel *model = self.slideImgArray[indexPath.item];
//
//
//    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_HomeBannerCCell:advEventModel:index:)]) {
//        [self.delegate STL_HomeBannerCCell:self advEventModel:model index:indexPath.row];
//    }

}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(SCREEN_WIDTH - 12*2 - 14*2 - 20,120);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 14, 0, 14);
}
///如果不加这个，cell之间有间隙
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8;
}

#pragma mark - setter

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectZero];
        _headerView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _headerView;
}

- (UILabel *)reviewTitleLabel {
    if (!_reviewTitleLabel) {
        _reviewTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _reviewTitleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        if (APP_TYPE == 3) {
            _reviewTitleLabel.font = [UIFont vivaiaRegularFont:18];
        } else {
            _reviewTitleLabel.font = [UIFont boldSystemFontOfSize:16];
        }
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _reviewTitleLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _reviewTitleLabel;
}

- (UIView *)reviewStartView {
    if (!_reviewStartView) {
        _reviewStartView = [[UIView alloc] initWithFrame:CGRectZero];
        if (APP_TYPE == 3) {
            _reviewStartView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        } else {
            _reviewStartView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        }
    }
    return _reviewStartView;
}

-(UILabel *)ratingLabel {
    if (!_ratingLabel) {
        _ratingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _ratingLabel.font = [UIFont boldSystemFontOfSize:36];
        _ratingLabel.textColor = [OSSVThemesColors col_0D0D0D];
    }
    return _ratingLabel;
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

- (UICollectionView *)reviewCollectionView {
    if (!_reviewCollectionView) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        _reviewCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 12*2, 120) collectionViewLayout:flowLayout];
        [_reviewCollectionView registerClass:[OSSVDetailReviewNewItemCell class] forCellWithReuseIdentifier:@"OSSVDetailReviewNewItemCell"];
        _reviewCollectionView.backgroundColor = [UIColor clearColor];
        _reviewCollectionView.minimumZoomScale = 0;
        _reviewCollectionView.dataSource = self;
        _reviewCollectionView.delegate = self;
        _reviewCollectionView.showsHorizontalScrollIndicator = NO;
        _reviewCollectionView.showsVerticalScrollIndicator = NO;
    }
    return _reviewCollectionView;
}

- (UIView *)viewMoreView {
    if (!_viewMoreView) {
        _viewMoreView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _viewMoreView;
}

- (UIButton *)viewMoreButton {
    if (!_viewMoreButton) {
        _viewMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_viewMoreButton setTitle:STLLocalizedString_(@"viewAll", nil) forState:UIControlStateNormal];
        if (APP_TYPE == 3) {
            [_viewMoreButton setTitleColor:[OSSVThemesColors col_0D0D0D:0.5] forState:UIControlStateNormal];
            _viewMoreButton.titleLabel.font = [UIFont systemFontOfSize:12];
        } else {
            [_viewMoreButton setTitleColor:[OSSVThemesColors col_0D0D0D] forState:UIControlStateNormal];
            _viewMoreButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            _viewMoreButton.layer.borderWidth = 1;
            _viewMoreButton.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        }
        [_viewMoreButton addTarget:self action:@selector(actionMore:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _viewMoreButton;
}


- (UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        UIImage *backImg = STLImageWithName(@"spic_dash_line_black");
        UIColor*bcColor =[UIColor colorWithPatternImage:backImg];
//        _lineImageView.hidden = YES;
        _lineImageView.backgroundColor = bcColor;
    }
    return _lineImageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor  = OSSVThemesColors.col_E1E1E1;
    }
    return _lineView;
}
@end
