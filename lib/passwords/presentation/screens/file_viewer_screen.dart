import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pcrypt/authentication/bloc/authentication.dart';
import 'package:pcrypt/model/attachment.dart';
import 'package:pcrypt/model/pcrypt_key.dart';
import 'package:pcrypt/passwords/bloc/file_viewer.dart';
import 'package:pcrypt/util/strings.dart';

import '../../../widget/custom_widgets.dart';

enum _PdfLoadingState { needsReload, reloading, loaded }

/// Screen used to view file details
class FileViewerScreen extends StatefulWidget {
  const FileViewerScreen(
    this.file, {
    this.ownerId = -1,
    this.publicKey,
    this.teamId = -1,
    this.teamKey,
  });

  final Attachment file;
  final int ownerId;
  final PCryptKey? publicKey;
  final int teamId;
  final String? teamKey;

  @override
  State<StatefulWidget> createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewerScreen>
    with WidgetsBindingObserver {
  _PdfLoadingState _pdfState = _PdfLoadingState.loaded;
  int _pdfPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {
      if (Platform.isAndroid) {
        _pdfState = _PdfLoadingState.needsReload;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileViewerBloc>(
      create: (_) => FileViewerBloc(
        file: widget.file,
        ownerId: widget.ownerId,
        publicKey: widget.publicKey,
        teamId: widget.teamId,
        teamKey: widget.teamKey,
      ),
      child: BlocListener<FileViewerBloc, FileViewerState>(
        listener: (context, state) {
          if (state is SessionExpiredState) {
            BlocProvider.of<AuthenticationBloc>(context)
                .add(SessionExpiredEvent());
          }
          if (state is ConnectionErrorState) {
            connectionError(context, state.errorMessage);
          }
        },
        child: BlocBuilder<FileViewerBloc, FileViewerState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(state.title),
              ),
              body: Stack(
                children: <Widget>[
                  _buildContent(context, state),
                  state.isLoading
                      ? const LinearProgressIndicator()
                      : const SizedBox(height: 0.0),
                ],
              ),
              resizeToAvoidBottomInset: false,
            );
          },
        ),
      ),
    );
  }

  /// Method to build body (different widgets based on file data)
  Widget _buildContent(BuildContext context, FileViewerState state) {
    if (state.isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              Strings.fileViewerErrorLoad,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              child: Text(Strings.actionRetry.toUpperCase()),
              onPressed: () {
                BlocProvider.of<FileViewerBloc>(context).add(RetryPressed());
              },
            )
          ],
        ),
      );
    }
    if (state.fileData == null) {
      return const SizedBox(height: 0.0);
    }
    switch (state.fileFormat) {
      case FileFormat.none:
        return const SizedBox(height: 0.0);
      case FileFormat.unknown:
        return Center(
          child: Text(
            Strings.fileViewerUnknownFormat,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        );
      case FileFormat.image:
        final image = FileImage(state.fileData!);
        image.evict();
        return Image(image: image);
      case FileFormat.pdf:
        if (_pdfState == _PdfLoadingState.needsReload) {
          _pdfState = _PdfLoadingState.reloading;
          Timer(const Duration(milliseconds: 300),
              () => setState(() => _pdfState = _PdfLoadingState.loaded));
        }
        if (_pdfState == _PdfLoadingState.reloading) {
          return Container();
        }
        if (Platform.isAndroid && _pdfState == _PdfLoadingState.loaded) {
          _pdfState = _PdfLoadingState.needsReload;
        }
        return PDFView(
          filePath: state.fileData!.path,
          swipeHorizontal: false,
          enableSwipe: true,
          onPageChanged: (int? page, int? total) {
            if (page != null) {
              _pdfPage = page;
            }
          },
          onViewCreated: (controller) {
            final int page = _pdfPage;
            Timer(const Duration(milliseconds: 300),
                () => controller.setPage(page));
          },
        );
      case FileFormat.text:
        return Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(state.fileData!.readAsStringSync()),
            ),
          ),
        );
    }
    //TODO other formats
  }
}
