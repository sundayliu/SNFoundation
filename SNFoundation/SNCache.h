//
//  SNCache.h
//  SNFramework
//
//  Created by  liukun on 13-2-26.
//  Copyright (c) 2013年 liukun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kSNCacheAgeForever      (-1.)
#define kSNCacheAgeOneLifeCycle (-2.)
#define kSNCacheAgeDefault      (60. * 60. * 24. * 7.)  //a week

@interface SNFileCache : NSObject
{
	NSString *				_cachePath;
    dispatch_queue_t        _ioQueue;
    NSInteger               _maxCacheAge;
    NSMutableDictionary     *_cacheDictionary;
}

@property (nonatomic, strong) NSString *			cachePath;

+ (SNFileCache *)defaultCache;

- (BOOL)hasCached:(NSString *)key;

//data
- (NSData *)dataForKey:(NSString *)key;
- (void)saveData:(NSData *)data forKey:(NSString *)key;
- (void)saveData:(NSData *)data forKey:(NSString *)key cacheAge:(NSTimeInterval)age;

//string
- (NSString *)stringForKey:(NSString *)key;
- (void)saveString:(NSString *)string forKey:(NSString *)key;
- (void)saveString:(NSString *)string forKey:(NSString *)key cacheAge:(NSTimeInterval)age;

//array
- (NSArray *)arrayForKey:(NSString *)key;
- (void)saveArray:(NSArray *)array forKey:(NSString *)key;
- (void)saveArray:(NSArray *)array forKey:(NSString *)key cacheAge:(NSTimeInterval)age;

- (NSString *)cachePathForKey:(NSString *)key;

- (void)removeDataForKey:(NSString *)key;
- (void)clearDisk;  //清空缓存
- (void)cleanDisk;  //清除过期的缓存

//Get the size used by the disk cache
- (unsigned long long)cacheSize;

@end

#pragma mark -

@interface SNMemoryCache : NSObject
{
    NSCache *memCache;
}

+ (SNMemoryCache *)defaultCache;

- (id)objectForKey:(NSString *)key;
- (void)saveObject:(NSObject *)obj forKey:(NSString *)key;
- (void)removeObjectForKey:(NSObject *)key;

- (void)clearMemory;

@end