//
//  SSLPinningValidator.swift
//  
//
//  Created by Diego Caroli on 02/03/2020.
//

import Foundation

class SSLPinningValidator {

    private var config: Configuration

    struct Configuration {

        var validateCertificateChain: Bool
        var localCertificates: [SecCertificate] = []

        init() {
            self.validateCertificateChain = true
            self.localCertificates = SSLPinningValidator.certificates()
        }

    }

    struct Result {

        let serverTrust: SecTrust?
        let credential: URLCredential
        let isValid: Bool

        init(serverTrust: SecTrust?, isValid: Bool) {
            self.serverTrust = serverTrust
            self.isValid = isValid

            if let serverTrust = serverTrust {
                self.credential = URLCredential(trust: serverTrust)
            } else {
                self.credential = URLCredential()
            }
        }
    }

    // MARK: init
    ///init with an optional SSLPinningValidator.Configuration object, default will be used if empty
    init(withConfig config: Configuration = Configuration()) {
        self.config = config
    }

    // MARK: Validate Challenge
    ///Validate an Authentication Challenge using current settings
    ///
    /// - parameter challenge: The URLAuthenticationChallenge to validate.
    ///
    /// - parameter session: The URLSession related to the URLAuthenticationChallenge to validate.
    ///
    /// - returns: an SSLPinningValidator.Result with the response.
    public func validateChallenge(_ challenge: URLAuthenticationChallenge,
                                  forSession session: URLSession) -> Result {

        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            // Pinning failed
            return Result(serverTrust: nil, isValid: false)
        }

        // Set SSL policies for domain name check
        let policy = SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)
        SecTrustSetPolicies(serverTrust, policy)
        var serverTrustIsValid = false
        //check if we need to validate the certificate chain
        if self.config.validateCertificateChain {

            SecTrustSetPolicies(serverTrust, policy)

            SecTrustSetAnchorCertificates(serverTrust, self.config.localCertificates as CFArray)
            SecTrustSetAnchorCertificatesOnly(serverTrust, true)

            serverTrustIsValid = trustIsValid(serverTrust)
        } else {
            let serverCertificatesDataArray = certificateData(for: serverTrust)
            let pinnedCertificatesDataArray = certificateData(for: self.config.localCertificates)

            outerLoop: for serverCertificateData in serverCertificatesDataArray {
                for pinnedCertificateData in pinnedCertificatesDataArray {
                    if serverCertificateData == pinnedCertificateData {
                        serverTrustIsValid = true
                        break outerLoop
                    }
                }
            }
        }
        return Result(serverTrust: serverTrust, isValid: serverTrustIsValid)
    }

    // MARK: - Trust Validation
    private func trustIsValid(_ trust: SecTrust) -> Bool {
        var isValid = false

        var result = SecTrustResultType.invalid
        let status = SecTrustEvaluate(trust, &result)

        if status == errSecSuccess {
            let unspecified = SecTrustResultType.unspecified
            let proceed = SecTrustResultType.proceed

            isValid = result == unspecified || result == proceed
        }
        return isValid
    }

    // MARK: - Bundle Location
    /// Returns all certificates within the given bundle with a `.cer` file extension.
    ///
    /// - parameter bundle: The bundle to search for all `.cer` files.
    ///
    /// - returns: All certificates within the given bundle.
    private static func certificates(in bundle: Bundle = Bundle.main) -> [SecCertificate] {
        var certificates: [SecCertificate] = []

        let paths = Set([".cer", ".CER", ".crt", ".CRT", ".der", ".DER"].map { fileExtension in
            bundle.paths(forResourcesOfType: fileExtension, inDirectory: nil)
        }.joined())

        for path in paths {
            if
                let certificateData = try? Data(contentsOf: URL(fileURLWithPath: path)) as CFData,
                let certificate = SecCertificateCreateWithData(nil, certificateData)
            {
                certificates.append(certificate)
            }
        }
        return certificates
    }

    // MARK: - Certificate Data
    ///Get certificate data
    private func certificateData(for trust: SecTrust) -> [Data] {
        var certificates: [SecCertificate] = []

        for index in 0..<SecTrustGetCertificateCount(trust) {
            if let certificate = SecTrustGetCertificateAtIndex(trust, index) {
                certificates.append(certificate)
            }
        }

        return certificateData(for: certificates)
    }

    private func certificateData(for certificates: [SecCertificate]) -> [Data] {
        return certificates.map { SecCertificateCopyData($0) as Data }
    }

}
