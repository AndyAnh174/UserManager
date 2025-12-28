# 📋 HƯỚNG DẪN TEST ỨNG DỤNG QUẢN LÝ USER ORACLE

## 📌 Mục lục
1. [Chuẩn bị](#chuẩn-bị)
2. [Test Đăng nhập](#1-test-đăng-nhập)
3. [Test Quản lý User](#2-test-quản-lý-user)
4. [Test Quản lý Role](#3-test-quản-lý-role)
5. [Test Quản lý Profile](#4-test-quản-lý-profile)
6. [Test Quản lý Quyền](#5-test-quản-lý-quyền)
7. [Test Báo cáo](#6-test-báo-cáo)
8. [Test Thông tin bổ sung](#7-test-thông-tin-bổ-sung)

---

## Chuẩn bị

### Bước 1: Khởi động Oracle Database
```powershell
docker start oracle-23ai
```

### Bước 2: Chạy ứng dụng
```powershell
cd c:\Users\ADMIN\source\repos\UserManager
dotnet run --project UserManager
```

### Bước 3: Chuẩn bị tài khoản test
- **Admin:** `SYSTEM` / `YourStrongPassword123`
- **Test User:** Sẽ tạo trong quá trình test

---

## 1. TEST ĐĂNG NHẬP

### Test 1.1: Đăng nhập thành công với SYSTEM
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Nhập Username: `SYSTEM` | - |
| 2 | Nhập Password: `YourStrongPassword123` | - |
| 3 | Click nút **Đăng nhập** | ✅ Chuyển sang MainForm, hiển thị "SYSTEM" trên title |

### Test 1.2: Đăng nhập thất bại - sai mật khẩu
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Nhập Username: `SYSTEM` | - |
| 2 | Nhập Password: `wrongpassword` | - |
| 3 | Click nút **Đăng nhập** | ✅ Hiển thị thông báo lỗi |

### Test 1.3: Đăng nhập thất bại - để trống
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Để trống Username và Password | - |
| 2 | Click nút **Đăng nhập** | ✅ Hiển thị cảnh báo "Vui lòng nhập..." |

---

## 2. TEST QUẢN LÝ USER

### Test 2.1: Xem danh sách User
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Click menu **Quản lý User** → **Danh sách User** | ✅ Hiển thị bảng danh sách Users |
| 2 | Kiểm tra các cột | ✅ Có: Username, Status, Created Date, Tablespace, Profile |

### Test 2.2: Thêm User mới
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Click menu **Quản lý User** → **Thêm User mới** | ✅ Mở form "Thêm User Mới" |
| 2 | Tab "Tài khoản Oracle": | - |
| 3 | - Username: `TESTUSER01` | - |
| 4 | - Mật khẩu: `Password123!` | - |
| 5 | - Xác nhận mật khẩu: `Password123!` | - |
| 6 | - Default Tablespace: `USERS` | - |
| 7 | - Temp Tablespace: `TEMP` | - |
| 8 | - Profile: `DEFAULT` | - |
| 9 | - Quota: `UNLIMITED` | - |
| 10 | - Role: Chọn role (nếu có) | - |
| 11 | Tab "Thông tin cá nhân": | - |
| 12 | - Họ tên: `Nguyễn Văn Test` | - |
| 13 | - Email: `test@email.com` | - |
| 14 | - Số điện thoại: `0901234567` | - |
| 15 | Click nút **Lưu** | ✅ Thông báo "Tạo User thành công!" |
| 16 | Kiểm tra danh sách | ✅ User `TESTUSER01` xuất hiện trong danh sách |

### Test 2.3: Thêm User - Password không đủ mạnh
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Mở form Thêm User | - |
| 2 | Username: `TESTUSER02` | - |
| 3 | Mật khẩu: `123` (yếu) | - |
| 4 | Click **Lưu** | ✅ Thông báo lỗi về yêu cầu password |

### Test 2.4: Sửa User
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Trong danh sách User, click chọn `TESTUSER01` | - |
| 2 | Click nút **Sửa** hoặc Double-click | ✅ Mở form "Sửa User: TESTUSER01" |
| 3 | Thay đổi Profile hoặc Quota | - |
| 4 | Click **Lưu** | ✅ Thông báo "Cập nhật User thành công!" |

### Test 2.5: Lock/Unlock User
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Chọn user `TESTUSER01` trong danh sách | - |
| 2 | Click chuột phải → **Khóa User** | ✅ Thông báo "Khóa thành công" |
| 3 | Kiểm tra cột Status | ✅ Status = LOCKED |
| 4 | Click chuột phải → **Mở khóa User** | ✅ Status = OPEN |

### Test 2.6: Đổi mật khẩu User
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Chọn user `TESTUSER01` trong danh sách | - |
| 2 | Click chuột phải → **Đổi mật khẩu** | ✅ Mở form "Đổi Mật Khẩu" |
| 3 | Nhập mật khẩu mới: `NewPassword123!` | - |
| 4 | Xác nhận: `NewPassword123!` | - |
| 5 | Click **Lưu** | ✅ Thông báo "Đổi mật khẩu thành công!" |

### Test 2.7: Xóa User
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Chọn user `TESTUSER01` trong danh sách | - |
| 2 | Click chuột phải → **Xóa** | ✅ Hiện hộp thoại xác nhận |
| 3 | Click **Yes** | ✅ Thông báo "Xóa thành công" |
| 4 | Kiểm tra danh sách | ✅ User đã biến mất |

---

## 3. TEST QUẢN LÝ ROLE

### Test 3.1: Xem danh sách Role
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Click menu **Quản lý Role** → **Danh sách Role** | ✅ Hiển thị bảng danh sách Roles |
| 2 | Kiểm tra các cột | ✅ Có: Role Name, Password Required, Authentication Type |

### Test 3.2: Thêm Role không có password
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Click menu **Quản lý Role** → **Thêm Role mới** | ✅ Mở form "Thêm Role Mới" |
| 2 | Tên Role: `TESTROLE01` | - |
| 3 | Bỏ check "Role có mật khẩu" | - |
| 4 | Click **Lưu** | ✅ Thông báo "Tạo Role thành công!" |
| 5 | Kiểm tra danh sách | ✅ Role `TESTROLE01` xuất hiện, PASSWORD_REQUIRED = NO |

### Test 3.3: Thêm Role có password
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Mở form Thêm Role | - |
| 2 | Tên Role: `TESTROLE02` | - |
| 3 | Check "Role có mật khẩu" | ✅ Các ô mật khẩu được enable |
| 4 | Mật khẩu: `RolePass123!` | - |
| 5 | Xác nhận: `RolePass123!` | - |
| 6 | Click **Lưu** | ✅ Thông báo "Tạo Role thành công!" |
| 7 | Kiểm tra danh sách | ✅ PASSWORD_REQUIRED = YES |

### Test 3.4: Xóa Role
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Chọn role `TESTROLE02` | - |
| 2 | Click chuột phải → **Xóa** | ✅ Hộp thoại xác nhận |
| 3 | Click **Yes** | ✅ Thông báo "Xóa thành công" |

---

## 4. TEST QUẢN LÝ PROFILE

### Test 4.1: Xem danh sách Profile
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Click menu **Quản lý Profile** → **Danh sách Profile** | ✅ Hiển thị bảng Profiles |
| 2 | Kiểm tra | ✅ Có profile `DEFAULT` |

### Test 4.2: Thêm Profile mới
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Click menu **Quản lý Profile** → **Thêm Profile mới** | ✅ Mở form |
| 2 | Tên Profile: `TESTPROFILE01` | - |
| 3 | Sessions Per User: `5` | - |
| 4 | Connect Time: `60` | - |
| 5 | Idle Time: `15` | - |
| 6 | Click **Lưu** | ✅ Thông báo "Tạo Profile thành công!" |

### Test 4.3: Sửa Profile
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Chọn profile `TESTPROFILE01` | - |
| 2 | Click **Sửa** | ✅ Mở form sửa |
| 3 | Thay đổi Idle Time: `30` | - |
| 4 | Click **Lưu** | ✅ Cập nhật thành công |

### Test 4.4: Xóa Profile
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Chọn profile `TESTPROFILE01` | - |
| 2 | Click chuột phải → **Xóa** | ✅ Xác nhận và xóa thành công |

---

## 5. TEST QUẢN LÝ QUYỀN

### Test 5.1: Xem System Privileges
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Click menu **Quản lý Quyền** → **System Privileges** | ✅ Hiển thị danh sách |
| 2 | Tìm kiếm user | ✅ Filter hoạt động |

### Test 5.2: Xem Object Privileges
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Click menu **Quản lý Quyền** → **Object Privileges** | ✅ Hiển thị danh sách |

### Test 5.3: Grant quyền cho User
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Tạo user test trước: `TESTGRANTUSER` | - |
| 2 | Click menu **Quản lý Quyền** → **Grant Quyền** | ✅ Mở form Grant |
| 3 | Tab "System Privilege": | - |
| 4 | - Chọn Privilege: `CREATE TABLE` | - |
| 5 | - Grantee: `TESTGRANTUSER` | - |
| 6 | Click **Grant** | ✅ Thông báo thành công |
| 7 | Kiểm tra System Privileges | ✅ User có CREATE TABLE |

### Test 5.4: Grant Role cho User
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Mở form Grant Quyền | - |
| 2 | Tab "Role": | - |
| 3 | - Chọn Role: `TESTROLE01` | - |
| 4 | - Grantee: `TESTGRANTUSER` | - |
| 5 | Click **Grant** | ✅ Thành công |

### Test 5.5: Revoke quyền
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Trong danh sách System Privileges | - |
| 2 | Tìm privilege của `TESTGRANTUSER` | - |
| 3 | Click chuột phải → **Revoke** | ✅ Xác nhận và revoke thành công |

---

## 6. TEST BÁO CÁO

### Test 6.1: Xem báo cáo User đầy đủ
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Click menu **Báo cáo** → **Thông tin User đầy đủ** | ✅ Mở UserReportControl |
| 2 | Chọn một User từ ComboBox | ✅ Hiển thị thông tin chi tiết |
| 3 | Kiểm tra các tab | ✅ Có: Thông tin cơ bản, Roles, Privileges, Quotas |

### Test 6.2: Export báo cáo
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Trong màn hình báo cáo User | - |
| 2 | Click nút **Export** | ✅ Lưu file thành công |

---

## 7. TEST THÔNG TIN BỔ SUNG

### Test 7.1: Xem danh sách thông tin cá nhân
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Click menu **Thông tin bổ sung** → **Danh sách thông tin cá nhân** | ✅ Hiển thị bảng |
| 2 | Kiểm tra các cột | ✅ Có: Username, Họ tên, Email, SĐT, Phòng ban |

### Test 7.2: Tìm kiếm thông tin
| Bước | Hành động | Kết quả mong đợi |
|------|-----------|------------------|
| 1 | Nhập tên vào ô tìm kiếm | - |
| 2 | Nhấn Enter hoặc click Search | ✅ Lọc đúng kết quả |

---

## 📊 BẢNG TỔNG HỢP TEST CASES

| # | Module | Test Case | Priority |
|---|--------|-----------|----------|
| 1 | Login | Đăng nhập thành công | HIGH |
| 2 | Login | Đăng nhập thất bại | HIGH |
| 3 | User | Xem danh sách | HIGH |
| 4 | User | Thêm user mới | HIGH |
| 5 | User | Sửa user | HIGH |
| 6 | User | Lock/Unlock | MEDIUM |
| 7 | User | Đổi mật khẩu | HIGH |
| 8 | User | Xóa user | HIGH |
| 9 | Role | Xem danh sách | HIGH |
| 10 | Role | Thêm role | HIGH |
| 11 | Role | Xóa role | MEDIUM |
| 12 | Profile | Xem danh sách | MEDIUM |
| 13 | Profile | Thêm profile | MEDIUM |
| 14 | Profile | Sửa profile | MEDIUM |
| 15 | Profile | Xóa profile | LOW |
| 16 | Privilege | Xem System Privs | HIGH |
| 17 | Privilege | Xem Object Privs | HIGH |
| 18 | Privilege | Grant quyền | HIGH |
| 19 | Privilege | Revoke quyền | MEDIUM |
| 20 | Report | Xem báo cáo User | MEDIUM |
| 21 | UserInfo | Xem danh sách | MEDIUM |

---

## ✅ CHECKLIST TEST

### Đăng nhập
- [ ] Đăng nhập thành công với SYSTEM
- [ ] Đăng nhập thất bại - sai password
- [ ] Đăng nhập thất bại - để trống

### Quản lý User
- [ ] Xem danh sách User
- [ ] Thêm User mới (đầy đủ thông tin)
- [ ] Thêm User - validation password
- [ ] Sửa User
- [ ] Lock User
- [ ] Unlock User
- [ ] Đổi mật khẩu
- [ ] Xóa User

### Quản lý Role
- [ ] Xem danh sách Role
- [ ] Thêm Role không password
- [ ] Thêm Role có password
- [ ] Xóa Role

### Quản lý Profile
- [ ] Xem danh sách Profile
- [ ] Thêm Profile
- [ ] Sửa Profile
- [ ] Xóa Profile

### Quản lý Quyền
- [ ] Xem System Privileges
- [ ] Xem Object Privileges
- [ ] Grant System Privilege
- [ ] Grant Role
- [ ] Revoke Privilege

### Báo cáo
- [ ] Xem báo cáo User đầy đủ
- [ ] Export báo cáo

### Thông tin bổ sung
- [ ] Xem danh sách thông tin cá nhân
- [ ] Tìm kiếm

---

## 🔧 XỬ LÝ LỖI THƯỜNG GẶP

| Lỗi | Nguyên nhân | Cách xử lý |
|-----|-------------|------------|
| ORA-01017: invalid username/password | Sai mật khẩu | Kiểm tra lại mật khẩu |
| ORA-28003: password verification | Password không đủ mạnh | Thêm chữ hoa, thường, số, ký tự đặc biệt |
| ORA-01031: insufficient privileges | Không có quyền | Đăng nhập bằng SYSTEM |
| ORA-00942: table does not exist | Chưa tạo bảng USER_INFO | Chạy script create_userinfo_table.sql |
| ORA-65066: container error | Lỗi CDB/PDB | Đảm bảo kết nối đúng FREEPDB1 |

---

## 📝 GHI CHÚ

1. **Thứ tự test:** Nên test theo thứ tự từ trên xuống
2. **Cleanup:** Sau khi test xong, xóa các test data
3. **Screenshot:** Chụp màn hình khi test pass để làm evidence

---

**Tạo bởi:** UserManager Application  
**Ngày:** 28/12/2024
