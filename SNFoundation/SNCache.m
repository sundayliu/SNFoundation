//
//  SNCache.m
//  SNFramework
//
//  Created by  liukun on 13-2-26.
//  Copyright (c) 2013年 liukun. All rights reserved.
//

#import "SNCache.h"

@interface SNFileCache ()
{
    CFAbsoluteTime resignTime;  //记录进入后台的时间
}
@end


@implementation SNFileCache

@synthesize cachePath = _cachePath;

+ (SNFileCache *)defaultCache
{
    static SNFileCache *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SNFileCache alloc] init];
    });
    return _instance;
}

- (id)init
{
	self = [super init];
	if ( self )
	{
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		self.cachePath = [NSString stringWithFormat:@"%@/SNCache/", cachesDirectory];
        // Create IO serial queue
        _ioQueue = dispatch_queue_create("com.suning.SNFileCache", DISPATCH_QUEUE_SERIAL);
        
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:[self cachePathForKey:@"SNCache.plist"]];
		
		if([dict isKindOfClass:[NSDictionary class]]) {
			_cacheDictionary = [dict mutableCopy];
		} else {
			_cacheDictionary = [[NSMutableDictionary alloc] init];
		}
        
        [self cleanDisk];
        
        //清除过期的缓存
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(cleanDisk)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
	}
	return self;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    //进入后台超过5分钟回来后清空缓存
    CFAbsoluteTime currentTime = CFDateGetAbsoluteTime((CFDateRef)[NSDate date]);
    if (resignTime != 0 && currentTime - resignTime > 600) {
        
        [self cleanDisk];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    resignTime = CFDateGetAbsoluteTime((CFDateRef)[NSDate date]);
}

- (void)dealloc
{    
    dispatch_release(_ioQueue);
}

- (NSString *)cachePathForKey:(NSString *)key
{
	NSString * pathName = self.cachePath;
	
	if ( NO == [[NSFileManager defaultManager] fileExistsAtPath:pathName] )
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:pathName
								  withIntermediateDirectories:YES
												   attributes:nil
														error:NULL];
	}
    
	return [pathName stringByAppendingString:key];
}

- (BOOL)hasCached:(NSString *)key
{
    NSDate* date = [_cacheDictionary objectForKey:key];
	if(!date) return NO;
    if ([date isKindOfClass:[NSNumber class]])
    {
        if ([(NSNumber *)date intValue] == kSNCacheAgeForever) {
            return YES;
        }else{
            return NO;
        }
    }
    else
    {
        if([[[NSDate date] earlierDate:date] isEqualToDate:date]) return NO;
        return [[NSFileManager defaultManager] fileExistsAtPath:[self cachePathForKey:key]];
    }
}

- (NSData *)dataForKey:(NSString *)key
{
	if([self hasCached:key])
    {
		return [NSData dataWithContentsOfFile:[self cachePathForKey:key]
                                      options:0
                                        error:NULL];
	}
    else
    {
		return nil;
	}
}

- (void)saveData:(NSData *)data forKey:(NSString *)key
{
    [self saveData:data forKey:key cacheAge:kSNCacheAgeDefault];
}

- (void)saveData:(NSData *)data forKey:(NSString *)key cacheAge:(NSTimeInterval)age
{
    if (!data || !key)
    {
        return;
    }
    
    dispatch_async(_ioQueue, ^
    {
        NSFileManager *fileManager = NSFileManager.new;
        
        if (![fileManager fileExistsAtPath:self.cachePath])
        {
            [fileManager createDirectoryAtPath:self.cachePath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:NULL];
        }
        
        [fileManager createFileAtPath:[self cachePathForKey:key]
                             contents:data
                           attributes:nil];
        
        if (age < 0)
        {
            [_cacheDictionary setObject:@(age)
                                 forKey:key];
        }
        else
        {
            [_cacheDictionary setObject:[NSDate dateWithTimeIntervalSinceNow:age]
                                 forKey:key];
        }
        [_cacheDictionary writeToFile:[self cachePathForKey:@"SNCache.plist"]
                           atomically:YES];
    });
}

//string
- (NSString *)stringForKey:(NSString *)key
{
    NSData *data = [self dataForKey:key];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)saveString:(NSString *)string forKey:(NSString *)key
{
    [self saveString:string forKey:key cacheAge:kSNCacheAgeDefault];
}

- (void)saveString:(NSString *)string forKey:(NSString *)key cacheAge:(NSTimeInterval)age
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self saveData:data forKey:key cacheAge:age];
}

//array
- (NSArray *)arrayForKey:(NSString *)key
{
    NSData *data = [self dataForKey:key];
    id array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([array isKindOfClass:[NSArray class]])
    {
        return array;
    }
    return nil;
}

- (void)saveArray:(NSArray *)array forKey:(NSString *)key
{
    [self saveArray:array forKey:key cacheAge:kSNCacheAgeDefault];
}

- (void)saveArray:(NSArray *)array forKey:(NSString *)key cacheAge:(NSTimeInterval)age
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    [self saveData:data forKey:key cacheAge:age];
}

- (void)removeDataForKey:(NSString *)key
{
	dispatch_async(_ioQueue, ^
    {
        [[NSFileManager defaultManager] removeItemAtPath:[self cachePathForKey:key] error:nil];
    });
}

- (void)clearDisk
{
	dispatch_async(_ioQueue, ^
    {
        [_cacheDictionary removeAllObjects];
        [[NSFileManager defaultManager] removeItemAtPath:self.cachePath error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:self.cachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    });
}

- (void)cleanDisk
{
    dispatch_async(_ioQueue, ^
    {
        NSDictionary *cacheDic = [NSDictionary dictionaryWithDictionary:_cacheDictionary];
        for(NSString* key in cacheDic)
        {
			id date = [cacheDic objectForKey:key];
			if(([date isKindOfClass:[NSDate class]] && [[[NSDate date] earlierDate:date] isEqualToDate:date]) ||
               ([date isKindOfClass:[NSNumber class]] && [date intValue] == kSNCacheAgeOneLifeCycle))
            {
				[[NSFileManager defaultManager] removeItemAtPath:[self cachePathForKey:key]
                                                           error:NULL];
                [_cacheDictionary removeObjectForKey:key];
			}
		}
        [_cacheDictionary writeToFile:[self cachePathForKey:@"SNCache.plist"]
                           atomically:YES];
    });
}

- (unsigned long long)cacheSize
{
    unsigned long long size = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:self.cachePath];
    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [self.cachePath stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}

@end


#pragma mark -

@implementation SNMemoryCache

+ (SNMemoryCache *)defaultCache
{
    static SNMemoryCache *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SNMemoryCache alloc] init];
    });
    return instance;
}

- (id)init
{
	self = [super init];
	if ( self )
	{
        memCache = [[NSCache alloc] init];
        [memCache setTotalCostLimit:5000000];
        memCache.name = @"com.bluebox.SNMemoryCache";
        
		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
	}
    
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)hasCached:(NSString *)key
{
	return [memCache objectForKey:key] ? YES : NO;
}

- (id)objectForKey:(NSString *)key
{
	return [memCache objectForKey:key];
}

- (void)saveObject:(NSObject *)obj forKey:(NSString *)key
{
	if ( nil == key )
		return;
	
	if ( nil == obj )
		return;
	
	[memCache setObject:obj forKey:key];
}

- (void)removeObjectForKey:(NSObject *)key
{
	[memCache removeObjectForKey:key];
}

- (void)clearMemory
{
	[memCache removeAllObjects];
}


@end