import 'package:arche/arche.dart';
import 'package:cczu_helper/controllers/accounts.dart';
import 'package:cczu_helper/controllers/navigator.dart';
import 'package:cczu_helper/messages/account.pb.dart';
import 'package:flutter/material.dart';

class AccountManagePage extends StatefulWidget {
  final Widget backButton;
  const AccountManagePage({
    super.key,
    this.backButton = const BackButton(),
  });

  @override
  State<StatefulWidget> createState() => AccountManagePageState();
}

class AccountManagePageState extends State<AccountManagePage>
    with RefreshMountedStateMixin {
  Set<AccountType> accountType = const {AccountType.sso};

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if (ArcheBus.bus.has<MultiAccoutData>()) {
      var colorScheme = Theme.of(context).colorScheme;
      var data = ArcheBus.bus.of<MultiAccoutData>();
      items = data.accounts[accountType.first.name]!
          .map(
            (element) => Padding(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                leading: const Icon(Icons.person),
                tileColor: element.equal(data.current[accountType.first.name])
                    ? colorScheme.primaryContainer
                    : null,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: colorScheme.primary),
                    borderRadius: const BorderRadius.all(Radius.circular(4))),
                onTap: () {
                  setState(() {
                    data.current[accountType.first.name] = element;
                    data.writeAccounts();
                  });
                },
                onLongPress: () {
                  pushMaterialRoute(
                    builder: (context) => AddAccountPage(
                      account: element,
                      accountType: accountType.first,
                      callback: refreshMounted,
                    ),
                  );
                },
                title: Text(element.user),
              ),
            ),
          )
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        leading: widget.backButton,
        title: const Text("账号管理"),
        actions: [
          SegmentedButton(
            segments: const [
              ButtonSegment(
                  value: AccountType.sso,
                  icon: Icon(Icons.school),
                  label: Text("一网通办")),
              ButtonSegment(
                  value: AccountType.edu,
                  icon: Icon(Icons.school),
                  label: Text("教务系统"))
            ],
            selected: accountType,
            onSelectionChanged: (value) {
              setState(() {
                accountType = value;
              });
            },
          ),
          const SizedBox(
            width: 8,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => pushMaterialRoute(
          builder: (context) => AddAccountPage(
            accountType: accountType.first,
            callback: refreshMounted,
          ),
        ),
        child: const Icon(Icons.add),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text("暂无账户"),
            )
          : ListView(
              key: ValueKey(accountType.first),
              children: items,
            ),
    );
  }
}

class AddAccountPage extends StatefulWidget {
  final AccountType accountType;
  final AccountData? account;
  final Function() callback;
  const AddAccountPage({
    super.key,
    this.accountType = AccountType.sso,
    this.account,
    required this.callback,
  });

  @override
  State<StatefulWidget> createState() => _AddAccountPageState();
}

class _AddAccountPageState extends State<AddAccountPage> {
  late TextEditingController user;
  late TextEditingController password;
  bool obscurePassword = true;
  @override
  void initState() {
    super.initState();
    AccountData account = AccountData(user: "", password: "");
    if (widget.account != null) {
      account = widget.account!;
    }
    user = TextEditingController(text: account.user);
    password = TextEditingController(text: account.password);
  }

  @override
  void dispose() {
    super.dispose();
    user.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account != null ? "编辑账户" : "添加账户"),
        actions: [
          Visibility(
            visible: widget.account != null,
            child: IconButton(
              onPressed: () {
                var data = ArcheBus.bus.of<MultiAccoutData>();
                data.deleteAccount(widget.account!, widget.accountType);
                data.writeAccounts().then((_) {
                  Navigator.of(context).pop();
                  widget.callback();
                });
              },
              icon: const Icon(Icons.delete),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var data = ArcheBus.bus.provideof(instance: MultiAccoutData.template);
          data.addAccount(
              AccountData(
                user: user.text,
                password: password.text,
              ),
              widget.accountType);
          if (widget.account != null) {
            data.deleteAccount(widget.account!, widget.accountType);
          }
          data.writeAccounts().then((_) {
            Navigator.of(context).pop();
            widget.callback();
          });
        },
        child: const Icon(Icons.check),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                controller: user,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  labelText: "账户",
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              TextField(
                controller: password,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    labelText: "密码",
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: const Icon(Icons.visibility))),
                obscureText: obscurePassword,
              ),
              const SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                    onPressed: () {
                      //TODO
                    },
                    child: const Text("测试登录")),
              )
            ],
          ),
        ),
      ),
    );
  }
}
