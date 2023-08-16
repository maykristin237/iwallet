#ifndef FLUTTER_PLUGIN_WALLET_KIT_PLUGIN_H_
#define FLUTTER_PLUGIN_WALLET_KIT_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace wallet_kit {

class WalletKitPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  WalletKitPlugin();

  virtual ~WalletKitPlugin();

  // Disallow copy and assign.
  WalletKitPlugin(const WalletKitPlugin&) = delete;
  WalletKitPlugin& operator=(const WalletKitPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace wallet_kit

#endif  // FLUTTER_PLUGIN_WALLET_KIT_PLUGIN_H_
