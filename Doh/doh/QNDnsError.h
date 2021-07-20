//
//  QNDnsError.h
//  Doh
//
//  Created by yangsen on 2021/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kQNDnsInvalidParamErrorCode -10001
#define kQNDnsResponseBadTypeErrorCode -10002
#define kQNDnsResponseBadClassErrorCode -10003
#define kQNDnsResponseFormatErrorCode -10004

#define kQNDnsErrorDomain @"QNDnsDomain"

@interface QNDnsError : NSObject

+ (NSError *)error:(int)code desc:(NSString *)desc;

@end

#define kQNDnsInvalidParamError(description)      [QNDnsError error:kQNDnsInvalidParamErrorCode desc:description]
#define kQNDnsResponseBadTypeError(description)   [QNDnsError error:kQNDnsResponseBadTypeErrorCode desc:description]
#define kQNDnsResponseBadClassError(description)  [QNDnsError error:kQNDnsResponseBadClassErrorCode desc:description]
#define kQNDnsResponseFormatError(description)    [QNDnsError error:kQNDnsResponseFormatErrorCode desc:description]

NS_ASSUME_NONNULL_END
