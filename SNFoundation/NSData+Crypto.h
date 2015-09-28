//
//  NSData+Crypto.h
//  SubookDRM
//
//  Created by wangrui on 7/21/12.
//  Copyright (c) 2012 suning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>

extern NSString *const kCommonCryptoErrorDomain;

@interface NSError (CommonCryptoErrorDomain)
+ (NSError *)errorWithCCCryptorStatus:(CCCryptorStatus)status;
@end

@interface NSData (CommonDigest)

- (NSData *)MD2Sum;
- (NSData *)MD4Sum;
- (NSData *)MD5Sum;

- (NSData *)SHA1Hash;
- (NSData *)SHA224Hash;
- (NSData *)SHA256Hash;
- (NSData *)SHA384Hash;
- (NSData *)SHA512Hash;

@end

@interface NSData (CommonCryptor)

#pragma mark AES Cypto
- (NSData *)AES128EncryptedDataUsingKey:(id)key
                                  error:(NSError **)error;

- (NSData *)decryptedAES128DataUsingKey:(id)key
                                  error:(NSError **)error;

#pragma mark DES Cypto
- (NSData *)DESEncryptedDataUsingKey:(id)key
                               error:(NSError **)error;

- (NSData *)decryptedDESDataUsingKey:(id)key
                               error:(NSError **)error;

#pragma mark PBE Cypto
- (NSData *)PBEEncryptedDataUsingKey:(id)pwd
                               error:(NSError **)error;

- (NSData *)decryptedPBEDataUsingKey:(id)pwd
                               error:(NSError **)error;

@end

@interface NSData (LowLevelCommonCryptor)

- (NSData *)dataEncryptedUsingAlgorithm:(CCAlgorithm)algorithm
                                    key:(id)key         // data or string
                   initializationVector:(id)iv          // data or string
                                options:(CCOptions)options
                                  error:(CCCryptorStatus *)error;

- (NSData *)decryptedDataUsingAlgorithm:(CCAlgorithm)algorithm
                                    key:(id)key         // data or string
                   initializationVector:(id)iv          // data or string
                                options:(CCOptions)options
                                  error:(CCCryptorStatus *)error;

@end

@interface NSData (CommonHMAC)

- (NSData *)HMACWithAlgorithm:(CCHmacAlgorithm)algorithm;
- (NSData *)HMACWithAlgorithm:(CCHmacAlgorithm)algorithm key:(id)key;

@end
