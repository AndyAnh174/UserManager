# 📋 HƯỚNG DẪN TEST STORED PROCEDURES

## 📌 Mục lục
1. [Chuẩn bị](#chuẩn-bị)
2. [Test User Management](#1-test-user-management)
3. [Test Role Management](#2-test-role-management)
4. [Test Profile Management](#3-test-profile-management)
5. [Test Privilege Management](#4-test-privilege-management)
6. [Test User Info](#5-test-user-info)
7. [Cleanup](#cleanup---dọn-dẹp-sau-khi-test)

---

## Chuẩn bị

### Kết nối Oracle
```powershell
docker exec -it oracle-23ai sqlplus SYSTEM/YourStrongPassword123@FREEPDB1
```

### Chạy script tạo Stored Procedures
```sql
@/tmp/stored_procedures.sql
```

### Kiểm tra các procedures đã tạo
```sql
SELECT object_name, status 
FROM user_objects 
WHERE object_type = 'PROCEDURE' 
AND object_name LIKE 'SP_%'
ORDER BY object_name;
```

**Kết quả mong đợi:** 20+ procedures với status = VALID

---

## 1. TEST USER MANAGEMENT

### 1.1. Tạo User mới (SP_CREATE_USER)

```sql
-- Test 1: Tạo user với các tham số mặc định
EXEC SP_CREATE_USER('TEST_USER1', 'Password123!');

-- Kiểm tra
SELECT username, account_status, default_tablespace, profile 
FROM dba_users WHERE username = 'TEST_USER1';
```

**Kết quả mong đợi:**
| USERNAME | ACCOUNT_STATUS | DEFAULT_TABLESPACE | PROFILE |
|----------|----------------|-------------------|---------|
| TEST_USER1 | OPEN | USERS | DEFAULT |

```sql
-- Test 2: Tạo user với đầy đủ tham số
EXEC SP_CREATE_USER(
    p_username => 'TEST_USER2',
    p_password => 'Password123!',
    p_default_ts => 'USERS',
    p_temp_ts => 'TEMP',
    p_profile => 'DEFAULT',
    p_quota => '100M',
    p_account_lock => 0
);

-- Kiểm tra
SELECT username, account_status, default_tablespace 
FROM dba_users WHERE username = 'TEST_USER2';
```

```sql
-- Test 3: Tạo user và lock account
EXEC SP_CREATE_USER(
    p_username => 'TEST_USER3',
    p_password => 'Password123!',
    p_account_lock => 1
);

-- Kiểm tra
SELECT username, account_status FROM dba_users WHERE username = 'TEST_USER3';
```

**Kết quả mong đợi:** ACCOUNT_STATUS = LOCKED

---

### 1.2. Cập nhật User (SP_UPDATE_USER)

```sql
-- Test: Đổi password và tablespace
EXEC SP_UPDATE_USER(
    p_username => 'TEST_USER1',
    p_password => 'NewPassword123!'
);

-- Kiểm tra bằng cách kết nối với password mới
-- (Không có output, chỉ kiểm tra không có lỗi)
```

---

### 1.3. Lock/Unlock User

```sql
-- Lock user
EXEC SP_LOCK_USER('TEST_USER1');

-- Kiểm tra
SELECT username, account_status FROM dba_users WHERE username = 'TEST_USER1';
```

**Kết quả:** ACCOUNT_STATUS = LOCKED

```sql
-- Unlock user
EXEC SP_UNLOCK_USER('TEST_USER1');

-- Kiểm tra
SELECT username, account_status FROM dba_users WHERE username = 'TEST_USER1';
```

**Kết quả:** ACCOUNT_STATUS = OPEN

---

### 1.4. Đổi Password (SP_CHANGE_PASSWORD)

```sql
EXEC SP_CHANGE_PASSWORD('TEST_USER1', 'AnotherPass123!');
-- Không có output nếu thành công
```

---

### 1.5. Xóa User (SP_DELETE_USER)

```sql
-- Xóa user (CASCADE - xóa cả objects)
EXEC SP_DELETE_USER('TEST_USER3');

-- Kiểm tra
SELECT username FROM dba_users WHERE username = 'TEST_USER3';
```

**Kết quả:** no rows selected

---

## 2. TEST ROLE MANAGEMENT

### 2.1. Tạo Role không password (SP_CREATE_ROLE)

```sql
EXEC SP_CREATE_ROLE('TEST_ROLE1');

-- Kiểm tra
SELECT role, password_required FROM dba_roles WHERE role = 'TEST_ROLE1';
```

**Kết quả:**
| ROLE | PASSWORD_REQUIRED |
|------|-------------------|
| TEST_ROLE1 | NO |

---

### 2.2. Tạo Role có password (SP_CREATE_ROLE_WITH_PASSWORD)

```sql
EXEC SP_CREATE_ROLE_WITH_PASSWORD('TEST_ROLE2', 'RolePass123!');

-- Kiểm tra
SELECT role, password_required FROM dba_roles WHERE role = 'TEST_ROLE2';
```

**Kết quả:** PASSWORD_REQUIRED = YES

---

### 2.3. Đổi Password Role (SP_CHANGE_ROLE_PASSWORD)

```sql
EXEC SP_CHANGE_ROLE_PASSWORD('TEST_ROLE2', 'NewRolePass123!');
```

---

### 2.4. Xóa Password Role (SP_REMOVE_ROLE_PASSWORD)

```sql
EXEC SP_REMOVE_ROLE_PASSWORD('TEST_ROLE2');

-- Kiểm tra
SELECT role, password_required FROM dba_roles WHERE role = 'TEST_ROLE2';
```

**Kết quả:** PASSWORD_REQUIRED = NO

---

### 2.5. Xóa Role (SP_DELETE_ROLE)

```sql
EXEC SP_DELETE_ROLE('TEST_ROLE2');

-- Kiểm tra
SELECT role FROM dba_roles WHERE role = 'TEST_ROLE2';
```

**Kết quả:** no rows selected

---

## 3. TEST PROFILE MANAGEMENT

### 3.1. Tạo Profile (SP_CREATE_PROFILE)

```sql
-- Tạo profile với các giới hạn
EXEC SP_CREATE_PROFILE(
    p_profile_name => 'TEST_PROFILE1',
    p_sessions_per_user => '5',
    p_connect_time => '60',
    p_idle_time => '15'
);

-- Kiểm tra
SELECT profile, resource_name, limit 
FROM dba_profiles 
WHERE profile = 'TEST_PROFILE1'
AND resource_name IN ('SESSIONS_PER_USER', 'CONNECT_TIME', 'IDLE_TIME')
ORDER BY resource_name;
```

**Kết quả:**
| PROFILE | RESOURCE_NAME | LIMIT |
|---------|---------------|-------|
| TEST_PROFILE1 | CONNECT_TIME | 60 |
| TEST_PROFILE1 | IDLE_TIME | 15 |
| TEST_PROFILE1 | SESSIONS_PER_USER | 5 |

---

### 3.2. Cập nhật Profile (SP_UPDATE_PROFILE)

```sql
EXEC SP_UPDATE_PROFILE(
    p_profile_name => 'TEST_PROFILE1',
    p_sessions_per_user => '10',
    p_idle_time => '30'
);

-- Kiểm tra
SELECT resource_name, limit 
FROM dba_profiles 
WHERE profile = 'TEST_PROFILE1'
AND resource_name IN ('SESSIONS_PER_USER', 'IDLE_TIME');
```

**Kết quả:** SESSIONS_PER_USER = 10, IDLE_TIME = 30

---

### 3.3. Xóa Profile (SP_DELETE_PROFILE)

```sql
EXEC SP_DELETE_PROFILE('TEST_PROFILE1');

-- Kiểm tra
SELECT DISTINCT profile FROM dba_profiles WHERE profile = 'TEST_PROFILE1';
```

**Kết quả:** no rows selected

---

## 4. TEST PRIVILEGE MANAGEMENT

### 4.1. Grant System Privilege (SP_GRANT_SYS_PRIV)

```sql
-- Grant CREATE SESSION cho user
EXEC SP_GRANT_SYS_PRIV('CREATE SESSION', 'TEST_USER1', 0);

-- Kiểm tra
SELECT privilege FROM dba_sys_privs WHERE grantee = 'TEST_USER1';
```

**Kết quả:** CREATE SESSION

```sql
-- Grant với ADMIN OPTION
EXEC SP_GRANT_SYS_PRIV('CREATE TABLE', 'TEST_USER1', 1);

-- Kiểm tra
SELECT privilege, admin_option FROM dba_sys_privs WHERE grantee = 'TEST_USER1';
```

**Kết quả:** CREATE TABLE với ADMIN_OPTION = YES

---

### 4.2. Revoke System Privilege (SP_REVOKE_SYS_PRIV)

```sql
EXEC SP_REVOKE_SYS_PRIV('CREATE TABLE', 'TEST_USER1');

-- Kiểm tra
SELECT privilege FROM dba_sys_privs WHERE grantee = 'TEST_USER1' AND privilege = 'CREATE TABLE';
```

**Kết quả:** no rows selected

---

### 4.3. Grant Role (SP_GRANT_ROLE)

```sql
-- Grant role cho user
EXEC SP_GRANT_ROLE('TEST_ROLE1', 'TEST_USER1', 0);

-- Kiểm tra
SELECT granted_role FROM dba_role_privs WHERE grantee = 'TEST_USER1';
```

**Kết quả:** TEST_ROLE1

---

### 4.4. Revoke Role (SP_REVOKE_ROLE)

```sql
EXEC SP_REVOKE_ROLE('TEST_ROLE1', 'TEST_USER1');

-- Kiểm tra
SELECT granted_role FROM dba_role_privs WHERE grantee = 'TEST_USER1' AND granted_role = 'TEST_ROLE1';
```

**Kết quả:** no rows selected

---

### 4.5. Grant Object Privilege (SP_GRANT_OBJ_PRIV)

```sql
-- Tạo test table trước
CREATE TABLE TEST_TABLE (id NUMBER, name VARCHAR2(100));

-- Grant SELECT trên table
EXEC SP_GRANT_OBJ_PRIV('SELECT', 'SYSTEM', 'TEST_TABLE', 'TEST_USER1', 0);

-- Kiểm tra
SELECT privilege, table_name FROM dba_tab_privs 
WHERE grantee = 'TEST_USER1' AND table_name = 'TEST_TABLE';
```

**Kết quả:** SELECT on TEST_TABLE

---

### 4.6. Revoke Object Privilege (SP_REVOKE_OBJ_PRIV)

```sql
EXEC SP_REVOKE_OBJ_PRIV('SELECT', 'SYSTEM', 'TEST_TABLE', 'TEST_USER1');

-- Kiểm tra
SELECT * FROM dba_tab_privs 
WHERE grantee = 'TEST_USER1' AND table_name = 'TEST_TABLE';
```

**Kết quả:** no rows selected

---

### 4.7. Grant Column Privilege (SP_GRANT_COL_PRIV)

```sql
-- Grant UPDATE trên cột cụ thể
EXEC SP_GRANT_COL_PRIV('UPDATE', 'SYSTEM', 'TEST_TABLE', 'NAME', 'TEST_USER1', 0);

-- Kiểm tra
SELECT privilege, table_name, column_name FROM dba_col_privs 
WHERE grantee = 'TEST_USER1';
```

**Kết quả:** UPDATE on TEST_TABLE.NAME

---

## 5. TEST USER INFO

### Chuẩn bị: Tạo bảng USER_INFO và Sequence

```sql
-- Tạo Sequence
CREATE SEQUENCE SEQ_USER_INFO START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Tạo bảng
CREATE TABLE USER_INFO (
    USER_INFO_ID        NUMBER(10)          PRIMARY KEY,
    USERNAME            VARCHAR2(128)       NOT NULL UNIQUE,
    HO_TEN              NVARCHAR2(100)      NOT NULL,
    NGAY_SINH           DATE,
    GIOI_TINH           VARCHAR2(10),
    DIA_CHI             NVARCHAR2(255),
    SO_DIEN_THOAI       VARCHAR2(20),
    EMAIL               VARCHAR2(100),
    CHUC_VU             NVARCHAR2(100),
    PHONG_BAN           NVARCHAR2(100),
    MA_NHAN_VIEN        VARCHAR2(20),
    GHI_CHU             NVARCHAR2(500),
    CREATED_DATE        DATE DEFAULT SYSDATE,
    CREATED_BY          VARCHAR2(128),
    UPDATED_DATE        DATE,
    UPDATED_BY          VARCHAR2(128),
    IS_ACTIVE           NUMBER(1) DEFAULT 1
);
```

---

### 5.1. Thêm User Info (SP_INSERT_USER_INFO)

```sql
EXEC SP_INSERT_USER_INFO(
    p_username => 'TEST_USER1',
    p_ho_ten => N'Nguyễn Văn A',
    p_ngay_sinh => TO_DATE('1990-01-15', 'YYYY-MM-DD'),
    p_gioi_tinh => 'Nam',
    p_dia_chi => N'123 Đường ABC, Quận 1, TP.HCM',
    p_so_dien_thoai => '0901234567',
    p_email => 'nguyenvana@email.com',
    p_chuc_vu => N'Nhân viên',
    p_phong_ban => N'Phòng IT',
    p_ma_nhan_vien => 'NV001'
);

-- Kiểm tra
SELECT username, ho_ten, email, phong_ban FROM user_info WHERE username = 'TEST_USER1';
```

**Kết quả:**
| USERNAME | HO_TEN | EMAIL | PHONG_BAN |
|----------|--------|-------|-----------|
| TEST_USER1 | Nguyễn Văn A | nguyenvana@email.com | Phòng IT |

---

### 5.2. Cập nhật User Info (SP_UPDATE_USER_INFO)

```sql
EXEC SP_UPDATE_USER_INFO(
    p_username => 'TEST_USER1',
    p_ho_ten => N'Nguyễn Văn A Updated',
    p_chuc_vu => N'Trưởng phòng',
    p_email => 'nguyenvana.updated@email.com'
);

-- Kiểm tra
SELECT ho_ten, chuc_vu, email, updated_date FROM user_info WHERE username = 'TEST_USER1';
```

**Kết quả:** Thông tin đã được cập nhật

---

### 5.3. Xóa User Info - Soft Delete (SP_DELETE_USER_INFO)

```sql
EXEC SP_DELETE_USER_INFO('TEST_USER1');

-- Kiểm tra
SELECT username, is_active FROM user_info WHERE username = 'TEST_USER1';
```

**Kết quả:** IS_ACTIVE = 0

---

### 5.4. Xóa User Info - Hard Delete (SP_HARD_DELETE_USER_INFO)

```sql
EXEC SP_HARD_DELETE_USER_INFO('TEST_USER1');

-- Kiểm tra
SELECT * FROM user_info WHERE username = 'TEST_USER1';
```

**Kết quả:** no rows selected

---

## CLEANUP - Dọn dẹp sau khi test

```sql
-- Xóa test users
BEGIN
    FOR rec IN (SELECT username FROM dba_users WHERE username LIKE 'TEST_USER%') LOOP
        EXECUTE IMMEDIATE 'DROP USER "' || rec.username || '" CASCADE';
    END LOOP;
END;
/

-- Xóa test roles
BEGIN
    FOR rec IN (SELECT role FROM dba_roles WHERE role LIKE 'TEST_ROLE%') LOOP
        EXECUTE IMMEDIATE 'DROP ROLE "' || rec.role || '"';
    END LOOP;
END;
/

-- Xóa test profiles
BEGIN
    FOR rec IN (SELECT DISTINCT profile FROM dba_profiles WHERE profile LIKE 'TEST_PROFILE%') LOOP
        EXECUTE IMMEDIATE 'DROP PROFILE "' || rec.profile || '" CASCADE';
    END LOOP;
END;
/

-- Xóa test table
DROP TABLE TEST_TABLE;

-- Xóa user_info data
DELETE FROM USER_INFO WHERE USERNAME LIKE 'TEST_USER%';
COMMIT;

-- Kiểm tra đã dọn sạch
SELECT 'USERS: ' || COUNT(*) FROM dba_users WHERE username LIKE 'TEST_USER%'
UNION ALL
SELECT 'ROLES: ' || COUNT(*) FROM dba_roles WHERE role LIKE 'TEST_ROLE%'
UNION ALL
SELECT 'PROFILES: ' || COUNT(DISTINCT profile) FROM dba_profiles WHERE profile LIKE 'TEST_PROFILE%';
```

**Kết quả mong đợi:** Tất cả = 0

---

## 📊 BẢNG TỔNG HỢP PROCEDURES

| # | Procedure | Chức năng | Parameters |
|---|-----------|-----------|------------|
| 1 | SP_CREATE_USER | Tạo user mới | username, password, tablespace, profile, quota, lock |
| 2 | SP_UPDATE_USER | Cập nhật user | username, password, tablespace, profile, quota |
| 3 | SP_DELETE_USER | Xóa user CASCADE | username |
| 4 | SP_LOCK_USER | Khóa user | username |
| 5 | SP_UNLOCK_USER | Mở khóa user | username |
| 6 | SP_CHANGE_PASSWORD | Đổi mật khẩu | username, new_password |
| 7 | SP_CREATE_ROLE | Tạo role (no pass) | role_name |
| 8 | SP_CREATE_ROLE_WITH_PASSWORD | Tạo role có pass | role_name, password |
| 9 | SP_CHANGE_ROLE_PASSWORD | Đổi pass role | role_name, new_password |
| 10 | SP_REMOVE_ROLE_PASSWORD | Xóa pass role | role_name |
| 11 | SP_DELETE_ROLE | Xóa role | role_name |
| 12 | SP_CREATE_PROFILE | Tạo profile | profile_name, limits... |
| 13 | SP_UPDATE_PROFILE | Cập nhật profile | profile_name, limits... |
| 14 | SP_DELETE_PROFILE | Xóa profile CASCADE | profile_name |
| 15 | SP_GRANT_SYS_PRIV | Grant system priv | privilege, grantee, admin_option |
| 16 | SP_REVOKE_SYS_PRIV | Revoke system priv | privilege, grantee |
| 17 | SP_GRANT_OBJ_PRIV | Grant object priv | privilege, owner, object, grantee |
| 18 | SP_REVOKE_OBJ_PRIV | Revoke object priv | privilege, owner, object, grantee |
| 19 | SP_GRANT_COL_PRIV | Grant column priv | privilege, owner, object, column, grantee |
| 20 | SP_GRANT_ROLE | Grant role | role_name, grantee, admin_option |
| 21 | SP_REVOKE_ROLE | Revoke role | role_name, grantee |
| 22 | SP_INSERT_USER_INFO | Thêm thông tin cá nhân | username, họ tên, ngày sinh... |
| 23 | SP_UPDATE_USER_INFO | Cập nhật thông tin | username, họ tên, ngày sinh... |
| 24 | SP_DELETE_USER_INFO | Soft delete | username |
| 25 | SP_HARD_DELETE_USER_INFO | Hard delete | username |

---

## ✅ CHECKLIST TEST

- [ ] Chạy script stored_procedures.sql thành công
- [ ] Test SP_CREATE_USER - tạo user thành công
- [ ] Test SP_UPDATE_USER - cập nhật user thành công  
- [ ] Test SP_LOCK_USER / SP_UNLOCK_USER
- [ ] Test SP_DELETE_USER - xóa user thành công
- [ ] Test SP_CREATE_ROLE - tạo role thành công
- [ ] Test SP_CREATE_ROLE_WITH_PASSWORD
- [ ] Test SP_DELETE_ROLE
- [ ] Test SP_CREATE_PROFILE
- [ ] Test SP_UPDATE_PROFILE
- [ ] Test SP_DELETE_PROFILE
- [ ] Test SP_GRANT_SYS_PRIV
- [ ] Test SP_REVOKE_SYS_PRIV
- [ ] Test SP_GRANT_ROLE / SP_REVOKE_ROLE
- [ ] Test SP_GRANT_OBJ_PRIV / SP_REVOKE_OBJ_PRIV
- [ ] Test SP_INSERT_USER_INFO
- [ ] Test SP_UPDATE_USER_INFO
- [ ] Test SP_DELETE_USER_INFO
- [ ] Cleanup sau khi test

---

**Tạo bởi:** UserManager Application  
**Ngày:** 28/12/2024
