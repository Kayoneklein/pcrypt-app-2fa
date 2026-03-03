import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pcrypt/home/presentation/screens/home_screen.dart';
import 'package:pcrypt/model/language.dart';
import 'package:pcrypt/settings/bloc/settings.dart';
import 'package:pcrypt/settings/presentation/settings_screen.dart';
import 'package:pcrypt/util/strings.dart';
import 'package:pcrypt/widget/custom_widgets.dart';

///Screen for showing app settings
class ChooseLanguageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (context) => SettingsBloc()..loadInitialState(),
      child: ChooseLanguageForm(),
    );
  }
}

//======================================================================================================================

class ChooseLanguageForm extends StatefulWidget {
  @override
  State createState() => _ChooseLanguageFormState();
}

class _ChooseLanguageFormState extends State<ChooseLanguageForm> {
  late final SettingsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<SettingsBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsBloc, SettingsState>(
      listener: _stateChangeListener,
      child:
          BlocBuilder<SettingsBloc, SettingsState>(builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(Strings.settingsChooseLanguage),
            centerTitle: false,
            leading: PopScope(
              canPop: false,
              onPopInvoked: (bool? pop) {
                _backButtonPressed();
              },
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _backButtonPressed,
              ),
            ),
//!!!            actions: state.isInitialized
//                ? [
//                    IconButton(
//                      icon: Icon(Icons.check),
//                      tooltip: Strings.actionConfirm,
//                      onPressed: _confirmButtonPressed,
//                    ),
//                  ]
//                : [],
          ),
          body: state.isInitialized
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // const SizedBox(height: 24.0),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    //   child: Text(
                    //     Strings.settingsChooseLanguage,
                    //     style: Theme.of(context).textTheme.headline6,
                    //   ),
                    // ),
                    const SizedBox(height: 8.0),
                    ScrollConfiguration(
                      behavior: NoEdgeEffectScrollBehavior(),
                      child: Scrollbar(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.allLanguages.length,
                          itemBuilder: (context, position) {
                            final language = state.allLanguages[position];
                            return InkWell(
                              onTap: () => state.isChangingLanguage
                                  ? null
                                  : _languageSelectionChanged(position),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16.0),
                                child: Row(
                                  children: <Widget>[
                                    IgnorePointer(
                                      child: state.isChangingLanguage
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              width: 48.0,
                                              height: 48.0,
                                              child:
                                                  const CircularProgressIndicator(),
                                            )
                                          : Radio<Language>(
                                              value: language,
                                              groupValue: state.currentLanguage,
                                              onChanged: (_) {},
                                            ),
                                    ),
                                    const SizedBox(width: 8.0),
                                    Expanded(
                                      child: Text(
                                        language.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                )
              : const LinearProgressIndicator(),
        );
      }),
    );
  }

  /// Triggers when state changes
  Future<void> _stateChangeListener(
      BuildContext context, SettingsState state) async {
    if (state is LanguageChangingErrorState) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(Strings.settingsErrorChangingLanguage),
          ),
        );
    }
    if (state is ShowDiscardDialogState) {
      final bool? isYes = await showDialog<bool?>(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  content: Text(Strings.settingsDiscardChanges),
                  actions: <Widget>[
                    TextButton(
                      child: Text(Strings.actionNo.toUpperCase()),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text(Strings.actionYes.toUpperCase()),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                    ),
                  ],
                );
              }) ??
          false;
      _bloc.add(DialogConfirmationReceived(isYes: isYes ?? false));
    }
    if (state is NavigateBackState) {
      print(_bloc.isLanguageChanged);
      if (_bloc.isLanguageChanged) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => BlocProvider(
                create: (context) => SettingsBloc()..loadInitialState(),
                child: HomeScreen(),
              ),
            ),
            (route) => false);
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => BlocProvider(
              create: (context) => SettingsBloc()..loadInitialState(),
              child: SettingScreen(),
            ),
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
      //
    }
  }

  /// Triggers when language selection changes
  void _languageSelectionChanged(int position) {
    _bloc.add(LanguageSelectionChanged(position: position));
  }

  /// Triggers when user presses 'Confirm' button
  void _confirmButtonPressed() {
    _bloc.add(ChangesConfirmed());
  }

  void _backButtonPressed() {
    _bloc.add(BackButtonPressed());
  }
}
