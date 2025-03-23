part of 'app_user_cubit.dart';

@immutable
sealed class AppUserState {}

final class AppUserInitial extends AppUserState {}

final class AppUserLoggedIn extends AppUserState {
  final UserType user;
  AppUserLoggedIn(this.user); 
}

final class AppUserGuest extends AppUserState {}

final class AppUserSignOut extends AppUserState {}

