# Authentication Service

**Version:** 1.0.0  
**Last Updated:** January 6, 2026  
**Package:** abdalsalam_logic_flutter

---

## Overview

The Authentication Service provides a unified interface for user authentication operations including sign-in, sign-up, password reset, and token management. It's designed to work with Firebase Auth or any custom authentication backend.

### Key Features

✅ **Email/Password Authentication** - Traditional email-based auth  
✅ **Token Management** - Auth token retrieval and refresh  
✅ **Session Management** - Check authentication status  
✅ **Password Reset** - Send password reset emails  
✅ **Backend-Agnostic** - Works with any auth provider  

---

## API Reference

### Interface: AuthService

```dart
abstract class AuthService extends ServiceInterface {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password, Map<String, dynamic>? additionalData);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<String?> getCurrentUserId();
  Future<bool> isAuthenticated();
  Future<String?> getAuthToken();
  Future<void> refreshToken();
}
```

### Methods

#### signIn()
```dart
Future<String> signIn(String email, String password)
```
Authenticates a user with email and password.

**Parameters:**
- `email` - User's email address
- `password` - User's password

**Returns:** User ID of the authenticated user

**Throws:** `AuthException` if authentication fails

**Example:**
```dart
try {
  final userId = await authService.signIn('user@example.com', 'password123');
  print('Signed in as: $userId');
} catch (e) {
  print('Sign in failed: $e');
}
```

---

#### signUp()
```dart
Future<String> signUp(String email, String password, Map<String, dynamic>? additionalData)
```
Creates a new user account.

**Parameters:**
- `email` - User's email address
- `password` - User's desired password
- `additionalData` - Optional user profile data (e.g., name, age)

**Returns:** User ID of the newly created user

**Throws:** `AuthException` if registration fails

**Example:**
```dart
try {
  final userId = await authService.signUp(
    'newuser@example.com',
    'securePassword123',
    {'displayName': 'John Doe', 'age': 25},
  );
  print('Account created: $userId');
} catch (e) {
  print('Sign up failed: $e');
}
```

---

#### signOut()
```dart
Future<void> signOut()
```
Signs out the current user and clears authentication state.

**Example:**
```dart
await authService.signOut();
print('User signed out');
```

---

#### resetPassword()
```dart
Future<void> resetPassword(String email)
```
Sends a password reset email to the user.

**Parameters:**
- `email` - User's email address

**Throws:** `AuthException` if email is invalid or not registered

**Example:**
```dart
try {
  await authService.resetPassword('user@example.com');
  print('Password reset email sent');
} catch (e) {
  print('Failed to send reset email: $e');
}
```

---

#### getCurrentUserId()
```dart
Future<String?> getCurrentUserId()
```
Gets the ID of the currently authenticated user.

**Returns:** User ID if authenticated, `null` otherwise

**Example:**
```dart
final userId = await authService.getCurrentUserId();
if (userId != null) {
  print('Current user: $userId');
} else {
  print('No user signed in');
}
```

---

#### isAuthenticated()
```dart
Future<bool> isAuthenticated()
```
Checks if a user is currently authenticated.

**Returns:** `true` if user is signed in, `false` otherwise

**Example:**
```dart
final isLoggedIn = await authService.isAuthenticated();
if (isLoggedIn) {
  navigateToHomePage();
} else {
  navigateToLoginPage();
}
```

---

#### getAuthToken()
```dart
Future<String?> getAuthToken()
```
Retrieves the current authentication token for API requests.

**Returns:** Auth token if available, `null` otherwise

**Example:**
```dart
final token = await authService.getAuthToken();
if (token != null) {
  apiClient.setAuthToken(token);
}
```

---

#### refreshToken()
```dart
Future<void> refreshToken()
```
Refreshes the authentication token (useful for expired tokens).

**Throws:** `AuthException` if refresh fails

**Example:**
```dart
try {
  await authService.refreshToken();
  print('Token refreshed successfully');
} catch (e) {
  print('Token refresh failed: $e');
}
```

---

## Usage Examples

### Example 1: Login Flow

```dart
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = GetIt.I<AuthService>();
  
  Future<void> _handleLogin() async {
    try {
      final userId = await _authService.signIn(
        _emailController.text,
        _passwordController.text,
      );
      
      // Navigate to home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: _handleLogin,
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Registration Flow

```dart
class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final AuthService _authService = GetIt.I<AuthService>();
  
  Future<void> _handleSignUp() async {
    try {
      final userId = await _authService.signUp(
        _emailController.text,
        _passwordController.text,
        {
          'displayName': _nameController.text,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Navigate to home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Full Name'),
          ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          ElevatedButton(
            onPressed: _handleSignUp,
            child: Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
```

### Example 3: Auth Guard

```dart
class AuthGuard extends StatelessWidget {
  final Widget child;
  final AuthService authService;
  
  const AuthGuard({
    required this.child,
    required this.authService,
  });
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: authService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }
        
        if (snapshot.data == true) {
          return child;
        }
        
        return LoginPage();
      },
    );
  }
}

// Usage
void main() {
  runApp(MaterialApp(
    home: AuthGuard(
      authService: GetIt.I<AuthService>(),
      child: HomePage(),
    ),
  ));
}
```

### Example 4: Password Reset

```dart
class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final AuthService _authService = GetIt.I<AuthService>();
  
  Future<void> _handleResetPassword() async {
    try {
      await _authService.resetPassword(_emailController.text);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent!')),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send reset email: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          ElevatedButton(
            onPressed: _handleResetPassword,
            child: Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }
}
```

### Example 5: Auto Token Refresh

```dart
class ApiService {
  final AuthService _authService;
  final ApiClient _apiClient;
  
  ApiService(this._authService, this._apiClient);
  
  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      // Get token and set it
      final token = await _authService.getAuthToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }
      
      // Make API call
      return await _apiClient.get('/user/profile');
    } catch (e) {
      // If unauthorized, try refreshing token
      if (e.toString().contains('401')) {
        await _authService.refreshToken();
        
        // Retry with new token
        final newToken = await _authService.getAuthToken();
        if (newToken != null) {
          _apiClient.setAuthToken(newToken);
        }
        
        return await _apiClient.get('/user/profile');
      }
      rethrow;
    }
  }
}
```

---

## Implementation

### Setup with Dependency Injection

```dart
import 'package:get_it/get_it.dart';
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

void setupServices() {
  final getIt = GetIt.instance;
  
  // Register auth service
  getIt.registerLazySingleton<AuthService>(
    () => AuthServiceImpl(
      firebaseAuth: FirebaseAuth.instance,
      logger: getIt<LoggerService>(),
    ),
  );
}
```

### Initialization

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup services
  setupServices();
  
  // Initialize auth service
  final authService = GetIt.I<AuthService>();
  await authService.initialize();
  
  runApp(MyApp());
}
```

---

## Best Practices

### 1. Always Handle Errors

✅ **DO**: Wrap auth calls in try-catch
```dart
try {
  await authService.signIn(email, password);
} catch (e) {
  showErrorDialog(e.toString());
}
```

❌ **DON'T**: Ignore errors
```dart
await authService.signIn(email, password); // May crash!
```

### 2. Check Authentication Status

✅ **DO**: Check before accessing protected resources
```dart
final isAuth = await authService.isAuthenticated();
if (isAuth) {
  loadUserData();
}
```

### 3. Store Tokens Securely

✅ **DO**: Let the auth service handle token storage
```dart
final token = await authService.getAuthToken();
```

❌ **DON'T**: Store tokens in SharedPreferences
```dart
prefs.setString('token', token); // Insecure!
```

### 4. Refresh Tokens Proactively

✅ **DO**: Refresh before expiration
```dart
// Refresh token every 50 minutes (if it expires in 1 hour)
Timer.periodic(Duration(minutes: 50), (_) async {
  await authService.refreshToken();
});
```

### 5. Clear State on Sign Out

✅ **DO**: Clean up after sign out
```dart
await authService.signOut();
await clearUserData();
await navigateToLogin();
```

---

## Error Handling

Common errors and how to handle them:

| Error | Cause | Solution |
|-------|-------|----------|
| `invalid-email` | Email format is invalid | Validate email before submission |
| `user-not-found` | Email not registered | Show "account not found" message |
| `wrong-password` | Incorrect password | Show "incorrect password" message |
| `email-already-in-use` | Email already registered | Navigate to login page |
| `weak-password` | Password too weak | Show password requirements |
| `network-request-failed` | No internet connection | Show offline message |

---

## Summary

The Authentication Service provides:

✅ **Complete auth flow** - Sign in, sign up, sign out, password reset  
✅ **Token management** - Get and refresh auth tokens  
✅ **Session management** - Check authentication status  
✅ **Backend-agnostic** - Works with Firebase or custom backends  
✅ **Error handling** - Clear error messages for all scenarios  

Integrate it with your app to handle user authentication seamlessly.
