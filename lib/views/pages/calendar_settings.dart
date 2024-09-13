import 'dart:io';

import 'package:arche/arche.dart';
import 'package:arche/extensions/dialogs.dart';
import 'package:arche/extensions/io.dart';
import 'package:cczu_helper/controllers/config.dart';
import 'package:cczu_helper/controllers/scheduler.dart';
import 'package:cczu_helper/controllers/snackbar.dart';
import 'package:cczu_helper/views/pages/settings.dart';
import 'package:cczu_helper/views/widgets/scrollable.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CalendarSettings extends StatefulWidget {
  const CalendarSettings({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarSettingsState();
}

class _CalendarSettingsState extends State<CalendarSettings> {
  Future<int?> inputOpacity([String text = ""]) async {
    var input = await ComplexDialog.instance.input(
      context: context,
      title: const Text("透明度 (0~100)%"),
      controller: TextEditingController(text: text),
      decoration: const InputDecoration(border: OutlineInputBorder()),
      keyboardType: const TextInputType.numberWithOptions(),
    );
    if (input == null) {
      return null;
    }

    var result = int.tryParse(input);

    if (result == null || result < 0 || result > 100) {
      if (mounted) {
        showSnackBar(context: context, content: const Text("输入 0-100 的数字"));
      }
    } else {
      return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    ApplicationConfigs configs = ArcheBus().of();

    return Scaffold(
      appBar: AppBar(
        title: const Text("课程表设置"),
      ),
      body: PaddingScrollView(
        child: Column(
          children: [
            SettingGroup(name: "外观", children: [
              SwitchListTile(
                secondary: const Icon(Icons.visibility),
                title: const Text("显示分割线"),
                subtitle: const Text("Disable Interval Line"),
                value: configs.calendarIntervalLine.getOr(true),
                onChanged: (value) {
                  setState(() {
                    configs.calendarIntervalLine.write(value);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.opacity),
                title: const Text("日程背景透明度"),
                subtitle: const Text("Opactiy"),
                trailing: Text(
                    "${(configs.calendarCellOpacity.getOr(1) * 100).ceil()}%"),
                onTap: () {
                  inputOpacity((configs.calendarCellOpacity.getOr(1) * 100)
                          .ceil()
                          .toString())
                      .then((opacity) {
                    if (opacity != null) {
                      setState(() {
                        configs.calendarCellOpacity.write(opacity / 100);
                      });
                    }
                  });
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.image),
                title: const Text("背景图片"),
                subtitle: const Text("Background Image"),
                value: configs.calendarBackgroundImage.has(),
                onChanged: (value) async {
                  if (value) {
                    var picker = ImagePicker();
                    picker
                        .pickImage(source: ImageSource.gallery)
                        .then((image) async {
                      if (image != null) {
                        var calendarDir =
                            await platCalendarDataDirectory.getValue();

                        var origin = configs.calendarBackgroundImage.tryGet();

                        if (origin != null) {
                          var from = calendarDir.subFile(origin);
                          if (await from.exists()) {
                            from.delete();
                          }
                        }
                        setState(() {
                          configs.calendarBackgroundImage.write(image.name);
                        });

                        await calendarDir
                            .subFile(image.name)
                            .writeAsBytes(await image.readAsBytes());
                      }
                    });
                  } else {
                    var calendarDir =
                        await platCalendarDataDirectory.getValue();

                    var origin = configs.calendarBackgroundImage.tryGet();

                    if (origin != null) {
                      var from = calendarDir.subFile(origin);
                      if (await from.exists()) {
                        from.delete();
                      }
                    }
                    setState(() {
                      configs.calendarBackgroundImage.delete();
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.opacity),
                title: const Text("背景图片透明度"),
                subtitle: const Text("Opactiy"),
                trailing: Text(
                    "${(configs.calendarBackgroundImageOpacity.getOr(0.30) * 100).ceil()}%"),
                onTap: () {
                  inputOpacity(
                          (configs.calendarBackgroundImageOpacity.getOr(0.30) *
                                  100)
                              .ceil()
                              .toString())
                      .then((opacity) {
                    if (opacity != null) {
                      setState(() {
                        configs.calendarBackgroundImageOpacity
                            .write(opacity / 100);
                      });
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.blur_linear),
                title: const Text("背景模糊"),
                subtitle: const Text("Blur"),
                trailing: Text(
                    "Sigma ${(configs.calendarBackgroundImageBlur.getOr(0))}"),
                onTap: () {
                  ComplexDialog.instance
                      .input(
                    context: context,
                    title: const Text("Sigma"),
                    controller: TextEditingController(
                        text: (configs.calendarBackgroundImageBlur.getOr(0))
                            .toString()),
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                    keyboardType: const TextInputType.numberWithOptions(),
                  )
                      .then((text) {
                    if (text != null && mounted) {
                      var value = double.tryParse(text);

                      if (value != null) {
                        setState(() {
                          configs.calendarBackgroundImageBlur.write((value));
                        });
                      } else {
                        showSnackBar(
                          context: this.context,
                          content: const Text("请输入数字"),
                        );
                      }
                    }
                  });
                },
              )
            ]),
            SettingGroup(
              name: "通知",
              visible: Platform.isAndroid,
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
                        var platdir =
                            await platCalendarDataDirectory.getValue();
                        platdir
                            .subFile("calendar_curriculum.ics")
                            .exists()
                            .then((value) {
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
                  trailing:
                      Text("${configs.notificationsReminder.getOr(15)} 分钟"),
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
                  onTap: () =>
                      Scheduler.getScheduleNotifications().then((value) {
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
          ],
        ),
      ),
    );
  }
}
