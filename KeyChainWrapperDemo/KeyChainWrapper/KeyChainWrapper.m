//
//  KeyChainWrapper.m
//  
//
//  Created by jajeo on 10/23/15.
//
//

#import "KeyChainWrapper.h"
#import <Security/Security.h>

@interface KeyChainWrapper()

@end

@implementation KeyChainWrapper

- (instancetype) init{
    NSString *service = [[NSBundle mainBundle] bundleIdentifier];
    return [self initWithService:service withGroupName:nil];
}

- (instancetype) initWithService:(NSString *)service{
    return [self initWithService:service withGroupName:nil];
}

- (instancetype) initWithService:(NSString *)service withGroupName:(NSString *)group{
    if (self = [super init]) {
        _service = service;
        _group = group;
    }
    return self;
}


- (BOOL)setData:(NSData *)data forKey:(NSString *)key{
    if (!key || key.length == 0) {
        NSLog(@"data 或者 key 为空!");
        return NO;
    }
    
    NSDictionary *queryDic = [self _queryDicForChainItemWithKey:key];
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDic, NULL);
    
    //如果存在则更新
    if (status == errSecSuccess) {
        NSDictionary *updateDic = @{(__bridge id)kSecValueData: data};
        status = SecItemUpdate((__bridge CFDictionaryRef)queryDic, (__bridge CFDictionaryRef)updateDic);
        return status == errSecSuccess;
    }
    //不存在则添加新项目
    else {
        NSDictionary *newQuery = [self _newDicForChainItemWithKey:key withValue:data];
        status = SecItemAdd((__bridge CFDictionaryRef)newQuery, NULL);
        return status == errSecSuccess;
    }
}

- (NSData *)dataForKey:(NSString *)key{
    if (!key && key.length == 0) {
        return nil;
    }
    
    NSDictionary *queryDic = [self _queryDicForChainItemWithKey:key isLimitOne:YES];
    CFTypeRef data = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDic, &data);
    if (status != errSecSuccess) {
        return nil;
    }
    
    NSData *dataFound = [NSData dataWithData:(__bridge NSData*)data];
    if (data) CFRelease(data);
    return dataFound;
}


- (BOOL)hasValueForKey:(NSString *)key{
    if (!key || key.length == 0) {
        return NO;
    }
    
    NSDictionary *queryDic = [self _queryDicForChainItemWithKey:key ];
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryDic, NULL);
    return status == errSecSuccess;
}

- (BOOL)deleteItemForKey:(NSString *)key{
    if (!key || key.length == 0) {
        return NO;
    }
    
    NSDictionary *deleteDic = [self _queryDicForChainItemWithKey:key ];
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)deleteDic);
    return status == errSecSuccess;
}

- (void)resetKeyChain{
    NSDictionary *deleteDic = [self _queryDicForChainServiceAllItems];
    CFArrayRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)deleteDic, (CFTypeRef *)&result);
    if (status == errSecSuccess ) {
        NSArray *items = [NSArray arrayWithArray:(__bridge NSArray*)result];
        CFBridgingRelease(result);
        for (NSDictionary *item in items) {
            NSMutableDictionary *del = [[NSMutableDictionary alloc] initWithDictionary:item];
            [del setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
            OSStatus status = SecItemDelete((__bridge CFDictionaryRef)del);
            if (status != errSecSuccess) {
                break;
            }
        }
    }
}

#pragma mark - helpper method

- (NSDictionary *)_queryDicForChainServiceAllItems{
    NSMutableDictionary *retDic = [self _baseAttributes];
    [retDic setObject:@YES forKey:(__bridge id)kSecReturnAttributes];
    [retDic setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
    return retDic;
}

- (NSMutableDictionary*)_baseAttributes{
    NSMutableDictionary *attributes = [@{(__bridge id)kSecClass:(__bridge id)kSecClassGenericPassword,
                                        (__bridge id)kSecAttrService:_service} mutableCopy];
    if (!TARGET_IPHONE_SIMULATOR && _group) {
        [attributes setObject:(__bridge id)kSecAttrAccessGroup forKey:_group];
    }
    return attributes;
}

- (NSDictionary *)_queryDicForChainItemWithKey:(NSString *)key{
    return [self _queryDicForChainItemWithKey:key isLimitOne:NO];
}

- (NSDictionary *)_queryDicForChainItemWithKey:(NSString *)key isLimitOne:(BOOL)isLimitOne{
    if (!key || key.length == 0) NSAssert(key != nil, @"key 不能为空");
    
    NSMutableDictionary *retDic = [self _baseAttributes];
    [retDic setObject:key forKey:(__bridge id)kSecAttrAccount];
    if (isLimitOne) {
        [retDic setObject:@YES forKey:(__bridge id)kSecReturnData];
        [retDic setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    }
    
    return retDic;
}

- (NSDictionary *)_newDicForChainItemWithKey:(NSString *)key withValue:(NSData *)value{
    NSMutableDictionary *retDic = [self _baseAttributes];
    [retDic setObject:key forKey:(__bridge id)kSecAttrAccount];
    [retDic setObject:value forKey:(__bridge id)kSecValueData];
    [retDic setObject:[self _accessibility] forKey:(__bridge id)kSecAttrAccessible];
    return retDic;
}

- (CFTypeRef)_accessibility{
    CFTypeRef retAccessibility;
    switch (_defaultAccessType) {
        case KeyChainItemAcessibleWhenUnlocked:
            retAccessibility = kSecAttrAccessibleWhenUnlocked;
            break;
        case KeyChainItemAcessibleAfterFirstUnlock:
            retAccessibility = kSecAttrAccessibleAfterFirstUnlock;
            break;
        case KeyChainItemAcessibleAlways:
            retAccessibility = kSecAttrAccessibleAlways;
            break;
        case KeyChainItemAcessibleWhenPasscodeSetThisDeviceOnly:
            retAccessibility = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly;
            break;
        case KeyChainItemAcessibleWhenWhenUnlockedThisDeviceOnly:
            retAccessibility = kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
            break;
        case KeychainItemAccessibleAfterFirstUnlockThisDeviceOnly:
            retAccessibility = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
            break;
        case KeychainItemAccessibleAlwaysThisDeviceOnly:
            retAccessibility = kSecAttrAccessibleAlwaysThisDeviceOnly;
            break;
    }
    return retAccessibility;
}

#pragma mark - class method

+ (instancetype) keyChain{
    return [[KeyChainWrapper alloc] init];
}

+ (instancetype) keyChainWithService:(NSString *)service{
    return [[KeyChainWrapper alloc] initWithService:service];
}

+(instancetype) keyChainWithService:(NSString *)service withGroupName:(NSString *)group{
    return [[KeyChainWrapper alloc] initWithService:service withGroupName:group];
}



@end

