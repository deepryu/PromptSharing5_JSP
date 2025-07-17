import java.sql.*;

public class CheckDB {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5432/promptsharing";
        String username = "postgresql";
        String password = "1234";
        
        try (Connection conn = DriverManager.getConnection(url, username, password)) {
            System.out.println("데이터베이스 연결 성공");
            
            // candidates 테이블 확인
            String sql = "SELECT COUNT(*) as count FROM candidates";
            try (PreparedStatement pstmt = conn.prepareStatement(sql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    System.out.println("candidates 테이블 레코드 수: " + rs.getInt("count"));
                }
            }
            
            // interview_results 테이블 확인
            sql = "SELECT COUNT(*) as count FROM interview_results";
            try (PreparedStatement pstmt = conn.prepareStatement(sql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    System.out.println("interview_results 테이블 레코드 수: " + rs.getInt("count"));
                }
            } catch (SQLException e) {
                System.out.println("interview_results 테이블이 존재하지 않습니다: " + e.getMessage());
            }
            
        } catch (SQLException e) {
            System.out.println("데이터베이스 오류: " + e.getMessage());
        }
    }
} 