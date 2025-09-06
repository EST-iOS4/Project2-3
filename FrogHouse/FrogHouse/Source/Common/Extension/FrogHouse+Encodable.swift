//
//  FrogHouse+Encodable.swift
//  FrogHouse
//
//  Created by 서정원 on 9/6/25.
//

import Foundation

extension Encodable {
    func toDictionary() -> [String:Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else { return nil }
        return jsonObject as? [String:Any]
    }
    
    func toQueryItems() -> [URLQueryItem]? {
        guard let dict = self.toDictionary() else { return nil }
        return dict.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
    }
}
