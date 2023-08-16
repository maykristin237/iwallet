#include "include/wallet_kit/wallet_kit_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "wallet_kit_plugin.h"

void WalletKitPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  wallet_kit::WalletKitPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
