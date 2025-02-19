//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

public enum TransferError: Error {
    case BASE64_DECODING_ERROR
    case DECRYPTION_ERROR(Error?, String?)
    case SIGN_ERROR(Error?)
    case LOAD_KEY_ERROR(OSStatus?)
    case CREATE_KEY_ERROR(Error?)
    case CANNOT_GET_PUBLIC_KEY
    case CANNOT_ENCODE_PUBLIC_KEY(Error?)
    case REGISTER_FAILED(Error?)
    case GET_CERTIFICATE_FAILED(Error?)
    case CANNOT_DECODE_RESPONSE(statusCode: Int)
    case DELETE_CERTIFICATE_FAILED(Error?)

    public var errorCode: String {
        switch self {
        case .BASE64_DECODING_ERROR: return "C|B64"
        case let .DECRYPTION_ERROR(error, prefix): return "C|DE\(error.errorCodeString)|\(prefix ?? "")"
        case let .SIGN_ERROR(error): return "C|SE\(error.errorCodeString)"
        case let .LOAD_KEY_ERROR(status): return "C|LKE\(status != nil ? "\(status!)" : "")"
        case let .CREATE_KEY_ERROR(error): return "C|CKE\(error.errorCodeString)"
        case .CANNOT_GET_PUBLIC_KEY: return "C|CGPK"
        case let .CANNOT_ENCODE_PUBLIC_KEY(error): return "C|CEPK\(error.errorCodeString)"
        case let .REGISTER_FAILED(error): return "N|RF\(error.errorCodeString)"
        case let .GET_CERTIFICATE_FAILED(error): return "N|GCF\(error.errorCodeString)"
        case let .CANNOT_DECODE_RESPONSE(statusCode): return "N|CDR\(statusCode)"
        case let .DELETE_CERTIFICATE_FAILED(error): return "N|DCF\(error.errorCodeString)"
        }
    }

    public var isRecovarable: Bool {
        switch self {
        case .BASE64_DECODING_ERROR:
            return false
        case .DECRYPTION_ERROR:
            return false
        case .SIGN_ERROR:
            return false
        case .LOAD_KEY_ERROR:
            return false
        case .CREATE_KEY_ERROR:
            return false
        case .CANNOT_GET_PUBLIC_KEY:
            return false
        case .CANNOT_ENCODE_PUBLIC_KEY:
            return false
        case .REGISTER_FAILED:
            return true
        case .GET_CERTIFICATE_FAILED:
            return true
        case .CANNOT_DECODE_RESPONSE:
            return true
        case .DELETE_CERTIFICATE_FAILED:
            return true
        }
    }

    public var icon: UIImage? {
        switch self {
        case let .GET_CERTIFICATE_FAILED(error as NSError), let .REGISTER_FAILED(error as NSError):
            if error.noInternetError() {
                return UIImage(named: "ic-nocon")
            } else {
                return UIImage(named: "ic-error-orange")
            }
        default:
            return UIImage(named: "ic-error-orange")
        }
    }

    public var cornerIcon: UIImage? {
        switch self {
        case let .GET_CERTIFICATE_FAILED(error as NSError), let .REGISTER_FAILED(error as NSError):
            if error.noInternetError() {
                return UIImage(named: "corner-left-no-internet")
            } else {
                return UIImage(named: "corner-left-error")
            }
        default:
            return UIImage(named: "corner-left-error")
        }
    }

    // MARK: - Title / text shown on code generation

    public var generateErrorTitle: String {
        switch self {
        case let .REGISTER_FAILED(error as NSError):
            if error.noInternetError() {
                return UBLocalized.wallet_transfer_code_no_internet_title
            } else {
                return UBLocalized.wallet_transfer_code_generate_error_title
            }
        default:
            return UBLocalized.wallet_transfer_code_generate_error_title
        }
    }

    public var generateErrorText: String {
        switch self {
        case let .REGISTER_FAILED(error as NSError):
            if error.noInternetError() {
                return UBLocalized.wallet_transfer_code_generate_no_internet_error_text
            } else {
                return UBLocalized.wallet_transfer_code_generate_error_text
            }
        default:
            return UBLocalized.wallet_transfer_code_generate_error_text
        }
    }

    // MARK: - Title / text shown on update

    public var updateErrorTitle: String {
        switch self {
        case let .GET_CERTIFICATE_FAILED(error as NSError):
            if error.noInternetError() {
                return UBLocalized.wallet_transfer_code_no_internet_title
            } else {
                return UBLocalized.wallet_transfer_code_update_error_title
            }
        default:
            return UBLocalized.wallet_transfer_code_update_error_title
        }
    }

    public var updateErrorText: String {
        switch self {
        case let .GET_CERTIFICATE_FAILED(error as NSError):
            if error.noInternetError() {
                return UBLocalized.wallet_transfer_code_update_no_internet_error_text
            } else {
                return UBLocalized.wallet_transfer_code_update_general_error_text
            }
        default:
            return UBLocalized.wallet_transfer_code_update_general_error_text
        }
    }
}

private extension Optional where Wrapped == Error {
    /// returns a empty string if there is no error
    /// if a error exists the method retruns the error code prefixed with the uppercased letters of the error domain
    /// this makes easier UI Error code generation
    var errorCodeString: String {
        guard let error = self else { return "" }
        let domain = (error as NSError).domain.filter { $0.isUppercase || $0.isPunctuation }
        return "|\(domain)\((error as NSError).code)"
    }
}
