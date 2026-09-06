# EconoBrief

미국·국내 경제 및 IT 뉴스를 한 곳에서 확인하는 Flutter 뉴스 리더 앱입니다. 여러 RSS 피드를 모아 보여주고, 한국어가 아닌 기사는 기기 내(on-device) 번역을 제공합니다.

## 주요 기능

- **경제 뉴스 | IT 뉴스** 탭 (탭 클릭/스와이프로 전환)
- 여러 RSS 피드 통합
  - 경제: CNBC, MarketWatch, WSJ, 연준(Fed), Forbes, Fortune, NPR, BBC + 한국경제·매일경제·연합뉴스·동아일보
  - IT: TechCrunch, Ars Technica, Wired, Engadget + 한국경제 IT·전자신문·블로터
- Google ML Kit 기반 온디바이스 영→한 번역 (한국어 기사는 자동으로 건너뜀)
- 새로고침 버튼 + 당겨서 새로고침(pull-to-refresh), 새로고침 중에도 기존 목록 유지
- 3단계 글자 크기 조절 (작게 / 보통 / 크게)
- 다크 Material 3 테마 + 커스텀 ClipartKorea 폰트
- 사진 없는 기사는 앱 아이콘을 플레이스홀더로 표시해 카드뷰 일관성 유지
- 루머성/미검증 소스에는 주의(⚠️) 배지 표시

## 지원 플랫폼

Android, iOS, macOS — 앱 아이콘과 빌드 설정을 구성했습니다. Windows/Linux/Web은 `flutter create`가 생성한 기본 스캐폴딩만 있고 별도로 설정하지 않았습니다.

## 시작하기

### 요구 사항

- Flutter SDK (Dart `^3.13.1` 이상)

### 실행

```bash
flutter pub get
flutter run
```

### 테스트 / 정적 분석

```bash
flutter analyze
flutter test
```

## 프로젝트 구조

```
lib/
  models/       # Article, NewsSource 데이터 모델
  services/     # RSS 파싱(RssService), 번역(TranslationService)
  screens/      # HomeScreen(탭 컨테이너), NewsFeedView(피드 목록 화면)
  utils/        # 상대 시간 표시 등 유틸리티
assets/
  icon/         # 앱 아이콘 원본
  fonts/        # ClipartKorea 폰트 파일
```

## 라이선스

이 프로젝트는 [MIT License](LICENSE)를 따릅니다.
