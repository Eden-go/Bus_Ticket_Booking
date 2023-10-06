import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tesafari/states/personaldata.dart';
import 'package:tesafari/states/restservice.dart';
import 'package:tesafari/states/themenotifier.dart';

class PersonalInfoForm extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeNotifier>(context);
    final restService = Provider.of<RESTService>(context);
    final personalData = Provider.of<PersonalData>(context);

    return SimpleDialog(
        title: Text('personalinfo'.tr(),
            style: (theme.currentSize == FontSizes.Small)
                ? TextStyle(
                    fontSize: theme.fontTheme.titleSmall!.fontSize,
                    color: Colors.black)
                : (theme.currentSize == FontSizes.Medium)
                    ? TextStyle(
                        fontSize: theme.fontTheme.titleMedium!.fontSize,
                        color: Colors.black)
                    : TextStyle(
                        fontSize: theme.fontTheme.titleLarge!.fontSize,
                        color: Colors.black)),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        children: [
          Form(
            key: _formKey,
            child: Column(children: <Widget>[
              !personalData.checkInfoExists()
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
                            border: OutlineInputBorder(),
                            labelText: 'name'.tr(),
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
                            prefixIcon: Icon(Icons.people_outline_rounded)),
                      )
                    )
                  : SizedBox(),
              (!personalData.checkInfoExists())
                  ? Container(
                      width: MediaQuery.of(context).size.width * .7,
                      margin: EdgeInsets.all(10),
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          String numberVerifier = r"^(0|\+251)([0-9]{9})$";
                          if (!value!.contains(RegExp(numberVerifier)) &&
                              value.isEmpty) return 'invalidphone'.tr();

                          return null;
                        },
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
                            prefixIcon: Icon(Icons.phone)),
                      ),
                    )
                  : SizedBox()
            ])
          ),
          Container(
            margin: EdgeInsets.only(right: 20, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    child: Text('cancel'.tr()),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                    TextButton(
                    child: Text('ok'.tr()),
                    onPressed: () {
                      final isValid = _formKey.currentState!.validate();

                      if (!isValid) return;

                      _formKey.currentState!.save();

                      Navigator.pop(context, {
                        'name': _nameController.text,
                        'number': _phoneController.text,
                      });

                      restService.setPaymentGateway = null;
                    }),
              ]
            )
          )
        ]);
  }
}
