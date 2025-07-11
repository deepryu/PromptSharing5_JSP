package com.example.controller;

import com.example.util.DatabaseUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;

/**
 * 데이터베이스 연결 테스트 및 테이블 생성 서블릿
 */
@WebServlet("/db-test")
public class DatabaseTestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html lang='ko'>");
        out.println("<head>");
        out.println("<meta charset='UTF-8'>");
        out.println("<title>데이터베이스 테스트</title>");
        out.println("<style>");
        out.println("body { font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5; }");
        out.println(".container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }");
        out.println(".success { color: #28a745; background: #d4edda; padding: 15px; border-radius: 5px; margin: 10px 0; }");
        out.println(".error { color: #dc3545; background: #f8d7da; padding: 15px; border-radius: 5px; margin: 10px 0; }");
        out.println(".info { color: #17a2b8; background: #d1ecf1; padding: 15px; border-radius: 5px; margin: 10px 0; }");
        out.println("pre { background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; }");
        out.println("</style>");
        out.println("</head>");
        out.println("<body>");
        out.println("<div class='container'>");
        out.println("<h1>🔍 데이터베이스 연결 테스트</h1>");
        
        // 데이터베이스 연결 테스트
        try (Connection conn = DatabaseUtil.getConnection()) {
            out.println("<div class='success'>✅ 데이터베이스 연결 성공!</div>");
            
            // 데이터베이스 정보 표시
            out.println("<div class='info'>");
            out.println("<h3>📊 데이터베이스 정보</h3>");
            out.println("<p><strong>URL:</strong> jdbc:postgresql://localhost:5432/promptsharing</p>");
            out.println("<p><strong>연결 상태:</strong> " + (!conn.isClosed() ? "활성" : "비활성") + "</p>");
            out.println("</div>");
            
            // 기존 테이블 확인
            out.println("<h3>📋 기존 테이블 확인</h3>");
            Statement stmt = conn.createStatement();
            
            try {
                ResultSet rs = stmt.executeQuery("SELECT tablename FROM pg_tables WHERE schemaname = 'public'");
                out.println("<div class='info'>");
                out.println("<h4>현재 존재하는 테이블:</h4>");
                out.println("<ul>");
                boolean hasQuestionTable = false;
                boolean hasCriteriaTable = false;
                
                while (rs.next()) {
                    String tableName = rs.getString("tablename");
                    out.println("<li>" + tableName + "</li>");
                    if ("interview_questions".equals(tableName)) hasQuestionTable = true;
                    if ("evaluation_criteria".equals(tableName)) hasCriteriaTable = true;
                }
                out.println("</ul>");
                out.println("</div>");
                
                // 필요한 테이블이 없으면 생성
                if (!hasQuestionTable || !hasCriteriaTable) {
                    out.println("<h3>🔧 테이블 생성</h3>");
                    
                    if (!hasQuestionTable) {
                        createInterviewQuestionsTable(stmt, out);
                    }
                    
                    if (!hasCriteriaTable) {
                        createEvaluationCriteriaTable(stmt, out);
                    }
                    
                    // 기본 데이터 삽입
                    insertSampleData(stmt, out);
                }
                
            } catch (Exception e) {
                out.println("<div class='error'>❌ 테이블 확인 중 오류: " + e.getMessage() + "</div>");
                e.printStackTrace();
            }
            
        } catch (Exception e) {
            out.println("<div class='error'>❌ 데이터베이스 연결 실패: " + e.getMessage() + "</div>");
            out.println("<div class='info'>");
            out.println("<h4>해결 방법:</h4>");
            out.println("<ul>");
            out.println("<li>PostgreSQL 서버가 실행 중인지 확인</li>");
            out.println("<li>데이터베이스 'promptsharing'이 존재하는지 확인</li>");
            out.println("<li>사용자 'postgres' 비밀번호가 '1234'인지 확인</li>");
            out.println("</ul>");
            out.println("</div>");
            e.printStackTrace();
        }
        
        out.println("<p><a href='test_questions.jsp'>← 테스트 페이지로 돌아가기</a></p>");
        out.println("</div>");
        out.println("</body>");
        out.println("</html>");
    }
    
    private void createInterviewQuestionsTable(Statement stmt, PrintWriter out) {
        try {
            String sql = "CREATE TABLE IF NOT EXISTS interview_questions (" +
                        "id SERIAL PRIMARY KEY," +
                        "question_text TEXT NOT NULL," +
                        "category VARCHAR(50) NOT NULL DEFAULT '기술'," +
                        "difficulty_level INTEGER NOT NULL DEFAULT 3 CHECK (difficulty_level >= 1 AND difficulty_level <= 5)," +
                        "expected_answer TEXT," +
                        "is_active BOOLEAN NOT NULL DEFAULT true," +
                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                        "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                        ")";
            
            stmt.executeUpdate(sql);
            out.println("<div class='success'>✅ interview_questions 테이블 생성 완료</div>");
            
            // 인덱스 생성
            stmt.executeUpdate("CREATE INDEX IF NOT EXISTS idx_interview_questions_category ON interview_questions(category)");
            stmt.executeUpdate("CREATE INDEX IF NOT EXISTS idx_interview_questions_difficulty ON interview_questions(difficulty_level)");
            stmt.executeUpdate("CREATE INDEX IF NOT EXISTS idx_interview_questions_active ON interview_questions(is_active)");
            
        } catch (Exception e) {
            out.println("<div class='error'>❌ interview_questions 테이블 생성 실패: " + e.getMessage() + "</div>");
        }
    }
    
    private void createEvaluationCriteriaTable(Statement stmt, PrintWriter out) {
        try {
            String sql = "CREATE TABLE IF NOT EXISTS evaluation_criteria (" +
                        "id SERIAL PRIMARY KEY," +
                        "criteria_name VARCHAR(100) NOT NULL," +
                        "description TEXT," +
                        "max_score INTEGER NOT NULL DEFAULT 10," +
                        "weight DECIMAL(3,2) NOT NULL DEFAULT 1.00 CHECK (weight >= 0.1 AND weight <= 3.0)," +
                        "is_active BOOLEAN NOT NULL DEFAULT true," +
                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                        "updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                        ")";
            
            stmt.executeUpdate(sql);
            out.println("<div class='success'>✅ evaluation_criteria 테이블 생성 완료</div>");
            
            // 인덱스 생성
            stmt.executeUpdate("CREATE INDEX IF NOT EXISTS idx_evaluation_criteria_active ON evaluation_criteria(is_active)");
            
        } catch (Exception e) {
            out.println("<div class='error'>❌ evaluation_criteria 테이블 생성 실패: " + e.getMessage() + "</div>");
        }
    }
    
    private void insertSampleData(Statement stmt, PrintWriter out) {
        try {
            // 샘플 질문 3개만 삽입 (테스트용)
            String[] sampleQuestions = {
                "INSERT INTO interview_questions (question_text, category, difficulty_level, expected_answer) VALUES " +
                "('자바의 객체지향 프로그래밍 특징 4가지를 설명해주세요.', '기술', 2, '캡슐화, 상속, 다형성, 추상화에 대한 이해')",
                
                "INSERT INTO interview_questions (question_text, category, difficulty_level, expected_answer) VALUES " +
                "('팀에서 의견 충돌이 있을 때 어떻게 해결하시나요?', '인성', 2, '소통 능력, 문제 해결 능력, 협업 태도')",
                
                "INSERT INTO interview_questions (question_text, category, difficulty_level, expected_answer) VALUES " +
                "('가장 어려웠던 프로젝트 경험과 해결 과정을 말씀해주세요.', '경험', 3, '문제 해결 능력, 프로젝트 경험, 성장 과정')"
            };
            
            for (String sql : sampleQuestions) {
                stmt.executeUpdate(sql);
            }
            
            // 샘플 평가기준 3개 삽입
            String[] sampleCriteria = {
                "INSERT INTO evaluation_criteria (criteria_name, description, max_score, weight) VALUES " +
                "('기술적 역량', '프로그래밍 언어, 프레임워크, 도구 활용 능력', 10, 1.5)",
                
                "INSERT INTO evaluation_criteria (criteria_name, description, max_score, weight) VALUES " +
                "('소통 및 협업', '팀원과의 소통, 협업, 리더십 능력', 10, 1.2)",
                
                "INSERT INTO evaluation_criteria (criteria_name, description, max_score, weight) VALUES " +
                "('학습 능력', '새로운 기술과 지식을 빠르게 습득하는 능력', 10, 1.1)"
            };
            
            for (String sql : sampleCriteria) {
                stmt.executeUpdate(sql);
            }
            
            out.println("<div class='success'>✅ 샘플 데이터 삽입 완료 (질문 3개, 평가기준 3개)</div>");
            
        } catch (Exception e) {
            out.println("<div class='error'>❌ 샘플 데이터 삽입 실패: " + e.getMessage() + "</div>");
        }
    }
} 