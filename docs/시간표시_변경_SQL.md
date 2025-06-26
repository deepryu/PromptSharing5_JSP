# 등록일 시간 표시 변경 관련 SQL 및 변경사항

## 개요
지원자 목록에서 등록일(created_at)과 수정일(updated_at)을 전체 날짜+시간이 아닌 **시간만(HH:mm:ss)** 표시하도록 변경했습니다.

---

## 변경된 파일들

### 1. Java 모델 클래스
- **파일**: `src/com/example/model/Candidate.java`
- **변경사항**: 
  - `SimpleDateFormat` import 추가
  - `getCreatedAtTimeOnly()` 메소드 추가 (시간만 반환)
  - `getUpdatedAtTimeOnly()` 메소드 추가 (시간만 반환)

### 2. JSP 화면
- **파일**: `candidates.jsp`
  - 테이블 헤더: "등록일" → "등록시간"
  - 데이터 표시: `c.getCreatedAt()` → `c.getCreatedAtTimeOnly()`

- **파일**: `candidate_detail.jsp`
  - 라벨: "등록일" → "등록시간", "수정일" → "수정시간"
  - 데이터 표시: 각각 시간만 표시하는 메소드로 변경

---

## 데이터베이스 관련 SQL 문

### 1. 현재 테이블 구조 확인
```sql
-- candidates 테이블 구조 확인
\d candidates;

-- 또는
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'candidates';
```

### 2. 현재 데이터 확인 (변경 전후 비교용)
```sql
-- 전체 날짜+시간 형식으로 조회
SELECT id, name, email, created_at, updated_at 
FROM candidates 
ORDER BY created_at DESC;

-- 시간만 추출하여 조회 (PostgreSQL)
SELECT id, name, email, 
       TO_CHAR(created_at, 'HH24:MI:SS') as created_time,
       TO_CHAR(updated_at, 'HH24:MI:SS') as updated_time
FROM candidates 
ORDER BY created_at DESC;
```

### 3. 테이블 스키마 변경 (필요한 경우)

#### 옵션 1: 기존 컬럼 유지 (권장)
```sql
-- 기존 TIMESTAMP 컬럼을 그대로 유지하고 애플리케이션에서 포맷팅
-- 이미 적용된 방식으로, 추가 SQL 변경 불필요
```

#### 옵션 2: 시간 전용 컬럼 추가 (필요시)
```sql
-- 시간만 저장하는 별도 컬럼 추가
ALTER TABLE candidates 
ADD COLUMN created_time TIME,
ADD COLUMN updated_time TIME;

-- 기존 데이터에서 시간 추출하여 새 컬럼에 저장
UPDATE candidates 
SET created_time = created_at::TIME,
    updated_time = updated_at::TIME;
```

#### 옵션 3: 컬럼 타입 변경 (주의 필요)
```sql
-- ⚠️ 주의: 기존 데이터 백업 후 실행 권장
-- 날짜 정보가 손실될 수 있음

-- 백업 테이블 생성
CREATE TABLE candidates_backup AS SELECT * FROM candidates;

-- 컬럼 타입을 TIME으로 변경
ALTER TABLE candidates 
ALTER COLUMN created_at TYPE TIME USING created_at::TIME,
ALTER COLUMN updated_at TYPE TIME USING updated_at::TIME;
```

### 4. 데이터 삽입/수정 시 시간 처리
```sql
-- 새로운 지원자 등록 (기존 방식 유지)
INSERT INTO candidates (name, email, phone, resume) 
VALUES ('테스트', 'test@example.com', '010-1234-5678', '테스트 이력서');

-- 수정 시 updated_at을 현재 시간으로 업데이트 (기존 방식 유지)
UPDATE candidates 
SET name = '수정된 이름', updated_at = CURRENT_TIMESTAMP 
WHERE id = 1;
```

### 5. 시간 관련 쿼리 예제
```sql
-- 특정 시간대에 등록된 지원자 조회
SELECT * FROM candidates 
WHERE EXTRACT(HOUR FROM created_at) BETWEEN 9 AND 17;

-- 오늘 등록된 지원자의 시간만 조회
SELECT name, TO_CHAR(created_at, 'HH24:MI:SS') as registration_time
FROM candidates 
WHERE DATE(created_at) = CURRENT_DATE
ORDER BY created_at;

-- 최근 등록 순으로 시간과 함께 조회
SELECT name, email, 
       TO_CHAR(created_at, 'YYYY-MM-DD') as date,
       TO_CHAR(created_at, 'HH24:MI:SS') as time
FROM candidates 
ORDER BY created_at DESC;
```

### 6. 지원팀 컬럼 추가
```sql
-- candidates 테이블에 team 컬럼 추가
ALTER TABLE candidates ADD COLUMN team VARCHAR(50);

-- 기존 데이터에 기본값 설정 (선택사항)
UPDATE candidates SET team = '미지정' WHERE team IS NULL;

-- team 컬럼에 NOT NULL 제약조건 추가 (선택사항)
-- ALTER TABLE candidates ALTER COLUMN team SET NOT NULL;
```

### 7. 지원팀 종류
- 개발팀
- 기획팀
- 디자인팀
- 마케팅팀
- 영업팀
- 인사팀
- 재무팀

### 8. 코드 변경 완료
1. **Candidate.java**: team 필드 및 getter/setter 추가
2. **CandidateDAO.java**: 모든 SQL 쿼리에 team 필드 추가
3. **CandidateServlet.java**: team 파라미터 처리 추가
4. **candidates.jsp**: 지원팀 컬럼 추가 (이름 앞)
5. **candidate_form.jsp**: 지원팀 선택 드롭다운 추가
6. **candidate_detail.jsp**: 지원팀 정보 표시 추가

### 9. 컴파일 및 배포
```bash
# 컴파일
javac -cp ".;WEB-INF/lib/*;C:/tomcat9/lib/servlet-api.jar" -d WEB-INF/classes src/com/example/*/*.java

# Tomcat 재시작
taskkill /f /im java.exe
C:\tomcat9\bin\startup.bat
```

### 10. 테스트 체크리스트
- [ ] 데이터베이스에 team 컬럼 추가 확인
- [ ] 지원자 목록에서 지원팀 컬럼 표시 확인
- [ ] 신규 지원자 등록 시 지원팀 선택 기능 확인
- [ ] 기존 지원자 수정 시 지원팀 변경 기능 확인
- [ ] 지원자 상세보기에서 지원팀 정보 표시 확인
- [ ] 기존 데이터(team이 NULL인 경우) "-" 표시 확인

### 11. 주의사항
- 데이터베이스 스키마 변경 후 반드시 컴파일 및 Tomcat 재시작 필요
- 기존 데이터의 team 필드는 NULL 상태이므로 "-"로 표시됨
- 필요시 기존 데이터에 기본 지원팀 값 할당 가능

---

## 테스트 확인 사항

### 1. 화면 표시 테스트
- [ ] 지원자 목록에서 "등록시간"이 HH:mm:ss 형식으로 표시되는지 확인
- [ ] 지원자 상세보기에서 "등록시간", "수정시간"이 올바르게 표시되는지 확인
- [ ] null 값 처리가 정상적으로 되는지 확인 (빈 문자열 반환)

### 2. 데이터 무결성 테스트
- [ ] 새로운 지원자 등록 시 created_at이 정상적으로 저장되는지 확인
- [ ] 지원자 정보 수정 시 updated_at이 갱신되는지 확인
- [ ] 기존 데이터의 시간 표시가 올바른지 확인

### 3. 성능 테스트
- [ ] SimpleDateFormat 객체 생성이 성능에 미치는 영향 확인
- [ ] 대량 데이터 조회 시 시간 포맷팅 성능 확인

---

## 참고사항

### 장점
- 화면이 더 깔끔해지고 가독성 향상
- 시간 정보에 집중할 수 있음
- 기존 데이터베이스 스키마 변경 불필요

### 고려사항
- 날짜 정보가 화면에서 보이지 않음 (필요시 툴팁이나 상세보기에서 확인 가능)
- SimpleDateFormat은 thread-safe하지 않으므로 멀티스레드 환경에서 주의 필요
- 필요시 java.time.LocalTime 사용 고려

### 추후 개선 가능사항
- java.time.format.DateTimeFormatter 사용으로 성능 및 안전성 향상
- 사용자 설정에 따른 시간 형식 변경 기능
- 날짜와 시간을 선택적으로 표시하는 옵션 제공 

# 데이터베이스 스키마 변경 SQL

## 1. 시간 표시 형식 변경
지원자 목록에서 등록일/수정일을 전체 날짜+시간에서 시간만(HH:mm:ss) 표시로 변경

### 현재 상태
- 데이터베이스: PostgreSQL의 TIMESTAMP 타입으로 저장
- 표시 형식: Java SimpleDateFormat으로 "HH:mm:ss" 형식 변환
- 변경 완료: Candidate.java에 getCreatedAtTimeOnly(), getUpdatedAtTimeOnly() 메소드 추가

## 2. 지원팀 컬럼 추가
지원자 목록에서 이름 앞에 "지원팀" 컬럼 추가

### 데이터베이스 스키마 변경
```sql
-- candidates 테이블에 team 컬럼 추가
ALTER TABLE candidates ADD COLUMN team VARCHAR(50);

-- 기존 데이터에 기본값 설정 (선택사항)
UPDATE candidates SET team = '미지정' WHERE team IS NULL;

-- team 컬럼에 NOT NULL 제약조건 추가 (선택사항)
-- ALTER TABLE candidates ALTER COLUMN team SET NOT NULL;
```

### 지원팀 종류
- 개발팀
- 기획팀
- 디자인팀
- 마케팅팀
- 영업팀
- 인사팀
- 재무팀

### 코드 변경 완료
1. **Candidate.java**: team 필드 및 getter/setter 추가
2. **CandidateDAO.java**: 모든 SQL 쿼리에 team 필드 추가
3. **CandidateServlet.java**: team 파라미터 처리 추가
4. **candidates.jsp**: 지원팀 컬럼 추가 (이름 앞)
5. **candidate_form.jsp**: 지원팀 선택 드롭다운 추가
6. **candidate_detail.jsp**: 지원팀 정보 표시 추가

## 3. 인터뷰 일정 관리 시스템 (2025-06-25 추가)

### 3.1 interview_schedules 테이블 생성
```sql
-- 인터뷰 일정 관리 테이블
CREATE TABLE interview_schedules (
    id SERIAL PRIMARY KEY,
    candidate_id INTEGER NOT NULL,
    interviewer_name VARCHAR(100) NOT NULL,
    interview_date DATE NOT NULL,
    interview_time TIME NOT NULL,
    duration INTEGER DEFAULT 60, -- 면접 시간(분)
    location VARCHAR(200),
    interview_type VARCHAR(50) DEFAULT '기술면접', -- 면접 유형
    status VARCHAR(20) DEFAULT '예정', -- 예정, 진행중, 완료, 취소
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (candidate_id) REFERENCES candidates(id) ON DELETE CASCADE
);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX idx_interview_schedules_candidate_id ON interview_schedules(candidate_id);
CREATE INDEX idx_interview_schedules_date ON interview_schedules(interview_date);
CREATE INDEX idx_interview_schedules_status ON interview_schedules(status);
```

### 3.2 면접 유형 및 상태 정의
**면접 유형**:
- 기술면접
- 인성면접
- 임원면접
- 화상면접
- 전화면접

**면접 상태**:
- 예정 (scheduled)
- 진행중 (in_progress)
- 완료 (completed)
- 취소 (cancelled)
- 연기 (postponed)

### 3.3 테스트 데이터 삽입
```sql
-- 테스트용 인터뷰 일정 데이터
INSERT INTO interview_schedules (candidate_id, interviewer_name, interview_date, interview_time, duration, location, interview_type, status, notes) VALUES
(1, '김팀장', '2025-06-26', '14:00:00', 60, '회의실 A', '기술면접', '예정', '1차 기술면접'),
(2, '박부장', '2025-06-26', '15:30:00', 90, '회의실 B', '인성면접', '예정', '2차 인성면접'),
(3, '이대리', '2025-06-27', '10:00:00', 45, '화상회의', '화상면접', '예정', '원격 면접'),
(1, '최이사', '2025-06-28', '16:00:00', 30, '임원실', '임원면접', '예정', '최종 면접');
```

### 컴파일 및 배포
```bash
# 컴파일
javac -cp ".;WEB-INF/lib/*;C:/tomcat9/lib/servlet-api.jar" -d WEB-INF/classes src/com/example/*/*.java

# Tomcat 재시작
taskkill /f /im java.exe
C:\tomcat9\bin\startup.bat
```

### 테스트 체크리스트
- [ ] 데이터베이스에 interview_schedules 테이블 생성 확인
- [ ] 인터뷰 일정 등록 기능 확인
- [ ] 인터뷰 일정 수정/삭제 기능 확인
- [ ] 지원자별 일정 연결 기능 확인
- [ ] 캘린더 보기 기능 확인
- [ ] 리스트 보기 기능 확인
- [ ] 일정 상태 관리 기능 확인

### 주의사항
- 데이터베이스 스키마 변경 후 반드시 컴파일 및 Tomcat 재시작 필요
- 외래키 제약조건으로 인해 지원자 삭제 시 관련 일정도 함께 삭제됨
- 날짜/시간 검증 로직 필수 (과거 날짜 방지, 시간 중복 체크 등)

---

### 기존 내용들...

### 6. 지원팀 컬럼 추가
```sql
-- candidates 테이블에 team 컬럼 추가
ALTER TABLE candidates ADD COLUMN team VARCHAR(50);

-- 기존 데이터에 기본값 설정 (선택사항)
UPDATE candidates SET team = '미지정' WHERE team IS NULL;

-- team 컬럼에 NOT NULL 제약조건 추가 (선택사항)
-- ALTER TABLE candidates ALTER COLUMN team SET NOT NULL;
```

### 7. 지원팀 종류
- 개발팀
- 기획팀
- 디자인팀
- 마케팅팀
- 영업팀
- 인사팀
- 재무팀

### 8. 코드 변경 완료
1. **Candidate.java**: team 필드 및 getter/setter 추가
2. **CandidateDAO.java**: 모든 SQL 쿼리에 team 필드 추가
3. **CandidateServlet.java**: team 파라미터 처리 추가
4. **candidates.jsp**: 지원팀 컬럼 추가 (이름 앞)
5. **candidate_form.jsp**: 지원팀 선택 드롭다운 추가
6. **candidate_detail.jsp**: 지원팀 정보 표시 추가

### 9. 컴파일 및 배포
```bash
# 컴파일
javac -cp ".;WEB-INF/lib/*;C:/tomcat9/lib/servlet-api.jar" -d WEB-INF/classes src/com/example/*/*.java

# Tomcat 재시작
taskkill /f /im java.exe
C:\tomcat9\bin\startup.bat
```

### 10. 테스트 체크리스트
- [ ] 데이터베이스에 team 컬럼 추가 확인
- [ ] 지원자 목록에서 지원팀 컬럼 표시 확인
- [ ] 신규 지원자 등록 시 지원팀 선택 기능 확인
- [ ] 기존 지원자 수정 시 지원팀 변경 기능 확인
- [ ] 지원자 상세보기에서 지원팀 정보 표시 확인
- [ ] 기존 데이터(team이 NULL인 경우) "-" 표시 확인

### 11. 주의사항
- 데이터베이스 스키마 변경 후 반드시 컴파일 및 Tomcat 재시작 필요
- 기존 데이터의 team 필드는 NULL 상태이므로 "-"로 표시됨
- 필요시 기존 데이터에 기본 지원팀 값 할당 가능

--- 