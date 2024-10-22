class MainState {}

class MainInitial extends MainState {}

class MainSuccess extends MainState {}

class MainDrawerSuccess extends MainState {}

class ChangeIndexSuccussStates extends MainState {}

class ChangeIndex extends MainState {}

class LogOutUserLoading extends MainState {}

class LogOutUserSuccess extends MainState {}

class NavigateToPageState extends MainState {}

class DrawerItemsLoaded extends MainState {}

class PageTransitionStarted extends MainState {
  final int newIndex;
  PageTransitionStarted(this.newIndex);
}

class PageTransitionCompleted extends MainState {
  final int newIndex;
  PageTransitionCompleted(this.newIndex);
}

class ChangeViewState extends MainState {}

class GetCapabilitiesLoading extends MainState {}

class GetCapabilitiesSuccess extends MainState {}

class ConnectionSuccess extends MainState {}

class EnableBack extends MainState {}

class NotificationBadge extends MainState {}
