//
//  StorageKeyGenerator.swift
//  RealmRepository
//
//  Created by Kolos Foltanyi on 2023. 08. 06..
//

import Foundation
import CommonCrypto

extension RealmStorageImpl {
    enum KeyGeneratorError: Error {
        case unableToGenerateKey
    }

    private enum KeyConstants {
        static let defaultSalt = "91F1F352-F246-4D9C-9BAF-E355A3BABBB6"
    }

    func generateKey(from password: String, salt: String? = nil) throws -> Data {
        guard let key = pbkdf2(password: password, salt: salt ?? KeyConstants.defaultSalt) else {
            throw KeyGeneratorError.unableToGenerateKey
        }
        return key
    }

    private func pbkdf2(password: String, salt: String) -> Data? {
        guard let passwordData = password.data(using: .utf8),
              let salt = salt.data(using: String.Encoding.utf8) else {
            return nil
        }

        var derivedKeyData = Data(repeating: 0, count: 64)
        let derivedCount = derivedKeyData.count

        let derivationStatus: Int32 = derivedKeyData.withUnsafeMutableBytes { derivedKeyBytes in
            guard let keyAddress = derivedKeyBytes.baseAddress else { return Int32(kCCParamError) }
            let keyPointer = keyAddress.assumingMemoryBound(to: UInt8.self)

            return salt.withUnsafeBytes { saltBytes -> Int32 in
                guard let saltAddress = saltBytes.baseAddress else { return Int32(kCCParamError) }
                let saltPointer = saltAddress.assumingMemoryBound(to: UInt8.self)

                return CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    password,
                    passwordData.count,
                    saltPointer,
                    salt.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    UInt32(600_000),
                    keyPointer,
                    derivedCount
                )
            }
        }

        return derivationStatus == kCCSuccess ? derivedKeyData : nil
    }
}
