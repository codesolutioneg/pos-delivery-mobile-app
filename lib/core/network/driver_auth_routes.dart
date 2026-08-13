/// Driver auth paths on DishFlow (`AppConfig.baseUrl` + `apiPrefix`).
///
/// Full URLs:
///   `{baseUrl}/v1/drivers/login|me|logout|refresh`
abstract final class DriverAuthRoutes {
  static const login = '/drivers/login';
  static const me = '/drivers/me';
  static const logout = '/drivers/logout';
  static const refresh = '/drivers/refresh';
}
