//
//  NSDate+SNFoundation.h
//  SNFoundation
//
//  Created by liukun on 14-3-4.
//  Copyright (c) 2014年 liukun. All rights reserved.
//

#import <Foundation/Foundation.h>

#undef DEFAULT_DATE_PATTERN
#define DEFAULT_DATE_PATTERN    @"yyyy-MM-dd"

@interface NSDate (SNFoundation)

+ (NSDate *)getDate:(NSString *)dateStr pattern:(NSString *)ptn;
+ (NSDate *)getDate:(NSString *)sDate pattern:(NSString *)ptn locale:(NSLocale *)loc;

@end
