# 🛡️ 데이터 보호 및 재발 방지 가이드

**생성일**: 2025-01-14  
**목적**: 프로덕션 데이터베이스 보호 및 테스트 환경 분리  
**상태**: ✅ 재발 방지 대책 완료

---

## 🚨 **문제 발생 이력**

### **문제 상황**
- **발생일**: 2025-01-14 (재발)
- **문제**: Maven 테스트 실행 시 프로덕션 DB 데이터 삭제
- **원인**: 테스트 파일들이 `DatabaseUtil` 사용 → 프로덕션 DB 연결
- **피해**: `candidates` 테이블 데이터 손실

### **근본 원인 분석**
1. **테스트 파일 문제**: `CandidateDAOTest`, `UserDAOTest`, `InterviewScheduleDAOTest`
2. **데이터베이스 미분리**: 테스트와 프로덕션이 동일한 DB 사용
3. **tearDown 메소드**: `DELETE FROM` 명령어로 데이터 삭제
4. **Maven 라이프사이클**: 컴파일 시 테스트 자동 실행

---

## ✅ **완료된 재발 방지 대책**

### **1. 테스트 전용 데이터베이스 분리**

#### **📄 DB 생성 스크립트**: `sql/create_test_database.sql`
```sql
-- promptsharing_test 데이터베이스 생성
-- 프로덕션 DB와 완전 분리된 테스트 환경
```

**실행 방법:**
```cmd
psql -h localhost -U postgres -f sql/create_test_database.sql
```

#### **🔧 테스트 DB 특징**
- **DB 이름**: `promptsharing_test`
- **포트**: 5432 (동일)
- **스키마**: 프로덕션과 동일한 구조
- **데이터**: 테스트용 샘플 데이터만

### **2. 모든 테스트 파일 수정 완료**

#### **수정된 파일들**: ✅
- `test/com/example/model/CandidateDAOTest.java`
- `test/com/example/model/UserDAOTest.java`
- `test/com/example/model/InterviewScheduleDAOTest.java`

#### **변경 내용**:
```java
// 변경 전 (위험)
import com.example.util.DatabaseUtil;
Connection conn = DatabaseUtil.getConnection();

// 변경 후 (안전)
import com.example.util.TestDatabaseUtil;
Connection conn = TestDatabaseUtil.getTestConnection();
```

### **3. 안전한 컴파일 스크립트 생성**

#### **🛡️ safe-compile.cmd** (데이터 보호 보장)
```cmd
.\scripts\safe-compile.cmd
```

**특징:**
- 테스트 실행 안함 (`-DskipTests`)
- UTF-8 인코딩 지원
- 프로덕션 DB 데이터 보호
- Tomcat 자동 관리

### **4. Maven 설정 업데이트**

#### **pom.xml 테스트 환경 설정 추가**:
```xml
<systemPropertyVariables>
    <test.database.name>promptsharing_test</test.database.name>
    <test.database.url>jdbc:postgresql://localhost:5432/promptsharing_test</test.database.url>
    <test.environment>true</test.environment>
</systemPropertyVariables>
```

---

## 🚀 **안전한 개발 절차**

### **일반 개발 시 (Java 파일 변경)**

#### **1. 안전한 컴파일** (권장)
```cmd
.\scripts\safe-compile.cmd
```
- ✅ 테스트 실행 안함
- ✅ 프로덕션 DB 안전
- ✅ 한글 깨짐 없음

#### **2. UTF-8 컴파일** (한글 문제 시)
```cmd
.\scripts\compile-maven-utf8.cmd
```
- ⚠️ 테스트 포함 (주의 필요)

### **JSP 파일만 변경 시**
- 컴파일 불필요
- 브라우저 새로고침만 필요

### **테스트 실행 시 (테스트 DB 설정 완료 후)**

#### **1. 테스트 DB 생성** (최초 1회)
```cmd
psql -h localhost -U postgres -f sql/create_test_database.sql
```

#### **2. 안전한 테스트 실행**
```cmd
.\scripts\test-maven-utf8.cmd
```

---

## ⚠️ **위험 명령어 목록**

### **절대 사용 금지** (프로덕션 DB 위험)
```cmd
❌ mvn test                    # 프로덕션 DB 연결 위험
❌ mvn compile                 # 테스트 포함 시 위험
❌ .\scripts\test-maven.cmd    # 검증 완료 전까지 금지
❌ .\scripts\maven-all.cmd     # 테스트 포함 위험
```

### **안전한 대안 명령어**
```cmd
✅ .\scripts\safe-compile.cmd      # 데이터 보호 보장
✅ mvn compile -DskipTests         # 수동 테스트 제외
✅ .\scripts\compile-maven-utf8.cmd # UTF-8 컴파일
```

---

## 🔍 **검증 체크리스트**

### **테스트 DB 설정 확인**
- [ ] `promptsharing_test` 데이터베이스 생성됨
- [ ] 테스트 계정 (`test_admin` / `admin123`) 로그인 가능
- [ ] 모든 테이블 구조 정상 생성됨

### **테스트 파일 수정 확인**
- [x] `CandidateDAOTest.java` → `TestDatabaseUtil` 사용
- [x] `UserDAOTest.java` → `TestDatabaseUtil` 사용
- [x] `InterviewScheduleDAOTest.java` → `TestDatabaseUtil` 사용

### **스크립트 정상 동작 확인**
- [x] `safe-compile.cmd` 생성 완료
- [x] UTF-8 인코딩 정상 작동
- [x] 테스트 제외 옵션 적용됨

---

## 📚 **관련 문서**

- **scripts/README.md**: 모든 스크립트 사용법
- **sql/emergency_data_recovery.sql**: 긴급 복구 스크립트
- **docs/ERROR_GUIDE.md**: 에러 해결 가이드
- **PROJECT_GUIDE.md**: 프로젝트 전체 가이드

---

## 🎯 **향후 개발 원칙**

1. **안전 우선**: 항상 `safe-compile.cmd` 사용
2. **환경 분리**: 테스트는 반드시 테스트 DB에서
3. **단계적 검증**: 변경 → 컴파일 → 테스트 → 배포
4. **백업 습관**: 중요 변경 전 백업 실행
5. **문서 준수**: 가이드라인 철저히 따르기

**최종 목표**: 프로덕션 데이터 보호 및 안전한 개발 환경 구축 ✅ 