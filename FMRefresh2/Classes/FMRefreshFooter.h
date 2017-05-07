//
//  FMRefreshFooter.h
//  FMRefresh2
//
//  Created by qianjn on 2017/5/7.
//  Copyright © 2017年 SF. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *FM_Refresh_foot_normal_title  = @"Pull to refresh";
static NSString *FM_Refresh_foot_pulling_title  = @"Release to refresh";
static NSString *FM_Refresh_foot_Refreshing_title  = @"Loading";

@interface FMRefreshFooter : UIView

- (instancetype)initWithTargrt:(id)target refreshAction:(SEL)refreshAction;
- (void)endRefreshing;
- (void)endRefreshingWithNoMoreData;

@end
