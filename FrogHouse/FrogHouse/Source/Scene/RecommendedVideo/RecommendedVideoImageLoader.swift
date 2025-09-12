//
//  RecommendedVideoImageLoader.swift
//  FrogHouse
//
//  Created by JAY on 9/7/25.
//

import UIKit

// MARK: Jay - 간단한 이미지 로더 + 메모리 캐시
final class RecommendedVideoImageLoader {
    // MARK: Jay - Shared
    static let shared = RecommendedVideoImageLoader()
    // MARK: Jay - Cache
    private let cache = NSCache<NSURL, UIImage>()
    // MARK: Jay - Session
    private let session: URLSession
    
    // MARK: Jay - Init
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: Jay - 이미지 로드 (메인스레드 콜백)
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
    
    // MARK: Jay - 캐시 동기 조회 추가
    func cachedImage(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    // MARK: Jay - 프리페치 추가 (미리 로드해서 캐시만 채움)
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

// MARK: Jay - UIImageView URL 확장
extension UIImageView {
    // MARK: Jay - URL 로 이미지 설정 (페이드) + 캐시 히트 시 즉시 세팅으로 깜빡임 줄임
    func setImage(from url: URL?, placeholder: UIImage? = nil) {
        self.layer.removeAllAnimations() // MARK: Jay - 셀 재사용시 애니메이션 잔상 제거
        guard let url else {
            self.image = placeholder
            return
        }
        // MARK: Jay - 캐시 히트면 즉시 세팅(페이드 없음)
        if let cached = RecommendedVideoImageLoader.shared.cachedImage(for: url) {
            self.image = cached
            return
        }
        // MARK: Jay - 캐시 미스면 플레이스홀더 후 페이드
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
