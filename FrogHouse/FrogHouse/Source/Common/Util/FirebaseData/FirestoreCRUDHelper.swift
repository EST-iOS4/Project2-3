//
//  FirestoreCRUDHelper.swift
//  FrogHouse
//
//  Created by JAY on 9/15/25.
//

import Foundation
import FirebaseFirestore

// MARK: Jay - Firestore 데이터 헬퍼
enum FirestoreCRUDHelper {
    // MARK: Jay - 좋아요 상태 업데이트
    static func updateIsLiked(id: UUID, isLiked: Bool) async throws {
        try await Firestore.firestore()
            .collection("VideoList")
            .document(id.uuidString)
            .updateData(["isLiked": isLiked])
    }
    
    // MARK: Jay - Firestore문서들을 한번에 삭제하는 함수
    func deleteAllSampleData() {
        print("🚨 deleteAllVideos called")
        let db = Firestore.firestore()
        Task {
            do {
                // VideoList 컬렉션의 모든 문서를 가져옴
                let snapshot = try await db.collection("VideoList").getDocuments()
                print("📂 Total documents to delete: \(snapshot.documents.count)")
                for document in snapshot.documents {
                    do {
                        try await db.collection("VideoList").document(document.documentID).delete()
                        print("✅ Deleted document with ID: \(document.documentID)")
                    } catch {
                        print("❌ Failed to delete document:", error)
                    }
                }
                print("🎉 All deletions attempted.")
            } catch {
                print("❌ Failed to fetch documents:", error)
            }
        }
    }

    // MARK: Jay - Firestore에 샘플데이터 삽입하는 함수
    func insertSampleData() {
        print("🚀 insertSampleVideosOnce called")
        let db = Firestore.firestore()
        let baseDate = Date()
        let videos: [[String: Any]] = [
            [
                "id": UUID().uuidString,
                "title": "빅 벅 버니",
                "description": "귀여운 토끼 주인공 애니메이션 단편 영화",
                "categories": ["animation", "comedy"],
                "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                "thumbnailURL": "https://peach.blender.org/wp-content/uploads/title_anouncement.jpg?x11217",
                "viewCount": 120_000,
                "createdAt": baseDate.addingTimeInterval(0),
                "lastWatchedAt": baseDate.addingTimeInterval(0),
                "isLiked" : false
            ],
            [
                "id": UUID().uuidString,
                "title": "신텔",
                "description": "용을 찾아 떠나는 소녀의 판타지 모험 이야기",
                "categories": ["fantasy", "adventure"],
                "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
                "thumbnailURL": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Sintel_poster.jpg/848px-Sintel_poster.jpg",
                "viewCount": 95_000,
                "createdAt": baseDate.addingTimeInterval(1),
                "lastWatchedAt": baseDate.addingTimeInterval(0),
                "isLiked" : false
            ],
            [
                "id": UUID().uuidString,
                "title": "강철의 눈물",
                "description": "로봇과 인간의 갈등을 다룬 SF 단편 영화",
                "categories": ["sf", "action"],
                "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
                "thumbnailURL": "https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Tos-poster.png/500px-Tos-poster.png",
                "viewCount": 210_000,
                "createdAt": baseDate.addingTimeInterval(2),
                "lastWatchedAt": baseDate.addingTimeInterval(0),
                "isLiked" : false
            ],
            [
                "id": UUID().uuidString,
                "title": "더 큰 불꽃",
                "description": "불꽃 효과를 테스트하는 데모 영상",
                "categories": ["demo", "experiment"],
                "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
                "thumbnailURL": "https://i.ytimg.com/vi/2Vv-BfVoq4g/default.jpg",
                "viewCount": 15_300,
                "createdAt": baseDate.addingTimeInterval(3),
                "lastWatchedAt": baseDate.addingTimeInterval(0),
                "isLiked" : false
            ],
            [
                "id": UUID().uuidString,
                "title": "대탈출",
                "description": "긴박한 탈출 장면 샘플 액션 영상",
                "categories": ["action", "thriller"],
                "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
                "thumbnailURL": "https://i.namu.wiki/i/OxwU3Ou-vPKcInrxHEYCGLjf-iye3aQgIeB3GEL_tGEIvGq7MEa-OhUHYXazANtJgPRYjoWfg4j_K7uEq0nagg.webp",
                "viewCount": 33_200,
                "createdAt": baseDate.addingTimeInterval(4),
                "lastWatchedAt": baseDate.addingTimeInterval(0),
                "isLiked" : false
            ],
            [
                "id": UUID().uuidString,
                "title": "즐거운 하루",
                "description": "가볍게 웃을 수 있는 코미디 영상",
                "categories": ["comedy", "daily"],
                "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
                "thumbnailURL": "https://i.ytimg.com/vi/2vjPBrBU-TM/maxresdefault.jpg",
                "viewCount": 41_800,
                "createdAt": baseDate.addingTimeInterval(5),
                "lastWatchedAt": baseDate.addingTimeInterval(0),
                "isLiked" : false
            ],
            [
                "id": UUID().uuidString,
                "title": "스피드 드라이브",
                "description": "신나는 자동차 주행 장면 데모 영상",
                "categories": ["car", "action"],
                "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
                "thumbnailURL": "https://drivingexperience.hyundai.co.kr/kr/image/2025/04/%EB%93%9C%EB%9D%BC%EC%9D%B4%EB%B9%99-%ED%94%8C%EB%A0%88%EC%A0%80%ED%83%9D%EC%8B%9C%EB%93%9C%EB%9D%BC%EC%9D%B4%EB%B8%8C%ED%95%98%EC%9D%B4%EC%8A%A4%ED%94%BC%EB%93%9C%EB%A0%88%EC%9D%B4%EC%8A%A4%ED%83%9D%EC%8B%9C--.jpg",
                "viewCount": 62_000,
                "createdAt": baseDate.addingTimeInterval(6),
                "lastWatchedAt": baseDate.addingTimeInterval(0),
                "isLiked" : false
            ],
            [
                "id": UUID().uuidString,
                "title": "멜트다운",
                "description": "극적인 멜트다운 상황을 담은 드라마 영상",
                "categories": ["drama", "thriller"],
                "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
                "thumbnailURL": "https://ojsfile.ohmynews.com/STD_IMG_FILE/2022/0612/IE003005265_STD.jpg",
                "viewCount": 27_400,
                "createdAt": baseDate.addingTimeInterval(7),
                "lastWatchedAt": baseDate.addingTimeInterval(0),
                "isLiked" : false
            ],
            [
                "id": UUID().uuidString,
                "title": "즐거운 하루 확장판",
                "description": "코미디 영상의 확장 버전",
                "categories": ["comedy", "daily"],
                "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
                "thumbnailURL": "https://i.ytimg.com/vi/YykjpeuMNEk/maxresdefault.jpg",
                "viewCount": 18_900,
                "createdAt": baseDate.addingTimeInterval(8),
                "lastWatchedAt": baseDate.addingTimeInterval(0),
                "isLiked" : false
            ],
            [
                "id": UUID().uuidString,
                "title": "스피드 드라이브 HD",
                "description": "고화질 자동차 주행 샘플 영상",
                "categories": ["car", "action", "demo"],
                "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
                "thumbnailURL": "https://i.ytimg.com/vi/aqz-KE-bpKQ/maxresdefault.jpg",
                "viewCount": 75_000,
                "createdAt": baseDate.addingTimeInterval(9),
                "lastWatchedAt": baseDate.addingTimeInterval(0),
                "isLiked" : false
            ]
        ]
        
        Task {
                for video in videos {
                    guard let id = video["id"] as? String else { continue }
                    // MARK: Jay - docID를 직접 지정해서 저장
                    do {
                        try await db.collection("VideoList")
                            .document(id)        // docID = id(UUID)
                            .setData(video)
                        print("✅ Added document with custom ID: \(id)")
                    } catch {
                        print("❌ Failed to add document \(id): \(error)")
                    }
                }
            }
        }

    
}


func firestoreDeleteAllSampleData() {
    print("🚨 deleteAllVideos called")
    let db = Firestore.firestore()
    Task {
        do {
            // VideoList 컬렉션의 모든 문서를 가져옴
            let snapshot = try await db.collection("VideoList").getDocuments()
            print("📂 Total documents to delete: \(snapshot.documents.count)")
            for document in snapshot.documents {
                do {
                    try await db.collection("VideoList").document(document.documentID).delete()
                    print("✅ Deleted document with ID: \(document.documentID)")
                } catch {
                    print("❌ Failed to delete document:", error)
                }
            }
            print("🎉 All deletions attempted.")
        } catch {
            print("❌ Failed to fetch documents:", error)
        }
    }
}


func firestoreInsertSampleData() {
    print("🚀 insertSampleVideosOnce called")
    let db = Firestore.firestore()
    let baseDate = Date()
    let videos: [[String: Any]] = [
        [
            "id": UUID().uuidString,
            "title": "빅 벅 버니",
            "description": "귀여운 토끼 주인공 애니메이션 단편 영화",
            "categories": ["animation", "comedy"],
            "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            "thumbnailURL": "https://peach.blender.org/wp-content/uploads/title_anouncement.jpg?x11217",
            "viewCount": 120_000,
            "createdAt": baseDate.addingTimeInterval(0),
            "lastWatchedAt": baseDate.addingTimeInterval(0),
            "isLiked" : false
        ],
        [
            "id": UUID().uuidString,
            "title": "신텔",
            "description": "용을 찾아 떠나는 소녀의 판타지 모험 이야기",
            "categories": ["fantasy", "adventure"],
            "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
            "thumbnailURL": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Sintel_poster.jpg/848px-Sintel_poster.jpg",
            "viewCount": 95_000,
            "createdAt": baseDate.addingTimeInterval(1),
            "lastWatchedAt": baseDate.addingTimeInterval(0),
            "isLiked" : false
        ],
        [
            "id": UUID().uuidString,
            "title": "강철의 눈물",
            "description": "로봇과 인간의 갈등을 다룬 SF 단편 영화",
            "categories": ["sf", "action"],
            "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
            "thumbnailURL": "https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Tos-poster.png/500px-Tos-poster.png",
            "viewCount": 210_000,
            "createdAt": baseDate.addingTimeInterval(2),
            "lastWatchedAt": baseDate.addingTimeInterval(0),
            "isLiked" : false
        ],
        [
            "id": UUID().uuidString,
            "title": "더 큰 불꽃",
            "description": "불꽃 효과를 테스트하는 데모 영상",
            "categories": ["demo", "experiment"],
            "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            "thumbnailURL": "https://i.ytimg.com/vi/2Vv-BfVoq4g/default.jpg",
            "viewCount": 15_300,
            "createdAt": baseDate.addingTimeInterval(3),
            "lastWatchedAt": baseDate.addingTimeInterval(0),
            "isLiked" : false
        ],
        [
            "id": UUID().uuidString,
            "title": "대탈출",
            "description": "긴박한 탈출 장면 샘플 액션 영상",
            "categories": ["action", "thriller"],
            "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            "thumbnailURL": "https://i.namu.wiki/i/OxwU3Ou-vPKcInrxHEYCGLjf-iye3aQgIeB3GEL_tGEIvGq7MEa-OhUHYXazANtJgPRYjoWfg4j_K7uEq0nagg.webp",
            "viewCount": 33_200,
            "createdAt": baseDate.addingTimeInterval(4),
            "lastWatchedAt": baseDate.addingTimeInterval(0),
            "isLiked" : false
        ],
        [
            "id": UUID().uuidString,
            "title": "즐거운 하루",
            "description": "가볍게 웃을 수 있는 코미디 영상",
            "categories": ["comedy", "daily"],
            "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            "thumbnailURL": "https://i.ytimg.com/vi/2vjPBrBU-TM/maxresdefault.jpg",
            "viewCount": 41_800,
            "createdAt": baseDate.addingTimeInterval(5),
            "lastWatchedAt": baseDate.addingTimeInterval(0),
            "isLiked" : false
        ],
        [
            "id": UUID().uuidString,
            "title": "스피드 드라이브",
            "description": "신나는 자동차 주행 장면 데모 영상",
            "categories": ["car", "action"],
            "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
            "thumbnailURL": "https://drivingexperience.hyundai.co.kr/kr/image/2025/04/%EB%93%9C%EB%9D%BC%EC%9D%B4%EB%B9%99-%ED%94%8C%EB%A0%88%EC%A0%80%ED%83%9D%EC%8B%9C%EB%93%9C%EB%9D%BC%EC%9D%B4%EB%B8%8C%ED%95%98%EC%9D%B4%EC%8A%A4%ED%94%BC%EB%93%9C%EB%A0%88%EC%9D%B4%EC%8A%A4%ED%83%9D%EC%8B%9C--.jpg",
            "viewCount": 62_000,
            "createdAt": baseDate.addingTimeInterval(6),
            "lastWatchedAt": baseDate.addingTimeInterval(0),
            "isLiked" : false
        ],
        [
            "id": UUID().uuidString,
            "title": "멜트다운",
            "description": "극적인 멜트다운 상황을 담은 드라마 영상",
            "categories": ["drama", "thriller"],
            "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
            "thumbnailURL": "https://ojsfile.ohmynews.com/STD_IMG_FILE/2022/0612/IE003005265_STD.jpg",
            "viewCount": 27_400,
            "createdAt": baseDate.addingTimeInterval(7),
            "lastWatchedAt": baseDate.addingTimeInterval(0),
            "isLiked" : false
        ],
        [
            "id": UUID().uuidString,
            "title": "즐거운 하루 확장판",
            "description": "코미디 영상의 확장 버전",
            "categories": ["comedy", "daily"],
            "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            "thumbnailURL": "https://i.ytimg.com/vi/YykjpeuMNEk/maxresdefault.jpg",
            "viewCount": 18_900,
            "createdAt": baseDate.addingTimeInterval(8),
            "lastWatchedAt": baseDate.addingTimeInterval(0),
            "isLiked" : false
        ],
        [
            "id": UUID().uuidString,
            "title": "스피드 드라이브 HD",
            "description": "고화질 자동차 주행 샘플 영상",
            "categories": ["car", "action", "demo"],
            "mp4URL": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
            "thumbnailURL": "https://i.ytimg.com/vi/aqz-KE-bpKQ/maxresdefault.jpg",
            "viewCount": 75_000,
            "createdAt": baseDate.addingTimeInterval(9),
            "lastWatchedAt": baseDate.addingTimeInterval(0),
            "isLiked" : false
        ]
    ]
    
    Task {
            for video in videos {
                guard let id = video["id"] as? String else { continue }
                // MARK: Jay - docID를 직접 지정해서 저장
                do {
                    try await db.collection("VideoList")
                        .document(id)        // docID = id(UUID)
                        .setData(video)
                    print("✅ Added document with custom ID: \(id)")
                } catch {
                    print("❌ Failed to add document \(id): \(error)")
                }
            }
        }
    }
