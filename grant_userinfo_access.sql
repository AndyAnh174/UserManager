-- Grant quyền truy cập bảng USER_INFO cho tất cả users
-- Chạy script này bằng user SYSTEM

-- Grant SELECT cho tất cả users (thông qua PUBLIC)
GRANT SELECT ON SYSTEM.USER_INFO TO PUBLIC;
GRANT SELECT ON SYSTEM.SEQ_USER_INFO TO PUBLIC;

-- Hoặc grant riêng cho từng user khi tạo
-- GRANT SELECT ON SYSTEM.USER_INFO TO <username>;

COMMIT;
