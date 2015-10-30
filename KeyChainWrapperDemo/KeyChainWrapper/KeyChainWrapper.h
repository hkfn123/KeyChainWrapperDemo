//
//  KeyChainWrapper.h
//  
//
//  Created by jajeo on 10/23/15.
//
//

#import <Foundation/Foundation.h>

//对应kSecAttrAccessible访问权限类型，具体意义参考kSecAttrAccessible
typedef enum{
    KeyChainItemAcessibleWhenUnlocked,//kSecAttrAccessibleWhenUnlocked
    KeyChainItemAcessibleAfterFirstUnlock,//kSecAttrAccessibleAfterFirstUnlock
    KeyChainItemAcessibleAlways,//kSecAttrAccessibleAlways
    KeyChainItemAcessibleWhenPasscodeSetThisDeviceOnly,//kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
    KeyChainItemAcessibleWhenWhenUnlockedThisDeviceOnly,//kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    KeychainItemAccessibleAfterFirstUnlockThisDeviceOnly,//kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    KeychainItemAccessibleAlwaysThisDeviceOnly//kSecAttrAccessibleAlwaysThisDeviceOnly
}KeyChainItemSecAccessibleType;

@interface KeyChainWrapper : NSObject

/**
 *  服务名称，默认为Bundle Identifier
 */
@property (readonly, strong, nonatomic) NSString *service;

/**
 *  钥匙串项目共享访问组，nil则不在任何访问组共享，默认是nil
 */
@property (readonly, strong, nonatomic) NSString *group;

/**
 *   默认是KeyChainItemAcessibleWhenUnlocked 具体参考kSecAttrAccessible
 */
@property (assign, nonatomic)KeyChainItemSecAccessibleType defaultAccessType;

/**
 *  使用默认值初始化实例
 *
 *  @return 初始化后的实例对象
 */
- (instancetype)init;

/**
 *  指定一个service初始化实例
 *
 *  @param service 服务名
 *
 *  @return 初始化后的实例对象
 */
- (instancetype)initWithService:(NSString *)service;

/**
 *  指定一个service 和 group 初始化实例
 *
 *  @param service 服务名
 *  @param group   访问群组名
 *
 *  @return 初始化后的实例对象
 */
- (instancetype)initWithService:(NSString *)service withGroupName:(NSString *)group;

/**
 *  使用kSecClassGenericPassword类型保存data
 *
 *  @param data     需要保存的对象二进制形式
 *  @param key      钥匙串键值
 *
 *  @return 如果保存成功，则返回`YES`，否则返回`NO`。
 */

- (BOOL)setData:(NSData *)data forKey:(NSString *)key;

/**
 *  返回从钥匙串工具中查询到的二进制内容
 *
 *  @param key 钥匙串键值
 *
 *  @return 钥匙串工具中查询到的二进制内容
 */
- (NSData *)dataForKey:(NSString *)key;

/**
 *  判断键对应的值是否存在
 *
 *  @param key 键
 *
 *  @return 存在返回｀YES｀ 否则为｀NO｀
 */
- (BOOL)hasValueForKey:(NSString *)key;

/**
 *  删除一个钥匙串项目
 *
 *  @param key 键
 *
 *  @return 删除成功返回｀YES｀ 失败返回｀NO｀
 */
- (BOOL)deleteItemForKey:(NSString *)key;

/**
 *  重置
 */
- (void)resetKeyChain;

/**
 *  使用默认值创建实例
 *
 *  @return 创建后实例对象
 */
+ (instancetype)keyChain;

/**
 *  指定一个service创建实例
 *
 *  @param service 服务名
 *
 *  @return 创建后实例对象
 */
+ (instancetype)keyChainWithService:(NSString *)service;

/**
 *  指定service和group创建实例
 *
 *  @param service 服务名
 *  @param group   访问群组名
 *
 *  @return     创建后实例对象
 */
+ (instancetype)keyChainWithService:(NSString *)service withGroupName:(NSString*)group;



@end
