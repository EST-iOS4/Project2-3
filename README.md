# FrogHouse

<img width="800" height="600" alt="FrogHouseMockUp" src="https://github.com/user-attachments/assets/d9754e1e-43db-4255-a962-1ce9f778090b" />

🌟 이스트소프트 4회차 2차 프로젝트 iOS 3팀
</br>

## Tech Stack

- iOS 18.5+
- UIKit
- Combine
- Firebase
  </br>
  
## 🔔주요 기능 시연 사진
| 메인 | 카테고리 | 상세 화면 | 전체 화면 | 추천 화면 | 시청 기록 및 좋아요 | 
| --- | --- | --- | --- | --- | --- | 
|  <img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/bb5b16c4-e552-4cd5-9778-f61bbefd8345" /> |  <img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/5c68addf-caa7-4381-bde7-525e1ec78a13" /> |  <img width="1206" height="2622" alt="simulator_screenshot_E4CDA2E4-AD1D-4B19-8455-58F1697D8346" src="https://github.com/user-attachments/assets/6c0333a4-18e9-4f76-98bd-2f01c5bad043" /> | <img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/cf5a0f7c-e4a9-4e59-a048-e38564ea6c68" /> | <img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/a17522f2-bbaf-48f8-9d18-8ab65ab41274" /> | <img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/652a1bc4-a338-499e-9894-37765cac11db" /> | <img width="1206" height="2622" alt="image" src="https://github.com/user-attachments/assets/ef697417-afe6-49d9-b8a7-df8f120fbf59" />

## Code Convention

[StyleShare에서 작성한 Swift 한국어 스타일 가이드](https://github.com/StyleShare/swift-style-guide)
</br>
</br>

## Commit Convention

```
[CHORE] 코드 수정, 내부 파일 수정, 주석
[FEAT] 새로운 기능 구현
[ADD] Feat 이외의 부수적인 코드 추가, 라이브러리 추가, 새로운 파일 생성 시, 에셋 추가
[FIX] 버그, 오류 해결
[DEL] 쓸모없는 코드 삭제
[DOCS] README나 WIKI 등의 문서 개정
[MOVE] 프로젝트 내 파일이나 코드의 이동
[RENAME] 파일 이름 변경이 있을 때 사용합니다
[REFACTOR] 전면 수정이 있을 때 사용합니다
[INIT] 프로젝트 생성
```

</br>

## Git Branch Convention

```
feat/큰기능명/세부기능명

예시)
feat/Login/Apple
feat/FrogHouse/UI
```

</br>

## Foldering

```
📦 FrogHouse
│
├─ 🗂 Application      // AppDelegate, SceneDelegate 등
├─ 🗂 Resource         // Assets, Storyboards, Fonts, Lottie 등
└─ 🗂 Source
    ├─ 🗂 Common
    │   ├─ Extension   // UIKit, Foundation 등 확장
    │   └─ Util        // Helper, Manager, 공통 클래스
    │
    └─ 🗂 Scene
        ├─ Base        // 공통 Base VC, Base ViewModel
        ├─ VideoList   // VideoList 관련 VC, ViewModel
        ├─ RecommendedVideo  // Recommended VC, ViewModel
        └─ MyVideo     // MyVideo / WatchHistory VC, ViewModel

```

</br>
