-- ============================================================================
-- 📚 DATABASE SCHEMA - BẢO MẬT CƠ SỞ DỮ LIỆU
-- Hệ thống Quản Lý Người Dùng (UserManager)
-- Hệ quản trị CSDL: Oracle Database
-- ============================================================================

-- ============================================================================
-- 🗑️ PHẦN 1: XÓA CÁC ĐỐI TƯỢNG CŨ (NẾU CÓ)
-- ============================================================================

-- Xóa các sequences
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_USER_INFO';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_AUDIT_LOG';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Xóa các bảng
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE AUDIT_LOG CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE USER_INFO CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE APP_CONFIG CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- ============================================================================
-- 📋 PHẦN 2: TẠO CÁC TABLESPACES (Tùy chọn - Thường được DBA tạo sẵn)
-- ============================================================================

-- Lưu ý: Các tablespace thường được DBA tạo sẵn, đây chỉ là ví dụ
-- Uncomment nếu cần thiết

/*
-- Tablespace cho dữ liệu chính
CREATE TABLESPACE TBS_USERMANAGER_DATA
    DATAFILE 'usermanager_data01.dbf' SIZE 100M
    AUTOEXTEND ON NEXT 50M MAXSIZE 1G
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

-- Tablespace cho index
CREATE TABLESPACE TBS_USERMANAGER_INDEX
    DATAFILE 'usermanager_idx01.dbf' SIZE 50M
    AUTOEXTEND ON NEXT 25M MAXSIZE 500M
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

-- Tablespace tạm
CREATE TEMPORARY TABLESPACE TBS_USERMANAGER_TEMP
    TEMPFILE 'usermanager_temp01.dbf' SIZE 50M
    AUTOEXTEND ON NEXT 25M MAXSIZE 500M
    EXTENT MANAGEMENT LOCAL
    UNIFORM SIZE 1M;
*/

-- ============================================================================
-- 📦 PHẦN 3: TẠO CÁC SEQUENCES
-- ============================================================================

-- Sequence cho bảng USER_INFO
CREATE SEQUENCE SEQ_USER_INFO
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Sequence cho bảng AUDIT_LOG
CREATE SEQUENCE SEQ_AUDIT_LOG
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- ============================================================================
-- 👤 PHẦN 4: BẢNG THÔNG TIN BỔ SUNG (USER_INFO)
-- Bảng tự thiết kế để lưu thông tin cá nhân của người dùng
-- Dùng để demo chức năng gán quyền trên đối tượng (Object Privilege)
-- ============================================================================

CREATE TABLE USER_INFO (
    -- Primary Key
    USER_INFO_ID        NUMBER(10)          NOT NULL,
    
    -- Liên kết với Oracle User
    USERNAME            VARCHAR2(128)       NOT NULL,
    
    -- Thông tin cá nhân
    HO_TEN              NVARCHAR2(100)      NOT NULL,
    NGAY_SINH           DATE,
    GIOI_TINH           VARCHAR2(10)        CHECK (GIOI_TINH IN ('Nam', 'Nữ', 'Khác')),
    
    -- Thông tin liên lạc
    DIA_CHI             NVARCHAR2(255),
    QUAN_HUYEN          NVARCHAR2(50),
    TINH_THANH          NVARCHAR2(50),
    SO_DIEN_THOAI       VARCHAR2(20),
    EMAIL               VARCHAR2(100),
    
    -- Thông tin công việc
    CHUC_VU             NVARCHAR2(100),
    PHONG_BAN           NVARCHAR2(100),
    MA_NHAN_VIEN        VARCHAR2(20),
    
    -- Thông tin tài khoản (bổ sung)
    AVATAR_PATH         VARCHAR2(500),
    GHI_CHU             NVARCHAR2(500),
    
    -- Metadata
    CREATED_DATE        DATE                DEFAULT SYSDATE NOT NULL,
    CREATED_BY          VARCHAR2(128),
    UPDATED_DATE        DATE,
    UPDATED_BY          VARCHAR2(128),
    IS_ACTIVE           NUMBER(1)           DEFAULT 1 CHECK (IS_ACTIVE IN (0, 1)),
    
    -- Constraints
    CONSTRAINT PK_USER_INFO PRIMARY KEY (USER_INFO_ID),
    CONSTRAINT UK_USER_INFO_USERNAME UNIQUE (USERNAME),
    CONSTRAINT UK_USER_INFO_EMAIL UNIQUE (EMAIL),
    CONSTRAINT UK_USER_INFO_PHONE UNIQUE (SO_DIEN_THOAI)
);

-- Comments cho bảng USER_INFO
COMMENT ON TABLE USER_INFO IS 'Bảng lưu thông tin cá nhân bổ sung của người dùng Oracle';
COMMENT ON COLUMN USER_INFO.USER_INFO_ID IS 'ID định danh duy nhất cho mỗi bản ghi';
COMMENT ON COLUMN USER_INFO.USERNAME IS 'Tên đăng nhập Oracle (liên kết với DBA_USERS)';
COMMENT ON COLUMN USER_INFO.HO_TEN IS 'Họ và tên đầy đủ của người dùng';
COMMENT ON COLUMN USER_INFO.NGAY_SINH IS 'Ngày tháng năm sinh';
COMMENT ON COLUMN USER_INFO.GIOI_TINH IS 'Giới tính: Nam, Nữ, Khác';
COMMENT ON COLUMN USER_INFO.DIA_CHI IS 'Địa chỉ chi tiết (số nhà, đường, phường/xã)';
COMMENT ON COLUMN USER_INFO.QUAN_HUYEN IS 'Quận/Huyện';
COMMENT ON COLUMN USER_INFO.TINH_THANH IS 'Tỉnh/Thành phố';
COMMENT ON COLUMN USER_INFO.SO_DIEN_THOAI IS 'Số điện thoại liên lạc';
COMMENT ON COLUMN USER_INFO.EMAIL IS 'Địa chỉ email';
COMMENT ON COLUMN USER_INFO.CHUC_VU IS 'Chức vụ trong tổ chức';
COMMENT ON COLUMN USER_INFO.PHONG_BAN IS 'Phòng ban làm việc';
COMMENT ON COLUMN USER_INFO.MA_NHAN_VIEN IS 'Mã nhân viên nội bộ';
COMMENT ON COLUMN USER_INFO.AVATAR_PATH IS 'Đường dẫn ảnh đại diện';
COMMENT ON COLUMN USER_INFO.GHI_CHU IS 'Ghi chú thêm';
COMMENT ON COLUMN USER_INFO.CREATED_DATE IS 'Ngày tạo bản ghi';
COMMENT ON COLUMN USER_INFO.CREATED_BY IS 'Người tạo bản ghi';
COMMENT ON COLUMN USER_INFO.UPDATED_DATE IS 'Ngày cập nhật cuối';
COMMENT ON COLUMN USER_INFO.UPDATED_BY IS 'Người cập nhật cuối';
COMMENT ON COLUMN USER_INFO.IS_ACTIVE IS 'Trạng thái hoạt động (1=Active, 0=Inactive)';

-- ============================================================================
-- 📝 PHẦN 5: BẢNG AUDIT LOG (Ghi nhận các hoạt động)
-- ============================================================================

CREATE TABLE AUDIT_LOG (
    -- Primary Key
    LOG_ID              NUMBER(15)          NOT NULL,
    
    -- Thông tin người thực hiện
    USERNAME            VARCHAR2(128)       NOT NULL,
    SESSION_ID          NUMBER,
    IP_ADDRESS          VARCHAR2(45),
    
    -- Thông tin hành động
    ACTION_TYPE         VARCHAR2(50)        NOT NULL,
    ACTION_OBJECT       VARCHAR2(128),
    OBJECT_TYPE         VARCHAR2(50),
    ACTION_DETAIL       NVARCHAR2(1000),
    
    -- Kết quả
    STATUS              VARCHAR2(20)        DEFAULT 'SUCCESS' 
                                            CHECK (STATUS IN ('SUCCESS', 'FAILED', 'WARNING')),
    ERROR_MESSAGE       NVARCHAR2(500),
    
    -- Timestamp
    ACTION_DATE         TIMESTAMP           DEFAULT SYSTIMESTAMP NOT NULL,
    
    -- Constraints
    CONSTRAINT PK_AUDIT_LOG PRIMARY KEY (LOG_ID)
);

-- Comments cho bảng AUDIT_LOG
COMMENT ON TABLE AUDIT_LOG IS 'Bảng ghi nhận lịch sử các hoạt động của người dùng';
COMMENT ON COLUMN AUDIT_LOG.LOG_ID IS 'ID định danh duy nhất cho mỗi log entry';
COMMENT ON COLUMN AUDIT_LOG.USERNAME IS 'Tên người dùng thực hiện hành động';
COMMENT ON COLUMN AUDIT_LOG.SESSION_ID IS 'Session ID của Oracle';
COMMENT ON COLUMN AUDIT_LOG.IP_ADDRESS IS 'Địa chỉ IP của máy client';
COMMENT ON COLUMN AUDIT_LOG.ACTION_TYPE IS 'Loại hành động (CREATE, UPDATE, DELETE, GRANT, REVOKE, LOGIN, LOGOUT, ...)';
COMMENT ON COLUMN AUDIT_LOG.ACTION_OBJECT IS 'Đối tượng bị tác động';
COMMENT ON COLUMN AUDIT_LOG.OBJECT_TYPE IS 'Loại đối tượng (USER, ROLE, PROFILE, TABLE, ...)';
COMMENT ON COLUMN AUDIT_LOG.ACTION_DETAIL IS 'Chi tiết hành động thực hiện';
COMMENT ON COLUMN AUDIT_LOG.STATUS IS 'Trạng thái kết quả (SUCCESS, FAILED, WARNING)';
COMMENT ON COLUMN AUDIT_LOG.ERROR_MESSAGE IS 'Thông báo lỗi nếu có';
COMMENT ON COLUMN AUDIT_LOG.ACTION_DATE IS 'Thời điểm thực hiện hành động';

-- Index cho AUDIT_LOG
CREATE INDEX IDX_AUDIT_LOG_USERNAME ON AUDIT_LOG(USERNAME);
CREATE INDEX IDX_AUDIT_LOG_ACTION_DATE ON AUDIT_LOG(ACTION_DATE);
CREATE INDEX IDX_AUDIT_LOG_ACTION_TYPE ON AUDIT_LOG(ACTION_TYPE);

-- ============================================================================
-- ⚙️ PHẦN 6: BẢNG CẤU HÌNH ỨNG DỤNG (APP_CONFIG)
-- ============================================================================

CREATE TABLE APP_CONFIG (
    CONFIG_KEY          VARCHAR2(100)       NOT NULL,
    CONFIG_VALUE        NVARCHAR2(500),
    CONFIG_TYPE         VARCHAR2(50)        DEFAULT 'STRING' 
                                            CHECK (CONFIG_TYPE IN ('STRING', 'NUMBER', 'BOOLEAN', 'JSON')),
    DESCRIPTION_VN      NVARCHAR2(255),
    IS_EDITABLE         NUMBER(1)           DEFAULT 1 CHECK (IS_EDITABLE IN (0, 1)),
    UPDATED_DATE        DATE                DEFAULT SYSDATE,
    UPDATED_BY          VARCHAR2(128),
    
    CONSTRAINT PK_APP_CONFIG PRIMARY KEY (CONFIG_KEY)
);

COMMENT ON TABLE APP_CONFIG IS 'Bảng lưu các cấu hình của ứng dụng';
COMMENT ON COLUMN APP_CONFIG.CONFIG_KEY IS 'Khóa cấu hình (unique)';
COMMENT ON COLUMN APP_CONFIG.CONFIG_VALUE IS 'Giá trị cấu hình';
COMMENT ON COLUMN APP_CONFIG.CONFIG_TYPE IS 'Kiểu dữ liệu của giá trị';
COMMENT ON COLUMN APP_CONFIG.DESCRIPTION_VN IS 'Mô tả cấu hình bằng tiếng Việt';
COMMENT ON COLUMN APP_CONFIG.IS_EDITABLE IS 'Có thể chỉnh sửa qua UI (1=Có, 0=Không)';

-- ============================================================================
-- 🔧 PHẦN 7: INSERT DỮ LIỆU CẤU HÌNH MẶC ĐỊNH
-- ============================================================================

INSERT INTO APP_CONFIG (CONFIG_KEY, CONFIG_VALUE, CONFIG_TYPE, DESCRIPTION_VN, IS_EDITABLE) VALUES
('PASSWORD_MIN_LENGTH', '8', 'NUMBER', 'Độ dài tối thiểu của mật khẩu', 1);

INSERT INTO APP_CONFIG (CONFIG_KEY, CONFIG_VALUE, CONFIG_TYPE, DESCRIPTION_VN, IS_EDITABLE) VALUES
('PASSWORD_REQUIRE_UPPERCASE', 'true', 'BOOLEAN', 'Yêu cầu chữ hoa trong mật khẩu', 1);

INSERT INTO APP_CONFIG (CONFIG_KEY, CONFIG_VALUE, CONFIG_TYPE, DESCRIPTION_VN, IS_EDITABLE) VALUES
('PASSWORD_REQUIRE_LOWERCASE', 'true', 'BOOLEAN', 'Yêu cầu chữ thường trong mật khẩu', 1);

INSERT INTO APP_CONFIG (CONFIG_KEY, CONFIG_VALUE, CONFIG_TYPE, DESCRIPTION_VN, IS_EDITABLE) VALUES
('PASSWORD_REQUIRE_NUMBER', 'true', 'BOOLEAN', 'Yêu cầu số trong mật khẩu', 1);

INSERT INTO APP_CONFIG (CONFIG_KEY, CONFIG_VALUE, CONFIG_TYPE, DESCRIPTION_VN, IS_EDITABLE) VALUES
('PASSWORD_REQUIRE_SPECIAL', 'false', 'BOOLEAN', 'Yêu cầu ký tự đặc biệt trong mật khẩu', 1);

INSERT INTO APP_CONFIG (CONFIG_KEY, CONFIG_VALUE, CONFIG_TYPE, DESCRIPTION_VN, IS_EDITABLE) VALUES
('SESSION_TIMEOUT_MINUTES', '30', 'NUMBER', 'Thời gian timeout session (phút)', 1);

INSERT INTO APP_CONFIG (CONFIG_KEY, CONFIG_VALUE, CONFIG_TYPE, DESCRIPTION_VN, IS_EDITABLE) VALUES
('MAX_LOGIN_ATTEMPTS', '5', 'NUMBER', 'Số lần đăng nhập sai tối đa trước khi khóa', 1);

INSERT INTO APP_CONFIG (CONFIG_KEY, CONFIG_VALUE, CONFIG_TYPE, DESCRIPTION_VN, IS_EDITABLE) VALUES
('DEFAULT_PAGE_SIZE', '20', 'NUMBER', 'Số bản ghi mặc định mỗi trang', 1);

INSERT INTO APP_CONFIG (CONFIG_KEY, CONFIG_VALUE, CONFIG_TYPE, DESCRIPTION_VN, IS_EDITABLE) VALUES
('HASH_ALGORITHM', 'SHA256', 'STRING', 'Thuật toán mã hóa mật khẩu (SHA256, BCRYPT)', 0);

INSERT INTO APP_CONFIG (CONFIG_KEY, CONFIG_VALUE, CONFIG_TYPE, DESCRIPTION_VN, IS_EDITABLE) VALUES
('ENABLE_AUDIT_LOG', 'true', 'BOOLEAN', 'Bật/tắt ghi log hoạt động', 1);

COMMIT;

-- ============================================================================
-- 📊 PHẦN 8: VIEWS HỖ TRỢ TRUY VẤN SYSTEM CATALOG
-- ============================================================================

-- View 1: Liệt kê tất cả Users và thông tin cơ bản
CREATE OR REPLACE VIEW VW_ALL_USERS AS
SELECT 
    u.USERNAME,
    u.ACCOUNT_STATUS,
    u.LOCK_DATE,
    u.CREATED AS CREATED_DATE,
    u.DEFAULT_TABLESPACE,
    u.TEMPORARY_TABLESPACE,
    u.PROFILE,
    NVL(ui.HO_TEN, u.USERNAME) AS FULL_NAME,
    ui.EMAIL,
    ui.SO_DIEN_THOAI,
    ui.PHONG_BAN
FROM DBA_USERS u
LEFT JOIN USER_INFO ui ON UPPER(u.USERNAME) = UPPER(ui.USERNAME)
WHERE u.ORACLE_MAINTAINED = 'N'  -- Loại bỏ các user hệ thống của Oracle
ORDER BY u.USERNAME;

-- View 2: Liệt kê tất cả Roles
CREATE OR REPLACE VIEW VW_ALL_ROLES AS
SELECT 
    r.ROLE,
    r.PASSWORD_REQUIRED,
    r.AUTHENTICATION_TYPE,
    (SELECT COUNT(*) FROM DBA_ROLE_PRIVS rp WHERE rp.GRANTED_ROLE = r.ROLE) AS GRANTEE_COUNT
FROM DBA_ROLES r
WHERE r.ORACLE_MAINTAINED = 'N'
ORDER BY r.ROLE;

-- View 3: Liệt kê tất cả Profiles và resources
CREATE OR REPLACE VIEW VW_ALL_PROFILES AS
SELECT 
    p.PROFILE,
    MAX(CASE WHEN p.RESOURCE_NAME = 'SESSIONS_PER_USER' THEN p.LIMIT END) AS SESSIONS_PER_USER,
    MAX(CASE WHEN p.RESOURCE_NAME = 'CONNECT_TIME' THEN p.LIMIT END) AS CONNECT_TIME,
    MAX(CASE WHEN p.RESOURCE_NAME = 'IDLE_TIME' THEN p.LIMIT END) AS IDLE_TIME,
    MAX(CASE WHEN p.RESOURCE_NAME = 'PASSWORD_LIFE_TIME' THEN p.LIMIT END) AS PASSWORD_LIFE_TIME,
    MAX(CASE WHEN p.RESOURCE_NAME = 'PASSWORD_GRACE_TIME' THEN p.LIMIT END) AS PASSWORD_GRACE_TIME,
    MAX(CASE WHEN p.RESOURCE_NAME = 'PASSWORD_REUSE_MAX' THEN p.LIMIT END) AS PASSWORD_REUSE_MAX,
    MAX(CASE WHEN p.RESOURCE_NAME = 'FAILED_LOGIN_ATTEMPTS' THEN p.LIMIT END) AS FAILED_LOGIN_ATTEMPTS,
    MAX(CASE WHEN p.RESOURCE_NAME = 'PASSWORD_LOCK_TIME' THEN p.LIMIT END) AS PASSWORD_LOCK_TIME
FROM DBA_PROFILES p
GROUP BY p.PROFILE
ORDER BY p.PROFILE;

-- View 4: Liệt kê System Privileges được gán
CREATE OR REPLACE VIEW VW_SYSTEM_PRIVILEGES AS
SELECT 
    sp.GRANTEE,
    sp.PRIVILEGE,
    sp.ADMIN_OPTION,
    CASE 
        WHEN EXISTS (SELECT 1 FROM DBA_USERS u WHERE u.USERNAME = sp.GRANTEE) THEN 'USER'
        WHEN EXISTS (SELECT 1 FROM DBA_ROLES r WHERE r.ROLE = sp.GRANTEE) THEN 'ROLE'
        ELSE 'OTHER'
    END AS GRANTEE_TYPE
FROM DBA_SYS_PRIVS sp
ORDER BY sp.GRANTEE, sp.PRIVILEGE;

-- View 5: Liệt kê Object Privileges được gán
CREATE OR REPLACE VIEW VW_OBJECT_PRIVILEGES AS
SELECT 
    tp.GRANTEE,
    tp.OWNER,
    tp.TABLE_NAME AS OBJECT_NAME,
    tp.PRIVILEGE,
    tp.GRANTABLE,
    tp.GRANTOR,
    'TABLE' AS OBJECT_TYPE,
    CASE 
        WHEN EXISTS (SELECT 1 FROM DBA_USERS u WHERE u.USERNAME = tp.GRANTEE) THEN 'USER'
        WHEN EXISTS (SELECT 1 FROM DBA_ROLES r WHERE r.ROLE = tp.GRANTEE) THEN 'ROLE'
        ELSE 'OTHER'
    END AS GRANTEE_TYPE
FROM DBA_TAB_PRIVS tp
ORDER BY tp.GRANTEE, tp.OWNER, tp.TABLE_NAME;

-- View 6: Liệt kê Role được gán cho User/Role khác
CREATE OR REPLACE VIEW VW_ROLE_GRANTS AS
SELECT 
    rp.GRANTEE,
    rp.GRANTED_ROLE,
    rp.ADMIN_OPTION,
    rp.DEFAULT_ROLE,
    CASE 
        WHEN EXISTS (SELECT 1 FROM DBA_USERS u WHERE u.USERNAME = rp.GRANTEE) THEN 'USER'
        WHEN EXISTS (SELECT 1 FROM DBA_ROLES r WHERE r.ROLE = rp.GRANTEE) THEN 'ROLE'
        ELSE 'OTHER'
    END AS GRANTEE_TYPE
FROM DBA_ROLE_PRIVS rp
ORDER BY rp.GRANTEE, rp.GRANTED_ROLE;

-- View 7: Liệt kê Tablespaces có sẵn
CREATE OR REPLACE VIEW VW_TABLESPACES AS
SELECT 
    t.TABLESPACE_NAME,
    t.BLOCK_SIZE,
    t.STATUS,
    t.CONTENTS,
    t.EXTENT_MANAGEMENT,
    ROUND(NVL(SUM(f.BYTES), 0) / 1024 / 1024, 2) AS SIZE_MB,
    ROUND(NVL(SUM(f.BYTES) - NVL(SUM(fs.BYTES), 0), 0) / 1024 / 1024, 2) AS USED_MB
FROM DBA_TABLESPACES t
LEFT JOIN DBA_DATA_FILES f ON t.TABLESPACE_NAME = f.TABLESPACE_NAME
LEFT JOIN DBA_FREE_SPACE fs ON t.TABLESPACE_NAME = fs.TABLESPACE_NAME
GROUP BY t.TABLESPACE_NAME, t.BLOCK_SIZE, t.STATUS, t.CONTENTS, t.EXTENT_MANAGEMENT
ORDER BY t.TABLESPACE_NAME;

-- View 8: Liệt kê Quota của User trên Tablespace
CREATE OR REPLACE VIEW VW_USER_QUOTAS AS
SELECT 
    tq.USERNAME,
    tq.TABLESPACE_NAME,
    CASE 
        WHEN tq.MAX_BYTES = -1 THEN 'UNLIMITED'
        ELSE TO_CHAR(ROUND(tq.MAX_BYTES / 1024 / 1024, 2)) || ' MB'
    END AS MAX_QUOTA,
    ROUND(tq.BYTES / 1024 / 1024, 2) AS USED_MB
FROM DBA_TS_QUOTAS tq
ORDER BY tq.USERNAME, tq.TABLESPACE_NAME;

-- View 9: Column Privileges (cho demo Object Privilege trên Column)
CREATE OR REPLACE VIEW VW_COLUMN_PRIVILEGES AS
SELECT 
    cp.GRANTEE,
    cp.TABLE_SCHEMA AS OWNER,
    cp.TABLE_NAME,
    cp.COLUMN_NAME,
    cp.PRIVILEGE,
    cp.GRANTABLE
FROM DBA_COL_PRIVS cp
ORDER BY cp.GRANTEE, cp.TABLE_NAME, cp.COLUMN_NAME;

-- ============================================================================
-- 📦 PHẦN 9: STORED PROCEDURES HỖ TRỢ
-- ============================================================================

-- Procedure ghi Audit Log
CREATE OR REPLACE PROCEDURE SP_WRITE_AUDIT_LOG (
    p_username      IN VARCHAR2,
    p_action_type   IN VARCHAR2,
    p_object_type   IN VARCHAR2 DEFAULT NULL,
    p_action_object IN VARCHAR2 DEFAULT NULL,
    p_action_detail IN NVARCHAR2 DEFAULT NULL,
    p_status        IN VARCHAR2 DEFAULT 'SUCCESS',
    p_error_message IN NVARCHAR2 DEFAULT NULL
) AS
    v_enabled VARCHAR2(10);
BEGIN
    -- Kiểm tra cấu hình có bật audit log không
    SELECT CONFIG_VALUE INTO v_enabled 
    FROM APP_CONFIG 
    WHERE CONFIG_KEY = 'ENABLE_AUDIT_LOG';
    
    IF UPPER(v_enabled) = 'TRUE' THEN
        INSERT INTO AUDIT_LOG (
            LOG_ID, 
            USERNAME, 
            SESSION_ID, 
            ACTION_TYPE, 
            OBJECT_TYPE,
            ACTION_OBJECT, 
            ACTION_DETAIL, 
            STATUS, 
            ERROR_MESSAGE, 
            ACTION_DATE
        ) VALUES (
            SEQ_AUDIT_LOG.NEXTVAL,
            p_username,
            SYS_CONTEXT('USERENV', 'SESSIONID'),
            p_action_type,
            p_object_type,
            p_action_object,
            p_action_detail,
            p_status,
            p_error_message,
            SYSTIMESTAMP
        );
        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Không để lỗi audit log ảnh hưởng đến chức năng chính
END SP_WRITE_AUDIT_LOG;
/

-- Procedure lấy thông tin User đầy đủ
CREATE OR REPLACE PROCEDURE SP_GET_USER_FULL_INFO (
    p_username  IN VARCHAR2,
    p_cursor    OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            u.USERNAME,
            u.ACCOUNT_STATUS,
            u.LOCK_DATE,
            u.CREATED AS CREATED_DATE,
            u.DEFAULT_TABLESPACE,
            u.TEMPORARY_TABLESPACE,
            u.PROFILE,
            ui.HO_TEN,
            ui.NGAY_SINH,
            ui.GIOI_TINH,
            ui.DIA_CHI,
            ui.SO_DIEN_THOAI,
            ui.EMAIL,
            ui.CHUC_VU,
            ui.PHONG_BAN,
            ui.MA_NHAN_VIEN
        FROM DBA_USERS u
        LEFT JOIN USER_INFO ui ON UPPER(u.USERNAME) = UPPER(ui.USERNAME)
        WHERE UPPER(u.USERNAME) = UPPER(p_username);
END SP_GET_USER_FULL_INFO;
/

-- Procedure lấy danh sách Privileges của User
CREATE OR REPLACE PROCEDURE SP_GET_USER_PRIVILEGES (
    p_username  IN VARCHAR2,
    p_cursor    OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        -- System Privileges trực tiếp
        SELECT 
            sp.PRIVILEGE AS PRIVILEGE_NAME,
            'SYSTEM' AS PRIVILEGE_TYPE,
            'DIRECT' AS SOURCE,
            NULL AS SOURCE_ROLE,
            sp.ADMIN_OPTION
        FROM DBA_SYS_PRIVS sp
        WHERE UPPER(sp.GRANTEE) = UPPER(p_username)
        
        UNION ALL
        
        -- System Privileges từ Role
        SELECT 
            rsp.PRIVILEGE AS PRIVILEGE_NAME,
            'SYSTEM' AS PRIVILEGE_TYPE,
            'ROLE' AS SOURCE,
            rp.GRANTED_ROLE AS SOURCE_ROLE,
            rsp.ADMIN_OPTION
        FROM DBA_ROLE_PRIVS rp
        JOIN DBA_SYS_PRIVS rsp ON rsp.GRANTEE = rp.GRANTED_ROLE
        WHERE UPPER(rp.GRANTEE) = UPPER(p_username)
        
        UNION ALL
        
        -- Object Privileges trực tiếp
        SELECT 
            tp.PRIVILEGE || ' ON ' || tp.OWNER || '.' || tp.TABLE_NAME AS PRIVILEGE_NAME,
            'OBJECT' AS PRIVILEGE_TYPE,
            'DIRECT' AS SOURCE,
            NULL AS SOURCE_ROLE,
            tp.GRANTABLE AS ADMIN_OPTION
        FROM DBA_TAB_PRIVS tp
        WHERE UPPER(tp.GRANTEE) = UPPER(p_username)
        
        ORDER BY PRIVILEGE_TYPE, SOURCE, PRIVILEGE_NAME;
END SP_GET_USER_PRIVILEGES;
/

-- Procedure lấy danh sách Roles của User
CREATE OR REPLACE PROCEDURE SP_GET_USER_ROLES (
    p_username  IN VARCHAR2,
    p_cursor    OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            rp.GRANTED_ROLE,
            rp.ADMIN_OPTION,
            rp.DEFAULT_ROLE
        FROM DBA_ROLE_PRIVS rp
        WHERE UPPER(rp.GRANTEE) = UPPER(p_username)
        ORDER BY rp.GRANTED_ROLE;
END SP_GET_USER_ROLES;
/

-- Function kiểm tra User có quyền hay không
CREATE OR REPLACE FUNCTION FN_CHECK_USER_PRIVILEGE (
    p_username  IN VARCHAR2,
    p_privilege IN VARCHAR2
) RETURN NUMBER AS
    v_count NUMBER;
BEGIN
    -- Kiểm tra quyền trực tiếp
    SELECT COUNT(*) INTO v_count
    FROM DBA_SYS_PRIVS
    WHERE UPPER(GRANTEE) = UPPER(p_username)
      AND UPPER(PRIVILEGE) = UPPER(p_privilege);
    
    IF v_count > 0 THEN
        RETURN 1;
    END IF;
    
    -- Kiểm tra quyền qua Role
    SELECT COUNT(*) INTO v_count
    FROM DBA_ROLE_PRIVS rp
    JOIN DBA_SYS_PRIVS sp ON UPPER(sp.GRANTEE) = UPPER(rp.GRANTED_ROLE)
    WHERE UPPER(rp.GRANTEE) = UPPER(p_username)
      AND UPPER(sp.PRIVILEGE) = UPPER(p_privilege);
    
    IF v_count > 0 THEN
        RETURN 1;
    END IF;
    
    RETURN 0;
END FN_CHECK_USER_PRIVILEGE;
/

-- ============================================================================
-- 🔐 PHẦN 10: TRIGGERS
-- ============================================================================

-- Trigger tự động gán ID cho USER_INFO
CREATE OR REPLACE TRIGGER TRG_USER_INFO_BI
BEFORE INSERT ON USER_INFO
FOR EACH ROW
BEGIN
    IF :NEW.USER_INFO_ID IS NULL THEN
        :NEW.USER_INFO_ID := SEQ_USER_INFO.NEXTVAL;
    END IF;
    :NEW.CREATED_DATE := NVL(:NEW.CREATED_DATE, SYSDATE);
    :NEW.USERNAME := UPPER(:NEW.USERNAME);
END;
/

-- Trigger cập nhật thời gian update cho USER_INFO
CREATE OR REPLACE TRIGGER TRG_USER_INFO_BU
BEFORE UPDATE ON USER_INFO
FOR EACH ROW
BEGIN
    :NEW.UPDATED_DATE := SYSDATE;
END;
/

-- ============================================================================
-- 🔒 PHẦN 11: TẠO SAMPLE PROFILES (Tùy chọn)
-- ============================================================================

-- Profile cho Developer
/*
CREATE PROFILE PROFILE_DEVELOPER LIMIT
    SESSIONS_PER_USER 5
    CONNECT_TIME 480
    IDLE_TIME 30
    PASSWORD_LIFE_TIME 90
    PASSWORD_GRACE_TIME 7
    PASSWORD_REUSE_MAX 3
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 1;
*/

-- Profile cho Tester
/*
CREATE PROFILE PROFILE_TESTER LIMIT
    SESSIONS_PER_USER 3
    CONNECT_TIME 240
    IDLE_TIME 15
    PASSWORD_LIFE_TIME 60
    PASSWORD_GRACE_TIME 5
    PASSWORD_REUSE_MAX 5
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 1/24;
*/

-- Profile cho Guest (hạn chế)
/*
CREATE PROFILE PROFILE_GUEST LIMIT
    SESSIONS_PER_USER 1
    CONNECT_TIME 60
    IDLE_TIME 5
    PASSWORD_LIFE_TIME 30
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LOCK_TIME 1;
*/

-- ============================================================================
-- 🎭 PHẦN 12: TẠO SAMPLE ROLES (Tùy chọn)
-- ============================================================================

-- Role cho Admin
/*
CREATE ROLE ROLE_ADMIN;
GRANT CREATE USER, ALTER USER, DROP USER TO ROLE_ADMIN;
GRANT CREATE ROLE, ALTER ANY ROLE, DROP ANY ROLE, GRANT ANY ROLE TO ROLE_ADMIN;
GRANT CREATE PROFILE, ALTER PROFILE, DROP PROFILE TO ROLE_ADMIN;
GRANT CREATE SESSION TO ROLE_ADMIN;
GRANT SELECT ANY TABLE, INSERT ANY TABLE, UPDATE ANY TABLE, DELETE ANY TABLE TO ROLE_ADMIN;
*/

-- Role cho Developer
/*
CREATE ROLE ROLE_DEVELOPER;
GRANT CREATE SESSION TO ROLE_DEVELOPER;
GRANT CREATE TABLE TO ROLE_DEVELOPER;
GRANT SELECT ANY TABLE TO ROLE_DEVELOPER;
*/

-- Role cho Viewer (chỉ đọc)
/*
CREATE ROLE ROLE_VIEWER;
GRANT CREATE SESSION TO ROLE_VIEWER;
GRANT SELECT ANY TABLE TO ROLE_VIEWER;
*/

-- ============================================================================
-- 📋 PHẦN 13: INSERT DỮ LIỆU MẪU CHO BẢNG USER_INFO
-- ============================================================================

-- Lưu ý: Thay đổi USERNAME theo các user thực tế trong database của bạn

/*
INSERT INTO USER_INFO (
    USERNAME, HO_TEN, NGAY_SINH, GIOI_TINH, 
    DIA_CHI, QUAN_HUYEN, TINH_THANH,
    SO_DIEN_THOAI, EMAIL, 
    CHUC_VU, PHONG_BAN, MA_NHAN_VIEN,
    CREATED_BY
) VALUES (
    'ADMIN', N'Nguyễn Văn Admin', TO_DATE('1985-01-15', 'YYYY-MM-DD'), 'Nam',
    N'123 Đường Lê Lợi', N'Quận 1', N'TP. Hồ Chí Minh',
    '0901234567', 'admin@company.com',
    N'Quản trị viên hệ thống', N'Phòng CNTT', 'NV001',
    'SYSTEM'
);

INSERT INTO USER_INFO (
    USERNAME, HO_TEN, NGAY_SINH, GIOI_TINH, 
    DIA_CHI, QUAN_HUYEN, TINH_THANH,
    SO_DIEN_THOAI, EMAIL, 
    CHUC_VU, PHONG_BAN, MA_NHAN_VIEN,
    CREATED_BY
) VALUES (
    'DEV_USER', N'Trần Thị Developer', TO_DATE('1992-06-20', 'YYYY-MM-DD'), N'Nữ',
    N'456 Đường Nguyễn Huệ', N'Quận 3', N'TP. Hồ Chí Minh',
    '0912345678', 'developer@company.com',
    N'Lập trình viên', N'Phòng Phát triển', 'NV002',
    'ADMIN'
);

COMMIT;
*/

-- ============================================================================
-- ✅ PHẦN 14: GRANT QUYỀN CHO BẢNG USER_INFO (Demo Object Privilege)
-- ============================================================================

-- Ví dụ Grant quyền SELECT trên toàn bộ bảng
-- GRANT SELECT ON USER_INFO TO ROLE_VIEWER;

-- Ví dụ Grant quyền trên các cột cụ thể
-- GRANT SELECT (USERNAME, HO_TEN, EMAIL) ON USER_INFO TO ROLE_DEVELOPER;
-- GRANT INSERT (USERNAME, HO_TEN, DIA_CHI, SO_DIEN_THOAI, EMAIL) ON USER_INFO TO ROLE_DEVELOPER;

-- ============================================================================
-- 📊 PHẦN 15: THỐNG KÊ SAU KHI TẠO SCHEMA
-- ============================================================================

SELECT 'Tables Created:' AS STATUS, COUNT(*) AS COUNT 
FROM USER_TABLES 
WHERE TABLE_NAME IN ('USER_INFO', 'AUDIT_LOG', 'APP_CONFIG');

SELECT 'Sequences Created:' AS STATUS, COUNT(*) AS COUNT 
FROM USER_SEQUENCES 
WHERE SEQUENCE_NAME IN ('SEQ_USER_INFO', 'SEQ_AUDIT_LOG');

SELECT 'Views Created:' AS STATUS, COUNT(*) AS COUNT 
FROM USER_VIEWS 
WHERE VIEW_NAME LIKE 'VW_%';

SELECT 'Procedures Created:' AS STATUS, COUNT(*) AS COUNT 
FROM USER_PROCEDURES 
WHERE OBJECT_NAME LIKE 'SP_%';

SELECT 'Functions Created:' AS STATUS, COUNT(*) AS COUNT 
FROM USER_PROCEDURES 
WHERE OBJECT_NAME LIKE 'FN_%';

SELECT 'Triggers Created:' AS STATUS, COUNT(*) AS COUNT 
FROM USER_TRIGGERS 
WHERE TRIGGER_NAME LIKE 'TRG_%';

-- ============================================================================
-- 🎉 HOÀN THÀNH - DATABASE SCHEMA CHO HỆ THỐNG QUẢN LÝ NGƯỜI DÙNG
-- ============================================================================

/*
=============================================================================
📝 HƯỚNG DẪN SỬ DỤNG:

1. Chạy script này trên Oracle Database với quyền DBA/SYSDBA

2. Các bảng chính:
   - USER_INFO: Lưu thông tin cá nhân bổ sung
   - AUDIT_LOG: Ghi log hoạt động
   - APP_CONFIG: Lưu cấu hình ứng dụng

3. Các Views hỗ trợ truy vấn:
   - VW_ALL_USERS: Danh sách tất cả users
   - VW_ALL_ROLES: Danh sách tất cả roles
   - VW_ALL_PROFILES: Danh sách profiles và resources
   - VW_SYSTEM_PRIVILEGES: Quyền hệ thống
   - VW_OBJECT_PRIVILEGES: Quyền đối tượng
   - VW_ROLE_GRANTS: Roles được gán
   - VW_TABLESPACES: Danh sách tablespaces
   - VW_USER_QUOTAS: Quota của users
   - VW_COLUMN_PRIVILEGES: Quyền trên column

4. Các Stored Procedures:
   - SP_WRITE_AUDIT_LOG: Ghi log hoạt động
   - SP_GET_USER_FULL_INFO: Lấy thông tin đầy đủ của user
   - SP_GET_USER_PRIVILEGES: Lấy danh sách quyền của user
   - SP_GET_USER_ROLES: Lấy danh sách roles của user

5. Function:
   - FN_CHECK_USER_PRIVILEGE: Kiểm tra user có quyền cụ thể không

=============================================================================
*/
