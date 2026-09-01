#include "flutter_window.h"

#include <commdlg.h>

#include <optional>
#include <string>
#include <vector>

#include "flutter/generated_plugin_registrant.h"
#include "utils.h"

namespace {

std::wstring Utf16FromUtf8(const std::string& utf8) {
  if (utf8.empty()) return std::wstring();
  const int length = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS,
                                         utf8.c_str(), -1, nullptr, 0);
  if (length <= 1) return std::wstring();
  std::wstring utf16(length, L'\0');
  MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, utf8.c_str(), -1,
                      utf16.data(), length);
  utf16.resize(length - 1);
  return utf16;
}

std::wstring BuildFilter(bool receipt_only) {
  std::wstring filter = receipt_only ? L"Receipt files" : L"Document files";
  filter.push_back(L'\0');
  filter += receipt_only ? L"*.pdf;*.png;*.jpg;*.jpeg"
                         : L"*.pdf;*.xlsx;*.xls;*.dwg;*.step;*.png;*.jpg;*.jpeg";
  filter.push_back(L'\0');
  filter += L"All files (*.*)";
  filter.push_back(L'\0');
  filter += L"*.*";
  filter.push_back(L'\0');
  filter.push_back(L'\0');
  return filter;
}

std::optional<std::string> ShowOpenDialog(HWND owner, bool receipt_only,
                                          DWORD* error_code) {
  std::vector<wchar_t> file_buffer(32768, L'\0');
  const std::wstring filter = BuildFilter(receipt_only);
  OPENFILENAMEW dialog = {};
  dialog.lStructSize = sizeof(dialog);
  dialog.hwndOwner = owner;
  dialog.lpstrFile = file_buffer.data();
  dialog.nMaxFile = static_cast<DWORD>(file_buffer.size());
  dialog.lpstrFilter = filter.c_str();
  dialog.nFilterIndex = 1;
  dialog.Flags = OFN_EXPLORER | OFN_FILEMUSTEXIST | OFN_PATHMUSTEXIST |
                 OFN_NOCHANGEDIR;
  if (GetOpenFileNameW(&dialog)) {
    *error_code = 0;
    return Utf8FromUtf16(file_buffer.data());
  }
  *error_code = CommDlgExtendedError();
  return std::nullopt;
}

std::optional<std::string> ShowSaveDialog(HWND owner,
                                          const std::string& suggested_name,
                                          DWORD* error_code) {
  std::vector<wchar_t> file_buffer(32768, L'\0');
  const std::wstring file_name = Utf16FromUtf8(suggested_name);
  if (!file_name.empty()) {
    wcsncpy_s(file_buffer.data(), file_buffer.size(), file_name.c_str(),
              _TRUNCATE);
  }
  const bool is_xlsx = suggested_name.size() >= 5 &&
                       suggested_name.substr(suggested_name.size() - 5) ==
                           ".xlsx";
  std::wstring filter =
      is_xlsx ? L"Excel Workbook (*.xlsx)" : L"All files (*.*)";
  filter.push_back(L'\0');
  filter += is_xlsx ? L"*.xlsx" : L"*.*";
  filter.push_back(L'\0');
  filter.push_back(L'\0');
  const wchar_t* default_extension = is_xlsx ? L"xlsx" : nullptr;

  OPENFILENAMEW dialog = {};
  dialog.lStructSize = sizeof(dialog);
  dialog.hwndOwner = owner;
  dialog.lpstrFile = file_buffer.data();
  dialog.nMaxFile = static_cast<DWORD>(file_buffer.size());
  dialog.lpstrFilter = filter.c_str();
  dialog.lpstrDefExt = default_extension;
  dialog.nFilterIndex = 1;
  dialog.Flags = OFN_EXPLORER | OFN_OVERWRITEPROMPT | OFN_PATHMUSTEXIST |
                 OFN_NOCHANGEDIR;
  if (GetSaveFileNameW(&dialog)) {
    *error_code = 0;
    return Utf8FromUtf16(file_buffer.data());
  }
  *error_code = CommDlgExtendedError();
  return std::nullopt;
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  file_dialog_channel_ = std::make_unique<
      flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "robin_portal/file_dialog",
      &flutter::StandardMethodCodec::GetInstance());
  file_dialog_channel_->SetMethodCallHandler(
      [this](const auto& call, auto result) {
        if (call.method_name() == "openFile") {
          bool receipt_only = false;
          if (const auto* arguments =
                  std::get_if<flutter::EncodableMap>(call.arguments())) {
            const auto entry = arguments->find(
                flutter::EncodableValue("receiptOnly"));
            if (entry != arguments->end()) {
              if (const auto* value = std::get_if<bool>(&entry->second)) {
                receipt_only = *value;
              }
            }
          }
          DWORD error_code = 0;
          const auto path =
              ShowOpenDialog(GetHandle(), receipt_only, &error_code);
          if (path.has_value()) {
            result->Success(flutter::EncodableValue(path.value()));
          } else if (error_code == 0) {
            result->Success(flutter::EncodableValue());
          } else {
            result->Error("OPEN_DIALOG_FAILED",
                          "Unable to open the Windows file dialog.",
                          flutter::EncodableValue(
                              static_cast<int>(error_code)));
          }
          return;
        }
        if (call.method_name() == "saveFile") {
          std::string suggested_name = "ROBIN_file";
          if (const auto* arguments =
                  std::get_if<flutter::EncodableMap>(call.arguments())) {
            const auto entry = arguments->find(
                flutter::EncodableValue("suggestedName"));
            if (entry != arguments->end()) {
              if (const auto* value =
                      std::get_if<std::string>(&entry->second)) {
                suggested_name = *value;
              }
            }
          }
          DWORD error_code = 0;
          const auto path =
              ShowSaveDialog(GetHandle(), suggested_name, &error_code);
          if (path.has_value()) {
            result->Success(flutter::EncodableValue(path.value()));
          } else if (error_code == 0) {
            result->Success(flutter::EncodableValue());
          } else {
            result->Error("SAVE_DIALOG_FAILED",
                          "Unable to open the Windows save dialog.",
                          flutter::EncodableValue(
                              static_cast<int>(error_code)));
          }
          return;
        }
        result->NotImplemented();
      });
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  file_dialog_channel_.reset();
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
