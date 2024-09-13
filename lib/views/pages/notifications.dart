import 'package:arche/arche.dart';
import 'package:arche/extensions/dialogs.dart';
import 'package:arche/extensions/io.dart';
import 'package:cczu_helper/controllers/config.dart';
import 'package:cczu_helper/controllers/scheduler.dart';
import 'package:cczu_helper/controllers/snackbar.dart';
import 'package:cczu_helper/views/pages/settings.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<StatefulWidget> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    ApplicationConfigs configs = ArcheBus().of();
    return Scaffold(
      appBar: AppBar(
        title: const Text("通知设置"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SettingGroup(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_on),
                title: const Text("启用通知"),
                subtitle: const Text("Enable Notifications"),
                value: configs.notificationsEnable.getOr(false),
                onChanged: (bool value) async {
                  if (value) {
                    Scheduler.requestAndroidPermission().then((value) async {
                      if (!value) {
                        if (mounted) {
                          showSnackBar(
                            context: this.context,
                            content: const Text("尚未生成课表"),
                          );
                        }

                        return;
                      }
                      var platdir = await platDirectory.getValue();
                      platdir.subFile("_curriculum.ics").exists().then((value) {
                        if (value) {
                          Scheduler.scheduleAll();
                          setState(() {
                            configs.notificationsEnable.write(true);
                          });
                        } else {
                          if (mounted) {
                            showSnackBar(
                              context: this.context,
                              content: const Text("尚未生成课表"),
                            );
                          }
                        }
                      });
                    });

                    return;
                  }

                  await Scheduler.cancelAll();
                  setState(() {
                    configs.notificationsEnable.write(false);
                  });
                },
              ),
              Visibility(
                visible: configs.notificationsEnable.getOr(false),
                child: SwitchListTile(
                  secondary: const Icon(Icons.notifications_on),
                  title: const Text("仅计划今日通知"),
                  subtitle: const Text("Day Schedule"),
                  value: configs.notificationsDay.getOr(false),
                  onChanged: (bool value) async {
                    setState(() {
                      configs.notificationsDay.write(value);
                    });

                    Scheduler.reScheduleAll();
                  },
                ),
              ),
              Visibility(
                visible: configs.notificationsEnable.getOr(false),
                child: ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text("重新计划通知"),
                  subtitle: const Text("reSchedule"),
                  onTap: () {
                    Scheduler.reScheduleAll();
                    showSnackBar(
                        context: context, content: const Text("重新计划完成"));
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.timer),
                title: const Text("课前提醒"),
                subtitle: const Text("Course Reminder"),
                trailing: Text("${configs.notificationsReminder.getOr(15)} 分钟"),
                onTap: () => ComplexDialog.instance
                    .input(
                        context: context,
                        autofocus: true,
                        title: const Text("输入整数"),
                        decoration: const InputDecoration(
                          labelText: "课前提醒(分钟)",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number)
                    .then(
                  (value) {
                    if (value == null) {
                      return;
                    }
                    var reminder = int.tryParse(value);

                    if (reminder == null) {
                      if (mounted) {
                        showSnackBar(
                          context: this.context,
                          content: Text("\"$value\" 不是一个整数"),
                        );
                      }

                      return;
                    }

                    setState(() {
                      configs.notificationsReminder.write(reminder);
                    });
                    Scheduler.reScheduleAll();
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text("查看计划中的通知"),
                subtitle: const Text("Notifications"),
                onTap: () => Scheduler.getScheduleNotifications().then((value) {
                  if (!mounted) {
                    return;
                  }

                  if (value.isNotEmpty) {
                    showModalBottomSheet(
                      context: this.context,
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListView(
                            children: value
                                .map(
                                  (e) => Card(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant,
                                    child: ListTile(
                                      title: Text(e.title.toString()),
                                      subtitle: Text(e.body.toString()),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      },
                    );
                  } else {
                    showSnackBar(
                      context: this.context,
                      content: const Text("暂无计划中的通知"),
                    );
                  }
                }),
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text("通知权限"),
                subtitle: const Text("Notification Permission"),
                onTap: () {
                  Scheduler.requestAndroidPermission().then((value) {
                    if (mounted) {
                      ComplexDialog.instance.text(
                        context: this.context,
                        title: const Text("权限状态"),
                        content:
                            Text("权限 $value\n如果关闭应用无通知，请查询如何让你的手机系统允许应用后台行为"),
                      );
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text("测试通知"),
                subtitle: const Text("Test Notification"),
                onTap: () {
                  Scheduler.scheduleTest();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
