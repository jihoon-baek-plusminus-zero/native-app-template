# 웹뷰 앱 빌드 및 설치 가이드

> Xcode 프로젝트를 빌드해서 내 Mac에 앱으로 설치하는 방법

## 📋 목차

1. [Config.swift 설정하기](#1-configswift-설정하기)
2. [Xcode에서 빌드하기](#2-xcode에서-빌드하기)
3. [앱 파일 찾기](#3-앱-파일-찾기)
4. [Applications 폴더에 설치하기](#4-applications-폴더에-설치하기)
5. [앱 실행하기](#5-앱-실행하기)
6. [문제 해결](#6-문제-해결)

---

## 1. Config.swift 설정하기

### 1-1. Xcode에서 프로젝트 열기
```bash
# 프로젝트 폴더로 이동
cd "Native app template"

# Xcode 프로젝트 열기 (더블클릭 또는 터미널에서)
open "Native app template.xcodeproj"
```

### 1-2. Config.swift 파일 열기
- 왼쪽 네비게이터에서 `Native app template` 폴더 확장
- `Config.swift` 파일 클릭

### 1-3. 변수 수정하기
```swift
struct AppConfig {
    /// 앱 이름
    static let appName = "내 앱 이름"  // 원하는 앱 이름으로 변경
    
    /// 감쌀 웹사이트 URL
    static let targetURL = "https://example.com"  // 원하는 URL로 변경
    
    // MARK: - 타이틀바 커스터마이징
    /// 타이틀바 색상 (Hex 코드)
    static let titlebar_color = "#4285F4"  // 원하는 색상으로 변경
    
    /// 타이틀바 제목
    static let titlebar_title = "내 앱"  // 원하는 제목으로 변경
    
    /// 타이틀바 높이 (px 단위)
    static let titlebar_height = "40px"  // 원하는 높이로 변경
}
```

**예시 - Gmail 앱 만들기:**
```swift
static let appName = "Gmail"
static let targetURL = "https://mail.google.com"
static let titlebar_color = "#EA4335"  // Gmail 레드
static let titlebar_title = "Gmail"
static let titlebar_height = "35px"
```

### 1-4. 저장하기
- `Command + S` 로 저장

---

## 2. Xcode에서 빌드하기

### 2-1. 빌드 설정 확인
1. 상단 메뉴: `Product` → `Scheme` → `Native app template` 선택됨 확인
2. 상단 툴바: 디바이스 선택 드롭다운에서 `My Mac` 선택

### 2-2. 빌드 실행
**방법 1: 단축키 사용 (추천)**
```
Command + B
```

**방법 2: 메뉴 사용**
```
Product → Build
```

### 2-3. 빌드 완료 대기
- 상단 중앙에 빌드 진행 상황 표시
- "Build Succeeded" 메시지 확인 (보통 10-30초 소요)
- 하단 로그에서 빌드 결과 확인 가능

### 2-4. 빌드 실패 시
- 하단 이슈 네비게이터(⚠️ 아이콘) 클릭하여 오류 확인
- 대부분 Config.swift의 오타나 문법 오류
- 오류 수정 후 다시 `Command + B`

---

## 3. 앱 파일 찾기

### 3-1. Xcode에서 앱 파일 찾기

**방법 1: Products 폴더에서 찾기 (가장 쉬움)**
1. 왼쪽 네비게이터에서 `Products` 폴더 확장
2. `Native app template.app` 파일 찾기 (앱 아이콘 모양)
3. 파일을 **오른쪽 클릭** → `Show in Finder` 선택

**방법 2: 터미널에서 찾기**
```bash
# DerivedData 폴더로 이동
cd ~/Library/Developer/Xcode/DerivedData

# 최근 빌드된 앱 찾기
find . -name "Native app template.app" -type d | grep "Build/Products/Debug"

# 결과 예시:
# ./Native_app_template-xxxxx/Build/Products/Debug/Native app template.app
```

### 3-2. 앱 파일 위치
빌드된 앱은 다음 위치에 생성됩니다:
```
~/Library/Developer/Xcode/DerivedData/
  └── Native_app_template-[고유ID]/
      └── Build/
          └── Products/
              └── Debug/
                  └── Native app template.app  ← 여기!
```

---

## 4. Applications 폴더에 설치하기

### 4-1. 앱 파일 복사하기

**방법 1: Finder에서 드래그 (가장 쉬움)**
1. 3-1에서 `Show in Finder`로 연 Finder 창
2. `Native app template.app` 파일을 선택
3. **Option 키를 누른 채로** `/Applications` 폴더로 드래그
   - Option 키: 복사 (누르지 않으면 이동)
   - `/Applications` 폴더는 Finder → `이동` → `응용 프로그램` (Command + Shift + A)

**방법 2: 터미널에서 복사**
```bash
# 앱 파일 복사
cp -R ~/Library/Developer/Xcode/DerivedData/Native_app_template-*/Build/Products/Debug/"Native app template.app" /Applications/

# 기존 앱이 있으면 덮어쓰기
rm -rf "/Applications/Native app template.app"
cp -R ~/Library/Developer/Xcode/DerivedData/Native_app_template-*/Build/Products/Debug/"Native app template.app" /Applications/
```

### 4-2. 앱 이름 변경 (선택 사항)
1. `/Applications` 폴더에서 `Native app template.app` 파일 선택
2. `Enter` 키 또는 오른쪽 클릭 → `이름 변경`
3. 원하는 이름으로 변경 (예: `Gmail.app`, `Notion.app`)

---

## 5. 앱 실행하기

### 5-1. 첫 실행

**방법 1: Finder에서 실행**
1. `/Applications` 폴더 열기 (Command + Shift + A)
2. 앱 아이콘 더블클릭

**방법 2: Spotlight에서 실행**
1. `Command + Space` (Spotlight 열기)
2. 앱 이름 입력 (예: "Native app template" 또는 변경한 이름)
3. `Enter` 키로 실행

**방법 3: Launchpad에서 실행**
1. F4 (또는 트랙패드 4손가락 모으기)
2. 앱 아이콘 찾아서 클릭

### 5-2. 보안 경고 처리

**"개발자를 확인할 수 없음" 경고가 뜨는 경우:**

1. `확인` 클릭 (앱 닫힘)
2. `시스템 설정` → `개인정보 보호 및 보안` 열기
3. 하단 `보안` 섹션에서 다음 메시지 확인:
   ```
   "Native app template.app"이(가) 차단되었습니다.
   ```
4. `확인 없이 열기` 버튼 클릭
5. 확인 대화상자에서 `열기` 클릭

**또는 오른쪽 클릭 방법:**
1. 앱 아이콘을 **오른쪽 클릭** (또는 Control + 클릭)
2. `열기` 선택
3. 경고 대화상자에서 `열기` 클릭

> ⚠️ **참고**: 이 보안 경고는 앱 서명이 없어서 나타나는 것으로, 
> 자신이 직접 빌드한 앱이므로 안전합니다. 
> 한 번 허용하면 다음부터는 경고 없이 실행됩니다.

### 5-3. 정상 실행 확인
- 앱 창이 열리고 설정한 웹사이트가 로드됨
- 상단에 커스텀 타이틀바 (설정한 색상/제목) 표시
- 웹사이트가 정상적으로 작동

---

## 6. 문제 해결

### 문제 1: "빌드 실패" 오류

**원인:**
- Config.swift에 문법 오류
- URL 형식 오류

**해결:**
1. Xcode 하단 이슈 네비게이터(⚠️) 확인
2. 오류 메시지 확인하고 수정
3. 다시 `Command + B`로 빌드

**흔한 오류:**
```swift
// ❌ 잘못된 예
static let targetURL = https://google.com  // 따옴표 없음

// ✅ 올바른 예
static let targetURL = "https://google.com"
```

---

### 문제 2: 앱이 실행되지 않음

**증상:**
- 앱 아이콘을 클릭해도 아무 반응이 없음
- 앱이 바로 종료됨

**해결:**
1. Xcode에서 직접 실행해보기
   ```
   Command + R (Run)
   ```
2. Xcode 콘솔에서 오류 메시지 확인
3. Config.swift의 `targetURL`이 올바른지 확인
   - `https://` 포함 여부 확인
   - URL이 실제로 접근 가능한지 확인

---

### 문제 3: "로딩 중..." 화면에서 멈춤

**원인:**
- URL이 잘못되었거나 접근 불가능
- 네트워크 연결 문제

**해결:**
1. Config.swift의 `targetURL` 확인
   ```swift
   // ✅ https:// 포함 필수
   static let targetURL = "https://www.google.com"
   ```
2. 브라우저에서 해당 URL이 정상 작동하는지 확인
3. 네트워크 연결 확인

---

### 문제 4: 웹사이트가 모바일 버전으로 표시됨

**원인:**
- User Agent 설정 문제 (거의 발생하지 않음)

**해결:**
- ContentView.swift의 Safari User Agent 설정이 올바른지 확인
- 대부분의 경우 이미 올바르게 설정되어 있음

---

### 문제 5: 앱 업데이트 후 변경사항이 반영 안됨

**원인:**
- 이전 버전이 메모리에 캐시됨
- Applications 폴더의 앱이 업데이트되지 않음

**해결:**
1. 실행 중인 앱 완전 종료
   ```
   Command + Q (앱 종료)
   ```
2. Applications 폴더의 기존 앱 삭제
   ```bash
   rm -rf "/Applications/Native app template.app"
   ```
3. 새로 빌드한 앱을 다시 복사

---

### 문제 6: 쿠키/로그인 정보가 저장 안됨

**원인:**
- entitlements 설정 문제 (거의 발생하지 않음)

**해결:**
1. `Native_app_template.entitlements` 파일 확인
2. 다음 권한이 있는지 확인:
   ```xml
   <key>com.apple.security.network.client</key>
   <true/>
   ```
3. 이미 올바르게 설정되어 있으면 웹사이트 자체의 문제일 수 있음

---

## 🎯 빠른 참조 가이드

### 새 앱 만들기 (5단계)

```
1. Config.swift 수정
   ↓
2. Command + B (빌드)
   ↓
3. Products → 오른쪽 클릭 → Show in Finder
   ↓
4. Option 키 + 드래그 → /Applications
   ↓
5. 앱 실행
```

### 자주 쓰는 단축키

| 단축키 | 기능 |
|--------|------|
| `Command + B` | 빌드 |
| `Command + R` | 실행 (테스트용) |
| `Command + Q` | 앱 종료 |
| `Command + Shift + A` | Applications 폴더 열기 |
| `Command + Space` | Spotlight 검색 |

---

## 📦 여러 앱 동시에 관리하기

### 시나리오: Gmail, Notion, Discord 앱 모두 만들기

1. **첫 번째 앱 (Gmail)**
   ```swift
   // Config.swift
   static let appName = "Gmail"
   static let targetURL = "https://mail.google.com"
   static let titlebar_color = "#EA4335"
   ```
   - 빌드 (`Command + B`)
   - `/Applications/Gmail.app`으로 복사 및 이름 변경

2. **두 번째 앱 (Notion)**
   ```swift
   // Config.swift (수정)
   static let appName = "Notion"
   static let targetURL = "https://notion.so"
   static let titlebar_color = "#000000"
   ```
   - 빌드 (`Command + B`)
   - `/Applications/Notion.app`으로 복사 및 이름 변경

3. **세 번째 앱 (Discord)**
   ```swift
   // Config.swift (수정)
   static let appName = "Discord"
   static let targetURL = "https://discord.com/app"
   static let titlebar_color = "#5865F2"
   ```
   - 빌드 (`Command + B`)
   - `/Applications/Discord.app`으로 복사 및 이름 변경

### 팁
- 각 앱마다 다른 이름으로 저장하면 충돌 없음
- 원본 프로젝트는 그대로 두고 Config.swift만 계속 수정
- 빌드된 .app 파일은 독립적으로 작동

---

## 🚀 고급: 자동화 스크립트

### 빌드 자동화 (선택 사항)

**build.sh 스크립트 생성:**
```bash
#!/bin/bash

# 프로젝트 이름
PROJECT_NAME="Native app template"

# 빌드
echo "🔨 빌드 중..."
xcodebuild -project "$PROJECT_NAME.xcodeproj" \
           -scheme "$PROJECT_NAME" \
           -configuration Debug \
           clean build

# 앱 파일 찾기
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "$PROJECT_NAME.app" | grep "Debug" | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ 빌드 실패: 앱 파일을 찾을 수 없습니다"
    exit 1
fi

# Applications 폴더로 복사
echo "📦 /Applications로 복사 중..."
rm -rf "/Applications/$PROJECT_NAME.app"
cp -R "$APP_PATH" /Applications/

echo "✅ 완료!"
echo "📍 위치: /Applications/$PROJECT_NAME.app"
```

**사용 방법:**
```bash
# 실행 권한 부여
chmod +x build.sh

# 스크립트 실행
./build.sh
```

---

## ✅ 체크리스트

### 빌드 전
- [ ] Config.swift에서 `appName` 수정
- [ ] Config.swift에서 `targetURL` 수정 (https:// 포함)
- [ ] Config.swift에서 `titlebar_color` 수정 (# 포함)
- [ ] Config.swift에서 `titlebar_title` 수정
- [ ] Config.swift 저장 (`Command + S`)

### 빌드 중
- [ ] Xcode에서 `My Mac` 타겟 선택 확인
- [ ] `Command + B`로 빌드
- [ ] "Build Succeeded" 메시지 확인

### 설치 후
- [ ] `/Applications` 폴더에 .app 파일 확인
- [ ] 앱 아이콘 더블클릭하여 실행
- [ ] 보안 경고 시 "확인 없이 열기" 허용
- [ ] 웹사이트 정상 로딩 확인
- [ ] 커스텀 타이틀바 색상/제목 확인

---

## 🎉 완료!

이제 당신만의 웹뷰 네이티브 앱을 만들 수 있습니다!

**다른 웹사이트로 앱을 만들고 싶다면:**
1. Config.swift만 수정
2. 빌드 (`Command + B`)
3. Applications 폴더로 복사
4. 끝!

**질문이나 문제가 있다면:**
- [문제 해결](#6-문제-해결) 섹션 참고
- Xcode 콘솔 로그 확인
- Config.swift 설정 재확인

---

**즐거운 앱 개발 되세요!** 🚀

