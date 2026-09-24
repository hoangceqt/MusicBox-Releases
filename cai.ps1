# =========================================================================
#  MusicBox POS - CAI BANG MOT LENH
# =========================================================================
#
#   powershell -c "iex (irm https://raw.githubusercontent.com/hoangceqt/MusicBox-Releases/main/cai.ps1)"
#
# Tep nay ASCII thuan (LUAT 85): no duoc tai qua mang va chay bang `iex`,
# nen khong co cho nao dat BOM.
#
# ---- VI SAO SCRIPT NAY DOC `ban-cai.json` THAY VI GHIM SAN SO PHIEN BAN ----
#
# Ghim so phien ban vao day nghia la moi lan phat hanh phai sua script, va
# quen sua mot lan la lenh mot dong lang le cai lai ban CU. `ban-cai.json`
# da la nguon su that cua co che cap nhat o quan - doc chinh no thi lenh
# nay dung mai mai va khong bao gio ghim sai ban.
#
# ---- PHEP KIEM BAM KHONG DUOC BO ----
#
# Bo cai 176 MB tai qua mang thi tai thieu la chuyen thuong. Mot tep thieu
# vai MB VAN mo duoc va hong o giua - luc no da dung dich vu va dang di tru
# co so du lieu. Nen: bam truoc, chay sau. Bam lech thi XOA tep va dung
# han, khong hoi "co muon chay thu khong".
#
# Script nay KHONG bao ve duoc truoc viec kho GitHub bi chiem - ai sua duoc
# kho thi sua duoc ca `ban-cai.json` lan chuoi bam trong do. Doi lay mot
# lenh la phai tin kho ay, dung nhu khi tai bo cai tu chinh kho ay.
#
param(
  # Nguon: dia chi web (raw) hoac MOT THU MUC (USB, o mang). Thu muc thi
  # `tepCai` trong ban khai la ten tep tron, ghep vao chinh thu muc ay.
  [string]$Nguon = 'https://raw.githubusercontent.com/hoangceqt/MusicBox-Releases/main',
  # Chi tai va kiem bam, KHONG chay bo cai. Dung de do, va de tai san truoc
  # gio dong quan roi toi cai.
  [switch]$ChiTai
)
$ErrorActionPreference = 'Stop'

function Doi([string]$s) { $s -replace '/+$', '' }
$Nguon = Doi $Nguon
$tuWeb = $Nguon -match '^https?://'

Write-Host ''
Write-Host '=== MusicBox POS - cai bang mot lenh ==='
Write-Host "Nguon: $Nguon"

# --- 1 - Doc ban khai --------------------------------------------------
try {
  if ($tuWeb) {
    $khai = Invoke-RestMethod -Uri "$Nguon/ban-cai.json" -UseBasicParsing -TimeoutSec 60
  } else {
    $khai = Get-Content -Raw (Join-Path $Nguon 'ban-cai.json') | ConvertFrom-Json
  }
} catch {
  Write-Host "DUNG: khong doc duoc ban-cai.json tai nguon nay." -ForegroundColor Red
  Write-Host "      $($_.Exception.Message)"
  exit 1
}

$ban = [string]$khai.phienBan
$bamMongDoi = ([string]$khai.sha256).Trim().ToLower()
if (-not $ban -or $bamMongDoi.Length -ne 64) {
  Write-Host 'DUNG: ban-cai.json thieu phienBan hoac sha256 khong dung khuon 64 ky tu.' -ForegroundColor Red
  exit 1
}

Write-Host ''
Write-Host "Ban moi nhat : $ban   ($($khai.ngay))"
Write-Host "Ban di tru   : $($khai.soMigration)"
foreach ($g in @($khai.ghiChu)) { Write-Host "  - $g" }

# --- 2 - Tai (hoac chep) bo cai ---------------------------------------
$tenTep = Split-Path -Leaf ([string]$khai.tepCai)
$dich = Join-Path $env:TEMP $tenTep

# Xoa tep cu CUNG TEN truoc khi tai. Neu khong: mot lan tai do dang de lai
# tep ngan, va lan sau bam lech ma khong ai hieu vi sao.
if (Test-Path $dich) { Remove-Item $dich -Force }

Write-Host ''
Write-Host "Dang lay bo cai ($tenTep) ..."
try {
  if ([string]$khai.tepCai -match '^https?://') {
    # `curl.exe` co san tu Windows 10 1803, va nhanh hon Invoke-WebRequest
    # nhieu lan voi tep tram MB. Khong co thi lui ve Invoke-WebRequest.
    if (Get-Command curl.exe -ErrorAction SilentlyContinue) {
      & curl.exe -L --fail --progress-bar -o $dich ([string]$khai.tepCai)
      if ($LASTEXITCODE -ne 0) { throw "curl.exe tra ma thoat $LASTEXITCODE" }
    } else {
      $ProgressPreference = 'SilentlyContinue'
      Invoke-WebRequest -Uri ([string]$khai.tepCai) -OutFile $dich -UseBasicParsing
    }
  } else {
    Copy-Item (Join-Path $Nguon $tenTep) $dich -Force
  }
} catch {
  Write-Host 'DUNG: khong lay duoc bo cai.' -ForegroundColor Red
  Write-Host "      $($_.Exception.Message)"
  if (Test-Path $dich) { Remove-Item $dich -Force }
  exit 1
}

# --- 3 - Bam, TRUOC khi chay ------------------------------------------
$mb = [math]::Round((Get-Item $dich).Length / 1MB, 1)
Write-Host "Da lay: $dich ($mb MB)"
Write-Host 'Dang kiem ma bam SHA-256 ...'
$bamThat = (Get-FileHash $dich -Algorithm SHA256).Hash.ToLower()

if ($bamThat -ne $bamMongDoi) {
  # Xoa han. De lai mot tep hong trong TEMP la de lan sau co nguoi bam vao.
  Remove-Item $dich -Force
  Write-Host ''
  Write-Host 'DUNG: MA BAM KHONG KHOP - da xoa tep vua tai.' -ForegroundColor Red
  Write-Host "  mong doi : $bamMongDoi"
  Write-Host "  that     : $bamThat"
  Write-Host ''
  Write-Host '  Tai do dang, hoac tep tren nguon khong phai tep ma ban khai noi.'
  Write-Host '  Chay lai lenh nay. Van lech thi dung cai, bao lai.'
  exit 1
}
Write-Host "Ma bam KHOP: $bamThat" -ForegroundColor Green

if ($ChiTai) {
  Write-Host ''
  Write-Host 'Chi tai (-ChiTai): KHONG chay bo cai. Tep nam o:'
  Write-Host "  $dich"
  exit 0
}

# --- 4 - Chay bo cai --------------------------------------------------
#
# Bo cai khai `PrivilegesRequired=admin`, nen Windows tu hien hop UAC -
# script nay KHONG tu nang quyen, va co y the: nang quyen tu mot script
# vua tai tu mang la dung thu ma nguoi dung khong con thay minh dong y cai gi.
#
# Bo cai KHONG ky so (chu quan chot 15/09/2026) nen Windows con hien man
# xanh "Windows protected your PC" - noi truoc de khong ai tuong tep hong.
Write-Host ''
Write-Host 'Dang chay bo cai. Hai hop thoai sap hien, ca hai deu binh thuong:'
Write-Host '  1. "Windows protected your PC"  -> More info -> Run anyway'
Write-Host '     (bo cai nay khong ky so, do la quyet dinh cua chu quan)'
Write-Host '  2. Hop UAC xin quyen quan tri   -> Yes'
Write-Host ''
Write-Host 'Bo cai tu SAO LUU co so du lieu truoc khi di tru, va dung lai neu di tru hong.'
Write-Host ''

$tt = Start-Process -FilePath $dich -PassThru -Wait
$ma = $tt.ExitCode

Write-Host ''
if ($ma -eq 0) {
  Write-Host "XONG: da cai ban $ban." -ForegroundColor Green
} else {
  Write-Host "BO CAI TRA MA THOAT $ma - CHUA chac da cai xong." -ForegroundColor Red
  Write-Host 'Doc nhat ky cai trong %TEMP%\Setup Log*.txt roi bao lai.'
}
exit $ma
