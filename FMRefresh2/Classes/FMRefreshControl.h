//
//  FMRefreshControl.h
//  FMRefresh2
//
//  Created by qianjn on 2016/10/31.
//  Copyright © 2016年 SF. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *FM_Refresh_normal_title  = @"正常状态";
static NSString *FM_Refresh_pulling_title  = @"释放刷新状态";
static NSString *FM_Refresh_Refreshing_title  = @"正在刷新";

@interface FMRefreshControl : UIRefreshControl

- (instancetype)initWithTargrt:(id)target refreshAction:(SEL)refreshAction;
- (void)endRefreshing;

@end
