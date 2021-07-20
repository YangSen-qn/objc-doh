//
//  QNDnsServer.h
//  Doh
//
//  Created by yangsen on 2021/7/20.
//

#import "QNDnsDefine.h"
#import "QNDnsResponse.h"

NS_ASSUME_NONNULL_BEGIN

@interface QNDnsServer : NSObject

+ (instancetype)dnsServer:(NSString *)server timeout:(int)timeout;

- (QNDnsResponse *)lookupHost:(NSString *)host recordType:(QNDnsRecordType)recordType error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
