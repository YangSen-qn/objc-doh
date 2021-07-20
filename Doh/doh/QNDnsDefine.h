//
//  QNDnsDefine.h
//  Doh
//
//  Created by yangsen on 2021/7/20.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QNDnsRecordType) {
    QNDnsRecordTypeA = 1, // IPv4 地址
    QNDnsRecordTypeNS = 2, // NS 记录
    QNDnsRecordTypeCNAME = 5, // NS 记录
    QNDnsRecordTypeSOA = 6, // ZONE 的 SOA 记录
    QNDnsRecordTypeTXT = 16, // TXT 记录
    QNDnsRecordTypeAAAA = 28, // IPv6 地址
};

typedef NS_ENUM(NSInteger, QNDnsOpCode) {
    QNDnsOpCodeQuery = 0,  // 标准查询
    QNDnsOpCodeIQuery = 1, // 反向查询
    QNDnsOpCodeStatus = 2, // DNS状态请求
    QNDnsOpCodeUpdate = 5, // DNS域更新请求
};
