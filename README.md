# MusicBox POS — Kho phát hành

Kho này chứa **bộ cài chính thức** của phần mềm MusicBox POS và bản khai
`ban-cai.json` mà phần mềm ở quán đọc để biết có bản mới hay không.

Đây **không phải** kho mã nguồn.

## Cài bằng một lệnh

Mở `cmd` rồi dán nguyên văn:

```
powershell -c "iex (irm https://raw.githubusercontent.com/hoangceqt/MusicBox-Releases/main/cai.ps1)"
```

Lệnh này **không ghim phiên bản**: nó đọc `ban-cai.json` trong kho này, nên luôn
cài đúng bản mới nhất. Nó **băm SHA-256 và so với bản khai trước khi chạy** bộ
cài; lệch thì xoá tệp và dừng, không hỏi lại.

Không có mạng thì chép `ban-cai.json` + bộ cài `.exe` vào một thư mục rồi:

```
powershell -File cai.ps1 -Nguon D:\MusicBox
```

Thêm `-ChiTai` nếu chỉ muốn tải sẵn và kiểm băm, chưa cài.

> Lệnh một dòng tải script từ kho này rồi chạy ngay — tức **tin kho này hoàn
> toàn**. Phép băm chặn được **tải lỗi**, không chặn được **kho bị chiếm**. Mức
> tin cậy đúng bằng mức khi tải bộ cài từ chính kho này. Ai không muốn đánh đổi
> thế thì tải tay theo `INSTALL_GUIDE.md` và tự chạy `certutil -hashfile`.

## Máy ở quán khai gì

Vào **Cấu hình → Cập nhật phần mềm → Nguồn cập nhật**, điền:

```
https://raw.githubusercontent.com/hoangceqt/MusicBox-Releases/main
```

Sau đó bấm **Tải về** khi có mạng. Việc tải **không dừng gì cả** — quán vẫn bán
bình thường trong lúc tải. Chỉ khi chạy bộ cài mới cần đóng phần mềm.

Quán không có internet thì chép **hai tệp** dưới đây vào một thư mục trên USB và
khai đường thư mục ấy thay cho địa chỉ web:

- `ban-cai.json`
- bộ cài `.exe` của bản mới nhất (tải ở mục **Releases**)

## `ban-cai.json` có gì

| trường | nghĩa |
|---|---|
| `phienBan` | ba số, **chỉ tăng** |
| `soMigration` | số bản di trú — máy quán dùng để biết bản này có đụng cơ sở dữ liệu không |
| `tepCai` | địa chỉ bộ cài |
| `sha256` | mã băm của bộ cài |
| `ghiChu` | các dòng người ở quán đọc trên màn cập nhật |

**Máy quán tự kiểm mã băm trước khi nhận.** Băm không khớp thì nó **bỏ tệp** và
nói rõ ra, chứ không chạy một bộ cài tải thiếu.

## Cập nhật có an toàn không

Bộ cài **tự sao lưu cơ sở dữ liệu trước khi di trú**, và nếu di trú hỏng thì nó
**dừng lại** chứ không sửa liều — bản sao lưu nằm trong thư mục `backups` của
máy. Nó cũng **giữ lại một bản của chính nó** trong `bo-cai-da-dung`, nên lần
sau còn đường lùi.

Muốn lùi về bản cũ: chạy `tools\restore.ps1` để đưa cơ sở dữ liệu về bản sao lưu,
rồi cài lại bộ cài cũ trong `bo-cai-da-dung`. **Phải làm cả hai** — cài lại mã cũ
mà không khôi phục dữ liệu là bản cũ gặp bảng đã đổi và vỡ theo kiểu khó hiểu hơn.

## Không gõ tay `ban-cai.json`

Nó do `backend/scripts/phat-hanh.js` sinh ra từ sổ phát hành và từ chính tệp cài.
Gõ tay thì sớm muộn có một trường lệch — mã băm lệch thì máy quán bỏ tệp (thấy
ngay), còn số bản di trú lệch thì màn hình nói sai về việc bản này có đụng cơ sở
dữ liệu hay không (im lặng, và sai).
