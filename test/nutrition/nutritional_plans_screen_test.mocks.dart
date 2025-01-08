// Mocks generated by Mockito 5.4.5 from annotations
// in wger/test/nutrition/nutritional_plans_screen_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:convert' as _i9;
import 'dart:typed_data' as _i10;
import 'dart:ui' as _i7;

import 'package:http/http.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i6;
import 'package:package_info_plus/package_info_plus.dart' as _i4;
import 'package:wger/providers/auth.dart' as _i3;
import 'package:wger/providers/base_provider.dart' as _i8;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeClient_0 extends _i1.SmartFake implements _i2.Client {
  _FakeClient_0(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeAuthProvider_1 extends _i1.SmartFake implements _i3.AuthProvider {
  _FakeAuthProvider_1(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeUri_2 extends _i1.SmartFake implements Uri {
  _FakeUri_2(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeResponse_3 extends _i1.SmartFake implements _i2.Response {
  _FakeResponse_3(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

class _FakeStreamedResponse_4 extends _i1.SmartFake
    implements _i2.StreamedResponse {
  _FakeStreamedResponse_4(Object parent, Invocation parentInvocation)
      : super(parent, parentInvocation);
}

/// A class which mocks [AuthProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthProvider extends _i1.Mock implements _i3.AuthProvider {
  MockAuthProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set token(String? _token) => super.noSuchMethod(
        Invocation.setter(#token, _token),
        returnValueForMissingStub: null,
      );

  @override
  set serverUrl(String? _serverUrl) => super.noSuchMethod(
        Invocation.setter(#serverUrl, _serverUrl),
        returnValueForMissingStub: null,
      );

  @override
  set serverVersion(String? _serverVersion) => super.noSuchMethod(
        Invocation.setter(#serverVersion, _serverVersion),
        returnValueForMissingStub: null,
      );

  @override
  set applicationVersion(_i4.PackageInfo? _applicationVersion) =>
      super.noSuchMethod(
        Invocation.setter(#applicationVersion, _applicationVersion),
        returnValueForMissingStub: null,
      );

  @override
  Map<String, String> get metadata => (super.noSuchMethod(
        Invocation.getter(#metadata),
        returnValue: <String, String>{},
      ) as Map<String, String>);

  @override
  set metadata(Map<String, String>? _metadata) => super.noSuchMethod(
        Invocation.setter(#metadata, _metadata),
        returnValueForMissingStub: null,
      );

  @override
  _i2.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_0(this, Invocation.getter(#client)),
      ) as _i2.Client);

  @override
  set client(_i2.Client? _client) => super.noSuchMethod(
        Invocation.setter(#client, _client),
        returnValueForMissingStub: null,
      );

  @override
  bool get dataInit =>
      (super.noSuchMethod(Invocation.getter(#dataInit), returnValue: false)
          as bool);

  @override
  set dataInit(bool? _dataInit) => super.noSuchMethod(
        Invocation.setter(#dataInit, _dataInit),
        returnValueForMissingStub: null,
      );

  @override
  bool get isAuth =>
      (super.noSuchMethod(Invocation.getter(#isAuth), returnValue: false)
          as bool);

  @override
  bool get hasListeners =>
      (super.noSuchMethod(Invocation.getter(#hasListeners), returnValue: false)
          as bool);

  @override
  _i5.Future<void> setServerVersion() => (super.noSuchMethod(
        Invocation.method(#setServerVersion, []),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> setApplicationVersion() => (super.noSuchMethod(
        Invocation.method(#setApplicationVersion, []),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> initVersions(String? serverUrl) => (super.noSuchMethod(
        Invocation.method(#initVersions, [serverUrl]),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<bool> applicationUpdateRequired([
    String? version,
    Map<String, String>? metadata,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(#applicationUpdateRequired, [version, metadata]),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<Map<String, _i3.LoginActions>> register({
    required String? username,
    required String? password,
    required String? email,
    required String? serverUrl,
    String? locale = 'en',
  }) =>
      (super.noSuchMethod(
        Invocation.method(#register, [], {
          #username: username,
          #password: password,
          #email: email,
          #serverUrl: serverUrl,
          #locale: locale,
        }),
        returnValue: _i5.Future<Map<String, _i3.LoginActions>>.value(
          <String, _i3.LoginActions>{},
        ),
      ) as _i5.Future<Map<String, _i3.LoginActions>>);

  @override
  _i5.Future<Map<String, _i3.LoginActions>> login(
    String? username,
    String? password,
    String? serverUrl,
  ) =>
      (super.noSuchMethod(
        Invocation.method(#login, [username, password, serverUrl]),
        returnValue: _i5.Future<Map<String, _i3.LoginActions>>.value(
          <String, _i3.LoginActions>{},
        ),
      ) as _i5.Future<Map<String, _i3.LoginActions>>);

  @override
  _i5.Future<String> getServerUrlFromPrefs() => (super.noSuchMethod(
        Invocation.method(#getServerUrlFromPrefs, []),
        returnValue: _i5.Future<String>.value(
          _i6.dummyValue<String>(
            this,
            Invocation.method(#getServerUrlFromPrefs, []),
          ),
        ),
      ) as _i5.Future<String>);

  @override
  _i5.Future<bool> tryAutoLogin() => (super.noSuchMethod(
        Invocation.method(#tryAutoLogin, []),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  _i5.Future<void> logout({bool? shouldNotify = true}) => (super.noSuchMethod(
        Invocation.method(#logout, [], {#shouldNotify: shouldNotify}),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  String getAppNameHeader() => (super.noSuchMethod(
        Invocation.method(#getAppNameHeader, []),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.method(#getAppNameHeader, []),
        ),
      ) as String);

  @override
  void addListener(_i7.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(#addListener, [listener]),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i7.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(#removeListener, [listener]),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(#dispose, []),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(#notifyListeners, []),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [WgerBaseProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockWgerBaseProvider extends _i1.Mock implements _i8.WgerBaseProvider {
  MockWgerBaseProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.AuthProvider get auth => (super.noSuchMethod(
        Invocation.getter(#auth),
        returnValue: _FakeAuthProvider_1(this, Invocation.getter(#auth)),
      ) as _i3.AuthProvider);

  @override
  set auth(_i3.AuthProvider? _auth) => super.noSuchMethod(
        Invocation.setter(#auth, _auth),
        returnValueForMissingStub: null,
      );

  @override
  _i2.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_0(this, Invocation.getter(#client)),
      ) as _i2.Client);

  @override
  set client(_i2.Client? _client) => super.noSuchMethod(
        Invocation.setter(#client, _client),
        returnValueForMissingStub: null,
      );

  @override
  Map<String, String> getDefaultHeaders({bool? includeAuth = false}) =>
      (super.noSuchMethod(
        Invocation.method(#getDefaultHeaders, [], {
          #includeAuth: includeAuth,
        }),
        returnValue: <String, String>{},
      ) as Map<String, String>);

  @override
  Uri makeUrl(
    String? path, {
    int? id,
    String? objectMethod,
    Map<String, dynamic>? query,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #makeUrl,
          [path],
          {#id: id, #objectMethod: objectMethod, #query: query},
        ),
        returnValue: _FakeUri_2(
          this,
          Invocation.method(
            #makeUrl,
            [path],
            {#id: id, #objectMethod: objectMethod, #query: query},
          ),
        ),
      ) as Uri);

  @override
  _i5.Future<Map<String, dynamic>> fetch(Uri? uri) => (super.noSuchMethod(
        Invocation.method(#fetch, [uri]),
        returnValue: _i5.Future<Map<String, dynamic>>.value(
          <String, dynamic>{},
        ),
      ) as _i5.Future<Map<String, dynamic>>);

  @override
  _i5.Future<List<dynamic>> fetchPaginated(Uri? uri) => (super.noSuchMethod(
        Invocation.method(#fetchPaginated, [uri]),
        returnValue: _i5.Future<List<dynamic>>.value(<dynamic>[]),
      ) as _i5.Future<List<dynamic>>);

  @override
  _i5.Future<Map<String, dynamic>> post(Map<String, dynamic>? data, Uri? uri) =>
      (super.noSuchMethod(
        Invocation.method(#post, [data, uri]),
        returnValue: _i5.Future<Map<String, dynamic>>.value(
          <String, dynamic>{},
        ),
      ) as _i5.Future<Map<String, dynamic>>);

  @override
  _i5.Future<Map<String, dynamic>> patch(
    Map<String, dynamic>? data,
    Uri? uri,
  ) =>
      (super.noSuchMethod(
        Invocation.method(#patch, [data, uri]),
        returnValue: _i5.Future<Map<String, dynamic>>.value(
          <String, dynamic>{},
        ),
      ) as _i5.Future<Map<String, dynamic>>);

  @override
  _i5.Future<_i2.Response> deleteRequest(String? url, int? id) =>
      (super.noSuchMethod(
        Invocation.method(#deleteRequest, [url, id]),
        returnValue: _i5.Future<_i2.Response>.value(
          _FakeResponse_3(
            this,
            Invocation.method(#deleteRequest, [url, id]),
          ),
        ),
      ) as _i5.Future<_i2.Response>);
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i2.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i2.Response> head(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
        Invocation.method(#head, [url], {#headers: headers}),
        returnValue: _i5.Future<_i2.Response>.value(
          _FakeResponse_3(
            this,
            Invocation.method(#head, [url], {#headers: headers}),
          ),
        ),
      ) as _i5.Future<_i2.Response>);

  @override
  _i5.Future<_i2.Response> get(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
        Invocation.method(#get, [url], {#headers: headers}),
        returnValue: _i5.Future<_i2.Response>.value(
          _FakeResponse_3(
            this,
            Invocation.method(#get, [url], {#headers: headers}),
          ),
        ),
      ) as _i5.Future<_i2.Response>);

  @override
  _i5.Future<_i2.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i9.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i5.Future<_i2.Response>.value(
          _FakeResponse_3(
            this,
            Invocation.method(
              #post,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i5.Future<_i2.Response>);

  @override
  _i5.Future<_i2.Response> put(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i9.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i5.Future<_i2.Response>.value(
          _FakeResponse_3(
            this,
            Invocation.method(
              #put,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i5.Future<_i2.Response>);

  @override
  _i5.Future<_i2.Response> patch(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i9.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #patch,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i5.Future<_i2.Response>.value(
          _FakeResponse_3(
            this,
            Invocation.method(
              #patch,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i5.Future<_i2.Response>);

  @override
  _i5.Future<_i2.Response> delete(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i9.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [url],
          {#headers: headers, #body: body, #encoding: encoding},
        ),
        returnValue: _i5.Future<_i2.Response>.value(
          _FakeResponse_3(
            this,
            Invocation.method(
              #delete,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
          ),
        ),
      ) as _i5.Future<_i2.Response>);

  @override
  _i5.Future<String> read(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
        Invocation.method(#read, [url], {#headers: headers}),
        returnValue: _i5.Future<String>.value(
          _i6.dummyValue<String>(
            this,
            Invocation.method(#read, [url], {#headers: headers}),
          ),
        ),
      ) as _i5.Future<String>);

  @override
  _i5.Future<_i10.Uint8List> readBytes(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(#readBytes, [url], {#headers: headers}),
        returnValue: _i5.Future<_i10.Uint8List>.value(_i10.Uint8List(0)),
      ) as _i5.Future<_i10.Uint8List>);

  @override
  _i5.Future<_i2.StreamedResponse> send(_i2.BaseRequest? request) =>
      (super.noSuchMethod(
        Invocation.method(#send, [request]),
        returnValue: _i5.Future<_i2.StreamedResponse>.value(
          _FakeStreamedResponse_4(
            this,
            Invocation.method(#send, [request]),
          ),
        ),
      ) as _i5.Future<_i2.StreamedResponse>);

  @override
  void close() => super.noSuchMethod(
        Invocation.method(#close, []),
        returnValueForMissingStub: null,
      );
}
