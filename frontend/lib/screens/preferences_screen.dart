import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/services/api/preferences_service.dart';
import 'package:frontend/services/preferences_manager.dart';
import 'package:frontend/utils/snackbar.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedTheme;
  String? _selectedLocalization;
  bool _showAssignedCardsInHomepage = true;
  bool _preferencesUpdated = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final preferences = await PreferencesService.getPreferences();

      if (mounted) {
        setState(() {
          _selectedTheme = preferences.theme;
          _selectedLocalization = preferences.localization;
          _showAssignedCardsInHomepage =
              preferences.showAssignedCardsInHomepage;
          _isLoading = false;
        });

        // Sync API preferences with local preferences manager
        PreferencesManager().update(
          localization: preferences.localization,
          theme: preferences.theme,
          showAssignedCardsInHomepage: preferences.showAssignedCardsInHomepage,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updatePreferences({
    String? theme,
    String? localization,
    bool? showAssignedCardsInHomepage,
  }) async {
    try {
      final updatedPreferences = await PreferencesService.updatePreferences(
        theme: theme,
        localization: localization,
        showAssignedCardsInHomepage: showAssignedCardsInHomepage,
      );

      if (mounted) {
        setState(() {
          _selectedTheme = updatedPreferences.theme;
          _selectedLocalization = updatedPreferences.localization;
          _showAssignedCardsInHomepage =
              updatedPreferences.showAssignedCardsInHomepage;
          _preferencesUpdated = true;
        });

        // Sync with local preferences manager for immediate effect
        if (localization != null) {
          await PreferencesManager().setLocalization(localization);
        }
        if (theme != null) {
          await PreferencesManager().setTheme(theme);
        }
        if (showAssignedCardsInHomepage != null) {
          await PreferencesManager().setShowAssignedCardsInHomepage(
            showAssignedCardsInHomepage,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showSnackBarError(
          context,
          l10n.failedToUpdatePreferences(e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, bool? result) {
        if (!didPop) {
          // Show snackbar if preferences were updated
          if (_preferencesUpdated) {
            showSnackBarSuccess(context, l10n.preferencesUpdatedSuccessfully);
          }
          // Pop with the result indicating if preferences were updated
          Navigator.of(context).pop(_preferencesUpdated);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.preferences)),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.failedToLoadPreferences(_errorMessage!),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadPreferences,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appearance Settings Section
                    Text(
                      l10n.appearanceSettings,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.theme,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<String>(
                              segments: [
                                ButtonSegment(
                                  value: 'light',
                                  label: Text(l10n.light),
                                  icon: const Icon(Icons.light_mode),
                                ),
                                ButtonSegment(
                                  value: 'dark',
                                  label: Text(l10n.dark),
                                  icon: const Icon(Icons.dark_mode),
                                ),
                                ButtonSegment(
                                  value: 'system',
                                  label: Text(l10n.system),
                                  icon: const Icon(Icons.brightness_auto),
                                ),
                              ],
                              selected: {_selectedTheme ?? 'system'},
                              onSelectionChanged: (Set<String> selection) {
                                final newTheme = selection.first;
                                setState(() {
                                  _selectedTheme = newTheme;
                                });
                                _updatePreferences(theme: newTheme);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.language,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'en',
                                  label: Text('EN'),
                                  icon: Text('🇬🇧'),
                                ),
                                ButtonSegment(
                                  value: 'fr',
                                  label: Text('FR'),
                                  icon: Text('🇫🇷'),
                                ),
                              ],
                              selected: {_selectedLocalization ?? 'en'},
                              onSelectionChanged: (Set<String> selection) {
                                final newLocalization = selection.first;
                                setState(() {
                                  _selectedLocalization = newLocalization;
                                });
                                _updatePreferences(
                                  localization: newLocalization,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Display Settings Section
                    Text(
                      l10n.displaySettings,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: SwitchListTile(
                        title: Text(l10n.showAssignedCards),
                        subtitle: Text(
                          l10n.showAssignedCardsInHomepageDescription,
                        ),
                        value: _showAssignedCardsInHomepage,
                        onChanged: (bool value) {
                          setState(() {
                            _showAssignedCardsInHomepage = value;
                          });
                          _updatePreferences(
                            showAssignedCardsInHomepage: value,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
