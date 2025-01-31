import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:smart_list/providers/auth_provider.dart';
import 'package:smart_list/views/auth/login_screen.dart';
import 'package:smart_list/views/auth/signup_screen.dart';
import 'package:smart_list/views/contact/contact_details.dart';
import 'package:smart_list/views/contact/contact_form.dart';
import 'package:smart_list/views/home/home_screen.dart';
import 'package:smart_list/views/settings/settings_screen.dart';

class AppRoutes {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
        routes: [
          GoRoute(
            path: 'new-contact',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const ContactForm(),
            ),
          ),
          GoRoute(
            path: 'settings',
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: SettingsScreen(),
            ),
          ),
          GoRoute(
            path: 'contact/:id',
            pageBuilder: (context, state) => MaterialPage(
              child: ContactDetailsScreen(
                contactId: state.params['id']!,
              ),
            ),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (!auth.isInitialized) return null;

      final isLoggedIn = auth.currentUser != null;
      final isAuthRoute = state.location.startsWith('/login') || state.location.startsWith('/signup');

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
  );
}
