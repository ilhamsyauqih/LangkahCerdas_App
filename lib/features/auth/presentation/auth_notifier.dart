import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../domain/user_model.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authNotifierProvider = NotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(AuthNotifier.new);

class AuthNotifier extends Notifier<AsyncValue<UserModel?>> {
  late AuthRepository _repository;

  @override
  AsyncValue<UserModel?> build() {
    _repository = ref.watch(authRepositoryProvider);
    final user = _repository.getCurrentUser();
    return AsyncValue.data(user);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(name, email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(String name, String? avatar) async {
    // Keep the previous state if we want to show loading silently, but for now simple loading is fine
    // Actually, setting state to loading might clear the UI. Let's use AsyncData directly or preserve data.
    final previousData = state.value;
    state = const AsyncValue.loading();
    try {
      final user = await _repository.updateProfile(name, avatar);
      state = AsyncValue.data(user);
    } catch (e, st) {
      // Restore previous data on error
      state = AsyncValue.data(previousData);
      // We could also throw or show error, but restoring data prevents UI blanking
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}
