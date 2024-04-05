#!/bin/sh

# Exit immediately if any command exits with non-zero exit status.
set -e

# Kiểm tra xem Termux đã cài đặt `unzip` chưa
if ! command -v unzip >/dev/null; then
	echo 'err: `unzip` is required to install Rush. Please install it and try again.'
	exit 1
fi

# Thiết lập biến môi trường RUSH_HOME
if [[ -v RUSH_HOME ]]; then
  rushHome="$RUSH_HOME"
else
  rushHome="$HOME/.rush"
fi

# Xác định target dựa trên hệ điều hành
case $(uname -sm) in
"Darwin x86_64") target="x86_64-apple-darwin" ;;
"Darwin arm64") target="arm64-apple-darwin" ;;
*) target="x86_64-linux" ;;
esac

# Xác định URL của file zip dựa trên target
zipUrl="https://github.com/shreyashsaitwal/rush-cli/releases/latest/download/rush-$target.zip"

# Tải và giải nén file zip
curl --location --progress-bar -o "$rushHome/rush-$target.zip" "$zipUrl"
unzip -oq "$rushHome/rush-$target.zip" -d "$rushHome"/
rm "$rushHome/rush-$target.zip"

# Đặt quyền thực thi cho tệp binary của Rush
chmod +x "$rushHome/bin/rush"

# Hiển thị thông báo cài đặt thành công
echo
echo "Successfully downloaded the Rush CLI binary at $rushHome/bin/rush"

# Hỏi người dùng có muốn tải các thư viện Java cần thiết không
echo "Now, proceeding to download necessary Java libraries (approx size: 170 MB)."
read -p "Do you want to continue? (Y/n) " -n 1 -r
echo

# Tải các thư viện Java nếu người dùng chọn tiếp tục
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
  "$rushHome/bin/rush" deps sync --dev-deps --no-logo
fi

# Hiển thị thông báo cài đặt thành công
echo
echo "Success! Installed Rush at $rushHome/bin/rush"

# Thêm đoạn mã vào profile của Termux
echo
echo "Now, add the following to your ~/.bashrc (or similar):"
echo "export PATH=\"\$PATH:$rushHome/bin\""

echo
echo 'Run `rush --help` to get started.'
