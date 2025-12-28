# 📚 Bài Tập Lớn - BẢO MẬT CƠ SỞ DỮ LIỆU

## 📋 1. Thông Tin Chung

| Mục | Nội dung |
|-----|----------|
| **Môn học** | Bảo mật Cơ sở dữ liệu |
| **Hình thức** | Bài tập lớn theo nhóm (3-4 sinh viên) |
| **Hệ quản trị CSDL** | Oracle |
| **Ngôn ngữ lập trình** | C# WinForms |

---

## 🎯 2. Đề Tài: Xây Dựng Ứng Dụng Quản Lý Người Dùng (Đề 1)

**Mục tiêu:** Xây dựng một ứng dụng **WinForms** có chức năng quản lý người dùng trên Oracle Database.

---

### 🏗️ A. Kiến Trúc Hệ Thống

Ứng dụng phải được xây dựng theo **mô hình 3 lớp (3-Layer Architecture)**:

```
┌─────────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                        │
│         (WinForms UI - Passive MVP Pattern)                 │
│     • Nhận input từ user, hiển thị kết quả                  │
│     • Forms, Controls, DataGridView...                      │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    BUSINESS LAYER                           │
│              (Xử lý logic nghiệp vụ)                        │
│     • Validate dữ liệu                                      │
│     • Kiểm tra quyền hạn                                    │
│     • Xử lý các chức năng chính                             │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
│           (Truy xuất dữ liệu Oracle)                        │
│     • Kết nối Oracle DB                                     │
│     • Thực thi SQL/PL-SQL                                   │
│     • Truy vấn System Catalog                               │
└─────────────────────────────────────────────────────────────┘
```

---

### ⚙️ B. Các Chức Năng Yêu Cầu

#### 1️⃣ Đăng Nhập (Login)

- [ ] Form đăng nhập với Username và Password
- [ ] **Bắt buộc:** Áp dụng phương pháp mã hóa password (VD: SHA256, BCrypt...)

---

#### 2️⃣ Quản Lý User (CRUD)

| Thông tin | Mô tả |
|-----------|-------|
| `Username` | Tên đăng nhập |
| `Password` | Mật khẩu (đã mã hóa) |
| `Default_tablespace` | Tablespace mặc định (chọn từ danh sách có sẵn) |
| `Temporary_tablespace` | Tablespace tạm (chọn từ danh sách có sẵn) |
| `Quota` | Dung lượng được cấp |
| `Account Status` | Lock / Unlock |
| `Profile` | Profile được gán |
| `Role` | Role được gán |

> 📝 **Lưu ý:** Tablespace được tạo sẵn trên Oracle, admin chỉ việc gán, không cần làm chức năng tạo tablespace.

---

#### 3️⃣ Quản Lý Profile (CRUD)

Cho phép gán/thay đổi các **resource** sau:

| Resource | Giá trị |
|----------|---------|
| `SESSIONS_PER_USER` | Unlimited / Default / Số cụ thể |
| `CONNECT_TIME` | Unlimited / Default / Số cụ thể |
| `IDLE_TIME` | Unlimited / Default / Số cụ thể |

> 📝 **Lưu ý:** Chỉ cần thiết lập giá trị, ứng dụng không cần quản lý/chặn giới hạn khi user đăng nhập.

---

#### 4️⃣ Quản Lý Role (CRUD)

- [ ] Tạo role có hoặc không có password
- [ ] Cho phép thay đổi password của role (nếu có)

---

#### 5️⃣ Gán/Thu Hồi Quyền (Grant/Revoke)

Cho phép gán quyền cho **User** hoặc **Role**, kèm tùy chọn `WITH ADMIN OPTION` / `WITH GRANT OPTION`.

##### 🔐 Quyền Hệ Thống (System Privileges)

| Nhóm | Quyền |
|------|-------|
| **Profile** | `CREATE PROFILE`, `ALTER PROFILE`, `DROP PROFILE` |
| **Role** | `CREATE ROLE`, `ALTER ANY ROLE`, `DROP ANY ROLE`, `GRANT ANY ROLE` |
| **Session** | `CREATE SESSION` |
| **Table (ANY)** | `CREATE ANY TABLE`, `ALTER ANY TABLE`, `DROP ANY TABLE`, `SELECT ANY TABLE`, `DELETE ANY TABLE`, `INSERT ANY TABLE`, `UPDATE ANY TABLE` |
| **Table (Own)** | `CREATE TABLE` |
| **User** | `CREATE USER`, `ALTER USER`, `DROP USER` |

##### 📦 Quyền Đối Tượng (Object Privileges)

| Đối tượng | Quyền |
|-----------|-------|
| **Trên Table** | `SELECT`, `INSERT`, `DELETE` |
| **Trên Column** | `SELECT`, `INSERT` |

##### ✅ Cơ Chế Kiểm Tra Quyền

> ⚠️ **QUAN TRỌNG:** Ứng dụng **PHẢI kiểm tra** xem user có quyền tương ứng không trước khi cho phép thực hiện hành động.

---

## 📊 3. Yêu Cầu Hiển Thị Thông Tin

Ứng dụng cần truy xuất **System Catalog** của Oracle để hiển thị:

### 📋 Bảng 1: Quản Lý Quyền
- Liệt kê tất cả quyền và user nào đang giữ quyền đó

### 📋 Bảng 2: Quản Lý Role
- Liệt kê tất cả role
- Quyền của từng role
- User được gán role đó

### 📋 Bảng 3: Quản Lý Profile
- Liệt kê profile
- Các resource của profile
- User được gán profile

### 📋 Bảng 4: Quản Lý Thông Tin User

**Phân quyền xem:**
- 👑 **Admin:** Xem được tất cả user
- 👤 **User thường:** Chỉ xem được thông tin của chính mình

**Thông tin hiển thị:**

| Cột | Mô tả |
|-----|-------|
| Username | Tên đăng nhập |
| Account Status | Trạng thái tài khoản |
| Lock Date | Ngày bị khóa |
| Created Date | Ngày tạo |
| Default Tablespace | Tablespace mặc định |
| Temporary Tablespace | Tablespace tạm |
| Quota | Dung lượng |
| Profile | Profile được gán |
| Role | Role + có được gán tiếp không |
| Privilege | Quyền + nguồn gốc (trực tiếp/qua role) + có được cấp tiếp không |

### 📋 Bảng 5: Thông Tin Bổ Sung (Tự thiết kế)

Bảng do sinh viên tự thiết kế, chứa thông tin cá nhân:
- Họ tên
- Địa chỉ
- Số điện thoại
- Email
- ...

> 🎯 **Mục đích:** Demo chức năng gán quyền trên đối tượng (Object Privilege)

---

## 🗂️ Tổng Quan Chức Năng

```
📦 UserManager (WinForms C# + Oracle)
│
├── 🔐 Authentication
│   └── Login (với mã hóa password)
│
├── 👥 User Management
│   ├── Create User
│   ├── Edit User
│   ├── Delete User
│   ├── Lock/Unlock User
│   └── View User Info
│
├── 📋 Profile Management
│   ├── Create Profile
│   ├── Edit Profile (Resources)
│   └── Delete Profile
│
├── 🎭 Role Management
│   ├── Create Role (với/không password)
│   ├── Edit Role
│   └── Delete Role
│
├── 🔑 Privilege Management
│   ├── Grant System Privileges
│   ├── Grant Object Privileges
│   ├── Revoke Privileges
│   └── View All Privileges
│
└── 📊 Reports/Views
    ├── Bảng Quyền
    ├── Bảng Role
    ├── Bảng Profile
    ├── Bảng User Info
    └── Bảng Thông Tin Bổ Sung
```

---

## 🛠️ Công Nghệ Sử Dụng

| Thành phần | Công nghệ |
|------------|-----------|
| **Frontend** | C# WinForms (.NET Framework / .NET 8+) |
| **Database** | Oracle Database |
| **ORM/Data Access** | Oracle.ManagedDataAccess / ODP.NET |
| **Architecture** | 3-Layer + Passive MVP |
| **Security** | Password Hashing (SHA256/BCrypt) |

---