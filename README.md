# ComeIt <img src = "https://github.com/JongPyoAhn/Gitramy/blob/main/ComeIt/Assets.xcassets/AppIcon.appiconset/1024.png?raw=true" width = 50 align = right>
<img src = "https://github.com/JongPyoAhn/ComeIt/blob/main/ScreenShots/ComeitScreenshot.png?raw=true">

> **첫 번째 개인 Project**

[<img src = "https://devimages-cdn.apple.com/app-store/marketing/guidelines/images/badge-download-on-the-app-store.svg">](https://apps.apple.com/kr/app/컴잇/id1599428215?mt=8)

# 📖 프로젝트 소개

 **개발실력 향상을 위한 습관을 들이는 방법 ⚒️,  Comeit**
 
 👋 Comeit을 개발한 **안종표**입니다!

### 📝 개발실력을 향상시키고 싶으신가요?
> Comeit에서 알림받고 1일 1커밋을 성공하세요!

### 💡 간편하게 커밋현황을 볼 수 있습니다.
> Contribution 이미지와 그래프를 통해 한눈에 확인할 수 있습니다.

### 🫵 원하는 레포지토리를 선택하세요!
> 선택된 저장소에 관해 오늘 자신이 몇번의 커밋을 했는지 볼 수 있습니다.

# ✨ 주요 기능
### 선택된 저장소에 관해 오늘 자신이 몇번의 커밋을 했는지 볼 수 있습니다.
### 푸시알림을 여러개 추가하여 여러개의 푸시알림을 받을 수 있습니다.
### 시각적인 통계를 통해 이번주 저장소의 순위와 자주 사용하는 언어의 통계를 확인할 수 있습니다.

# 🔨 기술 소개

## ➡️ MVVM

### 도입 이유
- 사용자 입력 및 뷰의 로직과 비즈니스 로직을 분리하고 싶었습니다.
- 처음 MVC로 구현한 프로젝트의 ViewController가 비대해져서 유지보수하기 어려워지는 것을 경험하였습니다.

### 도입 결과
- 뷰의 로직과 비즈니스로직의 독립적인 개발이 가능해졌습니다.
- ViewController가 ViewModel의 프로퍼티를 참조하는 의존성을 해결할 수 있었습니다.

## ➡️ Coordinator Pattern

### 도입 이유
- ViewController에서 화면을 전환하는 역할을 분리하기 위해 적용했습니다.

### 도입 결과
- ViewController간의 데이터 전달 시, 전달되는 데이터를 한눈에 파악할 수 있었습니다.
- View들의 Flow를 파악하기 쉬워졌습니다.

## ➡️ Combine

### 도입 이유
- 네트워크 기반의 서비스여서 대부분의 동작이 비동기적이기 때문에 Thread 관리에 주의해야합니다.
- 통계 탭으로 넘어갈 때, 올해의 기여 이미지를 불러오는 과정으로 인해 4초간의 지연시간 발생

### 도입 결과
- 비동기 코드(DispatchQueue, OperationQueue)를 직접적으로 사용하지 않아 일관성 있는 비동기 코드로 작성할 수 있었습니다.
- escaping closure가 아닌 Combine을 활용하여 코드 양이 감소하여 깔끔해지고 실수를 방지할 수 있었습니다.
- 통계 탭으로 넘어갈 때, 지연시간 4초 -> 0초로 지연시간을 단축할 수 있었습니다.

## ➡️ Firebase

### 도입 이유
- 사용자 인증의 기능 구현을 위해 빠르게 개발 가능한 Firebase를 사용하였습니다.
- Firebase Console을 통한 프로젝트의 사용자 현황을 모니터링이 가능하다는 장점이 있었습니다.

### 도입 결과
- Firebase Authentication을 사용하여 Github 소셜 로그인을 구현하였습니다.


# 🗓️ Update
## Ver. 1
- v1.0.0: 1차 App Store release (2021.12.13)
- v1.0.1: iOS 14.0 버전부터 이용할 수 있도록 개선, 통계화면으로 이동할 때 화면이 늦게 나오는 현상을 개선(2022.02.08)
- v1.0.2: 버튼 UI 개선, 로그인 토큰만료 처리, 네트워킹 방법 변경(2022.08.09)
## Contact Me
- 📱 +82 10.7763.2458
- 📧 whdvy3@naver.com

***
**Thanks For, Watching My ReadMe**
