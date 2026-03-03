import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pcrypt/authentication/bloc/authentication.dart';
import 'package:pcrypt/model/password.dart';
import 'package:pcrypt/passwords/bloc/password_edit.dart';
import 'package:pcrypt/passwords/presentation/widgets/address_drawer.dart';
import 'package:pcrypt/passwords/presentation/widgets/location_drawer.dart';
import 'package:pcrypt/passwords/presentation/widgets/password_edit_body.dart';
import 'package:pcrypt/passwords/presentation/widgets/passwords_app_bar.dart';
import 'package:pcrypt/passwords/presentation/widgets/tags_drawer.dart';
import 'package:pcrypt/util/strings.dart';
import 'package:pcrypt/widget/custom_widgets.dart';

///Various types to use when uploading documents
enum FileUploadType { none, image, pdf, other }

///Screen for editing password
class PasswordEditScreen extends StatelessWidget {
  const PasswordEditScreen({
    this.password,
    this.totalFilesAttached = 0,
  });

  final Password? password;
  final int totalFilesAttached;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PasswordEditBloc>(
      create: (_) => PasswordEditBloc(
          password: password,
          isPremium: BlocProvider.of<AuthenticationBloc>(context)
              .isPremiumFeaturesAvailable,
          totalFilesAttached: totalFilesAttached),
      child: PasswordEditForm(),
    );
  }
}

//----------------------------------------------------------------------------------------------------------------------

///Widget to edit data of specific password
class PasswordEditForm extends StatefulWidget {
  @override
  State createState() => _PasswordEditFormState();
}

class _PasswordEditFormState extends State<PasswordEditForm> {
  late final PasswordEditBloc _bloc;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationTitleController = TextEditingController();
  final _locationLatitudeController = TextEditingController();
  final _locationLongitudeController = TextEditingController();
  final _locationAccuracyController = TextEditingController();
  final _locationAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<PasswordEditBloc>(context);
    _nameController.addListener(_onNameChanged);
    _usernameController.addListener(_onUsernameChanged);
    _passwordController.addListener(_onPasswordChanged);
    _urlController.addListener(_onUrlChanged);
    _notesController.addListener(_onNotesChanged);
    _locationTitleController.addListener(_onLocationTitleChanged);
    _locationLatitudeController.addListener(_onLocationLatitudeChanged);
    _locationLongitudeController.addListener(_onLocationLongitudeChanged);
    _locationAccuracyController.addListener(_onLocationAccuracyChanged);
    _locationAddressController.addListener(_onLocationAddressChanged);
  }

  void _initControllers(PasswordEditState state) {
    if (_nameController.text != state.name) {
      _nameController.value = _nameController.value.copyWith(text: state.name);
    }
    if (_usernameController.text != state.username) {
      _usernameController.value =
          _usernameController.value.copyWith(text: state.username);
    }
    if (_passwordController.text != state.password) {
      _passwordController.value =
          _passwordController.value.copyWith(text: state.password);
    }
    if (_urlController.text != state.url) {
      _urlController.value = _urlController.value.copyWith(text: state.url);
    }
    if (_notesController.text != state.notes) {
      _notesController.value =
          _notesController.value.copyWith(text: state.notes);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    _locationTitleController.dispose();
    _locationLatitudeController.dispose();
    _locationLongitudeController.dispose();
    _locationAccuracyController.dispose();
    _locationAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) async {
        if (state is Unauthenticated) {
          Navigator.of(context).pop();
        }
      },
      child: BlocListener<PasswordEditBloc, PasswordEditState>(
        listener: _blocCommandListener,
        child: BlocBuilder<PasswordEditBloc, PasswordEditState>(
            builder: (context, state) {
          _initControllers(state);
          return PopScope(
            // canPop: false,
            onPopInvokedWithResult: (bool? pop, result) {
              if (_scaffoldKey.currentState?.isEndDrawerOpen == false) {
              } else {
                ///REMOVE THE END DRAWER FIRST BEFORE EXITING THE EDIT SCREEN
                ///FOR NOW I LEFT IT COMMENTED BECAUSE I HAVE NOT BEEN ABLE TO EXPERIMENT THE USE CASE
                // Navigator.of(context).pop();
                _onCancelPressed();
              }
            },
            child: Scaffold(
              key: _scaffoldKey,
              appBar: EditScreenAppBar(state: state),
              // appBar: _buildAppBar(context, state),
              body: PasswordEditBody(
                state: state,
                nameController: _nameController,
                usernameController: _usernameController,
                urlController: _urlController,
                passwordController: _passwordController,
                notesController: _notesController,
                scaffoldKey: _scaffoldKey,
              ),
              // body: _buildBody(context, state),
              endDrawer: GestureDetector(
                  onTap: () {
                    final FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  },
                  child: _buildEndDrawer(context, state)),
              drawerEdgeDragWidth: 0.0,
            ),
          );
        }),
      ),
    );
  }

  //--------------------------------------------------------------------------------------------------------------------

  Widget _buildEndDrawer(BuildContext context, PasswordEditState state) {
    switch (state.drawerPage) {
      case DrawerPage.selectTags:
        return TagsEndDrawer(
          state: state,
          scaffoldKey: _scaffoldKey,
        );
      case DrawerPage.addLocation:
        return LocationEndDrawer(
          state: state,
          isNew: true,
          titleController: _locationTitleController,
          accuracyController: _locationAccuracyController,
          latitudeController: _locationLatitudeController,
          longitudeController: _locationLongitudeController,
          scaffoldKey: _scaffoldKey,
        );
      case DrawerPage.editLocation:
        return LocationEndDrawer(
          state: state,
          isNew: false,
          titleController: _locationTitleController,
          accuracyController: _locationAccuracyController,
          latitudeController: _locationLatitudeController,
          longitudeController: _locationLongitudeController,
          scaffoldKey: _scaffoldKey,
        );
      case DrawerPage.getAddress:
        return AddressEndDrawer(
          state: state,
          addressController: _locationAddressController,
        );
      case DrawerPage.none:
      default:
        return const SizedBox(height: 0.0);
    }
  }

  //--------------------------------------------------------------------------------------------------------------------

  void _onNameChanged() {
    _bloc.add(NameChanged(name: _nameController.text));
  }

  void _onUsernameChanged() {
    _bloc.add(UsernameChanged(username: _usernameController.text));
  }

  void _onPasswordChanged() {
    _bloc.add(PasswordChanged(password: _passwordController.text));
  }

  void _onUrlChanged() {
    _bloc.add(UrlChanged(url: _urlController.text));
  }

  void _onNotesChanged() {
    _bloc.add(NotesChanged(notes: _notesController.text));
  }

  void _onLocationTitleChanged() {
    _bloc.add(LocationTitleChanged(title: _locationTitleController.text));
  }

  void _onLocationLatitudeChanged() {
    _bloc.add(
        LocationLatitudeChanged(latitude: _locationLatitudeController.text));
  }

  void _onLocationLongitudeChanged() {
    _bloc.add(
        LocationLongitudeChanged(longitude: _locationLongitudeController.text));
  }

  void _onLocationAccuracyChanged() {
    _bloc.add(
        LocationAccuracyChanged(accuracy: _locationAccuracyController.text));
  }

  void _onLocationAddressChanged() {
    _bloc.add(LocationAddressChanged(address: _locationAddressController.text));
  }

  void _onCancelPressed() {
    FocusScope.of(context).unfocus();
    _bloc.add(FormCanceled());
  }

  /// Upload file
  Future<void> _uploadFile(BuildContext context) async {
    final FileUploadType picked = await showDialog<FileUploadType>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text(Strings.uploadFileTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 16.0),
                  Text(
                    Strings.uploadFileChooseType,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12.0),
                  ListTile(
                    title: Text(Strings.uploadFileTypeImage),
                    leading: const Icon(Icons.image),
                    onTap: () {
                      Navigator.of(dialogContext).pop(FileUploadType.image);
                    },
                  ),
                  ListTile(
                    title: Text(Strings.uploadFileTypePDF),
                    leading: const Icon(Icons.picture_as_pdf),
                    onTap: () {
                      Navigator.of(dialogContext).pop(FileUploadType.pdf);
                    },
                  ),
                  ListTile(
                    title: Text(Strings.uploadFileTypeOther),
                    leading: const Icon(Icons.insert_drive_file),
                    onTap: () {
                      Navigator.of(dialogContext).pop(FileUploadType.other);
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(Strings.actionCancel.toUpperCase()),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        ) ??
        FileUploadType.none;
    FilePickerResult? result;
    switch (picked) {
      case FileUploadType.image:
        result = await FilePicker.platform.pickFiles(type: FileType.image);
        break;
      case FileUploadType.pdf:
        result = await FilePicker.platform
            .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
        break;
      case FileUploadType.other:
        result = await FilePicker.platform.pickFiles(type: FileType.any);
        break;
      default:
        result = null;
        break;
    }
    if (result != null) {
      _bloc.add(FileForUploadPicked(path: result.files.single.path ?? ''));
    }
  }

  /// Listener for specific Bloc states
  Future<void> _blocCommandListener(
      BuildContext context, PasswordEditState state) async {
    if (_scaffoldKey.currentState?.isEndDrawerOpen == true &&
        state.drawerPage == DrawerPage.none) {
      Navigator.of(context).pop();
    }
    if (state is TagCreationPermittedState) {
      _createNewTag(context);
    }
    if (state is FileUploadPermittedState) {
      _uploadFile(context);
    }
    if (state is FileUploadResultState) {
      String text;
      switch (state.uploadResult) {
        case FileUploadResult.success:
          text = Strings.uploadFileResultSuccess;
          break;
        case FileUploadResult.storageFull:
          text = Strings.uploadFileResultStorageFull;
          break;
        case FileUploadResult.largerThan1Mb:
        case FileUploadResult.otherError:
          text = Strings.uploadFileResultFail;
          break;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(text),
            action: state.errorDetails?.isNotEmpty == true
                ? SnackBarAction(
                    label: Strings.actionDetails.toUpperCase(),
                    onPressed: () {
                      showDialog<void>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(Strings.passwordError),
                              content: Text(state.errorDetails!),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(Strings.actionOk),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          });
                    },
                  )
                : null,
          ),
        );
    }
    if (state is FinishEditState) {
      Navigator.of(context).pop(state.result);
    }
    if (state is ConfirmDiscardChangesState) {
      final bool result = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(Strings.passwordDiscardChangesPrompt),
                actions: [
                  TextButton(
                    child: Text(Strings.actionNo.toUpperCase()),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                      child: Text(Strings.actionYes.toUpperCase()),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      }),
                ],
              );
            },
          ) ??
          false;
      _bloc.add(ConfirmationSubmitted(isConfirmed: result));
    }
    if (state is PremiumRequiredState) {
      showPremiumRestrictionsDialog(context);
    }
    if (state is SessionExpiredState) {
      BlocProvider.of<AuthenticationBloc>(context).add(SessionExpiredEvent());
    }
    if (state is ConnectionErrorState) {
      connectionError(context, state.errorMessage);
    }
  }

  /// Method for new tag creation
  Future<void> _createNewTag(BuildContext context) async {
    final name = await showEditTextDialog(
      context,
      title: Strings.passwordTagsCreateNew,
      hint: Strings.passwordTagsName,
      emptyMessage: Strings.passwordTagsNameEmpty,
      positiveTitle: Strings.actionCreate,
      cancelTitle: Strings.actionCancel,
    );
    if (name != null) {
      _bloc.add(NewTagAdded(name: name));
    }
  }
}
