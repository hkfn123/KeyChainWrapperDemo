### 主要功能
提供简单的钥匙串访问接口
### 依赖库
`Security.framework`
### 系统要求
`iOS6+`
### 如何使用
1. 添加依赖库到项目中，并将`KeyChainWrapper.h`和`KeyChainWrapper.m`到项目中。
2. 以`NSString`为例子添加如下代码：
3. 删除调用`- (BOOL)deleteItemForKey:(NSString *)key`或者`- (void)resetKeyChain`

```
NSString *storeKey = @"storKey";
NSString *storeValue = @"some value";
NSData *data = [storeValue dataUsingEncoding:NSUTF8StringEncoding];
[[KeyChainWrapper keyChain] setData:data forKey:storeKey];
```
其他类型的对象都可以转化成NSData后保存到钥匙串中，你也可以使用`+ (instancetype) keyChainWithService:(NSString *)service`指定一个服务名称，你也可以指定一个权限访问组名`+(instancetype) keyChainWithService:(NSString *)service withGroupName:(NSString *)group`
方法类似，具体例子可以运行示例程序。
