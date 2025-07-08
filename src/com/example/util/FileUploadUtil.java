package com.example.util;

import java.io.*;
import java.nio.file.*;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.servlet.http.Part;

public class FileUploadUtil {
    
    // 업로드 디렉토리 설정
    private static final String UPLOAD_DIR = "uploads/resumes/";
    private static final String TEMP_DIR = "uploads/temp/";
    
    // 허용된 파일 확장자
    private static final Set<String> ALLOWED_EXTENSIONS = new HashSet<>(
        Arrays.asList("pdf", "hwp", "doc", "docx")
    );
    
    // 허용된 MIME 타입
    private static final Set<String> ALLOWED_MIME_TYPES = new HashSet<>(
        Arrays.asList(
            "application/pdf",
            "application/haansofthwp", 
            "application/x-hwp",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        )
    );
    
    // 최대 파일 크기 (10MB)
    private static final long MAX_FILE_SIZE = 10 * 1024 * 1024;
    
    /**
     * 파일을 업로드하고 저장된 파일 정보를 반환합니다.
     */
    public static Map<String, Object> uploadResumeFile(Part filePart, String candidateName) throws Exception {
        if (filePart == null || filePart.getSize() == 0) {
            throw new IllegalArgumentException("파일이 선택되지 않았습니다.");
        }
        
        // 파일 크기 검증
        if (filePart.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("파일 크기가 10MB를 초과할 수 없습니다.");
        }
        
        // 원본 파일명 가져오기
        String originalFileName = getFileName(filePart);
        if (originalFileName == null || originalFileName.trim().isEmpty()) {
            throw new IllegalArgumentException("유효하지 않은 파일명입니다.");
        }
        
        // 파일 확장자 검증
        String fileExtension = getFileExtension(originalFileName).toLowerCase();
        if (!ALLOWED_EXTENSIONS.contains(fileExtension)) {
            throw new IllegalArgumentException("지원하지 않는 파일 형식입니다. (PDF, HWP, DOC, DOCX만 가능)");
        }
        
        // MIME 타입 검증
        String contentType = filePart.getContentType();
        if (contentType != null && !ALLOWED_MIME_TYPES.contains(contentType.toLowerCase())) {
            System.out.println("Warning: MIME 타입이 예상과 다릅니다 - " + contentType);
        }
        
        // 새 파일명 생성 (날짜시간_지원자명_원본파일명)
        String timestamp = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String safeFileName = sanitizeFileName(originalFileName);
        String newFileName = timestamp + "_" + sanitizeFileName(candidateName) + "_" + safeFileName;
        
        // 업로드 디렉토리 생성
        Path uploadPath = Paths.get(UPLOAD_DIR);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        
        // 파일 저장
        Path filePath = uploadPath.resolve(newFileName);
        try (InputStream inputStream = filePart.getInputStream()) {
            Files.copy(inputStream, filePath, StandardCopyOption.REPLACE_EXISTING);
        }
        
        // 파일 정보 반환
        Map<String, Object> fileInfo = new HashMap<>();
        fileInfo.put("originalFileName", originalFileName);
        fileInfo.put("savedFileName", newFileName);
        fileInfo.put("filePath", UPLOAD_DIR + newFileName);
        fileInfo.put("fileSize", filePart.getSize());
        fileInfo.put("fileType", fileExtension);
        fileInfo.put("contentType", contentType);
        
        return fileInfo;
    }
    
    /**
     * 파일을 삭제합니다.
     */
    public static boolean deleteResumeFile(String filePath) {
        if (filePath == null || filePath.trim().isEmpty()) {
            return false;
        }
        
        try {
            Path path = Paths.get(filePath);
            return Files.deleteIfExists(path);
        } catch (Exception e) {
            System.err.println("파일 삭제 실패: " + filePath + " - " + e.getMessage());
            return false;
        }
    }
    
    /**
     * 파일이 존재하는지 확인합니다.
     */
    public static boolean fileExists(String filePath) {
        if (filePath == null || filePath.trim().isEmpty()) {
            return false;
        }
        return Files.exists(Paths.get(filePath));
    }
    
    /**
     * 파일 크기를 사람이 읽기 쉬운 형태로 변환합니다.
     */
    public static String formatFileSize(long size) {
        if (size <= 0) return "0 B";
        
        String[] units = {"B", "KB", "MB", "GB"};
        int unitIndex = 0;
        double fileSize = size;
        
        while (fileSize >= 1024 && unitIndex < units.length - 1) {
            fileSize /= 1024;
            unitIndex++;
        }
        
        return String.format("%.1f %s", fileSize, units[unitIndex]);
    }
    
    /**
     * Part에서 파일명을 추출합니다.
     */
    private static String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        if (contentDisposition == null) return null;
        
        for (String token : contentDisposition.split(";")) {
            if (token.trim().startsWith("filename")) {
                String fileName = token.substring(token.indexOf('=') + 1).trim();
                return fileName.replace("\"", "");
            }
        }
        return null;
    }
    
    /**
     * 파일 확장자를 추출합니다.
     */
    private static String getFileExtension(String fileName) {
        if (fileName == null || !fileName.contains(".")) {
            return "";
        }
        return fileName.substring(fileName.lastIndexOf(".") + 1);
    }
    
    /**
     * 파일명을 안전하게 정리합니다.
     */
    private static String sanitizeFileName(String fileName) {
        if (fileName == null) return "unknown";
        
        // 위험한 문자 제거 및 공백을 언더스코어로 변경
        return fileName.replaceAll("[^a-zA-Z0-9가-힣._-]", "_")
                      .replaceAll("\\s+", "_")
                      .replaceAll("_{2,}", "_");
    }
    
    /**
     * 업로드 디렉토리 경로를 반환합니다.
     */
    public static String getUploadDirectory() {
        return UPLOAD_DIR;
    }
    
    /**
     * 허용된 파일 확장자 목록을 반환합니다.
     */
    public static Set<String> getAllowedExtensions() {
        return new HashSet<>(ALLOWED_EXTENSIONS);
    }
    
    /**
     * 최대 파일 크기를 반환합니다.
     */
    public static long getMaxFileSize() {
        return MAX_FILE_SIZE;
    }
} 