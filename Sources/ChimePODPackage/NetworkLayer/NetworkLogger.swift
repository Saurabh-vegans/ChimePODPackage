//
//  NetworkLogger.swift
//  NetworkLayer
//
//  Created by Diego Caroli on 06/08/2019.
//

import Foundation

class NetworkLogger {
    static func log(request: URLRequest, response: URLResponse?, dataResponse: Data?) {

        print("\n - - - - - - - - NETWORK LOGGER - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }


        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)

        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"

        var logOutput = ""
        logOutput += ("\n - - - - - - - - - - REQUEST - - - - - - - - - - \n")
        logOutput += """
        \(urlAsString) \n\n
        \(method) \(path)?\(query) HTTP/1.1 \n
        HOST: \(host)\n
        """
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            logOutput += "\(key): \(value) \n"
        }
        if let body = request.httpBody {
            logOutput += "\n \(String(data: body, encoding: .utf8) ?? "")"
        }

        logOutput += ("\n - - - - - - - - - - RESPONSE - - - - - - - - - - \n")
        if let response = response,
            let httpURLResponse = response as? HTTPURLResponse {
            logOutput += "\n \(httpURLResponse.statusCode)"
        }

        if let dataResponse = dataResponse {
            do {
                let object = try JSONSerialization.jsonObject(with: dataResponse, options: [.mutableContainers])
                let data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted])

                if let prettyPrintedString = String(data: data, encoding: .utf8) {
                    logOutput += "\n \(prettyPrintedString)"
                }
            } catch {
                if let string = String(data: dataResponse, encoding: .utf8) {
                    logOutput += "\n \(string)"
                }
            }
        }

        print(logOutput)
    }
}
