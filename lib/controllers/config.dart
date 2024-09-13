import 'dart:async';
import 'dart:io';

import 'package:arche/arche.dart';
import 'package:cczu_helper/models/navstyle.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

FutureLazyDynamicCan<Directory> platDirectory =
    FutureLazyDynamicCan(builder: getPlatDirectory);

Future<Directory> getPlatDirectory() async {
  if (Platform.isWindows || Platform.isLinux) {
    return Directory.current.absolute;
  }

  return (await getExternalStorageDirectory() ??
      await getApplicationCacheDirectory());
}

class ApplicationConfigs extends AppConfigsBase {
  ApplicationConfigs(super.config, [super.generateMap = true]);

  ConfigEntry<String> get sysfont => generator("sysfont");

  ConfigEntryConverter<int, ThemeMode> get themeMode => ConfigEntryConverter(
        generator("thememode"),
        forward: (value) => ThemeMode.values[value],
        reverse: (value) => value.index,
      );

  ConfigEntryConverter<int, NavigationStyle> get navStyle =>
      ConfigEntryConverter(
        generator("navigation_style"),
        forward: (value) => NavigationStyle.values[value],
        reverse: (value) => value.index,
      );
  ConfigEntryConverter<int, CalendarView> get calendarView =>
      ConfigEntryConverter(
        generator("calendarview"),
        forward: (value) {
          return CalendarView.values[value];
        },
        reverse: (value) {
          return value.index;
        },
      );
  ConfigEntry<bool> get autosavelog => generator("autosavelog");
  ConfigEntry<bool> get skipServiceExitConfirm =>
      generator("skipserviceexitconfirm");
  ConfigEntry<bool> get notificationsEnable =>
      generator("notifications_enable");
  ConfigEntry<int> get notificationsReminder =>
      generator("notifications_reminder");
  ConfigEntry<bool> get notificationsDay => generator("notifications_day");
  ConfigEntry<bool> get firstUse => generator("first_use");
  ConfigEntry<bool> get weakAnimation => generator("weak_animation");
  ConfigEntry<bool> get forceTransparent => generator("force_transparent");
  ConfigEntry<bool> get calendarSimple => generator("calendar_simple");

  ConfigEntry<bool> get calendarIntervalLine =>
      generator("calendar_intervalline");

  ConfigEntry<bool> get calendarBackgroundImage =>
      generator("calendar_background_image");
}

class CalendarConfigs extends AppConfigsBase {
  CalendarConfigs(super.config, [super.generateMap = true]);
}
