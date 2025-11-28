import 'package:frontend/auth_service.dart';
import 'package:frontend/models/board.dart';

/// Service to manage board permissions and check user roles
class BoardPermissionsService {
  static Board? _currentBoard;

  /// Set the current board (called when connecting to a board)
  static void setCurrentBoard(Board board) {
    _currentBoard = board;
  }

  /// Clear the current board (called when disconnecting)
  static void clearCurrentBoard() {
    _currentBoard = null;
  }

  /// Check if the current user is the owner of the board
  static bool get isOwner {
    if (_currentBoard == null) return false;
    return _currentBoard!.ownerId == AuthService.userId;
  }

  /// Check if the current user is a member of the board
  static bool get isMember {
    if (_currentBoard == null) return false;
    return _currentBoard!.members.any(
      (member) => member.id == AuthService.userId,
    );
  }

  /// Check if the current user is a viewer of the board
  static bool get isViewer {
    if (_currentBoard == null) return false;
    return _currentBoard!.viewers.any(
      (viewer) => viewer.id == AuthService.userId,
    );
  }

  /// Check if the current user can edit the board (owner or member, but not viewer)
  static bool get canEdit {
    if (_currentBoard == null) return false;
    // Viewers cannot edit, even if they're also in members list
    if (isViewer) return false;
    return isOwner || isMember;
  }

  /// Check if the current user can view the board (any role)
  static bool get canView {
    return isOwner || isMember || isViewer;
  }
}
