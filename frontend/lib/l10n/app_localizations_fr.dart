// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get login => 'Connexion';

  @override
  String get register => 'S\'inscrire';

  @override
  String get email => 'E-mail';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get loginTitle => 'MyTrello - Connexion';

  @override
  String get registerTitle => 'MyTrello - Inscription';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get registerButton => 'S\'inscrire';

  @override
  String get pleaseEnterEmail => 'Veuillez entrer votre e-mail';

  @override
  String get pleaseEnterValidEmail =>
      'Veuillez entrer une adresse e-mail valide';

  @override
  String get pleaseEnterUsername => 'Veuillez entrer votre nom d\'utilisateur';

  @override
  String get pleaseEnterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get loginSuccessful => 'Connexion réussie !';

  @override
  String loginFailed(String error) {
    return 'Échec de la connexion : $error';
  }

  @override
  String get registrationSuccessful => 'Inscription réussie !';

  @override
  String registrationFailed(String error) {
    return 'Échec de l\'inscription : $error';
  }

  @override
  String get home => 'Accueil';

  @override
  String get createBoard => 'Créer un tableau';

  @override
  String get boardTitle => 'Titre du tableau';

  @override
  String get title => 'Titre';

  @override
  String get usersAndPermissions => 'Utilisateurs et permissions';

  @override
  String get addUser => 'Ajouter un utilisateur';

  @override
  String get noUsersAddedYet => 'Aucun utilisateur ajouté';

  @override
  String get member => 'Membre';

  @override
  String get viewer => 'Observateur';

  @override
  String get owner => 'Propriétaire';

  @override
  String get boardCreatedSuccessfully => 'Tableau créé avec succès !';

  @override
  String failedToCreateBoard(String error) {
    return 'Échec de la création du tableau : $error';
  }

  @override
  String get pleaseEnterBoardTitle => 'Veuillez entrer un titre de tableau';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get add => 'Ajouter';

  @override
  String get remove => 'Retirer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get search => 'Rechercher';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get logout => 'Déconnexion';

  @override
  String get boardSettings => 'Paramètres du tableau';

  @override
  String get deleteBoard => 'Supprimer le tableau';

  @override
  String get areYouSureDeleteBoard =>
      'Êtes-vous sûr de vouloir supprimer ce tableau ?';

  @override
  String get card => 'Carte';

  @override
  String get column => 'Colonne';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get startDate => 'Date de début';

  @override
  String get description => 'Description';

  @override
  String get addCard => 'Ajouter une carte';

  @override
  String get userSettings => 'Paramètres utilisateur';

  @override
  String get accountSettings => 'Paramètres du compte';

  @override
  String get preferences => 'Préférences';

  @override
  String get appPreferences => 'Préférences de l\'application';

  @override
  String get appearanceSettings => 'Paramètres d\'apparence';

  @override
  String get displaySettings => 'Paramètres d\'affichage';

  @override
  String get theme => 'Thème';

  @override
  String get language => 'Langue';

  @override
  String get dark => 'Sombre';

  @override
  String get light => 'Clair';

  @override
  String get system => 'Système';

  @override
  String get showAssignedCards => 'Afficher les cartes assignées';

  @override
  String get showAssignedCardsInHomepageDescription =>
      'Afficher les cartes assignées sur l\'écran d\'accueil';

  @override
  String get preferencesUpdatedSuccessfully =>
      'Préférences mises à jour avec succès';

  @override
  String failedToUpdatePreferences(String error) {
    return 'Échec de la mise à jour des préférences : $error';
  }

  @override
  String failedToLoadPreferences(String error) {
    return 'Échec du chargement des préférences : $error';
  }

  @override
  String get accountInformation => 'Informations du compte';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get boardTitleCannotBeEmpty =>
      'Le titre du tableau ne peut pas être vide';

  @override
  String get boardUpdatedSuccessfully => 'Tableau mis à jour avec succès !';

  @override
  String failedToUpdateBoard(String error) {
    return 'Échec de la mise à jour du tableau : $error';
  }

  @override
  String areYouSureDeleteBoardWithName(String boardName) {
    return 'Êtes-vous sûr de vouloir supprimer \"$boardName\" ? Cette action est irréversible.';
  }

  @override
  String get boardDeletedSuccessfully => 'Tableau supprimé avec succès';

  @override
  String failedToDeleteBoard(String error) {
    return 'Échec de la suppression du tableau : $error';
  }

  @override
  String get boardOwner => 'Propriétaire du tableau';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get usernameCannotBeEmpty =>
      'Le nom d\'utilisateur ne peut pas être vide';

  @override
  String get newUsernameMustBeDifferent =>
      'Le nouveau nom d\'utilisateur doit être différent de l\'actuel';

  @override
  String get usernameUpdatedSuccessfully =>
      'Nom d\'utilisateur mis à jour avec succès';

  @override
  String get allFieldsRequired => 'Tous les champs sont requis';

  @override
  String get newEmailMustBeDifferent =>
      'Le nouvel e-mail doit être différent de l\'actuel';

  @override
  String get emailUpdatedSuccessfully => 'E-mail mis à jour avec succès';

  @override
  String get newPasswordsDoNotMatch =>
      'Les nouveaux mots de passe ne correspondent pas';

  @override
  String get newPasswordMustBeDifferent =>
      'Le nouveau mot de passe doit être différent de l\'actuel';

  @override
  String get passwordUpdatedSuccessfully =>
      'Mot de passe mis à jour avec succès';

  @override
  String get homeTitle => 'MyTrello - Accueil';

  @override
  String get createNewBoard => 'Créer un nouveau tableau';

  @override
  String get errorLoadingBoards => 'Erreur lors du chargement des tableaux';

  @override
  String get backendServerMayBeDown =>
      'Le serveur backend est peut-être hors ligne ou inaccessible.';

  @override
  String get retry => 'Réessayer';

  @override
  String get noBoardsYet => 'Aucun tableau pour le moment';

  @override
  String get createFirstBoard => 'Créez votre premier tableau pour commencer !';

  @override
  String get searchCards => 'Rechercher des cartes...';

  @override
  String get updateUsername => 'Mettre à jour le nom d\'utilisateur';

  @override
  String get newUsername => 'Nouveau nom d\'utilisateur';

  @override
  String get updateEmail => 'Mettre à jour l\'email';

  @override
  String get newEmail => 'Nouvel email';

  @override
  String get updatePassword => 'Mettre à jour le mot de passe';

  @override
  String failedToLoadBoardSettings(String error) {
    return 'Échec du chargement des paramètres du tableau : $error';
  }

  @override
  String get deleteCard => 'Supprimer la carte';

  @override
  String deleteCardConfirmation(String cardTitle) {
    return 'Êtes-vous sûr de vouloir supprimer \"$cardTitle\" ?';
  }

  @override
  String deleteColumnConfirmation(String columnTitle) {
    return 'Êtes-vous sûr de vouloir supprimer la colonne \"$columnTitle\"? Toutes les cartes de cette colonne seront supprimées.';
  }

  @override
  String get deleteCardTooltip => 'Supprimer la carte';

  @override
  String get assignUsersTooltip => 'Assigner des utilisateurs';

  @override
  String get setDeadlinesTooltip => 'Définir les échéances';

  @override
  String get cardTitle => 'Titre de la carte';

  @override
  String get cardDescription => 'Description de la carte';

  @override
  String get assignedToYou => 'Assignées à vous';

  @override
  String get yourBoards => 'Vos tableaux';

  @override
  String membersViewersCount(int members, int viewers) {
    return '$members membres, $viewers observateurs';
  }

  @override
  String get columnTitle => 'Titre de la colonne';

  @override
  String get dropHere => 'Déposer ici';

  @override
  String get noCards => 'Aucune carte';

  @override
  String get deleteColumn => 'Supprimer la colonne';

  @override
  String cardsCount(int count) {
    return '$count cartes';
  }

  @override
  String get newColumn => 'Nouvelle colonne';

  @override
  String get unassignUser => 'Désassigner l\'utilisateur';

  @override
  String removeUserFromCard(String username) {
    return 'Retirer $username de cette carte ?';
  }

  @override
  String get unassign => 'Désassigner';

  @override
  String get addCardDialog => 'Ajouter une carte';

  @override
  String get boardChat => 'Chat du tableau';

  @override
  String get typeMessage => 'Écrire un message';

  @override
  String get send => 'Envoyer';

  @override
  String get setDeadlines => 'Définir les échéances';

  @override
  String get selectDate => 'Sélectionner une date';

  @override
  String get clearStartDate => 'Effacer la date de début';

  @override
  String get clearDueDate => 'Effacer la date d\'échéance';

  @override
  String durationDays(int days) {
    return 'Durée : $days jours';
  }

  @override
  String get selectStartDate => 'Sélectionner la date de début';

  @override
  String get selectDueDate => 'Sélectionner la date d\'échéance';

  @override
  String failedToLoadUsers(String error) {
    return 'Échec du chargement des utilisateurs : $error';
  }

  @override
  String searchFailed(String error) {
    return 'Échec de la recherche : $error';
  }

  @override
  String get noUsersFound => 'Aucun utilisateur trouvé.';
}
