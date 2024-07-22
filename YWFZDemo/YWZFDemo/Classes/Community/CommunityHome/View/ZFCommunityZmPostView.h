//
//  ZFCommunityZmPostView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityViewModel.h"
@class ZFCommunityHotTopicItemView;

@interface ZFCommunityZmPostView : UIView

@property (nonatomic, copy) void (^showsBlock)(void);
@property (nonatomic, copy) void (^outfitsBlock)(void);

///外部带入的
@property (nonatomic, strong) ZFCommunityHotTopicModel *hotTopicModel;

- (void)show;
- (void)hiddenViewAnimation:(BOOL)animation;

- (void)pushOutfitPostController:(NSString *)topic;
- (void)pushShowPostController:(NSString *)topic;

- (void)showHotTopicView;
@end


@interface ZFCommunityHotTopicItemView : UIButton


@property (nonatomic, strong) ZFCommunityHotTopicModel *hotTopicModel;

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UILabel *topicLabel;
@property (nonatomic, strong) UILabel *topicDescLabel;




@end
