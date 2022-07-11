//
//  YXNewsLiveSectionView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/8/5.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXLiveModel.h"
@class YXNewCourseVideoInfoSubModel;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YXNewsLiveStatus) {
    YXNewsLiveStatusPre = 0,
    YXNewsLiveStatusLive = 1,
    YXNewsLiveStatusReplay = 2,
    YXNewsLiveStatusChatRoomLive = 3,
    YXNewsLiveStatusChatRoomEnd = 4
};

@interface YXNewsLiveSectionView : UIView

@property (nonatomic, strong) NSArray *list;

@property (nonatomic, copy) void (^arrowCallBack)(void);

@property (nonatomic, copy) void (^detailViewClickCallBack)(YXLiveModel *model);

@end

@interface YXNewsLiveStatusView : UIView

@property (nonatomic, assign) YXNewsLiveStatus status;

@property (nonatomic, strong) QMUILabel *rightLabel;

@property (nonatomic, strong) NSString *tagStr;

@end


@interface YXNewsLiveDetailView : UIView

@property (nonatomic, strong) YXLiveModel *liveModel;

@property (nonatomic, strong) YXNewCourseVideoInfoSubModel *courseModel;

- (void)resetRecommendLayout;

@end




NS_ASSUME_NONNULL_END
