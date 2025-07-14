# 파비콘(Favicon) 설정 가이드

## 📋 개요
브라우저 탭 상단에 표시되는 톰캣 고양이 이미지를 회사 로고로 변경하는 방법을 안내합니다.

## 🔧 설정 완료된 파일들
다음 JSP 파일들에 파비콘 설정이 추가되었습니다:
- `main.jsp` - 메인 대시보드
- `candidates.jsp` - 인터뷰 대상자 관리
- `login.jsp` - 로그인 페이지
- `register.jsp` - 회원가입 페이지

## 📁 필요한 파일들

### 1. 루트 디렉토리
```
/PromptSharing5_JSP/favicon.ico
```
- 크기: 16x16, 32x32, 48x48 픽셀 (멀티사이즈)
- 형식: ICO 파일
- 용도: 기본 파비콘

### 2. images 디렉토리
```
/PromptSharing5_JSP/images/
├── favicon-16x16.png    (16x16 픽셀 PNG)
├── favicon-32x32.png    (32x32 픽셀 PNG)
└── apple-touch-icon.png (180x180 픽셀 PNG)
```

## 🎨 파비콘 파일 생성 방법

### 방법 1: 온라인 파비콘 생성기 사용 (권장)
1. **favicon.io** (https://favicon.io/) 접속
2. 회사 로고 이미지 업로드 (PNG, JPG 지원)
3. 자동으로 모든 크기의 파비콘 생성
4. 다운로드한 파일들을 해당 디렉토리에 복사

### 방법 2: RealFaviconGenerator 사용
1. **realfavicongenerator.net** 접속
2. 회사 로고 업로드
3. 각 플랫폼별 설정 조정
4. 생성된 파일들 다운로드 및 설치

### 방법 3: 이미지 편집 프로그램 사용
1. **포토샵, 김프, 페인트닷넷** 등 사용
2. 회사 로고를 다음 크기로 리사이즈:
   - 16x16 픽셀
   - 32x32 픽셀
   - 48x48 픽셀
   - 180x180 픽셀 (Apple 터치 아이콘)
3. 각각 PNG/ICO 형식으로 저장

## 📋 설치 방법

### 1단계: 파일 준비
회사 로고를 위의 방법으로 파비콘 파일들로 변환합니다.

### 2단계: 파일 배치
```bash
# 프로젝트 루트에 favicon.ico 복사
copy favicon.ico C:\tomcat9\webapps\PromptSharing5_JSP\

# images 디렉토리에 PNG 파일들 복사
copy favicon-16x16.png C:\tomcat9\webapps\PromptSharing5_JSP\images\
copy favicon-32x32.png C:\tomcat9\webapps\PromptSharing5_JSP\images\
copy apple-touch-icon.png C:\tomcat9\webapps\PromptSharing5_JSP\images\
```

### 3단계: 브라우저 캐시 삭제
파비콘은 브라우저에서 강력하게 캐시되므로:
1. **Ctrl + F5** (강력 새로고침)
2. **개발자 도구** → **Application** → **Storage** → **Clear storage**
3. **브라우저 재시작**

## 🔍 설정된 HTML 태그
각 JSP 파일의 `<head>` 태그에 다음이 추가되었습니다:

```html
<!-- 파비콘 설정 -->
<link rel="icon" type="image/x-icon" href="${pageContext.request.contextPath}/favicon.ico">
<link rel="icon" type="image/png" sizes="32x32" href="${pageContext.request.contextPath}/images/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="16x16" href="${pageContext.request.contextPath}/images/favicon-16x16.png">
<link rel="apple-touch-icon" sizes="180x180" href="${pageContext.request.contextPath}/images/apple-touch-icon.png">
```

## 📱 지원 플랫폼
- **데스크톱 브라우저**: Chrome, Firefox, Safari, Edge
- **모바일 브라우저**: Chrome Mobile, Safari Mobile
- **iOS**: Apple Touch Icon 지원
- **Android**: Chrome Mobile Favicon 지원

## ⚠️ 주의사항
1. **파일 크기**: 파비콘 파일은 가능한 작게 유지 (ICO: ~10KB, PNG: ~5KB)
2. **정사각형**: 로고가 정사각형이 아닌 경우 배경을 추가하여 정사각형으로 만들기
3. **단순함**: 16x16 픽셀에서도 인식 가능한 단순한 디자인 권장
4. **브랜딩**: 회사 브랜드 가이드라인에 맞는 색상과 형태 사용

## 🔄 업데이트 방법
새로운 회사 로고로 변경하려면:
1. 기존 파비콘 파일들 삭제
2. 새로운 로고로 파비콘 파일들 재생성
3. 동일한 경로에 새 파일들 복사
4. 브라우저 캐시 삭제

## 📞 문의
파비콘 설정에 문제가 있을 경우:
1. 파일 경로 확인
2. 파일 권한 확인
3. 브라우저 캐시 삭제 재시도
4. Tomcat 재시작

---
**최종 업데이트**: 2025-07-12
**작성자**: AI Assistant 