//
//  QNDnsError.m
//  Doh
//
//  Created by yangsen on 2021/7/20.
//

#import "QNDnsError.h"

@implementation QNDnsError

+ (NSError *)error:(int)code desc:(NSString *)desc {
    return [NSError errorWithDomain:kQNDnsErrorDomain code:code userInfo:@{@"user_info" : desc ?: @"nil"}];
}

@end
