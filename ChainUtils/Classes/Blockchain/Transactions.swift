//
//  ONTInvocation.swift
//  ChainUtils
//
//  Created by Wyatt Mufson on 2/15/19.
//  Copyright © 2020 Ryu Games. All rights reserved.
//

import Foundation
import Neoutils

private func convertParamArray(params: [NVMParameter]) -> [String: [[String: Any]]] {
    var args: [[String: Any]] = []
    for i in 0..<params.count {
        let item = params[i]
        if item.type == .Array {
            guard let arr = item.value as? [NVMParameter] else {
                continue
            }

            let dict = convertParamArray(params: arr)
            var str: String = ""
            if let data = try? JSONSerialization.data(withJSONObject: dict) {
                str = String(data: data, encoding: .utf8) ?? ""
            }

            let arg: [String: Any] = ["type": item.type.rawValue, "value": str]
            args.append(arg)
        } else {
            let type = item.type.rawValue
            let value = item.value
            let arg: [String: Any] = ["type": type, "value": value]
            args.append(arg)
        }
    }
    return ["array": args]
}

private func buildOntologyInvocationTransactionHelper(contractHash: String, method: String, args: [String: [[String: Any]]], gasPrice: Int, gasLimit: Int, wif: String, payer: String) -> String {
    do {
        let data = try JSONSerialization.data(withJSONObject: args)
        let params = String(data: data, encoding: .utf8)
        let err = NSErrorPointer(nilLiteral: ())
        let res = NeoutilsBuildOntologyInvocationTransaction(contractHash, method, params, gasPrice, gasLimit, wif, payer, err)
        return res
    } catch {
        return ""
    }
}

public func buildOntologyInvocationTransaction(contractHash: String, method: String, args: [NVMParameter], gasPrice: Int = 0, gasLimit: Int = 0, wif: String, payer: String = "") -> String {
    let params = convertParamArray(params: args)
    let p = payer == "" ? addressFromWif(wif: wif) ?? "" : payer
    return buildOntologyInvocationTransactionHelper(contractHash: contractHash, method: method, args: params, gasPrice: gasPrice, gasLimit: gasLimit, wif: wif, payer: p)
}
