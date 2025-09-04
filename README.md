# FrogHouse

🌟 이스트소프트 4회차 2차 프로젝트 iOS 3팀
</br>
</br>

## Tech Stack

- iOS 18.5+
- UIKit
- Combine
  </br>

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
