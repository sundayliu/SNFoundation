//
//  NSData+Crypto.m
//  SubookDRM
//
//  Created by wangrui on 7/21/12.
//  Copyright (c) 2012 suning. All rights reserved.
//

#import "NSData+Crypto.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

#define PBE_DEFAULT_SALT   @"bO0KsAlt"
#define MD5_ITERATIONS_NUM 100

NSString *const kCommonCryptoErrorDomain = @"CommonCryptoErrorDomain";

static void FixKeyLengths(CCAlgorithm algorithm, NSMutableData *keyData, NSMutableData *ivData);

@implementation NSError (CommonCryptoErrorDomain)

+ (NSError *)errorWithCCCryptorStatus:(CCCryptorStatus)status
{
    NSString *description = nil, *reason = nil;

    switch (status)
    {
        case kCCSuccess:
            description = NSLocalizedString(@"Success", @"Error description");
            break;

        case kCCParamError:
            description = NSLocalizedString(@"Parameter Error", @"Error description");
            reason = NSLocalizedString(@"Illegal parameter supplied to encryption/decryption algorithm", @"Error reason");
            break;

        case kCCBufferTooSmall:
            description = NSLocalizedString(@"Buffer Too Small", @"Error description");
            reason = NSLocalizedString(@"Insufficient buffer provided for specified operation", @"Error reason");
            break;

        case kCCMemoryFailure:
            description = NSLocalizedString(@"Memory Failure", @"Error description");
            reason = NSLocalizedString(@"Failed to allocate memory", @"Error reason");
            break;

        case kCCAlignmentError:
            description = NSLocalizedString(@"Alignment Error", @"Error description");
            reason = NSLocalizedString(@"Input size to encryption algorithm was not aligned correctly", @"Error reason");
            break;

        case kCCDecodeError:
            description = NSLocalizedString(@"Decode Error", @"Error description");
            reason = NSLocalizedString(@"Input data did not decode or decrypt correctly", @"Error reason");
            break;

        case kCCUnimplemented:
            description = NSLocalizedString(@"Unimplemented Function", @"Error description");
            reason = NSLocalizedString(@"Function not implemented for the current algorithm", @"Error reason");
            break;

        default:
            description = NSLocalizedString(@"Unknown Error", @"Error description");
            break;
    }

    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:description forKey:NSLocalizedDescriptionKey];

    if (reason != nil)
    {
        [userInfo setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
    }

    NSError *result = [NSError errorWithDomain:kCommonCryptoErrorDomain code:status userInfo:userInfo];

    return result;
}

@end

#pragma mark -

@implementation NSData (CommonDigest)

- (NSData *)MD2Sum
{
    unsigned char hash[CC_MD2_DIGEST_LENGTH];

    (void)CC_MD2([self bytes], (CC_LONG)[self length], hash);
    return [NSData dataWithBytes:hash length:CC_MD2_DIGEST_LENGTH];
}

- (NSData *)MD4Sum
{
    unsigned char hash[CC_MD4_DIGEST_LENGTH];

    (void)CC_MD4([self bytes], (CC_LONG)[self length], hash);
    return [NSData dataWithBytes:hash length:CC_MD4_DIGEST_LENGTH];
}

- (NSData *)MD5Sum
{
    unsigned char hash[CC_MD5_DIGEST_LENGTH];

    (void)CC_MD5([self bytes], (CC_LONG)[self length], hash);
    return [NSData dataWithBytes:hash length:CC_MD5_DIGEST_LENGTH];
}

- (NSData *)SHA1Hash
{
    unsigned char hash[CC_SHA1_DIGEST_LENGTH];

    (void)CC_SHA1([self bytes], (CC_LONG)[self length], hash);
    return [NSData dataWithBytes:hash length:CC_SHA1_DIGEST_LENGTH];
}

- (NSData *)SHA224Hash
{
    unsigned char hash[CC_SHA224_DIGEST_LENGTH];

    (void)CC_SHA224([self bytes], (CC_LONG)[self length], hash);
    return [NSData dataWithBytes:hash length:CC_SHA224_DIGEST_LENGTH];
}

- (NSData *)SHA256Hash
{
    unsigned char hash[CC_SHA256_DIGEST_LENGTH];

    (void)CC_SHA256([self bytes], (CC_LONG)[self length], hash);
    return [NSData dataWithBytes:hash length:CC_SHA256_DIGEST_LENGTH];
}

- (NSData *)SHA384Hash
{
    unsigned char hash[CC_SHA384_DIGEST_LENGTH];

    (void)CC_SHA384([self bytes], (CC_LONG)[self length], hash);
    return [NSData dataWithBytes:hash length:CC_SHA384_DIGEST_LENGTH];
}

- (NSData *)SHA512Hash
{
    unsigned char hash[CC_SHA512_DIGEST_LENGTH];

    (void)CC_SHA512([self bytes], (CC_LONG)[self length], hash);
    return [NSData dataWithBytes:hash length:CC_SHA512_DIGEST_LENGTH];
}

@end

@implementation NSData (CommonCryptor)

#pragma mark AES Cypto
- (NSData *)AES128EncryptedDataUsingKey:(id)key error:(NSError **)error
{
    CCCryptorStatus status = kCCSuccess;

    NSData *iv = key;

    NSData *result = [self dataEncryptedUsingAlgorithm:kCCAlgorithmAES128
                                                   key:key
                                  initializationVector:iv
                                               options:kCCOptionPKCS7Padding
                                                 error:&status];

    if (result != nil)
    {
        return result;
    }

    if (error != NULL)
    {
        *error = [NSError errorWithCCCryptorStatus:status];
    }

    return nil;
}

- (NSData *)decryptedAES128DataUsingKey:(id)key error:(NSError **)error
{
    CCCryptorStatus status = kCCSuccess;

    NSData *iv = key;

    NSData *result = [self decryptedDataUsingAlgorithm:kCCAlgorithmAES128
                                                   key:key
                                  initializationVector:iv
                                               options:kCCOptionPKCS7Padding
                                                 error:&status];

    if (result != nil)
    {
        return result;
    }

    if (error != NULL)
    {
        *error = [NSError errorWithCCCryptorStatus:status];
    }

    return nil;
}

#pragma mark DES Cypto
- (NSData *)DESEncryptedDataUsingKey:(id)key error:(NSError **)error
{
    CCCryptorStatus status = kCCSuccess;
    NSData         *result = [self dataEncryptedUsingAlgorithm:kCCAlgorithmDES
                                                           key:key
                                          initializationVector:nil
                                                       options:kCCOptionECBMode + kCCOptionPKCS7Padding
                                                         error:&status];

    if (result != nil)
    {
        return result;
    }

    if (error != NULL)
    {
        *error = [NSError errorWithCCCryptorStatus:status];
    }

    return nil;
}

- (NSData *)decryptedDESDataUsingKey:(id)key error:(NSError **)error
{
    CCCryptorStatus status = kCCSuccess;
    NSData         *result = [self decryptedDataUsingAlgorithm:kCCAlgorithmDES
                                                           key:key
                                          initializationVector:nil
                                                       options:kCCOptionECBMode + kCCOptionPKCS7Padding
                                                         error:&status];

    if (result != nil)
    {
        return result;
    }

    if (error != NULL)
    {
        *error = [NSError errorWithCCCryptorStatus:status];
    }

    return nil;
}

#pragma mark PBE Cypto
- (NSData *)PBEEncryptedDataUsingKey:(id)pwd error:(NSError **)error
{
    NSParameterAssert([pwd isKindOfClass:[NSData class]] || [pwd isKindOfClass:[NSString class]]);

    NSMutableData *pData;

    if ([pwd isKindOfClass:[NSData class]])
    {
        pData = (NSMutableData *)[pwd mutableCopy];
    }
    else
    {
        pData = [[pwd dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    }

    NSData *salt = [PBE_DEFAULT_SALT dataUsingEncoding:NSUTF8StringEncoding];

    uint8_t md5[CC_MD5_DIGEST_LENGTH];
    memset(md5, 0, CC_MD5_DIGEST_LENGTH);

    CC_MD5_CTX ctx;
    CC_MD5_Init(&ctx);
    CC_MD5_Update(&ctx, [pData bytes], (CC_LONG)[pData length]);
    CC_MD5_Update(&ctx, [salt bytes], (CC_LONG)[salt length]);
    CC_MD5_Final(md5, &ctx);

    int i = 0;

    while (++i < MD5_ITERATIONS_NUM)
    {
        CC_MD5(md5, CC_MD5_DIGEST_LENGTH, md5);
    }

    NSData *key = [NSData dataWithBytes:md5 length:CC_MD5_DIGEST_LENGTH];

    unsigned char iv[kCCBlockSizeDES];
    memcpy(iv, md5 + (CC_MD5_DIGEST_LENGTH / 2), sizeof(iv));
    NSData *civ = [NSData dataWithBytes:iv length:kCCBlockSizeDES];

    CCCryptorStatus status = kCCSuccess;
    NSData         *result = [self dataEncryptedUsingAlgorithm:kCCAlgorithmDES
                                                           key:key
                                          initializationVector:civ
                                                       options:kCCOptionPKCS7Padding
                                                         error:&status];

    if (result != nil)
    {
        return result;
    }

    if (error != NULL)
    {
        *error = [NSError errorWithCCCryptorStatus:status];
    }

    return nil;
}

- (NSData *)decryptedPBEDataUsingKey:(id)pwd error:(NSError **)error
{
    NSParameterAssert([pwd isKindOfClass:[NSData class]] || [pwd isKindOfClass:[NSString class]]);

    NSMutableData *pData;

    if ([pwd isKindOfClass:[NSData class]])
    {
        pData = (NSMutableData *)[pwd mutableCopy];
    }
    else
    {
        pData = [[pwd dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    }

    NSData *salt = [PBE_DEFAULT_SALT dataUsingEncoding:NSUTF8StringEncoding];

    uint8_t md5[CC_MD5_DIGEST_LENGTH];
    memset(md5, 0, CC_MD5_DIGEST_LENGTH);

    CC_MD5_CTX ctx;
    CC_MD5_Init(&ctx);
    CC_MD5_Update(&ctx, [pData bytes], (CC_LONG)[pData length]);
    CC_MD5_Update(&ctx, [salt bytes], (CC_LONG)[salt length]);
    CC_MD5_Final(md5, &ctx);

    int i = 0;

    while (++i < MD5_ITERATIONS_NUM)
    {
        CC_MD5(md5, CC_MD5_DIGEST_LENGTH, md5);
    }

    NSData *key = [NSData dataWithBytes:md5 length:CC_MD5_DIGEST_LENGTH];

    unsigned char iv[kCCBlockSizeDES];
    memcpy(iv, md5 + (CC_MD5_DIGEST_LENGTH / 2), sizeof(iv));
    NSData *civ = [NSData dataWithBytes:iv length:kCCBlockSizeDES];

    CCCryptorStatus status = kCCSuccess;
    NSData         *result = [self decryptedDataUsingAlgorithm:kCCAlgorithmDES
                                                           key:key
                                          initializationVector:civ
                                                       options:kCCOptionPKCS7Padding
                                                         error:&status];

    if (result != nil)
    {
        return result;
    }

    if (error != NULL)
    {
        *error = [NSError errorWithCCCryptorStatus:status];
    }

    return nil;
}

@end

static void FixKeyLengths(CCAlgorithm algorithm, NSMutableData *keyData, NSMutableData *ivData)
{
    NSUInteger keyLength = [keyData length];

    switch (algorithm)
    {
        case kCCAlgorithmAES128:
        {
            if (keyLength <= 16)
            {
                [keyData setLength:16];
            }
            else if (keyLength <= 24)
            {
                [keyData setLength:24];
            }
            else
            {
                [keyData setLength:32];
            }

            break;
        }

        case kCCAlgorithmDES:
        {
            [keyData setLength:8];
            break;
        }

        case kCCAlgorithm3DES:
        {
            [keyData setLength:24];
            break;
        }

        case kCCAlgorithmCAST:
        {
            if (keyLength <= 5)
            {
                [keyData setLength:5];
            }
            else if (keyLength >= 16)
            {
                [keyData setLength:16];
            }

            break;
        }

        case kCCAlgorithmRC4:
        {
            if (keyLength >= 512)
            {
                [keyData setLength:512];
            }

            break;
        }

        default:
            break;
    }

    [ivData setLength:[keyData length]];
}

@implementation NSData (LowLevelCommonCryptor)

- (NSData *)_runCryptor:(CCCryptorRef)cryptor result:(CCCryptorStatus *)status
{
    size_t bufsize = CCCryptorGetOutputLength(cryptor, (size_t)[self length], true);
    void  *buf = malloc(bufsize);

    size_t bufused = 0;
    size_t bytesTotal = 0;

    *status = CCCryptorUpdate(cryptor, [self bytes], (size_t)[self length],
            buf, bufsize, &bufused);

    if (*status != kCCSuccess)
    {
        free(buf);
        return nil;
    }

    bytesTotal += bufused;

    // From Brent Royal-Gordon (Twitter: architechies):
    //  Need to update buf ptr past used bytes when calling CCCryptorFinal()
    *status = CCCryptorFinal(cryptor, buf + bufused, bufsize - bufused, &bufused);

    if (*status != kCCSuccess)
    {
        free(buf);
        return nil;
    }

    bytesTotal += bufused;

    return [NSData dataWithBytesNoCopy:buf length:bytesTotal];
}

- (NSData *)dataEncryptedUsingAlgorithm:(CCAlgorithm)algorithm
                                    key:(id)key
                   initializationVector:(id)iv
                                options:(CCOptions)options
                                  error:(CCCryptorStatus *)error
{
    CCCryptorRef    cryptor = NULL;
    CCCryptorStatus status = kCCSuccess;

    NSParameterAssert([key isKindOfClass:[NSData class]] || [key isKindOfClass:[NSString class]]);
    NSParameterAssert(iv == nil || [iv isKindOfClass:[NSData class]] || [iv isKindOfClass:[NSString class]]);

    NSMutableData *keyData, *ivData;

    if ([key isKindOfClass:[NSData class]])
    {
        keyData = (NSMutableData *)[key mutableCopy];
    }
    else
    {
        keyData = [[key dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    }

    if ([iv isKindOfClass:[NSString class]])
    {
        ivData = [[iv dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    }
    else
    {
        ivData = (NSMutableData *)[iv mutableCopy];     // data or nil
    }

    // ensure correct lengths for key and iv data, based on algorithms
    FixKeyLengths(algorithm, keyData, ivData);

    status = CCCryptorCreate(kCCEncrypt, algorithm, options,
            [keyData bytes], [keyData length], [ivData bytes],
            &cryptor);

    if (status != kCCSuccess)
    {
        if (error != NULL)
        {
            *error = status;
        }

        return nil;
    }

    NSData *result = [self _runCryptor:cryptor result:&status];

    if ((result == nil) && (error != NULL))
    {
        *error = status;
    }

    CCCryptorRelease(cryptor);

    return result;
}

- (NSData *)decryptedDataUsingAlgorithm:(CCAlgorithm)algorithm
                                    key:(id)key         // data or string
                   initializationVector:(id)iv          // data or string
                                options:(CCOptions)options
                                  error:(CCCryptorStatus *)error
{
    CCCryptorRef    cryptor = NULL;
    CCCryptorStatus status = kCCSuccess;

    NSParameterAssert([key isKindOfClass:[NSData class]] || [key isKindOfClass:[NSString class]]);
    NSParameterAssert(iv == nil || [iv isKindOfClass:[NSData class]] || [iv isKindOfClass:[NSString class]]);

    NSMutableData *keyData, *ivData;

    if ([key isKindOfClass:[NSData class]])
    {
        keyData = (NSMutableData *)[key mutableCopy];
    }
    else
    {
        keyData = [[key dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    }

    if ([iv isKindOfClass:[NSString class]])
    {
        ivData = [[iv dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
    }
    else
    {
        ivData = (NSMutableData *)[iv mutableCopy];     // data or nil
    }
    
    // ensure correct lengths for key and iv data, based on algorithms
    FixKeyLengths(algorithm, keyData, ivData);

    status = CCCryptorCreate(kCCDecrypt, algorithm, options,
            [keyData bytes], [keyData length], [ivData bytes],
            &cryptor);

    if (status != kCCSuccess)
    {
        if (error != NULL)
        {
            *error = status;
        }

        return nil;
    }

    NSData *result = [self _runCryptor:cryptor result:&status];

    if ((result == nil) && (error != NULL))
    {
        *error = status;
    }

    CCCryptorRelease(cryptor);

    return result;
}

@end

@implementation NSData (CommonHMAC)

- (NSData *)HMACWithAlgorithm:(CCHmacAlgorithm)algorithm
{
    return [self HMACWithAlgorithm:algorithm key:nil];
}

- (NSData *)HMACWithAlgorithm:(CCHmacAlgorithm)algorithm key:(id)key
{
    NSParameterAssert(key == nil || [key isKindOfClass:[NSData class]] || [key isKindOfClass:[NSString class]]);

    NSData *keyData = nil;

    if ([key isKindOfClass:[NSString class]])
    {
        keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        keyData = (NSData *)key;
    }

    // this could be either CC_SHA1_DIGEST_LENGTH or CC_MD5_DIGEST_LENGTH. SHA1 is larger.
    unsigned char buf[CC_SHA1_DIGEST_LENGTH];
    CCHmac(algorithm, [keyData bytes], [keyData length], [self bytes], [self length], buf);

    return [NSData dataWithBytes:buf length:(algorithm == kCCHmacAlgMD5 ? CC_MD5_DIGEST_LENGTH : CC_SHA1_DIGEST_LENGTH)];
}

@end
