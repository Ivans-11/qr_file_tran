<div align="center">
  <img src="assets/logo.png" alt="QR-Link Logo" width="200"/>
</div>

[English](README_EN.md) | 中文

# QR-Link

一个基于 Flutter 开发的文件传输应用，通过二维码实现设备间的离线文件传输。目前仅支持 Android 平台。

## 开始使用

### 方式一：直接安装 APK

1. 从 [Releases](https://github.com/Ivans-11/qr_file_tran/releases) 页面下载最新版本的 APK 文件
2. 在 Android 设备上安装 APK 文件
3. 首次运行时，请确保授予应用所需的权限

### 方式二：从源码构建

1. 确保已安装 Flutter 开发环境
2. 克隆项目到本地
3. 运行以下命令安装依赖：
   ```bash
   flutter pub get
   ```
4. 运行应用：
   ```bash
   flutter run
   ```

## 使用说明

1. 发送文件：
   - 点击"选择文件"按钮选择要传输的文件或文件夹
   - 系统会自动处理文件并生成二维码序列
   - 接收方扫描二维码即可接收文件

2. 接收文件：
   - 点击"扫描"按钮，输入相应验证码
   - 使用相机扫描发送方显示的二维码
   - 文件将自动保存到设备存储中

## 权限说明

应用需要以下权限：
- 存储权限：用于读取和保存文件
- 相机权限：用于扫描二维码

## 注意事项

- 目前仅支持 Android 平台
- 建议使用 Android 10 及以上版本
- 首次使用请确保授予所有必要权限
