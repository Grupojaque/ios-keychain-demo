//
//  ViewController.m
//  Keychain Example
//
//  Created by Orlando Rey Sánchez on 15/06/16.
//  Copyright © 2016 Grupo Jaque. All rights reserved.
//

#import "ViewController.h"
#import <Security/Security.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)savePassword:(id)sender {
    NSString *passwordText = _textField.text;
    _textField.text = @"";
    
    // Construir un identificador para la entrada en el Keychain. Debe ser único en la aplicación
    static const uint8_t keychainId[] = "com.example.keychainExample.apiToken";
    NSData *tag = [[NSData alloc] initWithBytesNoCopy:(void *)keychainId
                                               length:sizeof(keychainId)
                                         freeWhenDone:NO];
    
    // Convertimos a NSData el valor del texto
    NSData *password = [passwordText dataUsingEncoding:NSUTF8StringEncoding];
    
    // Guardar la contraseña en el Keychain
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag,
                            (__bridge id)kSecAttrKeySizeInBits: @512,
                            (__bridge id)kSecValueData: password };
    
    
    // Ejecutamos una consulta que introduce ese valor al Keychain
    OSStatus status = SecItemAdd((__bridge_retained CFDictionaryRef)query, NULL);
    
    // Pero si el item está duplicado entonces debemos actualizarlo
    if (status == errSecDuplicateItem) {
        query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                  (__bridge id)kSecAttrApplicationTag: tag,
                  (__bridge id)kSecAttrKeySizeInBits: @512 };
        
        NSDictionary *updateValues = @{ (__bridge id)kSecValueData: password };
        status = SecItemUpdate((__bridge_retained CFDictionaryRef)query, (__bridge_retained CFDictionaryRef)updateValues);
    }
}

- (IBAction)checkPassword:(id)sender {
    static const uint8_t keychainId[] = "com.example.keychainExample.apiToken";
    NSData *tag = [[NSData alloc] initWithBytesNoCopy:(void *)keychainId
                                               length:sizeof(keychainId)
                                         freeWhenDone:NO];

    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassKey,
                            (__bridge id)kSecAttrApplicationTag: tag,
                            (__bridge id)kSecAttrKeySizeInBits: @512,
                            (__bridge id)kSecReturnData: @YES };
    
    CFTypeRef dataRef = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&dataRef);
    
    if (status == errSecItemNotFound) {
        _passLabel.text = @"(No hay valores guardados)";
        
        return;
    }

    if (status == errSecSuccess) {
        NSData *passData = (__bridge_transfer NSData *)dataRef;
        _passLabel.text = [[NSString alloc] initWithData:passData encoding:NSUTF8StringEncoding];
    }
}

@end
