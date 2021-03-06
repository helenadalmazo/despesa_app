import 'package:despesa_app/model/group.dart';
import 'package:despesa_app/model/user.dart';
import 'package:despesa_app/screen/current_user_screen.dart';
import 'package:despesa_app/screen/group_screen.dart';
import 'package:despesa_app/service/authentication_service.dart';
import 'package:despesa_app/service/group_service.dart';
import 'package:despesa_app/utils/text_form_field_validator.dart';
import 'package:despesa_app/widget/empty_state.dart';
import 'package:despesa_app/widget/list_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  User _currentUser = AuthenticationService.currentUser;

  List<Group> _groupList;

  bool _loading = true;

  final TextEditingController _groupNameTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getGroupList();

    setState(() {
      _loading = false;
    });
  }

  void _getGroupList() async {
    List<Group> list = await GroupService.instance.list();
    setState(() {
      _groupList = list;
    });
  }

  void _saveGroup(String name) async {
    Group save = await GroupService.instance.save(name);
    setState(() {
      _groupList.add(save);
    });
  }

  void _updateGroup(String name, int id,  int index) async {
    final String groupName = _groupNameTextEditingController.text;
    Group update = await GroupService.instance.update(id, groupName);
    setState(() {
      _groupList[index] = update;
    });
  }

  void _deleteGroup(int id, int index) async {
    bool delete = await GroupService.instance.delete(id);
    setState(() {
      _groupList.removeAt(index);
    });
  }

  void _showGroupModalBottomSheetCallback(Map<String, dynamic> params) {
    _showGroupModalBottomSheet(params['context'], params['function']);
  }

  void _showGroupModalBottomSheet(BuildContext context, Function function, [Group group, int index]) {
    _groupNameTextEditingController.text = group == null ? "" : group.name;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16
            ),
            child: Wrap(
              children: [
                Column(
                  children: [
                    TextFormField(
                      controller: _groupNameTextEditingController,
                      validator: TextFormFieldValidator.validateMandatory,
                      decoration: InputDecoration(
                        hintText: 'Novo grupo',
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          if (group == null) {
                            function(_groupNameTextEditingController.text);
                          } else {
                            function(_groupNameTextEditingController.text, group.id, index);
                          }

                          Navigator.pop(context);
                        },
                        child: Text(
                          'SALVAR'
                        )
                      ),
                    )
                  ],
                )
              ],
            )
          ),
        );
      }
    );
  }

  void _showDeleteGroupDialog(BuildContext context, Group group, int index) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remover grupo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Você quer realmente remover esse grupo?'),
                Text('Essa ação não pode ser desfeita.'),
              ],
            ),
          ),
          actions: <Widget> [
            TextButton(
              child: Text('NÃO'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              child: Text('SIM'),
              onPressed: () {
                _deleteGroup(group.id, index);
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  void _showGroupOptionsModalBottomSheet(BuildContext context, Group group, int index) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              onTap: () {
                Navigator.pop(context);
                _showGroupModalBottomSheet(context, _updateGroup, group, index);
              },
              leading: Icon(Icons.edit),
              title: Text('Editar grupo'),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                _showDeleteGroupDialog(context, group, index);
              },
              leading: Icon(Icons.delete),
              title: Text('Remover grupo'),
            )
          ],
        );
      }
    );
  }

  void _currentUserScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrentUserScreen()
      )
    );
  }

  void _groupScreen(BuildContext context, Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupScreen(
          group: group,
        )
      )
    );
  }

  Widget _groupListView(BuildContext context) {
    if (_groupList == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groupList.isEmpty) {
      return EmptyState(
        icon: Icons.group,
        title: "Grupos",
        description: "Aqui você vai visualizar os grupos que faz parte, você pode ser adicionado pelos administradores de um grupo ou então iniciar um novo grupo clicando no botão acima.",
      );
    }

    return ListView.separated(
      itemCount: _groupList.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onLongPress: () => _showGroupOptionsModalBottomSheet(context, _groupList[index], index),
          onTap: () => _groupScreen(context, _groupList[index]),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 32
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _groupList[index].name,
                  style: Theme.of(context).textTheme.subtitle1
                ),
                Text(
                  _groupList[index].users.map((groupUser) {
                    String firstName = groupUser.user.getFirstName();
                    if (groupUser.user.id == _currentUser.id) {
                      return firstName += " (Você)";
                    }
                    return groupUser.user.getFirstName();
                  }).join(", "),
                )
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => Divider(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        toolbarHeight: 96,
        title: Container(
          padding: EdgeInsets.only(
            left: 16,
          ),
          child: Row(
            children: [
              Text("Olá, "),
              Hero(
                tag: "user_fullName_${_currentUser.id}",
                child: Text(
                  _currentUser.fullName,
                  style: Theme.of(context).textTheme.headline6.merge(
                    TextStyle(
                      color: Colors.white
                    )
                  )
                ),
              )
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () => _currentUserScreen(context),
          )
        ],
      ),
      body: Column(
        children: [
          ListHeader(
            buttonFunction: _showGroupModalBottomSheetCallback,
            buttonFunctionParams: {
              'context': context,
              'function': _saveGroup
            }
          ),
          Expanded(
            child: _groupListView(context),
          )
        ]
      )
    );
  }
}
