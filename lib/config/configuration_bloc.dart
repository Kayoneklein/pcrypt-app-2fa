import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:pcrypt/web/server_adapter.dart';

import 'configuration_event.dart';
import 'configuration_state.dart';

/// Bloc that handles loading of remote configuration
class ConfigurationBloc extends Bloc<ConfigurationEvent, ConfigurationState> {
  ConfigurationBloc() : super(ConfigurationState.initial()) {
    _loadConfigData();

    on<ConfigurationEvent>((event, emit)  async {
      if (event is ReloadRequested) {
        emit(state.copyWith(
          isLoading: true,
        ));
        await _server.cleanRemoteConfig();
        _loadConfigData();
      }
      if (event is ConfigurationLoadFinished) {
        if (event.isSuccess) {
          emit( state.copyWith(
            isLoading: false,
            configuration: event.configuration,
          ));
        } else {
          emit( state.copyWith(
            isLoading: false,
          ));
          //TODO maybe inform user somehow
        }
      }
    });
  }

  final ServerAdapter _server = ServerAdapter.get;

  /*@override
  Stream<ConfigurationState> mapEventToState(ConfigurationEvent event) async* {
    if (event is ReloadRequested) {
      yield state.copyWith(
        isLoading: true,
      );
      await _server.cleanRemoteConfig();
      _loadConfigData();
    }
    if (event is ConfigurationLoadFinished) {
      if (event.isSuccess) {
        yield state.copyWith(
          isLoading: false,
          configuration: event.configuration,
        );
      } else {
        yield state.copyWith(
          isLoading: false,
        );
        //TODO maybe inform user somehow
      }
    }
  }*/

  // //
  /// Loads configs from the server
  void _loadConfigData() {
    _server.getRemoteConfig(
      onSuccess: (config) {
        add(ConfigurationLoadFinished(
          isSuccess: true,
          configuration: config,
        ));
      },
      onError: (error) {
        add(const ConfigurationLoadFinished(isSuccess: false));
      },
    );
  }
}
