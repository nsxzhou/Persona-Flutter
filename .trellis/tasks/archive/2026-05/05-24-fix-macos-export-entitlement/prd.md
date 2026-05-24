# 修复 macOS TXT 导出写入权限

## Goal

修复 macOS 上点击“导出 TXT”后出现 `PlatformException(ENTITLEMENT_REQUIRED_WRITE, The Read-Write entitlement is required for this action...)` 的问题。

## Requirements

* Debug/Profile 和 Release macOS entitlement 都允许用户选择文件的读写权限。
* 保留现有 sandbox、网络和 JIT 配置。
* 不改 TXT 导出业务逻辑。

## Acceptance Criteria

* [ ] `macos/Runner/DebugProfile.entitlements` 包含 `com.apple.security.files.user-selected.read-write`。
* [ ] `macos/Runner/Release.entitlements` 包含 `com.apple.security.files.user-selected.read-write`。
* [ ] 移除或替换 read-only entitlement，避免权限语义冲突。
* [ ] `flutter analyze` 通过。

## Technical Notes

* 当前失败来自 macOS sandbox 权限，`file_picker.saveFile` 写入用户选择路径需要 read-write entitlement。
* 修改 entitlement 后需要重新构建/重启 macOS app 才会生效。
