


//
//  ZFSubmitReviewWriteTableViewCell.m
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSubmitReviewWriteTableViewCell.h"
#import "ZFInitViewProtocol.h"

#import "UICollectionViewLeftAlignedLayout.h"
#import "ZFSearchMatchCollectionViewCell.h"
#import "ZFSubmitOverallFitView.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"

static NSString *const kZFSearchMatchCollectionViewCellIdentifier = @"kZFSearchMatchCollectionViewCellIdentifier";

@interface ZFSubmitReviewWriteTableViewCell()
<
    ZFInitViewProtocol,
    UITextViewDelegate,
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateLeftAlignedLayout,
    ZFSubmitOverallFitViewDelegate
> {
    NSInteger           _countInput;
    __block CGFloat     _collectionHeight;
    NSInteger           _currentPointLoc;
}

@property (nonatomic, strong) UILabel                               *overallTipsLabel;
@property (nonatomic, strong) UILabel                               *overallContentLabel;
@property (nonatomic, strong) ZFSubmitOverallFitView                *overallSelectView;
@property (nonatomic, strong) UILabel                               *tipsLabel;
@property (nonatomic, strong) UILabel                               *contentLabel;
@property (nonatomic, strong) UITextView                            *inputTextView;
@property (nonatomic, strong) UILabel                               *placeholderLabel;
@property (nonatomic, strong) UILabel                               *countLabel;
@property (nonatomic, strong) UICollectionViewLeftAlignedLayout     *flowLayout;
@property (nonatomic, strong) UICollectionView                      *collectionView;
@end


@implementation ZFSubmitReviewWriteTableViewCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
     self.inputTextView.text = @"";
    self.countLabel.text = @"0/300";
}

#pragma mark - action methods
- (void)intputViewChangeNotification:(id)notification {
    if (self.inputTextView.text.length < 300) {
        return ;
    }
    self.inputTextView.text = [self.inputTextView.text substringToIndex:300];
    self->_countInput = self.inputTextView.text.length;
    self.countLabel.text = [NSString stringWithFormat:@"%lu/300", self->_countInput];
    self.inputTextView.scrollsToTop = YES;
} 

#pragma mark - private methods
- (CGFloat)calculateAttrInfoWidthWithAttrName:(NSString *)attrName {
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    CGSize  size = [attrName boundingRectWithSize:CGSizeMake(MAXFLOAT, 30)  options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)   attributes:attribute context:nil].size;
    
    return size.width + 16 <= 64 ? 64 : size.width + 16;
}

- (void)calculateHotReviewWordCollectionHeigthWithWords:(NSArray *)words {
    __block CGFloat _startPoint = 0;
    self->_collectionHeight = 30;
    [words enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat currentWidth = [self calculateAttrInfoWidthWithAttrName:obj];
        _startPoint += currentWidth;
        if (_startPoint > KScreenWidth) {
            self->_collectionHeight += 42;
            _startPoint = currentWidth;
        }
    }];
}

#pragma mark - <UITextViewDelegate>
- (void)textViewDidEndEditing:(UITextView *)textView {
    //编辑结束后 将数据源更新
    if (self.submitReviewWriteContentCompletionHandler) {
        self.submitReviewWriteContentCompletionHandler(textView.text);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  
    if ([NSStringUtils isEmptyString:text]) {
        _countInput--;
        return YES;
    }
    
    _countInput = textView.text.length;
    self.countLabel.text = [NSString stringWithFormat:@"%lu/300", _countInput];
    if (self.submitReviewWriteContentCompletionHandler) {
        self.submitReviewWriteContentCompletionHandler(textView.text);
    }
    return _countInput < 300;
}

- (void)textViewDidChange:(UITextView *)textView {
    _countInput = textView.text.length;
    self.countLabel.text = [NSString stringWithFormat:@"%lu/300", _countInput];
    if (self.submitReviewWriteContentCompletionHandler) {
        self.submitReviewWriteContentCompletionHandler(textView.text);
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self performSelector:@selector(textViewDidChange:) withObject:textView afterDelay:0.1f];
}

#pragma mark - SubmitOverallFitView delelgate

- (void)ZFSubmitOverallFitViewDidClick:(NSInteger)index content:(NSString *)content
{
    if (self.submitReviewSelectOverallFitHandler) {
        self.submitReviewSelectOverallFitHandler(index);
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.review_hot_word.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFSearchMatchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFSearchMatchCollectionViewCellIdentifier forIndexPath:indexPath];
    cell.searchKey = self.model.review_hot_word[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];

    NSString *hotKey = [NSString stringWithFormat:@"%@ ", self.model.review_hot_word[indexPath.item]];
    if (self.inputTextView.text.length + hotKey.length > 300) {
        return ;
    }
    [self.inputTextView insertText:hotKey];
    if (self.submitReviewWriteContentCompletionHandler) {
        self.submitReviewWriteContentCompletionHandler(self.inputTextView.text);
    }
}

#pragma mark - <UICollectionViewDelegateLeftAlignedLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *hot_key = self.model.review_hot_word[indexPath.item];
    
    return CGSizeMake([self calculateAttrInfoWidthWithAttrName:hot_key], 30);
}


#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.overallTipsLabel];
    [self.contentView addSubview:self.overallContentLabel];
    [self.contentView addSubview:self.overallSelectView];
    [self.contentView addSubview:self.tipsLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.inputTextView];
    [self.contentView addSubview:self.countLabel];
    [self.contentView addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.overallTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.width.mas_offset(6);
        make.top.mas_equalTo(self.contentView.mas_top).offset(2);
    }];
    
    [self.overallContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.overallTipsLabel.mas_trailing).offset(2);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.overallTipsLabel);
    }];
    
    [self.overallSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.overallTipsLabel.mas_bottom).mas_offset(8);
        make.height.mas_offset(36);
        make.width.mas_offset(KScreenWidth);
        make.leading.mas_equalTo(self.contentView);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.width.mas_equalTo(6);
        make.top.mas_equalTo(self.overallSelectView.mas_bottom).offset(16);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.tipsLabel.mas_trailing).offset(2);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.tipsLabel);
    }];
    
    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentLabel);
        make.height.mas_equalTo(120);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
    }];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.inputTextView.mas_trailing).offset(-10);
        make.bottom.mas_equalTo(self.inputTextView.mas_bottom).offset(-10);
        make.height.mas_equalTo(15);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.inputTextView.mas_bottom).offset(12);
    }];
    
}

#pragma mark - setter
- (void)setModel:(ZFOrderReviewModel *)model {
    _model = model;
    self.collectionView.hidden = YES;
    if (_model.review_hot_word.count <= 0) {
        [self.inputTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(12);
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.contentLabel);
            make.height.mas_equalTo(120);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        }];
    } else {
        [self calculateHotReviewWordCollectionHeigthWithWords:model.review_hot_word];
        
        [self.inputTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(12);
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.contentLabel);
            make.height.mas_equalTo(120);
        }];
        
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.contentView);
            make.height.mas_equalTo(self->_collectionHeight);
            make.top.mas_equalTo(self.inputTextView.mas_bottom).offset(12);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-12);
        }];
        
        self.collectionView.hidden = NO;
        [self.collectionView reloadData];
    }
}

- (void)setEditInfo:(ZFOrderReviewSubmitModel *)editInfo {
    _editInfo = editInfo;
    self.inputTextView.text = _editInfo.content;
}

#pragma mark - getter

-(UILabel *)overallTipsLabel
{
    if (!_overallTipsLabel) {
        _overallTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 1;
            label.text = @"*";
            label.textColor = ZFC0x666666();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _overallTipsLabel;
}

-(UILabel *)overallContentLabel
{
    if (!_overallContentLabel) {
        _overallContentLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 1;
//            NSString *content = [NSString stringWithFormat:@"%@ (%@)",ZFLocalizedString(@"Reviews_OverallFit", nil), ZFLocalizedString(@"OverallFit_Required", nil)];
            label.text = ZFLocalizedString(@"Reviews_OverallFit", nil);
            label.textColor = ZFC0x666666();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _overallContentLabel;
}

-(ZFSubmitOverallFitView *)overallSelectView
{
    if (!_overallSelectView) {
        _overallSelectView = [[ZFSubmitOverallFitView alloc] init];
        _overallSelectView.delegate = self;
    }
    return _overallSelectView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.font = [UIFont systemFontOfSize:14];
        _tipsLabel.textColor = _overallContentLabel.textColor;
        _tipsLabel.text = @"*";
    }
    return _tipsLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = _overallContentLabel.textColor;
        _contentLabel.text = ZFLocalizedString(@"WriteReview_Content", nil);
    }
    return _contentLabel;
}

- (UITextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        _inputTextView.layer.borderWidth = .5f;
        _inputTextView.layer.borderColor = ZFCOLOR(153, 153, 153, 1.f).CGColor;
        _inputTextView.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _inputTextView.contentInset = UIEdgeInsetsMake(5, 0, 25, 0);
        _inputTextView.font = [UIFont systemFontOfSize:12];
        _inputTextView.delegate = self;
        _inputTextView.directionalLockEnabled = YES;
        _inputTextView.showsHorizontalScrollIndicator = NO;
        _inputTextView.showsVerticalScrollIndicator = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(intputViewChangeNotification:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return _inputTextView;
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _placeholderLabel.hidden = YES;
        _placeholderLabel.font = [UIFont systemFontOfSize:12];
        _placeholderLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _placeholderLabel.text = @"";
    }
    return _placeholderLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _countLabel.font = [UIFont systemFontOfSize:12];
        _countLabel.text = @"0/300";
    }
    return _countLabel;
}

- (UICollectionViewLeftAlignedLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewLeftAlignedLayout alloc] init];
        _flowLayout.minimumLineSpacing = 10;
        _flowLayout.minimumInteritemSpacing = 10;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        _flowLayout.alignedLayoutType = UICollectionViewLeftAlignedLayoutTypeLeft;
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[ZFSearchMatchCollectionViewCell class] forCellWithReuseIdentifier:kZFSearchMatchCollectionViewCellIdentifier];
        _collectionView.hidden = YES;
    }
    return _collectionView;
}


@end
