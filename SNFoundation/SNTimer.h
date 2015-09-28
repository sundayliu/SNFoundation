//
//  SNTimer.h
//  SNFramework
//
//  Created by  liukun on 13-1-31.
//  Copyright (c) 2013年 liukun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (SNTimer)

- (void)startTimerWithInterval:(NSTimeInterval)interval sel:(SEL)aSel repeat:(BOOL)aRep;
- (void)stopTimerWithSel:(SEL)aSel;
- (void)stopAllTimers;

@end


/*********************************************************************/


@interface SNTimerQueue : NSObject
{
    NSMutableArray  *_timerQueue;
}

+ (SNTimerQueue *)sharedInstance;

- (void)scheduleTimeWithInterval:(NSTimeInterval)interval target:(id)target sel:(SEL)aSel repeat:(BOOL)aRep;

- (void)cancelTimerOfTarget:(id)target sel:(SEL)aSel;

- (void)cancelTimerOfTarget:(id)target;
@end
