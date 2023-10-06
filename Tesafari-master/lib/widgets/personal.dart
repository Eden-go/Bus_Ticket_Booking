import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesafari/states/personaldata.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tesafari/states/themenotifier.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Personal extends StatefulWidget {
  _PersonalState createState() => _PersonalState();
}

class _PersonalState extends State<Personal> {
  bool isEditing = false;

  TextEditingController controller1 = new TextEditingController();
  TextEditingController controller2 = new TextEditingController();

  String? _name;
  String? _number;

  checkValidation(PersonalData data, String? name, String? number) async {
    bool isValid = await data.setPref(name ?? '', number ?? '');

    if (!isValid)
      Fluttertoast.showToast(
          msg: 'incorrect'.tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          fontSize: 16.0,
          backgroundColor: Colors.indigoAccent,
          textColor: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalData>(builder: (context, data, _) {
      final theme = Provider.of<ThemeNotifier>(context);
      List<Person> _people = data.getPeople;

      return SafeArea(
          child: WillPopScope(
              onWillPop: () async {
                if (isEditing) {
                  return showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                            title: Text('saveinfo'.tr(),
                                style: (theme.currentSize == FontSizes.Small)
                                    ? TextStyle(
                                        fontSize: theme
                                            .fontTheme.titleSmall!.fontSize,
                                        color: Colors.black)
                                    : (theme.currentSize == FontSizes.Medium)
                                        ? TextStyle(
                                            fontSize: theme.fontTheme
                                                .titleMedium!.fontSize,
                                            color: Colors.black)
                                        : TextStyle(
                                            fontSize: theme
                                                .fontTheme.titleLarge!.fontSize,
                                            color: Colors.black)),
                            content: Text('saveinfodesc'.tr(),
                                style: (theme.currentSize == FontSizes.Small)
                                    ? theme.fontTheme.bodySmall
                                    : (theme.currentSize == FontSizes.Medium)
                                        ? theme.fontTheme.bodyMedium
                                        : theme.fontTheme.bodyLarge),
                            actions: <Widget>[
                              TextButton(
                                  child: Text('yes'.tr()),
                                  onPressed: () {
                                    setState(() {
                                      isEditing = false;
                                    });
                                    Navigator.pop(context, true);
                                  }),
                              TextButton(
                                  child: Text('no'.tr()),
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  })
                            ]);
                      }).then((value) {
                    return value!;
                  });
                } else
                  return true;
              },
              child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.indigoAccent[400],
                      title: Text('personaldata'.tr(),
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: (theme.currentSize == FontSizes.Small)
                                  ? theme.fontTheme.titleSmall!.fontSize
                                  : (theme.currentSize == FontSizes.Medium)
                                      ? theme.fontTheme.titleMedium!.fontSize
                                      : theme.fontTheme.titleLarge!.fontSize)),
                      elevation: 3,
                      iconTheme: IconThemeData(color: Colors.white)),
                  body: ListView(children: <Widget>[
                    Container(
                        margin: EdgeInsets.all(10),
                        child: TextField(
                            controller: (!isEditing)
                                ? TextEditingController(text: data.getName)
                                : null,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'name'.tr(),
                                labelStyle: (theme.currentSize ==
                                        FontSizes.Small)
                                    ? TextStyle(
                                        fontSize:
                                            theme.fontTheme.bodySmall!.fontSize)
                                    : (theme.currentSize == FontSizes.Medium)
                                        ? TextStyle(
                                            fontSize: theme
                                                .fontTheme.bodyMedium!.fontSize)
                                        : TextStyle(
                                            fontSize: theme.fontTheme.bodyLarge!
                                                .fontSize)),
                            onChanged: (String value) {
                              setState(() {
                                _name = value;
                                isEditing = true;
                              });
                            })),
                    Container(
                        margin: EdgeInsets.all(10),
                        child: TextField(
                            controller: (!isEditing)
                                ? TextEditingController(text: data.getNumber)
                                : null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'phNumber'.tr(),
                              labelStyle: (theme.currentSize == FontSizes.Small)
                                  ? TextStyle(
                                      fontSize:
                                          theme.fontTheme.bodySmall!.fontSize)
                                  : (theme.currentSize == FontSizes.Medium)
                                      ? TextStyle(
                                          fontSize: theme
                                              .fontTheme.bodyMedium!.fontSize)
                                      : TextStyle(
                                          fontSize: theme
                                              .fontTheme.bodyLarge!.fontSize),
                            ),
                            onChanged: (String value) {
                              setState(() {
                                _number = value;
                                isEditing = true;
                              });
                            })),
                    Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        child: Row(children: [
                          Text('people'.tr(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: (theme.currentSize ==
                                          FontSizes.Small)
                                      ? theme.fontTheme.labelSmall!.fontSize
                                      : (theme.currentSize == FontSizes.Medium)
                                          ? theme
                                              .fontTheme.labelMedium!.fontSize
                                          : theme
                                              .fontTheme.labelLarge!.fontSize)),
                          Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(children: [
                                Container(
                                    child: TextButton(
                                        child: Row(
                                          children: [
                                            Icon(Icons.add),
                                            Container(
                                                child: Text('addpeople'.tr(),
                                                    style: (theme.currentSize ==
                                                            FontSizes.Small)
                                                        ? theme.fontTheme
                                                            .labelSmall
                                                        : (theme.currentSize ==
                                                                FontSizes
                                                                    .Medium)
                                                            ? theme.fontTheme
                                                                .labelMedium
                                                            : theme.fontTheme
                                                                .labelLarge))
                                          ],
                                        ),
                                        onPressed: () => showDialog<void>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              if (data.checkInfoExists()) {
                                                return AlertDialog(
                                                    title: Text(
                                                        'newcontact'.tr(),
                                                        style: (theme.currentSize ==
                                                                FontSizes.Small)
                                                            ? TextStyle(
                                                                fontSize: theme
                                                                    .fontTheme
                                                                    .titleSmall!
                                                                    .fontSize,
                                                                color: Colors
                                                                    .black)
                                                            : (theme.currentSize ==
                                                                    FontSizes
                                                                        .Medium)
                                                                ? TextStyle(
                                                                    fontSize: theme
                                                                        .fontTheme
                                                                        .titleMedium!
                                                                        .fontSize,
                                                                    color: Colors
                                                                        .black)
                                                                : TextStyle(
                                                                    fontSize: theme
                                                                        .fontTheme
                                                                        .titleLarge!
                                                                        .fontSize,
                                                                    color: Colors
                                                                        .black)),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 10),
                                                    content: Container(
                                                        height: 160,
                                                        child: Column(children: <Widget>[
                                                          Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .7,
                                                              margin: EdgeInsets
                                                                  .all(10),
                                                              child: TextField(
                                                                controller:
                                                                    controller1,
                                                                decoration: InputDecoration(
                                                                    border: OutlineInputBorder(),
                                                                    labelText: 'name'.tr(),
                                                                    labelStyle: (theme.currentSize == FontSizes.Small)
                                                                        ? TextStyle(fontSize: theme.fontTheme.bodySmall!.fontSize)
                                                                        : (theme.currentSize == FontSizes.Medium)
                                                                            ? TextStyle(fontSize: theme.fontTheme.bodyMedium!.fontSize)
                                                                            : TextStyle(fontSize: theme.fontTheme.bodyLarge!.fontSize),
                                                                    prefixIcon: Icon(Icons.people_outline_rounded)),
                                                              )),
                                                          Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  .7,
                                                              margin: EdgeInsets
                                                                  .all(10),
                                                              child: TextField(
                                                                controller:
                                                                    controller2,
                                                                decoration: InputDecoration(
                                                                    border: OutlineInputBorder(),
                                                                    labelText: 'phNumber'.tr(),
                                                                    labelStyle: (theme.currentSize == FontSizes.Small)
                                                                        ? TextStyle(fontSize: theme.fontTheme.bodySmall!.fontSize)
                                                                        : (theme.currentSize == FontSizes.Medium)
                                                                            ? TextStyle(fontSize: theme.fontTheme.bodyMedium!.fontSize)
                                                                            : TextStyle(fontSize: theme.fontTheme.bodyLarge!.fontSize),
                                                                    prefixIcon: Icon(Icons.phone)),
                                                              ))
                                                        ])),
                                                    actions: <Widget>[
                                                      TextButton(
                                                          child: Text(
                                                              'cancel'.tr()),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          }),
                                                          TextButton(
                                                          child:
                                                              Text('ok'.tr()),
                                                          onPressed: () {
                                                            data.save(
                                                                controller1
                                                                    .value.text,
                                                                controller2
                                                                    .value
                                                                    .text);

                                                            controller1.clear();
                                                            controller2.clear();

                                                            data.readLocalStorage();
                                                            Navigator.pop(
                                                                context);
                                                          })
                                                    ]);
                                              
                                              } else {
                                                return AlertDialog(
                                                    title: Text(
                                                      'info'.tr(),
                                                      style: (theme
                                                                  .currentSize ==
                                                              FontSizes.Small)
                                                          ? theme.fontTheme
                                                              .titleSmall
                                                          : (theme.currentSize ==
                                                                  FontSizes
                                                                      .Medium)
                                                              ? theme.fontTheme
                                                                  .titleMedium
                                                              : theme.fontTheme
                                                                  .titleLarge,
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 10),
                                                    content: Text(
                                                        'savepersonalwarning'
                                                            .tr(),
                                                        style: (theme
                                                                    .currentSize ==
                                                                FontSizes.Small)
                                                            ? theme.fontTheme
                                                                .bodySmall
                                                            : (theme.currentSize ==
                                                                    FontSizes
                                                                        .Medium)
                                                                ? theme
                                                                    .fontTheme
                                                                    .bodyMedium
                                                                : theme
                                                                    .fontTheme
                                                                    .bodyLarge),
                                                    actions: <Widget>[
                                                      TextButton(
                                                          child:
                                                              Text('ok'.tr()),
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context)),
                                                    ]);
                                              }
                                            })))
                              ]))
                        ])),
                    Container(
                      margin: EdgeInsets.all(10),
                      height: MediaQuery.of(context).size.height * .5,
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      (MediaQuery.of(context).size.width < 565)
                                          ? 1
                                          : 2,
                                  childAspectRatio: 3),
                          itemCount: _people.length,
                          itemBuilder: (context, index) {
                            return Container(
                                height: 10,
                                width: 250,
                                margin: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color:
                                        (theme.getTheme() == theme.lightTheme)
                                            ? Colors.grey[300]
                                            : const Color.fromARGB(
                                                255, 95, 120, 138),
                                    borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                    leading: Icon(Icons.person),
                                    title: Text(_people[index].name,
                                        style: TextStyle(
                                            fontSize: (theme.currentSize ==
                                                    FontSizes.Small)
                                                ? theme.fontTheme.displaySmall!
                                                    .fontSize
                                                : (theme.currentSize ==
                                                        FontSizes.Medium)
                                                    ? theme.fontTheme
                                                        .displayMedium!.fontSize
                                                    : theme
                                                        .fontTheme
                                                        .displayLarge!
                                                        .fontSize)),
                                    subtitle: Text(_people[index].phoneNum,
                                        style: TextStyle(
                                            fontSize: (theme.currentSize ==
                                                    FontSizes.Small)
                                                ? theme.fontTheme.labelSmall!
                                                    .fontSize
                                                : (theme.currentSize ==
                                                        FontSizes.Medium)
                                                    ? theme.fontTheme
                                                        .labelMedium!.fontSize
                                                    : theme.fontTheme
                                                        .labelLarge!.fontSize)),
                                    onTap: () {},
                                    trailing: TextButton(
                                        child: Icon(Icons.delete, color: Colors.white),
                                        onPressed: () {
                                          data.deletePerson(_people[index]);
                                        },
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color?>(
                                          (theme.getTheme() == theme.lightTheme)
                                              ? Colors.red
                                              : const Color.fromARGB(
                                                  255, 82, 102, 107),
                                        )))));
                          }),
                    )
                  ]),
                  floatingActionButton: FloatingActionButton(
                      backgroundColor: (isEditing) ? Colors.blue : Colors.grey,
                      child: Icon(Icons.save),
                      onPressed: () {
                        if (isEditing) {
                          checkValidation(data, _name, _number);
                          data.setDeviceId(
                              '$_name$_number${DateTime.now().toString()}');
                          setState(() {
                            isEditing = false;
                          });
                        }
                      }))));
    });
  }
}
