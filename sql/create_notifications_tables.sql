-- 알림 테이블 생성
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'info', -- info, warning, success, error
    target_user VARCHAR(100), -- NULL이면 전체 사용자 대상
    is_read BOOLEAN NOT NULL DEFAULT false,
    related_type VARCHAR(50), -- schedule, result, candidate, user, system
    related_id INTEGER, -- 관련 객체 ID
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP
);

-- 활동 히스토리 테이블 생성
CREATE TABLE IF NOT EXISTS activity_history (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL, -- login, logout, create, update, delete, view
    target_type VARCHAR(50), -- candidate, schedule, result, question, etc.
    target_id INTEGER, -- 대상 객체 ID
    target_name VARCHAR(255), -- 대상 객체의 이름이나 제목
    description TEXT, -- 상세 설명
    ip_address VARCHAR(45), -- IPv4, IPv6 지원
    user_agent TEXT, -- 브라우저 정보
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 인덱스 생성 (성능 향상을 위해)
CREATE INDEX IF NOT EXISTS idx_notifications_target_user ON notifications(target_user);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_activity_history_username ON activity_history(username);
CREATE INDEX IF NOT EXISTS idx_activity_history_created_at ON activity_history(created_at);
CREATE INDEX IF NOT EXISTS idx_activity_history_action ON activity_history(action);

-- 샘플 데이터 삽입
INSERT INTO notifications (title, content, type, target_user, related_type) VALUES
('시스템 공지', '채용 관리 시스템이 새롭게 업데이트되었습니다.', 'info', NULL, 'system'),
('면접 일정 알림', '내일 오후 2시에 면접이 예정되어 있습니다.', 'warning', 'admin', 'schedule'),
('평가 완료', '김철수 지원자의 면접 평가가 완료되었습니다.', 'success', 'admin', 'result');

INSERT INTO activity_history (username, action, target_type, target_id, target_name, description) VALUES
('admin', 'login', 'user', NULL, 'admin', '관리자 로그인'),
('admin', 'create', 'candidate', 1, '김철수', '새 지원자 등록'),
('admin', 'update', 'schedule', 1, '면접 일정 변경', '면접 시간을 오후 3시로 변경'),
('admin', 'view', 'statistics', NULL, '통계 조회', '통계 페이지 조회');

-- 알림 정리를 위한 함수 (선택사항)
CREATE OR REPLACE FUNCTION cleanup_old_notifications()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM notifications 
    WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '30 days';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- 활동 히스토리 정리를 위한 함수 (선택사항)
CREATE OR REPLACE FUNCTION cleanup_old_activities()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM activity_history 
    WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '90 days';
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql; 