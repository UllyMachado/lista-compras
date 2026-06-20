import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lista_compras/domain/repositories/auth_repository.dart';
import 'package:lista_compras/presentation/state/auth_provider.dart';
import 'package:lista_compras/data/datasources/remote/auth_remote_datasource.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockAuthRepository mockRepository;
  late AuthProvider provider;

  setUp(() {
    mockRepository = MockAuthRepository();
    provider = AuthProvider(mockRepository);
  });

  group('AuthProvider Tests', () {
    test('initial state is unauthenticated', () {
      expect(provider.isAuthenticated, false);
    });

    test('login success sets isAuthenticated to true', () async {
      when(() => mockRepository.login('test@test.com', 'password'))
          .thenAnswer((_) async => AuthTokenResponse(
                accessToken: 'access',
                refreshToken: 'refresh',
                expiresIn: 3600,
                tokenType: 'Bearer',
              ));
      when(() => mockRepository.saveTokens('access', 'refresh'))
          .thenAnswer((_) async => {});

      final result = await provider.login('test@test.com', 'password');

      expect(result, true);
      expect(provider.isAuthenticated, true);
      verify(() => mockRepository.login('test@test.com', 'password')).called(1);
      verify(() => mockRepository.saveTokens('access', 'refresh')).called(1);
    });

    test('login failure keeps isAuthenticated false', () async {
      when(() => mockRepository.login('test@test.com', 'wrong'))
          .thenThrow(Exception('Invalid credentials'));

      final result = await provider.login('test@test.com', 'wrong');

      expect(result, false);
      expect(provider.isAuthenticated, false);
    });

    test('logout resets isAuthenticated to false', () async {
      when(() => mockRepository.login('test@test.com', 'password'))
          .thenAnswer((_) async => AuthTokenResponse(
                accessToken: 'access',
                refreshToken: 'refresh',
                expiresIn: 3600,
                tokenType: 'Bearer',
              ));
      when(() => mockRepository.saveTokens('access', 'refresh'))
          .thenAnswer((_) async => {});
      await provider.login('test@test.com', 'password');
      expect(provider.isAuthenticated, true);

      when(() => mockRepository.clearTokens()).thenAnswer((_) async => {});
      await provider.logout();

      expect(provider.isAuthenticated, false);
      verify(() => mockRepository.clearTokens()).called(1);
    });
  });
}
