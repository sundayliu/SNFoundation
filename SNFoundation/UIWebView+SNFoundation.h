//
//  UIWebView+SNFoundation.h
//  SNFoundation
//
//  Created by liukun on 14-3-2.
//  Copyright (c) 2014年 liukun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWebView (SNFoundation)

- (NSString *)documentTitle;
- (void)fixViewPort;    //网页content自适应
- (void)cleanBackground;    //清除默认的背景高光

@end
