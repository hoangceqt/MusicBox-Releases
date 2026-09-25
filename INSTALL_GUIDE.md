# 📘 HƯỚNG DẪN TRIỂN KHAI CÀI ĐẶT
## MusicBox Manager v1.0.0

**Tài liệu dành cho:** Kỹ thuật viên triển khai  
**Cập nhật lần cuối:** 11/05/2026

---

## Mục lục
1. [Yêu cầu hệ thống](#1-yêu-cầu-hệ-thống)
2. [Chuẩn bị trước cài đặt](#2-chuẩn-bị-trước-cài-đặt)
3. [Quy trình cài đặt](#3-quy-trình-cài-đặt)
4. [Xác nhận sau cài đặt](#4-xác-nhận-sau-cài-đặt)
5. [Thiết lập lần đầu (First-Run Wizard)](#5-thiết-lập-lần-đầu)
6. [Quản lý Services](#6-quản-lý-services)
7. [Sao lưu & Phục hồi](#7-sao-lưu--phục-hồi)
8. [Cập nhật phần mềm](#8-cập-nhật-phần-mềm)
9. [Gỡ cài đặt](#9-gỡ-cài-đặt)
10. [Xử lý sự cố](#10-xử-lý-sự-cố)
11. [Thông tin kỹ thuật](#11-thông-tin-kỹ-thuật)

---

## 1. Yêu cầu hệ thống

### Phần cứng tối thiểu

| Thành phần | Tối thiểu | Khuyến nghị |
|---|---|---|
| CPU | 1 Core | 2+ Cores |
| RAM | 1 GB | 4 GB |
| Ổ đĩa | 20 GB SSD | 50 GB SSD |
| Mạng | LAN 100Mbps | LAN 1Gbps |

### Phần mềm

| Thành phần | Yêu cầu |
|---|---|
| Hệ điều hành | Windows 10 (x64), Windows 11, hoặc Windows Server 2019+ |
| Kiến trúc | x64 only |
| Quyền | **Administrator** (bắt buộc) |

> [!NOTE]
> **Không cần cài đặt trước:** Node.js, PostgreSQL, hoặc bất kỳ phần mềm phụ thuộc nào. Tất cả đã được đóng gói sẵn trong installer.

---

## 2. Chuẩn bị trước cài đặt

### 2.1 Checklist trước cài đặt

- [ ] Máy tính đáp ứng yêu cầu phần cứng
- [ ] Đăng nhập với tài khoản **Administrator**
- [ ] Các port chưa bị sử dụng: `3000`, `5432`, `1883`
- [ ] Chuẩn bị sẵn thông tin:
  - Tên cửa hàng
  - Địa chỉ
  - Email admin
  - Mật khẩu admin (tối thiểu 6 ký tự)
- [ ] Tắt tạm Windows Defender Real-Time Protection (nếu cài đặt bị chặn)

### 2.2 Kiểm tra port

Mở **PowerShell (Admin)** và chạy:

```powershell
# Kiểm tra port 3000, 5432, 1883 có đang bị sử dụng không
@(3000, 5432, 1883) | ForEach-Object {
    $conn = Get-NetTCPConnection -LocalPort $_ -ErrorAction SilentlyContinue
    if ($conn) { Write-Host "⚠️ Port $_ đang bị sử dụng bởi PID $($conn.OwningProcess[0])" -ForegroundColor Yellow }
    else { Write-Host "✅ Port $_ — Trống" -ForegroundColor Green }
}
```

Nếu port đã bị chiếm, ghi nhớ để nhập port khác trong bước cấu hình.

---

## 3. Quy trình cài đặt

### Bước 1: Chạy Installer

1. Click phải vào file `MusicBox-Manager-Setup-1.0.0.exe`
2. Chọn **"Run as administrator"**
3. Nếu Windows SmartScreen xuất hiện → Click **"More info"** → **"Run anyway"**

### Bước 2: Chọn thư mục cài đặt

- **Mặc định:** `C:\MusicBox`
- Có thể thay đổi bằng nút Browse
- **Yêu cầu:** Ít nhất 2 GB trống

> [!WARNING]
> Tránh đường dẫn chứa dấu tiếng Việt hoặc khoảng trắng quá dài. Khuyến nghị dùng đường dẫn mặc định.

### Bước 3: Cấu hình Port

| Port | Mặc định | Dịch vụ |
|---|---|---|
| Backend API | `3000` | NestJS Backend |
| PostgreSQL | `5432` | Database |
| MQTT Broker | `1883` | Thiết bị IoT |

- Nhập port trong khoảng **1024 – 65535**
- Nếu port mặc định bị chiếm → nhập port khác (VD: 3001, 5433, 1884)

### Bước 4: Tạo tài khoản Admin

| Trường | Yêu cầu | Ví dụ |
|---|---|---|
| Họ và tên | Bắt buộc | Nguyễn Văn Quản Lý |
| Email | Bắt buộc (có @) | admin@quankaraoke.com |
| Mật khẩu | Tối thiểu 6 ký tự | ******** |

> [!IMPORTANT]
> **Ghi nhớ email và mật khẩu này!** Đây là tài khoản duy nhất có quyền Super Admin. Không thể khôi phục nếu mất.

### Bước 5: Tùy chọn bổ sung

| Tùy chọn | Mặc định | Khuyến nghị |
|---|---|---|
| Tạo shortcut Desktop | ✅ Checked | Giữ nguyên |
| Mở Firewall | ✅ Checked | **Bắt buộc** nếu dùng LAN |
| Tự động khởi động khi boot | ⬜ Unchecked | ✅ Check cho máy sản xuất |
| Sao lưu tự động 3h sáng | ⬜ Unchecked | ✅ Khuyến nghị check |

### Bước 6: Xác nhận và Cài đặt

- Kiểm tra lại tất cả thông tin
- Click **"Cài đặt"** (Install)
- Quá trình tự động chạy 8 giai đoạn (~2 phút):

```
[1/8] Giải nén tập tin...
[2/8] Khởi tạo PostgreSQL...
[3/8] Tạo cơ sở dữ liệu...
[4/8] Chạy database migration...
[5/8] Nhập dữ liệu khởi tạo...
[6/8] Cài đặt Windows Services...
[7/8] Cấu hình Firewall...
[8/8] Tạo shortcuts...
```

### Bước 7: Hoàn tất

- ✅ Tick "Khởi động MusicBox Manager ngay" nếu muốn mở ngay
- Ghi nhận thông tin hiển thị trên màn hình hoàn tất

---

## 4. Xác nhận sau cài đặt

### 4.1 Kiểm tra Services

Mở **PowerShell (Admin)**:

```powershell
# Kiểm tra trạng thái services
Get-Service MusicBoxDB, MusicBoxAPI | Format-Table Name, DisplayName, Status -AutoSize
```

Kết quả mong đợi:
```
Name         DisplayName            Status
----         -----------            ------
MusicBoxDB   MusicBox PostgreSQL    Running
MusicBoxAPI  MusicBox Backend API   Running
```

### 4.2 Kiểm tra Firewall

```powershell
netsh advfirewall firewall show rule name="MusicBox API"
netsh advfirewall firewall show rule name="MusicBox Database"
netsh advfirewall firewall show rule name="MusicBox MQTT"
```

### 4.3 Kiểm tra API

```powershell
# Test API đang chạy
Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
```

### 4.4 Truy cập Frontend

Mở trình duyệt, truy cập:
- **Cùng máy:** `http://localhost:5173`
- **Từ LAN:** `http://<IP-máy-chủ>:5173`

> [!NOTE]
> Trong phiên bản này, frontend cần được khởi động riêng bằng `npm run dev` trong thư mục `frontend/` hoặc sử dụng Tauri desktop app (nếu đã build).

---

## 5. Thiết lập lần đầu

### 5.1 Đăng nhập

1. Mở browser → `http://localhost:5173`
2. Nhập email + mật khẩu admin đã tạo ở Bước 4
3. Click **"Đăng nhập"**

### 5.2 First-Run Wizard

Hệ thống tự động hiển thị **Wizard thiết lập** khi đăng nhập lần đầu:

| Bước | Nhập | Ghi chú |
|---|---|---|
| 1/5 | **Tên cửa hàng** | In trên hóa đơn, báo cáo |
| 2/5 | **Địa chỉ** | In trên hóa đơn |
| 3/5 | Số điện thoại + Logo | Tùy chọn |
| 4/5 | Múi giờ + Tiền tệ | Mặc định: VN (UTC+7), VND |
| 5/5 | **Xác nhận** | Review và hoàn tất |

Sau khi hoàn tất → chuyển tới Dashboard.

> [!TIP]
> Wizard chỉ hiển thị **một lần**. Sau đó có thể chỉnh sửa lại trong **Cài đặt → Cửa hàng**.

---

## 6. Quản lý Services

### 6.1 Khởi động / Dừng

```powershell
# Dừng tất cả
C:\MusicBox\tools\nssm.exe stop MusicBoxAPI
C:\MusicBox\tools\nssm.exe stop MusicBoxDB

# Khởi động (DB trước, API sau)
C:\MusicBox\tools\nssm.exe start MusicBoxDB
Start-Sleep -Seconds 3
C:\MusicBox\tools\nssm.exe start MusicBoxAPI
```

### 6.2 Restart nhanh

```powershell
C:\MusicBox\tools\nssm.exe restart MusicBoxAPI
```

### 6.3 Xem log

```powershell
# Log backend API
Get-Content "C:\MusicBox\logs\backend.log" -Tail 50

# Log PostgreSQL
Get-Content "C:\MusicBox\logs\postgres.log" -Tail 50

# Log cài đặt
Get-Content "C:\MusicBox\logs\install.log"
```

### 6.4 Cấu hình auto-start

```powershell
# Bật auto-start khi Windows boot
C:\MusicBox\tools\nssm.exe set MusicBoxDB Start SERVICE_AUTO_START
C:\MusicBox\tools\nssm.exe set MusicBoxAPI Start SERVICE_AUTO_START

# Tắt auto-start
C:\MusicBox\tools\nssm.exe set MusicBoxDB Start SERVICE_DEMAND_START
C:\MusicBox\tools\nssm.exe set MusicBoxAPI Start SERVICE_DEMAND_START
```

---

## 7. Sao lưu & Phục hồi

### 7.1 Sao lưu thủ công

```powershell
powershell -ExecutionPolicy Bypass -File "C:\MusicBox\tools\backup.ps1" -InstallDir "C:\MusicBox"
```

File backup lưu tại: `C:\MusicBox\backups\musicbox_YYYYMMDD_HHMMSS.sql`

### 7.2 Phục hồi từ backup

```powershell
powershell -ExecutionPolicy Bypass -File "C:\MusicBox\tools\restore.ps1" `
  -BackupFile "C:\MusicBox\backups\musicbox_20260511_030000.sql" `
  -InstallDir "C:\MusicBox"
```

> [!CAUTION]
> Phục hồi sẽ **GHI ĐÈ** toàn bộ dữ liệu hiện tại. Script sẽ hỏi xác nhận trước khi thực hiện.

### 7.3 Sao lưu tự động

Nếu chưa bật trong quá trình cài đặt:

```powershell
# Tạo scheduled task backup hàng ngày lúc 3h sáng
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
  -Argument '-ExecutionPolicy Bypass -File "C:\MusicBox\tools\backup.ps1" -InstallDir "C:\MusicBox"'
$trigger = New-ScheduledTaskTrigger -Daily -At "03:00"
Register-ScheduledTask -TaskName "MusicBox_SaoLuuHangNgay" -Action $action -Trigger $trigger -RunLevel Highest
```

> **Sửa 31/08/2026 — cái tên ở dòng trên trước đây là `"MusicBox Daily Backup"`.**
>
> Bảng điều khiển đi hỏi đúng chuỗi `MusicBox_SaoLuuHangNgay`
> (`bang-dieu-khien.py` → `TEN_TAC_VU_SAO_LUU`). Ai làm theo tài liệu này với cái
> tên cũ thì tác vụ **chạy thật lúc 3 giờ sáng**, mà bảng điều khiển báo
> **"chưa đăng ký"** mãi mãi — một việc, hai cái tên.
>
> Ngày 29/08 lỗi ấy đã được sửa trong `post-install.ps1` và `uninstall-services.ps1`,
> nhưng **không ai sửa tờ này** — đúng khuôn "gỡ đúng chỗ nổ, không gỡ cả lớp
> luật". Lưới `bo-cai.spec.ts` LUẬT 9 nay soi cả tài liệu.

---

## 8. Cập nhật phần mềm

> **Sửa 31/08/2026 — mục này trước đây chỉ sai đường.**
>
> Bản cũ bảo chạy `C:\MusicBox\tools\update.ps1 -UpdatePackage <gói>.zip`.
> Đo 29/08 và đo lại 31/08: **không tệp nào trong dự án dựng ra gói `.zip` ấy**
> (`Compress-Archive` không xuất hiện ở đâu trong kho). Nghĩa là mục 8 cũ mô tả
> một quy trình chưa từng chạy được, bằng giọng của một quy trình đã chạy.
>
> Chủ quán chốt: **gỡ `update.ps1` khỏi bộ cài.** Từ bản này trở đi thư mục
> `C:\MusicBox\tools\` **không còn tệp ấy**. Lưới `backend/src/health/bo-cai.spec.ts`
> (LUẬT 14) chặn việc đóng gói lại nó chừng nào chưa ai viết bộ dựng gói.

### 8.1 Đường cập nhật đang dùng

Cập nhật chạy từ một **bản checkout git**, không từ gói `.zip`:

```powershell
powershell -ExecutionPolicy Bypass -File "<thư-mục-kho>\CAP-NHAT.ps1"
```

Đường lùi khi cập nhật hỏng:

```powershell
powershell -ExecutionPolicy Bypass -File "<thư-mục-kho>\LUI-LAI.ps1"
```

Cả hai đã **diễn tập thật ngày 27/08/2026**, kể cả tình huống `npm ci` chết
giữa chừng để lại `node_modules` rỗng.

### 8.2 Máy cài bằng `setup.exe` thì cập nhật thế nào

Hôm nay: **cài đè bằng `setup.exe` phiên bản mới**. Bộ cài giữ nguyên
`backend\.env`, thư mục `pgsql\data` và `backups\`.

Muốn có đường cập nhật gọn hơn thì phải viết bộ dựng gói `.zip` trước — chưa ai
viết. Đừng dựa vào `update.ps1`.

> [!WARNING]
> **KHÔNG** cập nhật khi đang có khách sử dụng hệ thống. Nên cập nhật ngoài giờ kinh doanh.

---

## 9. Gỡ cài đặt

### 9.1 Qua Control Panel

1. **Settings → Apps → MusicBox Manager → Uninstall**
2. Installer tự động:
   - Dừng và xóa Windows Services
   - Xóa Firewall rules
   - Xóa Scheduled Tasks
   - Xóa toàn bộ thư mục cài đặt

### 9.2 Thủ công (nếu Control Panel lỗi)

```powershell
# Chạy script cleanup
powershell -ExecutionPolicy Bypass -File "C:\MusicBox\tools\uninstall-services.ps1" -InstallDir "C:\MusicBox"

# Xóa thư mục
Remove-Item "C:\MusicBox" -Recurse -Force
```

---

## 10. Xử lý sự cố

### 10.1 Không truy cập được giao diện

| Triệu chứng | Nguyên nhân | Giải pháp |
|---|---|---|
| `ERR_CONNECTION_REFUSED` | Backend chưa chạy | Kiểm tra service: `Get-Service MusicBoxAPI` |
| `ERR_CONNECTION_REFUSED` (LAN) | Firewall chặn | Kiểm tra: `netsh advfirewall firewall show rule name="MusicBox API"` |
| Trang trắng | Frontend lỗi | Kiểm tra Console (F12) |

### 10.2 Service không khởi động

```powershell
# Kiểm tra lỗi chi tiết
C:\MusicBox\tools\nssm.exe status MusicBoxDB
C:\MusicBox\tools\nssm.exe status MusicBoxAPI

# Xem log lỗi
Get-Content "C:\MusicBox\logs\backend.log" -Tail 20
Get-Content "C:\MusicBox\logs\postgres.log" -Tail 20
```

### 10.3 Lỗi database

```powershell
# Kiểm tra PostgreSQL có chạy không
C:\MusicBox\pgsql\bin\pg_isready.exe -p 5432

# Kiểm tra kết nối
C:\MusicBox\pgsql\bin\psql.exe -U postgres -p 5432 -d musicbox -c "SELECT 1"
```

### 10.4 Quên mật khẩu admin

```powershell
# Kết nối trực tiếp database và reset password
$dbPass = (Get-Content "C:\MusicBox\config.ini" | Where-Object { $_ -match "^password=" }) -replace "password=", ""
$env:PGPASSWORD = $dbPass
C:\MusicBox\pgsql\bin\psql.exe -U postgres -p 5432 -d musicbox -c "UPDATE \"User\" SET password = '<bcrypt-hash>' WHERE email = 'admin@example.com'"
```

> [!TIP]
> Liên hệ hỗ trợ kỹ thuật để nhận hash bcrypt mới, hoặc sử dụng script seed lại admin.

### 10.5 Windows Defender chặn installer

```powershell
# Tạm tắt Real-Time Protection
Set-MpPreference -DisableRealtimeMonitoring $true

# Sau khi cài xong, bật lại
Set-MpPreference -DisableRealtimeMonitoring $false
```

---

## 11. Thông tin kỹ thuật

### 11.1 Cấu trúc thư mục cài đặt

```
C:\MusicBox\
├── backend\
│   ├── dist\              # NestJS compiled (395 files, 1.3 MB)
│   ├── node_modules\      # Dependencies
│   ├── prisma\
│   │   ├── schema.prisma  # Database schema
│   │   └── migrations\    # Migration history
│   └── .env               # Cấu hình (auto-generated)
├── nodejs\
│   ├── node.exe           # Node.js v22.15.0 LTS
│   └── node_modules\      # npm
├── pgsql\
│   ├── bin\               # PostgreSQL 15.3 binaries
│   ├── data\              # Database data files
│   ├── lib\               # Libraries
│   └── share\             # Extensions
├── tools\
│   ├── nssm.exe           # Service manager
│   ├── backup.ps1
│   ├── restore.ps1
│   ├── repair.ps1
│   ├── seed-production.sql
│   └── uninstall-services.ps1
│                              # (update.ps1 CỐ Ý không còn — xem mục 8)
├── logs\
│   ├── install.log        # Log cài đặt
│   ├── backend.log        # Log API runtime
│   └── postgres.log       # Log database
├── backups\               # Thư mục backup tự động
├── config.ini             # Cấu hình master (ports, passwords)
└── VERSION                # Phiên bản hiện tại
```

### 11.2 File cấu hình

**`config.ini`** chứa tất cả cấu hình hệ thống:

```ini
[general]
version=1.0.0
install_dir=C:\MusicBox

[ports]
api=3000
database=5432
mqtt=1883

[database]
host=localhost
name=musicbox
user=postgres
password=<auto-generated>

[jwt]
secret=<auto-generated>
```

**`backend\.env`** — cấu hình NestJS (tự động tạo khi cài):

```env
DATABASE_URL="postgresql://postgres:<password>@localhost:<port>/musicbox?schema=public"
PORT=3000
JWT_SECRET="<auto-generated>"
NODE_ENV=production
MQTT_PORT=1883
```

### 11.3 Windows Services

| Service Name | Display Name | Port | Dependency |
|---|---|---|---|
| `MusicBoxDB` | MusicBox PostgreSQL | 5432 | — |
| `MusicBoxAPI` | MusicBox Backend API | 3000 | MusicBoxDB |

### 11.4 Firewall Rules

| Rule Name | Direction | Protocol | Port |
|---|---|---|---|
| MusicBox API | Inbound | TCP | 3000 |
| MusicBox Database | Inbound | TCP | 5432 |
| MusicBox MQTT | Inbound | TCP | 1883 |

---

> [!NOTE]
> **Liên hệ hỗ trợ kỹ thuật:**
> - Email: support@ongmap.vn
> - Tài liệu: Xem thêm trong thư mục `docs/` tại vị trí cài đặt
