import 'dart:io';

import 'package:arche/arche.dart';
import 'package:cczu_helper/controllers/config.dart';
import 'package:cczu_helper/controllers/navigator.dart';
import 'package:cczu_helper/models/fields.dart';
import 'package:cczu_helper/models/translators.dart';
import 'package:cczu_helper/models/version.dart';
import 'package:cczu_helper/views/pages/checkupdate.dart';
import 'package:cczu_helper/views/pages/log.dart';
import 'package:cczu_helper/views/pages/login.dart';
import 'package:cczu_helper/views/pages/notifications.dart';
import 'package:cczu_helper/views/widgets/scrollable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  final GlobalKey<PopupMenuButtonState> _themeModeMenuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    ApplicationConfigs configs = ArcheBus.bus.of();
    return PaddingScrollView(
      child: Column(
        children: [
          const ListTile(
            title: Text("通用"),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.perm_identity),
                    title: const Text("账户"),
                    subtitle: const Text("Accounts"),
                    trailing: const Icon(Icons.arrow_right),
                    onTap: () {
                      pushMaterialRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: const Text("账户"),
                          ),
                          body: AccountLoginPage(
                            autoLogin: false,
                            callback: (context) => Navigator.of(context).pop(),
                          ),
                        ),
                      );
                    },
                  ),
                  Visibility(
                    visible: Platform.isAndroid,
                    child: ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text("课程表通知"),
                      subtitle: const Text("Notifications"),
                      trailing: const Icon(Icons.arrow_right),
                      onTap: () => pushMaterialRoute(
                        builder: (context) => const NotificationsPage(),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.update),
                    title: const Text("检查更新"),
                    subtitle: const Text("Check Update"),
                    trailing: const Icon(Icons.arrow_right),
                    onTap: () => pushMaterialRoute(
                      builder: (context) => const CheckUpdatePage(),
                    ),
                  )
                ],
              ),
            ),
          ),
          const ListTile(
            title: Text("外观"),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.color_lens),
                    title: const Text("主题"),
                    subtitle: const Text("Theme"),
                    onTap: () =>
                        _themeModeMenuKey.currentState?.showButtonMenu(),
                    trailing: IgnorePointer(
                      child: PopupMenuButton(
                        key: _themeModeMenuKey,
                        child: Text(thememodeTr
                            .translation(
                                configs.themeMode.getOr(ThemeMode.system))
                            .toString()),
                        itemBuilder: (context) => ThemeMode.values
                            .map(
                              (e) => PopupMenuItem(
                                child:
                                    Text(thememodeTr.translation(e).toString()),
                                onTap: () {
                                  setState(() {
                                    configs.themeMode.write(e);
                                  });
                                  rootKey.currentState?.refreshMounted();
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  SwitchListTile(
                      title: const Text("使用 Material 3"),
                      subtitle: const Text("Material You"),
                      secondary: const Icon(Icons.widgets),
                      value: configs.material3.getOr(true),
                      onChanged: (value) {
                        setState(() {
                          configs.material3.write(value);
                        });

                        rootKey.currentState?.refreshMounted();
                      }),
                  SwitchListTile(
                      title: const Text("使用系统字体"),
                      subtitle: const Text("System Font"),
                      secondary: const Icon(Icons.font_download),
                      value: configs.useSystemFont.getOr(true),
                      onChanged: (value) {
                        setState(() {
                          configs.useSystemFont.write(value);
                        });

                        rootKey.currentState?.refreshMounted();
                      }),
                  SwitchListTile(
                    title: const Text("显示导航栏"),
                    subtitle: const Text("Navigation Bar"),
                    secondary: const Icon(Icons.visibility),
                    value: configs.showBar.getOr(true),
                    onChanged: (value) {
                      setState(() {
                        configs.showBar.write(value);
                      });

                      viewKey.currentState?.refreshMounted();
                    },
                  ),
                ],
              ),
            ),
          ),
          const ListTile(
            title: Text("调试"),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Column(
                children: [
                  SwitchListTile(
                    value: configs.autosavelog.getOr(false),
                    secondary: const Icon(Icons.error),
                    title: const Text("自动保存错误日志"),
                    subtitle: const Text("Auto Save"),
                    onChanged: (value) {
                      setState(() {
                        configs.autosavelog.write(value);
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.book),
                    title: const Text("当前日志"),
                    subtitle: const Text("Current Logs"),
                    trailing: const Icon(Icons.arrow_right),
                    onTap: () => pushMaterialRoute(
                      builder: (context) => const LogPage(),
                    ),
                  )
                ],
              ),
            ),
          ),
          const ListTile(
            title: Text("关于"),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(FontAwesomeIcons.github),
                    title: const Text("开源地址"),
                    subtitle:
                        const Text("https://github.com/CCZU-OSSA/cczu-helper"),
                    onTap: () => launchUrlString(
                        "https://github.com/CCZU-OSSA/cczu-helper"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.chat),
                    title: const Text("QQ群"),
                    subtitle: const Text("947560153"),
                    onTap: () => launchUrlString(
                        "http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=6wgGLJ_NmKQl7f9Ws6JAprbTwmG9Ouei&authKey=g7bXX%2Bn2dHlbecf%2B8QfGJ15IFVOmEdGTJuoLYfviLg7TZIsZCu45sngzZfL3KktN&noverify=0&group_code=947560153"),
                  ),
                  ListTile(
                    leading: const Icon(Icons.library_books),
                    title: const Text("开源许可"),
                    subtitle: const Text("License"),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => AboutDialog(
                        applicationVersion: appVersion.format(),
                        applicationName: "吊大助手",
                        applicationLegalese: "copyright © 2023-2024 常州大学开源软件协会",
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                                "除第三方代码与资源（包括但不限于图片字体）保留原有协议外\n应用本身所有代码以及资源均使用GPLv3开源，请参照协议使用"),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
