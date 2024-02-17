import 'package:contacts_service/contacts_service.dart';
import 'package:drive/src/controller/language_controller.dart';
import 'package:drive/src/repository/network_repository.dart';
import 'package:drive/src/style/colors.dart';
import 'package:drive/src/style/decoration.dart';
import 'package:drive/src/utils/locator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

class UserContacts {
  final NetworkRepository _networkRepository = locator<NetworkRepository>();
  GetStorage getStorage = GetStorage();
  Future<bool> isContactsSave({
    required BuildContext context,
  }) async {
    bool iscontactSaved = getStorage.read('saveContacts') ?? false;
    if (iscontactSaved) {
      return true;
    } else {
      return await getContactList(
        context: context,
        isEnableClick: false,
      );
    }
  }

  Future<bool> getContactList({
    required BuildContext context,
    required bool isEnableClick,
  }) async {
    bool isContactPermission = getStorage.read('isContactPermission') ?? true;
    final PermissionStatus permissionStatus =
        await _getPermission(isEnableClick, isContactPermission);
    if (permissionStatus == PermissionStatus.granted) {
      return getContacts();
    } else if ((permissionStatus == PermissionStatus.permanentlyDenied &&
            isEnableClick) ||
        !isContactPermission) {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text('Permissions error'),
          content: Text(
              'Allow "Fahrschulhero" to access your accounts so you can invite your friends to a App'),
          actions: <Widget>[
            CupertinoDialogAction(
                child: Text(currentLanguage['btn_cancel']),
                onPressed: () {
                  getStorage.write('isContactPermission', false);
                  isContactPermission =
                      getStorage.read('isContactPermission') ?? true;
                  Navigator.of(context).pop();
                }),
            CupertinoDialogAction(
              child: Text('Settings'),
              onPressed: () async {
                await openAppSettings();
              },
            ),
          ],
        ),
      );
      final PermissionStatus permissionStatus =
          await _getPermission(isEnableClick, isContactPermission);
      if (permissionStatus == PermissionStatus.granted) {
        return getContacts();
      } else if (permissionStatus == PermissionStatus.denied ||
          permissionStatus == PermissionStatus.permanentlyDenied) {
        getStorage.write('isContactPermission', false);
        return true;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  Future<PermissionStatus> _getPermission(
      isEnableClick, isContactPermission) async {
    final PermissionStatus permission = await Permission.contacts.status;
    if ((permission != PermissionStatus.granted &&
            permission != PermissionStatus.permanentlyDenied) ||
        isEnableClick ||
        isContactPermission) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      if (isContactPermission) {
        getStorage.write('isContactPermission', false);
      }
      return permissionStatus[Permission.contacts] ?? PermissionStatus.limited;
    } else {
      return permission;
    }
  }

  Future<bool> getContacts() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    return saveContacts(contacts);
  }

  Future<bool> saveContacts(userContacts) async {
    List saveContactsList = [];
    if (userContacts.length != 0) {
      for (int i = 0; i < userContacts.length; i++) {
        Contact userContact = await userContacts.elementAt(i);
        List emails = [];
        List phones = [];
        Iterable<Item> getEmails = userContact.emails ?? [];
        Iterable<Item> getPhones = userContact.phones ?? [];
        if (emails.length != 0) {
          for (int j = 0; j < getEmails.length; j++) {
            Item mail = getEmails.elementAt(j);
            emails.add({
              "label": mail.label,
              "value": mail.value,
            });
          }
        }
        if (getPhones.length != 0) {
          for (int j = 0; j < getPhones.length; j++) {
            Item phone = getPhones.elementAt(j);
            phones.add({
              "label": phone.label,
              "value": phone.value,
            });
          }
        }
        saveContactsList.add({
          "identifier": userContact.identifier,
          "displayName": userContact.displayName,
          "givenName": userContact.givenName,
          "middleName": userContact.middleName,
          "prefix": userContact.prefix,
          "suffix": userContact.suffix,
          "familyName": userContact.familyName,
          "company": userContact.company,
          "jobTitle": userContact.jobTitle,
          "androidAccountTypeRaw": userContact.androidAccountTypeRaw,
          "androidAccountName": userContact.androidAccountName,
          "emails": emails,
          "phones": phones,
        });
      }
      if (saveContactsList.length != 0) {
        dynamic response =
            await _networkRepository.saveContacts(null, saveContactsList);
        if (response != null &&
            (response['statusCode'] == 200 ||
                response['statusCode'] == "200")) {
          getStorage.write('saveContacts', true);
          return true;
        } else {
          return true;
        }
      } else
        return true;
    } else {
      return true;
    }
  }

  Widget noContactsOrPermission(
      {required bool permission, required Function() enableOnTap}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: permission
          ? Center(
              child: TextAndStyle(
                title: 'No contacts found.',
                color: greyColor,
                fontSize: 16,
                textAlign: TextAlign.center,
                letterSpacing: 0.5,
              ),
            )
          : Center(
              child: Column(
                children: [
                  TextAndStyle(
                    title:
                        'Enable contacts permission to organize \n matches with your friends.',
                    color: greyColor,
                    fontSize: 16,
                    textAlign: TextAlign.center,
                    letterSpacing: 0.5,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: enableOnTap,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 28.0, vertical: 12),
                      decoration: BoxDecoration(
                        color: appColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextAndStyle(
                        title: 'Enable',
                        color: whiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
