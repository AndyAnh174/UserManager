-- ============================================================================
-- 📊 DATABASE ERD - HỆ THỐNG QUẢN LÝ NGƯỜI DÙNG
-- Chỉ bao gồm các bảng và quan hệ (relationships)
-- ============================================================================

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│                           ERD DIAGRAM (Text-based)                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌──────────────────┐                                                      │
│   │   DBA_USERS      │  (Oracle System Table - không cần tạo)               │
│   │   ─────────────  │                                                      │
│   │   USERNAME (PK)  │◄─────────────────────────────────────────┐           │
│   │   ACCOUNT_STATUS │                                          │           │
│   │   LOCK_DATE      │                                          │           │
│   │   CREATED        │                                          │           │
│   │   PROFILE        │──────────┐                               │           │
│   │   ...            │          │                               │           │
│   └──────────────────┘          │                               │           │
│            │                    │                               │           │
│            │ 1:1                │ N:1                           │           │
│            ▼                    ▼                               │           │
│   ┌──────────────────┐   ┌──────────────────┐                   │           │
│   │   USER_INFO      │   │  DBA_PROFILES    │ (Oracle System)   │           │
│   │   ─────────────  │   │  ─────────────   │                   │           │
│   │   USER_INFO_ID   │   │  PROFILE (PK)    │                   │           │
│   │   USERNAME (FK)  │   │  RESOURCE_NAME   │                   │           │
│   │   HO_TEN         │   │  LIMIT           │                   │           │
│   │   NGAY_SINH      │   └──────────────────┘                   │           │
│   │   EMAIL          │                                          │           │
│   │   SO_DIEN_THOAI  │                                          │           │
│   │   PHONG_BAN      │                                          │           │
│   │   ...            │                                          │           │
│   └──────────────────┘                                          │           │
│            │                                                    │           │
│            │ 1:N                                                │           │
│            ▼                                                    │           │
│   ┌──────────────────┐         ┌──────────────────┐            │           │
│   │   AUDIT_LOG      │         │  USER_ROLES      │            │           │
│   │   ─────────────  │         │  ─────────────   │            │           │
│   │   LOG_ID (PK)    │         │  ID (PK)         │            │           │
│   │   USERNAME (FK)  │◄────────│  USERNAME (FK)   │────────────┘           │
│   │   ACTION_TYPE    │         │  ROLE_NAME (FK)  │───────┐                │
│   │   ACTION_OBJECT  │         │  GRANTED_BY      │       │                │
│   │   ACTION_DATE    │         │  GRANT_DATE      │       │                │
│   │   STATUS         │         └──────────────────┘       │                │
│   └──────────────────┘                                    │                │
│                                                           │                │
│                                ┌──────────────────┐       │                │
│                                │  ROLES           │◄──────┘                │
│                                │  ─────────────   │                        │
│                                │  ROLE_ID (PK)    │                        │
│                                │  ROLE_NAME       │◄─────────────┐         │
│                                │  DESCRIPTION     │              │         │
│                                │  HAS_PASSWORD    │              │         │
│                                └──────────────────┘              │         │
│                                         │                        │         │
│                                         │ 1:N                    │         │
│                                         ▼                        │         │
│                                ┌──────────────────┐              │         │
│                                │ ROLE_PRIVILEGES  │              │         │
│                                │ ─────────────    │              │         │
│                                │ ID (PK)          │              │         │
│                                │ ROLE_NAME (FK)   │──────────────┘         │
│                                │ PRIVILEGE_NAME   │                        │
│                                │ PRIVILEGE_TYPE   │                        │
│                                │ WITH_ADMIN_OPT   │                        │
│                                └──────────────────┘                        │
│                                                                            │
│   ┌──────────────────┐         ┌──────────────────┐                        │
│   │ USER_PRIVILEGES  │         │   APP_CONFIG     │                        │
│   │ ─────────────    │         │   ─────────────  │                        │
│   │ ID (PK)          │         │   CONFIG_KEY(PK) │                        │
│   │ USERNAME (FK)    │─────────│   CONFIG_VALUE   │                        │
│   │ PRIVILEGE_NAME   │         │   CONFIG_TYPE    │                        │
│   │ PRIVILEGE_TYPE   │         │   DESCRIPTION    │                        │
│   │ OBJECT_NAME      │         └──────────────────┘                        │
│   │ WITH_GRANT_OPT   │                                                     │
│   └──────────────────┘                                                     │
│                                                                            │
└─────────────────────────────────────────────────────────────────────────────┘
*/

-- ============================================================================
-- 🗑️ XÓA CÁC BẢNG CŨ (NẾU CÓ)
-- ============================================================================
BEGIN EXECUTE IMMEDIATE 'DROP TABLE AUDIT_LOG CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE USER_PRIVILEGES CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE USER_ROLES CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE ROLE_PRIVILEGES CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE ROLES CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE USER_INFO CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE APP_CONFIG CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- ============================================================================
-- 📋 BẢNG 1: USER_INFO (Thông tin cá nhân bổ sung)
-- Liên kết: FK → DBA_USERS.USERNAME (Oracle System)
-- ============================================================================
CREATE TABLE USER_INFO (
    USER_INFO_ID        NUMBER(10)          PRIMARY KEY,
    USERNAME            VARCHAR2(128)       NOT NULL UNIQUE,  -- FK → DBA_USERS
    HO_TEN              NVARCHAR2(100)      NOT NULL,
    NGAY_SINH           DATE,
    GIOI_TINH           VARCHAR2(10),
    DIA_CHI             NVARCHAR2(255),
    SO_DIEN_THOAI       VARCHAR2(20)        UNIQUE,
    EMAIL               VARCHAR2(100)       UNIQUE,
    CHUC_VU             NVARCHAR2(100),
    PHONG_BAN           NVARCHAR2(100),
    MA_NHAN_VIEN        VARCHAR2(20),
    AVATAR_PATH         VARCHAR2(500),
    CREATED_DATE        DATE                DEFAULT SYSDATE,
    CREATED_BY          VARCHAR2(128),
    UPDATED_DATE        DATE,
    IS_ACTIVE           NUMBER(1)           DEFAULT 1
);

-- ============================================================================
-- 📋 BẢNG 2: ROLES (Quản lý Role tự định nghĩa)
-- Bảng độc lập, được tham chiếu bởi USER_ROLES và ROLE_PRIVILEGES
-- ============================================================================
CREATE TABLE ROLES (
    ROLE_ID             NUMBER(10)          PRIMARY KEY,
    ROLE_NAME           VARCHAR2(128)       NOT NULL UNIQUE,
    DESCRIPTION         NVARCHAR2(255),
    HAS_PASSWORD        NUMBER(1)           DEFAULT 0,
    CREATED_DATE        DATE                DEFAULT SYSDATE,
    CREATED_BY          VARCHAR2(128)
);

-- ============================================================================
-- 📋 BẢNG 3: USER_ROLES (Liên kết User - Role) [N:N]
-- Liên kết: FK → USER_INFO.USERNAME, FK → ROLES.ROLE_NAME
-- ============================================================================
CREATE TABLE USER_ROLES (
    ID                  NUMBER(10)          PRIMARY KEY,
    USERNAME            VARCHAR2(128)       NOT NULL,
    ROLE_NAME           VARCHAR2(128)       NOT NULL,
    ADMIN_OPTION        NUMBER(1)           DEFAULT 0,
    DEFAULT_ROLE        NUMBER(1)           DEFAULT 1,
    GRANTED_BY          VARCHAR2(128),
    GRANT_DATE          DATE                DEFAULT SYSDATE,
    
    -- Foreign Keys
    CONSTRAINT FK_USER_ROLES_USER 
        FOREIGN KEY (USERNAME) REFERENCES USER_INFO(USERNAME),
    CONSTRAINT FK_USER_ROLES_ROLE 
        FOREIGN KEY (ROLE_NAME) REFERENCES ROLES(ROLE_NAME),
    
    -- Unique constraint: mỗi user chỉ có 1 role cùng tên
    CONSTRAINT UK_USER_ROLES UNIQUE (USERNAME, ROLE_NAME)
);

-- ============================================================================
-- 📋 BẢNG 4: ROLE_PRIVILEGES (Quyền của Role)
-- Liên kết: FK → ROLES.ROLE_NAME
-- ============================================================================
CREATE TABLE ROLE_PRIVILEGES (
    ID                  NUMBER(10)          PRIMARY KEY,
    ROLE_NAME           VARCHAR2(128)       NOT NULL,
    PRIVILEGE_NAME      VARCHAR2(100)       NOT NULL,
    PRIVILEGE_TYPE      VARCHAR2(20)        NOT NULL,  -- 'SYSTEM' hoặc 'OBJECT'
    OBJECT_OWNER        VARCHAR2(128),                 -- Chỉ dùng cho Object Privilege
    OBJECT_NAME         VARCHAR2(128),                 -- Chỉ dùng cho Object Privilege
    WITH_ADMIN_OPTION   NUMBER(1)           DEFAULT 0,
    GRANTED_DATE        DATE                DEFAULT SYSDATE,
    
    -- Foreign Key
    CONSTRAINT FK_ROLE_PRIVS_ROLE 
        FOREIGN KEY (ROLE_NAME) REFERENCES ROLES(ROLE_NAME),
    
    -- Unique constraint
    CONSTRAINT UK_ROLE_PRIVILEGES UNIQUE (ROLE_NAME, PRIVILEGE_NAME, OBJECT_NAME)
);

-- ============================================================================
-- 📋 BẢNG 5: USER_PRIVILEGES (Quyền trực tiếp của User)
-- Liên kết: FK → USER_INFO.USERNAME
-- ============================================================================
CREATE TABLE USER_PRIVILEGES (
    ID                  NUMBER(10)          PRIMARY KEY,
    USERNAME            VARCHAR2(128)       NOT NULL,
    PRIVILEGE_NAME      VARCHAR2(100)       NOT NULL,
    PRIVILEGE_TYPE      VARCHAR2(20)        NOT NULL,  -- 'SYSTEM' hoặc 'OBJECT'
    OBJECT_OWNER        VARCHAR2(128),                 -- Chỉ dùng cho Object Privilege
    OBJECT_NAME         VARCHAR2(128),                 -- Chỉ dùng cho Object Privilege
    COLUMN_NAME         VARCHAR2(128),                 -- Chỉ dùng cho Column Privilege
    WITH_GRANT_OPTION   NUMBER(1)           DEFAULT 0,
    WITH_ADMIN_OPTION   NUMBER(1)           DEFAULT 0,
    GRANTED_BY          VARCHAR2(128),
    GRANTED_DATE        DATE                DEFAULT SYSDATE,
    
    -- Foreign Key
    CONSTRAINT FK_USER_PRIVS_USER 
        FOREIGN KEY (USERNAME) REFERENCES USER_INFO(USERNAME),
    
    -- Unique constraint
    CONSTRAINT UK_USER_PRIVILEGES UNIQUE (USERNAME, PRIVILEGE_NAME, OBJECT_NAME, COLUMN_NAME)
);

-- ============================================================================
-- 📋 BẢNG 6: AUDIT_LOG (Ghi log hoạt động)
-- Liên kết: FK → USER_INFO.USERNAME
-- ============================================================================
CREATE TABLE AUDIT_LOG (
    LOG_ID              NUMBER(15)          PRIMARY KEY,
    USERNAME            VARCHAR2(128)       NOT NULL,
    SESSION_ID          NUMBER,
    IP_ADDRESS          VARCHAR2(45),
    ACTION_TYPE         VARCHAR2(50)        NOT NULL,
    OBJECT_TYPE         VARCHAR2(50),
    ACTION_OBJECT       VARCHAR2(128),
    ACTION_DETAIL       NVARCHAR2(1000),
    STATUS              VARCHAR2(20)        DEFAULT 'SUCCESS',
    ERROR_MESSAGE       NVARCHAR2(500),
    ACTION_DATE         TIMESTAMP           DEFAULT SYSTIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT FK_AUDIT_LOG_USER 
        FOREIGN KEY (USERNAME) REFERENCES USER_INFO(USERNAME)
);

-- ============================================================================
-- 📋 BẢNG 7: APP_CONFIG (Cấu hình ứng dụng)
-- Bảng độc lập, không có quan hệ
-- ============================================================================
CREATE TABLE APP_CONFIG (
    CONFIG_KEY          VARCHAR2(100)       PRIMARY KEY,
    CONFIG_VALUE        NVARCHAR2(500),
    CONFIG_TYPE         VARCHAR2(50)        DEFAULT 'STRING',
    DESCRIPTION_VN      NVARCHAR2(255),
    IS_EDITABLE         NUMBER(1)           DEFAULT 1,
    UPDATED_DATE        DATE                DEFAULT SYSDATE,
    UPDATED_BY          VARCHAR2(128)
);

-- ============================================================================
-- 📊 TỔNG KẾT CÁC QUAN HỆ (RELATIONSHIPS)
-- ============================================================================

/*
┌─────────────────────────────────────────────────────────────────────────────┐
│                         BẢNG TỔNG KẾT QUAN HỆ                               │
├──────────────────┬──────────────────┬───────────┬───────────────────────────┤
│   Bảng Cha       │   Bảng Con       │  Quan hệ  │   Mô tả                   │
├──────────────────┼──────────────────┼───────────┼───────────────────────────┤
│ USER_INFO        │ USER_ROLES       │   1 : N   │ 1 User có nhiều Roles     │
│ USER_INFO        │ USER_PRIVILEGES  │   1 : N   │ 1 User có nhiều Privileges│
│ USER_INFO        │ AUDIT_LOG        │   1 : N   │ 1 User có nhiều Log       │
│ ROLES            │ USER_ROLES       │   1 : N   │ 1 Role gán cho nhiều User │
│ ROLES            │ ROLE_PRIVILEGES  │   1 : N   │ 1 Role có nhiều Privileges│
├──────────────────┴──────────────────┴───────────┴───────────────────────────┤
│                                                                             │
│   DBA_USERS (Oracle System) ─── 1:1 ───► USER_INFO                         │
│   DBA_PROFILES (Oracle System) ◄── N:1 ── DBA_USERS                        │
│   DBA_ROLES (Oracle System) ─── sync ───► ROLES                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                            ER DIAGRAM SUMMARY                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                           ┌─────────────┐                                   │
│                           │  APP_CONFIG │ (Standalone)                      │
│                           └─────────────┘                                   │
│                                                                             │
│                                                                             │
│                ┌─────────────────────────────────────┐                      │
│                │            USER_INFO                │                      │
│                │         (Central Entity)            │                      │
│                └──────────┬──────────┬───────────────┘                      │
│                           │          │                                      │
│              ┌────────────┼──────────┼────────────┐                         │
│              │            │          │            │                         │
│              ▼            ▼          ▼            ▼                         │
│     ┌────────────┐ ┌────────────┐ ┌────────────┐                            │
│     │ AUDIT_LOG  │ │USER_ROLES  │ │USER_PRIVS  │                            │
│     └────────────┘ └─────┬──────┘ └────────────┘                            │
│                          │                                                  │
│                          │                                                  │
│                          ▼                                                  │
│                   ┌─────────────┐                                           │
│                   │   ROLES     │                                           │
│                   └──────┬──────┘                                           │
│                          │                                                  │
│                          ▼                                                  │
│                  ┌──────────────┐                                           │
│                  │ROLE_PRIVILEGES│                                          │
│                  └──────────────┘                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
*/

-- ============================================================================
-- 📋 INDEXES CHO CÁC FOREIGN KEYS
-- ============================================================================
CREATE INDEX IDX_USER_ROLES_USERNAME ON USER_ROLES(USERNAME);
CREATE INDEX IDX_USER_ROLES_ROLE ON USER_ROLES(ROLE_NAME);
CREATE INDEX IDX_ROLE_PRIVS_ROLE ON ROLE_PRIVILEGES(ROLE_NAME);
CREATE INDEX IDX_USER_PRIVS_USER ON USER_PRIVILEGES(USERNAME);
CREATE INDEX IDX_AUDIT_LOG_USER ON AUDIT_LOG(USERNAME);
CREATE INDEX IDX_AUDIT_LOG_DATE ON AUDIT_LOG(ACTION_DATE);

-- ============================================================================
-- ✅ KIỂM TRA CÁC BẢNG ĐÃ TẠO
-- ============================================================================
SELECT TABLE_NAME, 
       (SELECT COUNT(*) FROM USER_CONSTRAINTS WHERE TABLE_NAME = t.TABLE_NAME AND CONSTRAINT_TYPE = 'P') AS PK_COUNT,
       (SELECT COUNT(*) FROM USER_CONSTRAINTS WHERE TABLE_NAME = t.TABLE_NAME AND CONSTRAINT_TYPE = 'R') AS FK_COUNT
FROM USER_TABLES t
WHERE TABLE_NAME IN ('USER_INFO', 'ROLES', 'USER_ROLES', 'ROLE_PRIVILEGES', 
                     'USER_PRIVILEGES', 'AUDIT_LOG', 'APP_CONFIG')
ORDER BY TABLE_NAME;

-- ============================================================================
-- 🎉 HOÀN THÀNH
-- ============================================================================
