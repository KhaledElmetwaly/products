abstract class TaskStates {}

class initialState extends TaskStates {}

class productInsertToDatabaseState extends TaskStates {}

class TaskChangeModeState extends TaskStates {}

class GetDatabaseLoadingStates extends TaskStates {}

class GetDatabaseStates extends TaskStates {}

class ChangeButton extends TaskStates {}

class imagePickedState extends TaskStates {}

class getHomeLoadingState extends TaskStates {}

class getHomeSuccessState extends TaskStates {}

class getHomeErrorState extends TaskStates {
  final String error;

  getHomeErrorState(this.error);
}
