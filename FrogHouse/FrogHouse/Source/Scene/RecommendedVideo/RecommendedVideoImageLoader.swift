//
//  RecommendedVideoImageLoader.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import UIKit

final class RecommendedVideoImageLoader {
    static let shared = RecommendedVideoImageLoader()
    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let key = url as NSURL
        if let cached = cache.object(forKey: key) {
            DispatchQueue.main.async { completion(cached) }
            return
        }
        session.dataTask(with: url) { [weak self] data, _, _ in
            guard let self, let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self.cache.setObject(image, forKey: key)
            DispatchQueue.main.async { completion(image) }
        }.resume()
    }
    
    func cachedImage(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func prefetch(urls: [URL]) {
        for url in urls {
            let key = url as NSURL
            // 이미 캐시에 있으면 스킵
            if cache.object(forKey: key) != nil { continue }
            session.dataTask(with: url) { [weak self] data, _, _ in
                guard let self, let data, let image = UIImage(data: data) else { return }
                self.cache.setObject(image, forKey: key)
            }.resume()
        }
    }
}

extension UIImageView {
    func setImage(from url: URL?, placeholder: UIImage? = nil) {
        self.layer.removeAllAnimations()
        guard let url else {
            self.image = placeholder
            return
        }
        if let cached = RecommendedVideoImageLoader.shared.cachedImage(for: url) {
            self.image = cached
            return
        }
        self.image = placeholder
        RecommendedVideoImageLoader.shared.loadImage(from: url) { [weak self] image in
            guard let self else { return }
            guard let image else { return }
            UIView.transition(with: self, duration: 0.28, options: .transitionCrossDissolve) {
                self.image = image
            }
        }
    }
}
