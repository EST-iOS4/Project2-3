//
//  AppDelegate.swift
//  FrogHouse
//
//  Created by 이건준 on 9/4/25.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
//        do {
//            try insertMockVideos()
//        } catch {
//            
//        }
//        return true
        Task {
            do {
                try await FirestoreVideoListStore.shared.loadFirestoreData()
            } catch {
                print("🔥 초기 데이터 로딩 실패: \(error)")
            }
        }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate {
    func insertMockVideos() throws {
#if DEBUG
        let context = PersistenceManager.shared.context
        try PersistenceManager.shared.deleteAll(request: Video.fetchRequest())
        
        struct VideoMock {
            let title: String
            let description: String
            let categories: [String]
            let mp4URL: URL?
            let thumbnailURL: URL?
            let isLiked: Bool
            let viewCount: Int64
            let createdAt: Date
        }
        
        let baseDate = Date()
        
        let videos: [VideoMock] = [
            VideoMock(title: "빅 벅 버니",
                      description: "귀여운 토끼 주인공 애니메이션 단편 영화",
                      categories: ["animation", "comedy"],
                      mp4URL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
                      thumbnailURL: URL(string: "https://peach.blender.org/wp-content/uploads/title_anouncement.jpg?x11217"),
                      isLiked: false, viewCount: 120_000,
                      createdAt: baseDate.addingTimeInterval(0)),
            
            VideoMock(title: "신텔",
                      description: "용을 찾아 떠나는 소녀의 판타지 모험 이야기",
                      categories: ["fantasy", "adventure"],
                      mp4URL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"),
                      thumbnailURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Sintel_poster.jpg/848px-Sintel_poster.jpg"),
                      isLiked: true, viewCount: 95_000,
                      createdAt: baseDate.addingTimeInterval(1)),
            
            VideoMock(title: "강철의 눈물",
                      description: "로봇과 인간의 갈등을 다룬 SF 단편 영화",
                      categories: ["sf", "action"],
                      mp4URL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"),
                      thumbnailURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Tos-poster.png/500px-Tos-poster.png"),
                      isLiked: false, viewCount: 210_000,
                      createdAt: baseDate.addingTimeInterval(2)),
            
            VideoMock(title: "더 큰 불꽃",
                      description: "불꽃 효과를 테스트하는 데모 영상",
                      categories: ["demo", "experiment"],
                      mp4URL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"),
                      thumbnailURL: URL(string: "https://i.ytimg.com/vi/2Vv-BfVoq4g/default.jpg"),
                      isLiked: false, viewCount: 15_300,
                      createdAt: baseDate.addingTimeInterval(3)),
            
            VideoMock(title: "대탈출",
                      description: "긴박한 탈출 장면 샘플 액션 영상",
                      categories: ["action", "thriller"],
                      mp4URL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"),
                      thumbnailURL: URL(string: "https://i.namu.wiki/i/OxwU3Ou-vPKcInrxHEYCGLjf-iye3aQgIeB3GEL_tGEIvGq7MEa-OhUHYXazANtJgPRYjoWfg4j_K7uEq0nagg.webp"),
                      isLiked: true, viewCount: 33_200,
                      createdAt: baseDate.addingTimeInterval(4)),
            
            VideoMock(title: "즐거운 하루",
                      description: "가볍게 웃을 수 있는 코미디 영상",
                      categories: ["comedy", "daily"],
                      mp4URL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"),
                      thumbnailURL: URL(string: "https://i.ytimg.com/vi/2vjPBrBU-TM/maxresdefault.jpg"),
                      isLiked: false, viewCount: 41_800,
                      createdAt: baseDate.addingTimeInterval(5)),
            
            VideoMock(title: "스피드 드라이브",
                      description: "신나는 자동차 주행 장면 데모 영상",
                      categories: ["car", "action"],
                      mp4URL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"),
                      thumbnailURL: URL(string: "https://drivingexperience.hyundai.co.kr/kr/image/2025/04/%EB%93%9C%EB%9D%BC%EC%9D%B4%EB%B9%99-%ED%94%8C%EB%A0%88%EC%A0%80%ED%83%9D%EC%8B%9C%EB%93%9C%EB%9D%BC%EC%9D%B4%EB%B8%8C%ED%95%98%EC%9D%B4%EC%8A%A4%ED%94%BC%EB%93%9C%EB%A0%88%EC%9D%B4%EC%8A%A4%ED%83%9D%EC%8B%9C--.jpg"),
                      isLiked: false, viewCount: 62_000,
                      createdAt: baseDate.addingTimeInterval(6)),
            
            VideoMock(title: "멜트다운",
                      description: "극적인 멜트다운 상황을 담은 드라마 영상",
                      categories: ["drama", "thriller"],
                      mp4URL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4"),
                      thumbnailURL: URL(string: "https://ojsfile.ohmynews.com/STD_IMG_FILE/2022/0612/IE003005265_STD.jpg"),
                      isLiked: true, viewCount: 27_400,
                      createdAt: baseDate.addingTimeInterval(7)),
            
            VideoMock(title: "즐거운 하루 확장판",
                      description: "코미디 영상의 확장 버전",
                      categories: ["comedy", "daily"],
                      mp4URL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"),
                      thumbnailURL: URL(string: "https://i.ytimg.com/vi/YykjpeuMNEk/maxresdefault.jpg"),
                      isLiked: false, viewCount: 18_900,
                      createdAt: baseDate.addingTimeInterval(8)),
            
            VideoMock(title: "스피드 드라이브 HD",
                      description: "고화질 자동차 주행 샘플 영상",
                      categories: ["car", "action", "demo"],
                      mp4URL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"),
                      thumbnailURL: URL(string: "https://i.ytimg.com/vi/aqz-KE-bpKQ/maxresdefault.jpg"),
                      isLiked: true, viewCount: 75_000,
                      createdAt: baseDate.addingTimeInterval(9))
        ]
        
        
        for data in videos {
            let video = Video(context: context)
            video.id = UUID()
            video.title = data.title
            video.descriptionText = data.description
            video.mp4URL = data.mp4URL
            video.thumbnailURL = data.thumbnailURL
            video.isLiked = data.isLiked
            video.createdAt = data.createdAt
            
            for name in data.categories {
                let category = Category(context: context)
                category.name = name
                video.addToCategories(category)
                category.addToVideos(video)
            }
            
            let stats = Statistics(context: context)
            stats.viewCount = data.viewCount
            stats.video = video
            video.statistics = stats
        }
        
        try context.save()
        print("목데이터 10개 삽입 완료 ✅")
#endif
    }
}
