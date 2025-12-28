# 🧪 HƯỚNG DẪN TEST ỨNG DỤNG USERMANAGER

## 📋 MỤC LỤC

1. [Chuẩn Bị Môi Trường](#1-chuẩn-bị-môi-trường)
2. [Khởi Động Oracle Database](#2-khởi-động-oracle-database)
3. [Tạo Database Schema](#3-tạo-database-schema)
4. [Chạy Ứng Dụng](#4-chạy-ứng-dụng)
5. [Test Các Chức Năng](#5-test-các-chức-năng)
6. [Troubleshooting](#6-troubleshooting)

---

## 1. CHUẨN BỊ MÔI TRƯỜNG

### Yêu cầu hệ thống

- Windows 10/11
- .NET 8 SDK
- Docker Desktop
- Visual Studio 2022 (tùy chọn)

### Kiểm tra .NET đã cài

```powershell
dotnet --version
# Kết quả mong đợi: 8.0.x
```

### Kiểm tra Docker đã cài

```powershell
docker --version
# Kết quả mong đợi: Docker version 2x.x.x
```

---

## 2. KHỞI ĐỘNG ORACLE DATABASE

### Bước 2.1: Mở Docker Desktop

Đảm bảo Docker Desktop đang chạy (icon Docker ở system tray)

### Bước 2.2: Start Oracle Container

```powershell
# Di chuyển đến thư mục project
cd c:\Users\ADMIN\source\repos\UserManager\UserManager

# Start container (lần đầu sẽ pull image ~2GB)
docker-compose up -d
```

### Bước 2.3: Kiểm tra container đang chạy

```powershell
docker ps
```

Kết quả mong đợi:

```
CONTAINER ID   IMAGE                                                 STATUS          PORTS
xxxx           container-registry.oracle.com/database/free:23.4.0.0  Up x minutes    0.0.0.0:1521->1521/tcp
```

### Bước 2.4: Đợi Oracle khởi động hoàn tất

```powershell
# Xem logs để theo dõi tiến trình
docker logs -f oracle-23ai
```

**Đợi cho đến khi thấy:**

```
#########################
DATABASE IS READY TO USE!
#########################
```

⏱️ **Lần đầu tiên:** Khoảng 5-10 phút
⏱️ **Các lần sau:** Khoảng 1-2 phút

**Nhấn `Ctrl+C` để thoát xem logs**

---

## 3. TẠO DATABASE SCHEMA

### Bước 3.1: Kết nối vào Oracle trong container

```powershell
docker exec -it oracle-23ai sqlplus SYSTEM/YourStrongPassword123@FREEPDB1
```

### Bước 3.2: Tạo bảng USER_INFO và các objects

Copy và paste đoạn SQL sau vào SQL*Plus:

```sql
-- Tạo Sequence
CREATE SEQUENCE SEQ_USER_INFO START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_AUDIT_LOG START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- Tạo bảng USER_INFO (Thông tin cá nhân bổ sung)
CREATE TABLE USER_INFO (
    USER_INFO_ID        NUMBER(10)          PRIMARY KEY,
    USERNAME            VARCHAR2(128)       NOT NULL UNIQUE,
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
    GHI_CHU             NVARCHAR2(500),
    CREATED_DATE        DATE                DEFAULT SYSDATE,
    CREATED_BY          VARCHAR2(128),
    UPDATED_DATE        DATE,
    UPDATED_BY          VARCHAR2(128),
    IS_ACTIVE           NUMBER(1)           DEFAULT 1
);

-- Tạo bảng AUDIT_LOG
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
    ACTION_DATE         TIMESTAMP           DEFAULT SYSTIMESTAMP
);

-- Tạo bảng APP_CONFIG
CREATE TABLE APP_CONFIG (
    CONFIG_KEY          VARCHAR2(100)       PRIMARY KEY,
    CONFIG_VALUE        NVARCHAR2(500),
    CONFIG_TYPE         VARCHAR2(50)        DEFAULT 'STRING',
    DESCRIPTION_VN      NVARCHAR2(255),
    IS_EDITABLE         NUMBER(1)           DEFAULT 1,
    UPDATED_DATE        DATE                DEFAULT SYSDATE,
    UPDATED_BY          VARCHAR2(128)
);

-- Insert cấu hình mặc định
INSERT INTO APP_CONFIG VALUES ('PASSWORD_MIN_LENGTH', '8', 'NUMBER', 'Độ dài tối thiểu mật khẩu', 1, SYSDATE, 'SYSTEM');
INSERT INTO APP_CONFIG VALUES ('HASH_ALGORITHM', 'SHA256', 'STRING', 'Thuật toán mã hóa', 0, SYSDATE, 'SYSTEM');
INSERT INTO APP_CONFIG VALUES ('ENABLE_AUDIT_LOG', 'true', 'BOOLEAN', 'Bật ghi log', 1, SYSDATE, 'SYSTEM');

COMMIT;

-- Kiểm tra
SELECT table_name FROM user_tables;
```

### Bước 3.3: Tạo một số Users test

```sql
-- Tạo User test (không phải SYSTEM)
CREATE USER TEST_USER IDENTIFIED BY Test123456
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON USERS;

CREATE USER DEV_USER IDENTIFIED BY Dev123456
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE TEMP
    QUOTA 100M ON USERS;

-- Grant quyền cơ bản
GRANT CREATE SESSION TO TEST_USER;
GRANT CREATE SESSION TO DEV_USER;

-- Thêm thông tin cá nhân
INSERT INTO USER_INFO (USER_INFO_ID, USERNAME, HO_TEN, EMAIL, PHONG_BAN, CREATED_BY)
VALUES (SEQ_USER_INFO.NEXTVAL, 'SYSTEM', N'Quản trị viên hệ thống', 'admin@company.com', N'IT', 'SYSTEM');

INSERT INTO USER_INFO (USER_INFO_ID, USERNAME, HO_TEN, EMAIL, SO_DIEN_THOAI, PHONG_BAN, CREATED_BY)
VALUES (SEQ_USER_INFO.NEXTVAL, 'TEST_USER', N'Nguyễn Văn Test', 'test@company.com', '0901234567', N'QA', 'SYSTEM');

INSERT INTO USER_INFO (USER_INFO_ID, USERNAME, HO_TEN, EMAIL, SO_DIEN_THOAI, PHONG_BAN, CREATED_BY)
VALUES (SEQ_USER_INFO.NEXTVAL, 'DEV_USER', N'Trần Thị Developer', 'dev@company.com', '0912345678', N'Development', 'SYSTEM');

COMMIT;

-- Thoát SQL*Plus
EXIT;
```

---

## 4. CHẠY ỨNG DỤNG

### Bước 4.1: Build project

```powershell
cd c:\Users\ADMIN\source\repos\UserManager
dotnet build
```

### Bước 4.2: Chạy ứng dụng

```powershell
dotnet run --project UserManager
```

**Hoặc mở Visual Studio:**

1. Mở file `UserManager.sln`
2. Nhấn `F5` để chạy

---

## 5. TEST CÁC CHỨC NĂNG

### 5.1 Test Đăng Nhập

| Test Case | Input | Expected Result |
|-----------|-------|-----------------|
| Đăng nhập đúng | Username: `SYSTEM`, Password: `YourStrongPassword123` | Vào màn hình chính |
| Đăng nhập sai password | Username: `SYSTEM`, Password: `wrong` | Thông báo lỗi |
| Username trống | Username: ``, Password: `abc` | Thông báo "Vui lòng nhập tên đăng nhập" |
| Đăng nhập user thường | Username: `TEST_USER`, Password: `Test123456` | Vào màn hình chính (quyền hạn chế) |

### 5.2 Test Quản Lý User (Đăng nhập với SYSTEM)

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Xem danh sách Users | Menu → Quản lý User → Danh sách User | Hiển thị DataGridView với các users |
| Tìm kiếm User | Nhập "TEST" vào ô tìm kiếm | Lọc hiển thị users có chứa "TEST" |
| Lock User | Click chuột phải → Khóa/Mở khóa | User bị khóa, Account Status = LOCKED |
| Unlock User | Click chuột phải → Khóa/Mở khóa | User được mở khóa |
| Xóa User | Click chuột phải → Xóa → Xác nhận | User bị xóa khỏi database |

### 5.3 Test Quản Lý Role

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Xem danh sách Roles | Menu → Quản lý Role → Danh sách Role | Hiển thị các Roles trong hệ thống |
| Xem Privileges của Role | Click chuột phải → Xem Privileges | Hiển thị popup với danh sách privileges |
| Xem Grantees của Role | Click chuột phải → Xem Grantees | Hiển thị popup với danh sách users được gán role |

### 5.4 Test Quản Lý Profile

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Xem danh sách Profiles | Menu → Quản lý Profile → Danh sách Profile | Hiển thị các Profiles |
| Xem Resources | Click chuột phải → Xem Resources | Hiển thị SESSIONS_PER_USER, CONNECT_TIME, IDLE_TIME |
| Xem Users | Click chuột phải → Xem Users | Hiển thị users sử dụng profile đó |

### 5.5 Test Quản Lý Quyền

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Xem System Privileges | Menu → Quản lý Quyền → System Privileges | Hiển thị các privileges đã grant |
| Tìm kiếm Privilege | Nhập vào ô tìm kiếm | Lọc theo privilege hoặc grantee |
| Revoke Privilege | Click chuột phải → Revoke → Xác nhận | Thu hồi quyền thành công |

### 5.6 Test Thông Tin Bổ Sung

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Xem danh sách | Menu → Thông tin bổ sung | Hiển thị thông tin cá nhân |
| Tìm kiếm | Nhập tên hoặc username | Lọc kết quả |

### 5.7 Test Đăng Xuất

| Test Case | Steps | Expected Result |
|-----------|-------|-----------------|
| Đăng xuất | Menu → Hệ thống → Đăng xuất | Quay về màn hình đăng nhập |
| Thoát | Menu → Hệ thống → Thoát | Đóng ứng dụng |

---

## 6. TROUBLESHOOTING

### Lỗi: "Không thể kết nối Oracle"

**Nguyên nhân:** Container chưa chạy hoặc Oracle chưa sẵn sàng

**Giải pháp:**

```powershell
# Kiểm tra container
docker ps

# Nếu không thấy, start lại
docker-compose up -d

# Xem logs
docker logs oracle-23ai
```

### Lỗi: "ORA-01017: invalid username/password"

**Nguyên nhân:** Sai mật khẩu

**Giải pháp:** Kiểm tra `appsettings.json` có đúng password `YourStrongPassword123`

### Lỗi: "ORA-12514: TNS:listener does not currently know of service"

**Nguyên nhân:** Service name sai

**Giải pháp:**

```powershell
# Kiểm tra service name
docker exec -it oracle-23ai lsnrctl status
```

Thử các service names: `FREEPDB1`, `FREE`, `XEPDB1`

### Lỗi: "Cannot find Oracle.ManagedDataAccess.dll"

**Giải pháp:**

```powershell
dotnet restore
dotnet build
```

### Lỗi: Docker image pull failed

**Giải pháp:** Đăng nhập Oracle Container Registry

```powershell
docker login container-registry.oracle.com
# Nhập username/password Oracle account
```

---

## 📝 CHECKLIST TEST HOÀN THÀNH

- [ ] Docker Desktop đang chạy
- [ ] Oracle container đã start và READY
- [ ] Database schema đã tạo
- [ ] Test đăng nhập SYSTEM thành công
- [ ] Test đăng nhập user thường thành công
- [ ] Test xem danh sách Users
- [ ] Test Lock/Unlock User
- [ ] Test xem danh sách Roles
- [ ] Test xem danh sách Profiles
- [ ] Test xem System Privileges
- [ ] Test xem thông tin bổ sung
- [ ] Test đăng xuất

---

## ⚡ QUICK START (TÓM TẮT NHANH)

```powershell
# 1. Mở Docker Desktop

# 2. Start Oracle
cd c:\Users\ADMIN\source\repos\UserManager\UserManager
docker-compose up -d

# 3. Đợi Oracle ready (xem logs)
docker logs -f oracle-23ai
# (Đợi thấy "DATABASE IS READY TO USE!", rồi Ctrl+C)

# 4. Chạy app
cd ..
dotnet run --project UserManager

# 5. Đăng nhập
# Username: SYSTEM
# Password: YourStrongPassword123
```

---

**Chúc bạn test thành công! 🎉**
