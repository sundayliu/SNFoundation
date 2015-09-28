//
//  SNTimer.m
//  SNFramework
//
//  Created by  liukun on 13-1-31.
//  Copyright (c) 2013年 liukun. All rights reserved.
//

#import "SNTimer.h"
#import "SNDefines.h"

@interface SNTimerItem : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

@end

@implementation SNTimerItem

@synthesize target;
@synthesize selector;

@end

@implementation NSObject(SNTimer)

- (void)startTimerWithInterval:(NSTimeInterval)interval sel:(SEL)aSel repeat:(BOOL)aRep
{
    [[SNTimerQueue sharedInstance] scheduleTimeWithInterval:interval
                                                     target:self
                                                        sel:aSel
                                                     repeat:aRep];
}

- (void)stopTimerWithSel:(SEL)aSel
{
    [[SNTimerQueue sharedInstance] cancelTimerOfTarget:self sel:aSel];
}

- (void)stopAllTimers
{
    [[SNTimerQueue sharedInstance] cancelTimerOfTarget:self];
}

@end

@interface SNTimerQueue()
{
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	UIBackgroundTaskIdentifier backgroundTask;
#endif
}

@end

/*********************************************************************/

@implementation SNTimerQueue

+ (SNTimerQueue *)sharedInstance
{
    static SNTimerQueue *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SNTimerQueue alloc] init];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _timerQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)scheduleTimeWithInterval:(NSTimeInterval)interval target:(id)target sel:(SEL)aSel repeat:(BOOL)aRep
{
    [self cancelTimerOfTarget:target sel:aSel];
    
    SNTimerItem *item = [[SNTimerItem alloc] init];
    item.target = target;
    item.selector = aSel;
    
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    if (!backgroundTask || backgroundTask == UIBackgroundTaskInvalid)
    {
        backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            // Synchronize the cleanup call on the main thread in case
            // the task actually finishes at around the same time.
            dispatch_async(dispatch_get_main_queue(), ^{
                if (backgroundTask != UIBackgroundTaskInvalid)
                {
                    [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                    backgroundTask = UIBackgroundTaskInvalid;
                }
            });
        }];
    }
#endif
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                      target:self
                                                    selector:@selector(handleTimer:)
                                                    userInfo:item
                                                     repeats:aRep];
    [_timerQueue addObject:timer];
}

- (void)handleTimer:(NSTimer *)timer
{
    SNTimerItem *item = (SNTimerItem *)[timer userInfo];
    
    if ([item.target respondsToSelector:item.selector])
    {
        SuppressPerformSelectorLeakWarning([item.target performSelector:item.selector];);
    }
    
    if (![timer isValid])
    {
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
        dispatch_async(dispatch_get_main_queue(), ^{
            if (backgroundTask != UIBackgroundTaskInvalid) {
                [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                backgroundTask = UIBackgroundTaskInvalid;
            }
        });
#endif
        [_timerQueue removeObject:timer];
    }
}

- (void)cancelTimerOfTarget:(id)target sel:(SEL)aSel
{
    NSArray *timerArr = [NSArray arrayWithArray:_timerQueue];
    for (NSTimer *timer in timerArr)
    {
        SNTimerItem *item = (SNTimerItem *)[timer userInfo];
        if (item.target == target && item.selector == aSel)
        {
            if ([timer isValid]) {
                [timer invalidate];
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (backgroundTask != UIBackgroundTaskInvalid) {
                        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                        backgroundTask = UIBackgroundTaskInvalid;
                    }
                });
#endif
            }
            [_timerQueue removeObject:timer];
            break;
        }
    }
}

- (void)cancelTimerOfTarget:(id)target
{
    NSArray *timerArr = [NSArray arrayWithArray:_timerQueue];
    for (NSTimer *timer in timerArr)
    {
        SNTimerItem *item = (SNTimerItem *)[timer userInfo];
        if (item.target == target)
        {
            if ([timer isValid]) {
                [timer invalidate];
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (backgroundTask != UIBackgroundTaskInvalid) {
                        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
                        backgroundTask = UIBackgroundTaskInvalid;
                    }
                });
#endif
            }
            [_timerQueue removeObject:timer];
        }
    }
}

@end
