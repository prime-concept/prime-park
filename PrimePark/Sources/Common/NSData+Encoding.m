//
//  NSData+Encoding.m
//  PrimePark
//
//  Created by Ксения Салфетникова on 06.11.2020.
//

#import "NSData+Encoding.h"
#import "../../EsmartVirtualCard/BLEAdvertiser.h"
#import "../../EsmartVirtualCard/GroupsManager.h"
#import "../../EsmartVirtualCard/ReadersManager.h"
#import "../../EsmartVirtualCard/ReaderProfile.h"
#import "../../EsmartVirtualCard/ReaderController.h"
#import <CommonCrypto/CommonCryptor.h>
#import "../../EsmartVirtualCard/Importer.h"

@implementation NSData (Encoding)

+ (NSData *) encryptData: (NSData *) dataToEncrypt withKey:(NSData *) aesKey {
    void *key = malloc(kCCBlockSizeAES128);
    [aesKey getBytes:key length:aesKey.length];
    void *iv = malloc(kCCBlockSizeAES128);
    memset(iv, 0x00, kCCBlockSizeAES128);
    double xmlLength = dataToEncrypt.length;
    size_t size = ceil(xmlLength / kCCBlockSizeAES128) * kCCBlockSizeAES128;
    void *bytes = malloc(size);
    memcpy(bytes, dataToEncrypt.bytes, dataToEncrypt.length);
    memset(bytes + dataToEncrypt.length, 0x20, size - dataToEncrypt.length);
    void *buffer = malloc(size);
    size_t sizeEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
            kCCAlgorithmAES128,
            0,
            key, kCCBlockSizeAES128,
            iv,
            bytes, size,
            buffer, size,
            &sizeEncrypted);
    if (cryptStatus != kCCSuccess) {
        abort();
    }
    NSData *encryptedXML = [NSData dataWithBytes:buffer length:sizeEncrypted];
    free(key);
    free(iv);
    free(bytes);
    free(buffer);
    return encryptedXML;
}

+ (NSData *)decryptedDataForData:(NSData *)encryptedData withKey:(NSData *)key error:(NSError __autoreleasing**)error {
    size_t bufferSize = encryptedData.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    void *iv = malloc(16);
    memset(iv, 0x00, 16);

    CCCryptorStatus result = CCCrypt(kCCDecrypt,
                                     kCCAlgorithmAES128,
                                     0,
                                     key.bytes,
                                     kCCKeySizeAES128,
                                     iv, // iv OR NULL --> same result o_O
                                     encryptedData.bytes,
                                     encryptedData.length,
                                     buffer,
                                     bufferSize,
                                     &numBytesDecrypted);
    if (result != kCCSuccess) {
        abort();
    }
    NSData *decrypted = [NSData dataWithBytes:buffer length:numBytesDecrypted];
    free(iv);
    free(buffer);
    return decrypted;
}

+ (NSData *)dataForHex:(NSString *)hex {
    NSString *hexNoSpaces = [[[hex stringByReplacingOccurrencesOfString:@" " withString:@""]
            stringByReplacingOccurrencesOfString:@"<" withString:@""]
            stringByReplacingOccurrencesOfString:@">" withString:@""];

    NSMutableData *data = [[NSMutableData alloc] init];
    unsigned char whole_byte = 0;
    char byte_chars[3] = {'\0','\0','\0'};
    for (NSUInteger i = 0; i < [hexNoSpaces length] / 2; i++) {
        byte_chars[0] = (unsigned char) [hexNoSpaces characterAtIndex:(NSUInteger) (i * 2)];
        byte_chars[1] = (unsigned char) [hexNoSpaces characterAtIndex:(NSUInteger) (i * 2 + 1)];
        whole_byte = (unsigned char)strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    return data;
}

+ (NSData *) getValueForKey: (NSString *) key {
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];

    query[(__bridge id)kSecClass] =(__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrSynchronizable] = (__bridge id)kSecAttrSynchronizableAny;
    query[(__bridge id)(kSecAttrService)] = @"ISBCKeyCard";

    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;

    query[(__bridge id)kSecAttrAccount] = key;
    CFDictionaryRef cfquery = (__bridge_retained CFDictionaryRef) query;
    CFTypeRef data = nil;
    OSStatus status = SecItemCopyMatching(cfquery, &data);
    CFRelease(cfquery);
    NSData *ret;
    if (status == errSecSuccess) {
        if (data) {
            ret = [[NSData alloc] initWithData:(__bridge NSData *) data];
            CFRelease(data);
        }
    }
    return ret;
}

+ (void) deleteValueForKey: (NSString *) key {
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];

    query[(__bridge id)kSecClass] =(__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrSynchronizable] = (__bridge id)kSecAttrSynchronizableAny;
    query[(__bridge id)(kSecAttrService)] = @"ISBCKeyCard";

    query[(__bridge id)kSecAttrAccount] = key;
    CFDictionaryRef cfquery = (__bridge_retained CFDictionaryRef) query;
    OSStatus status = SecItemCopyMatching(cfquery, NULL);
    if ((status == errSecInteractionNotAllowed) ||  (status == errSecSuccess)) {
        status = SecItemDelete((__bridge CFDictionaryRef)query);
    }
    CFRelease(cfquery);
}

+ (NSData *) genAesKey {
    NSLog(@"Generate new aes key");
    uuid_t uuid;
    [[NSUUID UUID] getUUIDBytes:uuid];
    NSData *aesKey = [NSData dataWithBytes:uuid length:kCCBlockSizeAES128];
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    query[(__bridge id)kSecAttrSynchronizable] = (__bridge id)kSecAttrSynchronizableAny;
    query[(__bridge id)kSecAttrService] = @"ISBCKeyCard";
    query[(__bridge id)kSecAttrAccount] = @"K_AES";
    query[(__bridge id)kSecValueData] = aesKey;
    query[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAlways;
    if (SecItemAdd((__bridge CFDictionaryRef)query, NULL) == errSecSuccess) {
    }
    return aesKey;
}

+ (void)commonInit {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEsmartLibraryEvent:)
                                                 name:@"ESMART_VIRTUAL_CARD_EVENT"
                                               object:nil];
    [self listGroups];

    if (! [GroupsManager isActiveGroupExist]) {
        [self importLocalConfig];
    }
}

+ (void) listGroups {
    NSArray *list = [GroupsManager groupsList];
    NSLog(@"Groups in library:");
    for (Group *group in list) {
        NSLog(@"\tGroup: %@; %@ %@ %@ %@", group.groupId, group.enabled ? @"enabled" : @"disabled", group.expired ? @"expired" : @"not expired", group.userId, @"-"/*[EsmartCloudGroupStatus stringValueFromEnum:group.cloudStatus]*/);
    }
}

+ (void) handleEsmartLibraryEvent: (NSNotification*) notificationEvent {
    NSDictionary * eventInfo = notificationEvent.userInfo;
    NSString *evtTask = (NSString *) [eventInfo objectForKey:@"EVT"];
    if ([@"IMPORT" isEqualToString:evtTask]) {
        NSString *state = [eventInfo valueForKey:@"STATE"];
        if ([state isEqualToString:@"START"]) {
            NSLog(@"Import start");
        } else if ([state isEqualToString:@"FINISH"]) {
            NSLog(@"Import end");
            NSLog(@"List import result");
            NSNumber *groups = [eventInfo valueForKey:@"GroupsAffected"];
            NSLog(@"Groups: %@", groups);
            NSNumber *readers = [eventInfo valueForKey:@"ReadersAffected"];
            NSLog(@"Readers: %@", readers);
            NSDictionary *groupsNames = [eventInfo valueForKey:@"GroupsNames"];
            NSArray *affectedGroups = [groupsNames allKeys];
            if (affectedGroups.count > 0) {
                NSLog(@"Imported Groups: %@", affectedGroups);
                [self listGroups];
                [BLEAdvertiser startAdvertising];
            } else {
                NSLog(@"\tNo groups imported");
            }
        }
    } else if ([@"GROUP_EXPIRED" isEqualToString:evtTask]) {
        Group *g = [eventInfo valueForKey:@"GROUP"];
        NSLog(@"Group Expire: %@", g);
    } else if ([@"RSSI_CHANGED" isEqualToString:evtTask]) {
        /*
        NSString *readerId = [eventInfo objectForKey:@"READER_IDENTIFIER"];
        ReaderProfile *reader = [[ReadersManager getInstance] getReaderProfileById:readerId];
        NSString *readerType = [self.knownReaders objectForKey:reader.identifier];
        if (readerType == nil) {
            [ReaderController determineReaderVersion:reader];
            readerType = reader.identifier;
        }
        NSNumber *flags = [eventInfo objectForKey:@"FLAGS"];
        [self appendText:[NSString stringWithFormat:@"RSSI[%@]: %d FLAG:%d", readerType, reader.rssi, flags.unsignedIntValue]];
         */
    } else if ([@"HIDE_NOTIFICATION" isEqualToString:evtTask]) {
        BOOL userIdSent = ([(NSNumber *) [eventInfo objectForKey:@"USERID_SENT"] boolValue]);
        if (userIdSent) {
            /*
            [self appendText:[NSString stringWithFormat:@"OPEN"]];
             */
        }
    } else if ([@"READER_EVENT" isEqualToString:evtTask]) {
        NSString *cfg_sent = [eventInfo objectForKey:@"TYPE"];
        if ([@"CONFIG_SENT" isEqualToString:cfg_sent]) {
            ReaderProfile *reader = [eventInfo objectForKey:@"READER"];
//            Group *group = [GroupsManager groupByIdentifier:reader.groupId];
//            [self appendText:[NSString stringWithFormat:@"CFG: %d/%d", reader.TapArea, reader.NotificationArea]];
        }
    } else if ([@"ADVERTISEMENT_STATE" isEqualToString:evtTask]) {
        NSString *state = [eventInfo objectForKey:@"STATE"];
        if ([@"ON" isEqualToString:state]) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                self.text.text = @"";
            });
        }
//        [self appendText:[NSString stringWithFormat:@"ADVERTISE:%@", state]];
    }
}

+ (void)importLocalConfig {
    NSLog(@"Need import");
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"import" ofType:@"xml"];
    NSString *import = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    import = [NSString stringWithFormat:import, [NSUUID UUID].UUIDString];
    NSLog(@"Import loaded: %@", import);
    
    NSData *xml = [import dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *aesKey = [NSData getValueForKey:@"K_AES"];
    if (aesKey == nil) {
        aesKey = [NSData genAesKey];
    } else {
        NSLog(@"Use existing aes key");
    }
    
    NSString *temporaryFilename = [[NSUUID UUID] UUIDString];
    NSURL *tmpDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *fileURL = [[tmpDirURL URLByAppendingPathComponent:temporaryFilename] URLByAppendingPathExtension:@"ESIF"];
    NSData *encryptedXML = [NSData encryptData:xml withKey:aesKey];
    BOOL written = [encryptedXML writeToURL:fileURL atomically:YES];
    if (written) {
        [Importer importFile:fileURL batchOperation:NO];
        NSLog(@"Import launched");
    } else {
        NSLog(@"Error write file");
    }
}

+ (void)click {
    if (! [BLEAdvertiser isAdvertising]) {
        [BLEAdvertiser startAdvertising];
    } else {
        [BLEAdvertiser stopAdvertising];
    }
}

@end
