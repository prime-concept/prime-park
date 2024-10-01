#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Encoding)

+ (NSData *) encryptData: (NSData *) dataToEncrypt withKey:(NSData *) aesKey;
+ (NSData *) decryptedDataForData:(NSData *)encryptedData withKey:(NSData *)key error:(NSError __autoreleasing**)error;
+ (NSData *) getValueForKey: (NSString *) key;
+ (void) deleteValueForKey: (NSString *) key;
+ (NSData *) genAesKey;
+ (NSData *) dataForHex:(NSString *)hex;
+ (void) importLocalConfig;
+ (void) commonInit;
+ (void) handleEsmartLibraryEvent: (NSNotification*) notificationEvent;
+ (void) click;

@end

NS_ASSUME_NONNULL_END
