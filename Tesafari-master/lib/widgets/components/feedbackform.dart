import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:tesafari/states/personaldata.dart';
import 'package:tesafari/states/restservice.dart';
import 'package:tesafari/states/themenotifier.dart';

class FeedbackForm extends StatelessWidget {
  final _feedBackController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> _feedbackItems = [
    'driverbehaviour',
    'lostitem',
    'complaint',
    'suggestion',
    'other',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context);
    final personalData = Provider.of<PersonalData>(context);
    final restService = Provider.of<RESTService>(context);
    bool nameExists =
        personalData.getName != null && personalData.getName != '';
    bool phoneExists =
        personalData.getNumber != null && personalData.getNumber != '';

    String? _feedbackTitle;

    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
          title: Text('feedback'.tr(),
              style: (theme.currentSize == FontSizes.Small)
                  ? TextStyle(fontSize: theme.fontTheme.titleSmall!.fontSize)
                  : (theme.currentSize == FontSizes.Medium)
                      ? TextStyle(
                          fontSize: theme.fontTheme.titleMedium!.fontSize)
                      : TextStyle(
                          fontSize: theme.fontTheme.titleLarge!.fontSize)),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          content: Container(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(children: <Widget>[
                  (!nameExists)
                      ? Container(
                          width: MediaQuery.of(context).size.width * .7,
                          margin: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: _nameController,
                            validator: (value) {
                              if (value!.isEmpty) return 'entername'.tr();
                              return null;
                            },
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 30),
                                border: OutlineInputBorder(),
                                labelText: 'name'.tr(),
                                labelStyle: (theme.currentSize ==
                                        FontSizes.Small)
                                    ? TextStyle(
                                        fontSize:
                                            theme.fontTheme.bodySmall!.fontSize)
                                    : (theme.currentSize == FontSizes.Medium)
                                        ? TextStyle(
                                            fontSize: theme.fontTheme
                                                .bodyMedium!.fontSize!)
                                        : TextStyle(
                                            fontSize: theme
                                                .fontTheme.bodyLarge!.fontSize),
                                prefixIcon: Icon(Icons.person)),
                          ))
                      : SizedBox(),
                  (!phoneExists)
                      ? Container(
                          width: MediaQuery.of(context).size.width * .7,
                          margin: EdgeInsets.all(10),
                          child: TextFormField(
                            controller: _phoneController,
                            validator: (value) {
                              String numberVerifier = r"^(0|\+251)([0-9]{9})$";
                              if (!value!.contains(RegExp(numberVerifier)) &&
                                  value.isEmpty) return 'invalidphone'.tr();
                              return null;
                            },
                            decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 30),
                                border: OutlineInputBorder(),
                                labelText: 'phNumber'.tr(),
                                labelStyle: (theme.currentSize ==
                                        FontSizes.Small)
                                    ? TextStyle(
                                        fontSize:
                                            theme.fontTheme.bodySmall!.fontSize)
                                    : (theme.currentSize == FontSizes.Medium)
                                        ? TextStyle(
                                            fontSize: theme.fontTheme
                                                .bodyMedium!.fontSize!)
                                        : TextStyle(
                                            fontSize: theme
                                                .fontTheme.bodyLarge!.fontSize),
                                prefixIcon: Icon(Icons.phone)),
                          ))
                      : SizedBox(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: InputDecorator(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                      child: Row(
                        children: [
                          Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Icon(Icons.info, color: Colors.grey)),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                hint: Text('reason'.tr(),
                                    style:
                                        (theme.currentSize == FontSizes.Small)
                                            ? TextStyle(
                                                fontSize: theme.fontTheme
                                                    .bodySmall!.fontSize)
                                            : (theme.currentSize ==
                                                    FontSizes.Medium)
                                                ? TextStyle(
                                                    fontSize: theme.fontTheme
                                                        .bodyMedium!.fontSize!)
                                                : TextStyle(
                                                    fontSize: theme
                                                            .fontTheme
                                                            .bodyLarge!
                                                            .fontSize! -
                                                        2)),
                                validator: (value) =>
                                    value == null ? 'enterreason'.tr() : null,
                                value: _feedbackTitle,
                                items: _feedbackItems.map((String items) {
                                  return DropdownMenuItem(
                                    value: items,
                                    child: Text(items.tr()),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _feedbackTitle = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * .7,
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        maxLines: 5,
                        controller: _feedBackController,
                        validator: (value) {
                          if (value!.isEmpty) return 'emptymessage'.tr();
                          return null;
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'writefeedback'.tr(),
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
                            prefixIcon: Icon(Icons.edit)),
                      )),
                ]),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text('cancel'.tr()),
                onPressed: () {
                  Navigator.pop(context);
                }),
                TextButton(
                child: Text('ok'.tr()),
                onPressed: () async {
                  var isValid = _formKey.currentState!.validate();

                  if (isValid) {
                    String name = _nameController.text;
                    String number = _phoneController.text;

                    Response? response = await restService.submitComplaint({
                      'name': (personalData.checkInfoExists())
                          ? personalData.getName
                          : name,
                      'phone': (personalData.checkInfoExists())
                          ? personalData.getNumber
                          : number,
                      'reason': _feedbackTitle ?? 'Other',
                      'message': _feedBackController.text
                    });

                    if (response!.statusCode == 200)
                      _feedBackController.clear();
                    else
                      Fluttertoast.showToast(
                          msg: 'failedrequest'.tr(),
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                          fontSize: 16.0,
                          backgroundColor: Colors.indigoAccent,
                          textColor: Colors.white);

                    Navigator.pop(context);
                  }
                }),
          ]),
    );
  }
}
